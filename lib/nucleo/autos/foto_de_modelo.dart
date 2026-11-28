/// Fotos de modelos incluidas en la app, resueltas por el nombre del modelo.
///
/// Viven en el núcleo para que la v2 (el inicio, el garaje) las use sin
/// depender de `lib/widgets` de la v1.
library;

/// Ruta de la foto incluida en la app para un modelo, o `null` si no hay.
///
/// Las fotos viven en `assets/autos/` (ver `ATRIBUCIONES.md` ahi mismo) para
/// que se vean sin internet. Se resuelve por el nombre del modelo, sin
/// distinguir mayusculas ni guiones: «X-Trail», «xtrail» y «X TRAIL» dan igual.
String? fotoDeModelo(String? modelo) {
  final clave = claveDeModelo(modelo);
  return clave == null ? null : 'assets/autos/$clave.jpg';
}

/// Clave corta de un modelo («X-Trail» → `xtrail`), o `null` si no se conoce.
///
/// La usan las fotos y la ficha tecnica, para que ambas coincidan siempre.
String? claveDeModelo(String? modelo) {
  if (modelo == null) return null;
  final m = modelo.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  // «Z» es una sola letra: solo coincide completo, para no chocar con otros.
  if (m == 'z' || m == 'nissanz') return 'z';
  for (final nombre in fotosDeModelos) {
    if (m.contains(nombre)) return nombre;
  }
  return null;
}

/// Modelos con foto en `assets/autos/` (sin la «z», que se resuelve aparte).
const fotosDeModelos = [
  'march',
  'versa',
  'kicks',
  'sentra',
  'xtrail',
  'frontier',
  'leaf',
  'ariya',
  'gtr',
  'altima',
  'pathfinder',
  'murano',
  'armada',
  'titan',
  'urvan',
  'maxima',
  'juke',
  'qashqai',
  'patrol',
  'tiida',
  'note',
  'jetta',
  'tsuru',
];
