# Diccionario de datos — F2: Estaciones Troncales de TRANSMILENIO

Archivo: [`/datos/raw/Estaciones_Troncales_de_TRANSMILENIO.csv`](../raw/Estaciones_Troncales_de_TRANSMILENIO.csv) · 153 filas · 29 columnas · UTF-8 con BOM. Solo se listan los campos que usa el DW.

| Campo | Tipo | Descripción | Ejemplo | Problema de calidad | Regla en PDI |
|---|---|---|---|---|---|
| num_est | Texto | Código oficial de la estación | 07103 | 4 códigos sin cero a la izquierda (`9005`) | `regla_codigo_5_digitos` |
| nom_est | Texto | Nombre público | Portal Norte – Unicervantes | 17 nombres con guion largo «–», abreviatura «AV.» o espacios sobrantes | `regla_normaliza_nombre_estacion` |
| id_trazado | Texto | Trazado al que pertenece (llave hacia F3) | TZ008 | Ninguno | Lookup `busca_trazado_F3` |
| tipo_esta | Entero | Tipo de estación (en los datos, 1 = portales y 2 = estaciones intermedias; 3 y 4 = demás estaciones) | 4 | Ninguno | `deriva_atributos_estacion` |
| ub_est | Texto | Dirección | KR 30 - CL 72 | Ninguno | — |
| num_vag, num_acc | Entero | Vagones y accesos | 3 | Ninguno | — |
| cap_biart, cap_art | Entero | Capacidad de buses biarticulados / articulados | 120 | Ninguno | — |
| area_est | Decimal | Área de la estación (m²) | 694.56 | 17 estaciones con área 0 (dato no medido) | `regla_area_cero_a_nulo` |
| latitud, longitud | Decimal | Coordenadas WGS84 | 4.66635264 | Ninguno | — |
| created_user … last_edited_date | Texto | Metadatos de edición | editorInfraSTS | Mayoría vacíos (no se usan) | Se descartan en la selección de campos |
