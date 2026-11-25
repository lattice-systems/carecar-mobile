import 'parser_ticket.dart';

/// De dónde sale la foto del ticket.
enum OrigenFoto { camara, galeria }

/// No se pudo tomar o leer la foto (permiso denegado, cámara no disponible).
///
/// No es un error de la bitácora: el formulario queda en blanco y se explica.
class FalloLecturaTicket implements Exception {
  const FalloLecturaTicket(this.permisoDenegado);

  /// La persona negó el permiso de la cámara o de las fotos.
  final bool permisoDenegado;

  @override
  String toString() => 'FalloLecturaTicket(permisoDenegado: $permisoDenegado)';
}

/// Toma la foto de un ticket y la lee **en el dispositivo** (V2-M18.02).
///
/// La foto no se sube ni se guarda: la implementación real la borra apenas
/// reconoce el texto. Una implementación de pruebas devuelve una lectura fija.
abstract interface class LectorTicket {
  /// Devuelve lo leído, una lectura vacía si el texto no se entendió, o nulo si
  /// la persona canceló. Lanza [FalloLecturaTicket] si no hubo permiso.
  Future<LecturaTicket?> leer(OrigenFoto origen);
}

/// Lector de pruebas y desarrollo: devuelve [lectura] (o falla con [fallo]).
class LectorTicketFake implements LectorTicket {
  LectorTicketFake({this.lectura, this.fallo});

  /// Lo que "se lee"; nulo simula que la persona canceló.
  final LecturaTicket? lectura;
  final FalloLecturaTicket? fallo;

  /// Origen de la última lectura pedida.
  OrigenFoto? ultimoOrigen;

  @override
  Future<LecturaTicket?> leer(OrigenFoto origen) async {
    ultimoOrigen = origen;
    final f = fallo;
    if (f != null) throw f;
    return lectura;
  }
}
