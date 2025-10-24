# Usar Node.js Alpine
FROM node:18-alpine

# Argumento de build para la URL del API
ARG VITE_API_URL=http://localhost:3001

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Instalar serve globalmente para servir archivos estáticos
RUN npm install -g serve

# Copiar el resto de archivos
COPY . .

# Construir la aplicación con la variable de entorno
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

# Exponer el puerto 3000
EXPOSE 3000

# Comando para servir la aplicación en modo producción
CMD ["serve", "-s", "dist", "-l", "3000"]
