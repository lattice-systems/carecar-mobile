# Ocultar datos en el selector de apps y bloquear capturas (V2-M22.06)

Historia [V2-M22.06](../../plan/modulos/M22-seguridad-y-privacidad.md). Controles MASVS L1 relacionados: MSTG-STORAGE-9 (datos sensibles fuera de la vista previa al pasar a segundo plano) y MSTG-STORAGE-7 (datos sensibles fuera de la pantalla cuando no se necesitan).

## Qué hace

| Criterio | Mecanismo | Código |
| --- | --- | --- |
| Pantalla cubierta en segundo plano | Capa opaca con la marca al pasar a `inactive`, `hidden` o `paused`; se retira en `resumed`. Va por fuera del enrutador en `main.dart`. | `lib/nucleo/privacidad/cubierta_en_segundo_plano.dart` |
| iOS: instantánea del selector tapada | Vista nativa opaca en `sceneWillResignActive`, retirada en `sceneDidBecomeActive`. Sin canal ni dependencias. | `ios/Runner/SceneDelegate.swift` |
| Capturas bloqueadas solo en pago y documentos | `PantallaSegura` activa el bloqueo mientras esté en el árbol. Android usa `FLAG_SECURE` por un canal de plataforma. | `pantalla_segura.dart`, `proteccion_de_captura.dart`, `MainActivity.kt` |

## Decisiones

- **Canal propio en vez de paquete**: son 15 líneas de Kotlin. Un paquete (p. ej. `flutter_windowmanager`) añade una dependencia que pasa por el check requerido "Revisión de dependencias", muchos están sin mantenimiento y no necesitamos nada más que un flag.
- **Por pantalla, no global**: `FLAG_SECURE` en toda la app impediría capturas legítimas (soporte, catálogo). Un contador de pantallas activas evita liberar el flag mientras quede una pantalla segura apilada.
- **Interfaz + fake**: `ProteccionDeCaptura` (`proteccionDeCapturaProvider`) se sustituye en pruebas por `ProteccionDeCapturaFake`.

## Límites por plataforma

- **Android**: `FLAG_SECURE` bloquea capturas, grabación y deja la ventana en negro en el selector de apps. Fuera de pantallas seguras, la vista previa de Recientes depende de la cubierta de Flutter: si el sistema toma la imagen antes de que el motor repinte, puede verse un cuadro previo. Mitigación posible: activar `FLAG_SECURE` en toda la app (descartado hoy).
- **iOS**: el sistema **no permite bloquear capturas de pantalla** a las apps. Lo único que se puede hacer es (a) cubrir la ventana al pasar a segundo plano (hecho) y (b) detectar `UIScreen.isCaptured` / `userDidTakeScreenshotNotification` y tapar o avisar. (b) queda **pendiente** como historia nueva (no está en los criterios de M22.06); por ahora las pantallas de pago y documentos en iOS se pueden capturar y grabar.
- La cubierta nativa de iOS se valida a mano en un iPhone (no hay prueba automática de la instantánea del sistema): abrir la app, ir al selector de apps y comprobar que se ve el fondo y no datos.

## Cómo usarlo desde un módulo

```dart
GoRoute(
  path: rutaPagoDetalle,
  name: 'pago-detalle',
  builder: (c, s) => PantallaSegura(child: PantallaPago(id: s.pathParameters['id']!)),
),
```

En pruebas: `proteccionDeCapturaProvider.overrideWithValue(ProteccionDeCapturaFake())` y comprobar `fake.bloqueada`. M08 (pagos y facturas) y M09 (documentos y vencimientos) deben envolver **todas** sus pantallas con datos de pago o archivos del cliente (visor de PDF incluido).
