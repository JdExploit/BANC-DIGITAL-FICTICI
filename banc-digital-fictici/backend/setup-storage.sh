#!/bin/bash
echo "🔧 Configurando storage para la flag..."

# Crear directorio para la flag
mkdir -p /var/lib/postgresql/storage/admin-secrets

# Crear archivo secrets.txt
echo "fin has llegado flag[congratulations_bbva_digital_hacked]" > /var/lib/postgresql/storage/admin-secrets/secrets.txt

# Crear archivos adicionales para demostración
echo "Backup de claves de cifrado" > /var/lib/postgresql/storage/admin-secrets/backup.txt
echo "Lista de administradores: admin@bbva.es" > /var/lib/postgresql/storage/admin-secrets/admins.txt

echo "✅ Storage configurado"