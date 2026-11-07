-- 09 · Reinicio de la carga (lo ejecuta el trabajo j_carga_dw.kjb como primer paso)
-- Vacía hechos y dimensiones y crea los miembros «Desconocido» (llave -1).
TRUNCATE dw.fact_validaciones, dw.dim_estacion, dw.dim_ruta, dw.dim_bus, dw.dim_tarifa,
         dw.dim_tiempo, dw.dim_hora RESTART IDENTITY CASCADE;

INSERT INTO dw.dim_estacion (sk_estacion, cod_estacion, nombre_estacion, tipo_estacion,
                             id_trazado, nombre_trazado, letra_troncal, nombre_troncal)
VALUES (-1, 'N/D', 'Desconocida', 'N/D', 'N/D', 'Desconocido', 'N/D', 'Desconocida');
INSERT INTO dw.dim_ruta (sk_ruta, cod_ruta, letra_troncal, nombre_troncal, tipo_servicio)
VALUES (-1, 'N/D', 'N/D', 'Desconocida', 'N/D');
INSERT INTO dw.dim_bus (sk_bus, cod_bus, numero_bus) VALUES (-1, 'SIN-BUS', NULL);
INSERT INTO dw.dim_tarifa (sk_tarifa, tipo_tarifa, grupo_tarifa, metodo_pago)
VALUES (-1, 'N/D', 'N/D', 'N/D');
