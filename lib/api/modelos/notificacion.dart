import 'comun.dart';

/// Un aviso de la bandeja, tal como lo manda el backend · V2-M06.04.
///
/// Contrato v2 2.31.0, esquema `Notificacion`. `destino` es obligatorio ahi:
/// `notificacion.destino` es `not null` en la base, asi que todo aviso lleva a
/// algun lado.
class Notificacion {
  const Notificacion({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.cuerpo,
    required this.destino,
    required this.creadaEn,
    this.leidaEn,
  });

  factory Notificacion.fromJson(Map<String, Object?> json) => Notificacion(
    id: leerEntero(json['id'], 'id'),
    categoria: leerTexto(json['categoria'], 'categoria'),
    titulo: leerTexto(json['titulo'], 'titulo'),
    cuerpo: leerTexto(json['cuerpo'], 'cuerpo'),
    destino: leerTexto(json['destino'], 'destino'),
    creadaEn: leerMomentoUtc(json['creadaEn'], 'creadaEn'),
    leidaEn: json['leidaEn'] == null
        ? null
        : leerMomentoUtc(json['leidaEn'], 'leidaEn'),
  );

  final int id;
  final String categoria;
  final String titulo;
  final String cuerpo;

  /// Ruta interna de la app a la que lleva tocarlo (V2-M06.03).
  final String destino;
  final DateTime creadaEn;

  /// Nulo si sigue sin leer.
  final DateTime? leidaEn;
}

/// Una pagina de la bandeja.
///
/// No usa `Pagina<T>` porque trae un dato mas que no es de la pagina:
/// [noLeidas] es de **toda la cuenta**, y es lo que la app pinta en el
/// contador. Meterlo en el generico obligaria a que todas las paginas lo
/// llevaran.
class PaginaDeNotificaciones {
  const PaginaDeNotificaciones({
    required this.contenido,
    required this.pagina,
    required this.totalPaginas,
    required this.noLeidas,
  });

  factory PaginaDeNotificaciones.fromJson(Map<String, Object?> json) =>
      PaginaDeNotificaciones(
        contenido: ((json['contenido'] as List?) ?? const [])
            .cast<Map<String, Object?>>()
            .map(Notificacion.fromJson)
            .toList(growable: false),
        pagina: leerEntero(json['pagina'], 'pagina'),
        totalPaginas: leerEntero(json['totalPaginas'], 'totalPaginas'),
        noLeidas: leerEntero(json['noLeidas'], 'noLeidas'),
      );

  final List<Notificacion> contenido;
  final int pagina;
  final int totalPaginas;

  /// Sin leer en toda la cuenta, no en esta pagina.
  final int noLeidas;

  bool get hayMas => pagina + 1 < totalPaginas;
}
