SELECT CAST(to_char(d, 'YYYYMMDD') AS INTEGER)              AS sk_tiempo,
       CAST(d AS DATE)                                       AS fecha,
       CAST(EXTRACT(DAY FROM d) AS SMALLINT)                 AS dia,
       CAST(EXTRACT(ISODOW FROM d) AS SMALLINT)              AS dia_semana,
       (ARRAY['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'])[EXTRACT(ISODOW FROM d)] AS nombre_dia,
       EXTRACT(ISODOW FROM d) IN (6, 7)                      AS es_fin_semana,
       CAST(EXTRACT(WEEK FROM d) AS SMALLINT)                AS semana_iso,
       CAST(EXTRACT(MONTH FROM d) AS SMALLINT)               AS mes,
       (ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'])[EXTRACT(MONTH FROM d)] AS nombre_mes,
       to_char(d, 'YYYY-MM')                                 AS anio_mes,
       CAST(EXTRACT(QUARTER FROM d) AS SMALLINT)             AS trimestre,
       CAST(CASE WHEN EXTRACT(MONTH FROM d) <= 6 THEN 1 ELSE 2 END AS SMALLINT) AS semestre,
       CAST(EXTRACT(YEAR FROM d) AS SMALLINT)                AS anio
FROM generate_series(DATE '${FECHA_INICIO}', DATE '${FECHA_FIN}', INTERVAL '1 day') AS g(d)
ORDER BY 1
