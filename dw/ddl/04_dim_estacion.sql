-- 04 · Dimensión estación (fuente F2 enriquecida con F3 por id_trazado)
-- Jerarquía: estación -> trazado -> troncal
CREATE TABLE dw.dim_estacion (
    sk_estacion       SERIAL        PRIMARY KEY,       -- llave subrogada generada en la carga
    cod_estacion      VARCHAR(10)   NOT NULL UNIQUE,   -- num_est de la fuente F2
    nombre_estacion   VARCHAR(80)   NOT NULL,
    ubicacion         VARCHAR(80),
    tipo_estacion     VARCHAR(20)   NOT NULL,
    num_vagones       SMALLINT,
    num_accesos       SMALLINT,
    capacidad_biart   SMALLINT,
    capacidad_art     SMALLINT,
    area_m2           NUMERIC(10,2),
    latitud           NUMERIC(10,7),
    longitud          NUMERIC(10,7),
    id_trazado        VARCHAR(10)   NOT NULL,
    nombre_trazado    VARCHAR(80)   NOT NULL,
    letra_troncal     VARCHAR(3)    NOT NULL,
    nombre_troncal    VARCHAR(60)   NOT NULL
);
