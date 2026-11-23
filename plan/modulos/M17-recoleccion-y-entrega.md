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

## Fuera de alcance / notas

- El chofer captura el checklist con una herramienta interna; mientras el ERP siga congelado se carga con un endpoint interno o con datos de ejemplo. La app solo consulta.
- El proveedor de mapas y geocodificación se decide en la historia del componente `Mapa` (V2-T02.09) con una decisión (ADR).

## Avance de V2-M17.01

El módulo vive en `lib/modulos/recoleccion/` (`dominio/`, `datos/`, `presentacion/`) y su contrato público es `recoleccion.dart`. «Mis direcciones» se abre en `/recoleccion/direcciones` (exige sesión); el alta y la edición se abren encima de la lista.

- **Contrato y backend:** el backend ya implementa `/direcciones` (GET, POST, PUT, DELETE) en su rama `feat/v2-juan-pablo-ubicacion-recoleccion`. La copia de `api/agencia360-api-app-v1.yaml` pasa a 1.5.0 y suma de forma aditiva las cinco operaciones y los esquemas `NuevaDireccion`, `Direccion`, `FranjaRecoleccion`, `CotizacionRecoleccion`, `EstadoTraslado`, `Traslado`, `RecoleccionCita` y `NuevaRecoleccion`. No toca el enum de códigos de `Problema`: el 422 de cobertura y el 409 de dirección en uso se reconocen por su estado HTTP (el cliente HTTP convierte todo 422 en `SinParametrosDeValuacion`, y el repositorio lo traduce a `FueraDeCobertura`; el 409 de borrar, a `DireccionEnUso`). `ClienteApi` gana `actualizar` (PUT) y `eliminar` (DELETE).
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
