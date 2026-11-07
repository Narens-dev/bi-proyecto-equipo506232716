"""
Generador de la fuente F1 (v2) - Registro transaccional de validaciones de MoviBogotá S.A.

F1 es un conjunto SINTÉTICO (el sistema de recaudo real no publica validaciones
individuales). La versión 2 reemplaza a la v1 de la Entrega 1 para que F1 se pueda
integrar con las fuentes reales:
  * id_estacion usa el código oficial de la estación (num_est de F2) con prefijo EST-.
  * id_ruta conserva los 7 códigos de la v1 (B12, L10, A60, K16, F23, H27, G43); la letra
    coincide con le_troncal de F3, y cada ruta solo valida en estaciones de su troncal.
  * Flota de 450 buses (BUS-001 a BUS-450), cada uno asignado a una ruta (FLOTA_RUTA).

Se conservan a propósito los problemas de calidad diagnosticados en la Entrega 1
(tabla 2.2) para que la limpieza ocurra en PDI y no a mano:
  1. fecha_hora en tres formatos: ISO, dd/mm/aaaa hh:mm AM/PM y epoch Unix en texto.
  2. id_estacion con espacios y minúsculas («  est-07103 »).
  3. id_bus vacío por fallas de transmisión.
  4. Validaciones duplicadas (mismo id_validacion) por reenvío del validador.
  5. monto_pagado en cero o negativo (reversos mal registrados).
  6. Estación no catalogada (EST-00000, validador sin configurar).

Uso:  python generar_F1.py <ruta_F2.csv> <ruta_salida.csv>
Semilla fija: el archivo resultante es siempre el mismo.
"""
import csv
import random
import sys
from datetime import date, datetime, timedelta

SEED = 506232716
N_TOTAL = 55_000          # filas del archivo, incluidos duplicados
N_DUPLICADOS = 180
N_MONTO_INVALIDO = 45
N_ESTACION_DESCONOCIDA = 38
P_BUS_VACIO = 0.02
P_CODIGO_SUCIO = 0.04
P_FMT_AMPM = 0.10
P_FMT_EPOCH = 0.05

RUTAS = {  # ruta -> trazados de F2/F3 donde opera
    "RUTA-A60": ["TZ001"],
    "RUTA-B12": ["TZ002"],
    "RUTA-F23": ["TZ009"],
    "RUTA-G43": ["TZ010", "TZ011"],
    "RUTA-H27": ["TZ012", "TZ013", "TZ014"],
    "RUTA-K16": ["TZ016"],
    "RUTA-L10": ["TZ018"],
}
PESO_RUTA = {"RUTA-A60": 1.25, "RUTA-B12": 1.30, "RUTA-F23": 1.05, "RUTA-G43": 0.95,
             "RUTA-H27": 1.00, "RUTA-K16": 0.80, "RUTA-L10": 0.65}

# perfil horario (0..23) de un día hábil
PERFIL_HORA = [0.15, 0.08, 0.05, 0.10, 0.90, 3.20, 4.60, 4.20, 2.80, 1.60, 1.30, 1.30,
               1.50, 1.50, 1.30, 1.50, 2.30, 3.60, 4.10, 3.10, 1.80, 1.10, 0.60, 0.30]
PESO_DIA = {1: 1.00, 2: 1.03, 3: 1.04, 4: 1.03, 5: 1.08, 6: 0.68, 7: 0.42}
PESO_MES = {1: 0.82, 2: 1.00, 3: 1.04, 4: 0.97, 5: 1.05, 6: 0.90, 7: 0.92,
            8: 1.02, 9: 1.06, 10: 1.05, 11: 1.03, 12: 0.86}
CRECIMIENTO_2025 = 1.06
# asignación histórica de la flota por ruta (no proporcional a la demanda: es lo que P2 evalúa)
FLOTA_RUTA = {"RUTA-A60": 72, "RUTA-B12": 62, "RUTA-F23": 70, "RUTA-G43": 68,
              "RUTA-H27": 60, "RUTA-K16": 64, "RUTA-L10": 54}

TARIFAS = [("General", 0.61), ("Sisben", 0.15), ("Adulto Mayor", 0.14),
           ("Discapacidad", 0.05), ("Estudiantil", 0.05)]
VALOR = {2024: {"General": 2950, "Estudiantil": 2700, "Sisben": 2500,
                "Adulto Mayor": 2500, "Discapacidad": 2500},
         2025: {"General": 3200, "Estudiantil": 2900, "Sisben": 2700,
                "Adulto Mayor": 2700, "Discapacidad": 2700}}
METODOS = [("Tarjeta TuLlave", 0.85), ("NFC Celular", 0.10), ("Tarjeta Bancaria", 0.05)]


def elegir(rng, pares):
    return rng.choices([p[0] for p in pares], weights=[p[1] for p in pares])[0]


def main(ruta_f2, salida):
    rng = random.Random(SEED)

    # estaciones reales de F2 por trazado (código normalizado a 5 dígitos)
    estaciones = {}
    with open(ruta_f2, encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            cod = r["num_est"].strip().zfill(5)
            peso = 4.0 if r["tipo_esta"] == "1" else (2.0 if r["tipo_esta"] == "2" else 1.0)
            estaciones.setdefault(r["id_trazado"], []).append((cod, peso))

    est_ruta = {}
    for ruta, tzs in RUTAS.items():
        lst = [e for tz in tzs for e in estaciones[tz]]
        est_ruta[ruta] = ([c for c, _ in lst], [p for _, p in lst])

    # flota: 450 buses repartidos según FLOTA_RUTA
    buses = [f"BUS-{i:03d}" for i in range(1, 451)]
    rng.shuffle(buses)
    flota, i = {}, 0
    for ruta, n in FLOTA_RUTA.items():
        flota[ruta] = buses[i:i + n]
        i += n

    # momentos (día, hora) ponderados
    dias, pesos_dia = [], []
    d = date(2024, 1, 1)
    while d <= date(2025, 12, 31):
        w = PESO_DIA[d.isoweekday()] * PESO_MES[d.month] * (CRECIMIENTO_2025 if d.year == 2025 else 1)
        dias.append(d)
        pesos_dia.append(w)
        d += timedelta(days=1)

    n_base = N_TOTAL - N_DUPLICADOS
    # garantizar al menos una validación por día (sin huecos en el periodo)
    dias_sel = list(dias) + rng.choices(dias, weights=pesos_dia, k=n_base - len(dias))
    rutas = list(RUTAS)
    filas = []
    for d in dias_sel:
        h = rng.choices(range(24), weights=PERFIL_HORA)[0]
        if d.isoweekday() >= 6 and h in (5, 6, 7, 17, 18):   # fines de semana sin pico marcado
            h = rng.choice([9, 10, 11, 12, 13, 14, 15])
        ts = datetime(d.year, d.month, d.day, h, rng.randrange(60), 0)
        ruta = rng.choices(rutas, weights=[PESO_RUTA[r] for r in rutas])[0]
        cods, pesos = est_ruta[ruta]
        est = rng.choices(cods, weights=pesos)[0]
        tarifa = elegir(rng, TARIFAS)
        filas.append([ts, f"EST-{est}", ruta, rng.choice(flota[ruta]), tarifa,
                      VALOR[ts.year][tarifa], elegir(rng, METODOS)])
    filas.sort(key=lambda x: x[0])

    out = []
    for n, (ts, est, ruta, bus, tarifa, monto, metodo) in enumerate(filas, start=1):
        u = rng.random()
        if u < P_FMT_EPOCH:          # epoch Unix (UTC) de la hora local de Bogotá (UTC-5)
            fh = str(int((ts + timedelta(hours=5) - datetime(1970, 1, 1)).total_seconds()))
        elif u < P_FMT_EPOCH + P_FMT_AMPM:
            fh = ts.strftime("%d/%m/%Y %I:%M %p")
        else:
            fh = ts.strftime("%Y-%m-%d %H:%M:%S")
        if rng.random() < P_CODIGO_SUCIO:
            est = " " + est.lower() + " "
        if rng.random() < P_BUS_VACIO:
            bus = ""
        out.append([f"VAL-{n:07d}", fh, est, ruta, bus, tarifa, str(monto), metodo])

    # errores puntuales sobre filas distintas
    idx = rng.sample(range(len(out)), N_MONTO_INVALIDO + N_ESTACION_DESCONOCIDA)
    for j in idx[:N_MONTO_INVALIDO]:
        out[j][6] = rng.choice(["0", "-" + out[j][6]])
    for j in idx[N_MONTO_INVALIDO:]:
        out[j][2] = "EST-00000"
    validas = [j for j in range(len(out)) if j not in set(idx[:N_MONTO_INVALIDO])]
    for j in sorted(rng.sample(validas, N_DUPLICADOS), reverse=True):
        out.insert(j + 1 + rng.randrange(3), list(out[j]))   # reenvío cercano

    with open(salida, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["id_validacion", "fecha_hora", "id_estacion", "id_ruta", "id_bus",
                    "tipo_tarifa", "monto_pagado", "metodo_pago"])
        w.writerows(out)
    print(f"{len(out)} filas escritas en {salida}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
