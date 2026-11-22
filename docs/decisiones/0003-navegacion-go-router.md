# 0003 · Navegación declarativa con go_router

**Estado:** Aceptada

## Contexto

La v2 necesita deep links (enlace de recuperación de la ficha, notificaciones push, widgets, Wallet, accesos rápidos) y guardias de sesión (login, cambio obligatorio de contraseña). La v1 navega con `Navigator.push` imperativo.

## Opciones

1. `Navigator` imperativo (v1).
2. `go_router` (paquete mantenido por el equipo de Flutter).
3. `auto_route`.

## Decisión

Opción 2. Rutas por URL, redirecciones por estado de sesión, soporte de enlaces universales y pestañas con estado (`StatefulShellRoute`).

## Consecuencias

- Toda pantalla tiene una ruta y es alcanzable por enlace (probado en T01.03).
- Configurar `assetlinks.json` y `apple-app-site-association` en el dominio de la agencia.
