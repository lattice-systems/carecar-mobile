import '../dominio/aviso_cliente.dart';

/// Bandeja en memoria para pruebas y para la galeria · V2-M06.04.
class RepositorioAvisosFake implements RepositorioAvisos {
  RepositorioAvisosFake({List<AvisoCliente>? avisos, this.falla = false})
    : _avisos = [...?avisos];

  final List<AvisoCliente> _avisos;

  /// Si `true`, toda llamada truena. Para probar los estados de error.
  bool falla;

  int lotes = 0;
  final marcados = <int>[];

  @override
  Future<PaginaDeAvisos> bandeja({int pagina = 0, int tamano = 20}) async {
    if (falla) throw Exception('sin bandeja');
    final desde = (pagina * tamano).clamp(0, _avisos.length);
    final hasta = (desde + tamano).clamp(0, _avisos.length);
    return PaginaDeAvisos(
      avisos: _avisos.sublist(desde, hasta),
      pagina: pagina,
      hayMas: hasta < _avisos.length,
      noLeidos: _avisos.where((a) => !a.leida).length,
    );
  }

  @override
  Future<void> marcarLeido(int avisoId) async {
    if (falla) throw Exception('no se pudo marcar');
    marcados.add(avisoId);
    final i = _avisos.indexWhere((a) => a.id == avisoId);
    if (i >= 0) _avisos[i] = _avisos[i].comoLeida();
  }

  @override
  Future<void> marcarTodosLeidos() async {
    if (falla) throw Exception('no se pudo marcar');
    lotes++;
    for (var i = 0; i < _avisos.length; i++) {
      _avisos[i] = _avisos[i].comoLeida();
    }
  }
}
