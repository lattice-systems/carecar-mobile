import '../dominio/aviso.dart';
import '../dominio/repositorio_avisos.dart';

/// Repositorio de ejemplo con datos en memoria. Un repositorio real recibiria
/// `CarecarApi` (de `nucleo/api`) y traduciria DTO a modelos de dominio.
class RepositorioAvisosFake implements RepositorioAvisos {
  RepositorioAvisosFake([
    this._avisos = const [
      Aviso(
        id: 1,
        titulo: 'Cambio de aceite proximo',
        detalle: 'Faltan 500 km para tu servicio.',
      ),
      Aviso(
        id: 2,
        titulo: 'Verificacion vencida',
        detalle: 'Agenda tu verificacion lo antes posible.',
        urgente: true,
      ),
    ],
  ]);

  final List<Aviso> _avisos;

  @override
  Future<List<Aviso>> avisos() async => _avisos;
}
