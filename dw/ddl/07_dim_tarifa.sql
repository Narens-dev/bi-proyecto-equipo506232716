-- 07 · Dimensión tarifa y medio de pago (F1). Jerarquía: tipo_tarifa -> grupo_tarifa
CREATE TABLE dw.dim_tarifa (
    sk_tarifa         SERIAL        PRIMARY KEY,
    tipo_tarifa       VARCHAR(20)   NOT NULL,
    grupo_tarifa      VARCHAR(20)   NOT NULL,          -- Plena / Subsidiada
    metodo_pago       VARCHAR(25)   NOT NULL,
    CONSTRAINT uq_tarifa UNIQUE (tipo_tarifa, metodo_pago)
);
