# 0002 · Estado e inyección de dependencias con Riverpod

**Estado:** Aceptada

## Contexto

La v1 usa `ChangeNotifier` y pasa dependencias a mano. Funcionó para 10 pantallas. La v2 suma datos en vivo (SSE, WebSocket), caché local, cola sin conexión, muchos módulos que comparten sesión y API, y pruebas por criterio que necesitan sustituir dependencias fácilmente.

## Opciones

1. Seguir con `ChangeNotifier` + inyección manual.
2. Riverpod (con generación de código).
3. Bloc/Cubit.

## Decisión

Opción 2: Riverpod. Resuelve estado asíncrono (`AsyncValue` = cargando/datos/error, que encaja con la regla de los cinco estados), inyección y sustitución en pruebas con una sola herramienta, sin depender del árbol de widgets.

## Consecuencias

- Una dependencia más (y `build_runner` si se usa generación).
- Curva de aprendizaje: guía corta en `plan/arquitectura-v2.md` y un módulo de ejemplo en T01.02.
- El `ControladorSesion` v1 se envuelve en un proveedor durante la migración.
