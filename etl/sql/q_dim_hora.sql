SELECT CAST(m AS SMALLINT)                                   AS sk_hora,
       CAST(TIME '00:00' + m * INTERVAL '1 minute' AS TIME)  AS hora_minuto,
       CAST(m / 60 AS SMALLINT)                              AS hora,
       CAST(m % 60 AS SMALLINT)                              AS minuto,
       CASE WHEN m / 60 BETWEEN 0  AND 4  THEN 'Madrugada'
            WHEN m / 60 BETWEEN 5  AND 8  THEN 'Pico mañana'
            WHEN m / 60 BETWEEN 9  AND 11 THEN 'Valle mañana'
            WHEN m / 60 BETWEEN 12 AND 15 THEN 'Mediodía'
            WHEN m / 60 BETWEEN 16 AND 19 THEN 'Pico tarde'
            ELSE 'Noche' END                                 AS franja_horaria,
       CAST(CASE WHEN m / 60 BETWEEN 0  AND 4  THEN 1
                 WHEN m / 60 BETWEEN 5  AND 8  THEN 2
                 WHEN m / 60 BETWEEN 9  AND 11 THEN 3
                 WHEN m / 60 BETWEEN 12 AND 15 THEN 4
                 WHEN m / 60 BETWEEN 16 AND 19 THEN 5
                 ELSE 6 END AS SMALLINT)                     AS orden_franja,
       (m / 60 BETWEEN 5 AND 8 OR m / 60 BETWEEN 16 AND 19)  AS es_hora_pico
FROM generate_series(0, 1439) AS g(m)
ORDER BY 1
