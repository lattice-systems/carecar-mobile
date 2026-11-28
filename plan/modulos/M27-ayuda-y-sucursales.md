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

### V2-M27.02 · Sucursales con mapa y horarios (Juan Pablo por R6, aviso a Haziel) — hecha (#193, backend#115)

- **Backend** (rama `feat/v2-m27-02-sucursales`): migración `sucursal` (migración `V59`; `lat`, `lng` y demás de la ficha, más `activa` y `orden`), sembrada con León, Gto. (21.1250, -101.6860); `GET /sucursales` en el contrato 2.28.0.
- **App**: módulo `lib/modulos/ayuda/` (`ayuda.dart` es el contrato), ruta `/sucursales`, pantalla con el componente `Mapa`, horarios por departamento, llamar (`tel:`) y cómo llegar (`geo:` en Android, Mapas de Apple en iPhone). Mock en `mock_api/modulos/sucursales.js`.
- **Decisiones**:
  - «Abierto ahora» lo calcula el **servidor** con la hora de la agencia (`America/Mexico_City`), no el teléfono.
  - Por eso `CarecarApiConCache` **no guarda** las sucursales: una copia vieja diría «abierto» con la agencia cerrada. Sin conexión se muestra el estado de error con reintento.
  - El componente `Mapa` admite un solo pin: se muestra la sucursal elegida y las demás se eligen en la lista. Un mapa con varios pines sería una historia nueva del sistema de diseño (`V2-T02.xx`, Borrador, no creada aquí).
  - Un departamento nuevo del backend se omite en la app hasta que se conozca.
- **Cómo se conectan las otras historias**: ya conectadas con V2-M27.03 (abajo) mediante `contactoDeAgenciaProvider`; V2-M02.12 y V2-M11.02 dejaron de usar valores de ejemplo.
- **Revisión de diseño (V2-M27.03)**: se probó la pantalla a 320x568 con letra al 200 % en claro y oscuro, en pantalla ancha, desplazando hasta «Todas las sucursales» y con nombres y direcciones largos: sin desbordes ni títulos pisados, así que no hubo defecto que corregir (`test/modulos/ayuda/pantalla_sucursales_diseno_test.dart`). Observación para el sistema de diseño: el componente `Mapa` es interactivo y un arrastre vertical que empieza sobre el mapa lo mueve en vez de desplazar la lista; es del núcleo (`lib/nucleo/diseno/`) y no se tocó aquí.
- **Pendiente**: probar en celular con teselas reales; alta y edición de sucursales desde el ERP (congelado, R9).

### V2-M27.03 · Contactar a la agencia (Juan Pablo por R6, ayuda a Haziel; aviso a Haziel) — en revisión

- **Pantalla** `PantallaContacto` en `/contacto` (módulo `lib/modulos/ayuda/`, sesión obligatoria como el resto): encabezado grande con regreso, un `GrupoLista` «Medios de contacto» (llamar a la agencia con `tel:` y escribir un correo con `mailto:`, cada fila muestra el número o el correo) y un grupo «Dónde estamos» con una fila a `/sucursales` (nombre y dirección de la sucursal principal, `Insignia` «Abierto ahora» o «Cerrado»). Si el teléfono no puede abrir el marcador o la app de correo, un `Aviso` lo dice (en el caso del correo, con el correo para escribirlo a mano) y la pantalla sigue.
- **Datos** (`ContactoDeAgencia`, `contactoDeAgenciaProvider`, exportados en `ayuda.dart`): vienen de `sucursalPrincipalProvider`; lo que la sucursal no trae (teléfono o correo vacíos) y todo si la lectura falla, aún carga o no hay sucursales sale de `Agencia` (`lib/config/agencia.dart`). El proveedor nunca falla, así que quien lo use no necesita su propio respaldo. Los enlaces se abren con `abrirEnlaceDeSucursalProvider` (`url_launcher`, sustituible en pruebas).
- **Entrada desde la UI**: perfil → Ayuda. «Contactar a la agencia» abre `/contacto` (con enrutador; sin enrutador, la v1 suelta, queda la hoja de siempre con los datos de `Agencia`) y la fila nueva «Sucursales y horarios» abre `/sucursales`. Se eligió el perfil porque es donde ya viven «Contactar» y «Privacidad» (sección Ayuda), no obliga a tocar el menú ni el inicio y no compite con el flujo del taller; cuando exista la pantalla de Ayuda de V2-M27.01 (preguntas frecuentes), las dos filas se mueven ahí.
- **Conexiones**: V2-M02.12 (`BotonAgregarAlCalendario`, lugar del evento «Nombre, dirección») y V2-M11.02 (llamadas rápidas y atajo sin conexión de «Pedir ayuda») leen `contactoDeAgenciaProvider`.
- **Diseño verificado** (`test/modulos/ayuda/pantalla_contacto_test.dart`): claro, oscuro, letra al 200 % en 320x568 con textos largos sin excepción de desborde, pantalla ancha, desplazar hasta el final, título que se recoge al desplazar, textos del lector de pantalla e inglés.
- **Decisiones y supuestos**:
  - **Chat**: el criterio dice «Llamar, correo y chat»; el chat es V2-M07 (Borrador, sin pantalla ni backend). No se muestra una fila muerta: cuando exista V2-M07.01 se agrega como una fila más del primer grupo (el comentario de `PantallaContacto` lo dice). Es la parte del criterio que queda abierta.
  - **WhatsApp** no está en el criterio ni en la ficha: no se agregó.
  - **Sin conexión** el dato de la sucursal no está en el teléfono (V2-M27.02 decidió no guardar sucursales por «abierto ahora»): sin red ni sucursal leída antes en la sesión, se usa `Agencia`. Historia nueva sugerida (Borrador): guardar solo teléfono, correo y dirección de la sucursal principal (no el «abierto ahora») para que el atajo sin conexión de V2-M11.02 marque el número real aunque la app abra sin datos.
  - Mientras la sucursal carga se usa `Agencia`; si la sucursal llega después, las filas cambian solas.
  - **Antes de entregar** hay que reemplazar los valores de ejemplo de `Agencia` por los reales (siguen siendo el respaldo); `PantallaCuentaDesactivada` (módulo `acceso`) aún usa `Agencia` directo: se conectaría igual con `contactoDeAgenciaProvider` (sin sesión no hay sucursales, así que su valor real es el de `Agencia`).

### V2-M27.05 · Acerca de

Desde Ajustes, la fila CareCar abre la versión instalada, las licencias de Flutter, el aviso de privacidad y los términos incluidos en la aplicación. La pantalla de términos muestra el texto aprobado que se incluye en el paquete, con encabezados accesibles.

La [prueba de widget](../../test/modulos/ayuda/acerca_de_test.dart) comprueba la versión y las licencias. La [prueba de integración](../../integration_test/terminos_instalados_test.dart) comprueba también los términos del paquete. La [corrida física H4.2](../../docs/pruebas/evidencia.md#corrida-física-de-haziel-en-android) documenta su apertura en Android.
