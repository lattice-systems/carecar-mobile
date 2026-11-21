import 'package:flutter/material.dart';

import '../tema/tema_carecar.dart';

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
];

/// Foto de un auto: la incluida en la app, si no la URL, si no un marcador.
class FotoAuto extends StatelessWidget {
  const FotoAuto({
    required this.modelo,
    required this.alto,
    this.url,
    this.radio = 16,
    super.key,
  });

  final String? modelo;
  final String? url;
  final double alto;
  final double radio;

  static const marcador = Key('foto_auto_marcador');

  @override
  Widget build(BuildContext context) {
    final vacio = Container(
      key: marcador,
      height: alto,
      width: double.infinity,
      color: TemaCareCar.azulSuave,
      child: const Icon(
        Icons.directions_car_outlined,
        size: 56,
        color: TemaCareCar.azulAgencia,
      ),
    );
    final asset = fotoDeModelo(modelo);
    final Widget imagen = asset != null
        ? Image.asset(
            asset,
            height: alto,
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: 'Foto de $modelo',
            errorBuilder: (_, _, _) => vacio,
          )
        : url != null
        ? Image.network(
            url!,
            height: alto,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => vacio,
          )
        : vacio;
    return ClipRRect(borderRadius: BorderRadius.circular(radio), child: imagen);
  }
}
