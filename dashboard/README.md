# Tablero — Power BI Desktop

Archivo: `tablero_movibogota.pbix` · Capturas: `captura_p1_demanda.png`, `captura_p2_tarifas.png`, `captura_p3_rutas_flota.png`.

## 1. Conexión al data warehouse (no a los archivos de las fuentes)

1. *Inicio › Obtener datos › Base de datos PostgreSQL*. Servidor `localhost:5432`, base `movibogota_dw`, modo **Importar**.
2. Credenciales: *Base de datos*, usuario `postgres` y su contraseña local (Power BI la guarda en su equipo, no en el .pbix).
3. Seleccionar **solo** las tablas del esquema `dw`: `dim_tiempo`, `dim_hora`, `dim_estacion`, `dim_ruta`, `dim_bus`, `dim_tarifa`, `fact_validaciones`. Renombrarlas quitando el prefijo `dw `.
4. *Vista de modelo*: comprobar las 6 relaciones 1:* desde cada `sk_*` de la dimensión a `fact_validaciones` (dirección de filtro única). Crear las que falten arrastrando la columna.
5. Seleccionar `dim_tiempo` › *Herramientas de tabla › Marcar como tabla de fechas* › columna `fecha`.
6. Ordenar columnas: `nombre_mes` por `mes`, `nombre_dia` por `dia_semana`, `franja_horaria` por `orden_franja`.
7. Crear las medidas de [`medidas_dax.md`](medidas_dax.md) y darles formato (número entero con separador de miles; recaudo como moneda COP sin decimales; porcentajes con 1 decimal).

## 2. Páginas y visuales

En las tres páginas: segmentadores (todos con interacción de filtro sobre todos los visuales de la página) **Año** (`dim_tiempo[anio]`, sin selección por defecto = 2024 y 2025), **Mes** (`dim_tiempo[nombre_mes]`) y **Troncal** (`dim_estacion[nombre_troncal]`; en la página 3 usar `dim_ruta[nombre_troncal]`). Por defecto filtran todos los visuales de su página.

### Página 1 · «Demanda por estación y franja» (P0)
| Visual | Tipo | Campos | Título |
|---|---|---|---|
| Tarjeta KPI | Tarjeta (nueva) o KPI | `[Validaciones último año]` con referencia `[Validaciones año anterior]` y `[Var % validaciones]` | Validaciones del último año vs. año anterior |
| Tarjeta KPI | Tarjeta (nueva) o KPI | `[Recaudo último año]` vs `[Recaudo año anterior]` y `[Var % recaudo]` | Recaudo (COP) del último año vs. año anterior |
| Barras horizontales | Gráfico de barras agrupadas, orden descendente | Eje Y `dim_estacion[nombre_troncal]`, X `[Validaciones]` | Validaciones por troncal (n.º de validaciones) |
| Matriz con escala de color | Matriz + formato condicional (color de fondo) | Filas `dim_estacion[nombre_estacion]` (Top 10 por `[Validaciones]`), columnas `dim_hora[franja_horaria]`, valores `[Validaciones]` | Top 10 estaciones por franja horaria (validaciones) |
| Líneas | Gráfico de líneas | Eje X `dim_tiempo[anio_mes]`, Y `[Validaciones]`, leyenda `dim_tiempo[anio]` | Validaciones por mes, 2024–2025 |

### Página 2 · «Volumen diario por tarifa y estación» (P1)
| Visual | Tipo | Campos | Título |
|---|---|---|---|
| Tarjeta | Tarjeta | `[Promedio diario]` | Promedio diario de validaciones (validaciones/día) |
| Barras horizontales | Barras agrupadas | Eje Y `dim_tarifa[tipo_tarifa]`, X `[Promedio diario]` | Promedio diario de validaciones por tipo de tarifa (validaciones/día) |
| Matriz | Matriz | Filas `dim_estacion[nombre_estacion]`, columnas `dim_tarifa[tipo_tarifa]`, valores `[Validaciones]` | Validaciones por estación y tipo de tarifa |
| Columnas apiladas 100 % | Columnas apiladas 100 % | Eje X `dim_tiempo[anio_mes]`, leyenda `dim_tarifa[grupo_tarifa]`, Y `[Validaciones]` | Participación tarifa plena vs. subsidiada por mes (%) |

### Página 3 · «Rutas y flota: pico vs. valle» (P2)
| Visual | Tipo | Campos | Título |
|---|---|---|---|
| Tarjeta KPI | KPI / medidor | `[% en hora pico]` frente a `[Meta % hora pico]` | % de validaciones en hora pico vs. meta 55 % |
| Tarjeta KPI | Tarjeta | `[Validaciones por bus]` vs `[Validaciones por bus (promedio red)]` | Validaciones por bus vs. promedio de la red |
| Barras agrupadas | Barras horizontales agrupadas | Eje Y `dim_ruta[cod_ruta]`, X `[Validaciones pico]` y `[Validaciones valle]` | Validaciones por ruta en hora pico y valle |
| Barras + línea de referencia | Barras horizontales, ordenadas desc. + *Análisis › Línea constante* = `[Validaciones por bus (promedio red)]` | Eje Y `dim_ruta[cod_ruta]`, X `[Validaciones por bus]` | Validaciones por bus en servicio, por ruta (validaciones/bus) |
| Columnas | Gráfico de columnas | Eje X `dim_hora[hora]` (0–23), Y `[Validaciones]` | Validaciones por hora del día (n.º de validaciones) |

## 3. Reglas de presentación (rúbrica T6–T8)
- Cada visual con título que diga qué muestra; ejes con nombre y unidad («n.º de validaciones», «COP», «%»).
- Sin gráficos 3D, sin tortas de muchas categorías, sin imágenes decorativas.
- Tendencias en línea; comparaciones entre categorías en barras ordenadas.

## 4. Capturas
*Archivo › Exportar › PDF* o recorte de pantalla de cada página a 100 % de zoom; guardar como PNG en esta carpeta con los nombres de arriba.
