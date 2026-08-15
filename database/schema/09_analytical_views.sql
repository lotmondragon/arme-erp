-- ============================================================================
-- VISTAS ANALÍTICAS Y DE REPORTES
-- Vistas optimizadas para dashboards y reportes
-- ============================================================================

-- ============================================================================
-- VISTA: Dashboard Principal
-- ============================================================================
CREATE OR REPLACE VIEW v_dashboard_summary AS
SELECT
    -- Proyectos
    (SELECT COUNT(*) FROM projects WHERE is_active = true) AS total_projects,
    (SELECT COUNT(*) FROM projects WHERE status = 'in_progress' AND is_active = true) AS active_projects,
    (SELECT COUNT(*) FROM projects WHERE status = 'planning' AND is_active = true) AS planning_projects,
    (SELECT COUNT(*) FROM projects WHERE status = 'completed' AND is_active = true) AS completed_projects,
    
    -- Clientes
    (SELECT COUNT(*) FROM clients WHERE is_active = true) AS total_clients,
    (SELECT COUNT(*) FROM clients WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') AS new_clients_month,
    
    -- Financiero
    (SELECT COALESCE(SUM(total_amount), 0) FROM invoices WHERE invoice_type = 'income' AND status = 'paid') AS total_revenue,
    (SELECT COALESCE(SUM(total_amount), 0) FROM invoices WHERE invoice_type = 'expense' AND status = 'paid') AS total_expenses,
    (SELECT COALESCE(SUM(balance), 0) FROM invoices WHERE invoice_type = 'income' AND status != 'paid') AS pending_receivables,
    (SELECT COALESCE(SUM(balance), 0) FROM invoices WHERE invoice_type = 'expense' AND status != 'paid') AS pending_payables,
    
    -- Tareas
    (SELECT COUNT(*) FROM project_tasks WHERE status = 'pending' AND is_active = true) AS pending_tasks,
    (SELECT COUNT(*) FROM project_tasks WHERE status = 'in_progress' AND is_active = true) AS active_tasks,
    (SELECT COUNT(*) FROM project_tasks WHERE due_date < CURRENT_DATE AND status NOT IN ('completed', 'cancelled')) AS overdue_tasks,
    
    -- Inventario
    (SELECT COUNT(*) FROM materials WHERE current_stock <= minimum_stock AND is_active = true) AS low_stock_materials,
    
    CURRENT_TIMESTAMP AS generated_at;

COMMENT ON VIEW v_dashboard_summary IS 'Resumen ejecutivo para el dashboard principal';

-- ============================================================================
-- VISTA: Proyectos con Información Completa
-- ============================================================================
CREATE OR REPLACE VIEW v_projects_full AS
SELECT 
    p.id,
    p.project_code,
    p.name,
    p.description,
    p.status,
    p.progress_percentage,
    p.health_status,
    p.priority,
    
    -- Cliente
    c.id AS client_id,
    c.company_name AS client_name,
    c.contact_name AS client_contact,
    
    -- Responsables
    pm.id AS project_manager_id,
    pm.first_name || ' ' || pm.last_name AS project_manager_name,
    ss.id AS site_supervisor_id,
    ss.first_name || ' ' || ss.last_name AS site_supervisor_name,
    
    -- Fechas
    p.planned_start_date,
    p.planned_end_date,
    p.actual_start_date,
    p.actual_end_date,
    CASE 
        WHEN p.actual_end_date IS NOT NULL THEN p.actual_end_date - p.actual_start_date
        WHEN p.actual_start_date IS NOT NULL THEN CURRENT_DATE - p.actual_start_date
        ELSE NULL
    END AS days_elapsed,
    
    -- Financiero
    p.contract_amount,
    p.current_budget,
    p.total_expenses,
    p.total_income,
    p.profit_margin,
    CASE 
        WHEN p.current_budget > 0 THEN 
            ROUND(((p.total_expenses / p.current_budget) * 100)::NUMERIC, 2)
        ELSE 0
    END AS budget_utilization_percentage,
    
    -- Estadísticas
    (SELECT COUNT(*) FROM project_stages WHERE project_id = p.id AND is_active = true) AS total_stages,
    (SELECT COUNT(*) FROM project_stages WHERE project_id = p.id AND status = 'completed') AS completed_stages,
    (SELECT COUNT(*) FROM project_tasks WHERE project_id = p.id AND is_active = true) AS total_tasks,
    (SELECT COUNT(*) FROM project_tasks WHERE project_id = p.id AND status = 'completed') AS completed_tasks,
    (SELECT COUNT(*) FROM project_team WHERE project_id = p.id AND is_active = true) AS team_size,
    
    p.created_at,
    p.updated_at,
    p.is_active
FROM projects p
LEFT JOIN clients c ON p.client_id = c.id
LEFT JOIN users pm ON p.project_manager_id = pm.id
LEFT JOIN users ss ON p.site_supervisor_id = ss.id;

COMMENT ON VIEW v_projects_full IS 'Vista completa de proyectos con información relacionada';

-- ============================================================================
-- VISTA: Estado Financiero por Proyecto
-- ============================================================================
CREATE OR REPLACE VIEW v_project_financial_status AS
SELECT 
    p.id AS project_id,
    p.project_code,
    p.name AS project_name,
    p.status AS project_status,
    c.company_name AS client_name,
    
    -- Presupuesto
    p.contract_amount,
    p.current_budget,
    
    -- Ingresos
    COALESCE(SUM(CASE WHEN i.invoice_type = 'income' THEN i.total_amount ELSE 0 END), 0) AS total_invoiced,
    COALESCE(SUM(CASE WHEN i.invoice_type = 'income' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 0) AS total_collected,
    COALESCE(SUM(CASE WHEN i.invoice_type = 'income' AND i.status != 'paid' THEN i.balance ELSE 0 END), 0) AS pending_collection,
    
    -- Egresos
    COALESCE(SUM(CASE WHEN i.invoice_type = 'expense' THEN i.total_amount ELSE 0 END), 0) AS total_expenses_invoiced,
    COALESCE(SUM(CASE WHEN i.invoice_type = 'expense' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 0) AS total_expenses_paid,
    COALESCE(SUM(CASE WHEN i.invoice_type = 'expense' AND i.status != 'paid' THEN i.balance ELSE 0 END), 0) AS pending_payments,
    
    -- Utilidad
    COALESCE(SUM(CASE WHEN i.invoice_type = 'income' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 0) -
    COALESCE(SUM(CASE WHEN i.invoice_type = 'expense' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 0) AS net_profit,
    
    -- Margen
    CASE 
        WHEN COALESCE(SUM(CASE WHEN i.invoice_type = 'income' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 0) > 0 THEN
            ROUND((
                (COALESCE(SUM(CASE WHEN i.invoice_type = 'income' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 0) -
                 COALESCE(SUM(CASE WHEN i.invoice_type = 'expense' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 0)) /
                COALESCE(SUM(CASE WHEN i.invoice_type = 'income' AND i.status = 'paid' THEN i.total_amount ELSE 0 END), 1) * 100
            )::NUMERIC, 2)
        ELSE 0
    END AS profit_margin_percentage
    
FROM projects p
LEFT JOIN clients c ON p.client_id = c.id
LEFT JOIN invoices i ON p.id = i.project_id AND i.is_active = true
WHERE p.is_active = true
GROUP BY p.id, p.project_code, p.name, p.status, c.company_name, p.contract_amount, p.current_budget;

COMMENT ON VIEW v_project_financial_status IS 'Estado financiero detallado por proyecto';

-- ============================================================================
-- VISTA: Facturas Pendientes de Pago
-- ============================================================================
CREATE OR REPLACE VIEW v_pending_invoices AS
SELECT 
    i.id,
    i.invoice_code,
    i.folio,
    i.invoice_type,
    i.status,
    i.total_amount,
    i.paid_amount,
    i.balance,
    i.issue_date,
    i.due_date,
    CURRENT_DATE - i.due_date AS days_overdue,
    CASE 
        WHEN i.due_date < CURRENT_DATE THEN 'overdue'
        WHEN i.due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'due_soon'
        ELSE 'on_time'
    END AS payment_urgency,
    
    -- Proyecto
    p.project_code,
    p.name AS project_name,
    
    -- Cliente o Proveedor
    COALESCE(c.company_name, s.company_name) AS party_name,
    COALESCE(c.email, s.email) AS party_email,
    COALESCE(c.phone, s.phone) AS party_phone,
    
    i.created_at
FROM invoices i
LEFT JOIN projects p ON i.project_id = p.id
LEFT JOIN clients c ON i.client_id = c.id
LEFT JOIN suppliers s ON i.supplier_id = s.id
WHERE i.status NOT IN ('paid', 'cancelled')
AND i.is_active = true
ORDER BY 
    CASE 
        WHEN i.due_date < CURRENT_DATE THEN 1
        WHEN i.due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 2
        ELSE 3
    END,
    i.due_date ASC;

COMMENT ON VIEW v_pending_invoices IS 'Facturas pendientes de pago con urgencia';

-- ============================================================================
-- VISTA: Avance de Proyectos
-- ============================================================================
CREATE OR REPLACE VIEW v_project_progress AS
SELECT 
    p.id AS project_id,
    p.project_code,
    p.name AS project_name,
    p.status,
    p.progress_percentage AS overall_progress,
    p.health_status,
    
    -- Fechas y duración
    p.planned_start_date,
    p.planned_end_date,
    p.actual_start_date,
    p.estimated_duration_days AS planned_duration,
    CASE 
        WHEN p.actual_end_date IS NOT NULL THEN p.actual_duration_days
        WHEN p.actual_start_date IS NOT NULL THEN CURRENT_DATE - p.actual_start_date
        ELSE NULL
    END AS current_duration,
    
    -- Progreso de etapas
    COUNT(ps.id) AS total_stages,
    COUNT(ps.id) FILTER (WHERE ps.status = 'completed') AS completed_stages,
    ROUND(AVG(ps.progress_percentage), 2) AS avg_stage_progress,
    
    -- Progreso de tareas
    COUNT(pt.id) AS total_tasks,
    COUNT(pt.id) FILTER (WHERE pt.status = 'completed') AS completed_tasks,
    COUNT(pt.id) FILTER (WHERE pt.status = 'in_progress') AS in_progress_tasks,
    COUNT(pt.id) FILTER (WHERE pt.status = 'pending') AS pending_tasks,
    COUNT(pt.id) FILTER (WHERE pt.due_date < CURRENT_DATE AND pt.status NOT IN ('completed', 'cancelled')) AS overdue_tasks,
    
    -- Indicadores
    CASE 
        WHEN p.planned_end_date IS NOT NULL AND CURRENT_DATE > p.planned_end_date AND p.status != 'completed' THEN true
        ELSE false
    END AS is_delayed,
    
    CASE 
        WHEN p.planned_end_date IS NOT NULL THEN 
            ROUND(((CURRENT_DATE - p.planned_start_date)::NUMERIC / NULLIF((p.planned_end_date - p.planned_start_date), 0) * 100), 2)
        ELSE NULL
    END AS time_elapsed_percentage
    
FROM projects p
LEFT JOIN project_stages ps ON p.id = ps.project_id AND ps.is_active = true
LEFT JOIN project_tasks pt ON p.id = pt.project_id AND pt.is_active = true
WHERE p.is_active = true
GROUP BY p.id, p.project_code, p.name, p.status, p.progress_percentage, p.health_status,
         p.planned_start_date, p.planned_end_date, p.actual_start_date, p.actual_end_date,
         p.estimated_duration_days, p.actual_duration_days;

COMMENT ON VIEW v_project_progress IS 'Avance detallado de proyectos con indicadores';

-- ============================================================================
-- VISTA: Inventario con Alertas
-- ============================================================================
CREATE OR REPLACE VIEW v_inventory_status AS
SELECT 
    m.id,
    m.material_code,
    m.name,
    m.description,
    mc.name AS category_name,
    m.unit,
    m.current_stock,
    m.minimum_stock,
    m.maximum_stock,
    m.reorder_point,
    m.standard_cost,
    m.average_cost,
    m.current_stock * m.average_cost AS stock_value,
    
    -- Alertas
    CASE 
        WHEN m.current_stock = 0 THEN 'out_of_stock'
        WHEN m.current_stock <= m.minimum_stock THEN 'low_stock'
        WHEN m.current_stock <= m.reorder_point THEN 'reorder_needed'
        WHEN m.maximum_stock IS NOT NULL AND m.current_stock >= m.maximum_stock THEN 'overstock'
        ELSE 'normal'
    END AS stock_status,
    
    -- Proveedor preferido
    s.company_name AS preferred_supplier,
    s.email AS supplier_email,
    s.phone AS supplier_phone,
    
    -- Uso en proyectos
    (SELECT COUNT(DISTINCT project_id) FROM project_materials WHERE material_id = m.id) AS projects_using,
    (SELECT COALESCE(SUM(used_quantity), 0) FROM project_materials WHERE material_id = m.id) AS total_used,
    
    m.is_active
FROM materials m
LEFT JOIN material_categories mc ON m.category_id = mc.id
LEFT JOIN suppliers s ON m.preferred_supplier_id = s.id
WHERE m.is_active = true;

COMMENT ON VIEW v_inventory_status IS 'Estado del inventario con alertas de stock';

-- ============================================================================
-- VISTA: Desempeño de Proveedores
-- ============================================================================
CREATE OR REPLACE VIEW v_supplier_performance AS
SELECT 
    s.id,
    s.supplier_code,
    s.company_name,
    s.supplier_type,
    s.rating,
    s.quality_score,
    s.delivery_score,
    s.price_score,
    s.is_approved,
    
    -- Estadísticas
    (SELECT COUNT(*) FROM project_suppliers WHERE supplier_id = s.id AND is_active = true) AS active_projects,
    (SELECT COUNT(*) FROM contracts WHERE supplier_id = s.id AND status = 'active') AS active_contracts,
    (SELECT COALESCE(SUM(total_amount), 0) FROM contracts WHERE supplier_id = s.id) AS total_contracted,
    (SELECT COALESCE(SUM(total_amount), 0) FROM invoices WHERE supplier_id = s.id AND status = 'paid') AS total_paid,
    (SELECT COUNT(*) FROM supplier_evaluations WHERE supplier_id = s.id) AS total_evaluations,
    (SELECT AVG(overall_score) FROM supplier_evaluations WHERE supplier_id = s.id) AS avg_evaluation_score,
    
    -- Última evaluación
    (SELECT evaluation_date FROM supplier_evaluations WHERE supplier_id = s.id ORDER BY evaluation_date DESC LIMIT 1) AS last_evaluation_date,
    
    s.is_active
FROM suppliers s
WHERE s.is_active = true;

COMMENT ON VIEW v_supplier_performance IS 'Desempeño y estadísticas de proveedores';

-- ============================================================================
-- VISTA: Flujo de Caja Mensual
-- ============================================================================
CREATE OR REPLACE VIEW v_monthly_cash_flow AS
SELECT 
    DATE_TRUNC('month', cf.transaction_date) AS month,
    p.project_code,
    p.name AS project_name,
    SUM(CASE WHEN cf.transaction_type = 'income' THEN cf.amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN cf.transaction_type = 'expense' THEN cf.amount ELSE 0 END) AS total_expenses,
    SUM(CASE WHEN cf.transaction_type = 'income' THEN cf.amount ELSE -cf.amount END) AS net_cash_flow,
    SUM(SUM(CASE WHEN cf.transaction_type = 'income' THEN cf.amount ELSE -cf.amount END)) 
        OVER (PARTITION BY p.id ORDER BY DATE_TRUNC('month', cf.transaction_date)) AS cumulative_cash_flow
FROM cash_flow cf
JOIN projects p ON cf.project_id = p.id
GROUP BY DATE_TRUNC('month', cf.transaction_date), p.id, p.project_code, p.name
ORDER BY month DESC, p.project_code;

COMMENT ON VIEW v_monthly_cash_flow IS 'Flujo de caja mensual por proyecto';

-- ============================================================================
-- FUNCIONES ANALÍTICAS
-- ============================================================================

-- Función para obtener KPIs del mes
CREATE OR REPLACE FUNCTION get_monthly_kpis(target_month DATE DEFAULT CURRENT_DATE)
RETURNS TABLE (
    kpi_name VARCHAR,
    kpi_value NUMERIC,
    kpi_unit VARCHAR,
    comparison_previous_month NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Total Revenue'::VARCHAR,
        COALESCE(SUM(i.total_amount), 0)::NUMERIC,
        'MXN'::VARCHAR,
        0::NUMERIC
    FROM invoices i
    WHERE i.invoice_type = 'income'
    AND i.status = 'paid'
    AND DATE_TRUNC('month', i.paid_date) = DATE_TRUNC('month', target_month);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_monthly_kpis IS 'Obtiene KPIs del mes especificado';
