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
