import '../../../nucleo/mapas/mapas.dart';

/// Campos de una dirección que la persona captura y el contrato valida.
enum CampoDireccion { alias, calle, colonia, cp, ciudad, ubicacion }

/// Una dirección ya guardada en la cuenta del cliente (V2-M17.01).
///
/// Dart puro. `ubicacion` es el pin del mapa: el backend la exige y con ella
/// decide la cobertura y calcula el costo.
class DireccionGuardada {
  const DireccionGuardada({
    required this.id,
    required this.alias,
    required this.calle,
    required this.colonia,
    required this.cp,
    required this.ciudad,
    required this.ubicacion,
  });

  final int id;
  final String alias;
  final String calle;
  final String colonia;
  final String cp;
  final String ciudad;
  final Coordenada ubicacion;

  /// «Calle, colonia, 06600 Ciudad», lista para mostrar bajo el alias.
  String get resumen => '$calle, $colonia, $cp $ciudad';

  /// El mismo contenido como borrador, para editarlo.
  BorradorDireccion comoBorrador() => BorradorDireccion(
    alias: alias,
    calle: calle,
    colonia: colonia,
    cp: cp,
    ciudad: ciudad,
    ubicacion: ubicacion,
  );
}

/// Lo que la persona escribe al guardar o editar una dirección.
///
/// Valida con las mismas reglas del contrato (`NuevaDireccion`) para avisar
/// antes de ir a la red; el servidor vuelve a validar.
class BorradorDireccion {
  const BorradorDireccion({
    required this.alias,
    required this.calle,
    required this.colonia,
    required this.cp,
    required this.ciudad,
    required this.ubicacion,
  });

  final String alias;
  final String calle;
  final String colonia;
  final String cp;
  final String ciudad;

  /// Nulo mientras no se ha puesto el pin.
  final Coordenada? ubicacion;

  static final _cinco = RegExp(r'^[0-9]{5}$');

  /// Campos que no cumplen el contrato, en el orden del formulario.
  List<CampoDireccion> get camposInvalidos {
    bool mal(String valor, int maximo) =>
        valor.trim().isEmpty || valor.trim().length > maximo;
    return [
      if (mal(alias, 40)) CampoDireccion.alias,
      if (mal(calle, 120)) CampoDireccion.calle,
      if (mal(colonia, 80)) CampoDireccion.colonia,
      if (!_cinco.hasMatch(cp.trim())) CampoDireccion.cp,
      if (mal(ciudad, 80)) CampoDireccion.ciudad,
      if (ubicacion == null || !ubicacion!.esValida) CampoDireccion.ubicacion,
    ];
  }
}
