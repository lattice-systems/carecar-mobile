# M26 · Valuación y toma a cuenta avanzada

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Cristian |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 22. Valuación formal |
| Estado | Listo para historias |

## Propósito

Pasar de la estimación no vinculante a una **valuación formal**: el cliente sube fotos guiadas, agenda inspección y recibe una oferta de la agencia. Mueve O5.

## Pantallas

- **Mis valuaciones** (`/valuaciones`): lista de la más reciente a la más antigua con auto, estado y, si hay, oferta y vigencia. Abre el detalle. Vacío con acceso a «Mis estimaciones».
- **Detalle** (`/valuaciones/{id}`): el auto, el rango estimado con la leyenda no vinculante, el avance en tres pasos (fotos «N de 8», inspección y oferta), las fotos subidas (`GaleriaFotos`), la cita y el asesor cuando ya lo hay. Con oferta vigente muestra el monto, la vigencia y la nota, y deja aceptar (`DeslizarParaConfirmar`) o rechazar (con `Dialogo` de confirmación).
- **Fotos guiadas** (`/valuaciones/{id}/fotos`): las 8 tomas en orden. Cada una con su silueta, una instrucción corta, la foto ya subida si existe y las acciones «Tomar foto» y «Elegir de la galería».
- **Agendar inspección** (`/valuaciones/{id}/cita`): «Día» (`Calendario`) y «Horario» (`SelectorFranja`) con la disponibilidad del taller, como al agendar una campaña, y el cierre con `ResultadoPantalla`.
- **Valor de mi auto** (`/valuaciones/valor/{vehiculoId}`): `Grafica` de líneas con el valor estimado medio por mes y debajo el rango de cada mes.

Entradas: «Pedir valuación formal» en el resultado de la calculadora y en el detalle de una estimación guardada, «Mis valuaciones» desde «Mis estimaciones», y «Ver cómo cambia el valor» desde el detalle de una estimación hecha con un vehículo y desde el detalle de la valuación. Todas están en pantallas de `catalogo` (M03) y de este módulo.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `valuacion` ➕ | id, estimacion_toma_cuenta_id, cliente_id, fotos (json), cita_id, oferta, vigencia_hasta, estado, vehiculo_cliente_id, prospecto_id, oferta_nota, ofertada_por, ofertada_en, respondida_en, created_at, updated_at | La oferta sí es formal (a diferencia de la estimación de M03). Los primeros ocho campos son los de la ficha y el plan, y los demás son agregados. Una sola abierta por cliente y vehículo. |
| `estimacion_toma_cuenta` (existe) | — | De ahí salen el auto y el rango. La gráfica de V2-M26.05 se arma con ellas, sin tabla nueva. |
| `cita` (existe) | — | La inspección usa la agenda con `motivo` `VALUACION`. |
| `prospecto` (existe) | — | Se reutiliza el prospecto abierto de M16 o se crea uno con origen `APP`. |

El diseño técnico (tipos, checks, índices, migración, eventos y seguridad) está en `agencia-360-backend/plan/historias-backend.md`, sección M26.

## Reglas

- **Estados:** `SOLICITADA` → `CITA_AGENDADA` → `OFERTADA` → `ACEPTADA` o `RECHAZADA`. Una oferta sin respuesta pasa a `VENCIDA` y la agencia puede renovarla. Si la cita se cancela, la valuación vuelve a `SOLICITADA`. Los calcula el servidor y la app no los deduce. Ofrece «Agendar inspección» solo cuando `puedeAgendar` es verdadero.
- **Vehículo registrado:** solo se valúa una estimación hecha con uno de los vehículos del cliente, porque la cita necesita un vehículo.
- **Fotos:** se puede agendar sin las 8 y la oferta no las exige. La oferta formal sale de la inspección física.
- **Oferta (ERP y CRM congelados):** la captura el personal de ventas con los endpoints protegidos `/api/v1/valuaciones`, fuera del contrato de la app. No hay pantalla web.
- **Propuestas pendientes del PO** (configurables en `app.valuacion.*`): la oferta vale 7 días, se puede capturar hasta con 30 y, si el cliente no llegó a la inspección, puede reagendar pasados 7 días sin oferta.

## API (`/api/v1/app`)

Contrato 2.19.0, etiqueta `Valuación`. Todas responden además 401, 403 `CUENTA_DESACTIVADA` y 404 en lo ajeno.

| Método | Ruta | Uso | Errores propios |
| --- | --- | --- | --- |
| POST | `/valuaciones` | `{estimacionTomaCuentaId}`. 201, o 200 con la abierta de ese vehículo (V2-M26.01). | 400 · 404 · 422 `VALUACION_SIN_VEHICULO` |
| GET | `/valuaciones` | Mis valuaciones, paginadas. | 400 |
| GET | `/valuaciones/{valuacionId}` | Detalle con fotos, cita, oferta y asesor. | 404 |
| POST | `/valuaciones/{valuacionId}/fotos/{toma}` | Multipart `imagen`, JPEG o PNG de hasta 8 MB. Reemplaza la toma (V2-M26.02). | 400 · 404 · 409 `VALUACION_CERRADA` |
| POST | `/valuaciones/{valuacionId}/cita` | `{franjaId, fecha}`. 201 con la cita de motivo `valuacion` (V2-M26.03). | 400 · 404 · 409 `VALUACION_NO_AGENDABLE`, `FRANJA_SIN_CUPO` o `CITA_DUPLICADA` |
| POST | `/valuaciones/{valuacionId}/respuesta` | `{aceptada, monto}` (V2-M26.04). | 400 · 404 · 409 `OFERTA_VENCIDA` u `OFERTA_NO_DISPONIBLE` |
| GET | `/vehiculos/{vehiculoId}/valor-estimado` | `meses` de 1 a 36, 12 por omisión (V2-M26.05). | 400 · 404 |
| GET | `/eventos` | Aviso en vivo `valuacion.oferta` con `valuacionId`, `vehiculoId` y `vigenciaHasta`, sin monto. | — |

Los cinco códigos nuevos todavía no están en el enum de `Problema.codigo`: las pruebas de contrato de los dos repos exigen que ese enum sea igual al código que existe. **El primer commit de código del backend** los agrega a `CodigosError` y al enum y sube el contrato a 2.19.1. La app copia esa versión en el mismo commit en que agrega los valores a `CodigoProblema`. Mientras tanto, el simulador ya los manda y la app los lee como `desconocido`.

## Historias

Cada criterio se comprueba con una prueba automática.

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M26.01 | Como cliente quiero pedir una valuación formal desde mi estimación para saber cuánto me ofrece de verdad la agencia | **Dado** una estimación mía hecha con un vehículo, **cuando** toco «Pedir valuación formal», **entonces** se crea en `SOLICITADA` ligada a esa estimación y abre su detalle. **Dado** que ese vehículo ya tiene una abierta, **cuando** la pido otra vez, **entonces** abre la existente sin crear otra. **Dado** una estimación capturada a mano, **entonces** se explica que se pide en la agencia (422) y no se crea. **Dado** una estimación ajena, **entonces** 404. «Mis valuaciones» las lista con estado y resuelve cargando, datos, vacío, error y sin conexión | ✅ | V2-M03.07 |
| V2-M26.02 | Como cliente quiero subir fotos guiadas de mi auto para que la agencia lo conozca antes de la inspección | **Dado** una valuación que admite cambios, **cuando** abro las fotos, **entonces** veo las 8 tomas (frente, trasera, dos laterales, interior delantero y trasero, tablero con el kilometraje y cajuela), cada una con silueta e instrucción, y «N de 8». **Cuando** tomo o elijo una foto, **entonces** se sube sola esa toma y se puede repetir. **Si** falla la subida, la foto se conserva en pantalla con «Reintentar» y las demás no se pierden. **Sin** permiso de cámara, se explica y se abren los ajustes. **Dado** una valuación cerrada, **entonces** no hay acciones para subir (409). El servidor guarda la foto sin EXIF y la entrega solo con URL firmada | ✅ | V2-M26.01 |
| V2-M26.03 | Como cliente quiero agendar la inspección física para que revisen mi auto y me hagan una oferta | **Dado** una valuación que se puede agendar, **cuando** elijo día y horario y confirmo, **entonces** nace una cita con motivo `valuacion`, la valuación pasa a `CITA_AGENDADA` y la cita sale en «Mis citas». **Los** 409 `FRANJA_SIN_CUPO`, `CITA_DUPLICADA` y `VALUACION_NO_AGENDABLE` se explican sin perder lo elegido. **Dado** que cancelo la cita, **entonces** la valuación vuelve a «por agendar». **Dado** que reprogramo la cita, **entonces** el detalle muestra la nueva fecha | ✅ | V2-M26.01, V2-M02.08 |
| V2-M26.04 | Como cliente quiero recibir la oferta y aceptarla o rechazarla para decidir si dejo mi auto a cuenta | **Dado** una inspección hecha, **cuando** ventas captura la oferta, **entonces** me llega `valuacion.oferta` y el detalle muestra monto, vigencia y nota sin recargar a mano. **Dado** una oferta vigente (incluido su último día), **cuando** deslizo para aceptar o confirmo que rechazo, **entonces** queda `ACEPTADA` o `RECHAZADA` una sola vez. **Dado** una oferta vencida, **entonces** se ve «Vencida» sin acciones y el 409 `OFERTA_VENCIDA` se explica. **Dado** que la oferta cambió con la pantalla abierta, **entonces** no se registra nada (409 `OFERTA_NO_DISPONIBLE`) y se vuelve a cargar. La valuación queda ligada al prospecto abierto de M16 o a uno nuevo de origen `APP`, y el detalle nombra al asesor cuando ya lo hay. La etapa del prospecto no cambia sola | ✅ | V2-M26.03 |
| V2-M26.05 | Como cliente quiero ver cómo cambia el valor de mi auto con el tiempo para elegir cuándo cambiarlo | **Dado** estimaciones guardadas de mi vehículo en varios meses, **cuando** abro «Valor de mi auto», **entonces** veo un punto por mes con el valor medio de la última estimación de ese mes, la tabla accesible de la gráfica y el rango de cada mes. Los meses sin estimación no se inventan. **Dado** un solo mes, **entonces** se muestra su valor y se explica que la tendencia aparece al estimar en otros meses. **Dado** ninguno, **entonces** vacío con acceso a la calculadora. La leyenda «Estimación no vinculante» está siempre visible. Resuelve los cinco estados | ✅ | V2-M03.04 |

## Diseño de la app

Módulo nuevo en `lib/modulos/valuacion/`, sin interruptor v1/v2. Sus rutas se registran con una línea en `lib/nucleo/navegacion/registro_de_rutas.dart` y otros módulos solo importan `valuacion.dart`.

- **Dominio:** `RepositorioValuacion` (pedir, listar, una, subir foto, agendar, responder, valor estimado), `Valuacion`, `EstadoValuacion`, `TomaValuacion` (el orden de las 8), `OfertaValuacion`, `InspeccionValuacion`, `PuntoValorEstimado` y fallos propios por código. `valuacion` no importa `catalogo`: el resumen de la estimación que trae `Valuacion` es una clase suya, porque `catalogo` sí importará `valuacion.dart` para sus botones y habría un ciclo.
- **Datos:** `repositorio_valuacion_api.dart` y `repositorio_valuacion_fake.dart` (con fallo a pedido). La foto usa `ClienteApi.enviarArchivo` con `imagen` como nombre del campo y sin campos de texto, así que el cliente HTTP no cambia.
- **Citas:** la pantalla de inspección usa de `citas.dart` `disponibilidadProvider`, `FranjaDisponible` y `rutaMisCitas`, y al agendar invalida `misCitasProvider` y `disponibilidadProvider`. El módulo `citas` no se toca. Su enum `MotivoCita` no conoce `valuacion` y deja el motivo nulo sin fallar. Mostrar «Valuación» en «Mis citas» (sin ofrecerlo como motivo al agendar) es un PR chico aparte para Juan Pablo.
- **Fotos:** `SelectorFoto` del núcleo (`lib/nucleo/camara/`) con un proveedor propio, `selectorValuacionProvider`. Ya reduce a 1600 px y borra el temporal. La app no guarda las fotos en el teléfono ni las registra en bitácoras. No hay cola sin conexión (M21).
- **Silueta de cada toma:** `image_picker` abre la cámara del sistema y no permite dibujar encima, así que la silueta y la instrucción se ven **antes** de abrirla. Es una ilustración propia de este dominio (`silueta_toma.dart`, trazos con tokens), no un componente reutilizable del sistema de diseño. Los laterales reutilizan `SiluetaAuto` (el izquierdo en espejo). No lleva golden ni se exporta. No se agrega el paquete `camera`.
- **Componentes:** todos existen (`MarcoPantalla`, `TarjetaResumen`, `LineaDeTiempo`, `GaleriaFotos`, `Calendario`, `SelectorFranja`, `DeslizarParaConfirmar`, `Dialogo`, `ResultadoPantalla`, `Grafica`, estados y esqueletos). No hace falta historia T02 ni provisional.
- **Gráfica:** `Grafica` de líneas, un `PuntoGrafica` por mes con `medio` y `formatoValor` en pesos. Admite una sola serie, así que el rango va en una lista debajo.
- **En vivo:** lista y detalle se vuelven a pedir con `valuacion.oferta` y al volver la conexión, sin pasar por carga, como en M10.
- **Textos:** claves `valuacion*` en `app_es.arb` y `app_en.arb`, en orden. La leyenda no vinculante reutiliza el texto de la calculadora.
- **Pruebas:** `test/modulos/valuacion/` (repositorio API y fake, cada pantalla con sus estados, en vivo y rutas, en claro, oscuro y letra al 200 %, con guías de accesibilidad) y `test/contrato/contrato_valuacion_test.dart` (versión 2.19.0 o posterior, esquemas, operaciones, las 8 tomas, los estados y el motivo `valuacion`).
- **Simulador:** `mock_api/modulos/valuacion.js` con `semillas/valuacion.json`, una línea en `server.js` y sus filas en `mock_api/README.md`. Lee `estimacionesTomaCuenta`, crea la cita con las mismas reglas de cupo que `garantia.js`, lee el multipart a mano como `asistente.js`, sirve una imagen de prueba en `/api/v1/archivos/valuacion-fotos/{id}` y calcula `valor-estimado` desde las estimaciones guardadas. Emisor `POST /__mock/valuaciones/{id}/oferta` `{monto, vigenciaHasta?, nota?}`: acepta cualquier valuación con cita (sin esperar la fecha), la renueva y emite `valuacion.oferta`. La semilla trae una valuación ofertada y estimaciones del March en varios meses para la gráfica.

## Reparto para trabajar en paralelo

| Quién | Archivos |
| --- | --- |
| Backend | `agencia-360-backend`: `carecarapp/{domain,application,infrastructure,web}` de la valuación, `MotivoCita` y la validación de `AgendaAppController`, `LimpiadorImagen`, `AnonimizadorDeCuentaJdbc`, `ExportadorDeDatosJdbc`, el escucha y `ConsultaProspectos` en `ventascrm`, `shared/eventos`, `CodigosError`, la migración, `application.properties` (`app.valuacion.*`), `src/test/`, `docs/api/`, `README.md`, `scripts/` y `plan/historias-backend.md` |
| App | `carecar-mobile`: `lib/modulos/valuacion/**`, `test/modulos/valuacion/**`, `test/contrato/contrato_valuacion_test.dart`, `mock_api/modulos/valuacion.js`, `mock_api/semillas/valuacion.json`, los botones en `lib/modulos/catalogo/presentacion/` con sus pruebas, y en archivos calientes solo lo suyo: `mock_api/server.js`, `mock_api/README.md`, `registro_de_rutas.dart`, `lib/l10n/` (ARB y generados), `lib/api/modelos/problema.dart` y `api/` |

El único punto de cruce es el contrato. Solo el implementador del backend lo edita. La app lo copia.

PR sugeridos en la app: (1) módulo, solicitud, lista, detalle y simulador, (2) fotos guiadas, (3) inspección y oferta, (4) valor en el tiempo.

## Fuera de alcance / notas

- No hay pantalla en el ERP ni en el CRM web. El vendedor tampoco ve la valuación en el CRM: la consulta con `GET /api/v1/valuaciones`.
- El cliente no puede cancelar una valuación ni borrar fotos: las fotos se reemplazan y una solicitud abierta se retoma. Si hace falta, es una historia nueva.
- La oferta no se paga ni se aplica sola a la compra: aceptar solo registra la decisión.
- El push con la app cerrada llega con V2-M06.07.
- `valor-estimado` solo muestra meses con estimación guardada. Un registro automático cada mes sería una historia nueva.
- **Pendiente del PO:** los valores reales de `parametro_toma_cuenta`. Sin ellos toda estimación responde 422 en el backend real, así que no hay valuación ni gráfica fuera del simulador y de datos capturados por SQL.
- **Pendiente del PO:** confirmar los plazos propuestos, el texto que acompaña a la oferta (alcance legal de «formal») y si un auto capturado a mano debe poder valuarse.
- **Pendiente del PO y de M22:** confirmar que el aviso de privacidad cubre las fotos del vehículo, que muestran placas, y cuánto tiempo se conservan. Hoy se borran al cancelar la cuenta.

## Avance de V2-M26.01 a V2-M26.05

La app está construida contra `mock_api`. El módulo vive en `lib/modulos/valuacion/` (`dominio/`, `datos/`, `presentacion/`) y su contrato público es `valuacion.dart`. No importa `catalogo`. Es nuevo en v2: sus rutas se registran sin interruptor v1/v2.

- **Solicitud, lista y detalle (V2-M26.01):** `BotonPedirValuacion` está en el resultado de la calculadora y en la hoja de una estimación guardada. «Mis estimaciones» abre «Mis valuaciones» desde su barra. `VALUACION_SIN_VEHICULO` se explica sin salir de la pantalla. La lista se pide por páginas.
- **Fotos guiadas (V2-M26.02):** las 8 tomas con su silueta, instrucción, «Tomar foto» y «Elegir de la galería». Cada subida se guarda por toma en memoria. De dos subidas a la vez queda de cada toma la más reciente. Sin permiso, el aviso y «Abrir ajustes» van en la barra inferior para que se vean aunque la lista esté desplazada. Un 400 o un 413 por tamaño se explican y conservan la foto.
- **Orientación de la foto:** el servidor borra el EXIF sin aplicar la orientación. En Android, `image_picker` reduce la foto sin girar los píxeles y solo copia la marca (`ImageResizer.java`), así que `datos/enderezar_foto.dart` la manda ya girada. `dart:ui` solo escribe PNG: una foto girada viaja como PNG, que pesa más que el JPEG. Una foto que ya viene derecha no se toca.
- **Inspección (V2-M26.03):** «Agendar inspección» solo sale con `puedeAgendar`. Al agendar se vuelven a pedir «Mis citas», la disponibilidad, la lista y el detalle. Al volver de «Mis citas» el detalle se recarga, así refleja una cancelación o un cambio de fecha.
- **Oferta (V2-M26.04):** monto, vigencia y nota, con `DeslizarParaConfirmar` para aceptar y `Dialogo` para rechazar. Con `OFERTA_VENCIDA` u `OFERTA_NO_DISPONIBLE` se explica y se vuelve a cargar. Lista y detalle se actualizan con `valuacion.oferta` y al volver la conexión.
- **Valor en el tiempo (V2-M26.05):** gráfica de líneas con su tabla y la lista de rangos. Con un solo mes se muestra la cifra en lugar de la gráfica. La leyenda no vinculante está en los cinco estados.

La copia de `api/` es la 2.20.0. El backend sumó la valuación sobre su `main`, que ya traía M12 con el número 2.19.0. Por eso la copia también trae las rutas de lealtad, y sus cuatro códigos están en `CodigoProblema` sin pantallas todavía.

Ajustes respecto del diseño:

- La estimación de `catalogo` ahora guarda `vehiculoId` en su dominio y su repositorio. Sin él, una estimación guardada no puede abrir «Ver cómo cambia el valor».
- Los accesos a «Mis estimaciones» y a la calculadora desde los estados vacíos usan rutas escritas en `valuacion`, para no crear un ciclo. `test/modulos/valuacion/ruta_valuacion_test.dart` comprueba que coincidan con las de `catalogo`.
- El calendario de la inspección usa 12 de margen y no tiene relleno dentro de la tarjeta. Con el relleno de la pantalla de campañas, en un ancho de 360 cada día mide menos de 48 y no pasa la guía de zona táctil.
- El simulador suma sus estimaciones y la cita de la oferta desde `semillas/valuacion.json` sin editar las semillas de otros módulos. Si las franjas de `citas` ya pasaron, agrega tres futuras.

Pendientes:

- Integrar el backend y demostrar el flujo en celular, con cámara y galería reales. Hay que revisar en el celular que una foto vertical llegue derecha y cuánto pesa el PNG. Si pesa demasiado, escribir JPEG necesita un paquete y su PR de dependencias.
- Mostrar «Valuación» en «Mis citas» es un PR aparte del módulo `citas`.
- El simulador de `citas` todavía acepta `POST /citas` con motivo `valuacion`. El contrato pide responder 400.
