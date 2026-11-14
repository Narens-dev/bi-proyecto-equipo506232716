# Power BI · conexión, modelo y medidas de la página «Predicciones» (Entrega 3)

Archivo: `dashboard/MoviBogota_Tablero.pbix` · Captura: `dashboard/pagina4_predicciones_powerbi.png`.
Las páginas 1–3 (Entrega 2) siguen documentadas en `README.md` y `medidas_looker.md`.

## 1. Conexión (Obtener datos › Base de datos PostgreSQL)

| Campo | Valor |
|---|---|
| Servidor | `localhost:5432` (o el host del DW) |
| Base de datos | `movibogota_dw` |
| Modo | **Importar** (el `.pbix` guarda los datos y se abre sin acceso al DW) |
| Credenciales | Base de datos › usuario/contraseña propios. **No se guardan en el repositorio.** |

Requiere el conector Npgsql (Power BI Desktop lo pide la primera vez; instalar y reiniciar).

Tablas a importar (esquema `dw`): `pred_validaciones_estacion_mes`, `dim_estacion`, `dim_tiempo`.
Consulta M equivalente (Editor de Power Query › Editor avanzado), una por tabla:

```m
let
    Origen = PostgreSQL.Database("localhost:5432", "movibogota_dw"),
    pred   = Origen{[Schema = "dw", Item = "pred_validaciones_estacion_mes"]}[Data]
in
    pred
```

Cambie `Item` por `dim_estacion` y `dim_tiempo` para las otras dos. Tipos: `validaciones_predichas` y `error_absoluto` → *Número decimal fijo*; `validaciones_reales` → *Número entero*.

## 2. Relaciones (Vista de modelo)

| Desde (muchos) | Hacia (uno) | Cardinalidad | Dirección |
|---|---|---|---|
| `pred_validaciones_estacion_mes[sk_estacion]` | `dim_estacion[sk_estacion]` | Varios a uno | Única |
| `pred_validaciones_estacion_mes[sk_tiempo]` | `dim_tiempo[sk_tiempo]` | Varios a uno | Única |

Estas dos relaciones son la evidencia de que la tabla `pred_*` se une a las dimensiones (indicador DE1).
En `dim_tiempo`, ordene `nombre_mes` por `mes` y marque `anio_mes` como texto (ordena bien: `2025-10`, `2025-11`…).

## 3. Medidas DAX (tabla `pred_validaciones_estacion_mes`)

Cree una tabla de medidas o póngalas en `pred_validaciones_estacion_mes`.

```dax
Validaciones reales = SUM ( pred_validaciones_estacion_mes[validaciones_reales] )

Validaciones predichas = SUM ( pred_validaciones_estacion_mes[validaciones_predichas] )

-- Solo meses con valor real (periodo de prueba oct-dic 2025)
MAE =
CALCULATE (
    AVERAGE ( pred_validaciones_estacion_mes[error_absoluto] ),
    pred_validaciones_estacion_mes[tipo_registro] = "prueba"
)

RMSE =
SQRT (
    AVERAGEX (
        FILTER ( pred_validaciones_estacion_mes, pred_validaciones_estacion_mes[tipo_registro] = "prueba" ),
        ( pred_validaciones_estacion_mes[validaciones_reales]
          - pred_validaciones_estacion_mes[validaciones_predichas] ) ^ 2
    )
)

Meta MAE = 5

¿Cumple la meta? = IF ( [MAE] < [Meta MAE], "Sí", "No" )

Pronóstico ene-mar 2026 =
CALCULATE (
    [Validaciones predichas],
    pred_validaciones_estacion_mes[tipo_registro] = "pronostico"
)

Sesgo del total (prueba) % =
VAR p = CALCULATE ( [Validaciones predichas], pred_validaciones_estacion_mes[tipo_registro] = "prueba" )
VAR r = CALCULATE ( [Validaciones reales],    pred_validaciones_estacion_mes[tipo_registro] = "prueba" )
RETURN DIVIDE ( p - r, r )

-- Reparto de los 450 buses en proporción a la demanda pronosticada (sección 5.5 de la entrega)
Buses sugeridos =
ROUND (
    450 * DIVIDE ( [Pronóstico ene-mar 2026],
                   CALCULATE ( [Pronóstico ene-mar 2026], ALL ( dim_estacion ) ) ),
    0
)
```

Verificación: con el filtro `Periodo = prueba`, `MAE` debe dar **4,29** y `RMSE` **5,90**; el total de `Pronóstico ene-mar 2026` debe dar **6.894**; `Buses sugeridos` para *Autopista Norte* debe dar **83**. Si no coinciden, la tabla no se cargó completa (636 filas).

Columna calculada opcional en `pred_validaciones_estacion_mes` para un filtro legible:

```dax
Periodo = IF ( pred_validaciones_estacion_mes[tipo_registro] = "prueba", "Prueba oct–dic 2025", "Pronóstico ene–mar 2026" )
```

## 4. Diseño de la página 4 «Predicciones de validaciones por estación y mes»

Nombre de la página (pestaña) y título de texto arriba: **«Validaciones reales vs. predichas por estación y mes (prueba oct–dic 2025 y pronóstico ene–mar 2026)»** (indicador DE3: el título dice qué muestra).

| Zona | Visual | Campos |
|---|---|---|
| Izquierda | 3 segmentaciones (*slicers*, lista desplegable) | `dim_estacion[nombre_troncal]`, `Periodo`, `dim_estacion[nombre_estacion]` (opcional `tipo_estacion`) |
| Fila de tarjetas | 4 tarjetas | `MAE` (formato 0,00), `RMSE`, `¿Cumple la meta?`, `Pronóstico ene-mar 2026` |
| Centro | Gráfico de líneas (reales vs. predichas) | Eje X `dim_tiempo[anio_mes]`; Valores `Validaciones reales`, `Validaciones predichas` |
| Abajo izquierda | Tabla (detalle) | `nombre_estacion`, `anio_mes`, `Validaciones reales`, `Validaciones predichas`, `error_absoluto` |
| Abajo derecha | Barras por troncal | Eje `nombre_troncal`; Valores `Pronóstico ene-mar 2026`, `Buses sugeridos` |

Con la segmentación de `Periodo` en «Prueba», la línea de reales y predichas se superpone mes a mes; en «Pronóstico», solo hay predichas (el real aún no existe). Esto cubre el indicador DE2 (predicciones junto a los valores reales).

Cuando actualice los datos: *Inicio › Actualizar*.

## 5. (Opcional) Páginas 1–3 en Power BI

Importe la vista `dw.v_tablero_validaciones` y use estas medidas, equivalentes a `medidas_looker.md`:

```dax
Validaciones = SUM ( v_tablero_validaciones[cantidad_validaciones] )
Recaudo COP  = SUM ( v_tablero_validaciones[monto_pagado] )
Validaciones pico  = CALCULATE ( [Validaciones], v_tablero_validaciones[es_hora_pico] = TRUE () )
Validaciones valle = CALCULATE ( [Validaciones], v_tablero_validaciones[es_hora_pico] = FALSE () )
% en hora pico = DIVIDE ( [Validaciones pico], [Validaciones] )
Buses en servicio = DISTINCTCOUNT ( v_tablero_validaciones[cod_bus] )
Validaciones por bus = DIVIDE ( [Validaciones], [Buses en servicio] )
Promedio diario = DIVIDE ( [Validaciones], DISTINCTCOUNT ( v_tablero_validaciones[fecha] ) )
```
