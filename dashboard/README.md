# Tablero — Looker Studio

Reporte: **MoviBogotá S.A. - Tablero de demanda (DW movibogota_dw)**
<https://datastudio.google.com/reporting/ff362d1b-b283-4d16-969c-23989bdc0614> (pedir acceso al equipo si no abre).

Capturas: `pagina1_demanda.png`, `pagina2_tarifas.png`, `pagina3_rutas_flota.png`.

## 1. Conexión al data warehouse (no a los archivos de las fuentes)

El tablero lee una copia del DW `movibogota_dw` publicada en PostgreSQL (Supabase, proyecto `movibogota-dw`), con el mismo esquema `dw` que crean los scripts de `/dw/ddl` y la misma carga que hace el ETL de `/etl`.

1. En Looker Studio: *Añadir datos › PostgreSQL*.
2. Host `aws-0-us-east-1.pooler.supabase.com`, puerto `5432`, base `postgres`, usuario de solo lectura `tablero_lectura.pspgdsiwhuwbxtnkteff` (la contraseña no está en el repositorio).
3. *Consulta personalizada*: `SELECT * FROM dw.v_tablero_validaciones;`

`dw.v_tablero_validaciones` une `fact_validaciones` con sus 6 dimensiones (una fila por validación, 54.775 filas). El tablero no lee los CSV/GeoJSON de `/datos`.

## 2. Campos calculados

Ver [`medidas_looker.md`](medidas_looker.md).

## 3. Páginas y visuales

Controles en las tres páginas: **intervalo de fechas** (sobre `fecha`) y **lista desplegable de troncal** (`troncal_estacion` en las páginas 1 y 2; `troncal_ruta` en la página 3). Por defecto filtran todos los visuales de su página.

### Página 1 · Demanda por estación y franja (P0)
| Visual | Tipo | Campos |
|---|---|---|
| Validaciones 2025 vs. 2024 | Cuadro de resultados con comparación con el año anterior | `Validaciones` (periodo 2025) |
| Recaudo (COP) 2025 vs. 2024 | Cuadro de resultados con comparación | `Recaudo COP` |
| Validaciones por troncal | Barras horizontales | `troncal_estacion` × `Validaciones` |
| Estaciones con más demanda por franja horaria | Tabla dinámica con mapa de calor | filas `nombre_estacion`, columnas `franja_horaria`, `Validaciones` |
| Validaciones por mes, 2024–2025 | Serie temporal | `fecha` (año-mes) × `Validaciones` |

### Página 2 · Volumen diario por tarifa y estación (P1)
| Visual | Tipo | Campos |
|---|---|---|
| Promedio diario de validaciones 2025 vs. 2024 | Cuadro de resultados con comparación | `Promedio diario` |
| Promedio diario por tipo de tarifa | Barras horizontales | `tipo_tarifa` × `Promedio diario` |
| Validaciones por estación y tipo de tarifa | Tabla dinámica con mapa de calor | filas `nombre_estacion`, columnas `tipo_tarifa`, `Validaciones` |
| Validaciones por mes, tarifa plena vs. subsidiada | Serie temporal con desglose | `fecha` × `Validaciones`, desglose `grupo_tarifa` |

### Página 3 · Rutas y flota: pico vs. valle (P2)
| Visual | Tipo | Campos |
|---|---|---|
| % de validaciones en hora pico vs. meta 55 % | Gráfico de viñetas (objetivo 0,55) | `% en hora pico` |
| Validaciones por bus en servicio 2025 vs. 2024 | Cuadro de resultados con comparación | `Validaciones por bus` |
| Validaciones por ruta en hora pico y valle | Barras agrupadas | `cod_ruta` × `Validaciones pico`, `Validaciones valle` |
| Validaciones por bus en servicio, por ruta | Barras con línea de referencia constante 121,7 («Promedio de la red») | `cod_ruta` × `Validaciones por bus` |
| Validaciones por hora del día, 0 a 23 h | Columnas (24 barras, orden por `hora` ascendente) | `hora` × `Validaciones` |

## 4. Verificación de cifras

`/dw/conciliacion/04_cifras_tablero.sql` reproduce en SQL las cifras de las tres páginas (por ejemplo 28.291 validaciones y $85.264.100 en 2025; 56,6 % en hora pico; 121,7 validaciones por bus).
