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
| P3 | ¿Cuántas validaciones se esperan por estación y franja horaria en el próximo trimestre? | BA (Entrega 3) |

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
| Usuario final | Microsoft Looker Studio (conectado a PostgreSQL) |
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

Requisitos: PostgreSQL 16, Pentaho Data Integration 9.4 o 10.x (Java 11/17) y Looker Studio.

1. **Fuentes.** Clonar el repositorio: las tres fuentes originales ya están en [`datos/raw/`](datos/raw/). Su origen y cómo volver a descargarlas está en [`datos/descarga.md`](datos/descarga.md); los diccionarios, en [`datos/diccionarios/`](datos/diccionarios/).
2. **Data warehouse.** Ejecutar en orden los scripts de [`dw/ddl/`](dw/ddl/) (`00` crea la base; `01`–`08` crean el esquema, las 6 dimensiones y la tabla de hechos con sus llaves).
3. **ETL.** Configurar la conexión en `kettle.properties` y ejecutar `etl/trabajos/j_carga_dw.kjb`. Detalle en [`etl/README.md`](etl/README.md).
4. **Conciliación.** Desde la raíz del repositorio, ejecutar con `psql` los scripts de [`dw/conciliacion/`](dw/conciliacion/) en orden (`01` copia las fuentes crudas al esquema `conciliacion`; `02` y `03` comparan con el DW; `04` da las cifras del tablero).
5. **Tablero.** Abrir el reporte de Looker Studio (<https://datastudio.google.com/reporting/ff362d1b-b283-4d16-969c-23989bdc0614>). Conexión, campos calculados y páginas: [`dashboard/README.md`](dashboard/README.md).
6. **Diagrama físico.** `python docs/diagramas/generar_diagrama_fisico.py "host=localhost dbname=movibogota_dw user=postgres"` lo regenera desde el catálogo de la base.

Ningún archivo del repositorio contiene contraseñas.
