-- 02 · Dimensión de tiempo (grano: día). Jerarquía día -> mes -> trimestre -> año
-- La llave es inteligente (aaaammdd), práctica estándar para la dimensión calendario.
CREATE TABLE dw.dim_tiempo (
    sk_tiempo       INTEGER      PRIMARY KEY,          -- aaaammdd
    fecha           DATE         NOT NULL UNIQUE,
    dia             SMALLINT     NOT NULL,
    dia_semana      SMALLINT     NOT NULL,             -- 1 = lunes ... 7 = domingo (ISO)
    nombre_dia      VARCHAR(10)  NOT NULL,
    es_fin_semana   BOOLEAN      NOT NULL,
    semana_iso      SMALLINT     NOT NULL,
    mes             SMALLINT     NOT NULL,
    nombre_mes      VARCHAR(10)  NOT NULL,
    anio_mes        CHAR(7)      NOT NULL,             -- '2024-01'
    trimestre       SMALLINT     NOT NULL,
    semestre        SMALLINT     NOT NULL,
    anio            SMALLINT     NOT NULL
);
