-- =====================================================================
-- 04 · Cifras de control del tablero (mismo cálculo que las medidas DAX)
-- Sirve para verificar que lo que muestra Power BI coincide con el DW.
-- =====================================================================
SET search_path TO dw;

-- KPI 1 y 2: validaciones y recaudo por año (2025 frente a 2024)
SELECT t.anio, sum(f.cantidad_validaciones) AS validaciones, sum(f.monto_pagado) AS recaudo_cop
FROM fact_validaciones f JOIN dim_tiempo t USING (sk_tiempo)
GROUP BY t.anio ORDER BY t.anio;

-- KPI 3: % de validaciones en hora pico por año (meta: máximo 55 %)
SELECT t.anio, round(100.0 * avg(h.es_hora_pico::int), 1) AS pct_hora_pico
FROM fact_validaciones f JOIN dim_hora h USING (sk_hora) JOIN dim_tiempo t USING (sk_tiempo)
GROUP BY t.anio ORDER BY t.anio;

-- KPI 4: validaciones por bus en servicio, por ruta y promedio de la red
SELECT r.cod_ruta, r.nombre_troncal, count(*) AS validaciones,
       count(DISTINCT f.sk_bus) FILTER (WHERE f.sk_bus > 0) AS buses_en_servicio,
       round(count(*)::numeric / count(DISTINCT f.sk_bus) FILTER (WHERE f.sk_bus > 0), 1) AS validaciones_por_bus,
       sum(CASE WHEN h.es_hora_pico THEN 1 ELSE 0 END) AS validaciones_pico,
       sum(CASE WHEN h.es_hora_pico THEN 0 ELSE 1 END) AS validaciones_valle
FROM fact_validaciones f JOIN dim_ruta r USING (sk_ruta) JOIN dim_hora h USING (sk_hora)
GROUP BY r.cod_ruta, r.nombre_troncal ORDER BY validaciones_por_bus DESC;

SELECT round(count(*)::numeric / count(DISTINCT sk_bus) FILTER (WHERE sk_bus > 0), 1) AS validaciones_por_bus_red
FROM fact_validaciones;

-- P0: troncales, estaciones y franjas con mayor demanda y recaudo
SELECT e.nombre_troncal, count(*) AS validaciones, sum(f.monto_pagado) AS recaudo_cop,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct
FROM fact_validaciones f JOIN dim_estacion e USING (sk_estacion)
GROUP BY e.nombre_troncal ORDER BY validaciones DESC;

SELECT e.nombre_estacion, h.franja_horaria, count(*) AS validaciones
FROM fact_validaciones f JOIN dim_estacion e USING (sk_estacion) JOIN dim_hora h USING (sk_hora)
GROUP BY e.nombre_estacion, h.franja_horaria ORDER BY validaciones DESC LIMIT 10;

SELECT h.franja_horaria, count(*) AS validaciones, round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct
FROM fact_validaciones f JOIN dim_hora h USING (sk_hora)
GROUP BY h.franja_horaria, h.orden_franja ORDER BY h.orden_franja;

SELECT t.anio_mes, count(*) AS validaciones
FROM fact_validaciones f JOIN dim_tiempo t USING (sk_tiempo)
GROUP BY t.anio_mes ORDER BY t.anio_mes;

-- P1: promedio diario por tipo de tarifa (731 días) y estación
SELECT ta.tipo_tarifa, count(*) AS validaciones,
       round(count(*) / (SELECT count(*) FROM dim_tiempo)::numeric, 1) AS promedio_diario,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct
FROM fact_validaciones f JOIN dim_tarifa ta USING (sk_tarifa)
GROUP BY ta.tipo_tarifa ORDER BY validaciones DESC;

SELECT e.nombre_estacion, count(*) AS validaciones,
       round(count(*) / (SELECT count(*) FROM dim_tiempo)::numeric, 2) AS promedio_diario
FROM fact_validaciones f JOIN dim_estacion e USING (sk_estacion)
GROUP BY e.nombre_estacion ORDER BY validaciones DESC LIMIT 10;
