#!/usr/bin/env bash
# Corre solo las pruebas que tocan lo que cambiaste respecto a origin/dev, en
# vez de las ~390 archivos (la CI corre la suite completa en 8 partes).
#
#   tool/probar.sh            pruebas de lo cambiado (committed + sin commitear)
#   tool/probar.sh --todo     la suite completa, repartida en todos tus núcleos
#   tool/probar.sh BASE       compara contra otra base (por defecto origin/dev)
#
# Sin --coverage a propósito: es lo que más enlentece y en local no se mira.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# Con MOCK_API_URL a un puerto muerto no estorba una API simulada vieja en :3000.
export MOCK_API_URL="${MOCK_API_URL:-http://127.0.0.1:9}"
nucleos="$(nproc 2>/dev/null || sysctl -n hw.ncpu)"

if [ "${1:-}" = "--todo" ]; then
  exec flutter test --concurrency="$nucleos" --reporter failures-only
fi

base="${1:-origin/dev}"
cambiados=$( { git diff --name-only "$base"...HEAD; git diff --name-only; git ls-files --others --exclude-standard; } | sort -u | grep '\.dart$' || true)
[ -n "$cambiados" ] || { echo "Sin cambios en .dart contra $base."; exit 0; }

pruebas=()
agregar() { [ -f "$1" ] && pruebas+=("$1"); return 0; }
while IFS= read -r f; do
  case "$f" in
    test/*_test.dart) agregar "$f" ;;
    lib/*)
      agregar "test/${f#lib/}" ; agregar "test/$(echo "${f#lib/}" | sed 's/\.dart$/_test.dart/')"
      nombre="$(basename "$f")"
      # Pruebas que importan el archivo cambiado.
      while IFS= read -r t; do pruebas+=("$t"); done < <(grep -rl --include='*_test.dart' "/$nombre'" test 2>/dev/null || true)
      ;;
  esac
done <<< "$cambiados"

if [ "${#pruebas[@]}" -eq 0 ]; then
  echo "Ninguna prueba toca lo cambiado; corre tool/probar.sh --todo si dudas."
  exit 0
fi
mapfile -t unicas < <(printf '%s\n' "${pruebas[@]}" | sort -u)
echo "Corriendo ${#unicas[@]} archivo(s) de prueba:"; printf '  %s\n' "${unicas[@]}"
exec flutter test --concurrency="$nucleos" --reporter failures-only "${unicas[@]}"
