# Vehículos y manuales locales

Los datos opcionales `marca`, `tipo`, `version` y `color` se leen del JSON y se
transfieren junto con el mismo `Vehiculo` seleccionado al detalle. El mock los
conserva en su respuesta; si faltan o son nulos se muestra «No disponible».
Son una extensión local opcional: el contrato v1.1 no los declara ni prohíbe
propiedades adicionales. No se modificó OpenAPI y no se garantiza que el backend
real los entregue hasta que el equipo los incorpore formalmente.

Los ejemplos del mock son ficticios: Versa Sense 2024 Blanco, Kicks Advance 2023
Gris y March Sense 2020 Blanco. Las versiones y colores de Versa/Kicks son datos
de prueba, no información verificada de vehículos reales. Los demás registros y
sus relaciones se conservan.

## Añadir un manual

1. Guardar el PDF original en
   `assets/Manuales/{Marca}/{Tipo}/{Año}/{Marca}{Tipo}{Año}Manual.pdf`.
2. Declarar la carpeta específica del año en `flutter.assets` de `pubspec.yaml`.
   Flutter no incluye recursivamente las subcarpetas de una carpeta declarada.
3. Asegurar que el vehículo entregue `marca`, `tipo` y `anio` por la API.
4. Ejecutar `flutter pub get` y reiniciar/compilar la app para empaquetar el asset.

No se crea una condición nueva por vehículo. `ResolverManual` coteja la ruta
calculada con el manifest de assets; ignora espacios y diferencias de mayúsculas,
pero utiliza la ruta real con su capitalización. No usa VIN, versión ni el texto
comercial de `modelo`. Nunca elige otro año ni resuelve coincidencias ambiguas.

`ServicioManuales` entrega un `DocumentoManual` (título, identificador y bytes).
`ManualesLocales` consulta el manifest y carga el asset. `PantallaManual` recibe
el documento y lo presenta con `pdfx`, sin conocer la estructura de carpetas.
Se puede implementar otro servicio para una futura descarga sin cambiar el visor.
No hay consultas al endpoint remoto de manuales ni caché persistente.

El lector usa `PdfViewPinch`: desplazamiento vertical, zoom por pellizco y
contador de páginas. Ofrece carga, error con reintento, documento no disponible,
datos incompletos y regreso al detalle. Las citas y el historial siguen pendientes.

## Plataformas

`pdfx ^2.11.0` soporta Android/iOS y también Web/Windows/macOS. No soporta Linux.
En iOS es necesario compilar con Xcode/macOS; no se verificó aquí.
Para Web se incluye la configuración PDF.js indicada por la biblioteca; requiere
acceso a su CDN. Los PDF siguen siendo assets locales. Web no se da por validado
en navegador hasta ejecutar una prueba específica.

Si el mock estaba abierto antes del cambio, reiniciarlo: conserva el estado en
memoria. Se actualizaron la semilla y los atributos de los registros del archivo
local `db.json` conservando las cuentas y relaciones existentes.
