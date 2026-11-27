import '../../../api/carecar_api.dart';
import '../../../api/modelos/notificacion.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/aviso_cliente.dart';

/// La bandeja contra el contrato v2 2.31.0 · V2-M06.04.
///
/// Traduce el DTO a dominio, y ahi se valida el `destino`: lo escribe el
/// servidor, asi que entra a la app como dato de fuera. La pantalla recibe un
/// destino que sirve o un nulo, y no tiene que desconfiar de el.
class RepositorioAvisosApi with RepositorioBase implements RepositorioAvisos {
  const RepositorioAvisosApi(this._api);

  final CarecarApi _api;

  @override
  Future<PaginaDeAvisos> bandeja({int pagina = 0, int tamano = 20}) =>
      pedir(() async {
        final dto = await _api.paginaDeNotificaciones(
          pagina: pagina,
          tamano: tamano,
        );
        return PaginaDeAvisos(
          avisos: dto.contenido.map(_aDominio).toList(growable: false),
          pagina: dto.pagina,
          hayMas: dto.hayMas,
          noLeidos: dto.noLeidas,
        );
      });

  @override
  Future<void> marcarLeido(int avisoId) =>
      pedir(() => _api.marcarAvisoLeido(avisoId));

  @override
  Future<void> marcarTodosLeidos() => pedir(_api.marcarAvisosLeidos);

  AvisoCliente _aDominio(Notificacion n) => AvisoCliente(
    id: n.id,
    categoria: CategoriaDeAviso.de(n.categoria),
    titulo: n.titulo,
    cuerpo: n.cuerpo,
    creadaEn: n.creadaEn,
    destino: destinoValidado(n.destino),
    leida: n.leidaEn != null,
  );
}
