"""Dibuja los .kjb/.ktr del repo como diagramas (pasos y saltos leídos del XML) y la tabla de filas cargadas."""
import subprocess, xml.etree.ElementTree as ET, html
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

REPO = "/home/claude/repo"
OUT = f"{REPO}/docs/diagramas"

COLORS = {"CsvInput": "#dbeafe", "JsonInput": "#dbeafe", "TableOutput": "#dcfce7", "TextFileOutput": "#fee2e2",
          "SPECIAL": "#f3f4f6", "TRANS": "#e0e7ff", "SQL": "#fef3c7", "SUCCESS": "#dcfce7"}


def render(path, kind, png):
    root = ET.parse(path).getroot()
    lines = ['digraph G { rankdir=TB; bgcolor="white"; nodesep=0.35; ranksep=0.45;',
             'node [shape=box, style="rounded,filled", fontname="Helvetica", fontsize=10, color="#64748b"];',
             'edge [color="#475569", arrowsize=0.7, fontname="Helvetica", fontsize=8];']
    items = root.findall("step") if kind == "ktr" else root.find("entries").findall("entry")
    for it in items:
        name, typ = it.findtext("name"), it.findtext("type")
        label = f"<<b>{html.escape(name)}</b><br/><font point-size='8' color='#475569'>{html.escape(typ)}</font>>"
        lines.append(f'"{name}" [label={label}, fillcolor="{COLORS.get(typ, "#ffffff")}"];')
    hops = root.find("order").findall("hop") if kind == "ktr" else root.find("hops").findall("hop")
    for h in hops:
        a = h.findtext("from")
        b = h.findtext("to")
        lab = ""
        if kind == "kjb" and h.findtext("unconditional") == "N":
            lab = ', label="OK", fontcolor="#15803d", color="#15803d"'
        lines.append(f'"{a}" -> "{b}" [{lab.lstrip(", ")}];')
    if kind == "ktr":  # flujos de error (filas rechazadas)
        for e in root.iter("error"):
            s, d = e.findtext("source_step"), e.findtext("target_step")
            if s and d:
                lines.append(f'"{s}" -> "{d}" [style=dashed, color="#b91c1c", label="rechazo", fontcolor="#b91c1c"];')
    if kind == "kjb":  # filas de 4 entradas en el orden de ejecución, para que quepa en la página
        order, cur = [], "START"
        nxt = {h.findtext("from"): h.findtext("to") for h in hops}
        while cur:
            order.append(cur); cur = nxt.get(cur)
        for i in range(0, len(order), 4):
            lines.append("{rank=same; " + " ".join(f'"{n}";' for n in order[i:i + 4]) + "}")
    lines.append("}")
    subprocess.run(["dot", "-Tpng", "-Gdpi=170", "-o", png], input="\n".join(lines).encode(), check=True)


render(f"{REPO}/etl/trabajos/j_carga_dw.kjb", "kjb", f"{OUT}/etl_j_carga_dw.png")
render(f"{REPO}/etl/transformaciones/t_dim_estacion.ktr", "ktr", f"{OUT}/etl_t_dim_estacion.png")
render(f"{REPO}/etl/transformaciones/t_fact_validaciones.ktr", "ktr", f"{OUT}/etl_t_fact_validaciones.png")

# Filas por tabla tras la carga (consulta a dw.* en la base movibogota-dw)
rows = [("dw.dim_tiempo", "731", "730 días 2024–2025 + miembro −1"),
        ("dw.dim_hora", "1.440", "1.440 minutos del día"),
        ("dw.dim_estacion", "154", "153 estaciones de F2 + miembro −1"),
        ("dw.dim_ruta", "8", "7 rutas + miembro −1"),
        ("dw.dim_bus", "451", "450 buses + miembro −1"),
        ("dw.dim_tarifa", "16", "tarifas × método de pago + miembro −1"),
        ("dw.fact_validaciones", "54.775", "55.000 leídas − 180 duplicadas − 45 montos ≤ 0")]
fig, ax = plt.subplots(figsize=(8.2, 2.9), dpi=170)
ax.axis("off")
t = ax.table(cellText=[list(r) for r in rows], colLabels=["Tabla", "Filas", "Explicación"],
             colWidths=[0.28, 0.12, 0.60], loc="center", cellLoc="left")
t.auto_set_font_size(False)
t.set_fontsize(9)
t.scale(1, 1.45)
for (r, c), cell in t.get_celld().items():
    cell.set_edgecolor("#cbd5e1")
    if r == 0:
        cell.set_facecolor("#1e3a8a"); cell.get_text().set_color("white"); cell.get_text().set_weight("bold")
    elif c == 1:
        cell.get_text().set_ha("right")
plt.savefig(f"{OUT}/etl_filas_cargadas.png", bbox_inches="tight", facecolor="white")
print("ok")
