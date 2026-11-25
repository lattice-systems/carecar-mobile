# M25 · Widgets, Wallet y accesos rápidos

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Juan Pablo |
| Revisa | Cristian |
| Ficha técnica | No (frente transversal; se cumple dentro de las funcionalidades de la ficha) |
| Estado | Listo para historias |

## Propósito

CareCar fuera de la app: widget de inicio con próxima cita y estado del taller, pase de cita en Google Wallet / Apple Wallet, accesos rápidos desde el ícono. Mueve O2 y O3.

## Pantallas

- **Widget de inicio** (Android Glance, iOS WidgetKit) — próxima cita o, si hay una orden abierta, la etapa del taller.
- **Pase de Wallet** — botón en el comprobante de cita para guardarlo en Google Wallet o Apple Wallet.
- **Accesos rápidos** — al mantener presionado el ícono: Agendar, Mi auto y SOS.
- **Live Activity** (iPhone) — etapa del taller en la pantalla bloqueada mientras la orden esté abierta.

## Datos

Sin tablas nuevas: lee `cita` y la orden de servicio abierta (M04).

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/citas/{id}/pase?plataforma=apple\|google` | Pase firmado por el backend con el QR del comprobante (V2-M02.11). Apple responde el archivo `.pkpass` (`application/vnd.apple.pkpass`); Google responde `{url}` con el enlace «Guardar en Google Wallet» (`https://pay.google.com/gp/v/save/<jwt>`). 404 si la cita no es del cliente; 409 `CITA_CANCELADA` si está cancelada (el pase queda vencido); 503 `WALLET_NO_CONFIGURADO` si el servidor no tiene certificados. Simulado en `mock_api`. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M25.01 | Como cliente quiero un widget con mi próxima cita para verla sin abrir la app | Android (Glance) e iOS (WidgetKit) · fecha, hora y vehículo de la próxima cita confirmada; sin cita invita a agendar · un toque abre la cita · se actualiza al agendar o cancelar | | V2-M02.09, V2-T01.03 |
| V2-M25.02 | Como cliente quiero ver en el widget el estado de mi auto en el taller para seguirlo de un vistazo | Con orden abierta muestra la etapa actual (M04); sin orden, vuelve a la próxima cita | | V2-M04.02, V2-M25.01 |
| V2-M25.03 | Como cliente quiero guardar mi cita en Wallet para presentarla en recepción | Botón en el comprobante · pase firmado por el backend con el QR · si la cita se cancela, el pase queda vencido | ✅ | V2-M02.11 |
| V2-M25.04 | Como cliente quiero accesos rápidos desde el ícono para ir directo a lo que más uso | Mantener presionado el ícono muestra Agendar, Mi auto y SOS · cada uno abre su pantalla | | V2-T01.03 |
| V2-M25.05 | Como cliente de iPhone quiero ver el estado del taller en la pantalla bloqueada para seguir mi servicio | Live Activity con la etapa actual mientras la orden esté abierta · termina al entregar el auto · se actualiza por push desde el backend | ✅ | V2-M04.03 |
| V2-M25.06 | Como cliente quiero que el pase de Wallet de una cita cancelada o reprogramada deje de servir para no presentarme con un pase viejo | Apple: servicio de actualización (`webServiceURL`, registro de dispositivos, APNs) marca el pase `voided` · Google: el objeto pasa a `EXPIRED` · al reprogramar se actualiza fecha y horario · llaves fuera del repo (R8) | ✅ | V2-M25.03 |

## Fuera de alcance / notas

- Firmar pases de Apple y Google pide certificados de las cuentas de desarrollador; van fuera del repositorio (R8) y se tramitan junto con T04.

## Avance de V2-M25.04

**Qué quedó**

- Dependencia `quick_actions ^1.1.1` (atajos de Android y quick actions de iOS).
- Módulo `lib/modulos/widgets/` con contrato `widgets.dart`. Dominio puro: `AccesoRapido` (`agendar`, `mi_auto`, `sos`), `AtajoDeIcono` y la interfaz `PuertoAccesosRapidos`; el paquete queda detrás de ella (`datos/accesos_rapidos_quick_actions.dart`) y se sustituye en pruebas con `puertoAccesosRapidosProvider`.
- `InstaladorDeAccesosRapidos` se monta en el `builder` del `MaterialApp` (`lib/main.dart`): registra los tres atajos con títulos del ARB (prefijo `widgets`, es y en), los vuelve a registrar si cambia el idioma, y al tocar uno navega con `go` al destino. La guardia de sesión aplica igual: sin sesión pide acceso y luego vuelve al destino.
- Destinos: Agendar → `/citas/agendar` (`rutaAgendarCita`), Mi auto → `/garaje` (`rutaGaraje`), SOS → `rutaSos`. Solo se usan constantes del contrato público de cada módulo.
- **SOS abre las guías de emergencia** (`/asistencia/guias`, V2-M11.03) porque V2-M11.01 (pantalla SOS) aún no existe. Cuando exista, basta cambiar `rutaSos` en `lib/modulos/asistencia/presentacion/rutas_asistencia.dart`.
- Android: tres drawables `ic_acceso_*` y `res/raw/keep.xml` ampliado para que el reductor de release no los quite. Sin cambios en el manifiesto ni en `MainActivity`.
- iOS: sin cambios nativos. `quick_actions_ios` se engancha solo al `SceneDelegate` que ya usa el proyecto; los atajos son dinámicos (no hay `UIApplicationShortcutItems` en `Info.plist`).
- Un sistema que no admite atajos (Android 7.0, emulador de escritorio) no afecta a la app: el error al instalar se ignora.

**Estados:** no aplican los cinco de pantalla (el módulo no pinta UI propia); el caso "el sistema no deja registrar atajos" está probado.

**Pendiente / fuera de alcance**

- Probar en un teléfono real y en iOS (mantener presionado el ícono): las pruebas automáticas usan un puerto falso porque `quick_actions` es un canal de plataforma.
- Los atajos de iOS salen sin ícono (necesitan assets en `Assets.xcassets`); se puede agregar con un diseño de Cristian.
- Con arranque en frío y sesión por restaurar, el destino pasa por la guardia: si la sesión sigue activa se llega al destino, si no se pide acceso y se vuelve a él.
- V2-M25.01 a V2-M25.03 y V2-M25.05 siguen sin empezar.

## Avance de V2-M25.01

**Qué quedó**

- Dependencia `home_widget ^0.10.0` (canal y almacén compartido con el widget nativo). Queda detrás de `PuertoWidgetCita`; el adaptador real es `datos/widget_cita_home_widget.dart` y las pruebas usan un puerto falso.
- Dominio puro (`dominio/proxima_cita_widget.dart`): `proximaCita` elige la cita **confirmada** que empieza primero y todavía no empieza; `ContenidoWidgetCita` (con cita o sin cita) y los enlaces `carecar://citas/<id>/comprobante` y `carecar://citas/agendar`, que `EnlacesApp` ya traduce a `/citas/:id/comprobante` y `/citas/agendar`. Para eso `citas.dart` ahora publica `CitaCliente` y `EstadoDeCita`.
- `SincronizadorDelWidgetDeCita` se monta en el `builder` del `MaterialApp` (`lib/main.dart`). Observa la sesión y `misCitasProvider` y publica: con cita (día, horario y vehículo) o sin cita (mensaje e invitación a agendar). Se vuelve a publicar al cambiar el idioma, al volver la app al primer plano (la cita pudo empezar) y cada vez que cambia la lista.
- **Se actualiza al agendar o cancelar:** cancelar y reprogramar ya reemplazaban o invalidaban `misCitasProvider`; agendar no, así que `pantalla_agendar_cita.dart` ahora invalida `misCitasProvider` al confirmar (con prueba).
- Textos con prefijo `widgets` en los ARB es y en (`widgetsProximaCita*`, `widgetsSinCitaMensaje`; la acción reutiliza `widgetsAccesoAgendar`) y `app_localizations*.dart` regenerados.
- **Android completo:** `ProximaCitaWidgetProvider.kt` (pinta desde `HomeWidgetPreferences` y abre la app con un `PendingIntent` de `ACTION_VIEW` al enlace `carecar://`, que `MainActivity` ya recibe como deep link), layout `widget_proxima_cita.xml`, ficha `widget_proxima_cita_info.xml` (3x2, redimensionable, `updatePeriodMillis=0`), fondo, colores claro y oscuro con los valores de los tokens de Pista, textos es y en del selector y el `<receiver>` en el manifiesto. Compila con `flutter build apk --debug`.
- **iOS, código escrito pero sin enlazar:** `ios/ProximaCitaWidget/ProximaCitaWidget.swift` (WidgetKit, `kind` `ProximaCitaWidget`, lee el App Group `group.com.carecar.carecarMobile`, `widgetURL` al enlace). No se tocó `Runner.xcodeproj` porque crear el target de extensión a mano en el `pbxproj` no es fiable.

**Datos y seguridad (OWASP Mobile)**

- Al widget solo viajan textos de pantalla: día, horario, nombre del vehículo y el id de la cita dentro del enlace. No viajan nombre del cliente, placas, VIN ni el código firmado del QR.
- Android: `SharedPreferences` privadas de la app (no legibles por otras apps). El widget es visible desde la pantalla de inicio aunque el teléfono esté bloqueado en algunos lanzadores: es el costo de mostrar la cita sin abrir la app.
- Al cerrar sesión (o sin sesión al arrancar) se publica el estado sin cita y se borran los datos anteriores; no se piden citas sin sesión.
- No se escribe nada en logs; los fallos del sistema al publicar se ignoran (escritorio, emulador sin lanzador).

**Estados:** el widget tiene con cita y sin cita; mientras cargan las citas o si falla la red conserva lo último mostrado (probado). Los cinco estados de pantalla no aplican (no es una pantalla de la app).

**Pendiente / fuera de alcance**

- **iOS (falta Xcode):** (1) File > New > Target > Widget Extension llamado `ProximaCitaWidget` (sin Live Activity ni configuración), borrar los archivos que genera y agregar `ios/ProximaCitaWidget/ProximaCitaWidget.swift` al target; (2) activar la capacidad App Groups con `group.com.carecar.carecarMobile` en `Runner` y en la extensión (entitlements); (3) comprobar que el esquema `carecar://` ya está en `Info.plist` y probar el toque; (4) iOS 17 o superior por `containerBackground`.
- Probar en un teléfono real el toque desde el widget con la app cerrada (arranque en frío con sesión por restaurar pasa por la guardia de sesión).
- La cita deja de ser "próxima" cuando empieza; sin abrir la app el widget no se repinta solo hasta que la app vuelva al primer plano. Refresco en segundo plano (WorkManager o `BGAppRefresh`) queda como historia aparte si se necesita.
- Las dimensiones y la tipografía del widget no son del sistema de diseño (los widgets nativos no usan Flutter); solo se reutilizan los valores de color de los tokens de Pista. Pedir a Cristian una revisión de diseño.
- V2-M25.02 (estado del taller en el widget) reutiliza este widget y el puerto.
- `plan/cumplimiento-ficha.md` y `plan/tablero.md` los actualiza quien integra.

## Avance de V2-M25.02

**Qué quedó**

- El widget de V2-M25.01 ahora muestra el estado del auto cuando hay una **orden abierta**; sin orden vuelve a la próxima cita. Con orden: título «Tu auto en el taller», etapa actual, hora estimada de entrega (si el taller ya la estimó) y el auto. Al tocarlo abre `carecar://taller/<ordenId>` (la ruta `/taller/:ordenId` de V2-M04.02).
- **Sin duplicar el repositorio del taller:** `SincronizadorDelWidgetDeCita` lee `ordenesEnCursoProvider` (`GET /ordenes/activas`) por el contrato `taller.dart`, que ahora también publica `OrdenEnCurso`, `EtapaTaller`, `textoEtapa` y `horaTaller`. Si hay varias órdenes abiertas se muestra la primera que devuelve el backend.
- **Dominio:** `ContenidoWidgetCita.enTaller` y `enlaceDeOrdenWidget` (`dominio/proxima_cita_widget.dart`). Reutiliza las mismas claves del almacén (la etapa va en `proxima_cita_fecha`, la entrega en `proxima_cita_horario`, el auto en `proxima_cita_vehiculo`), así que **no cambió el contrato nativo**: el proveedor Kotlin, el layout y el Swift pintan igual; solo se actualizaron sus comentarios.
- **Cuándo se actualiza:** al cambiar la sesión (cerrar sesión borra todo), las órdenes o las citas, el idioma, al volver la app a primer plano (se vuelven a consultar las órdenes) y con la app abierta por el canal en vivo: el evento `orden` de `GET /eventos` (V2-T05.08) y `conexion.restablecida` invalidan `ordenesEnCursoProvider`. El canal solo se abre con sesión y se cierra al salir.
- **Si falla la red:** sin orden cargada nunca, el widget cae a la cita; si ya mostraba una orden, la conserva. Mientras las órdenes cargan por primera vez no se publica la cita para no parpadear.
- Textos con prefijo `widgets` en es y en (`widgetsTallerTitulo`, `widgetsTallerEntrega`) y `app_localizations*.dart` regenerados.
- Pruebas en `test/modulos/widgets/` (`contenido_widget_taller_test.dart` y casos nuevos en `sincronizador_widget_cita_test.dart`): orden con auto, etapa, entrega y enlace; sin hora estimada; idioma; regreso a la cita al entregarse; evento `orden`, reconexión y primer plano; borrado al cerrar sesión; equipo comprometido; fallos de red.

**Datos y seguridad (OWASP Mobile)**

- Al widget solo viajan textos de pantalla: etapa, hora de entrega, nombre del vehículo y el id de la orden dentro del enlace. No viajan asesor, montos, adicionales, placas, VIN ni datos del cliente. No se escribe nada en logs.
- Cerrar sesión (o equipo comprometido, V2-M22.05) publica el estado sin datos y no consulta órdenes ni abre el canal. Lo mismo que M25.01: el widget puede verse con el teléfono bloqueado en algunos lanzadores.

**Pendiente / fuera de alcance**

- **iOS (falta Xcode):** igual que M25.01; sin cambios en el Swift más que comentarios. Al enlazar el target se prueba también con orden abierta.
- Probar en teléfono real que el toque abra la orden con la app cerrada (pasa por la guardia de sesión) y que el evento `orden` repinte con la app abierta.
- Con la app cerrada el widget no se repinta solo (igual que M25.01); el refresco en segundo plano sería una historia aparte.
- El widget usa los mismos tamaños y tipografía de M25.01; pedir revisión de diseño a Cristian.
- `plan/cumplimiento-ficha.md` y `plan/tablero.md` los actualiza quien integra.

## Avance de V2-M25.03

Parte de **app** de «Guardar mi cita en Wallet». Estado: **En curso**; el pase firmado depende de la historia `Backend:` (otro agente la implementa contra el mismo contrato) y de los certificados de Apple y Google (ver notas de arriba).

**Qué quedó**

- **Botón en el comprobante:** `BotonAgregarAWallet` (`lib/modulos/citas/presentacion/`) bajo «Ver comprobante en PDF» en `PantallaComprobanteCita`. Usa `Boton`, `Aviso` y tokens del sistema v2. Donde no hay Wallet (escritorio) no se dibuja.
- **Por plataforma:** Android pide `plataforma=google` y abre el enlace «Guardar en Google Wallet» con `url_launcher` (modo aplicación externa); iOS pide `plataforma=apple`, descarga el `.pkpass` y lo ofrece en la hoja de compartir (`share_plus`), desde donde se abre en Wallet. La plataforma sale de `plataformaWalletProvider`.
- **Datos:** `RepositorioPaseWalletApi` usa el cliente del núcleo (`apiClienteProvider`); `ClienteApi.descargar` ahora acepta `consulta`. Dominio puro en `dominio/pase_de_wallet.dart` (`PlataformaWallet`, `PaseApple`, `PaseGoogle`, `RepositorioPaseWallet`, `EntregaDePase`) con fakes en `datos/`.
- **Estados:** carga (el botón anuncia «cargando» y no admite doble toque), éxito (se entrega al sistema) y error en línea con reintento: sin conexión, cita cancelada (409 `CITA_CANCELADA`), Wallet no configurado (503 `WALLET_NO_CONFIGURADO`, remite al QR) y genérico. No hay estado vacío (no es lista).
- **Sin caché:** el pase no pasa por `CarecarApiConCache` ni se escribe en disco; cada toque lo pide de nuevo y los bytes del `.pkpass` viajan en memoria.
- **Contrato:** `WALLET_NO_CONFIGURADO` agregado a `Problema.codigo` en `api/agencia360-api-app-v1.yaml`, a `CodigoProblema` y a `errores_v11_test.dart`. Fila del endpoint en las tablas API de M02 y M25.
- **mock_api:** `GET /citas/:citaId/pase` (pkpass falso de pocos bytes para Apple, `{url}` falsa para Google, 409 en cita cancelada, 400 con plataforma inválida).
- **Seguridad:** el enlace de Google solo se abre si es HTTPS de `pay.google.com`; cualquier otro se rechaza como respuesta inválida. No se registra el pase ni datos del cliente.
- **Textos:** claves `citasWallet*` en los ARB es y en.
- **Pruebas:** `repositorio_pase_wallet_test.dart` (Apple, Google, enlace falso, 409, 503, sin red), `boton_agregar_a_wallet_test.dart` (plataformas, carga, errores, 48 de zona tactil, claro, oscuro y letra al 200 %) y el caso nuevo de `pantalla_comprobante_cita_test.dart`.

**Pendiente / fuera de alcance**

- **Criterio «el pase queda vencido si se cancela»:** es del backend (pase con fecha de expiración o `voided` en Google y `voided` en el `.pkpass`; hoy solo se garantiza que no se emite uno nuevo con 409). La app no puede invalidar un pase ya guardado.
- Backend real: firma del `.pkpass` y JWT de Google con certificados fuera del repo (R8, tramitados con T04).
- Probar en teléfono real: abrir Google Wallet y la hoja de compartir de iOS con el `.pkpass` (las pruebas usan puertos falsos porque son canales de plataforma). En iOS no se verificó que la hoja ofrezca «Agregar a Wallet»; si no, usar `PassKit` con un canal propio.
- `queries` de Android 11+ para `url_launcher` (`https`) no se tocaron: el enlace se abre con `launchUrl`, que no depende de `canLaunchUrl`.
- `plan/cumplimiento-ficha.md` y `plan/tablero.md` los actualiza quien integra.
- V2-M25.02 y V2-M25.05 siguen sin empezar.
