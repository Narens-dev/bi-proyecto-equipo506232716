-- 03 · Dimensión hora del día (grano: minuto). Jerarquía minuto -> hora -> franja horaria
CREATE TABLE dw.dim_hora (
    sk_hora         SMALLINT     PRIMARY KEY,          -- minuto del día: hora*60 + minuto (0..1439)
    hora_minuto     TIME         NOT NULL UNIQUE,
    hora            SMALLINT     NOT NULL,
    minuto          SMALLINT     NOT NULL,
    franja_horaria  VARCHAR(20)  NOT NULL,
    orden_franja    SMALLINT     NOT NULL,
    es_hora_pico    BOOLEAN      NOT NULL
);
