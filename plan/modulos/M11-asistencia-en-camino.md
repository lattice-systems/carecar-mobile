# M11 · Asistencia en camino (SOS)

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Juan Pablo |
| Revisa | Jael |
| Ficha técnica | ✅ Sección 11. Asistencia en camino |
| Estado | Listo para historias |

## Propósito

Ayuda inmediata cuando el auto falla en la calle: un botón que comparte ubicación, vehículo y problema con la agencia o la aseguradora. Mueve O4.

## Pantallas

- **SOS** — botón grande con confirmación por deslizamiento; tipo de problema (llanta, batería, choque, sin gasolina, otro).
- **Seguimiento** — estado de la solicitud, contacto, ubicación compartida.
- **Contactos de emergencia** — aseguradora (desde M09), agencia, grúa, 911.
- **Guías rápidas** — cambiar llanta, pasar corriente, qué hacer en un choque (sin conexión).

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `solicitud_asistencia` ➕ | id, cliente_id, vehiculo_cliente_id, tipo, lat, lng, comentario, estado, creada_en | Ubicación solo mientras dure. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| POST | `/asistencia` | Crear solicitud (vehículo propio, tipo, ubicación opcional, comentario). Responde 201 con estado `recibida`. |
| GET | `/asistencia/{id}` | Estado de la solicitud del cliente; 404 si no es suya. |
| GET | `/asistencia?activa=true` | La solicitud abierta, para retomarla al volver a la app. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M11.01 | Como cliente varado quiero pedir ayuda compartiendo mi ubicación para que la agencia me atienda rápido | Dado que tengo un vehículo, cuando deslizo para confirmar y elijo el tipo (llanta, batería, choque, sin gasolina, otro), entonces se crea la solicitud con vehículo, tipo y ubicación y veo el folio · si niego el permiso de ubicación, puedo escribir dónde estoy · sin conexión, aviso y atajo a llamar (V2-M11.02) | ✅ | V2-M02.01, V2-T02.11 |
| V2-M11.02 | Como cliente quiero llamar con un toque a mi aseguradora o a la agencia para pedir ayuda aunque no tenga datos | Botones para la aseguradora (M09), la agencia (M27) y el 911 · un toque abre el marcador con el número · si no hay aseguradora registrada, el botón explica cómo agregarla | | V2-M09.01, V2-M27.02 |
| V2-M11.03 | Como cliente quiero guías de emergencia sin conexión para saber qué hacer mientras llega la ayuda | Guías de cambiar llanta, pasar corriente y qué hacer en un choque empaquetadas en la app · se abren en modo avión · el lector de pantalla las lee en orden | | — |
| V2-M11.04 | Como cliente quiero ver el estado de mi solicitud para saber cuándo llega la ayuda | Estados `recibida` → `en_camino` → `atendida` (o `cancelada`) en una línea de tiempo · push en cada cambio (M06) · la ubicación deja de compartirse al quedar atendida o cancelada | ✅ | V2-M11.01, V2-M06.02, V2-T02.13 |

## Fuera de alcance / notas

- Mientras el ERP siga congelado, el personal cambia el estado de la solicitud con un endpoint interno del backend (pruebas y datos de ejemplo); la pantalla del personal queda fuera de alcance.
- La ubicación solo se envía al crear la solicitud y mientras esté abierta; nunca en segundo plano después.

## Avance de V2-M11.03

**Qué quedó**

- Módulo `lib/modulos/asistencia/` con contrato `asistencia.dart`. Dominio puro (`TipoGuia`, `GuiaEmergencia`, `guiasDeEmergencia`): tres guías (cambiar llanta, 5 pasos; pasar corriente, 6; qué hacer en un choque, 6).
- Pantallas `PantallaGuias` (lista) y `PantallaGuia` (pasos numerados). Usan `FilaLista` y `Aviso` del sistema v2 y los tokens de `TokensPista`; sin colores ni medidas sueltas.
- Rutas `/asistencia/guias` y `/asistencia/guias/:tipo` (`llanta`, `corriente`, `choque`), registradas en `registro_de_rutas.dart` con una línea. Una guía inexistente vuelve a la lista. Exigen sesión como el resto de las rutas de módulo.
- Textos en `lib/l10n/` (prefijo `asistencia`, es y en). Las guías viven en el ARB empaquetado en la app: no hacen peticiones y se abren en modo avión.
- Accesibilidad: cada paso es un nodo semántico ("Paso 2 de 5" y su texto) con orden explícito, y se arman todos a la vez para que el lector de pantalla tenga la guía completa. Probado con letra al 200 %.
- `rutaSos` (constante en `asistencia.dart`) apunta a la lista de guías mientras no exista V2-M11.01; la usa V2-M25.04.

**Estados:** al ser contenido empaquetado no hay carga, vacío ni error de red. Lo que sí aplica (datos y sin conexión) se resuelve por construcción: la guía siempre está y el aviso lo dice.

**Pendiente / fuera de alcance**

- V2-M11.01, V2-M11.02 y V2-M11.04 siguen sin empezar. Cuando exista la pantalla SOS, `rutaSos` debe apuntar a ella y las guías quedan como destino de "Guías rápidas".
- Los pasos son texto; si Diseño pide ilustraciones se agregan como assets en una historia aparte.
- Queda por revisar con una persona de la agencia que los pasos de choque y corriente sean los que quieren dar a sus clientes.

## Avance de rediseño (estilo portada)

Rediseño visual de `PantallaGuias` y `PantallaGuia` (V2-M11.03) según el estilo portada del sistema de diseño v2 (§8). No cambian lógica, rutas ni criterios de aceptación; solo la presentación y textos nuevos.

**Lista (`/asistencia/guias`)**

- Título grande «Emergencias» con `EncabezadoGrande(translucido: true)`.
- Tarjeta héroe «¿Necesitas ayuda ahora?» (tinte `peligro`, ícono SOS grande). Su `BotonPildora` «Pedir ayuda» queda **deshabilitado** y el texto explica que llegará pronto; se activa cuando exista V2-M11.01 (hoy `rutaSos` ya apunta a esta lista).
- `Aviso` discreto «funciona sin conexión».
- `Estante` «Guías rápidas» con las tres guías como portadas: ícono grande (64) sobre el color de la guía (llanta `acento`, corriente `advertencia`, choque `peligro`) y su número de pasos. Cada portada es un solo nodo táctil con etiqueta «título, N pasos».
- `GrupoLista` «Todas las guías» con las mismas guías (ícono en cuadro de color, «N pasos», chevron). No hay duración por guía en el dominio, solo número de pasos.

**Guía (`/asistencia/guias/:tipo`)**

- `CabeceraPortada` con el ícono grande de la guía y su tinte, título y subtítulo «N pasos · sin conexión»; la barra superior es transparente solo con el botón de regreso.
- Pasos como lista numerada grande: número en círculo de color, «Paso N de M» en negrita y el texto con aire. Un nodo semántico por paso con `OrdinalSortKey`, como antes; el círculo se excluye de la semántica.
- La píldora «Llamar a la agencia» se **omitió**: no hay acción disponible hasta V2-M11.02 / M27.02.

**Código:** `estilo_guias.dart` (ícono y color por guía, compartidos), claves ARB `asistenciaListaTitulo`, `asistenciaHeroe*`, `asistenciaEstanteGuias`, `asistenciaGrupoGuias`, `asistenciaGuiaCantidadPasos`, `asistenciaGuiaSubtituloSinConexion` (es y en). Pruebas de `test/modulos/asistencia/ruta_guias_test.dart` actualizadas (los títulos aparecen en estante y lista) y ampliadas (héroe explicado, portada abre la guía, lista y guía al 200 % sin desbordes).

**Pendiente:** al integrar V2-M11.01 activar el botón del héroe; con V2-M11.02 agregar la píldora «Llamar a la agencia» en la guía; goldens de las dos pantallas si se piden.
