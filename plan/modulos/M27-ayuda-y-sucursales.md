# M27 · Centro de ayuda y sucursales

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Haziel |
| Revisa | Juan Pablo |
| Ficha técnica | ✅ Sección 23. Ayuda y sucursales |
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

## Avance

### V2-M27.02 · Sucursales con mapa y horarios (Juan Pablo por R6, aviso a Haziel) — en revisión

- **Backend** (rama `feat/v2-m27-02-sucursales`): migración `sucursal` (`lat`, `lng` y demás de la ficha, más `activa` y `orden`), sembrada con León, Gto. (21.1250, -101.6860); `GET /sucursales` en el contrato 2.27.0.
- **App**: módulo `lib/modulos/ayuda/` (`ayuda.dart` es el contrato), ruta `/sucursales`, pantalla con el componente `Mapa`, horarios por departamento, llamar (`tel:`) y cómo llegar (`geo:` en Android, Mapas de Apple en iPhone). Mock en `mock_api/modulos/sucursales.js`.
- **Decisiones**:
  - «Abierto ahora» lo calcula el **servidor** con la hora de la agencia (`America/Mexico_City`), no el teléfono.
  - Por eso `CarecarApiConCache` **no guarda** las sucursales: una copia vieja diría «abierto» con la agencia cerrada. Sin conexión se muestra el estado de error con reintento.
  - El componente `Mapa` admite un solo pin: se muestra la sucursal elegida y las demás se eligen en la lista. Un mapa con varios pines sería una historia nueva del sistema de diseño (`V2-T02.xx`, Borrador, no creada aquí).
  - Un departamento nuevo del backend se omite en la app hasta que se conozca.
- **Cómo se conectan las otras historias** (no se tocaron aquí): `sucursalPrincipalProvider` (exportado en `ayuda.dart`) da la sucursal principal. V2-M02.12 usa `direccion` en `BotonAgregarAlCalendario` (hoy `Agencia.direccion`, comentario `SUPUESTO`) y V2-M11.02 usa `telefono` en asistencia (hoy `Agencia.telefono`); ambos conservan el valor de `Agencia` como respaldo si la lectura falla o no hay sucursales.
- **Pendiente**: punto de entrada a la pantalla desde la UI (llega con V2-M27.03, contacto); probar en celular con teselas reales; alta y edición de sucursales desde el ERP (congelado, R9).
