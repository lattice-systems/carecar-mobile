# M02 · Mis vehículos y postventa

| Campo | Valor |
| --- | --- |
| Hito | H2 |
| Dueño | Juan Pablo (garaje, manuales, citas) · Ricardo (historial, tickets) |
| Revisa | Cristian |
| Ficha técnica | ✅ Sección 2. Mis vehículos y postventa |
| Estado | Listo para historias |

## Propósito

El corazón de la app: el garaje del cliente, todo lo que se le ha hecho a cada auto y la forma más fácil de volver al taller. Mueve O1, O2 y O4.

## Pantallas

- **Garaje** — tarjetas grandes con foto del modelo/color, placas, km, próximo servicio y cita activa; deslizable si hay varios autos.
- **Detalle del vehículo** — encabezado con foto, VIN copiable, placas, año, km; pestañas: Resumen · Historial · Manuales · Ficha técnica.
- **Ficha técnica** — especificaciones por modelo y año en secciones plegables.
- **Manual** — visor PDF con índice, búsqueda, zoom, descarga y compartir; respaldo local si no hay red.
- **Historial** — línea de tiempo infinita (paginada) con filtro por año y tipo, total por orden.
- **Ticket** — desglose mano de obra + refacciones = total; PDF descargable y compartible.
- **Agendar cita** — elige vehículo → fecha (calendario con días llenos marcados) → franja con cupo → motivo → confirmar.
- **Mis citas** — próximas y pasadas con estado (confirmada, atendida, no asistió, cancelada); cancelar; agregar al calendario.
- **Comprobante de cita** — código QR para recepción en el taller.

## Datos

Tablas de la ficha: `vehiculo_cliente`, `manual`, `orden_servicio`, `orden_refaccion`, `franja_horario`, `cita` (ver alineación en T05). Extensiones:

| Tabla | Campos | Notas |
| --- | --- | --- |
| `cita` ➕ | motivo, comentario, codigo_qr | Motivo del servicio (mantenimiento, ruido, revisión…). |
| `ficha_tecnica_modelo` ➕ | id, modelo, anio, seccion, clave, valor | Especificaciones por modelo y año (hoy viven en la app). |
| `vehiculo_cliente` ➕ | color | Ya existe en el backend y en `GET /vehiculos`; la usan el garaje y el detalle. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/vehiculos` · `/vehiculos/{id}/manuales` | Existen. `/vehiculos` suma `kilometrajeActualizadoEn` (fecha `AAAA-MM-DD`, opcional, nula si no hay): fecha de cierre de la orden de servicio que dejó el km (V2-T05.06). Simulado en `mock_api`. |
| GET | `/vehiculos/{id}/ficha-tecnica` | Nuevo. |
| GET | `/vehiculos/{id}/servicios?pagina=&tamano=&anio=` | Existe con `pagina` y `tamano`; el filtro `anio` es nuevo. |
| GET | `/servicios/{id}` · `/servicios/{id}/ticket` | Detalle nuevo; ticket existe. |
| GET | `/agenda/disponibilidad?desde=&hasta=` | Existe; rango de fechas. |
| GET/POST | `/citas` · POST `/citas/{id}/cancelar` | Existen; POST suma `motivo` y el 409 por cita duplicada suma el código `CITA_DUPLICADA` (hoy responde sin código; el cupo lleno ya usa `FRANJA_SIN_CUPO`). |
| GET | `/citas/{id}/ticket` | Existe: PDF del comprobante con la foto del vehículo. V2-M02.11 le suma el QR firmado. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M02.01 | Como cliente quiero ver mi garaje con todos mis vehículos para elegir uno | Tarjeta por vehículo con modelo, año, placas, km · vacío explica que la agencia registra los autos al entregarlos · sin conexión muestra lo guardado | | V2-T01.02, V2-T02.05 |
| V2-M02.02 | Como cliente quiero el detalle de un vehículo para ver sus datos y kilometraje | VIN copiable · km "actualizado por el taller el <fecha de cierre>" · accesos a historial, manuales, ficha | | V2-M02.01, V2-T05.06 |
| V2-M02.03 | Como cliente quiero abrir el manual de mi modelo y año para consultarlo | Se asocia por modelo y año · índice, búsqueda, zoom · descarga y compartir · respaldo local (ver notas: búsqueda en el PDF) | | V2-M02.02 |
| V2-M02.04 | Como cliente quiero la ficha técnica de mi vehículo para conocer sus especificaciones | Datos desde la API por modelo/año · secciones plegables · respaldo local mientras el backend no los tenga | ✅ | V2-M02.02 |
| V2-M02.05 | Como cliente quiero el historial de servicios de mi auto para saber qué se le ha hecho | Paginación infinita · filtro por año · cada orden muestra fecha de cierre, estatus y total | ✅ | V2-T05.06, V2-T02.13 |
| V2-M02.06 | Como cliente quiero el ticket de cada servicio para revisar el cobro | Mano de obra + refacciones (cantidad × precio) = total · PDF descargable/compartible | | V2-M02.05 |
| V2-M02.07 | Como cliente quiero ver la disponibilidad del taller en un calendario para elegir día | Días sin cupo deshabilitados · cupo por franja y fecha según `franja_horario.capacidad` | | V2-T05.07, V2-T02.14 |
| V2-M02.08 | Como cliente quiero agendar una cita eligiendo vehículo, fecha, franja y motivo | Confirmación con resumen · 409 `FRANJA_SIN_CUPO` → ofrece franjas cercanas · 409 `CITA_DUPLICADA` → muestra la existente | ✅ | V2-M02.07 |
| V2-M02.09 | Como cliente quiero ver mis citas próximas y pasadas con su estado | Estados confirmada/atendida/no asistió/cancelada con color y texto · paginación | | V2-M02.08 |
| V2-M02.10 | Como cliente quiero cancelar una cita desde la app | Confirmación con diálogo · solo citas confirmadas futuras · libera el cupo | | V2-M02.09 |
| V2-M02.11 | Como cliente quiero un comprobante con QR de mi cita para recepción rápida | QR con id firmado en el PDF que ya entrega `/citas/{id}/ticket` · agregable a Wallet (M25) | ✅ | V2-M02.08 |
| V2-M02.12 | Como cliente quiero agregar la cita a mi calendario del teléfono | Evento con dirección del taller y recordatorio | | V2-M02.08, V2-M27.02 |
| V2-M02.13 | Como cliente quiero reprogramar una cita sin cancelarla | Elige nueva franja; la anterior se libera en la misma operación | ✅ | V2-M02.10 |

## Fuera de alcance / notas

- La orden de servicio la crea y cierra el taller desde el ERP (congelado); la app solo lee. El estado en vivo es M04.
- V2-T05.05 (`manual.archivo_pdf`) alinea la tabla `manual` con la ficha, pero es interna del backend: no bloquea a V2-M02.03.
- La dirección del taller para el evento de calendario (V2-M02.12) sale de las sucursales de M27 (V2-M27.02).
- Riesgo de V2-M02.03: el visor actual (`pdfx`) no busca texto dentro del PDF. Hay que elegir paquete o resolver la búsqueda antes de tomar la historia.

## Avance de V2-M02.01

El garaje vive en `lib/modulos/vehiculos/` y se abre en la ruta `/garaje` (exige sesión, como toda ruta de módulo; registrada con una línea en `registro_de_rutas.dart`). Sigue la estructura de la guía: `dominio/` con `VehiculoGaraje` y la interfaz `RepositorioGaraje` en Dart puro, `datos/` con `RepositorioGarajeApi` (lee `GET /vehiculos` de `CarecarApi`, nunca un cliente HTTP propio) y `RepositorioGarajeFake` (en memoria, con `fallar: true` para probar el error), y `presentacion/` con los proveedores Riverpod y `PantallaGaraje`.

- **Tarjeta por vehículo:** `TarjetaVehiculo` con el título ("Mazda CX-5 2024") y el detalle ("Placas ABC-123 · 12,500 km"). Sin placas dice "Sin placas"; sin kilometraje omite ese dato. El kilometraje se escribe con coma de millares también en español, igual que los precios del catálogo.
- **Vacío:** explica que la agencia registra los autos al entregarlos.
- **Sin conexión:** la API del núcleo (`CarecarApiConCache`) devuelve la última copia guardada de `GET /vehiculos`, así que el garaje se ve con lo guardado; solo si nunca hubo datos aparece el estado "Sin conexión" con reintento.
- **Estados:** cargando con esqueleto, datos, vacío, error con reintento y sin conexión, más recargar jalando hacia abajo. `V2-T01.08` no está integrada: se usó el patrón del módulo `ejemplo` y se pasará a las piezas comunes cuando llegue.
- **Pendiente:** la tarjeta aún no abre el detalle (V2-M02.02); ya lleva `heroTag`. La foto sigue siendo la silueta del sistema porque el contrato de vehículos no trae imagen. En `plan/cumplimiento-ficha.md` la fila "Mis vehículos (garaje)" sigue en 🟡 hasta demostrarla en celular con el backend real.

## Avance de V2-M02.07

Pantalla `PantallaDisponibilidad` en `lib/modulos/citas/` (ruta `/citas/disponibilidad`, exige sesión). Estado: **En revisión**.

- **Dominio** (`dominio/`): `DisponibilidadTaller` agrupa las franjas por día, descarta las sin cupo y responde `tieneCupo(dia)` y `franjasDe(dia)` (ordenadas por hora). `RepositorioCitas` es la interfaz.
- **Datos** (`datos/`): `RepositorioCitasApi` lee `GET /agenda/disponibilidad` por `carecarApiProvider`; `RepositorioCitasFake` genera franjas en memoria (lunes a viernes, sin cupo los días que terminan en 0 o 5) y falla a pedido con `error:`.
- **Presentación** (`presentacion/`): `Calendario` y `SelectorFranja` del sistema v2. Los días sin cupo (o fuera de hoy a 60 días) se tachan y el lector de pantalla dice «sin cupo»; al elegir un día salen sus franjas con los lugares que quedan. Cinco estados: esqueleto, datos, vacío (sin lugares en todo el rango), error con reintento y sin conexión; se recarga jalando hacia abajo.
- **Contrato**: no hizo falta cambiarlo. El endpoint solo devuelve franjas con `cupoDisponible > 0`, así que un día sin franjas es un día sin cupo; la capacidad de `franja_horario` se refleja como `cupoDisponible`. Cuando V2-T05.07 cree la tabla, la app solo cambia de URL.
- **Textos**: claves `citas*` en `lib/l10n/app_es.arb` y `app_en.arb`.
- **Pruebas**: `test/modulos/citas/` (dominio, repositorios, pantalla en claro, oscuro y letra al 200 %, y la ruta con y sin sesión).
- **Pendientes**: el `mock_api` tiene franjas con fechas ya pasadas (`2026-10-20`), así que contra él la pantalla muestra el estado vacío; hay que sembrar fechas relativas a hoy (T03). El golden de la pantalla espera a V2-T03.02. Cupo por franja en V2-M02.08 (elegir franja y agendar) usa estos mismos proveedores.

## Avance de V2-M02.02

El detalle vive en `lib/modulos/vehiculos/` (`PantallaDetalleVehiculo`, ruta `/garaje/:id`, exige sesión). Se llega tocando una tarjeta del garaje: la foto viaja con el `heroTag` que ya llevaba. Estado: **En revisión**.

- **Datos:** no hay `GET /vehiculos/{id}` en el contrato v1, así que `vehiculoProvider(id)` busca el vehículo en la misma lectura del garaje (comparte copia guardada y recarga). `VehiculoGaraje` suma `vin`, `color`, `version` y `kilometrajeActualizadoEn`.
- **VIN copiable:** en cifras (monoespaciado), con botón «Copiar VIN» (zona táctil de 48) y un `Aviso` «VIN copiado» que el lector de pantalla anuncia.
- **Kilometraje:** «12,500 km» y debajo «Actualizado por el taller el <fecha completa>». Sin fecha de cierre dice «Aún sin actualización del taller»; sin km dice «Sin kilometraje registrado». Nunca inventa la fecha.
- **Fecha de cierre (V2-T05.06, simulable):** el campo `kilometrajeActualizadoEn` se agregó a `GET /vehiculos` en `mock_api` (bloque de vehículos de `server.js` y semilla de los autos con km) y a la tabla API de arriba. Cuando Ricardo integre T05.06, la app solo cambia de URL; si el backend usa otro nombre o formato, se ajusta el DTO `Vehiculo`.
- **Accesos:** historial, manuales y ficha técnica se ven como filas deshabilitadas con «Disponible pronto» (el lector de pantalla dice «Manuales. Disponible pronto»), sin pantallas en blanco. **Falta conectarlos:** historial a V2-M02.05 (Ricardo), manuales a V2-M02.03 y ficha a V2-M02.04. Hasta entonces ese criterio está cumplido a medias: están visibles, no navegan.
- **Estados:** esqueleto, datos, vehículo no encontrado (estado vacío con explicación, también para un id que no es número), error con reintento y sin conexión (copia guardada de la API del núcleo, o aviso si nunca hubo datos); se recarga jalando hacia abajo.
- **Textos:** claves `vehiculos*` en `app_es.arb` y `app_en.arb`.
- **Pruebas:** `test/modulos/vehiculos/pantalla_detalle_test.dart` (datos, copiar con portapapeles simulado, fecha, accesos, cinco estados, inglés, claro/oscuro/letra al 200 %), `ruta_garaje_test.dart` (tarjeta abre el detalle, `/garaje/:id`, id inválido, sin sesión), `garaje_test.dart`, `modelos_test.dart` y `vehiculos_semilla_test.dart`.
- **Pendientes:** el golden de la pantalla espera a V2-T03.02; sin foto del auto (el contrato no la trae); `plan/cumplimiento-ficha.md` no cambia: la fila «Detalle del vehículo y kilometraje» sigue en 🟡 hasta que exista T05.06 con `orden_servicio` real.
