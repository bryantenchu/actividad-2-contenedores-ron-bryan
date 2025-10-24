CREATE TABLE IF NOT EXISTS insumos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    cantidad INTEGER NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO insumos (nombre, cantidad, precio) VALUES
    ('Bolígrafos azules', 50, 15.00),
    ('Resmas de papel A4', 10, 120.00),
    ('Carpetas archivadoras', 25, 85.00),
    ('Marcadores permanentes', 30, 45.00),
    ('Clips metálicos', 100, 12.50),
    ('Grapadoras', 5, 75.00),
    ('Libretas tamaño carta', 20, 60.00),
    ('Post-it variados', 40, 35.00);

SELECT * FROM insumos;
