#!/usr/bin/env bash
# Notas de una versión a partir de los commits convencionales (V2-T04.05).
#
# Uso: scripts/notas-de-version.sh vX.Y.Z
# Toma los commits entre la etiqueta anterior y vX.Y.Z (sin merges) y los
# agrupa por tipo: feat → Novedades, fix → Correcciones, perf → Rendimiento.
# Lo demás (docs, test, build, ci, chore, refactor, style) solo se cuenta.
# Escribe Markdown en la salida estándar.
set -euo pipefail

ETIQUETA="${1:?Falta la etiqueta, por ejemplo v1.2.0}"
ANTERIOR=$(git describe --tags --abbrev=0 --match 'v*' "$ETIQUETA^" 2>/dev/null || true)
RANGO="${ANTERIOR:+$ANTERIOR..}$ETIQUETA"

novedades=""; correcciones=""; rendimiento=""; otros=0
while IFS= read -r asunto; do
  [ -n "$asunto" ] || continue
  if [[ "$asunto" =~ ^([a-z]+)(\(([^\)]*)\))?!?:\ (.+)$ ]]; then
    tipo="${BASH_REMATCH[1]}"; alcance="${BASH_REMATCH[3]}"; texto="${BASH_REMATCH[4]}"
    linea="- ${texto^}${alcance:+ ($alcance)}"
    case "$tipo" in
      feat) novedades+="$linea"$'\n' ;;
      fix) correcciones+="$linea"$'\n' ;;
      perf) rendimiento+="$linea"$'\n' ;;
      *) otros=$((otros + 1)) ;;
    esac
  else
    otros=$((otros + 1))
  fi
done < <(git log --no-merges --format=%s "$RANGO")

echo "## CareCar $ETIQUETA"
echo
if [ -n "$ANTERIOR" ]; then echo "Cambios desde $ANTERIOR."; else echo "Primera versión."; fi
for seccion in "Novedades:$novedades" "Correcciones:$correcciones" "Rendimiento:$rendimiento"; do
  titulo="${seccion%%:*}"; cuerpo="${seccion#*:}"
  [ -n "$cuerpo" ] || continue
  echo; echo "### $titulo"; echo; printf '%s' "$cuerpo"
done
if [ "$otros" -gt 0 ]; then
  echo; echo "Además, $otros cambios de mantenimiento (documentación, pruebas, CI y dependencias)."
fi
