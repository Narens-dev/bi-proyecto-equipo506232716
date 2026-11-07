# Diccionario de datos — F3: Trazados Troncales de TRANSMILENIO (GeoJSON)

Archivo: [`/datos/raw/Trazados_Troncales_de_TRANSMILENIO.geojson`](../raw/Trazados_Troncales_de_TRANSMILENIO.geojson) · 22 objetos `Feature` (geometría MultiLineString, CRS84). Los atributos están en `$.features[*].properties`.

| Campo | Tipo | Descripción | Ejemplo | Problema de calidad | Regla en PDI |
|---|---|---|---|---|---|
| id_trazado | Texto | Identificador del trazado (llave con F2) | TZ002 | Ninguno | Lookup en `t_dim_estacion` |
| nom_traz | Texto | Nombre del trazado | Calle 26 Extension | Sin tildes y mayúsculas irregulares (`Extension`, `Ciudad De Cali`) | `regla_estandariza_nombres_troncal` |
| le_troncal | Texto | Letra de la troncal (llave con la ruta de F1) | B | Ninguno | Lookup en `t_dim_ruta` |
| nom_tronc | Texto | Nombre de la troncal | Americas | Sin tildes (`Americas`) | `regla_estandariza_nombres_troncal` |
| long_traz | Decimal | Longitud del trazado (km) | 11.82 | Ninguno | — |
| ori_traz / fin_traz | Texto | Inicio y fin del trazado | Avenida Calle 80 / Terminal | Grafía inconsistente (`Limite del` / `Limite Del`) | No se usan en el DW |
| fase_tronc | Texto | Fase de implementación | FASE I | Ninguno | — |
| tipo_tra | Entero | 1 exclusivo, 2 mixto, 3 sin definir | 1 | Ninguno | — |
