# M27 · Centro de ayuda y sucursales

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Haziel |
| Revisa | Juan Pablo |
| Ficha técnica | No |
| Estado | Listo para historias |

## Propósito

Resolver dudas sin llamar y saber dónde y cuándo está la agencia. Reemplaza los placeholders de contacto de v1. Mueve O7.

## Pantallas

- **Ayuda** — preguntas frecuentes por tema con buscador.
- **Sucursales** — mapa, dirección, horarios por departamento (ventas, servicio, refacciones), cómo llegar, llamar.
- **Contacto** — llamar, correo, chat (M07), reportar un problema de la app (con datos técnicos anónimos).
- **Acerca de** — versión real (desde el paquete), licencias, aviso de privacidad, términos.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `sucursal` ➕ | id, nombre, direccion, lat, lng, telefono, correo, horarios (json) | |
| `pregunta_frecuente` ➕ | id, tema, pregunta, respuesta, orden, activa | Editable por la agencia. |
| `reporte_app` ➕ | id, cuenta_app_id, descripcion, version_app, sistema, dispositivo, creado_en | Sin datos personales extra. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M27.01 | Como cliente quiero buscar en preguntas frecuentes | Búsqueda local · contenido desde backend con caché | ✅ | — |
| V2-M27.02 | Como cliente quiero ver sucursales en un mapa con horarios | "Abierto ahora" calculado · cómo llegar abre la app de mapas | ✅ | — |
| V2-M27.03 | Como cliente quiero contactar a la agencia por el medio que prefiera | Llamar, correo y chat | | V2-M27.02 |
| V2-M27.04 | Como cliente quiero reportar un problema de la app | Formulario con versión, sistema y equipo (sin datos personales extra) | ✅ | — |
| V2-M27.05 | Como cliente quiero ver la versión, licencias y términos | Versión desde `package_info_plus` · licencias de Flutter | | — |
