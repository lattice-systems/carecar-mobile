# Evidencia de pruebas en celular físico

Registra cada corrida del [guion por hito](guion-por-hito.md). Agrega una fila por caso y dispositivo. Una corrida en emulador o contra el simulador se registra en CI y se puede enlazar como evidencia complementaria.

| Hito | Caso | Dispositivo y SO | App y ambiente de API | Resultado | Evidencia o bloqueo |
| --- | --- | --- | --- | --- | --- |
| H0 | H0.1 | Pendiente | Pendiente | Pendiente | Falta registrar la instalación en celular. |
| H1 | H1.1 | Samsung SM-G781U, Android 13 | APK `E93F2B4F1669` · Agencia360 local | Pasa | Al abrir `carecar://garaje` sin sesión se mostró Acceso. Al entrar, se reanudó Mi garaje con el vehículo ficticio. `carecar://ruta-inexistente` volvió al menú utilizable. |
| H1 | H1.2 | Samsung SM-G781U, Android 13, ancho de 360 dp | APK `9ACEBC758A25` · desarrollo | Pasa | Botones, insignias, chips y avatares en [claro](capturas-h1/h1-galeria-claro.png), [oscuro](capturas-h1/h1-galeria-oscuro.png) y [texto al 200 % con desplazamiento](capturas-h1/h1-galeria-200.png). El avatar chico mostró ambas iniciales después de corregir el recorte. CI de golden se revisará en la fase final. |
| H1 | H1.3 | Samsung SM-G781U, Android 13 | APK `E93F2B4F1669`, relectura con `9ACEBC758A25` · Agencia360 local | Pasa | Cita ficticia del 1 de diciembre a las 09:00. La app confirmó, canceló y volvió a mostrarla como Cancelada incluso al reinstalar y reabrir. El cupo de la franja pasó de 3 a 2 y regresó a 3. |
| H2 | H2.1–H2.3 | Pendiente | Pendiente | Pendiente | — |
| H3 | H3.1–H3.3 | Pendiente | Pendiente | Pendiente | — |
| H4 | H4.1–H4.2 | Pendiente | Pendiente | Pendiente | — |
| H5 | H5.1–H5.2 | Pendiente | Pendiente | Pendiente | — |
| H6 | H6.1–H6.3 | Pendiente | Pendiente | Pendiente | — |
| H7 | H7.1–H7.2 | Pendiente | Pendiente | Pendiente | — |

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

Pasaron siete pruebas dirigidas de Flutter para Documentos y Acerca de. La corrida física corresponde a la implementación local. La adaptación de Documentos al contrato integrado de V2-M09.01 sigue pendiente.

### Rendimiento en Android físico

Se instaló el APK `desarrollo` en modo `profile`, SHA-256 `55F28931A0A77FE3A361CBC899C2442E752BC544C66B0D6AC143C054A8D401D5`, y se hizo un arranque en frío con la sesión de prueba guardada. El panel O8 registró una muestra. El primer cuadro de Flutter llegó en **449 ms** y la primera pantalla útil en **2265 ms**. Se estimaron **3 cuadros perdidos de 120 medidos**. El backend respondió HTTP 204 al evento y se desactivó el consentimiento al terminar.
