FROM node:18-alpine

WORKDIR /app

# Copiar dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar aplicación
COPY . .

# Exponer puerto
EXPOSE 3000

# Iniciar aplicación
CMD ["npm", "start"]