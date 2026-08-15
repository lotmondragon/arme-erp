-- ============================================================================
-- MÓDULO DE SEGURIDAD
-- Gestión de usuarios, roles y permisos
-- ============================================================================

-- ============================================================================
-- Tabla: users
-- Descripción: Usuarios del sistema (internos y externos)
-- ============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    mobile VARCHAR(20),
    avatar_url VARCHAR(500),
    status user_status DEFAULT 'pending_activation',
    is_internal BOOLEAN DEFAULT true, -- true: empleado, false: cliente
    employee_code VARCHAR(20) UNIQUE,
    department VARCHAR(100),
    position VARCHAR(100),
    hire_date DATE,
    last_login_at TIMESTAMP,
    last_login_ip INET,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    password_changed_at TIMESTAMP,
    must_change_password BOOLEAN DEFAULT false,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(255),
    email_verified BOOLEAN DEFAULT false,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMP,
    preferences JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMP,
    
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_username_length CHECK (char_length(username) >= 3),
    CONSTRAINT chk_failed_attempts CHECK (failed_login_attempts >= 0)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_employee_code ON users(employee_code) WHERE employee_code IS NOT NULL;
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

COMMENT ON TABLE users IS 'Usuarios del sistema (empleados y clientes)';
COMMENT ON COLUMN users.is_internal IS 'true = empleado interno, false = cliente externo';
COMMENT ON COLUMN users.password_hash IS 'Hash bcrypt/argon2 de la contraseña';
COMMENT ON COLUMN users.two_factor_secret IS 'Secret para TOTP (Google Authenticator)';

-- ============================================================================
-- Tabla: roles
-- Descripción: Roles del sistema
-- ============================================================================
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(150) NOT NULL,
    description TEXT,
    is_system_role BOOLEAN DEFAULT false, -- No se puede eliminar si es true
    level INTEGER DEFAULT 0, -- Nivel jerárquico del rol
    permissions_summary JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    CONSTRAINT chk_role_level CHECK (level >= 0)
);

CREATE INDEX idx_roles_name ON roles(name);
CREATE INDEX idx_roles_is_active ON roles(is_active);

COMMENT ON TABLE roles IS 'Roles del sistema con niveles jerárquicos';
COMMENT ON COLUMN roles.is_system_role IS 'Roles del sistema que no pueden ser eliminados';
COMMENT ON COLUMN roles.level IS 'Nivel jerárquico: 0=admin, 1=manager, 2=supervisor, 3=user';

-- ============================================================================
-- Tabla: permissions
-- Descripción: Permisos granulares del sistema
-- ============================================================================
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(150) NOT NULL,
    description TEXT,
    module VARCHAR(50) NOT NULL, -- ej: 'projects', 'clients', 'finances'
    action VARCHAR(50) NOT NULL, -- ej: 'create', 'read', 'update', 'delete'
    resource VARCHAR(100), -- ej: 'project', 'budget', 'invoice'
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_permission_name_format CHECK (name ~ '^[a-z_]+\.[a-z_]+(\.[a-z_]+)?$')
);

CREATE INDEX idx_permissions_module ON permissions(module);
CREATE INDEX idx_permissions_action ON permissions(action);
CREATE INDEX idx_permissions_name ON permissions(name);

COMMENT ON TABLE permissions IS 'Permisos granulares del sistema';
COMMENT ON COLUMN permissions.name IS 'Formato: module.action.resource (ej: projects.create, finances.read.invoices)';

-- ============================================================================
-- Tabla: user_roles
-- Descripción: Relación muchos a muchos entre usuarios y roles
-- ============================================================================
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    
    CONSTRAINT uq_user_role UNIQUE(user_id, role_id)
);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_user_roles_expires_at ON user_roles(expires_at) WHERE expires_at IS NOT NULL;

COMMENT ON TABLE user_roles IS 'Asignación de roles a usuarios';
COMMENT ON COLUMN user_roles.expires_at IS 'Fecha de expiración del rol (opcional)';

-- ============================================================================
-- Tabla: role_permissions
-- Descripción: Relación muchos a muchos entre roles y permisos
-- ============================================================================
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID REFERENCES users(id),
    
    CONSTRAINT uq_role_permission UNIQUE(role_id, permission_id)
);

CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);

COMMENT ON TABLE role_permissions IS 'Permisos asignados a cada rol';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger para actualizar updated_at en users
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para actualizar updated_at en roles
CREATE TRIGGER trg_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para actualizar updated_at en permissions
CREATE TRIGGER trg_permissions_updated_at
    BEFORE UPDATE ON permissions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- DATOS INICIALES
-- ============================================================================

-- Insertar roles del sistema
INSERT INTO roles (name, display_name, description, is_system_role, level) VALUES
('super_admin', 'Super Administrador', 'Acceso total al sistema', true, 0),
('admin', 'Administrador', 'Administrador general', true, 0),
('project_manager', 'Gestor de Proyectos', 'Gestión de proyectos y obras', true, 1),
('accountant', 'Contador', 'Gestión financiera y contable', true, 1),
('supervisor', 'Supervisor de Obra', 'Supervisión de obras en campo', true, 2),
('client', 'Cliente', 'Cliente externo con acceso limitado', true, 3);

-- Insertar permisos básicos
INSERT INTO permissions (name, display_name, description, module, action, resource) VALUES
-- Proyectos
('projects.create', 'Crear Proyectos', 'Crear nuevos proyectos', 'projects', 'create', 'project'),
('projects.read', 'Ver Proyectos', 'Ver información de proyectos', 'projects', 'read', 'project'),
('projects.update', 'Actualizar Proyectos', 'Modificar proyectos existentes', 'projects', 'update', 'project'),
('projects.delete', 'Eliminar Proyectos', 'Eliminar proyectos', 'projects', 'delete', 'project'),
-- Clientes
('clients.create', 'Crear Clientes', 'Registrar nuevos clientes', 'clients', 'create', 'client'),
('clients.read', 'Ver Clientes', 'Ver información de clientes', 'clients', 'read', 'client'),
('clients.update', 'Actualizar Clientes', 'Modificar clientes existentes', 'clients', 'update', 'client'),
('clients.delete', 'Eliminar Clientes', 'Eliminar clientes', 'clients', 'delete', 'client'),
-- Finanzas
('finances.read', 'Ver Finanzas', 'Ver información financiera', 'finances', 'read', 'all'),
('finances.create.invoice', 'Crear Facturas', 'Crear facturas', 'finances', 'create', 'invoice'),
('finances.approve.payment', 'Aprobar Pagos', 'Aprobar pagos', 'finances', 'approve', 'payment'),
-- Inventario
('inventory.read', 'Ver Inventario', 'Ver inventario', 'inventory', 'read', 'material'),
('inventory.manage', 'Gestionar Inventario', 'Gestionar entradas/salidas', 'inventory', 'manage', 'material'),
-- Usuarios
('users.manage', 'Gestionar Usuarios', 'Administrar usuarios del sistema', 'users', 'manage', 'user'),
('roles.manage', 'Gestionar Roles', 'Administrar roles y permisos', 'roles', 'manage', 'role');
