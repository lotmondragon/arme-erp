-- ============================================================================
-- ARME ERP - Database Schema
-- Extensiones y Tipos de Datos
-- ============================================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para búsquedas de texto

-- ============================================================================
-- ENUMS (Tipos Enumerados)
-- ============================================================================

-- Estados de Usuario
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended', 'pending_activation');

-- Estados de Proyecto
CREATE TYPE project_status AS ENUM (
    'planning',           -- Planeación
    'approved',          -- Aprobado
    'in_progress',       -- En ejecución
    'on_hold',           -- En pausa
    'supervision',       -- En supervisión
    'delivery',          -- En entrega
    'completed',         -- Completado
    'cancelled'          -- Cancelado
);

-- Estados de Etapa de Proyecto
CREATE TYPE stage_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- Estados de Tarea
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'review', 'completed', 'cancelled');

-- Prioridad de Tarea
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- Estados de Presupuesto
CREATE TYPE budget_status AS ENUM ('draft', 'pending_approval', 'approved', 'rejected', 'revised');

-- Estados de Contrato
CREATE TYPE contract_status AS ENUM ('draft', 'pending_signature', 'active', 'completed', 'cancelled');

-- Tipos de Contrato
CREATE TYPE contract_type AS ENUM ('client_contract', 'supplier_contract', 'subcontractor_contract');

-- Estados de Factura
CREATE TYPE invoice_status AS ENUM ('draft', 'sent', 'paid', 'partially_paid', 'overdue', 'cancelled');

-- Tipos de Factura
CREATE TYPE invoice_type AS ENUM ('income', 'expense');

-- Estados de Pago
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'cancelled');

-- Métodos de Pago
CREATE TYPE payment_method AS ENUM ('cash', 'transfer', 'check', 'credit_card', 'debit_card', 'other');

-- Tipos de Movimiento de Inventario
CREATE TYPE movement_type AS ENUM ('entry', 'exit', 'transfer', 'adjustment');

-- Tipos de Documento
CREATE TYPE document_type AS ENUM (
    'contract',
    'invoice',
    'receipt',
    'permit',
    'blueprint',
    'photo',
    'report',
    'certificate',
    'other'
);

-- Tipos de Gasto
CREATE TYPE expense_type AS ENUM (
    'material',
    'labor',
    'equipment',
    'subcontractor',
    'transport',
    'administrative',
    'other'
);

-- ============================================================================
-- FUNCIONES AUXILIARES
-- ============================================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Función para generar código único
CREATE OR REPLACE FUNCTION generate_unique_code(prefix TEXT, table_name TEXT, column_name TEXT)
RETURNS TEXT AS $$
DECLARE
    new_code TEXT;
    code_exists BOOLEAN;
BEGIN
    LOOP
        new_code := prefix || '-' || LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
        EXECUTE format('SELECT EXISTS(SELECT 1 FROM %I WHERE %I = $1)', table_name, column_name)
        INTO code_exists
        USING new_code;
        
        EXIT WHEN NOT code_exists;
    END LOOP;
    
    RETURN new_code;
END;
$$ LANGUAGE plpgsql;

-- Función para validar RFC mexicano
CREATE OR REPLACE FUNCTION validate_rfc(rfc TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- RFC persona moral: 12 caracteres
    -- RFC persona física: 13 caracteres
    RETURN rfc ~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$';
END;
$$ LANGUAGE plpgsql;

-- Función para calcular edad de un registro
CREATE OR REPLACE FUNCTION calculate_age_days(date_field TIMESTAMP)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(DAY FROM (CURRENT_TIMESTAMP - date_field));
END;
$$ LANGUAGE plpgsql;

COMMENT ON EXTENSION "uuid-ossp" IS 'Generación de UUIDs';
COMMENT ON EXTENSION "pgcrypto" IS 'Funciones criptográficas para encriptación';
COMMENT ON EXTENSION "pg_trgm" IS 'Búsqueda de texto con trigrams';
