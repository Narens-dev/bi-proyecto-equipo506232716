# Diccionario de datos — F1: Registro transaccional de validaciones (v2, sintético)

Archivo: [`/datos/raw/Dataset_registros.csv`](../raw/Dataset_registros.csv) · 55.000 filas · separador `,` · UTF-8

| Campo | Tipo en la fuente | Descripción | Ejemplo | Problema de calidad | Regla en PDI |
|---|---|---|---|---|---|
| id_validacion | Texto | Identificador de la validación | VAL-0000003 | 180 filas repetidas (reenvío del validador) | `regla_elimina_duplicados` |
| fecha_hora | Texto | Momento de la validación | 2024-01-01 06:23:00 · 25/03/2024 04:38 PM · 1711986720 | Tres formatos: ISO, 12 h con AM/PM y epoch Unix | `regla_normaliza_fecha_ampm`, `regla_normaliza_fecha_epoch` |
| id_estacion | Texto | Código de la estación: `EST-` + `num_est` de F2 | EST-07103 | Espacios y minúsculas (` est-07103 `); 38 filas con `EST-00000` no catalogada | `regla_normaliza_codigo_estacion`, `regla_estacion_desconocida` |
| id_ruta | Texto | Ruta troncal; la letra es la troncal de F3 | RUTA-B12 | Ninguno | — |
| id_bus | Texto | Bus que prestó el servicio (flota de 450) | BUS-209 | Vacío por fallas de transmisión (≈2 %) | `regla_bus_vacio_a_desconocido` |
| tipo_tarifa | Texto | General, Sisben, Adulto Mayor, Discapacidad, Estudiantil | General | Ninguno | — |
| monto_pagado | Texto (entero COP) | Valor cobrado | 2950 | 45 filas en 0 o negativas | `regla_valida_monto_positivo` |
| metodo_pago | Texto | Tarjeta TuLlave, NFC Celular, Tarjeta Bancaria | Tarjeta TuLlave | Ninguno | — |
