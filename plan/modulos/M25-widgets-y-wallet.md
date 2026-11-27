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
| PUT | `/ordenes/{ordenId}/actividad-en-vivo` | Registra el push token (hexadecimal, máx. 300) de la Live Activity de la orden (V2-M25.05); el backend la actualiza por APNs y la termina al entregar. 204 (idempotente) · 400 · 404 si la orden es ajena · 409 `ORDEN_CERRADA` si ya se entregó. Simulado en `mock_api`. |
| DELETE | `/ordenes/{ordenId}/actividad-en-vivo?pushToken=` | Da de baja esa actividad; sin `pushToken`, todas las del cliente en la orden (al cerrar sesión). 204 idempotente · 404. Simulado en `mock_api`. |

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

## Avance de widgets múltiples

Rediseño de los widgets de inicio: cinco widgets independientes que se agregan por separado desde el selector, con estilo tipo widgets de iOS (esquinas grandes, cifras grandes, degradado sutil de marca, mucho aire; sin assets de Apple) y responsivos.

**Qué quedó**

- **Dart** (`lib/modulos/widgets/`): `TipoWidget` (cita, taller, mantenimiento, bitácora, accesos) con su prefijo de claves, `ContenidoWidget` por widget, `PuertoWidgets` y un sincronizador de los cinco (sesión, datos, idioma, primer plano y eventos). Cerrar sesión borra los cinco. Textos en los ARB es y en. Los contratos de mantenimiento y bitácora exportan lo necesario.
- **Android:** un `AppWidgetProvider` por widget sobre la base `WidgetCarecar`; layouts `widget_{cita,taller,mant,bit,acc}_{s,m,l}.xml` (2x2, 4x2, 4x4). En API 31 o más se entrega un mapa de tamaños y el lanzador elige; antes se elige por el ancho y alto mínimos y se repinta al redimensionar. Claro y oscuro, es y en, vistas previas y `contentDescription`. Accesos rápidos abre `carecar://` y no depende de datos.
- **iOS:** `ios/CareCarWidgets/` con cinco widgets y `WidgetBundle`, cada uno en `.systemSmall`, `.systemMedium` y `.systemLarge` (5 x 3).
- Enlaces: cita abre el comprobante, taller la orden, mantenimiento el plan, bitácora la bitácora, accesos los destinos de Agendar, Mi auto, SOS y Comprobante.

**iOS: el target sigue sin enlazar en Xcode.** Falta: (1) File > New > Target > Widget Extension llamado `CareCarWidgets`, borrar lo que genere y agregar todos los `.swift` de `ios/CareCarWidgets/`; (2) App Group `group.com.carecar.carecarMobile` en `Runner` y en la extensión; (3) iOS 17 o superior; (4) probar en dispositivo. El Swift no se compiló aquí (sin Xcode).

**Propuesta de historias nuevas** (no se tocó `plan/tablero.md`; la integra quien mueve el tablero)

| ID propuesto | Historia | Criterios de aceptación |
| --- | --- | --- |
| V2-M25.07 | Como cliente quiero un widget de mantenimiento para ver cuánto falta para mi próximo servicio | Próximo servicio, km faltantes, fecha estimada y avance · en rojo cuando ya toca · un toque abre el plan · sin plan invita a abrir el garaje · 2x2, 4x2 y 4x4 · claro, oscuro, es y en |
| V2-M25.08 | Como cliente quiero un widget de bitácora para ver mi rendimiento y gasto del mes | Rendimiento en km/l y gasto del mes · raya si hay menos de dos cargas · un toque abre la bitácora · tres tamaños |
| V2-M25.09 | Como cliente quiero un widget de accesos rápidos para ir directo a Agendar, Mi auto, SOS y Comprobante | Cuatro botones con enlace `carecar://` · funciona sin datos · tres tamaños |

**Pendiente**

- Probar en teléfono real tamaños, redimensión, tema oscuro y toque con la app cerrada.
- Revisión de diseño de Cristian y pase por la guardia de sesión en arranque en frío.
- `plan/cumplimiento-ficha.md` y `plan/tablero.md` los actualiza quien integra.

## Avance de V2-M25.06 y diseño de V2-M25.05

**V2-M25.06 (pases que siguen a la cita) — Google hecho en el backend, Apple pendiente.** No hay cambio en la app: el pase se actualiza o expira desde el servidor.

- **Backend:** al cancelar o reprogramar, `AgendaAppService` publica `CambioDePaseDeCita`; `ActualizadorDePasesGoogle` marca el objeto `EXPIRED` (cancelada) o le pone fecha y horario nuevos (reprogramada), tras confirmar la transacción y sin poder revertirla. Detalle y diseño de Apple en `agencia-360-backend/plan/historias-backend.md` («Diseño técnico — V2-M25.06»).
- **Decisiones y supuestos:** (1) Apple (`webServiceURL`, registro de dispositivos y APNs) exige certificado del Pass Type ID y un dominio HTTPS público, que no hay: queda diseñado, no implementado. (2) Mientras tanto un pase de Apple viejo sigue en el teléfono, pero recepción lo rechaza porque valida el QR contra la cita. (3) Lo de Google se probó con un transporte falso, no contra Google. Por eso la historia queda `En curso` y **no** pasa a `Hecha`.

**V2-M25.05 (Live Activity en pantalla bloqueada) — solo diseño, sin código.** Sigue `Lista`; depende de V2-M04.03 (Ricardo) y de V2-M06.02 (Jael), que no están integradas. Lo que se decide aquí para no frenar a nadie:

- **Solo iPhone** (criterio de la historia). Una Live Activity es una extensión nativa SwiftUI (`ActivityKit`) dentro del target de widgets de iOS, que sigue sin enlazarse en Xcode (ver «Avance de widgets múltiples»); sin eso no se puede construir ni probar.
- **Arranque y fin:** la app inicia la actividad al abrir una orden en curso (`orden` del canal en vivo, V2-M04.02) y el backend la termina al entregar el auto.
- **Actualización por push:** ActivityKit actualiza por APNs con un `push token` por actividad. Eso necesita el mismo certificado y servicio de envío que V2-M06.02/V2-M06.07; la app solo debe mandar ese token al backend (endpoint nuevo a definir con Ricardo/Jael, p. ej. `PUT /ordenes/{id}/actividad-en-vivo`).
- **Contenido:** etapa actual y progreso de `OrdenEnVivo` (el mismo contrato de V2-M04.02 que ya usa el widget del taller, V2-M25.02), para no inventar otro modelo.
- **Pendiente para tomarla:** que M04.03 y M06.02 estén integradas, enlazar el target en Xcode y definir el endpoint del token.

## Avance de V2-M25.05 y V2-M25.06 (Apple)

Live Activity del taller en la pantalla bloqueada (V2-M25.05, solo iPhone) y pases de Apple Wallet que siguen a la cita (V2-M25.06). **Estado: implementado con fakes; falta certificado Apple, dominio HTTPS y compilar en Xcode.** Por eso ninguna de las dos pasa a `Hecha`; `plan/tablero.md` lo mueve quien integra.

**Backend** (`agencia-360-backend`, rama `feat/v2-m25-apple-backend`; diseño en `plan/historias-backend.md`, secciones de V2-M25.05 y V2-M25.06)

- **APNs** detrás de la interfaz `EnvioApns`: `EnvioApnsReal` firma un JWT ES256 con la llave `.p8` (`APNS_KEY_ID`, `APNS_TEAM_ID`, `APNS_KEY_P8_BASE64`, `APNS_BUNDLE_ID`, `APNS_SANDBOX`), lo reutiliza 40 minutos y habla HTTP/2 con el cliente del JDK; `EnvioApnsFake` en pruebas. Sin las variables no se manda ningún push y nada falla (R8).
- **Live Activity:** tabla `actividad_en_vivo` (migración V62), `PUT`/`DELETE /ordenes/{ordenId}/actividad-en-vivo` y `ActualizadorDeActividadesEnVivo`, que escucha el mismo `OrdenServicioCambiada` del SSE (apertura, etapa, adicional, respuesta) y manda `apns-push-type: liveactivity` con `aps.content-state` `{etapa, estatus, avance, adicionalesPendientes, entregaEstimada?}` (nombres de los enums y la hora en segundos desde 1970). Un cambio de etapa trae `alert` en español. **Al entregar** manda `event: end` con el estado final y `dismissal-date` a 15 minutos y marca las actividades inactivas; un token muerto (410, `BadDeviceToken`) también.
- **Pases de Apple (V2-M25.06):** el `pass.json` lleva `webServiceURL` y `authenticationToken` (HMAC por cita) cuando hay URL pública HTTPS; **PassKit Web Service** fuera de `/api/v1/app` (`/v1/devices/...`, `/v1/passes/...`, `/v1/log`) con la tabla `registro_pase_apple`. Al cancelar la cita el pase sale **`voided`**; al **reprogramar** trae la fecha nueva; en ambos casos un push vacío por APNs a cada dispositivo registrado hace que Wallet lo vuelva a pedir. Google ya marcaba `EXPIRED` u horario nuevo. Nunca revierte la cancelación.

**App**

- **V2-M25.06: sin cambio de código.** El pase se actualiza o se anula desde el servidor; la app solo copió el párrafo nuevo de la descripción de `GET /citas/{citaId}/pase` en `api/agencia360-api-app-v2.yaml`.
- **Contrato:** copiadas solo las rutas `PUT`/`DELETE /ordenes/{ordenId}/actividad-en-vivo`, el esquema `ActividadEnVivoToken` y ese párrafo, en los mismos lugares que en el backend y sin tocar `version`. `ORDEN_CERRADA` ya estaba mapeado. Lo vigila `test/contrato/contrato_actividad_en_vivo_test.dart`.
- **Cliente del núcleo** (`lib/api/cliente_api.dart`, aditivo): `actualizarSinRespuesta` (PUT que contesta 204) y `eliminar` con `consulta` opcional.
- **Dominio** (`lib/modulos/widgets/dominio/actividad_en_vivo.dart`): `EstadoDeActividad` con las mismas llaves y tipos del `content-state` del backend (la actualización local y la remota pintan lo mismo); `ServicioActividadEnVivo` (puente con ActivityKit), `RepositorioActividadEnVivo` y `OrdenYaEntregada`.
- **Datos:** `ServicioActividadEnVivoCanal` (`MethodChannel` `carecar/actividad_en_vivo` y `EventChannel` `carecar/actividad_en_vivo/tokens`; `MissingPluginException` y `PlatformException` son «no disponible»), `ServicioActividadEnVivoNulo` (Android, escritorio, web, pruebas) y `ServicioActividadEnVivoFake`; `RepositorioActividadEnVivoApi` y su fake. En producción el canal solo se usa si `defaultTargetPlatform == TargetPlatform.iOS` (`servicioActividadEnVivoProvider`).
- **`CoordinadorDeActividadEnVivo`**, instanciado dentro de `SincronizadorDeWidgets` (no se tocó `lib/main.dart`): con cada lista de `ordenesEnCursoProvider` (que ya se refresca con el evento `orden` del canal en vivo, al reconectar y al volver a primer plano) inicia una actividad por orden abierta, la repinta si cambió su estado, la termina con el estado final al dejar de estar abierta (entregada) y manda cada push token al `PUT`. Al cerrar sesión, con `registrarAntesDeCerrarSesion`, da de baja cada actividad (`DELETE` con su token) y las termina; al perder la sesión sin cerrarla o en un equipo comprometido solo las termina. También termina las que quedaron de una ejecución anterior y ya no corresponden a una orden abierta.
- **iOS** (Swift escrito, sin compilar): `ios/CareCarWidgets/ActividadTallerAtributos.swift` (`AtributosActividadTaller` con solo `ordenId` y `EstadoActividadTaller: Codable, Hashable` con las llaves exactas), `ios/CareCarWidgets/ActividadTallerLiveActivity.swift` (pantalla bloqueada y Dynamic Island compacta, mínima y expandida: etapa grande, barra de avance, hora estimada y aviso «trabajo por aprobar»; textos de etapa de la app en es y en; un toque abre `carecar://taller/<id>`), registrada en `CareCarWidgetsBundle.swift`, y el puente `ios/Runner/PuenteActividadEnVivo.swift` (`Activity.request(..., pushType: .token)`, `pushTokenUpdates` en hexadecimal por el `EventChannel`, update y end con las APIs de iOS 16.1 y 16.2). `NSSupportsLiveActivities` en `Info.plist` e `Info-desarrollo.plist`.
- **mock_api:** `PUT` y `DELETE /ordenes/:ordenId/actividad-en-vivo` en `mock_api/modulos/taller.js` (204, 400 `DATOS_INVALIDOS`, 404 y 409 `ORDEN_CERRADA` en formato `Problema`; tokens en memoria).
- **Pruebas:** `estado_de_actividad_test.dart`, `servicio_actividad_en_vivo_canal_test.dart` (sin puente, error de plataforma, llamadas y tokens filtrados), `repositorio_actividad_en_vivo_test.dart`, `coordinador_de_actividad_en_vivo_test.dart` (ciclo completo, rotación de token, 409, sin red, cerrar y perder sesión, actividades de una ejecución anterior) y casos nuevos en `sincronizador_de_widgets_test.dart`.

**Decisiones**

1. **La actividad sale de `OrdenEnCurso` (`GET /ordenes/activas`), no de `OrdenEnVivo`.** Trae justo la etapa, el avance, los adicionales pendientes y la hora estimada, ya la usa el widget del taller y ya la refresca el evento `orden`; `OrdenEnVivo` pediría un `GET /ordenes/{id}` por orden y no se exporta en `taller.dart`. El `estatus` se deriva de la etapa con la misma regla que `EtapaTaller.estatus()` del backend. No se tocó el contrato del módulo `taller`.
2. **La hora estimada viaja como segundos desde 1970 con el desfase fijo de la agencia (UTC−6).** El contrato la da en hora de la agencia sin zona; México no tiene horario de verano desde 2022 y el backend usa `America/Mexico_City`, así que el instante coincide con el del push. En Swift es `Int?` y no `Date`: el `JSONDecoder` por omisión de ActivityKit leería un `Date` como segundos desde 2001.
3. **Una actividad por orden abierta** (un cliente con dos autos ve dos), cada una con su token; el backend ya admite varias.
4. **Al entregar no se manda `DELETE`:** el backend ya marca la actividad inactiva con su `event: end`. Solo se da de baja al cerrar sesión, con el token de este teléfono para no quitar la de otro dispositivo del mismo cliente; una actividad de una ejecución anterior sin token conocido se da de baja sin `pushToken` (todas las del cliente en esa orden).
5. **Reintentos:** un `409 ORDEN_CERRADA` termina la actividad y esa orden no se vuelve a iniciar en la sesión; un fallo de red se reintenta con el siguiente cambio de órdenes (evento `orden`, reconexión o primer plano). Nada de esto lanza ni escribe en logs.
6. **Sin dependencia nueva:** canal propio en vez de un paquete de Live Activities (evita un PR `build(deps)`).
7. **El puente nativo queda sin enlazar** y `AppDelegate.swift` sin cambios, para no romper la compilación de iOS: mientras tanto Dart recibe `MissingPluginException` y la actividad queda «no disponible». Sin UI Flutter nueva ni claves ARB nuevas (los textos de la Live Activity son nativos).

**Pasos en Xcode para enlazarla** (además de los de «Avance de widgets múltiples», que crean el target `CareCarWidgets`)

1. Agregar `ios/CareCarWidgets/ActividadTallerAtributos.swift` a **los dos targets**, `Runner` y `CareCarWidgets` (Target Membership), y `ActividadTallerLiveActivity.swift` solo a `CareCarWidgets`.
2. Agregar `ios/Runner/PuenteActividadEnVivo.swift` al target `Runner`.
3. En `ios/Runner/AppDelegate.swift`, dentro de `didInitializeImplicitFlutterEngine`, después de `GeneratedPluginRegistrant.register(...)`: `if let registrador = engineBridge.pluginRegistry.registrar(forPlugin: "PuenteActividadEnVivo") { PuenteActividadEnVivo.registrar(con: registrador) }`.
4. Capacidad **Push Notifications** en `Runner` (entitlement `aps-environment`); la extensión no la necesita.
5. `NSSupportsLiveActivities` = YES ya está en `ios/Runner/Info.plist` (y en `Info-desarrollo.plist`).
6. Compilar y corregir lo que diga el compilador: el Swift no se compiló aquí (sin Mac).
7. En el servidor: `APNS_*` con la llave `.p8` del mismo equipo y `APNS_BUNDLE_ID` igual al bundle id de `Runner`; `APNS_SANDBOX=true` para compilaciones de desarrollo.

**Qué no se probó**

- El Swift no se compiló (sin Xcode); se revisó a mano: `@available(iOS 16.1, *)`, imports `ActivityKit`, `WidgetKit`, `SwiftUI` y `Flutter`, y las APIs de 16.1 y 16.2.
- ActivityKit y APNs reales, la decodificación del push del backend en un iPhone, el presupuesto de actualizaciones de Apple y la Dynamic Island en un teléfono.
- Pases de Apple contra Wallet: guardar el pase, que Wallet se registre, cancelar y ver el pase `voided`. Con un Apple ID gratis tampoco funcionaría (no puede firmar `aps-environment`; ver `docs/guia-instalar-ios-sin-mac.md`).
- Las rutas nuevas de `mock_api` solo se revisaron cargando el módulo con Node (no había `node_modules` para levantar el servidor).
