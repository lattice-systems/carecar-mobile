#!/usr/bin/env bash
# Crea las dos llaves de firma de Android (V2-T04.02) y las sube a GitHub
# Secrets. Lo corre una persona del equipo, una sola vez, en su computadora:
#
#   scripts/crear-llaves-android.sh
#
# - pruebas: firma el APK de prueba de cada merge a main (flavor pruebas).
# - produccion: firma los Release (flavor produccion) y, más adelante, la
#   subida a Google Play. Si se pierde, la app ya publicada no se puede
#   actualizar: guarda una copia del .jks y su contraseña en un lugar seguro
#   (gestor de contraseñas). Nunca en el repositorio.
#
# Las llaves quedan en ~/.carecar-llaves/ (fuera del repo). Las contraseñas se
# generan al azar y solo se escriben en ese directorio y en GitHub Secrets.
# Requiere keytool (viene con el JDK) y gh con sesión iniciada.
set -euo pipefail

DIR="${CARECAR_LLAVES:-$HOME/.carecar-llaves}"
REPO="${REPO:-lattice-systems/carecar-mobile}"
mkdir -p "$DIR"; chmod 700 "$DIR"

for tipo in pruebas produccion; do
  jks="$DIR/carecar-$tipo.jks"
  clave="$DIR/carecar-$tipo.contrasena"
  alias="carecar-$tipo"
  if [ -f "$jks" ]; then
    echo "Ya existe $jks; se reusa."
  else
    umask 077
    head -c 32 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 32 > "$clave"
    keytool -genkeypair -v -keystore "$jks" -storetype JKS -alias "$alias" \
      -keyalg RSA -keysize 4096 -validity 10000 \
      -storepass:file "$clave" -keypass:file "$clave" \
      -dname "CN=CareCar $tipo, O=Agencia360, C=MX" >/dev/null
    echo "Creada $jks"
  fi
  MAYUS=$(echo "$tipo" | tr '[:lower:]' '[:upper:]')
  base64 -w0 "$jks" | gh secret set "ANDROID_${MAYUS}_LLAVE_BASE64" --repo "$REPO"
  gh secret set "ANDROID_${MAYUS}_LLAVE_CONTRASENA" --repo "$REPO" < "$clave"
  printf '%s' "$alias" | gh secret set "ANDROID_${MAYUS}_LLAVE_ALIAS" --repo "$REPO"
  echo "Secretos ANDROID_${MAYUS}_* actualizados en $REPO"
done

echo
echo "Listo. Respalda $DIR/carecar-produccion.jks y su contraseña fuera de esta computadora."
