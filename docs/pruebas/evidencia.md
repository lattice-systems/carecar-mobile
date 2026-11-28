# Evidencia de pruebas en celular físico

Registra cada corrida del [guion por hito](guion-por-hito.md). Agrega una fila por caso y dispositivo. Una corrida en emulador o contra el simulador se registra en CI y se puede enlazar como evidencia complementaria.

| Hito | Caso | Dispositivo y SO | App y ambiente de API | Resultado | Evidencia o bloqueo |
| --- | --- | --- | --- | --- | --- |
| H0 | H0.1 | Samsung SM-G781U, Android 13 | CareCar Pruebas 1.0.0 (3), dev `eba35efe` | Pasa | Instalación por USB, apertura de Bienvenida y llegada a Acceso al tocar «Saltar». [Corrida H0](#corrida-de-instalación-h0-en-android) |
| H1 | H1.1 | Samsung SM-G781U, Android 13 | APK `E93F2B4F1669` · Agencia360 local | Pasa | Al abrir `carecar://garaje` sin sesión se mostró Acceso. Al entrar, se reanudó Mi garaje con el vehículo ficticio. `carecar://ruta-inexistente` volvió al menú utilizable. |
| H1 | H1.2 | Samsung SM-G781U, Android 13, ancho de 360 dp | APK `9ACEBC758A25` · desarrollo | Pasa | Botones, insignias, chips y avatares en [claro](capturas-h1/h1-galeria-claro.png), [oscuro](capturas-h1/h1-galeria-oscuro.png) y [texto al 200 % con desplazamiento](capturas-h1/h1-galeria-200.png). El avatar chico mostró ambas iniciales después de corregir el recorte. CI de golden se revisará en la fase final. |
| H1 | H1.3 | Samsung SM-G781U, Android 13 | APK `E93F2B4F1669`, relectura con `9ACEBC758A25` · Agencia360 local | Pasa | Cita ficticia del 1 de diciembre a las 09:00. La app confirmó, canceló y volvió a mostrarla como Cancelada incluso al reinstalar y reabrir. El cupo de la franja pasó de 3 a 2 y regresó a 3. |
| H2 | H2.1–H2.3 | Pendiente | Pendiente | Pendiente | — |
| H3 | H3.1–H3.3 | Pendiente | Pendiente | Pendiente | — |
| H4 | H4.1–H4.2 | Pendiente | Pendiente | Pendiente | — |
| H3 | H3.3 · Documentos | Samsung SM-G781U, Android 13 | dev `5895971c` · Agencia360 local V66 | Parcial | Estados, factura, garantía y calendario de dos autos. El selector de galería se abrió y la carga quedó pendiente. Alertas y campaña pendientes. [Corrida Android](#corrida-de-documentos-y-encuestas-en-android) |
| H4 | H4.1 · Encuesta | Samsung SM-G781U, Android 13 | dev `5895971c` · Agencia360 local V66 | Parcial | Tarjeta, formulario y aplazamiento de una orden. Push y chat pendientes. [Corrida Android](#corrida-de-documentos-y-encuestas-en-android) |
| H5 | H5.1–H5.2 | Pendiente | Pendiente | Pendiente | — |
| H6 | H6.1–H6.3 | Pendiente | Pendiente | Pendiente | — |
| H7 | H7.1–H7.2 | Pendiente | Pendiente | Pendiente | — |

## Corrida de instalación H0 en Android

Se instaló por USB el APK `app-pruebas-release.apk` del commit `eba35efe` de `dev` en un Samsung SM-G781U con Android 13. Android confirmó la instalación de `com.carecar.carecar_mobile.pruebas`, versión 1.0.0, compilación 3. La app mostró Bienvenida y, después de tocar «Saltar», Acceso con correo, contraseña e «Iniciar sesión». SHA-256 del APK: `46D39EFEBD2AAB502B557ACC4184C4071DF226210EBB3EB432C089A065326C5F`.

Este caso termina en Acceso. El APK se instala con `adb install -r app-pruebas-release.apk` y se abre desde «CareCar Pruebas». [Corrida de dev](https://github.com/lattice-systems/carecar-mobile/actions/runs/46103029307) · [APK en el artefacto](https://github.com/lattice-systems/carecar-mobile/actions/runs/46103029307/artifacts/15246488656).

## Corrida física H1

Se realizó el 27 de noviembre de 2026 por USB con `adb reverse tcp:8080 tcp:8080`. El APK fue de desarrollo y depuración, con Flutter 3.50.1, `MODULOS_V2=vehiculos,citas` y base `http://localhost:8080/api/v1/app`. CareCar usó el código de trabajo sobre `869e6158`. Agencia360 se ejecutó desde el código de trabajo sobre `4f25950`, con PostgreSQL 16.15 aislado y las migraciones del repositorio aplicadas hasta V47.

- APK de los recorridos de enlace y cita, SHA-256 `E93F2B4F1669FCAEC1BBDB071E9FAEE08970A137D02D836F3DADBF70002DB39F`.
- APK con la corrección del avatar, SHA-256 `9ACEBC758A25A1A45F189B6BFE64148F9AA51101907A18416C535F22E093A655`.

La compilación se hizo en una copia temporal fuera de OneDrive con Android Gradle Plugin 9.1.1. En Windows sin enlaces simbólicos, se apartó la plataforma Windows solo en esa copia antes de `flutter pub get --offline`, para generar el registro de plugins Android.

## Corrida física de Haziel en Android

Samsung SM-G781U con Android 13, conectado por USB el 27 de noviembre de 2026. Se usó un APK `desarrollo` de depuración de la copia local de CareCar, versión 1.0.0. SHA-256 `E351EEA1653F950634A49327278D5E3F2A2849C5C0DC1A7093E4FFB4E0FC17DE`. Agencia360 corrió con datos ficticios y 46 migraciones de la copia local aplicadas en PostgreSQL embebido.

| Caso | Resultado observado |
| --- | --- |
| H3.3 · V2-M09.02 | Haziel capturó una hoja de prueba con la cámara y guardó el documento. La API respondió HTTP 201 y la app volvió al listado con «Seguro · Tu archivo». La relectura devolvió un JPEG de 990 × 2200 px y 391 299 bytes. El documento seguía en la lista después de reiniciar el proceso de la app. |
| H3.3 · V2-M09.03 | La factura y la póliza de garantía publicadas para el March aparecieron como documentos de agencia. Ambos archivos se abrieron en el visor y mostraron «Página 1 de 1». |
| H3.3 · V2-M09.06 | El 2 de diciembre quedó marcado con dos vencimientos. Al seleccionarlo, la lista mostró una póliza de garantía para el March y otra para el Sentra. |
| H4.2 · V2-M27.05 | Acerca de mostró la versión instalada 1.0.0. Se abrió Licencias de software y el WebView mostró el documento local de términos, incluidos sus encabezados. |

Pasaron siete pruebas dirigidas de Flutter para Documentos y Acerca de. La corrida física corresponde a la implementación local. La validación sobre el contrato integrado de V2-M09.01 se registró en la corrida de Android descrita abajo.

### Rendimiento en Android físico

Se instaló el APK `desarrollo` en modo `profile`, SHA-256 `55F28931A0A77FE3A361CBC899C2442E752BC544C66B0D6AC143C054A8D401D5`, y se hizo un arranque en frío con la sesión de prueba guardada. El panel O8 registró una muestra. El primer cuadro de Flutter llegó en **449 ms** y la primera pantalla útil en **2265 ms**. Se estimaron **3 cuadros perdidos de 120 medidos**. El backend respondió HTTP 204 al evento y se desactivó el consentimiento al terminar.

## Corrida de Documentos y Encuestas en Android

Samsung SM-G781U, Android 13, por USB. APK de desarrollo y depuración de `dev` en `5895971c`, SHA-256 `7C42B0CC96D384052328A224B30DB102CFE2093C0949E042ABEFE1AE5CF184B8`. La compilación temporal usó Flutter 3.50.1, Android Gradle Plugin 9.1.1 y el registro de plugins Android generado en esa copia. La API apuntó a Agencia360 `c5f8215`, con PostgreSQL 16.15 aislado y migraciones hasta V66. Las cuentas, vehículos y documentos eran ficticios.

| Caso | Resultado observado |
| --- | --- |
| H2.1 · Acceso normal | Inicio de sesión con una cuenta ficticia y aceptación del aviso vigente. La app abrió Mi garaje. Quedan contraseña temporal y recuperación para completar el caso. |
| H3.3 · Listado de documentos | El March mostró verificación vencida hacía 2 días y póliza por vencer en 5 días. La API local devolvió HTTP 404 al intentar listar un vehículo ajeno con la segunda cuenta. |
| H3.3 · Foto del cliente | El formulario abrió el selector de Android. La carga del JPEG desde esta compilación queda por repetir. |
| H3.3 · PDF de agencia | La factura y la garantía publicadas en la API aparecieron en el listado integrado. Cada una abrió el visor y mostró «Página 1 de 1». |
| H3.3 · Calendario | Al seleccionar el 2 de diciembre, la lista mostró la póliza del March y la del Sentra. |
| H4.1 · Encuesta | La tarjeta abrió las encuestas de March y Sentra. Al posponer la del March, quedó visible solo la del Sentra. PostgreSQL registró el aplazamiento para la orden del March. |

## Encuestas de servicio (M15)

La prueba de widgets abre la tarjeta, aplaza la encuesta, envía una respuesta y pide contacto tras un NPS de 5. La prueba de contrato comprueba el aplazamiento, el rechazo de una segunda respuesta y la solicitud de contacto contra la API simulada. La interfaz se revisó con datos de prueba a 390 × 844 píxeles.

- [Tarjeta en Inicio](capturas-m15/inicio-claro.png)
- [Formulario claro](capturas-m15/formulario-claro.png)
- [Formulario oscuro](capturas-m15/formulario-oscuro.png)
- [Formulario con texto al 200 %](capturas-m15/formulario-texto-200.png)

## Fallos que solo aparecieron contra la API real

Probando la app de producción con la cuenta de demo contra Azure salieron tres errores que `mock_api` no reproducía:

| Pantalla | Qué pasaba | Causa | Arreglo |
| --- | --- | --- | --- |
| Manuales | «Manual no disponible» aunque el manual existía | La API armaba la URL firmada con `http://` y la app solo baja archivos por https | backend #124: `server.forward-headers-strategy=framework` en producción |
| Catálogo (detalle y comparar) | «No encontramos el modelo» | `GET /app/catalogo/{id}` solo existía en el contrato y en `mock_api` | backend #125: endpoint, migración V67 y datos de ejemplo |
| Bitácora y «agregar a mi cita» de la tienda | No cargaban los gastos ni las citas | Pedían páginas de 100 y la API acepta de 1 a 50 | `tamano` de 50; `test/arquitectura/paginas_de_hasta_50_test.dart` lo vigila |
