-- ============================================================================
-- MÓDULO DE AUDITORÍA
-- Sistema de auditoría y logs
-- ============================================================================

-- ============================================================================
-- Tabla: audit_logs
-- Descripción: Registro de auditoría de cambios críticos
-- ============================================================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    user_id UUID REFERENCES users(id),
    username VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    
    -- Datos del cambio
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    
    -- Contexto
    module VARCHAR(50),
    description TEXT,
    severity VARCHAR(20) DEFAULT 'info', -- 'info', 'warning', 'critical'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_audit_action CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT'))
);

CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_record_id ON audit_logs(record_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_severity ON audit_logs(severity);
CREATE INDEX idx_audit_logs_module ON audit_logs(module);

-- Particionamiento por fecha (mensual)
-- ALTER TABLE audit_logs PARTITION BY RANGE (created_at);

COMMENT ON TABLE audit_logs IS 'Registro de auditoría de todas las operaciones críticas';

-- ============================================================================
-- Tabla: system_logs
-- Descripción: Logs del sistema
-- ============================================================================
CREATE TABLE system_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    log_level VARCHAR(20) NOT NULL, -- 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'
    module VARCHAR(100),
    message TEXT NOT NULL,
    exception_type VARCHAR(255),
    exception_message TEXT,
    stack_trace TEXT,
    user_id UUID REFERENCES users(id),
    ip_address INET,
    request_url TEXT,
    request_method VARCHAR(10),
    response_status INTEGER,
    execution_time_ms INTEGER,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_logs_log_level ON system_logs(log_level);
CREATE INDEX idx_system_logs_module ON system_logs(module);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at);
CREATE INDEX idx_system_logs_user_id ON system_logs(user_id) WHERE user_id IS NOT NULL;

COMMENT ON TABLE system_logs IS 'Logs de errores y eventos del sistema';

-- ============================================================================
-- Tabla: change_history
-- Descripción: Historial de cambios en registros importantes
-- ============================================================================
CREATE TABLE change_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    change_type VARCHAR(20) NOT NULL, -- 'CREATE', 'UPDATE', 'DELETE', 'STATUS_CHANGE'
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_change_history_entity ON change_history(entity_type, entity_id);
CREATE INDEX idx_change_history_changed_by ON change_history(changed_by);
CREATE INDEX idx_change_history_changed_at ON change_history(changed_at);
CREATE INDEX idx_change_history_change_type ON change_history(change_type);

COMMENT ON TABLE change_history IS 'Historial detallado de cambios en entidades críticas';

-- ============================================================================
-- FUNCIONES DE AUDITORÍA
-- ============================================================================

-- Función genérica de auditoría
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    changed_fields TEXT[];
BEGIN
    -- Convertir OLD y NEW a JSONB
    IF TG_OP = 'DELETE' THEN
        old_data := to_jsonb(OLD);
        new_data := NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);
        
        -- Identificar campos cambiados
        SELECT array_agg(key)
        INTO changed_fields
        FROM jsonb_each(old_data)
        WHERE old_data->key IS DISTINCT FROM new_data->key;
    ELSIF TG_OP = 'INSERT' THEN
        old_data := NULL;
        new_data := to_jsonb(NEW);
    END IF;
    
    -- Insertar en audit_logs
    INSERT INTO audit_logs (
        table_name,
        record_id,
        action,
        user_id,
        old_values,
        new_values,
        changed_fields,
        module
    ) VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        COALESCE(NEW.updated_by, NEW.created_by, OLD.updated_by, OLD.created_by),
        old_data,
        new_data,
        changed_fields,
        TG_TABLE_SCHEMA
    );
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- APLICAR TRIGGERS DE AUDITORÍA A TABLAS CRÍTICAS
-- ============================================================================

-- Usuarios
CREATE TRIGGER trg_audit_users
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

-- Proyectos
CREATE TRIGGER trg_audit_projects
    AFTER INSERT OR UPDATE OR DELETE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

-- Contratos
CREATE TRIGGER trg_audit_contracts
    AFTER INSERT OR UPDATE OR DELETE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

-- Facturas
CREATE TRIGGER trg_audit_invoices
    AFTER INSERT OR UPDATE OR DELETE ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

-- Pagos
CREATE TRIGGER trg_audit_payments
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

-- Presupuestos
CREATE TRIGGER trg_audit_budgets
    AFTER INSERT OR UPDATE OR DELETE ON budgets
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

-- ============================================================================
-- VISTAS DE AUDITORÍA
-- ============================================================================

-- Vista de actividad reciente
CREATE OR REPLACE VIEW v_recent_activity AS
SELECT 
    al.id,
    al.table_name,
    al.record_id,
    al.action,
    al.user_id,
    u.username,
    u.first_name || ' ' || u.last_name AS user_full_name,
    al.changed_fields,
    al.description,
    al.severity,
    al.created_at
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
ORDER BY al.created_at DESC
LIMIT 100;

-- Vista de cambios por usuario
CREATE OR REPLACE VIEW v_user_activity AS
SELECT 
    u.id AS user_id,
    u.username,
    u.first_name || ' ' || u.last_name AS full_name,
    COUNT(*) AS total_actions,
    COUNT(*) FILTER (WHERE al.action = 'INSERT') AS inserts,
    COUNT(*) FILTER (WHERE al.action = 'UPDATE') AS updates,
    COUNT(*) FILTER (WHERE al.action = 'DELETE') AS deletes,
    MAX(al.created_at) AS last_activity
FROM users u
LEFT JOIN audit_logs al ON u.id = al.user_id
GROUP BY u.id, u.username, u.first_name, u.last_name;

-- Vista de cambios por tabla
CREATE OR REPLACE VIEW v_table_activity AS
SELECT 
    table_name,
    COUNT(*) AS total_changes,
    COUNT(*) FILTER (WHERE action = 'INSERT') AS inserts,
    COUNT(*) FILTER (WHERE action = 'UPDATE') AS updates,
    COUNT(*) FILTER (WHERE action = 'DELETE') AS deletes,
    MAX(created_at) AS last_change
FROM audit_logs
GROUP BY table_name
ORDER BY total_changes DESC;

-- ============================================================================
-- FUNCIONES DE LIMPIEZA
-- ============================================================================

-- Función para limpiar logs antiguos
CREATE OR REPLACE FUNCTION cleanup_old_logs(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Eliminar audit_logs antiguos
    DELETE FROM audit_logs
    WHERE created_at < CURRENT_DATE - days_to_keep
    AND severity != 'critical';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Eliminar system_logs antiguos
    DELETE FROM system_logs
    WHERE created_at < CURRENT_DATE - days_to_keep
    AND log_level NOT IN ('ERROR', 'CRITICAL');
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_old_logs IS 'Limpia logs antiguos manteniendo los críticos';

-- ============================================================================
-- ÍNDICES ADICIONALES PARA PERFORMANCE
-- ============================================================================

-- Índice compuesto para búsquedas comunes
CREATE INDEX idx_audit_logs_user_table_date ON audit_logs(user_id, table_name, created_at DESC);
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);

-- Índice para búsquedas de texto en mensajes
CREATE INDEX idx_system_logs_message_trgm ON system_logs USING gin(message gin_trgm_ops);
