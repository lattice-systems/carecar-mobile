# M17 · Recolección y entrega a domicilio

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Juan Pablo |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 17. Recolección y entrega a domicilio |
| Estado | Listo para historias |

## Propósito

Que el cliente no tenga que llevar su auto: la agencia lo recoge y lo devuelve. Mueve O2 y O5.

## Pantallas

- **Opción al agendar** — "Recoger en mi domicilio" con dirección, horario y costo.
- **Direcciones** — guardadas con mapa.
- **Seguimiento del chofer** — en camino, recogido, en taller, de regreso, entregado; ubicación del chofer en mapa.
- **Checklist de entrega** — fotos del auto al recoger/entregar, km, gasolina, firma.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `direccion_cliente` ➕ | id, cliente_id, alias, calle, colonia, cp, ciudad, lat, lng | |
| `traslado` ➕ | id, cita_id, direccion_cliente_id, tipo (recoger/entregar), chofer_id, estado, costo | |
| `checklist_traslado` ➕ | id, traslado_id, km, gasolina, fotos (json), firma_url | |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET/POST | `/direcciones` | Listar y guardar direcciones; 422 si queda fuera de la zona de cobertura. |
| PUT/DELETE | `/direcciones/{id}` | Editar y borrar (solo las propias). |
| GET | `/recoleccion/cotizacion?direccionId=&fecha=` | Costo y franja de recolección para esa dirección y fecha. |
| POST | `/citas` | Suma `recoleccion: { direccionId }` y crea los `traslado` de recoger y entregar ligados a la cita. |
| GET | `/traslados/{id}` | Estado y, solo en `en_camino` o `de_regreso`, la ubicación del chofer. |
| GET | `/traslados/{id}/checklist` | Fotos (URL firmadas), km, gasolina y firma al recoger y al entregar. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M17.01 | Como cliente quiero guardar mis direcciones para pedir recolección sin escribirlas cada vez | Alta con alias, calle, colonia, CP y ciudad, y pin en el mapa · si queda fuera de la zona de cobertura se avisa antes de guardar · editar y borrar · solo veo las mías | ✅ | V2-T02.09 |
| V2-M17.02 | Como cliente quiero pedir que recojan mi auto al agendar para no tener que llevarlo | En la confirmación de la cita, opción "Recoger en mi domicilio" con una dirección guardada · costo y franja visibles antes de confirmar · se crean los traslados de recoger y entregar ligados a la cita · fuera de cobertura la opción no aparece | ✅ | V2-M02.08, V2-M17.01 |
| V2-M17.03 | Como cliente quiero seguir al chofer para saber cuándo llega | Estados `en_camino`, `recogido`, `en_taller`, `de_regreso`, `entregado` en una línea de tiempo con push · el mapa con el chofer solo aparece en `en_camino` y `de_regreso` | ✅ | V2-M17.02, V2-M06.02, V2-T02.09, V2-T02.13 |
| V2-M17.04 | Como cliente quiero ver el checklist con fotos del estado de mi auto para comprobar cómo lo recogieron y cómo me lo entregaron | Al recoger y al entregar: fotos, km, gasolina y firma · el cliente compara ambas entregas · fotos servidas con URL firmada de vida corta | ✅ | V2-M17.03, V2-T05.09, V2-T02.12 |
| V2-M17.05 | Como cliente quiero que al cancelar o reprogramar mi cita también se cancele o se mueva la recolección para no recibir al chofer en una fecha que ya no sirve | Cancelar la cita cancela sus traslados programados · reprogramar los mueve a la nueva fecha con sus ventanas · en la misma transacción que la cita · traslados ya en curso no se tocan | ✅ | V2-M17.02 |
| V2-M17.06 | Como cliente quiero entrar a «Mis direcciones» desde mi perfil para administrarlas sin tener que agendar | Fila «Mis direcciones» en el perfil o ajustes que abre `/recoleccion/direcciones` · respeta el interruptor v1/v2 | | V2-M17.01 |

## Fuera de alcance / notas

- El chofer captura el checklist con una herramienta interna; mientras el ERP siga congelado se carga con un endpoint interno o con datos de ejemplo. La app solo consulta.
- El proveedor de mapas y geocodificación se decide en la historia del componente `Mapa` (V2-T02.09) con una decisión (ADR).

## Avance de V2-M17.01

El módulo vive en `lib/modulos/recoleccion/` (`dominio/`, `datos/`, `presentacion/`) y su contrato público es `recoleccion.dart`. «Mis direcciones» se abre en `/recoleccion/direcciones` (exige sesión); el alta y la edición se abren encima de la lista.

- **Contrato y backend:** el backend ya implementa `/direcciones` (GET, POST, PUT, DELETE) en su rama `feat/v2-juan-pablo-ubicacion-recoleccion`. La copia de `api/agencia360-api-app-v1.yaml` pasa a 1.5.0 y suma de forma aditiva las cinco operaciones y los esquemas `NuevaDireccion`, `Direccion`, `FranjaRecoleccion`, `CotizacionRecoleccion`, `EstadoTraslado`, `Traslado`, `RecoleccionCita` y `NuevaRecoleccion`. No toca el enum de códigos de `Problema`: el 422 de cobertura y el 409 de dirección en uso se reconocían por su estado HTTP (el cliente HTTP convertía todo 422 en `SinParametrosDeValuacion` y el repositorio lo traducía a `FueraDeCobertura`; el 409 de borrar, a `DireccionEnUso`). Ese rodeo ya no existe: ver «Deudas resueltas» más abajo. `ClienteApi` gana `actualizar` (PUT) y `eliminar` (DELETE).
- **Lista:** `PantallaMisDirecciones` usa `GrupoLista` (alias y «calle, colonia, CP ciudad»), jalar para recargar y los cinco estados (cargando con esqueleto anunciado, vacío con acción, datos, error con reintento y sin conexión).
- **Formulario:** `PantallaDireccion` pide nombre, calle y número, colonia, código postal (5 dígitos, teclado numérico) y ciudad, con los largos del contrato validados antes de ir a la red. El pin se pone tocando el mapa, con «Usar mi ubicación» (`ProveedorUbicacion`; permiso denegado, ubicación apagada y tiempo agotado se explican y siempre se puede poner el pin a mano) o buscando la dirección escrita (`Geocodificador.coordenadasDe`). En los tres casos `Geocodificador.direccionDe` completa solo los campos vacíos, sin pisar lo que la persona escribió.
- **Cobertura:** el aviso «Fuera de cobertura» sale al intentar guardar, cuando el servidor responde 422; no se guarda nada y lo escrito se conserva. No hay una consulta de cobertura previa en el contrato, por eso el aviso llega con el intento de guardar y no antes.
- **Borrar:** pide confirmación con `Dialogo` de peligro; un 409 `DIRECCION_EN_USO` explica que ya tiene recolecciones y la deja en la lista.
- **Mapa PROVISIONAL:** `presentacion/provisional/mapa_provisional.dart` es el único archivo que importa `flutter_map` y `latlong2` (ADR 0006) y lee las teselas de `configuracionTeselasProvider`. Está marcado `// PROVISIONAL: se reemplaza por Mapa de V2-T02.09`; al integrarse ese componente se borra el archivo y el formulario usa `Mapa`. **Este hito no cierra con él.**
- **Estilo:** «Estilo portada» (§8 del sistema de diseño): encabezado grande translúcido que se contrae, secciones con título y barra inferior fija; solo tokens y componentes del sistema (`GrupoLista`, `CampoTexto`, `Aviso`, `Dialogo`, `BotonPildora`, `EstadoVacio`, `EstadoError`, `Esqueleto`). Ningún contenido atraviesa el título al desplazar (prueba `titulos_al_desplazar_test.dart`) y se prueba en claro, oscuro y letra al 200 %.
- **Pruebas:** `test/modulos/recoleccion/` (dominio, repositorio API y fake, proveedores, mapa provisional, lista, formulario, ruta, formato de pesos y títulos al desplazar), `test/api/cliente_api_test.dart` (PUT y DELETE) y `test/contrato/contrato_test.dart` (v1.5.0, 24 operaciones).
- **Pendiente:** la entrada a «Mis direcciones» desde el perfil o el menú no existe todavía; hoy se llega desde el flujo de agendar (V2-M17.02) y por la ruta. Se agrega cuando el perfil v2 tenga su lista de ajustes.

## Avance de V2-M17.02

«Que recojan mi auto» es una opción del flujo de agendar de `lib/modulos/citas/` (V2-M02.08), publicada por `recoleccion` como `SeleccionRecoleccion` y colocada tras el motivo de la cita.

- **Opción:** dos chips, «Lo llevo yo» (por omisión, no pide nada al servidor) y «Que recojan mi auto». Con la segunda se listan las direcciones guardadas (con «Administrar mis direcciones» o «Agregar dirección» si no hay) y, elegida una, se pide `GET /recoleccion/cotizacion?direccionId=&fecha=` y se muestran las franjas de recoger y entregar, el costo por traslado y el total antes de confirmar. Sin día elegido pide elegirlo; mientras cotiza hay esqueleto anunciado; un error de red ofrece reintentar.
- **Fuera de cobertura:** si la cotización responde 422, la opción explica que esa dirección queda fuera de la zona y «Revisar y confirmar» sigue deshabilitado hasta elegir otra dirección o volver a «Lo llevo yo». Con este criterio la recolección fuera de cobertura nunca llega a confirmarse. Si la zona cambia entre cotizar y confirmar, el 422 de `POST /citas` se explica en el resumen y se puede cambiar de dirección.
- **Confirmar:** `RepositorioCitas.agendar` gana el parámetro opcional `direccionRecoleccionId`; el cuerpo de `POST /citas` manda `recoleccion: { direccionId }` solo cuando se pidió. Un 404 (dirección ajena o borrada) se explica con «No encontramos esa dirección».
- **Resumen y confirmación:** el resumen suma el grupo «Recolección a domicilio» (dirección, cuándo recogen, cuándo entregan y costo total) y la pantalla «Cita confirmada» muestra los traslados que devuelve el 201 (`CitaAgendada.recoleccion`).
- **Comprobante:** el comprobante del servidor no trae los traslados, así que `PantallaComprobanteCita` recibe `recoleccion` desde la confirmación y la muestra con el mismo `GrupoRecoleccionCita`; si se abre desde otro lugar, no la muestra.
- **Mock:** `mock_api/server.js` (bloque `// ── recoleccion ──`) simula el CRUD, la cotización (80 más 12 por km, cobertura de 40 km) y los traslados del 201.
- **Pruebas:** `test/modulos/recoleccion/seleccion_recoleccion_test.dart`, `test/modulos/citas/agendar_con_recoleccion_test.dart`, el repositorio de citas (API y fake) y el comprobante.
- **Fuera de esta historia:** el seguimiento del chofer y el checklist son V2-M17.03 y V2-M17.04; los traslados nacen `programado` y la app aún no los consulta.

## Avance de V2-M17.03/.04/.06

Parte de la app de seguir al chofer, ver el checklist del auto y entrar a «Mis direcciones» desde el perfil. El backend (`GET /traslados/{id}`, `GET /traslados/{id}/checklist`, eventos `traslado.estado` y `traslado.ubicacion`, contrato 2.8.0) ya está implementado.

**V2-M17.03 · Seguir al chofer** (`/recoleccion/traslados/:id`, `PantallaSeguimientoTraslado`)

- «Estilo portada»: `CabeceraPortada` con el traslado («Recogemos tu auto» o «Entregamos tu auto») y su estado, `LineaDeTiempo` con programado → en camino → recogido → en taller → de regreso → entregado (cancelado corta la línea), franja del traslado y «Actualizar».
- **Mapa del chofer solo en `en_camino` y `de_regreso`:** usa el mapa PROVISIONAL del módulo (`MapaProvisional`, ahora de solo lectura, con ícono y descripción propios). Fuera de esos estados la ubicación se descarta aunque llegue.
- **En vivo:** `seguimientoTrasladoProvider` aplica `traslado.estado` y `traslado.ubicacion`, consulta de nuevo al reconectar y a pedido (jalar o «Actualizar»); si falla, conserva lo mostrado y avisa. El canal solo está abierto mientras la pantalla está puesta (cliente de eventos del núcleo, ver V2-M11.04).
- **Acceso:** desde el comprobante de la cita, cada traslado de «Recolección a domicilio» (`GrupoRecoleccionCita`) abre su seguimiento.
- Cinco estados: cargando (esqueleto anunciado), datos, no encontrado (404), error con reintento y sin conexión.

**V2-M17.04 · Checklist con fotos** (`/recoleccion/traslados/:id/checklist`, `PantallaChecklistTraslado`)

- Kilometraje, gasolina (indicador de cuatro segmentos más el nombre del nivel; no depende del color), notas del chofer, `GaleriaFotos` con una descripción por foto y `Firma` del sistema.
- **URLs firmadas:** el checklist se pide de nuevo cada vez que se abre (`checklistTrasladoProvider` es `autoDispose`; el repositorio no guarda nada) y las imágenes se descargan sin escribirlas a disco; la caché de imágenes de Flutter es solo en memoria.
- **404 = aún no hay checklist:** estado vacío que explica que el chofer lo registra al recoger y al entregar.
- Se llega desde el seguimiento con «Ver checklist del auto» (visible desde que el traslado sale: no en programado ni cancelado).

**V2-M17.06 · «Mis direcciones» desde el perfil**

- `PantallaPerfil` (v1, ruta de Ajustes) suma la fila «Mis direcciones» en «Cuenta», que abre `/recoleccion/direcciones` con `GoRouter`; regresar vuelve al perfil. La fila solo se ofrece dentro de la app enrutada. El módulo `recoleccion` es nuevo en v2 y no pasa por el interruptor v1/v2, así que no hay condición por módulo.

**Contrato, DTOs y mock**

- DTOs en `lib/api/modelos/traslado.dart` (`TrasladoDetalle`, `UbicacionChofer`, `ChecklistTraslado`, `EstadoTraslado`, `NivelGasolina`). El 404 del checklist se traduce a `null` en `RepositorioRecoleccionApi.checklist`. Código `TRANSICION_INVALIDA` agregado a `CodigoProblema` y a `test/api/errores_v11_test.dart`. `api/*.yaml` y `test/contrato` los integra quien integra.
- `mock_api/modulos/recoleccion.js`: `GET /traslados/{id}` (ubicación solo en `en_camino` y `de_regreso`), `GET /traslados/{id}/checklist` (404 si no hay; URLs con firma que cambia en cada petición), cancelar una cita cancela sus traslados programados y un emisor de prueba (`POST /__mock/traslados/{id}/estado|ubicacion|checklist`, ver `mock_api/README.md`).
- **Pruebas:** `test/api/traslado_modelos_test.dart`, repositorio, proveedores y fake de recolección, `seguimiento_traslado_test.dart`, `pantalla_seguimiento_traslado_test.dart`, `pantalla_checklist_traslado_test.dart`, `ruta_seguimiento_traslado_test.dart`, `mapa_provisional_test.dart`, `test/modulos/citas/grupo_recoleccion_cita_test.dart` y `test/pantallas/perfil/pantalla_perfil_direcciones_test.dart`.

**Pendiente / fuera de alcance**

- **Mapa PROVISIONAL:** sigue `// PROVISIONAL: se reemplaza por Mapa de V2-T02.09`; este hito no cierra con él.
- **Push** de cada cambio de estado (criterio de V2-M17.03): depende de V2-M06.02. Hoy el seguimiento solo se actualiza en vivo con la pantalla abierta.
- ~~Acceso desde «Mis citas»~~ y ~~Comparar recoger y entregar~~: resueltos, ver «Deudas resueltas».
- Fotos y firma con `NetworkImage`; si más adelante se quiere caché en disco, debe respetar la vida de 15 minutos de las URLs.
- Tablero y `plan/cumplimiento-ficha.md` los actualiza quien integra.

## Deudas resueltas (V2-M17.03 y V2-M17.04)

**1. Seguimiento del chofer desde «Mis citas» (V2-M17.03).** `GET /citas` trae en cada cita el campo `recoleccion` (el mismo `RecoleccionCita` que ya devuelve `POST /citas`; nulo si la cita no lleva recolección).

- `CitaCliente.recoleccion` es una `RecoleccionAgendada`; `TrasladoAgendado` suma `estado` (`EstadoTraslado`, `programado` por omisión) y `tieneChecklist` (recoger: desde que se recoge el auto; entregar: hasta que se devuelve). `RepositorioCitasApi` traduce el campo en la lista; un tipo de traslado que el contrato aún no declara se descarta en vez de romper.
- `PantallaMisCitas` muestra, bajo las próximas y bajo las pasadas, un `GrupoRecoleccionCita` por cada cita con recolección que no esté cancelada, con el encabezado «Recolección · <día y hora de la cita>» para distinguirlas. Cada traslado abre `/recoleccion/traslados/:id`; con el checklist ya dejado por el chofer, el mismo grupo suma «Checklist al recoger», «Checklist al entregar» y, con los dos, «Comparar recoger y entregar». Lo mismo ocurre en el comprobante, que usa el mismo componente.
- `mock_api`: `GET /citas` arma `recoleccion` con los traslados vigentes de cada cita (estado actual incluido); `mock_api/README.md` lo documenta.
- Pruebas: `test/modulos/citas/mis_citas_recoleccion_test.dart` (grupo por cita, sin recolección, cancelada, checklist, pasadas, oscuro y letra al 200 %), `repositorio_citas_test.dart`, `grupo_recoleccion_cita_test.dart` y `test/modulos/recoleccion/dominio_test.dart`.

**2. Comparar el checklist de recoger contra el de entregar (V2-M17.04).**

- `PantallaChecklistTraslado` acepta `trasladoContrarioId` (el otro traslado de la cita), `tipo` (si el abierto recoge o entrega) y `verComparacion`. Con el contrario aparecen las pestañas `Pestanas` «Al recoger», «Al entregar» y «Comparar»; sin él la pantalla es la de siempre.
- «Comparar» pone lado a lado el kilometraje (con los km recorridos entre uno y otro), la gasolina de los dos y, foto por foto, `ComparacionAntesDespues` (a la izquierda al recoger, a la derecha al entregar; deslizador accesible). Si traen distinto número de fotos compara las primeras y lo avisa; si alguno no trae, lo dice.
- **404 explicado:** si falta el checklist de recoger, el de entregar o los dos, la pestaña muestra `EstadoVacio` «Aún no se puede comparar» con el motivo (el de entregar llega cuando devuelven el auto). Error de red: `EstadoError` con reintento. Las pestañas «Al recoger» y «Al entregar» conservan su propio vacío.
- La ruta lleva los parámetros: `rutaChecklistTraslado(id, contrario:, tipo:, comparar:)` se arma como `.../checklist?contrario=6&tipo=entregar&ver=comparar`. La pantalla de seguimiento sigue abriendo el checklist solo (no conoce al contrario); la comparación se ofrece desde Mis citas y el comprobante, que tienen los dos ids.
- Pruebas: `test/modulos/recoleccion/comparacion_checklist_test.dart` y `ruta_seguimiento_traslado_test.dart`.

**3. Fin del rodeo del 422.** `ClienteApi` ya no convierte todo 422 en `SinParametrosDeValuacion`: lo entrega como `SolicitudRechazada` con su `Problema.codigo` (`FUERA_DE_COBERTURA`, `KM_INVALIDO`, …) y solo `SIN_PARAMETROS_DE_VALUACION` sigue siendo `SinParametrosDeValuacion` (ahora subclase de `SolicitudRechazada`; la calculadora de toma a cuenta no cambia). Los repositorios de recolección (guardar, editar, cotizar), citas (agendar), mantenimiento y bitácora atrapan `SolicitudRechazada` y traducen **solo su código**; un 422 con otro código pasa tal cual en vez de disfrazarse. Un 422 sin `codigo` queda `desconocido` y también pasa. Pruebas en `test/api/cliente_api_test.dart` y en los tests de repositorio de cada módulo.

## Ajustes visuales y de cobertura (rama `fix/v2-juan-pablo-ajustes-visuales`)

- **Regresar** en Mis direcciones (pantalla raíz) mediante `conRegreso` en `MarcoPantallaRecoleccion`; seguimiento y checklist lo traen por `BarraPortada`.
- **Cobertura alineada con el backend:** centro de León (21.1250, -101.6860), radio 15 km, tarifa 80 + 8/km y ventanas 07:00–09:00 y 17:00–19:00. Se actualizaron `mock_api/server.js`, `RepositorioRecoleccionFake` (distancia real en vez de cuadro de medio grado) y el centro inicial del mapa. Antes el mock cubría 40 km de la CDMX y guardar una dirección fallaba contra el backend.
- **422 `FUERA_DE_COBERTURA`:** el formulario muestra «Fuera de cobertura» y pide mover el pin; probado con Monterrey y con la CDMX.

## Rediseño: encabezados ligeros (V2-T02.21)

Los marcos de pantalla del módulo (`MarcoPantallaRecoleccion`, `BarraInferiorRecoleccion`, `SeccionRecoleccion`) son ahora `MarcoPantalla`, `BarraInferior` y `SeccionPantalla` del sistema. Seguimiento del traslado y checklist usan el encabezado grande (el checklist con pestañas usa `BarraPantalla`), con `FilaAcciones` («Ver checklist», «Actualizar») en el seguimiento. Sin portada.
