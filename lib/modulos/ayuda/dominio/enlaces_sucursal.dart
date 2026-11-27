import 'sucursal.dart';

/// `tel:` para abrir el marcador, o nulo si la sucursal no tiene teléfono.
///
/// Deja solo el signo más y los dígitos: los espacios y guiones de «+52 477
/// 000 0000» no van en el enlace.
Uri? enlaceDeLlamada(Sucursal sucursal) {
  final telefono = sucursal.telefono;
  if (telefono == null) return null;
  final numero = telefono.replaceAll(RegExp('[^+0-9]'), '');
  return numero.isEmpty ? null : Uri(scheme: 'tel', path: numero);
}

/// Enlace que abre la app de mapas del teléfono con la ruta a la sucursal.
///
/// En iPhone, Mapas de Apple; en Android, `geo:`, que ofrece la app de mapas
/// que la persona tenga. Con `apple` en falso y sin app de mapas, el sistema
/// no lo abre y la pantalla avisa.
Uri enlaceComoLlegar(Sucursal sucursal, {required bool apple}) {
  final destino = '${sucursal.latitud},${sucursal.longitud}';
  if (apple) {
    return Uri.https('maps.apple.com', '/', {
      'daddr': destino,
      'q': sucursal.nombre,
    });
  }
  return Uri.parse(
    'geo:$destino?q=$destino(${Uri.encodeComponent(sucursal.nombre)})',
  );
}
