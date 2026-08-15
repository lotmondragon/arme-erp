-- ============================================================================
-- ARME ERP - Script Maestro de Instalación
-- Sistema ERP para Construcción de Naves Industriales
-- ============================================================================
-- 
-- INSTRUCCIONES DE INSTALACIÓN:
-- 
-- 1. Crear la base de datos:
--    CREATE DATABASE arme_erp WITH ENCODING 'UTF8' LC_COLLATE='es_MX.UTF-8' LC_CTYPE='es_MX.UTF-8';
--
-- 2. Conectarse a la base de datos:
--    \c arme_erp
--
-- 3. Ejecutar este script:
--    \i /path/to/install.sql
--
-- ============================================================================

\echo '============================================================================'
\echo 'ARME ERP - Instalación de Base de Datos'
\echo '============================================================================'
\echo ''

-- Configuración de sesión
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

\echo 'Paso 1/9: Instalando extensiones y tipos de datos...'
\i schema/01_extensions_and_types.sql

\echo 'Paso 2/9: Creando módulo de seguridad...'
\i schema/02_security_module.sql

\echo 'Paso 3/9: Creando módulo de clientes...'
\i schema/03_clients_module.sql

\echo 'Paso 4/9: Creando módulo de proyectos...'
\i schema/04_projects_module.sql

\echo 'Paso 5/9: Creando módulo financiero...'
\i schema/05_financial_module.sql

\echo 'Paso 6/9: Creando módulo de proveedores...'
\i schema/06_suppliers_module.sql

\echo 'Paso 7/9: Creando módulo de inventario...'
\i schema/07_inventory_module.sql

\echo 'Paso 8/9: Creando módulo de auditoría...'
\i schema/08_audit_module.sql

\echo 'Paso 9/9: Creando vistas analíticas...'
\i schema/09_analytical_views.sql

\echo ''
\echo '============================================================================'
\echo 'Instalación completada exitosamente'
\echo '============================================================================'
\echo ''
\echo 'Estadísticas de la base de datos:'

SELECT 
    schemaname,
    COUNT(*) as total_tables
FROM pg_tables 
WHERE schemaname = 'public'
GROUP BY schemaname;

\echo ''
\echo 'Para crear un usuario administrador inicial, ejecutar:'
\echo "INSERT INTO users (username, email, password_hash, first_name, last_name, is_internal, status)"
\echo "VALUES ('admin', 'admin@arme-erp.local', crypt('Admin123!', gen_salt('bf')), 'Admin', 'Sistema', true, 'active');"
\echo ''
