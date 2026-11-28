#!/usr/bin/env bash
set -euo pipefail

apk=${1:?Indica la ruta del APK de pruebas}
simbolos=${2:?Indica la carpeta de símbolos Dart}
llvm=${3:?Indica la carpeta bin del NDK}
temporal=$(mktemp -d)
trap 'rm -f "$temporal/libapp.so"; rmdir "$temporal"' EXIT

build_id() {
  LC_ALL=C "$llvm/llvm-readelf" -n "$1" | awk '/Build ID:/ {print $3}'
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

  # Usa el índice de lib/main.dart para obtener una dirección de la tabla DWARF.
  direccion=$(LC_ALL=C "$llvm/llvm-dwarfdump" --debug-line "$archivo" | awk '
    /^debug_line\[/ {delete archivos}
    /^file_names\[/ {indice=$0; gsub(/[^0-9]/, "", indice)}
    /name: ".*\/lib\/main\.dart"/ {archivos[indice+0]=1}
    $1 ~ /^0x/ && $2 ~ /^[1-9][0-9]*$/ && ($4 in archivos) && !direccion {direccion=$1}
    END {print direccion}')
  if [[ -z "$direccion" ]]; then
    echo "No se encontró una dirección de lib/main.dart para $abi" >&2
    exit 1
  fi

  marco=$(LC_ALL=C "$llvm/llvm-addr2line" -i -e "$archivo" "$direccion" |
    awk '/\/lib\/main\.dart:[1-9][0-9]*/ && !marco {marco=$0} END {print marco}')
  if [[ -z "$marco" ]]; then
    echo "No se pudo simbolizar $direccion para $abi" >&2
    exit 1
  fi
  printf '%s | Build ID %s | %s -> %s\n' "$abi" "$id_apk" "$direccion" "$marco"
done
