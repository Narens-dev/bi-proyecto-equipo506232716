"""Genera el diagrama del modelo físico leyendo el catálogo de PostgreSQL (information_schema).

Uso:  python generar_diagrama_fisico.py "host=localhost port=5432 dbname=movibogota_dw user=postgres"
      (la contraseña se toma de PGPASSWORD o de ~/.pgpass; nunca se escribe en el repositorio)
Requiere: psycopg (pip install "psycopg[binary]") y Graphviz (comando dot).
Salida:   modelo_fisico_dw.dot y modelo_fisico_dw.png en esta carpeta.
"""
import os
import subprocess
import sys

import psycopg

COLS = """
SELECT c.table_name, c.column_name, c.data_type, c.character_maximum_length,
       c.numeric_precision, c.numeric_scale, c.is_nullable, c.ordinal_position
FROM information_schema.columns c
WHERE c.table_schema = 'dw'
ORDER BY c.table_name, c.ordinal_position"""
PKS = """
SELECT kcu.table_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
WHERE tc.table_schema = 'dw' AND tc.constraint_type = 'PRIMARY KEY'"""
FKS = """
SELECT kcu.table_name, kcu.column_name, ccu.table_name AS ref_table, ccu.column_name AS ref_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON tc.constraint_name = ccu.constraint_name AND tc.table_schema = ccu.table_schema
WHERE tc.table_schema = 'dw' AND tc.constraint_type = 'FOREIGN KEY'"""


def tipo(dt, ln, pr, sc):
    abrev = {"character varying": "varchar", "character": "char", "timestamp without time zone": "timestamp",
             "time without time zone": "time", "integer": "int", "smallint": "smallint", "bigint": "bigint"}
    t = abrev.get(dt, dt)
    if ln:
        t += f"({ln})"
    elif dt == "numeric" and pr:
        t += f"({pr},{sc})"
    return t


def main(dsn):
    with psycopg.connect(dsn) as cn:
        cols = cn.execute(COLS).fetchall()
        pks = set(cn.execute(PKS).fetchall())
        fks = cn.execute(FKS).fetchall()
    fkset = {(t, c) for t, c, _, _ in fks}
    tablas = {}
    for t, c, dt, ln, pr, sc, nul, _ in cols:
        tablas.setdefault(t, []).append((c, tipo(dt, ln, pr, sc), (t, c) in pks, (t, c) in fkset))

    out = ['digraph dw {', '  graph [rankdir=LR, splines=spline, nodesep=0.6, ranksep=1.2, fontname="Helvetica", '
           'label="Modelo físico MoviBogotá DW (esquema dw, PostgreSQL) - generado desde information_schema", '
           'labelloc=t, fontsize=16];', '  node [shape=plaintext, fontname="Helvetica", fontsize=10];',
           '  edge [arrowhead=crow, arrowtail=none, dir=both, color="#555555"];']
    for t, cs in tablas.items():
        color = "#0E3A5A" if t.startswith("fact") else "#1F6F8B"
        filas = "".join(
            f'<tr><td align="left" port="{c}">{"<b>PK</b> " if pk else ""}{"<i>FK</i> " if fk else ""}{c}</td>'
            f'<td align="left"><font color="#555555">{ty}</font></td></tr>' for c, ty, pk, fk in cs)
        out.append(f'  {t} [label=<<table border="1" cellborder="0" cellspacing="0" cellpadding="4">'
                   f'<tr><td colspan="2" bgcolor="{color}"><font color="white"><b>dw.{t}</b></font></td></tr>'
                   f'{filas}</table>>];')
    # dimensiones repartidas a ambos lados de la tabla de hechos (estrella)
    for i, (t, c, rt, rc) in enumerate(sorted(fks, key=lambda x: x[1])):
        etiqueta = f'label="{c}", fontsize=9, fontname="Helvetica"'
        if i % 2 == 0:
            out.append(f'  {rt} -> {t} [arrowtail=tee, arrowhead=crow, {etiqueta}];')
        else:
            out.append(f'  {t} -> {rt} [dir=both, arrowtail=crow, arrowhead=tee, {etiqueta}];')
    out.append("}")
    base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "modelo_fisico_dw")
    with open(base + ".dot", "w", encoding="utf-8") as f:
        f.write("\n".join(out))
    subprocess.run(["dot", "-Tpng", "-Gdpi=130", base + ".dot", "-o", base + ".png"], check=True)
    print("Diagrama escrito en", base + ".png")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "host=localhost dbname=movibogota_dw user=postgres")
