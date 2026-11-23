import 'modelo_vigente.dart';

/// Un modelo del catalogo con su galeria, sus versiones y su ficha resumida.
///
/// Dart puro, como [ModeloVigente]. Las tres listas pueden estar vacias
/// mientras la agencia no las capture, y la pantalla lo resuelve.
class DetalleModelo {
  const DetalleModelo({
    required this.modelo,
    this.fotos = const [],
    this.versiones = const [],
    this.ficha = const [],
  });

  final ModeloVigente modelo;
  final List<FotoModelo> fotos;
  final List<VersionDeModelo> versiones;
  final List<DatoFicha> ficha;
}

/// Una foto de la galeria.
class FotoModelo {
  const FotoModelo({required this.url, this.descripcion, this.color});

  final String url;

  /// Lo que lee el lector de pantalla. Si falta, la pantalla arma uno.
  final String? descripcion;
  final String? color;
}

/// Una version que se vende del mismo modelo.
class VersionDeModelo {
  const VersionDeModelo({
    required this.id,
    required this.nombre,
    this.precioDesde,
  });

  /// Id del modelo del catalogo de esa version, sirve para abrir su detalle.
  final int id;
  final String nombre;
  final double? precioDesde;
}

/// Un dato de la ficha resumida, como "Motor: 1.6 L".
class DatoFicha {
  const DatoFicha({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;
}
