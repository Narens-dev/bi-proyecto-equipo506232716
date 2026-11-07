# Medidas DAX del tablero

Crear una tabla vacía `_Medidas` (*Inicio › Especificar datos › Cargar*) y añadir estas medidas. Los nombres de tabla son los que Power BI asigna al importar desde PostgreSQL (`dw fact_validaciones`, etc.); si los renombró (recomendado: quitar el prefijo `dw `), ajuste las referencias.

```dax
Validaciones = SUM ( fact_validaciones[cantidad_validaciones] )

-- Año de referencia = último año visible en el filtro (sin filtro: 2025)
Validaciones último año =
CALCULATE ( [Validaciones], dim_tiempo[anio] = MAX ( dim_tiempo[anio] ) )

Validaciones año anterior =
CALCULATE ( [Validaciones], dim_tiempo[anio] = MAX ( dim_tiempo[anio] ) - 1 )

Var % validaciones =
DIVIDE ( [Validaciones último año] - [Validaciones año anterior], [Validaciones año anterior] )

Recaudo COP = SUM ( fact_validaciones[monto_pagado] )

Recaudo último año =
CALCULATE ( [Recaudo COP], dim_tiempo[anio] = MAX ( dim_tiempo[anio] ) )

Recaudo año anterior =
CALCULATE ( [Recaudo COP], dim_tiempo[anio] = MAX ( dim_tiempo[anio] ) - 1 )

Var % recaudo =
DIVIDE ( [Recaudo último año] - [Recaudo año anterior], [Recaudo año anterior] )

% en hora pico =
DIVIDE (
    CALCULATE ( [Validaciones], dim_hora[es_hora_pico] = TRUE () ),
    [Validaciones]
)

Meta % hora pico = 0.55

Buses en servicio =
CALCULATE ( DISTINCTCOUNT ( fact_validaciones[sk_bus] ), fact_validaciones[sk_bus] > 0 )

Validaciones por bus = DIVIDE ( [Validaciones], [Buses en servicio] )

Validaciones por bus (promedio red) =
CALCULATE ( [Validaciones por bus], ALL ( dim_ruta ) )

Promedio diario = DIVIDE ( [Validaciones], COUNTROWS ( dim_tiempo ) )

Validaciones pico = CALCULATE ( [Validaciones], dim_hora[es_hora_pico] = TRUE () )
Validaciones valle = CALCULATE ( [Validaciones], dim_hora[es_hora_pico] = FALSE () )
```

Equivalente SQL de los indicadores (para verificar las cifras): ver `dw/conciliacion/04_cifras_tablero.sql`.

Valores de control sin filtros (deben coincidir con el tablero): Validaciones 54.775 · Validaciones último año 28.291 · año anterior 26.484 · Var % +6,8 % · Recaudo último año $85.264.100 · año anterior $73.790.200 · Var % +15,5 % · % en hora pico 56,6 % · Validaciones por bus 121,7 · Promedio diario 74,9.
