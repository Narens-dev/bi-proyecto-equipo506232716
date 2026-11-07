-- 05 · Dimensión ruta (códigos de F1 enriquecidos con la troncal de F3 por letra)
-- Jerarquía: ruta -> troncal
CREATE TABLE dw.dim_ruta (
    sk_ruta           SERIAL        PRIMARY KEY,
    cod_ruta          VARCHAR(10)   NOT NULL UNIQUE,   -- p. ej. B12
    letra_troncal     VARCHAR(3)    NOT NULL,
    nombre_troncal    VARCHAR(60)   NOT NULL,
    tipo_servicio     VARCHAR(20)   NOT NULL
);
