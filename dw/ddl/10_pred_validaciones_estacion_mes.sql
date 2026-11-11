-- 10 · Tabla de predicciones del modelo de la Entrega 3 (pregunta P3)
-- Una fila por estación y mes: valores reales y predichos del periodo de prueba (oct–dic 2025)
-- y pronóstico del trimestre siguiente (ene–mar 2026).
-- Es idempotente: el notebook modelo/modelo_demanda_estacion.ipynb lo ejecuta antes de escribir.

-- 1. La dimensión de tiempo se extiende al horizonte del pronóstico (primer trimestre de 2026),
--    con la misma lógica de etl/sql/q_dim_tiempo.sql, para que cada predicción tenga su sk_tiempo.
INSERT INTO dw.dim_tiempo (sk_tiempo, fecha, dia, dia_semana, nombre_dia, es_fin_semana, semana_iso,
                           mes, nombre_mes, anio_mes, trimestre, semestre, anio)
SELECT CAST(to_char(d, 'YYYYMMDD') AS INTEGER),
       CAST(d AS DATE),
       CAST(EXTRACT(DAY FROM d) AS SMALLINT),
       CAST(EXTRACT(ISODOW FROM d) AS SMALLINT),
       (ARRAY['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'])[EXTRACT(ISODOW FROM d)],
       EXTRACT(ISODOW FROM d) IN (6, 7),
       CAST(EXTRACT(WEEK FROM d) AS SMALLINT),
       CAST(EXTRACT(MONTH FROM d) AS SMALLINT),
       (ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'])[EXTRACT(MONTH FROM d)],
       to_char(d, 'YYYY-MM'),
       CAST(EXTRACT(QUARTER FROM d) AS SMALLINT),
       CAST(CASE WHEN EXTRACT(MONTH FROM d) <= 6 THEN 1 ELSE 2 END AS SMALLINT),
       CAST(EXTRACT(YEAR FROM d) AS SMALLINT)
FROM generate_series(DATE '2026-01-01', DATE '2026-03-31', INTERVAL '1 day') AS g(d)
ON CONFLICT (sk_tiempo) DO NOTHING;

-- 2. Tabla de predicciones
CREATE TABLE IF NOT EXISTS dw.pred_validaciones_estacion_mes (
    sk_estacion            INTEGER       NOT NULL REFERENCES dw.dim_estacion (sk_estacion),
    sk_tiempo              INTEGER       NOT NULL REFERENCES dw.dim_tiempo (sk_tiempo),  -- primer día del mes
    anio                   SMALLINT      NOT NULL,
    mes                    SMALLINT      NOT NULL,
    tipo_registro          VARCHAR(12)   NOT NULL CHECK (tipo_registro IN ('prueba', 'pronostico')),
    validaciones_reales    INTEGER,                    -- NULL en el pronóstico (mes aún no ocurrido)
    validaciones_predichas NUMERIC(10,2) NOT NULL,
    error_absoluto         NUMERIC(10,2),              -- |real − predicho|, solo en prueba
    modelo                 VARCHAR(40)   NOT NULL,
    fecha_ejecucion        TIMESTAMP     NOT NULL DEFAULT now(),
    PRIMARY KEY (sk_estacion, sk_tiempo)
);

COMMENT ON TABLE dw.pred_validaciones_estacion_mes IS
    'Predicciones del modelo de demanda por estación y mes (Entrega 3, pregunta P3)';

-- 3. Vista para el tablero (página «Predicciones»): predicción + valor real + atributos de la estación
CREATE OR REPLACE VIEW dw.v_tablero_predicciones AS
SELECT p.sk_estacion, p.sk_tiempo, t.fecha AS fecha_mes, t.anio_mes, p.anio, p.mes,
       e.nombre_estacion, e.tipo_estacion, e.nombre_troncal,
       CASE p.tipo_registro WHEN 'prueba' THEN 'Prueba oct–dic 2025' ELSE 'Pronóstico ene–mar 2026' END AS periodo,
       p.validaciones_reales, p.validaciones_predichas, p.error_absoluto, p.modelo
FROM dw.pred_validaciones_estacion_mes p
JOIN dw.dim_estacion e ON e.sk_estacion = p.sk_estacion
JOIN dw.dim_tiempo  t ON t.sk_tiempo  = p.sk_tiempo;
