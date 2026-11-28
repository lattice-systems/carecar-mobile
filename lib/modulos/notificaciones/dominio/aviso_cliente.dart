import '../../../nucleo/avisos/destino_de_aviso.dart';

/// Un aviso de la bandeja, como lo ve el cliente · V2-M06.04.
///
/// Dart puro, sin el DTO del contrato: la pantalla no se entera de que
/// `categoria` llega como texto ni de que `destino` puede venir con algo que
/// no sirve.
class AvisoCliente {
  const AvisoCliente({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.cuerpo,
    required this.creadaEn,
    this.destino,
    this.leida = false,
  });

  final int id;
  final CategoriaDeAviso categoria;
  final String titulo;
  final String cuerpo;
  final DateTime creadaEn;

  /// Ruta interna a la que lleva tocarlo, **ya validada** (V2-M06.03).
  ///
  /// Nula si el servidor mando algo que no es una ruta interna. El aviso se
  /// sigue mostrando: lo que se pierde es el toque, no el mensaje.
  final String? destino;

  final bool leida;

  AvisoCliente comoLeida() => AvisoCliente(
    id: id,
    categoria: categoria,
    titulo: titulo,
    cuerpo: cuerpo,
    creadaEn: creadaEn,
    destino: destino,
    leida: true,
  );
}

/// Las categorias del contrato, mas una para lo que esta version no conoce.
///
/// [desconocida] no la manda el servidor: existe para que agregar una
/// categoria del lado del backend **no tumbe la bandeja**. Un aviso de
/// categoria nueva se sigue leyendo; solo pierde su icono propio.
enum CategoriaDeAviso {
  taller,
  citas,
  mantenimiento,
  documentos,
  promociones,
  mensajes,
  desconocida;

  static CategoriaDeAviso de(String valor) => switch (valor) {
    'TALLER' => taller,
    'CITAS' => citas,
    'MANTENIMIENTO' => mantenimiento,
    'DOCUMENTOS' => documentos,
    'PROMOCIONES' => promociones,
    'MENSAJES' => mensajes,
    _ => desconocida,
  };
}

/// Una pagina de la bandeja con el total sin leer de **toda la cuenta**.
class PaginaDeAvisos {
  const PaginaDeAvisos({
    required this.avisos,
    required this.pagina,
    required this.hayMas,
    required this.noLeidos,
  });

  final List<AvisoCliente> avisos;
  final int pagina;
  final bool hayMas;
  final int noLeidos;
}

/// Lo que la bandeja necesita del servidor · V2-M06.04.
abstract interface class RepositorioAvisos {
  Future<PaginaDeAvisos> bandeja({int pagina = 0, int tamano = 20});

  Future<void> marcarLeido(int avisoId);

  Future<void> marcarTodosLeidos();
}

/// El destino de un aviso, validado con la regla de V2-M06.03.
///
/// Se aplica al traducir y no al tocar: asi la pantalla recibe un destino que
/// sirve o un nulo, y no tiene que desconfiar de el.
String? destinoValidado(String crudo) => destinoDeAviso(crudo);
