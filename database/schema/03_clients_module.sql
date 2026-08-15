-- ============================================================================
-- MÓDULO DE CLIENTES
-- Gestión de clientes y sus contactos
-- ============================================================================

-- ============================================================================
-- Tabla: clients
-- Descripción: Clientes de la empresa
-- ============================================================================
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_code VARCHAR(20) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    commercial_name VARCHAR(255),
    rfc VARCHAR(13) UNIQUE,
    tax_regime VARCHAR(100),
    contact_name VARCHAR(200) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    mobile VARCHAR(20),
    website VARCHAR(255),
    
    -- Dirección fiscal
    fiscal_address TEXT,
    fiscal_street VARCHAR(255),
    fiscal_ext_number VARCHAR(20),
    fiscal_int_number VARCHAR(20),
    fiscal_neighborhood VARCHAR(100),
    fiscal_city VARCHAR(100),
    fiscal_state VARCHAR(100),
    fiscal_country VARCHAR(100) DEFAULT 'México',
    fiscal_zip_code VARCHAR(10),
    
    -- Información comercial
    credit_limit DECIMAL(15,2) DEFAULT 0,
    credit_days INTEGER DEFAULT 0,
    payment_terms TEXT,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    
    -- Clasificación
    client_type VARCHAR(50), -- 'corporativo', 'gobierno', 'particular'
    industry VARCHAR(100),
    size VARCHAR(50), -- 'pequeña', 'mediana', 'grande'
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'vip'
    
    -- Relación con usuario
    user_id UUID REFERENCES users(id),
    
    -- Estadísticas
    total_projects INTEGER DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0,
    last_project_date DATE,
    
    -- Notas y observaciones
    notes TEXT,
    internal_notes TEXT, -- Notas privadas, no visibles para el cliente
    
    -- Metadatos
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    -- Auditoría
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP,
    
    CONSTRAINT chk_credit_limit CHECK (credit_limit >= 0),
    CONSTRAINT chk_credit_days CHECK (credit_days >= 0),
    CONSTRAINT chk_discount CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
    CONSTRAINT chk_rfc_format CHECK (rfc IS NULL OR validate_rfc(rfc))
);

CREATE INDEX idx_clients_client_code ON clients(client_code);
CREATE INDEX idx_clients_company_name ON clients(company_name);
CREATE INDEX idx_clients_rfc ON clients(rfc) WHERE rfc IS NOT NULL;
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_clients_user_id ON clients(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_clients_is_active ON clients(is_active);
CREATE INDEX idx_clients_created_at ON clients(created_at);
CREATE INDEX idx_clients_priority ON clients(priority);
CREATE INDEX idx_clients_client_type ON clients(client_type);
CREATE INDEX idx_clients_tags ON clients USING GIN(tags);
CREATE INDEX idx_clients_company_name_trgm ON clients USING gin(company_name gin_trgm_ops);

COMMENT ON TABLE clients IS 'Clientes de la empresa';
COMMENT ON COLUMN clients.client_code IS 'Código único del cliente (ej: CLI-000001)';
COMMENT ON COLUMN clients.rfc IS 'RFC mexicano validado';
COMMENT ON COLUMN clients.user_id IS 'Usuario asociado para acceso al portal';
COMMENT ON COLUMN clients.internal_notes IS 'Notas privadas no visibles para el cliente';

-- ============================================================================
-- Tabla: client_contacts
-- Descripción: Contactos adicionales del cliente
-- ============================================================================
CREATE TABLE client_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    contact_type VARCHAR(50) DEFAULT 'general', -- 'general', 'financial', 'technical', 'legal'
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    department VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    extension VARCHAR(10),
    is_primary BOOLEAN DEFAULT false,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_contact_email CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_client_contacts_client_id ON client_contacts(client_id);
CREATE INDEX idx_client_contacts_email ON client_contacts(email) WHERE email IS NOT NULL;
CREATE INDEX idx_client_contacts_is_primary ON client_contacts(is_primary) WHERE is_primary = true;
CREATE INDEX idx_client_contacts_contact_type ON client_contacts(contact_type);

COMMENT ON TABLE client_contacts IS 'Contactos adicionales de cada cliente';
COMMENT ON COLUMN client_contacts.is_primary IS 'Contacto principal del cliente';

-- ============================================================================
-- Tabla: client_documents
-- Descripción: Documentos del cliente
-- ============================================================================
CREATE TABLE client_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    document_type document_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT, -- en bytes
    mime_type VARCHAR(100),
    document_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    is_verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    tags TEXT[],
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_file_size CHECK (file_size > 0)
);

CREATE INDEX idx_client_documents_client_id ON client_documents(client_id);
CREATE INDEX idx_client_documents_document_type ON client_documents(document_type);
CREATE INDEX idx_client_documents_expiry_date ON client_documents(expiry_date) WHERE expiry_date IS NOT NULL;
CREATE INDEX idx_client_documents_tags ON client_documents USING GIN(tags);

COMMENT ON TABLE client_documents IS 'Documentos asociados a clientes (contratos, identificaciones, etc.)';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger para generar client_code automáticamente
CREATE OR REPLACE FUNCTION generate_client_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.client_code IS NULL OR NEW.client_code = '' THEN
        NEW.client_code := generate_unique_code('CLI', 'clients', 'client_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_clients_generate_code
    BEFORE INSERT ON clients
    FOR EACH ROW
    EXECUTE FUNCTION generate_client_code();

-- Trigger para actualizar updated_at
CREATE TRIGGER trg_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_client_contacts_updated_at
    BEFORE UPDATE ON client_contacts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_client_documents_updated_at
    BEFORE UPDATE ON client_documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para asegurar solo un contacto primario por cliente
CREATE OR REPLACE FUNCTION ensure_single_primary_contact()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_primary = true THEN
        UPDATE client_contacts 
        SET is_primary = false 
        WHERE client_id = NEW.client_id 
        AND id != NEW.id 
        AND is_primary = true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_client_contacts_primary
    BEFORE INSERT OR UPDATE ON client_contacts
    FOR EACH ROW
    WHEN (NEW.is_primary = true)
    EXECUTE FUNCTION ensure_single_primary_contact();
