FROM postgres:15-alpine

# Instalar herramientas útiles
RUN apk add --no-cache bash

# Copiar scripts de inicialización
COPY init-db.sql /docker-entrypoint-initdb.d/init.sql
COPY setup-storage.sh /docker-entrypoint-initdb.d/setup-storage.sh

# Hacer ejecutable el script
RUN chmod +x /docker-entrypoint-initdb.d/setup-storage.sh

# Exponer puerto
EXPOSE 5432