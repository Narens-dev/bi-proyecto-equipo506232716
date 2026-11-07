-- =====================================================================
-- Conciliación · 03 · Total de métricas fuente vs. DW (tabla 3.2)
-- =====================================================================
WITH f AS (SELECT * FROM conciliacion.f1_validaciones),
rn AS (SELECT *, row_number() OVER (PARTITION BY id_validacion ORDER BY ctid) AS n
           FROM conciliacion.f1_validaciones)   -- los duplicados son copias exactas
SELECT 'monto_pagado (COP)'                                              AS metrica,
       (SELECT sum(monto_pagado::numeric) FROM f)                        AS total_fuente,
       (SELECT sum(monto_pagado) FROM dw.fact_validaciones)              AS total_dw,
       (SELECT sum(monto_pagado::numeric) FROM f)
     - (SELECT sum(monto_pagado) FROM dw.fact_validaciones)              AS diferencia,
       (SELECT sum(monto_pagado::numeric) FROM rn WHERE n > 1)           AS monto_duplicados,
       (SELECT sum(monto_pagado::numeric) FROM rn WHERE n = 1 AND monto_pagado::numeric <= 0) AS monto_no_valido
UNION ALL
SELECT 'cantidad_validaciones',
       (SELECT count(*) FROM f),
       (SELECT sum(cantidad_validaciones) FROM dw.fact_validaciones),
       (SELECT count(*) FROM f) - (SELECT sum(cantidad_validaciones) FROM dw.fact_validaciones),
       (SELECT count(*) FROM rn WHERE n > 1),
       (SELECT count(*) FROM rn WHERE n = 1 AND monto_pagado::numeric <= 0);

-- Control por año: el total debe coincidir también por periodo
SELECT t.anio, count(*) AS validaciones, sum(f.monto_pagado) AS recaudo
FROM dw.fact_validaciones f JOIN dw.dim_tiempo t USING (sk_tiempo)
GROUP BY t.anio ORDER BY t.anio;

-- Dimensión de tiempo sin huecos: días esperados vs. días cargados entre la primera y la última validación
SELECT min(fecha) AS desde, max(fecha) AS hasta,
       (max(fecha) - min(fecha) + 1) AS dias_esperados, count(*) AS dias_en_dim_tiempo,
       (SELECT count(DISTINCT sk_tiempo) FROM dw.fact_validaciones) AS dias_con_validaciones
FROM dw.dim_tiempo;
