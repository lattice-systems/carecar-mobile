# 0006 · Mapas, ubicación y geocodificación

**Estado:** Aceptada

## Contexto

Varias historias necesitan un mapa: M17 (guardar direcciones con pin y seguir al chofer en vivo), M11 (compartir la ubicación al pedir ayuda), M02 (ubicar la agencia) y M16 (ubicar la prueba de manejo). V2-T02.09 pide un componente `Mapa` con pin arrastrable, ubicación propia y un marcador en movimiento, y exige que el proveedor de mapas y la geocodificación se elijan en una decisión. Hoy la app no tiene ningún paquete de mapas ni de ubicación.

Restricciones que ya están escritas en el plan:

- La ubicación solo se pide en primer plano y solo mientras la solicitud está abierta; nunca en segundo plano (M11).
- El seguimiento del chofer solo muestra su posición en los estados `en_camino` y `de_regreso` (M17).
- Todo componente cumple el sistema de diseño v2: colores de los tokens, claro y oscuro, lector de pantalla y letra al 200 %.

Hay tres decisiones, no una: quién dibuja el mapa, de dónde sale la posición del teléfono y cómo se convierte una dirección en coordenadas y al revés.

## Opciones

### Dibujar el mapa

1. **`google_maps_flutter`.** Mejor calidad y datos de comercios. Pide una llave por plataforma y facturación en Google Cloud, cobra por carga de mapa y el estilo oscuro es un JSON aparte. El mapa es una vista nativa: no se puede probar con pruebas de widget.
2. **`flutter_map` con teselas de un servidor que se configura.** Es Dart puro, sin llave obligatoria, con marcadores y capas como widgets normales, así que se pintan con los tokens y se prueban sin dispositivo. El servidor público de OpenStreetMap **no se puede usar en producción** (su política lo prohíbe para apps con tráfico real); en producción hay que apuntar a un proveedor de teselas contratado o propio.
3. **`mapbox_maps_flutter`.** Buena calidad y estilos, pero pide un token secreto de descarga además del público, y el paquete es nativo.

### Posición del teléfono

1. **`geolocator`.** Permisos, posición actual y flujo de posiciones en una sola API para Android e iOS.
2. **Plugin propio por canal de plataforma.** Más trabajo sin ventaja.

### Geocodificación (dirección a coordenadas y al revés)

1. **API de Google Geocoding.** Precisa, con costo por consulta y la misma llave de Google.
2. **Nominatim público.** Gratis, pero con límite de una consulta por segundo y política de uso que no admite una app en producción.
3. **`geocoding` (geocodificador nativo del sistema).** Sin llave y sin costo, usa el de Android y el de iOS. Calidad variable según el país y no hay garantía de disponibilidad.

## Decisión

- **Mapa:** opción 2, `flutter_map`, con la URL de teselas y el nombre del proveedor en la configuración del flavor, no en el código. Desarrollo y pruebas usan las teselas públicas de OpenStreetMap con tráfico mínimo; producción apunta a un proveedor que el PO contrate. Se elige porque el mapa queda dentro del árbol de widgets: se tiñe con los tokens en claro y oscuro, se prueba con `flutter test` y no obliga a facturar antes de tener usuarios.
- **Posición:** `geolocator`, pedida solo en primer plano.
- **Geocodificación:** `geocoding` nativo para la primera versión. Si en M17 la calidad en las colonias de la ciudad de la agencia no alcanza, se cambia por un servicio de pago sin tocar las pantallas.
- **Aislamiento:** ningún módulo importa estos paquetes. `lib/nucleo/mapas/` define las interfaces `ProveedorUbicacion` y `Geocodificador` y el componente `Mapa` recibe teselas y marcadores como datos. Cambiar de proveedor es cambiar una implementación.

## Consecuencias

- Tres dependencias nuevas (`flutter_map`, `geolocator`, `geocoding`) que pasan por la revisión de dependencias del CI.
- Hay que declarar el permiso de ubicación en primer plano en `AndroidManifest.xml` e `Info.plist`, con el texto que explica para qué se usa.
- **Costo y legal, que decide el PO antes de producción:** qué proveedor de teselas se contrata y cuánto cuesta por mes, y la atribución a OpenStreetMap que exige la licencia.
- La calidad del geocodificador nativo no está garantizada. Se mide en M17.01 con direcciones reales; el criterio es que una dirección válida de la ciudad de la agencia se ubique a menos de 100 m.
- El marcador en movimiento (seguimiento del chofer) recibe posiciones cada pocos segundos y las anima con el token `base`; con "reducir movimiento" salta sin animar.
- Las pruebas del componente no dibujan teselas reales: se prueba con un proveedor falso que devuelve cuadros de un color.

## Qué se necesita para aceptarla

1. El PO confirma el proveedor de teselas de producción y su costo.
2. El equipo confirma que el geocodificador nativo es aceptable para la primera versión.
3. SM y PO aprueban este archivo en el PR; solo entonces V2-T02.09 escribe código.

## Implementación

Hecho: dependencias (`flutter_map`, `latlong2`, `geolocator`, `geocoding`), permisos de ubicación en primer plano en Android e iOS y `lib/nucleo/mapas/` con las interfaces, implementaciones, fakes y proveedores Riverpod. El componente `Mapa` (V2-T02.09) está en `lib/nucleo/diseno/componentes/mapa.dart` y es el que importa `flutter_map` y `latlong2`. Mientras M17 no retire su mapa provisional, ese archivo también los importa. Sigue abierto, antes de producción, el proveedor de teselas contratado y su costo.
