-- ============================================================================
-- MÓDULO DE INVENTARIO
-- Gestión de materiales y almacenes
-- ============================================================================

-- ============================================================================
-- Tabla: material_categories
-- Descripción: Categorías de materiales
-- ============================================================================
CREATE TABLE material_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id UUID REFERENCES material_categories(id),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_material_categories_parent_id ON material_categories(parent_category_id);
CREATE INDEX idx_material_categories_name ON material_categories(name);

COMMENT ON TABLE material_categories IS 'Categorías jerárquicas de materiales';

-- ============================================================================
-- Tabla: materials
-- Descripción: Catálogo de materiales
-- ============================================================================
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES material_categories(id),
    
    -- Unidades
    unit VARCHAR(50) NOT NULL, -- 'm3', 'kg', 'pza', 'ton', 'm2', 'lt'
    unit_per_package DECIMAL(10,2),
    package_unit VARCHAR(50),
    
    -- Costos
    standard_cost DECIMAL(12,2),
    last_purchase_cost DECIMAL(12,2),
    average_cost DECIMAL(12,2),
    
    -- Inventario
    current_stock DECIMAL(12,2) DEFAULT 0,
    minimum_stock DECIMAL(12,2) DEFAULT 0,
    maximum_stock DECIMAL(12,2),
    reorder_point DECIMAL(12,2),
    reorder_quantity DECIMAL(12,2),
    
    -- Clasificación
    material_type VARCHAR(50), -- 'raw_material', 'finished_product', 'consumable', 'tool'
    is_hazardous BOOLEAN DEFAULT false,
    requires_special_handling BOOLEAN DEFAULT false,
    
    -- Proveedores
    preferred_supplier_id UUID REFERENCES suppliers(id),
    alternative_suppliers UUID[],
    
    -- Especificaciones técnicas
    specifications JSONB DEFAULT '{}',
    technical_sheet_path VARCHAR(500),
    safety_sheet_path VARCHAR(500),
    
    -- Imágenes
    image_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP,
    
    CONSTRAINT chk_material_stock CHECK (current_stock >= 0),
    CONSTRAINT chk_material_costs CHECK (
        (standard_cost IS NULL OR standard_cost >= 0) AND
        (last_purchase_cost IS NULL OR last_purchase_cost >= 0) AND
        (average_cost IS NULL OR average_cost >= 0)
    )
);

CREATE INDEX idx_materials_material_code ON materials(material_code);
CREATE INDEX idx_materials_name ON materials(name);
CREATE INDEX idx_materials_category_id ON materials(category_id);
CREATE INDEX idx_materials_material_type ON materials(material_type);
CREATE INDEX idx_materials_preferred_supplier_id ON materials(preferred_supplier_id);
CREATE INDEX idx_materials_is_active ON materials(is_active);
CREATE INDEX idx_materials_tags ON materials USING GIN(tags);
CREATE INDEX idx_materials_name_trgm ON materials USING gin(name gin_trgm_ops);

COMMENT ON TABLE materials IS 'Catálogo de materiales, herramientas y consumibles';
COMMENT ON COLUMN materials.reorder_point IS 'Punto de reorden automático';

-- ============================================================================
-- Tabla: warehouses
-- Descripción: Almacenes
-- ============================================================================
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    warehouse_type VARCHAR(50), -- 'main', 'site', 'temporary'
    
    -- Ubicación
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'México',
    zip_code VARCHAR(10),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Capacidad
    total_capacity DECIMAL(12,2),
    capacity_unit VARCHAR(50),
    current_utilization DECIMAL(5,2) DEFAULT 0, -- Porcentaje
    
    -- Responsable
    manager_id UUID REFERENCES users(id),
    
    -- Proyecto asociado (si es almacén de obra)
    project_id UUID REFERENCES projects(id),
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_warehouses_warehouse_code ON warehouses(warehouse_code);
CREATE INDEX idx_warehouses_project_id ON warehouses(project_id);
CREATE INDEX idx_warehouses_manager_id ON warehouses(manager_id);
CREATE INDEX idx_warehouses_is_active ON warehouses(is_active);

COMMENT ON TABLE warehouses IS 'Almacenes y bodegas (centrales y de obra)';

-- ============================================================================
-- Tabla: inventory_movements
-- Descripción: Movimientos de inventario
-- ============================================================================
CREATE TABLE inventory_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_code VARCHAR(20) UNIQUE NOT NULL,
    movement_type movement_type NOT NULL,
    material_id UUID NOT NULL REFERENCES materials(id),
    
    -- Almacenes
    from_warehouse_id UUID REFERENCES warehouses(id),
    to_warehouse_id UUID REFERENCES warehouses(id),
    
    -- Cantidad
    quantity DECIMAL(12,2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    
    -- Costo
    unit_cost DECIMAL(12,2),
    total_cost DECIMAL(15,2),
    
    -- Fecha
    movement_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Relaciones
    project_id UUID REFERENCES projects(id),
    supplier_id UUID REFERENCES suppliers(id),
    purchase_order_id UUID,
    
    -- Documentación
    reference_document VARCHAR(100),
    notes TEXT,
    authorized_by UUID REFERENCES users(id),
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_movement_quantity CHECK (quantity > 0),
    CONSTRAINT chk_movement_warehouses CHECK (
        (movement_type = 'entry' AND to_warehouse_id IS NOT NULL) OR
        (movement_type = 'exit' AND from_warehouse_id IS NOT NULL) OR
        (movement_type = 'transfer' AND from_warehouse_id IS NOT NULL AND to_warehouse_id IS NOT NULL) OR
        (movement_type = 'adjustment')
    )
);

CREATE INDEX idx_inventory_movements_movement_code ON inventory_movements(movement_code);
CREATE INDEX idx_inventory_movements_material_id ON inventory_movements(material_id);
CREATE INDEX idx_inventory_movements_from_warehouse_id ON inventory_movements(from_warehouse_id);
CREATE INDEX idx_inventory_movements_to_warehouse_id ON inventory_movements(to_warehouse_id);
CREATE INDEX idx_inventory_movements_project_id ON inventory_movements(project_id);
CREATE INDEX idx_inventory_movements_movement_date ON inventory_movements(movement_date);
CREATE INDEX idx_inventory_movements_movement_type ON inventory_movements(movement_type);

COMMENT ON TABLE inventory_movements IS 'Movimientos de entrada, salida y transferencia de materiales';

-- ============================================================================
-- Tabla: project_materials
-- Descripción: Materiales asignados a proyectos
-- ============================================================================
CREATE TABLE project_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id),
    
    -- Cantidades
    estimated_quantity DECIMAL(12,2) NOT NULL,
    used_quantity DECIMAL(12,2) DEFAULT 0,
    remaining_quantity DECIMAL(12,2),
    unit VARCHAR(50) NOT NULL,
    
    -- Costos
    estimated_unit_cost DECIMAL(12,2),
    actual_unit_cost DECIMAL(12,2),
    estimated_total_cost DECIMAL(15,2),
    actual_total_cost DECIMAL(15,2) DEFAULT 0,
    
    -- Estado
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'ordered', 'received', 'in_use', 'completed'
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT uq_project_material UNIQUE(project_id, material_id),
    CONSTRAINT chk_project_material_quantities CHECK (
        estimated_quantity > 0 AND
        used_quantity >= 0 AND
        used_quantity <= estimated_quantity
    )
);

CREATE INDEX idx_project_materials_project_id ON project_materials(project_id);
CREATE INDEX idx_project_materials_material_id ON project_materials(material_id);
CREATE INDEX idx_project_materials_status ON project_materials(status);

COMMENT ON TABLE project_materials IS 'Materiales requeridos y utilizados en cada proyecto';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Generar códigos automáticos
CREATE OR REPLACE FUNCTION generate_material_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.material_code IS NULL OR NEW.material_code = '' THEN
        NEW.material_code := generate_unique_code('MAT', 'materials', 'material_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_materials_generate_code
    BEFORE INSERT ON materials
    FOR EACH ROW
    EXECUTE FUNCTION generate_material_code();

CREATE OR REPLACE FUNCTION generate_warehouse_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.warehouse_code IS NULL OR NEW.warehouse_code = '' THEN
        NEW.warehouse_code := generate_unique_code('WH', 'warehouses', 'warehouse_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_warehouses_generate_code
    BEFORE INSERT ON warehouses
    FOR EACH ROW
    EXECUTE FUNCTION generate_warehouse_code();

CREATE OR REPLACE FUNCTION generate_movement_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.movement_code IS NULL OR NEW.movement_code = '' THEN
        NEW.movement_code := generate_unique_code('MOV', 'inventory_movements', 'movement_code');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventory_movements_generate_code
    BEFORE INSERT ON inventory_movements
    FOR EACH ROW
    EXECUTE FUNCTION generate_movement_code();

-- Actualizar stock de materiales
CREATE OR REPLACE FUNCTION update_material_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.movement_type = 'entry' THEN
        UPDATE materials
        SET current_stock = current_stock + NEW.quantity
        WHERE id = NEW.material_id;
    ELSIF NEW.movement_type = 'exit' THEN
        UPDATE materials
        SET current_stock = current_stock - NEW.quantity
        WHERE id = NEW.material_id;
    ELSIF NEW.movement_type = 'transfer' THEN
        -- El stock total no cambia en transferencias
        NULL;
    ELSIF NEW.movement_type = 'adjustment' THEN
        UPDATE materials
        SET current_stock = NEW.quantity
        WHERE id = NEW.material_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventory_movements_update_stock
    AFTER INSERT ON inventory_movements
    FOR EACH ROW
    EXECUTE FUNCTION update_material_stock();

-- Actualizar updated_at
CREATE TRIGGER trg_materials_updated_at BEFORE UPDATE ON materials FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_warehouses_updated_at BEFORE UPDATE ON warehouses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_project_materials_updated_at BEFORE UPDATE ON project_materials FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_material_categories_updated_at BEFORE UPDATE ON material_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Calcular remaining_quantity
CREATE OR REPLACE FUNCTION calculate_remaining_quantity()
RETURNS TRIGGER AS $$
BEGIN
    NEW.remaining_quantity := NEW.estimated_quantity - NEW.used_quantity;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_project_materials_calculate_remaining
    BEFORE INSERT OR UPDATE ON project_materials
    FOR EACH ROW
    EXECUTE FUNCTION calculate_remaining_quantity();
