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
| GET | `/citas/{id}/pase?plataforma=apple\|google` | Pase firmado por el backend con el QR del comprobante (V2-M02.11). |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M25.01 | Como cliente quiero un widget con mi próxima cita para verla sin abrir la app | Android (Glance) e iOS (WidgetKit) · fecha, hora y vehículo de la próxima cita confirmada; sin cita invita a agendar · un toque abre la cita · se actualiza al agendar o cancelar | | V2-M02.09, V2-T01.03 |
| V2-M25.02 | Como cliente quiero ver en el widget el estado de mi auto en el taller para seguirlo de un vistazo | Con orden abierta muestra la etapa actual (M04); sin orden, vuelve a la próxima cita | | V2-M04.02, V2-M25.01 |
| V2-M25.03 | Como cliente quiero guardar mi cita en Wallet para presentarla en recepción | Botón en el comprobante · pase firmado por el backend con el QR · si la cita se cancela, el pase queda vencido | ✅ | V2-M02.11 |
| V2-M25.04 | Como cliente quiero accesos rápidos desde el ícono para ir directo a lo que más uso | Mantener presionado el ícono muestra Agendar, Mi auto y SOS · cada uno abre su pantalla | | V2-T01.03 |
| V2-M25.05 | Como cliente de iPhone quiero ver el estado del taller en la pantalla bloqueada para seguir mi servicio | Live Activity con la etapa actual mientras la orden esté abierta · termina al entregar el auto · se actualiza por push desde el backend | ✅ | V2-M04.03 |

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
