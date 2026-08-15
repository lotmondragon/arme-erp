-- ============================================================================
-- MÓDULO DE PROVEEDORES
-- Gestión de proveedores y subcontratistas
-- ============================================================================

-- ============================================================================
-- Tabla: suppliers
-- Descripción: Proveedores y subcontratistas
-- ============================================================================
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_code VARCHAR(20) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    commercial_name VARCHAR(255),
    rfc VARCHAR(13) UNIQUE,
    tax_regime VARCHAR(100),
    
    -- Contacto
    contact_name VARCHAR(200) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    mobile VARCHAR(20),
    website VARCHAR(255),
    
    -- Dirección
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'México',
    zip_code VARCHAR(10),
    
    -- Clasificación
    supplier_type VARCHAR(50), -- 'material', 'service', 'equipment', 'subcontractor'
    category VARCHAR(100),
    specialties TEXT[],
    
    -- Términos comerciales
    payment_terms TEXT,
    credit_days INTEGER DEFAULT 0,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    
    -- Calificación
    rating DECIMAL(3,2), -- 0.00 a 5.00
    quality_score INTEGER, -- 1 a 100
    delivery_score INTEGER, -- 1 a 100
    price_score INTEGER, -- 1 a 100
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0,
    
    -- Información bancaria
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    clabe VARCHAR(18),
    swift_code VARCHAR(20),
    
    -- Documentos
    tax_certificate_path VARCHAR(500),
    insurance_certificate_path VARCHAR(500),
    
    notes TEXT,
    internal_notes TEXT,
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    is_active BOOLEAN DEFAULT true,
    is_approved BOOLEAN DEFAULT false,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP,
    
    CONSTRAINT chk_supplier_rating CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5)),
    CONSTRAINT chk_supplier_scores CHECK (
        (quality_score IS NULL OR (quality_score >= 0 AND quality_score <= 100)) AND
        (delivery_score IS NULL OR (delivery_score >= 0 AND delivery_score <= 100)) AND
        (price_score IS NULL OR (price_score >= 0 AND price_score <= 100))
    ),
    CONSTRAINT chk_supplier_rfc CHECK (rfc IS NULL OR validate_rfc(rfc))
);

CREATE INDEX idx_suppliers_supplier_code ON suppliers(supplier_code);
CREATE INDEX idx_suppliers_company_name ON suppliers(company_name);
CREATE INDEX idx_suppliers_rfc ON suppliers(rfc) WHERE rfc IS NOT NULL;
CREATE INDEX idx_suppliers_supplier_type ON suppliers(supplier_type);
CREATE INDEX idx_suppliers_is_active ON suppliers(is_active);
CREATE INDEX idx_suppliers_is_approved ON suppliers(is_approved);
CREATE INDEX idx_suppliers_tags ON suppliers USING GIN(tags);
CREATE INDEX idx_suppliers_specialties ON suppliers USING GIN(specialties);

COMMENT ON TABLE suppliers IS 'Proveedores y subcontratistas';
COMMENT ON COLUMN suppliers.rating IS 'Calificación promedio del proveedor (0-5)';

-- ============================================================================
-- Tabla: project_suppliers
-- Descripción: Relación muchos a muchos entre proyectos y proveedores
-- ============================================================================
CREATE TABLE project_suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    role VARCHAR(100), -- 'main_contractor', 'subcontractor', 'material_supplier'
    scope_of_work TEXT,
    contract_amount DECIMAL(15,2),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    removed_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    
    CONSTRAINT uq_project_supplier UNIQUE(project_id, supplier_id, role)
);

CREATE INDEX idx_project_suppliers_project_id ON project_suppliers(project_id);
CREATE INDEX idx_project_suppliers_supplier_id ON project_suppliers(supplier_id);
CREATE INDEX idx_project_suppliers_is_active ON project_suppliers(is_active);

COMMENT ON TABLE project_suppliers IS 'Proveedores asignados a cada proyecto';

-- ============================================================================
-- Tabla: supplier_contracts
-- Descripción: Contratos con proveedores (referencia a contracts)
-- ============================================================================
CREATE TABLE supplier_evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id),
    evaluator_id UUID NOT NULL REFERENCES users(id),
    evaluation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Criterios de evaluación
    quality_score INTEGER NOT NULL, -- 1-100
    delivery_score INTEGER NOT NULL, -- 1-100
    price_score INTEGER NOT NULL, -- 1-100
    communication_score INTEGER NOT NULL, -- 1-100
    compliance_score INTEGER NOT NULL, -- 1-100
    
    -- Calificación general
    overall_score INTEGER, -- Promedio de los criterios
    rating DECIMAL(3,2), -- Conversión a escala 0-5
    
    comments TEXT,
    strengths TEXT,
    areas_for_improvement TEXT,
    would_recommend BOOLEAN,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_evaluation_scores CHECK (
        quality_score BETWEEN 1 AND 100 AND
        delivery_score BETWEEN 1 AND 100 AND
        price_score BETWEEN 1 AND 100 AND
        communication_score BETWEEN 1 AND 100 AND
        compliance_score BETWEEN 1 AND 100
    )
);

CREATE INDEX idx_supplier_evaluations_supplier_id ON supplier_evaluations(supplier_id);
CREATE INDEX idx_supplier_evaluations_project_id ON supplier_evaluations(project_id);
CREATE INDEX idx_supplier_evaluations_evaluation_date ON supplier_evaluations(evaluation_date);

COMMENT ON TABLE supplier_evaluations IS 'Evaluaciones de desempeño de proveedores';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Generar supplier_code
CREATE OR REPLACE FUNCTION generate_supplier_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.supplier_code IS NULL OR NEW.supplier_code = '' THEN
        NEW.supplier_code := generate_unique_code('SUP', 'suppliers', 'supplier_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_suppliers_generate_code
    BEFORE INSERT ON suppliers
    FOR EACH ROW
    EXECUTE FUNCTION generate_supplier_code();

CREATE TRIGGER trg_suppliers_updated_at
    BEFORE UPDATE ON suppliers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Calcular overall_score en evaluaciones
CREATE OR REPLACE FUNCTION calculate_evaluation_scores()
RETURNS TRIGGER AS $$
BEGIN
    NEW.overall_score := (
        NEW.quality_score + 
        NEW.delivery_score + 
        NEW.price_score + 
        NEW.communication_score + 
        NEW.compliance_score
    ) / 5;
    
    NEW.rating := (NEW.overall_score::DECIMAL / 20); -- Convertir de 0-100 a 0-5
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_supplier_evaluations_calculate_scores
    BEFORE INSERT OR UPDATE ON supplier_evaluations
    FOR EACH ROW
    EXECUTE FUNCTION calculate_evaluation_scores();

-- Actualizar rating del proveedor basado en evaluaciones
CREATE OR REPLACE FUNCTION update_supplier_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE suppliers
    SET 
        rating = (
            SELECT AVG(rating)
            FROM supplier_evaluations
            WHERE supplier_id = NEW.supplier_id
        ),
        quality_score = (
            SELECT AVG(quality_score)::INTEGER
            FROM supplier_evaluations
            WHERE supplier_id = NEW.supplier_id
        ),
        delivery_score = (
            SELECT AVG(delivery_score)::INTEGER
            FROM supplier_evaluations
            WHERE supplier_id = NEW.supplier_id
        ),
        price_score = (
            SELECT AVG(price_score)::INTEGER
            FROM supplier_evaluations
            WHERE supplier_id = NEW.supplier_id
        )
    WHERE id = NEW.supplier_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_supplier_evaluations_update_rating
    AFTER INSERT OR UPDATE ON supplier_evaluations
    FOR EACH ROW
    EXECUTE FUNCTION update_supplier_rating();
