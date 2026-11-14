# Proyecto de Business Intelligence - MoviBogotá S.A.

## Descripción del caso

MoviBogotá S.A. es un operador privado de transporte masivo urbano en Bogotá, con una flota de 450 buses troncales que opera 7 rutas sobre 7 corredores troncales (Caracas, Autopista Norte, Américas, NQS Sur, Caracas Sur, Calle 26 y Carrera 10). Actualmente, la organización padece una arquitectura accidental debido a la fragmentación de sus datos operativos (silos de datos en archivos planos, telemetría GPS e informes manuales de mantenimiento en Excel). Esto impide que la Gerencia de Operaciones y Planeación del Servicio tome decisiones oportunas para responder a la pregunta crítica del negocio:

> ¿Cómo programar y redistribuir de forma dinámica la flota de buses y las frecuencias de despacho por ruta e intervalos por horas, minimizando los costos de distancia recorrida en vacío y los tiempos de espera de los usuarios en estaciones de alta demanda?

Documentos de las entregas:
- Entrega 1 (diagnóstico y diseño): [`docs/entregas/BI-Entrega-1-Equipo506232716.pdf`](docs/entregas/BI-Entrega-1-Equipo506232716.pdf)
- Entrega 2 (data warehouse, ETL y tablero): [`docs/entregas/BI-Entrega-2-Equipo506232716.pdf`](docs/entregas/BI-Entrega-2-Equipo506232716.pdf)

## Preguntas de negocio (ajustadas en la Entrega 2 a los datos disponibles)

| # | Pregunta | Tipo |
|---|---|---|
| P0 | ¿Qué troncales, estaciones y franjas horarias concentran la mayor demanda de validaciones y recaudo, por mes, en 2024–2025? | BI |
| P1 | ¿Cuál es el volumen diario de validaciones por tipo de tarifa y estación? | BI |
| P2 | ¿Qué rutas tienen más demanda en hora pico frente a valle y cuántas validaciones atiende cada bus asignado? | BI |
| P3 | ¿Cuántas validaciones se esperan por estación en cada mes del próximo trimestre? | BA (Entrega 3: modelo predictivo) |

## Integrantes

| Integrante | Código |
|---|---|
| David Santiago Prieto Beltrán | 506212024 |
| Naren Santiago Rojas Sánchez | 506232716 |
| Joseph David Vargas Olaya | 506232072 |

Docente: Leandro Pájaro Fuentes

## Herramientas

| Capa | Herramienta |
|---|---|
| Fuentes de datos | F1 validaciones (CSV, sintético) · F2 Estaciones Troncales de TRANSMILENIO (CSV) · F3 Trazados Troncales de TRANSMILENIO (GeoJSON) |
| Integración (ETL) | Pentaho Data Integration 9.4 / 10.x (7 `.ktr` y 1 `.kjb`) |
| Almacén de datos | PostgreSQL 16, base `movibogota_dw`, esquema `dw` (modelo en estrella: 6 dimensiones + 1 tabla de hechos) |
| Usuario final | Microsoft Power BI Desktop (`dashboard/MoviBogota_Tablero.pbix`, conectado a PostgreSQL) · páginas 1–3 de la Entrega 2 también en Looker Studio |
| Modelo predictivo | Python (notebooks) |
| Gobierno y versionamiento | GitHub, draw.io |

## Estructura del repositorio

```
├── README.md            caso, integrantes, herramientas y cómo reproducir
├── .gitignore
├── docs/
│   ├── entregas/        PDF de cada entrega (E1, E2, E3, final)
│   └── diagramas/       arquitectura y esquema dimensional: PNG + archivo editable (draw.io)
├── datos/
│   ├── raw/             fuentes originales
│   ├── muestras/        20 filas por fuente, en CSV
│   ├── diccionarios/    un diccionario por fuente
│   └── descarga.md      URL, fecha y pasos para obtener cada fuente
├── dw/
│   ├── ddl/             scripts CREATE TABLE de dimensiones y hechos
│   └── conciliacion/    consultas de conteo y totales por fuente
├── etl/
│   ├── transformaciones/  archivos .ktr de Pentaho
│   ├── trabajos/          archivos .kjb de Pentaho
│   └── README.md          orden de ejecución y parámetros
├── dashboard/           enlace al reporte de Looker Studio, campos calculados y capturas
└── modelo/              notebooks de Python del modelo predictivo
```

## Cómo reproducir

Requisitos: PostgreSQL 16, Pentaho Data Integration 9.4 o 10.x (Java 11/17), Power BI Desktop (Windows) y Python 3.11+ para el modelo.

1. **Fuentes.** Clonar el repositorio: las tres fuentes originales ya están en [`datos/raw/`](datos/raw/). Su origen y cómo volver a descargarlas está en [`datos/descarga.md`](datos/descarga.md); los diccionarios, en [`datos/diccionarios/`](datos/diccionarios/).
2. **Data warehouse.** Ejecutar en orden los scripts de [`dw/ddl/`](dw/ddl/) (`00` crea la base; `01`–`08` crean el esquema, las 6 dimensiones y la tabla de hechos con sus llaves).
3. **ETL.** Configurar la conexión en `kettle.properties` y ejecutar `etl/trabajos/j_carga_dw.kjb`. Detalle en [`etl/README.md`](etl/README.md).
4. **Conciliación.** Desde la raíz del repositorio, ejecutar con `psql` los scripts de [`dw/conciliacion/`](dw/conciliacion/) en orden (`01` copia las fuentes crudas al esquema `conciliacion`; `02` y `03` comparan con el DW; `04` da las cifras del tablero).
5. **Tablero.** Abrir el reporte de Looker Studio (<https://datastudio.google.com/reporting/ff362d1b-b283-4d16-969c-23989bdc0614>). Conexión, campos calculados y páginas: [`dashboard/README.md`](dashboard/README.md).
6. **Modelo predictivo (Entrega 3).** Ver la sección siguiente.
7. **Diagrama físico.** `python docs/diagramas/generar_diagrama_fisico.py "host=localhost dbname=movibogota_dw user=postgres"` lo regenera desde el catálogo de la base.

Ningún archivo del repositorio contiene contraseñas.

## Entrega 3 · Modelo predictivo (pregunta P3)

Pronóstico de validaciones por estación y mes. Regresión lineal frente a bosque aleatorio, con división temporal: entrenamiento de jun 2024 a sep 2025 y prueba de oct a dic 2025. El modelo elegido es la regresión lineal, con un MAE de 4,29 validaciones por estación y mes. El pronóstico para ene–mar 2026 es de 6.894 validaciones.

| Ruta | Contenido |
|---|---|
| [`modelo/modelo_demanda_estacion.ipynb`](modelo/modelo_demanda_estacion.ipynb) | Notebook de principio a fin: extracción, exploración, preparación, 2 algoritmos, evaluación y despliegue |
| [`modelo/extraccion.sql`](modelo/extraccion.sql) | Consulta que extrae el conjunto de datos del DW (2.544 filas estación × mes) |
| [`modelo/requirements.txt`](modelo/requirements.txt) | Librerías y versiones |
| `modelo/figuras/`, `modelo/predicciones.csv` | Gráficos y predicciones que genera el notebook |
| [`etl/trabajos/j_despliegue_predicciones.kjb`](etl/trabajos/j_despliegue_predicciones.kjb) | Trabajo de Pentaho: crea `pred_*` y carga `modelo/predicciones.csv` en el DW |
| [`dw/ddl/10_pred_validaciones_estacion_mes.sql`](dw/ddl/10_pred_validaciones_estacion_mes.sql) | Tabla `dw.pred_validaciones_estacion_mes`, extensión de `dim_tiempo` a 2026 y vista del tablero |
| [`dashboard/MoviBogota_Tablero.pbix`](dashboard/MoviBogota_Tablero.pbix) | Tablero de Power BI con la página 4 «Predicciones» |
| [`dashboard/medidas_powerbi.md`](dashboard/medidas_powerbi.md) | Conexión, relaciones, medidas DAX y diseño de la página 4 |
| `dashboard/pagina4_predicciones_powerbi.png` | Captura de la página de predicciones en Power BI |

### Cómo ejecutar el modelo

1. Tener el DW cargado (pasos 2 y 3 de «Cómo reproducir»).
2. Instalar las librerías:
   ```bash
   python -m venv .venv && source .venv/bin/activate   # en Windows: .venv\Scripts\activate
   pip install -r modelo/requirements.txt
   ```
3. Definir la conexión al DW en una variable de entorno. La contraseña no se guarda en el repositorio.
   ```bash
   export DW_URL="postgresql+psycopg2://postgres:<clave>@localhost:5432/movibogota_dw"   # Windows: set DW_URL=...
   ```
4. Abrir y ejecutar el notebook completo (*Reiniciar y ejecutar todo*):
   ```bash
   cd modelo && jupyter notebook modelo_demanda_estacion.ipynb
   # o sin interfaz: jupyter nbconvert --to notebook --execute --inplace modelo_demanda_estacion.ipynb
   ```
   El notebook ejecuta `dw/ddl/10_pred_validaciones_estacion_mes.sql` y reescribe las 636 predicciones en `dw.pred_validaciones_estacion_mes`.

En Google Colab: subir la carpeta `modelo/` y `dw/ddl/10_...sql`, ejecutar `!pip install -r requirements.txt` y definir `DW_URL` con `os.environ` apuntando a un PostgreSQL accesible desde internet.

### Cómo cargar las predicciones con Pentaho (despliegue en el DW)

Después de ejecutar el notebook (genera `modelo/predicciones.csv`), abra en Spoon `etl/trabajos/j_despliegue_predicciones.kjb` y ejecútelo (F9), con `kettle.properties` configurado como en `etl/README.md`. Crea `dw.pred_validaciones_estacion_mes` y la llena con las 636 predicciones. Si recarga el DW con `j_carga_dw.kjb`, repita este paso.

### Cómo visualizar las predicciones

1. Instale Power BI Desktop y abra `dashboard/MoviBogota_Tablero.pbix`. Los datos ya vienen importados, así que se ve sin conectarse al DW.
2. Vaya a la página 4, **«Predicciones»**. Muestra las validaciones reales frente a las predichas por mes (prueba oct–dic 2025 y pronóstico ene–mar 2026), el MAE y RMSE, y el reparto de buses por troncal. Se filtra por troncal, periodo y estación.
3. Para actualizar con su propio DW: *Transformar datos › Configuración de origen de datos* → servidor `localhost:5432`, base `movibogota_dw`, y luego *Actualizar*. Lee `dw.pred_validaciones_estacion_mes`, `dw.dim_estacion` y `dw.dim_tiempo`. Detalle en [`dashboard/medidas_powerbi.md`](dashboard/medidas_powerbi.md).

La versión en Looker Studio de la Entrega 2 (<https://datastudio.google.com/reporting/ff362d1b-b283-4d16-969c-23989bdc0614>) también tiene la página de predicciones, sobre la vista `dw.v_tablero_predicciones`.
