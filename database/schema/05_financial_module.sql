-- ============================================================================
-- MÓDULO FINANCIERO
-- Gestión de contratos, presupuestos, facturas y pagos
-- ============================================================================

-- ============================================================================
-- Tabla: contracts
-- Descripción: Contratos (con clientes y proveedores)
-- ============================================================================
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_code VARCHAR(20) UNIQUE NOT NULL,
    contract_type contract_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Partes del contrato
    project_id UUID REFERENCES projects(id),
    client_id UUID REFERENCES clients(id),
    supplier_id UUID REFERENCES suppliers(id),
    
    -- Montos
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'MXN',
    
    -- Fechas
    contract_date DATE NOT NULL,
    start_date DATE,
    end_date DATE,
    signed_date DATE,
    
    -- Estado
    status contract_status DEFAULT 'draft',
    
    -- Términos
    payment_terms TEXT,
    delivery_terms TEXT,
    warranty_terms TEXT,
    penalties_terms TEXT,
    
    -- Documentos
    file_path VARCHAR(500),
    signed_file_path VARCHAR(500),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_contract_amount CHECK (total_amount > 0),
    CONSTRAINT chk_contract_dates CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_contract_parties CHECK (
        (contract_type = 'client_contract' AND client_id IS NOT NULL) OR
        (contract_type = 'supplier_contract' AND supplier_id IS NOT NULL) OR
        (contract_type = 'subcontractor_contract')
    )
);

CREATE INDEX idx_contracts_contract_code ON contracts(contract_code);
CREATE INDEX idx_contracts_project_id ON contracts(project_id);
CREATE INDEX idx_contracts_client_id ON contracts(client_id);
CREATE INDEX idx_contracts_supplier_id ON contracts(supplier_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_contracts_contract_type ON contracts(contract_type);

-- ============================================================================
-- Tabla: budgets
-- Descripción: Presupuestos de proyectos
-- ============================================================================
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_code VARCHAR(20) UNIQUE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    version INTEGER DEFAULT 1,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Montos
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_percentage DECIMAL(5,2) DEFAULT 16,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'MXN',
    
    -- Fechas
    issue_date DATE DEFAULT CURRENT_DATE,
    valid_until DATE,
    
    -- Estado
    status budget_status DEFAULT 'draft',
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    
    -- Comparación
    estimated_cost DECIMAL(15,2),
    actual_cost DECIMAL(15,2) DEFAULT 0,
    variance DECIMAL(15,2),
    variance_percentage DECIMAL(5,2),
    
    notes TEXT,
    terms_and_conditions TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_budgets_budget_code ON budgets(budget_code);
CREATE INDEX idx_budgets_project_id ON budgets(project_id);
CREATE INDEX idx_budgets_status ON budgets(status);

-- ============================================================================
-- Tabla: budget_items
-- Descripción: Partidas del presupuesto
-- ============================================================================
CREATE TABLE budget_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_id UUID NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
    item_number INTEGER NOT NULL,
    category VARCHAR(100),
    description TEXT NOT NULL,
    quantity DECIMAL(12,2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    tax_percentage DECIMAL(5,2) DEFAULT 16,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_budget_item_number UNIQUE(budget_id, item_number),
    CONSTRAINT chk_budget_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_budget_item_price CHECK (unit_price >= 0)
);

CREATE INDEX idx_budget_items_budget_id ON budget_items(budget_id);

-- ============================================================================
-- Tabla: invoices
-- Descripción: Facturas (emitidas y recibidas)
-- ============================================================================
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_code VARCHAR(20) UNIQUE NOT NULL,
    invoice_type invoice_type NOT NULL,
    folio VARCHAR(50) UNIQUE,
    uuid VARCHAR(100) UNIQUE, -- UUID del SAT (CFDI)
    
    -- Relaciones
    project_id UUID REFERENCES projects(id),
    client_id UUID REFERENCES clients(id),
    supplier_id UUID REFERENCES suppliers(id),
    contract_id UUID REFERENCES contracts(id),
    
    -- Montos
    subtotal DECIMAL(15,2) NOT NULL,
    tax_percentage DECIMAL(5,2) DEFAULT 16,
    tax_amount DECIMAL(15,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    balance DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'MXN',
    
    -- Fechas
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    paid_date DATE,
    
    -- Estado
    status invoice_status DEFAULT 'draft',
    
    -- Información fiscal
    payment_method VARCHAR(50),
    payment_form VARCHAR(50),
    cfdi_use VARCHAR(50),
    
    -- Archivos
    xml_file_path VARCHAR(500),
    pdf_file_path VARCHAR(500),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_invoice_amounts CHECK (total_amount > 0 AND paid_amount >= 0 AND paid_amount <= total_amount),
    CONSTRAINT chk_invoice_parties CHECK (
        (invoice_type = 'income' AND client_id IS NOT NULL) OR
        (invoice_type = 'expense' AND supplier_id IS NOT NULL)
    )
);

CREATE INDEX idx_invoices_invoice_code ON invoices(invoice_code);
CREATE INDEX idx_invoices_folio ON invoices(folio);
CREATE INDEX idx_invoices_uuid ON invoices(uuid);
CREATE INDEX idx_invoices_project_id ON invoices(project_id);
CREATE INDEX idx_invoices_client_id ON invoices(client_id);
CREATE INDEX idx_invoices_supplier_id ON invoices(supplier_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_invoice_type ON invoices(invoice_type);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);

-- ============================================================================
-- Tabla: invoice_items
-- Descripción: Conceptos de la factura
-- ============================================================================
CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    item_number INTEGER NOT NULL,
    product_code VARCHAR(50),
    description TEXT NOT NULL,
    quantity DECIMAL(12,2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    tax_percentage DECIMAL(5,2) DEFAULT 16,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_invoice_item_number UNIQUE(invoice_id, item_number),
    CONSTRAINT chk_invoice_item_quantity CHECK (quantity > 0)
);

CREATE INDEX idx_invoice_items_invoice_id ON invoice_items(invoice_id);

-- ============================================================================
-- Tabla: payments
-- Descripción: Pagos realizados y recibidos
-- ============================================================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_code VARCHAR(20) UNIQUE NOT NULL,
    payment_type VARCHAR(20) NOT NULL, -- 'income', 'expense'
    
    -- Relaciones
    project_id UUID REFERENCES projects(id),
    invoice_id UUID REFERENCES invoices(id),
    client_id UUID REFERENCES clients(id),
    supplier_id UUID REFERENCES suppliers(id),
    
    -- Monto
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'MXN',
    
    -- Método de pago
    payment_method payment_method NOT NULL,
    payment_reference VARCHAR(100),
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    
    -- Fechas
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    processed_at TIMESTAMP,
    
    -- Estado
    status payment_status DEFAULT 'pending',
    
    -- Comprobante
    receipt_file_path VARCHAR(500),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_payment_code ON payments(payment_code);
CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_payments_project_id ON payments(project_id);
CREATE INDEX idx_payments_client_id ON payments(client_id);
CREATE INDEX idx_payments_supplier_id ON payments(supplier_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);

-- ============================================================================
-- Tabla: expenses
-- Descripción: Gastos del proyecto
-- ============================================================================
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expense_code VARCHAR(20) UNIQUE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    expense_type expense_type NOT NULL,
    category VARCHAR(100),
    description TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'MXN',
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    supplier_id UUID REFERENCES suppliers(id),
    invoice_id UUID REFERENCES invoices(id),
    payment_id UUID REFERENCES payments(id),
    receipt_file_path VARCHAR(500),
    is_billable BOOLEAN DEFAULT true,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_expense_amount CHECK (amount > 0)
);

CREATE INDEX idx_expenses_expense_code ON expenses(expense_code);
CREATE INDEX idx_expenses_project_id ON expenses(project_id);
CREATE INDEX idx_expenses_expense_type ON expenses(expense_type);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date);

-- ============================================================================
-- Tabla: cash_flow
-- Descripción: Flujo de caja del proyecto
-- ============================================================================
CREATE TABLE cash_flow (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- 'income', 'expense'
    category VARCHAR(100),
    description TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    balance DECIMAL(15,2),
    reference_type VARCHAR(50), -- 'invoice', 'payment', 'expense'
    reference_id UUID,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_cash_flow_amount CHECK (amount != 0)
);

CREATE INDEX idx_cash_flow_project_id ON cash_flow(project_id);
CREATE INDEX idx_cash_flow_transaction_date ON cash_flow(transaction_date);
CREATE INDEX idx_cash_flow_transaction_type ON cash_flow(transaction_type);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

CREATE TRIGGER trg_contracts_updated_at BEFORE UPDATE ON contracts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_budgets_updated_at BEFORE UPDATE ON budgets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_budget_items_updated_at BEFORE UPDATE ON budget_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_invoices_updated_at BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_expenses_updated_at BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Calcular balance de factura
CREATE OR REPLACE FUNCTION calculate_invoice_balance()
RETURNS TRIGGER AS $$
BEGIN
    NEW.balance := NEW.total_amount - NEW.paid_amount;
    
    -- Actualizar estado según balance
    IF NEW.balance = 0 THEN
        NEW.status := 'paid';
    ELSIF NEW.paid_amount > 0 THEN
        NEW.status := 'partially_paid';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_invoices_calculate_balance
    BEFORE INSERT OR UPDATE ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION calculate_invoice_balance();
