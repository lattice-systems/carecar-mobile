# 0009 · Diagnóstico de CareCar

**Estado** Implementación de V2-M23.01. El alcance de validación de esta etapa es Android.

## Contexto

El equipo necesita detectar errores y crashes y conservar los símbolos de las compilaciones. El diagnóstico respeta la opción **Compartir analítica**, que está apagada por defecto.

## Opciones

Agencia360 permite recibir categorías fijas y consultar conteos en el panel. Un proveedor externo facilitaría capturar y simbolizar crashes nativos. Se descartó incorporar Sentry para esta etapa.

## Decisión

Usar la API de Agencia360 para contar errores de Flutter y del aislado principal en compilaciones profile y release con consentimiento activo. La app envía una categoría fija, como máximo una vez cada cinco segundos por categoría durante el proceso. Los mensajes, las trazas, el contenido de usuario y los identificadores personales quedan fuera del evento. Se conserva el comportamiento de los manejadores de Flutter.

En Android 11 o posterior, la app consulta el historial de salidas del sistema al restaurar una sesión activa. Reporta `CRASH_ANDROID` por cierres causados por excepciones sin manejar en Java/Kotlin o fallos de código nativo durante el período vigente de consentimiento. El dispositivo usa las marcas de tiempo de Android para filtrar y evitar contar dos veces. La petición solo contiene `tipo` y Agencia360 acumula un total diario. Para instalaciones con una elección anterior a este cambio, el historial empieza en el primer arranque con sesión activa. Android 7–10 conserva los reportes de Flutter y Dart. [Historial de salidas de Android](https://developer.android.com/reference/android/app/ActivityManager#getHistoricalProcessExitReasons(java.lang.String,int,int))

El workflow de distribución de Android prepara un artefacto con los símbolos Dart que genera `--split-debug-info` para el mismo build. Su publicación queda por comprobar en una corrida de GitHub Actions. La validación de iOS se aplaza por falta de un entorno iOS. [Símbolos de Flutter](https://docs.flutter.dev/deployment/obfuscate)

## Validación de Android

1. Ejecutar la suite de Flutter y la prueba de integración del flujo principal.
2. Con el APK profile de desarrollo y una cuenta de prueba, activar **Compartir analítica**. Provocar un cierre de la instancia de prueba y volver a abrirla. Comprobar que la API responde 204 a `{"tipo":"CRASH_ANDROID"}` y que una segunda reapertura no repite el evento. Repetir con el interruptor apagado y verificar que la API no recibe el reporte.
3. Comprobar que el workflow de distribución publica el artefacto de símbolos Dart del APK.

En el emulador API 37, con el APK profile de desarrollo, Android clasificó los cierres controlados con `SIGSEGV` como fallos de código nativo. El simulador recibió un evento con `tipo` como único campo y devolvió 204. La segunda apertura no repitió el envío. Un nuevo cierre con la opción apagada quedó fuera del reporte. Una sonda temporal reportó `ERROR_FLUTTER` al activar el permiso. Tanto esa categoría como `CRASH_ANDROID` quedaron fuera del envío con la opción apagada. El archivo de símbolos Dart x86_64 y `libapp.so` del APK tienen el mismo identificador de compilación.

## Consecuencias

Agencia360 conserva el diagnóstico operativo y el panel. El historial de Android es limitado y el envío es de mejor esfuerzo. El conteo se agrega al día de recepción. Los símbolos Dart sirven para inspeccionar trazas obtenidas por separado.
