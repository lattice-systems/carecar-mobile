/// Una especificacion: "Cilindrada" -> "1.6 L".
class EspecificacionFicha {
  const EspecificacionFicha({required this.clave, required this.valor});

  final String clave;
  final String valor;
}

/// Un grupo de especificaciones ("Motor", "Transmision") que la pantalla
/// muestra plegable.
class SeccionFicha {
  const SeccionFicha({required this.titulo, required this.especificaciones});

  final String titulo;
  final List<EspecificacionFicha> especificaciones;
}

/// Ficha tecnica de un vehiculo, por modelo y ano (V2-M02.04).
///
/// Dart puro. `delRespaldo` es verdadero cuando salio de lo que trae la app y
/// no de la agencia: la pantalla lo avisa.
class FichaTecnicaVehiculo {
  const FichaTecnicaVehiculo({
    required this.secciones,
    this.delRespaldo = false,
  });

  /// Cuerpo de `GET /vehiculos/{id}/ficha-tecnica`:
  /// `{vehiculoId, modelo, anio, secciones: [{titulo, especificaciones:
  /// [{clave, valor}]}]}`. Lanza `FormatException` si no trae `secciones`.
  factory FichaTecnicaVehiculo.fromJson(Map<String, Object?> json) {
    final secciones = json['secciones'];
    if (secciones is! List) {
      throw const FormatException('La ficha no trae «secciones».');
    }
    return FichaTecnicaVehiculo(
      secciones: [
        for (final s in secciones.cast<Map<String, Object?>>())
          SeccionFicha(
            titulo: s['titulo']! as String,
            especificaciones: [
              for (final e
                  in (s['especificaciones']! as List)
                      .cast<Map<String, Object?>>())
                EspecificacionFicha(
                  clave: e['clave']! as String,
                  valor: e['valor']! as String,
                ),
            ],
          ),
      ],
    );
  }

  final List<SeccionFicha> secciones;
  final bool delRespaldo;
}
