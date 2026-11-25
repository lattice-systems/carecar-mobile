#!/usr/bin/env bash
# Prepara la firma de Android en CI (V2-T04.02) sin guardar secretos en el repo.
#
# Lee de variables de entorno (que el workflow toma de GitHub Secrets):
#   LLAVE_BASE64      el keystore .jks en base64
#   LLAVE_CONTRASENA  contraseña del keystore y de la llave
#   LLAVE_ALIAS       alias de la llave
# Escribe el keystore en $RUNNER_TEMP (fuera del repo) y android/key.properties,
# que build.gradle.kts usa para firmar el release. Sin secretos no falla: avisa
# y el release queda con la llave de debug, como antes.
# Deja firmado=true|false en $GITHUB_OUTPUT si existe.
set -euo pipefail

salida="${GITHUB_OUTPUT:-/dev/null}"
if [ -z "${LLAVE_BASE64:-}" ] || [ -z "${LLAVE_CONTRASENA:-}" ] || [ -z "${LLAVE_ALIAS:-}" ]; then
  echo "::warning::Sin secretos de firma: el APK se firma con la llave de debug (no apto para tiendas)."
  echo "firmado=false" >> "$salida"
  exit 0
fi

dir="${RUNNER_TEMP:-$(mktemp -d)}"
llave="$dir/carecar-firma.jks"
printf '%s' "$LLAVE_BASE64" | base64 --decode > "$llave"
chmod 600 "$llave"

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
umask 077
cat > "$raiz/android/key.properties" <<PROPS
storeFile=$llave
storePassword=$LLAVE_CONTRASENA
keyPassword=$LLAVE_CONTRASENA
keyAlias=$LLAVE_ALIAS
PROPS
echo "firmado=true" >> "$salida"
echo "Firma de Android lista (alias $LLAVE_ALIAS)."
