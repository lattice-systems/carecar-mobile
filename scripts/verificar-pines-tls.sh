#!/usr/bin/env bash
# Vigilancia de los certificados fijados de la app (V2-M22.04).
#
# Comprueba tres cosas, con `openssl` y sin credenciales (solo abre una conexión
# TLS al servidor, como lo haría cualquier navegador):
#
#   1. Que los certificados de `lib/config/pines_tls.dart` se lean y que la
#      huella SHA-256 declarada de cada uno sea la del certificado.
#   2. Que ninguno venza pronto (aviso a 18 meses, fallo a 6).
#   3. Que el servidor real siga validando **solo** contra esas anclas: la misma
#      prueba que hace la app al conectarse. Si Azure cambia de jerarquía de
#      certificados, esto falla semanas antes de que lo note un usuario.
#
# Uso:   scripts/verificar-pines-tls.sh [host]
# El host sale de `lib/config/flavor.dart` si no se pasa. Variables:
#   MARGEN_AVISO_DIAS (540) y MARGEN_FALLO_DIAS (180).
#
# Qué hacer si falla: docs/seguridad/fijar-certificados.md, sección «Si algo se
# rompe». Corre cada semana en .github/workflows/pines-tls.yml.

set -euo pipefail

raiz="$(cd "$(dirname "$0")/.." && pwd)"
archivo_pines="$raiz/lib/config/pines_tls.dart"
archivo_flavor="$raiz/lib/config/flavor.dart"
margen_aviso="${MARGEN_AVISO_DIAS:-540}"
margen_fallo="${MARGEN_FALLO_DIAS:-180}"

trabajo="$(mktemp -d)"
trap 'rm -rf "$trabajo"' EXIT

fallos=0
fallo() { echo "FALLA: $*"; fallos=$((fallos + 1)); }
aviso() { echo "AVISO: $*"; }

command -v openssl >/dev/null || { echo "Falta openssl."; exit 2; }

# --- 1. Las anclas ------------------------------------------------------------

# Cada certificado del archivo Dart, a su propio .pem.
awk -v dir="$trabajo" '
  /-----BEGIN CERTIFICATE-----/ { n++; destino = sprintf("%s/ancla-%02d.pem", dir, n); dentro = 1 }
  dentro { print > destino }
  /-----END CERTIFICATE-----/ { dentro = 0; close(destino) }
' "$archivo_pines"

anclas=("$trabajo"/ancla-*.pem)
[ -e "${anclas[0]}" ] || { echo "No encontré certificados en $archivo_pines."; exit 2; }

declaradas="$(grep -oE "sha256: '[0-9a-f]{64}'" "$archivo_pines" | grep -oE '[0-9a-f]{64}' | sort)"
calculadas=""
echo "Anclas fijadas (${#anclas[@]}):"
for ancla in "${anclas[@]}"; do
  huella="$(openssl x509 -in "$ancla" -noout -fingerprint -sha256 | sed 's/.*=//; s/://g' | tr 'A-F' 'a-f')"
  calculadas="$calculadas$huella"$'\n'
  asunto="$(openssl x509 -in "$ancla" -noout -subject -nameopt RFC2253 | sed 's/^subject=//')"
  vence="$(openssl x509 -in "$ancla" -noout -enddate | sed 's/^notAfter=//')"
  echo "  - $asunto"
  echo "      sha256 $huella"
  echo "      vence  $vence"

  if ! openssl x509 -in "$ancla" -noout -checkend $((margen_fallo * 86400)) >/dev/null; then
    fallo "«$asunto» vence en menos de $margen_fallo días."
  elif ! openssl x509 -in "$ancla" -noout -checkend $((margen_aviso * 86400)) >/dev/null; then
    aviso "«$asunto» vence en menos de $margen_aviso días: hay que planear su reemplazo."
  fi
done
calculadas="$(printf '%s' "$calculadas" | sed '/^$/d' | sort)"

if [ "$declaradas" != "$calculadas" ]; then
  fallo "las huellas declaradas en pines_tls.dart no son las de los certificados incluidos."
  echo "  declaradas:"; echo "$declaradas" | sed 's/^/    /'
  echo "  calculadas:"; echo "$calculadas" | sed 's/^/    /'
fi

cat "${anclas[@]}" > "$trabajo/pines.pem"

# --- 2. El servidor real ------------------------------------------------------

host="${1:-}"
if [ -z "$host" ]; then
  host="$(grep -oE "https://[^/']+" "$archivo_flavor" | head -1 | sed 's#https://##')"
fi
[ -n "$host" ] || { echo "No encontré el host en $archivo_flavor."; exit 2; }

echo
echo "Servidor: $host"

con_limite() { if command -v timeout >/dev/null; then timeout 30 "$@"; else "$@"; fi; }

valido=0
for intento in 1 2 3; do
  # Solo confía en las anclas: sin la tienda del sistema (-no-CApath), como la app.
  if salida="$(con_limite openssl s_client -connect "$host:443" -servername "$host" \
      -verify_hostname "$host" -CAfile "$trabajo/pines.pem" -no-CApath \
      -verify_return_error -showcerts </dev/null 2>&1)" \
    && grep -qE 'Verification: OK|Verify return code: 0 \(ok\)' <<<"$salida"; then
    valido=1
    break
  fi
  echo "  intento $intento: no validó; reintento en 5 s…"
  sleep 5
done

echo "Cadena que presenta el servidor:"
grep -E '^ *[0-9]+ s:|^ *i:' <<<"${salida:-}" | sed 's/^/  /' || true

if [ "$valido" -eq 1 ]; then
  echo "OK: el servidor valida contra las anclas fijadas."
else
  fallo "el servidor NO valida contra las anclas fijadas: una app con estos pines no podría conectarse."
  grep -E 'Verification|Verify return code|verify error' <<<"${salida:-}" | sed 's/^/  /' || true
fi

echo
if [ "$fallos" -gt 0 ]; then
  echo "$fallos problema(s). Ver docs/seguridad/fijar-certificados.md, «Si algo se rompe»."
  exit 1
fi
echo "Todo en orden."
