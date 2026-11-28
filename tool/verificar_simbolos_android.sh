#!/usr/bin/env bash
set -euo pipefail

apk=${1:?Indica la ruta del APK de pruebas}
simbolos=${2:?Indica la carpeta de símbolos Dart}
temporal=$(mktemp -d)
trap 'rm -f "$temporal/libapp.so"; rmdir "$temporal"' EXIT

build_id() {
  LC_ALL=C readelf -n "$1" | awk '/Build ID:/ {print $3}'
}

for par in 'arm64-v8a:arm64' 'armeabi-v7a:arm' 'x86_64:x64'; do
  abi=${par%%:*}
  arquitectura=${par##*:}
  archivo="$simbolos/app.android-$arquitectura.symbols"
  unzip -p "$apk" "lib/$abi/libapp.so" > "$temporal/libapp.so"
  id_apk=$(build_id "$temporal/libapp.so")
  id_simbolos=$(build_id "$archivo")
  if [[ -z "$id_apk" || "$id_apk" != "$id_simbolos" ]]; then
    echo "El identificador de compilación de $abi no coincide" >&2
    exit 1
  fi

  # Construye un marco de prueba con una dirección del código Dart de CareCar.
  direccion=$(LC_ALL=C readelf --debug-dump=decodedline "$archivo" |
    awk '$1 == "main_pruebas.dart" && $2 ~ /^[1-9][0-9]*$/ && $3 ~ /^0x/ && !direccion {direccion=$3}
         END {print direccion}')
  if [[ -z "$direccion" ]]; then
    echo "No se encontró una dirección de main_pruebas.dart para $abi" >&2
    exit 1
  fi

  marco=$(LC_ALL=C addr2line -e "$archivo" "$direccion")
  if [[ ! "$marco" =~ main_pruebas\.dart:[1-9][0-9]* ]]; then
    echo "No se pudo simbolizar $direccion para $abi: $marco" >&2
    exit 1
  fi
  printf '%s | Build ID %s | %s -> %s\n' "$abi" "$id_apk" "$direccion" "$marco"
done
