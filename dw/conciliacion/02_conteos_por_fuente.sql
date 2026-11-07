-- =====================================================================
-- Conciliación · 02 · Leídos = cargados + descartados, por fuente (tabla 3.1)
-- Requiere haber ejecutado 01_cargar_fuentes_crudas.sql
-- =====================================================================

-- F1 · validaciones -> dw.fact_validaciones
WITH fuente AS (
    SELECT count(*)                       AS leidos,
           count(*) - count(DISTINCT id_validacion) AS duplicados
    FROM conciliacion.f1_validaciones),
unicas AS (   -- primera aparición de cada id, como en el paso regla_elimina_duplicados
    SELECT DISTINCT ON (id_validacion) * FROM conciliacion.f1_validaciones),
monto AS (
    SELECT count(*) AS monto_no_valido FROM unicas WHERE monto_pagado::numeric <= 0),
dw AS (
    SELECT count(*) AS cargados FROM dw.fact_validaciones)
SELECT 'F1' AS fuente, f.leidos, d.cargados, f.duplicados + m.monto_no_valido AS descartados,
       f.duplicados, m.monto_no_valido,
       f.leidos = d.cargados + f.duplicados + m.monto_no_valido AS cuadra
FROM fuente f, monto m, dw d;

-- F2 · estaciones -> dw.dim_estacion (sin el miembro -1)
SELECT 'F2' AS fuente,
       (SELECT count(*) FROM conciliacion.f2_estaciones)                AS leidos,
       (SELECT count(*) FROM dw.dim_estacion WHERE sk_estacion > 0)     AS cargados,
       (SELECT count(*) FROM conciliacion.f2_estaciones)
     - (SELECT count(*) FROM dw.dim_estacion WHERE sk_estacion > 0)     AS descartados;

-- F3 · trazados -> atributos de trazado/troncal en dw.dim_estacion y dw.dim_ruta
SELECT 'F3' AS fuente,
       (SELECT count(*) FROM conciliacion.f3_trazados)                                AS leidos,
       (SELECT count(*) FROM conciliacion.f3_trazados t
         WHERE EXISTS (SELECT 1 FROM dw.dim_estacion e WHERE e.id_trazado = t.id_trazado)) AS cargados,
       (SELECT count(*) FROM conciliacion.f3_trazados t
         WHERE NOT EXISTS (SELECT 1 FROM dw.dim_estacion e WHERE e.id_trazado = t.id_trazado)) AS descartados,
       (SELECT string_agg(id_trazado, ', ' ORDER BY id_trazado) FROM conciliacion.f3_trazados t
         WHERE NOT EXISTS (SELECT 1 FROM dw.dim_estacion e WHERE e.id_trazado = t.id_trazado)) AS trazados_sin_estacion;

-- Detalle: registros cargados con llave «Desconocido» (-1)
SELECT 'sk_estacion = -1' AS caso, count(*) FROM dw.fact_validaciones WHERE sk_estacion = -1
UNION ALL SELECT 'sk_bus = -1', count(*) FROM dw.fact_validaciones WHERE sk_bus = -1
UNION ALL SELECT 'sk_ruta = -1', count(*) FROM dw.fact_validaciones WHERE sk_ruta = -1
UNION ALL SELECT 'sk_tarifa = -1', count(*) FROM dw.fact_validaciones WHERE sk_tarifa = -1;

-- Conteo de filas de cada tabla del DW (tabla 1.2)
SELECT 'dim_tiempo' AS tabla, count(*) FROM dw.dim_tiempo
UNION ALL SELECT 'dim_hora', count(*) FROM dw.dim_hora
UNION ALL SELECT 'dim_estacion', count(*) FROM dw.dim_estacion
UNION ALL SELECT 'dim_ruta', count(*) FROM dw.dim_ruta
UNION ALL SELECT 'dim_bus', count(*) FROM dw.dim_bus
UNION ALL SELECT 'dim_tarifa', count(*) FROM dw.dim_tarifa
UNION ALL SELECT 'fact_validaciones', count(*) FROM dw.fact_validaciones;
