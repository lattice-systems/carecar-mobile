#!/usr/bin/env bash
# Compila la app en debug, la instala en el celular Android por USB y la abre.
# Uso: bash scripts/instalar_en_celular.sh   (API_PUERTO opcional, por defecto 8089)
set -euo pipefail

PUERTO="${API_PUERTO:-8089}"
cd "$(dirname "$0")/.."

# (a) adb y dispositivo autorizado
if ! command -v adb >/dev/null 2>&1; then
  export PATH="$PATH:$HOME/Android/Sdk/platform-tools"
fi
command -v adb >/dev/null 2>&1 || { echo "ERROR: no encuentro adb (instala platform-tools)."; exit 1; }

estado="$(adb devices | awk 'NR>1 && $2!="" {print $2}' | head -n1)"
if [ -z "$estado" ]; then
  echo "ERROR: no hay celular conectado. Conecta el USB y activa la depuracion USB."
  exit 1
fi
if [ "$estado" = "unauthorized" ]; then
  echo "ERROR: el celular dice 'unauthorized'. Ejecuta: adb kill-server && adb start-server"
  echo "y acepta el mensaje 'Permitir depuracion USB' en el telefono."
  exit 1
fi
[ "$estado" = "device" ] || { echo "ERROR: estado del dispositivo: $estado"; exit 1; }

# (b) backend
if ! curl -s -o /dev/null --max-time 5 "http://localhost:$PUERTO/api/v1/app/auth/login"; then
  echo "ERROR: el backend no responde en http://localhost:$PUERTO. Levantalo con:"
  echo "  cd ../backend-agencia360-wt-app2 && ADMIN_INICIAL_USUARIO=admin ADMIN_INICIAL_CONTRASENA=Admin12345 \\"
  echo "    GERENTE_INICIAL_USUARIO=gerente GERENTE_INICIAL_CONTRASENA=Gerente12345 docker compose --profile proxy up -d"
  exit 1
fi

# (c) el celular llega al backend de la laptop por USB
adb reverse "tcp:$PUERTO" "tcp:$PUERTO"

# (d) compilar
if ! command -v flutter >/dev/null 2>&1 && [ -x "$HOME/flutter/bin/flutter" ]; then
  export PATH="$PATH:$HOME/flutter/bin"
fi
MODO="${MODO:-debug}"   # MODO=release: mucho mas fluido (sin las comprobaciones de depuracion)
flutter build apk "--$MODO" "--dart-define=API_BASE_URL=http://localhost:$PUERTO/api/v1/app"

# (e) instalar y abrir
adb install -r "build/app/outputs/flutter-apk/app-$MODO.apk"
paquete="$(grep -m1 applicationId android/app/build.gradle* | sed -E "s/.*[\"']([^\"']+)[\"'].*/\1/")"
adb shell monkey -p "$paquete" -c android.intent.category.LAUNCHER 1 >/dev/null
echo "Listo: $paquete instalada y abierta."
