-- Tabla de usuarios (simulando Authentik)
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    role TEXT DEFAULT 'client',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de cuentas bancarias
CREATE TABLE accounts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    account_number TEXT UNIQUE NOT NULL,
    account_type TEXT DEFAULT 'current',
    balance DECIMAL(15,2) DEFAULT 0.00,
    currency TEXT DEFAULT 'EUR',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de transacciones
CREATE TABLE transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    account_number TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    transaction_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de transferencias
CREATE TABLE transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_account TEXT NOT NULL,
    to_account TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    user_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) - Configuración vulnerable
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;

-- Políticas RLS (vulnerables a bypass)
CREATE POLICY "Users can view own accounts" ON accounts
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own transfers" ON transfers
    FOR INSERT WITH CHECK (true); -- VULNERABLE: sin verificación

-- Insertar datos de prueba
INSERT INTO users (id, email, name, role) VALUES
    ('11111111-1111-1111-1111-111111111101', 'cliente1@bbva.es', 'Juan Pérez', 'client'),
    ('11111111-1111-1111-1111-111111111102', 'cliente2@bbva.es', 'María García', 'client'),
    ('11111111-1111-1111-1111-111111111103', 'admin@bbva.es', 'Admin BBVA', 'service_role');

INSERT INTO accounts (user_id, account_number, balance) VALUES
    ('11111111-1111-1111-1111-111111111101', 'ES12000123456789012345', 15000.00),
    ('11111111-1111-1111-1111-111111111102', 'ES12987654321098765432', 25000.00);

INSERT INTO transactions (account_number, amount, description) VALUES
    ('ES12000123456789012345', -100.00, 'Compra Amazon'),
    ('ES12000123456789012345', 500.00, 'Ingreso nómina'),
    ('ES12987654321098765432', -50.00, 'Supermercado');

-- Crear bucket de storage para la flag
INSERT INTO storage.buckets (id, name, public) VALUES
    ('admin-secrets', 'admin-secrets', true);