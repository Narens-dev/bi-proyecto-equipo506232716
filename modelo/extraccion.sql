-- Entrega 3 · Extracción del conjunto de datos para el modelo predictivo (pregunta P3)
-- Una fila por estación y mes: 106 estaciones con demanda × 24 meses de 2024–2025 = 2.544 filas.
-- Une fact_validaciones con dim_tiempo (mes del hecho) y dim_estacion (atributos de la estación).
-- La malla estación × mes se arma con CROSS JOIN para que los meses sin validaciones queden con 0.
-- Filtra: (1) la estación desconocida (sk_estacion = −1), que no tiene atributos para el modelo, y
--         (2) las 47 estaciones sin ninguna validación en 2024–2025 (troncales que no cubren las 7 rutas
--         de MoviBogotá): su demanda es siempre 0 y solo inflarían los aciertos del modelo.

WITH meses AS (
    SELECT anio, mes,
           MIN(sk_tiempo)                                  AS sk_tiempo_mes,   -- primer día del mes
           COUNT(*)                                        AS dias_mes,
           COUNT(*) FILTER (WHERE NOT es_fin_semana)       AS dias_habiles
    FROM dw.dim_tiempo
    WHERE sk_tiempo > 0
      AND sk_tiempo <= (SELECT MAX(sk_tiempo) FROM dw.fact_validaciones)   -- sin los meses del horizonte
    GROUP BY anio, mes
),
hechos AS (
    SELECT f.sk_estacion, t.anio, t.mes,
           SUM(f.cantidad_validaciones)                                        AS validaciones,
           SUM(f.cantidad_validaciones) FILTER (WHERE h.es_hora_pico)          AS validaciones_pico
    FROM dw.fact_validaciones f
    JOIN dw.dim_tiempo t ON t.sk_tiempo = f.sk_tiempo
    JOIN dw.dim_hora   h ON h.sk_hora   = f.sk_hora
    WHERE f.sk_estacion > 0
    GROUP BY f.sk_estacion, t.anio, t.mes
)
SELECT e.sk_estacion,
       m.sk_tiempo_mes                         AS sk_tiempo,
       e.cod_estacion,
       e.nombre_estacion,
       e.nombre_troncal,
       e.tipo_estacion,
       e.num_vagones,
       e.num_accesos,
       e.area_m2,
       m.anio,
       m.mes,
       m.dias_mes,
       m.dias_habiles,
       COALESCE(hc.validaciones, 0)            AS validaciones,
       COALESCE(hc.validaciones_pico, 0)       AS validaciones_pico
FROM dw.dim_estacion e
CROSS JOIN meses m
LEFT JOIN hechos hc
       ON hc.sk_estacion = e.sk_estacion AND hc.anio = m.anio AND hc.mes = m.mes
WHERE e.sk_estacion > 0
  AND e.sk_estacion IN (SELECT sk_estacion FROM hechos)
ORDER BY e.sk_estacion, m.anio, m.mes;
