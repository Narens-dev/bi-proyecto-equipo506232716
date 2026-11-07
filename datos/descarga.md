# Obtención de las fuentes · MoviBogotá S.A.

Las tres fuentes están en [`datos/raw/`](raw/) **tal como se obtuvieron**; PDI las lee en su formato original (CSV, CSV y GeoJSON). Ningún archivo supera 50 MB, por lo que todos se versionan.

| Fuente | Archivo | Formato | Registros | Periodo / vigencia | Fecha de obtención | Licencia |
|---|---|---|---|---|---|---|
| F1 · Validaciones | `Dataset_registros.csv` | CSV | 55.000 | 01/01/2024 – 31/12/2025 | 06/11/2026 (v2) | Uso académico · datos sintéticos |
| F2 · Estaciones troncales | `Estaciones_Troncales_de_TRANSMILENIO.csv` | CSV | 153 | Capa vigente (edición ago. 2026) | 20/10/2026 | CC BY 4.0 |
| F3 · Trazados troncales | `Trazados_Troncales_de_TRANSMILENIO.geojson` | GeoJSON (JSON) | 22 | Capa vigente (actualizada 02/07/2026) | 06/11/2026 | CC BY 4.0 |

## F1 · Registro transaccional de validaciones (sintético)

El sistema de recaudo de Bogotá no publica validaciones individuales, así que F1 es un conjunto **sintético** generado por el equipo con [`generador/generar_F1.py`](generador/generar_F1.py) (semilla fija, resultado reproducible).

- **Versión 2 (Entrega 2):** reemplaza a la v1 de la Entrega 1 porque la v1 usaba diez estaciones inventadas (`EST-001`…`EST-010`) que no se podían cruzar con F2. La v2 usa los códigos oficiales de estación de F2 (`EST-` + `num_est`), las mismas 7 rutas (la letra coincide con `le_troncal` de F3) y una flota de 450 buses.
- Conserva **a propósito** los problemas de calidad que limpia PDI: tres formatos de fecha, códigos de estación con espacios y minúsculas, buses vacíos, validaciones duplicadas, montos en cero o negativos y una estación no catalogada.
- Reproducir: `python datos/generador/generar_F1.py datos/raw/Estaciones_Troncales_de_TRANSMILENIO.csv datos/raw/Dataset_registros.csv`

## F2 · Estaciones Troncales de TRANSMILENIO

- **Conjunto:** https://datosabiertos-transmilenio.hub.arcgis.com/datasets/Transmilenio::estaciones-troncales-de-transmilenio/about
- **Pasos:** abrir el enlace › *Descargar* › *CSV*. Se guarda sin modificar como `datos/raw/Estaciones_Troncales_de_TRANSMILENIO.csv` (UTF-8 con BOM).

## F3 · Trazados Troncales de TRANSMILENIO

- **Conjunto:** https://datosabiertos-transmilenio.hub.arcgis.com/datasets/Transmilenio::trazados-troncales-de-transmilenio/about
- **Réplica en el Portal Nacional:** https://www.datos.gov.co/dataset/Trazados-Troncales-de-TRANSMILENIO/rpry-a2us
- **Servicio REST (ArcGIS):** https://gis.transmilenio.gov.co/arcgis/rest/services/Tecnica/Consulta_Informacion_Geografica_STS/FeatureServer/5
- **Pasos:** abrir el enlace › *Descargar* › *GeoJSON*. Se guarda sin modificar como `datos/raw/Trazados_Troncales_de_TRANSMILENIO.geojson`.

## Muestras

[`muestras/`](muestras/) contiene las primeras 20 filas de cada fuente en CSV (para F3, los atributos `properties` de los primeros 20 trazados) y un extracto GeoJSON de F3 con 5 trazados en su formato original.
