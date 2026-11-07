-- 06 · Dimensión bus (códigos de F1)
CREATE TABLE dw.dim_bus (
    sk_bus            SERIAL        PRIMARY KEY,
    cod_bus           VARCHAR(10)   NOT NULL UNIQUE,   -- p. ej. BUS-209
    numero_bus        SMALLINT
);
