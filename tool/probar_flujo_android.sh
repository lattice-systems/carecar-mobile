#!/usr/bin/env bash
set -euo pipefail

dispositivo="${1:-emulator-5554}"
export PORT=3000
registro=$(mktemp)
node mock_api/pruebas/servidor_flujo.js > "$registro" 2>&1 &
mock=$!
limpiar() {
  kill "$mock" 2>/dev/null || true
  wait "$mock" 2>/dev/null || true
  cat "$registro"
  rm -f "$registro"
}
trap limpiar EXIT

for ((intento = 0; intento < 30; intento++)); do
  kill -0 "$mock" || exit 1
  if grep -Fxq 'http://127.0.0.1:3000/api/v1/app' "$registro"; then
    flutter test integration_test/flujo_principal_test.dart -d "$dispositivo" \
      --flavor desarrollo --dart-define=MODULOS_V2=vehiculos,citas \
      --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1/app
    exit 0
  fi
  sleep 1
done

echo 'No arrancó la API simulada del flujo principal.' >&2
exit 1
