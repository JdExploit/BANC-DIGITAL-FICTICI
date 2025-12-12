-- ============================================
-- BANCO DIGITAL FICTICIO - INICIALIZACIÓN BD
-- ============================================
-- Este archivo se ejecuta AUTOMÁTICAMENTE al iniciar PostgreSQL
-- Configura toda la base de datos con datos de prueba

-- 1. CONFIGURAR EXTENSIONES NECESARIAS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. CREAR ROLES PARA POSTGREST
-- Rol anónimo para conexiones públicas
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'web_anon') THEN
        CREATE ROLE web_anon NOLOGIN;
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN;
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN;
    END IF;
    
    -- Dar permisos básicos
    GRANT USAGE ON SCHEMA public TO web_anon, authenticated, service_role;
END
$$;

-- 3. CREAR TABLAS PRINCIPALES

-- Tabla de usuarios (simulando Authentik)
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    role TEXT DEFAULT 'client',
    password_hash TEXT, -- Para simulación simple (en producción sería en Authentik)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de cuentas bancarias
CREATE TABLE IF NOT EXISTS accounts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_number TEXT UNIQUE NOT NULL,
    account_type TEXT DEFAULT 'current' CHECK (account_type IN ('current', 'savings', 'business')),
    balance DECIMAL(15,2) DEFAULT 0.00,
    currency TEXT DEFAULT 'EUR',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de transacciones
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    account_number TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    transaction_type TEXT CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer', 'payment')),
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de transferencias
CREATE TABLE IF NOT EXISTS transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_account TEXT NOT NULL,
    to_account TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    user_id UUID,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Tabla de logs de auditoría (para demostración)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    action TEXT NOT NULL,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. CREAR ÍNDICES PARA MEJOR RENDIMIENTO
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_account_number ON accounts(account_number);
CREATE INDEX IF NOT EXISTS idx_transactions_account_number ON transactions(account_number);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transfers_user_id ON transfers(user_id);
CREATE INDEX IF NOT EXISTS idx_transfers_created_at ON transfers(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);

-- 5. CONFIGURAR ROW LEVEL SECURITY (RLS) - VULNERABLE INTENCIONALMENTE
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Políticas RLS INTENCIONALMENTE VULNERABLES
-- A01: Broken Access Control - IDOR possible
CREATE POLICY "users_select_policy" ON users
    FOR SELECT USING (true); -- VULNERABLE: Todos pueden ver todos los usuarios

CREATE POLICY "accounts_select_policy" ON accounts
    FOR SELECT USING (true); -- VULNERABLE: Sin verificación de propiedad

CREATE POLICY "accounts_insert_policy" ON accounts
    FOR INSERT WITH CHECK (true); -- VULNERABLE: Cualquiera puede insertar

CREATE POLICY "transactions_select_policy" ON transactions
    FOR SELECT USING (true); -- VULNERABLE: Sin restricciones

CREATE POLICY "transfers_insert_policy" ON transfers
    FOR INSERT WITH CHECK (true); -- VULNERABLE: A04 - Sin rate limiting

-- Política para admin (simulación)
CREATE POLICY "admin_all_access" ON accounts
    FOR ALL TO service_role
    USING (true)
    WITH CHECK (true);

-- 6. INSERTAR DATOS DE PRUEBA

-- Insertar usuarios
INSERT INTO users (id, email, name, role, password_hash) VALUES
    ('11111111-1111-1111-1111-111111111101', 'cliente1@bbva.es', 'Juan Pérez', 'client', 
     crypt('Password123!', gen_salt('bf'))),
    
    ('11111111-1111-1111-1111-111111111102', 'cliente2@bbva.es', 'María García', 'client',
     crypt('Password123!', gen_salt('bf'))),
    
    ('11111111-1111-1111-1111-111111111103', 'cliente3@bbva.es', 'Carlos López', 'client',
     crypt('Password123!', gen_salt('bf'))),
    
    ('11111111-1111-1111-1111-111111111104', 'admin@bbva.es', 'Admin BBVA', 'service_role',
     crypt('AdminPassword123!', gen_salt('bf'))),

    ('11111111-1111-1111-1111-111111111105', 'victima@bbva.es', 'Usuario Víctima', 'client',
     crypt('VictimPassword123!', gen_salt('bf')))
ON CONFLICT (email) DO NOTHING;

-- Insertar cuentas bancarias
INSERT INTO accounts (user_id, account_number, account_type, balance) VALUES
    ('11111111-1111-1111-1111-111111111101', 'ES12000123456789012345', 'current', 15000.00),
    ('11111111-1111-1111-1111-111111111101', 'ES12000123456789012346', 'savings', 5000.00),
    
    ('11111111-1111-1111-1111-111111111102', 'ES12987654321098765432', 'current', 25000.00),
    ('11111111-1111-1111-1111-111111111102', 'ES12987654321098765433', 'business', 100000.00),
    
    ('11111111-1111-1111-1111-111111111103', 'ES12000998877665544332', 'current', 8000.00),
    
    ('11111111-1111-1111-1111-111111111104', 'ES12000000000000000001', 'current', 999999.99),
    
    ('11111111-1111-1111-1111-111111111105', 'ES12111111111111111111', 'current', 3000.00)
ON CONFLICT (account_number) DO NOTHING;

-- Insertar transacciones de prueba
INSERT INTO transactions (account_number, amount, description, transaction_type) VALUES
    ('ES12000123456789012345', -100.00, 'Compra Amazon', 'payment'),
    ('ES12000123456789012345', 500.00, 'Ingreso nómina', 'deposit'),
    ('ES12000123456789012345', -50.00, 'Supermercado Mercadona', 'payment'),
    ('ES12000123456789012345', -25.00, 'Netflix mensual', 'payment'),
    
    ('ES12987654321098765432', -200.00, 'Transferencia a familia', 'transfer'),
    ('ES12987654321098765432', 1000.00, 'Ingreso freelance', 'deposit'),
    ('ES12987654321098765432', -75.00, 'Gasolina', 'payment'),
    
    ('ES12000998877665544332', -30.00, 'Spotify', 'payment'),
    ('ES12000998877665544332', 1200.00, 'Nómina empresa', 'deposit'),
    
    ('ES12000000000000000001', 50000.00, 'Fondos administrativos', 'deposit'),
    ('ES12000000000000000001', -10000.00, 'Mantenimiento sistemas', 'payment'),
    
    ('ES12111111111111111111', -20.00, 'Cafetería', 'payment'),
    ('ES12111111111111111111', 800.00, 'Ingreso ocasional', 'deposit')
ON CONFLICT DO NOTHING;

-- Insertar algunas transferencias de prueba
INSERT INTO transfers (from_account, to_account, amount, description, user_id, status) VALUES
    ('ES12000123456789012345', 'ES12987654321098765432', 200.00, 'Préstamo amigo', '11111111-1111-1111-1111-111111111101', 'completed'),
    ('ES12987654321098765432', 'ES12000123456789012345', 50.00, 'Devolución', '11111111-1111-1111-1111-111111111102', 'completed'),
    ('ES12000998877665544332', 'ES12111111111111111111', 100.00, 'Regalo cumpleaños', '11111111-1111-1111-1111-111111111103', 'pending')
ON CONFLICT DO NOTHING;

-- Insertar logs de auditoría iniciales
INSERT INTO audit_logs (user_id, action, details) VALUES
    ('11111111-1111-1111-1111-111111111104', 'system_init', '{"message": "Sistema bancario inicializado"}'),
    ('11111111-1111-1111-1111-111111111101', 'user_login', '{"ip": "192.168.1.100", "browser": "Chrome"}'),
    ('11111111-1111-1111-1111-111111111102', 'user_login', '{"ip": "192.168.1.101", "browser": "Firefox"}')
ON CONFLICT DO NOTHING;

-- 7. CREAR FUNCIONES ÚTILES

-- Función para generar números de cuenta (para demostración)
CREATE OR REPLACE FUNCTION generate_account_number()
RETURNS TEXT AS $$
DECLARE
    new_number TEXT;
BEGIN
    LOOP
        new_number := 'ES12' || LPAD(FLOOR(RANDOM() * 10000000000000000000)::TEXT, 20, '0');
        EXIT WHEN NOT EXISTS (SELECT 1 FROM accounts WHERE account_number = new_number);
    END LOOP;
    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- Función vulnerable a SQL Injection (para A03)
CREATE OR REPLACE FUNCTION search_transactions(search_term TEXT)
RETURNS TABLE(
    id UUID,
    account_number TEXT,
    amount DECIMAL,
    description TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    -- VULNERABLE A SQL INJECTION - No usar en producción!
    RETURN QUERY EXECUTE format(
        'SELECT id, account_number, amount, description, created_at 
         FROM transactions 
         WHERE description ILIKE %L 
         OR account_number ILIKE %L
         ORDER BY created_at DESC',
        '%' || search_term || '%',
        '%' || search_term || '%'
    );
END;
$$ LANGUAGE plpgsql;

-- Función para transferencia (vulnerable a lógica de negocio)
CREATE OR REPLACE FUNCTION make_transfer(
    p_from_account TEXT,
    p_to_account TEXT,
    p_amount DECIMAL,
    p_description TEXT,
    p_user_id UUID
)
RETURNS UUID AS $$
DECLARE
    v_transfer_id UUID;
    v_from_balance DECIMAL;
BEGIN
    -- VULNERABLE A04: Sin verificación de límites de tasa
    -- VULNERABLE: Sin validación suficiente de fondos
    
    -- Verificar saldo (pero de forma insegura)
    SELECT balance INTO v_from_balance 
    FROM accounts 
    WHERE account_number = p_from_account;
    
    IF v_from_balance < p_amount THEN
        RAISE EXCEPTION 'Saldo insuficiente';
    END IF;
    
    -- Crear transferencia
    INSERT INTO transfers (from_account, to_account, amount, description, user_id, status)
    VALUES (p_from_account, p_to_account, p_amount, p_description, p_user_id, 'pending')
    RETURNING id INTO v_transfer_id;
    
    -- Actualizar balances (debería ser transacción, pero es simplificado)
    UPDATE accounts SET balance = balance - p_amount 
    WHERE account_number = p_from_account;
    
    UPDATE accounts SET balance = balance + p_amount 
    WHERE account_number = p_to_account;
    
    -- Registrar transacciones
    INSERT INTO transactions (account_number, amount, description, transaction_type)
    VALUES 
        (p_from_account, -p_amount, p_description || ' (envío)', 'transfer'),
        (p_to_account, p_amount, p_description || ' (recibo)', 'transfer');
    
    -- Marcar transferencia como completada
    UPDATE transfers 
    SET status = 'completed', completed_at = NOW()
    WHERE id = v_transfer_id;
    
    -- Log de auditoría
    INSERT INTO audit_logs (user_id, action, details)
    VALUES (p_user_id, 'transfer_completed', 
            jsonb_build_object(
                'from_account', p_from_account,
                'to_account', p_to_account,
                'amount', p_amount,
                'transfer_id', v_transfer_id
            ));
    
    RETURN v_transfer_id;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener datos de usuario por ID (vulnerable a IDOR)
CREATE OR REPLACE FUNCTION get_user_data(p_user_id UUID)
RETURNS TABLE(
    user_id UUID,
    email TEXT,
    name TEXT,
    role TEXT,
    total_balance DECIMAL
) AS $$
BEGIN
    -- VULNERABLE A01: No verifica que el usuario solicitante sea el propietario
    RETURN QUERY
    SELECT 
        u.id,
        u.email,
        u.name,
        u.role,
        COALESCE(SUM(a.balance), 0) as total_balance
    FROM users u
    LEFT JOIN accounts a ON u.id = a.user_id
    WHERE u.id = p_user_id
    GROUP BY u.id, u.email, u.name, u.role;
END;
$$ LANGUAGE plpgsql;

-- 8. CONFIGURAR PERMISOS DE USUARIOS

-- Dar permisos a los roles de PostgREST
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO web_anon;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO authenticated;

-- Permisos específicos para funciones
GRANT EXECUTE ON FUNCTION search_transactions(TEXT) TO web_anon;
GRANT EXECUTE ON FUNCTION make_transfer(TEXT, TEXT, DECIMAL, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_data(UUID) TO web_anon;
GRANT EXECUTE ON FUNCTION generate_account_number() TO service_role;

-- 9. CREAR VISTAS ÚTILES PARA LA APLICACIÓN

-- Vista para dashboard de usuario
CREATE OR REPLACE VIEW user_dashboard AS
SELECT 
    u.id as user_id,
    u.email,
    u.name,
    u.role,
    COUNT(DISTINCT a.id) as num_accounts,
    COALESCE(SUM(a.balance), 0) as total_balance,
    COUNT(t.id) as recent_transactions_count,
    MAX(t.created_at) as last_transaction_date
FROM users u
LEFT JOIN accounts a ON u.id = a.user_id
LEFT JOIN transactions t ON a.account_number = t.account_number 
    AND t.created_at > NOW() - INTERVAL '30 days'
GROUP BY u.id, u.email, u.name, u.role;

-- Vista para transacciones recientes
CREATE OR REPLACE VIEW recent_transactions AS
SELECT 
    t.*,
    a.user_id,
    CASE 
        WHEN t.amount > 0 THEN 'income'
        ELSE 'expense'
    END as transaction_category
FROM transactions t
JOIN accounts a ON t.account_number = a.account_number
ORDER BY t.created_at DESC
LIMIT 100;

-- 10. CREAR TRIGGERS PARA DATOS AUTOMÁTICOS

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_accounts_updated_at 
    BEFORE UPDATE ON accounts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 11. CONFIGURACIÓN PARA DEMOSTRAR VULNERABILIDAD A03 (SQL Injection)

-- Crear tabla adicional para demostración de búsqueda vulnerable
CREATE TABLE IF NOT EXISTS transaction_search_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    search_term TEXT NOT NULL,
    user_id UUID,
    ip_address INET,
    results_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función de búsqueda EXTREMADAMENTE VULNERABLE
CREATE OR REPLACE FUNCTION vulnerable_search(p_search TEXT, p_user_id UUID DEFAULT NULL)
RETURNS TABLE(
    transaction_id UUID,
    account_number TEXT,
    amount DECIMAL,
    description TEXT,
    transaction_date TIMESTAMPTZ
) AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- VULNERABILIDAD CRÍTICA: Concatenación directa de entrada de usuario
    v_sql := 'SELECT id, account_number, amount, description, created_at 
              FROM transactions 
              WHERE description LIKE ''%' || p_search || '%'' 
              OR account_number LIKE ''%' || p_search || '%''
              ORDER BY created_at DESC';
    
    -- Log de la búsqueda (para demostrar la inyección)
    INSERT INTO transaction_search_log (search_term, user_id, results_count)
    VALUES (p_search, p_user_id, 0); -- El count se actualizará después
    
    -- Ejecutar la consulta vulnerable
    RETURN QUERY EXECUTE v_sql;
    
    -- Actualizar count (no es seguro, solo para demo)
    UPDATE transaction_search_log 
    SET results_count = (SELECT COUNT(*) FROM (SELECT 1 FROM transactions 
                             WHERE description LIKE '%' || p_search || '%' 
                             OR account_number LIKE '%' || p_search || '%') t)
    WHERE search_term = p_search AND user_id = p_user_id
    AND created_at = (SELECT MAX(created_at) FROM transaction_search_log 
                      WHERE search_term = p_search AND user_id = p_user_id);
    
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vulnerable_search(TEXT, UUID) TO web_anon;

-- 12. DATOS ADICIONALES PARA ENRIQUECER LA DEMOSTRACIÓN

-- Insertar más transacciones para hacer las búsquedas interesantes
INSERT INTO transactions (account_number, amount, description, transaction_type) VALUES
    ('ES12000123456789012345', -15.50, 'Café Starbucks', 'payment'),
    ('ES12000123456789012345', -89.99, 'Zapatos El Corte Inglés', 'payment'),
    ('ES12000123456789012345', 300.00, 'Devolución impuestos', 'deposit'),
    
    ('ES12987654321098765432', -45.00, 'Cena restaurante', 'payment'),
    ('ES12987654321098765432', -120.00, 'Compra Amazon: Libros', 'payment'),
    ('ES12987654321098765432', 750.00, 'Ingreso alquiler', 'deposit'),
    
    ('ES12000998877665544332', -9.99, 'Spotify Premium', 'payment'),
    ('ES12000998877665544332', -60.00, 'Gimnasio mensual', 'payment'),
    ('ES12000998877665544332', 1500.00, 'Nómina diciembre', 'deposit'),
    
    ('ES12111111111111111111', -5.00, 'Autobús urbano', 'payment'),
    ('ES12111111111111111111', -12.50, 'Farmacia', 'payment'),
    ('ES12111111111111111111', 200.00, 'Venta mueble', 'deposit')
ON CONFLICT DO NOTHING;

-- 13. CONFIGURAR USUARIO ADMINISTRATIVO PARA POSTGREST

-- Crear usuario para conexiones de la aplicación
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'bbva_app') THEN
        CREATE USER bbva_app WITH PASSWORD 'app_password_insecure';
        GRANT web_anon TO bbva_app;
    END IF;
END
$$;

-- 14. MENSAJE DE ÉXITO
DO $$ 
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'BASE DE DATOS BBVA DIGITAL INICIALIZADA';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Usuarios creados: %', (SELECT COUNT(*) FROM users);
    RAISE NOTICE 'Cuentas creadas: %', (SELECT COUNT(*) FROM accounts);
    RAISE NOTICE 'Transacciones creadas: %', (SELECT COUNT(*) FROM transactions);
    RAISE NOTICE '============================================';
    RAISE NOTICE 'VULNERABILIDADES IMPLEMENTADAS:';
    RAISE NOTICE '- A01: IDOR (funciones get_user_data sin validación)';
    RAISE NOTICE '- A02: JWT configurado con secret débil';
    RAISE NOTICE '- A03: SQL Injection (función vulnerable_search)';
    RAISE NOTICE '- A04: Sin rate limiting (función make_transfer)';
    RAISE NOTICE '============================================';
END $$;