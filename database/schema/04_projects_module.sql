-- ============================================================================
-- MÓDULO DE PROYECTOS
-- Gestión de proyectos de construcción de naves industriales
-- ============================================================================

-- ============================================================================
-- Tabla: projects
-- Descripción: Proyectos/Obras de construcción
-- ============================================================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    client_id UUID NOT NULL REFERENCES clients(id),
    
    -- Ubicación
    location TEXT,
    address VARCHAR(500),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'México',
    zip_code VARCHAR(10),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Características de la nave
    total_area DECIMAL(12,2), -- m²
    covered_area DECIMAL(12,2), -- m²
    height DECIMAL(8,2), -- metros
    construction_type VARCHAR(100), -- 'nave industrial', 'bodega', 'almacén'
    structure_type VARCHAR(100), -- 'acero', 'concreto', 'mixta'
    
    -- Fechas
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    estimated_duration_days INTEGER,
    actual_duration_days INTEGER,
    
    -- Estado y progreso
    status project_status DEFAULT 'planning',
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    health_status VARCHAR(20) DEFAULT 'on_track', -- 'on_track', 'at_risk', 'delayed'
    
    -- Responsables
    project_manager_id UUID REFERENCES users(id),
    site_supervisor_id UUID REFERENCES users(id),
    
    -- Financiero
    contract_amount DECIMAL(15,2),
    current_budget DECIMAL(15,2),
    total_expenses DECIMAL(15,2) DEFAULT 0,
    total_income DECIMAL(15,2) DEFAULT 0,
    profit_margin DECIMAL(5,2),
    
    -- Prioridad y clasificación
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    complexity VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high'
    risk_level VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'critical'
    
    -- Documentación
    notes TEXT,
    internal_notes TEXT,
    lessons_learned TEXT,
    
    -- Metadatos
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    custom_fields JSONB DEFAULT '{}',
    
    -- Auditoría
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP,
    
    CONSTRAINT chk_progress CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    CONSTRAINT chk_dates CHECK (planned_end_date IS NULL OR planned_start_date IS NULL OR planned_end_date >= planned_start_date),
    CONSTRAINT chk_actual_dates CHECK (actual_end_date IS NULL OR actual_start_date IS NULL OR actual_end_date >= actual_start_date),
    CONSTRAINT chk_area CHECK (total_area IS NULL OR total_area > 0),
    CONSTRAINT chk_covered_area CHECK (covered_area IS NULL OR covered_area <= total_area),
    CONSTRAINT chk_amounts CHECK (contract_amount IS NULL OR contract_amount >= 0)
);

CREATE INDEX idx_projects_project_code ON projects(project_code);
CREATE INDEX idx_projects_name ON projects(name);
CREATE INDEX idx_projects_client_id ON projects(client_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_project_manager_id ON projects(project_manager_id);
CREATE INDEX idx_projects_site_supervisor_id ON projects(site_supervisor_id);
CREATE INDEX idx_projects_planned_start_date ON projects(planned_start_date);
CREATE INDEX idx_projects_planned_end_date ON projects(planned_end_date);
CREATE INDEX idx_projects_is_active ON projects(is_active);
CREATE INDEX idx_projects_priority ON projects(priority);
CREATE INDEX idx_projects_health_status ON projects(health_status);
CREATE INDEX idx_projects_tags ON projects USING GIN(tags);
CREATE INDEX idx_projects_name_trgm ON projects USING gin(name gin_trgm_ops);

COMMENT ON TABLE projects IS 'Proyectos de construcción de naves industriales';
COMMENT ON COLUMN projects.health_status IS 'Estado de salud del proyecto: on_track, at_risk, delayed';
COMMENT ON COLUMN projects.progress_percentage IS 'Porcentaje de avance del proyecto (0-100)';

-- ============================================================================
-- Tabla: project_stages
-- Descripción: Etapas de un proyecto
-- ============================================================================
CREATE TABLE project_stages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    stage_number INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status stage_status DEFAULT 'pending',
    
    -- Fechas
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    -- Progreso
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    weight_percentage DECIMAL(5,2) DEFAULT 0, -- Peso de esta etapa en el proyecto total
    
    -- Responsable
    responsible_user_id UUID REFERENCES users(id),
    
    -- Dependencias
    depends_on_stage_id UUID REFERENCES project_stages(id),
    
    -- Financiero
    estimated_cost DECIMAL(15,2),
    actual_cost DECIMAL(15,2) DEFAULT 0,
    
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT uq_project_stage_number UNIQUE(project_id, stage_number),
    CONSTRAINT chk_stage_progress CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    CONSTRAINT chk_stage_weight CHECK (weight_percentage >= 0 AND weight_percentage <= 100),
    CONSTRAINT chk_stage_dates CHECK (planned_end_date IS NULL OR planned_start_date IS NULL OR planned_end_date >= planned_start_date)
);

CREATE INDEX idx_project_stages_project_id ON project_stages(project_id);
CREATE INDEX idx_project_stages_status ON project_stages(status);
CREATE INDEX idx_project_stages_responsible_user_id ON project_stages(responsible_user_id);
CREATE INDEX idx_project_stages_stage_number ON project_stages(project_id, stage_number);

COMMENT ON TABLE project_stages IS 'Etapas de construcción de un proyecto';
COMMENT ON COLUMN project_stages.weight_percentage IS 'Peso de la etapa en el avance total del proyecto';

-- ============================================================================
-- Tabla: project_tasks
-- Descripción: Tareas dentro de las etapas
-- ============================================================================
CREATE TABLE project_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    stage_id UUID REFERENCES project_stages(id) ON DELETE SET NULL,
    task_number VARCHAR(20),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status task_status DEFAULT 'pending',
    priority task_priority DEFAULT 'medium',
    
    -- Fechas
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    due_date DATE,
    
    -- Asignación
    assigned_to_user_id UUID REFERENCES users(id),
    assigned_at TIMESTAMP,
    
    -- Progreso
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    estimated_hours DECIMAL(8,2),
    actual_hours DECIMAL(8,2) DEFAULT 0,
    
    -- Dependencias
    depends_on_task_id UUID REFERENCES project_tasks(id),
    blocking_tasks INTEGER DEFAULT 0,
    
    -- Checklist
    checklist JSONB DEFAULT '[]', -- Array de items con {text, completed, completedBy, completedAt}
    
    notes TEXT,
    attachments JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_task_progress CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    CONSTRAINT chk_task_hours CHECK (estimated_hours IS NULL OR estimated_hours >= 0)
);

CREATE INDEX idx_project_tasks_project_id ON project_tasks(project_id);
CREATE INDEX idx_project_tasks_stage_id ON project_tasks(stage_id);
CREATE INDEX idx_project_tasks_status ON project_tasks(status);
CREATE INDEX idx_project_tasks_priority ON project_tasks(priority);
CREATE INDEX idx_project_tasks_assigned_to_user_id ON project_tasks(assigned_to_user_id);
CREATE INDEX idx_project_tasks_due_date ON project_tasks(due_date) WHERE due_date IS NOT NULL;

COMMENT ON TABLE project_tasks IS 'Tareas específicas dentro de las etapas del proyecto';

-- ============================================================================
-- Tabla: project_team
-- Descripción: Equipo asignado al proyecto
-- ============================================================================
CREATE TABLE project_team (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(100) NOT NULL, -- 'manager', 'supervisor', 'engineer', 'worker'
    responsibilities TEXT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    removed_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    
    CONSTRAINT uq_project_team_member UNIQUE(project_id, user_id, role)
);

CREATE INDEX idx_project_team_project_id ON project_team(project_id);
CREATE INDEX idx_project_team_user_id ON project_team(user_id);
CREATE INDEX idx_project_team_role ON project_team(role);
CREATE INDEX idx_project_team_is_active ON project_team(is_active);

COMMENT ON TABLE project_team IS 'Equipo de trabajo asignado a cada proyecto';

-- ============================================================================
-- Tabla: project_documents
-- Descripción: Documentos del proyecto
-- ============================================================================
CREATE TABLE project_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    stage_id UUID REFERENCES project_stages(id) ON DELETE SET NULL,
    document_type document_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    version VARCHAR(20) DEFAULT '1.0',
    document_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    is_approved BOOLEAN DEFAULT false,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    tags TEXT[],
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_project_documents_project_id ON project_documents(project_id);
CREATE INDEX idx_project_documents_stage_id ON project_documents(stage_id);
CREATE INDEX idx_project_documents_document_type ON project_documents(document_type);
CREATE INDEX idx_project_documents_tags ON project_documents USING GIN(tags);

COMMENT ON TABLE project_documents IS 'Documentos asociados a proyectos (planos, permisos, reportes)';

-- ============================================================================
-- Tabla: project_photos
-- Descripción: Fotografías del proyecto
-- ============================================================================
CREATE TABLE project_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    stage_id UUID REFERENCES project_stages(id) ON DELETE SET NULL,
    title VARCHAR(255),
    description TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    thumbnail_path VARCHAR(500),
    file_size BIGINT,
    taken_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    camera_info JSONB,
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);

CREATE INDEX idx_project_photos_project_id ON project_photos(project_id);
CREATE INDEX idx_project_photos_stage_id ON project_photos(stage_id);
CREATE INDEX idx_project_photos_taken_at ON project_photos(taken_at);
CREATE INDEX idx_project_photos_is_featured ON project_photos(is_featured) WHERE is_featured = true;
CREATE INDEX idx_project_photos_tags ON project_photos USING GIN(tags);

COMMENT ON TABLE project_photos IS 'Fotografías de avance y documentación del proyecto';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Generar project_code
CREATE OR REPLACE FUNCTION generate_project_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.project_code IS NULL OR NEW.project_code = '' THEN
        NEW.project_code := generate_unique_code('PRJ', 'projects', 'project_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_projects_generate_code
    BEFORE INSERT ON projects
    FOR EACH ROW
    EXECUTE FUNCTION generate_project_code();

-- Actualizar updated_at
CREATE TRIGGER trg_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_project_stages_updated_at BEFORE UPDATE ON project_stages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_project_tasks_updated_at BEFORE UPDATE ON project_tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_project_documents_updated_at BEFORE UPDATE ON project_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Calcular duración actual del proyecto
CREATE OR REPLACE FUNCTION calculate_project_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.actual_start_date IS NOT NULL AND NEW.actual_end_date IS NOT NULL THEN
        NEW.actual_duration_days := NEW.actual_end_date - NEW.actual_start_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_projects_calculate_duration
    BEFORE INSERT OR UPDATE ON projects
    FOR EACH ROW
    EXECUTE FUNCTION calculate_project_duration();
