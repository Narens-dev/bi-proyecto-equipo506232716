# Campos calculados del tablero (Looker Studio)

Definidos en la fuente de datos PostgreSQL (`SELECT * FROM dw.v_tablero_validaciones`).

| Campo | Fórmula | Formato |
|---|---|---|
| Validaciones | `SUM(cantidad_validaciones)` | Número entero |
| Recaudo COP | `SUM(monto_pagado)` | Moneda COP sin decimales |
| Validaciones pico | `SUM(CASE WHEN es_hora_pico THEN cantidad_validaciones ELSE 0 END)` | Número entero |
| Validaciones valle | `SUM(CASE WHEN es_hora_pico THEN 0 ELSE cantidad_validaciones END)` | Número entero |
| % en hora pico | `SUM(CASE WHEN es_hora_pico THEN cantidad_validaciones ELSE 0 END) / SUM(cantidad_validaciones)` | Porcentaje, 1 decimal |
| Buses en servicio | `COUNT_DISTINCT(cod_bus)` | Número entero |
| Validaciones por bus | `SUM(cantidad_validaciones) / COUNT_DISTINCT(cod_bus)` | Número, 1 decimal |
| Promedio diario | `SUM(cantidad_validaciones) / COUNT_DISTINCT(fecha)` | Número, 2 decimales |

Las variaciones frente al año anterior (+6,8 % validaciones, +15,5 % recaudo, +7,1 % promedio diario) las calcula el cuadro de resultados con *Comparar con: año anterior* sobre el periodo 2025.
