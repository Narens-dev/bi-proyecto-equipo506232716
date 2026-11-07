-- 08 · Tabla de hechos. Grano: una validación de pasaje (estación, ruta, bus, tarifa, minuto)
CREATE TABLE dw.fact_validaciones (
    id_validacion          BIGSERIAL     PRIMARY KEY,
    cod_validacion         VARCHAR(15)   NOT NULL UNIQUE,  -- dimensión degenerada (id de F1)
    sk_tiempo              INTEGER       NOT NULL REFERENCES dw.dim_tiempo (sk_tiempo),
    sk_hora                SMALLINT      NOT NULL REFERENCES dw.dim_hora (sk_hora),
    sk_estacion            INTEGER       NOT NULL REFERENCES dw.dim_estacion (sk_estacion),
    sk_ruta                INTEGER       NOT NULL REFERENCES dw.dim_ruta (sk_ruta),
    sk_bus                 INTEGER       NOT NULL REFERENCES dw.dim_bus (sk_bus),
    sk_tarifa              INTEGER       NOT NULL REFERENCES dw.dim_tarifa (sk_tarifa),
    fecha_hora             TIMESTAMP     NOT NULL,
    cantidad_validaciones  SMALLINT      NOT NULL DEFAULT 1,
    monto_pagado           NUMERIC(10,2) NOT NULL CHECK (monto_pagado > 0)
);

CREATE INDEX ix_fact_tiempo   ON dw.fact_validaciones (sk_tiempo);
CREATE INDEX ix_fact_hora     ON dw.fact_validaciones (sk_hora);
CREATE INDEX ix_fact_estacion ON dw.fact_validaciones (sk_estacion);
CREATE INDEX ix_fact_ruta     ON dw.fact_validaciones (sk_ruta);
CREATE INDEX ix_fact_bus      ON dw.fact_validaciones (sk_bus);
CREATE INDEX ix_fact_tarifa   ON dw.fact_validaciones (sk_tarifa);
