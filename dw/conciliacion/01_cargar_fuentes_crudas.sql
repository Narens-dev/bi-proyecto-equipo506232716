-- =====================================================================
-- Conciliación · 01 · Copia cruda de las fuentes (solo para contar y sumar)
-- Ejecutar con psql DESDE LA RAÍZ DEL REPOSITORIO:
--   psql -h localhost -U postgres -d movibogota_dw -f dw/conciliacion/01_cargar_fuentes_crudas.sql
-- Las fuentes se copian tal cual (todo como texto, sin limpiar) en el esquema conciliacion.
-- =====================================================================
DROP SCHEMA IF EXISTS conciliacion CASCADE;
CREATE SCHEMA conciliacion;

CREATE TABLE conciliacion.f1_validaciones (
    id_validacion TEXT, fecha_hora TEXT, id_estacion TEXT, id_ruta TEXT,
    id_bus TEXT, tipo_tarifa TEXT, monto_pagado TEXT, metodo_pago TEXT);
\copy conciliacion.f1_validaciones FROM 'datos/raw/Dataset_registros.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

CREATE TABLE conciliacion.f2_estaciones (
    x TEXT, y TEXT, observ TEXT, longitud TEXT, latitud TEXT, objectid TEXT, num_est TEXT, nom_est TEXT,
    id_trazado TEXT, long_est TEXT, ancho_est TEXT, area_est TEXT, esta_oper TEXT, eta_oper TEXT,
    tipo_esta TEXT, ub_est TEXT, num_acc TEXT, acc_esp TEXT, acc_depr TEXT, acc_puent TEXT, cod_nodo TEXT,
    cap_biart TEXT, num_vag TEXT, cap_art TEXT, globalid TEXT, created_user TEXT, created_date TEXT,
    last_edited_user TEXT, last_edited_date TEXT);
\copy conciliacion.f2_estaciones FROM 'datos/raw/Estaciones_Troncales_de_TRANSMILENIO.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

-- F3 (GeoJSON): una línea por objeto Feature; se lee línea a línea y se interpreta como JSON
CREATE TABLE conciliacion.f3_lineas (linea TEXT);
\copy conciliacion.f3_lineas FROM 'datos/raw/Trazados_Troncales_de_TRANSMILENIO.geojson' WITH (FORMAT text, DELIMITER E'\x01', ENCODING 'UTF8')
CREATE TABLE conciliacion.f3_trazados AS
SELECT (regexp_replace(linea, ',\s*$', ''))::jsonb -> 'properties' ->> 'id_trazado' AS id_trazado,
       (regexp_replace(linea, ',\s*$', ''))::jsonb -> 'properties' ->> 'nom_tronc'  AS nom_tronc
FROM conciliacion.f3_lineas
WHERE linea LIKE '{"type":"Feature"%';
