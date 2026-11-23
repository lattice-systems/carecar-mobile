/// Una especificacion: "Cilindrada" -> "1.6 L".
///
/// Los datos de la agencia traen su `clave` ya escrita. Los del respaldo local
/// traen solo un `codigo` estable ("potencia") que la pantalla traduce al
/// idioma de la app.
class EspecificacionFicha {
  const EspecificacionFicha({
    required this.valor,
    this.clave = '',
    this.codigo,
  });

  final String clave;
  final String valor;
  final String? codigo;
}

/// Un grupo de especificaciones ("Motor", "Transmision") que la pantalla
/// muestra plegable.
///
/// Igual que la especificacion: `titulo` de la agencia o `codigo` del respaldo.
class SeccionFicha {
  const SeccionFicha({
    required this.especificaciones,
    this.titulo = '',
    this.codigo,
  });

  final String titulo;
  final String? codigo;
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
            titulo: (s['nombre'] ?? s['titulo'])! as String,
            especificaciones: [
              for (final e
                  in (s['especificaciones']! as List)
                      .cast<Map<String, Object?>>())
                EspecificacionFicha(
                  clave: (e['nombre'] ?? e['clave'])! as String,
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
