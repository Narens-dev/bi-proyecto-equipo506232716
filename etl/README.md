# ETL — Pentaho Data Integration

Carga completa del data warehouse `movibogota_dw` (esquema `dw`) desde las tres fuentes originales, con un solo trabajo de PDI.

## Motor y versiones

| Componente | Versión probada / requerida |
|---|---|
| Base de datos | PostgreSQL 16 (funciona con 13 o superior) |
| ETL | Pentaho Data Integration (Spoon) 9.4 CE o 10.x Developer Edition |
| Java | 11 para PDI 9.4 · 17 para PDI 10.x |
| Driver JDBC | `postgresql-42.x.jar` (PDI ya lo incluye en `data-integration/lib`) |

## Parámetros de conexión (sin contraseñas)

Todas las transformaciones y el trabajo usan la conexión **`dw_movibogota`** (tipo PostgreSQL, acceso Native/JDBC), definida con variables:

| Variable | Valor usado | Dónde se define |
|---|---|---|
| `DW_HOST` | `localhost` | `kettle.properties` |
| `DW_PORT` | `5432` | `kettle.properties` |
| `DW_DB` | `movibogota_dw` | `kettle.properties` |
| `DW_USER` | `postgres` | `kettle.properties` |
| `DW_PASSWORD` | *(local de cada integrante, nunca en el repositorio)* | `kettle.properties` |

Copie el contenido de [`kettle.properties.ejemplo`](kettle.properties.ejemplo) en `%USERPROFILE%\.kettle\kettle.properties`, ponga su contraseña y reinicie Spoon. La carpeta `.kettle/` está en `.gitignore`.

## Ubicación esperada de las fuentes

Las rutas son **relativas al archivo** (`${Internal.Entry.Current.Directory}`), así que basta con clonar el repositorio completo; no hay rutas absolutas.

| Fuente | Archivo | Paso de PDI que la lee |
|---|---|---|
| F1 · Validaciones (CSV) | `datos/raw/Dataset_registros.csv` | `F1 CSV validaciones` (CSV file input) |
| F2 · Estaciones troncales (CSV) | `datos/raw/Estaciones_Troncales_de_TRANSMILENIO.csv` | `F2 CSV estaciones` (CSV file input) |
| F3 · Trazados troncales (GeoJSON) | `datos/raw/Trazados_Troncales_de_TRANSMILENIO.geojson` | `F3 JSON trazados` (JSON input) |

Los registros descartados se escriben en `etl/rechazos/` (`rechazos_duplicados.csv`, `rechazos_monto_invalido.csv`).

## Orden de ejecución

Se ejecuta **solo** `etl/trabajos/j_carga_dw.kjb`. El trabajo corre, en este orden:

| # | Entrada del trabajo | Qué hace |
|---|---|---|
| 1 | `reiniciar_dw` (SQL) | Ejecuta `dw/ddl/09_reiniciar_carga.sql`: vacía las tablas y crea los miembros «Desconocido» (llave −1) |
| 2 | `t_dim_tiempo.ktr` | 731 días (01/01/2024–31/12/2025) |
| 3 | `t_dim_hora.ktr` | 1.440 minutos del día con franja horaria |
| 4 | `t_dim_estacion.ktr` | F2 + F3 (lookup por `id_trazado`) |
| 5 | `t_dim_ruta.ktr` | F1 + F3 (lookup por letra de troncal) |
| 6 | `t_dim_bus.ktr` | F1 |
| 7 | `t_dim_tarifa.ktr` | F1 |
| 8 | `t_fact_validaciones.ktr` | F1 con reglas de limpieza y búsqueda de llaves en las 6 dimensiones |

Las dimensiones siempre se cargan antes que los hechos.

## Cómo reproducir desde cero

1. Crear la base y las tablas (una sola vez), desde la raíz del repositorio:
   ```bash
   psql -h localhost -U postgres -f dw/ddl/00_crear_base_y_esquema.sql
   psql -h localhost -U postgres -d movibogota_dw -f dw/ddl/01_esquema_dw.sql -f dw/ddl/02_dim_tiempo.sql -f dw/ddl/03_dim_hora.sql -f dw/ddl/04_dim_estacion.sql -f dw/ddl/05_dim_ruta.sql -f dw/ddl/06_dim_bus.sql -f dw/ddl/07_dim_tarifa.sql -f dw/ddl/08_fact_validaciones.sql
   ```
   (En pgAdmin o DBeaver se pueden abrir y ejecutar los mismos archivos en ese orden.)
2. Configurar `kettle.properties` (sección anterior).
3. Abrir Spoon → *File › Open* → `etl/trabajos/j_carga_dw.kjb` → *Run* (F9) → *Run*.
   Por consola: `kitchen.bat /file:"<repo>\etl\trabajos\j_carga_dw.kjb" /level:Basic` (Windows) o `./kitchen.sh -file=<repo>/etl/trabajos/j_carga_dw.kjb`.
4. Verificar con las consultas de `dw/conciliacion/` (ver su encabezado).

El trabajo es re-ejecutable: cada corrida vacía el DW y lo vuelve a cargar.

## Resultado esperado de la carga

| Transformación | Leídos | Escritos | Rechazos |
|---|---|---|---|
| t_dim_tiempo | 731 | 731 | 0 |
| t_dim_hora | 1.440 | 1.440 | 0 |
| t_dim_estacion | 153 (F2) + 22 (F3) | 153 | 0 |
| t_dim_ruta | 55.000 (F1) + 22 (F3) | 7 | 0 |
| t_dim_bus | 55.000 | 450 | 0 |
| t_dim_tarifa | 55.000 | 15 | 0 |
| t_fact_validaciones | 55.000 | 54.775 | 225 (180 duplicados + 45 montos ≤ 0) |

## Despliegue de las predicciones (Entrega 3)

Trabajo aparte, `etl/trabajos/j_despliegue_predicciones.kjb`. **Se ejecuta después de `j_carga_dw.kjb` y después de correr el notebook** (que genera `modelo/predicciones.csv`).

| # | Entrada del trabajo | Qué hace |
|---|---|---|
| 1 | `crear_tabla_pred` (SQL) | Ejecuta `dw/ddl/10_pred_validaciones_estacion_mes.sql`: extiende `dim_tiempo` a ene–mar 2026, crea `dw.pred_validaciones_estacion_mes` si no existe y la vista `dw.v_tablero_predicciones` |
| 2 | `t_pred_validaciones.ktr` | Lee `modelo/predicciones.csv` (636 filas), vacía la tabla y la recarga con las llaves `sk_estacion` y `sk_tiempo` |

Por consola: `kitchen.bat /file:"<repo>\etl\trabajos\j_despliegue_predicciones.kjb" /level:Basic` (Windows) o `./kitchen.sh -file=<repo>/etl/trabajos/j_despliegue_predicciones.kjb`.

Por qué se usa Pentaho además del notebook: el notebook también escribe la tabla (con SQLAlchemy), pero en Google Colab no llega a un PostgreSQL local. Con el CSV como punto de entrega, el modelo se corre en cualquier entorno y el despliegue en el DW queda en el mismo ETL del resto de la carga.

**Importante:** `j_carga_dw.kjb` ejecuta `TRUNCATE … CASCADE` (script 09), que también vacía `pred_validaciones_estacion_mes` y elimina de `dim_tiempo` los meses de 2026. Si se recarga el DW, hay que volver a ejecutar `j_despliegue_predicciones.kjb`. Las llaves `sk_estacion` se regeneran en el mismo orden en cada carga, así que el CSV sigue siendo válido mientras no cambien las fuentes; si cambian, vuelva a correr el notebook.

Resultado esperado: `t_pred_validaciones` lee 636 y escribe 636 filas (318 de prueba y 318 de pronóstico).
