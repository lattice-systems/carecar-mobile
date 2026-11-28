import 'comun.dart';

/// Preferencias de avisos del contrato v2 · V2-M06.05.
///
/// Esquema `PreferenciasNotificacion`. El mismo cuerpo se lee en el `GET` y se
/// manda en el `PUT`, asi que esta clase viaja en los dos sentidos.
class PreferenciasNotificacion {
  const PreferenciasNotificacion({
    required this.categorias,
    this.silencioDesde,
    this.silencioHasta,
  });

  factory PreferenciasNotificacion.fromJson(Map<String, Object?> json) =>
      PreferenciasNotificacion(
        categorias: ((json['categorias'] as List?) ?? const [])
            .cast<Map<String, Object?>>()
            .map(PreferenciaNotificacion.fromJson)
            .toList(growable: false),
        silencioDesde: json['silencioDesde'] == null
            ? null
            : leerTexto(json['silencioDesde'], 'silencioDesde'),
        silencioHasta: json['silencioHasta'] == null
            ? null
            : leerTexto(json['silencioHasta'], 'silencioHasta'),
      );

  /// Todas las categorias, tambien las que el cliente no ha tocado.
  final List<PreferenciaNotificacion> categorias;

  /// `HH:mm` en la zona de la agencia. Van juntos: uno sin el otro es 400.
  final String? silencioDesde;
  final String? silencioHasta;

  Map<String, Object?> aJson() => {
    'categorias': [for (final c in categorias) c.aJson()],
    'silencioDesde': silencioDesde,
    'silencioHasta': silencioHasta,
  };
}

/// Una categoria y si se quiere recibir.
class PreferenciaNotificacion {
  const PreferenciaNotificacion({required this.categoria, required this.push});

  factory PreferenciaNotificacion.fromJson(Map<String, Object?> json) =>
      PreferenciaNotificacion(
        categoria: leerTexto(json['categoria'], 'categoria'),
        push: leerBool(json['push'], 'push'),
      );

  final String categoria;
  final bool push;

  Map<String, Object?> aJson() => {'categoria': categoria, 'push': push};
}
