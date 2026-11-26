# 0009 · Diagnóstico de CareCar

**Estado** Propuesta para V2-M23.01.

## Contexto

El equipo necesita saber cuándo falla CareCar y conservar los símbolos de cada build. El diagnóstico tiene que respetar la misma elección de privacidad que la analítica de producto.

## Opciones

Usar Agencia360 para recibir categorías fijas, o usar Sentry como capturador con soporte para fallos nativos y simbolización. Las cuentas, la configuración de privacidad y el registro de símbolos de Sentry requieren validación antes de activar el SDK.

## Decisión

Usar la API de Agencia360 para contar errores de Flutter y del aislado principal con consentimiento activo. El reporte envía una categoría fija, como máximo una vez cada cinco segundos por categoría durante el proceso. Conserva el comportamiento de los manejadores de Flutter. El panel recibe totales diarios y las compilaciones de distribución guardan sus símbolos Dart como artefactos por plataforma y número de build.

## Consecuencias

Para fallos que terminan el proceso antes de poder enviar el reporte, se propone Sentry como proveedor de crashes de Flutter y nativos. Para completar esa parte hace falta configurar el proyecto, revisar qué datos salen de la app, vincular sus símbolos y probar un crash real en Android e iOS. El build y la API actuales pueden verificar la capa de diagnóstico de Agencia360 por separado. [Archivos de depuración de Sentry](https://docs.sentry.io/api/projects/list-a-projects-debug-information-files/) · [Símbolos de Flutter](https://docs.flutter.dev/deployment/obfuscate)
