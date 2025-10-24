FROM postgres:15-alpine

# Variables de entorno para la base de datos
ENV POSTGRES_DB=fintech_db
ENV POSTGRES_USER=fintech_user
ENV POSTGRES_PASSWORD=fintech_password

# Copia script de inicialización
COPY init.sql /docker-entrypoint-initdb.d/

# Expone el puerto de PostgreSQL
EXPOSE 5432

