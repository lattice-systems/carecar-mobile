import '../../../api/carecar_api.dart';
import '../../../api/modelos/preferencias_notificacion.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/aviso_cliente.dart';
import '../dominio/preferencias_de_avisos.dart';

/// Las preferencias contra el contrato v2 · V2-M06.05.
///
/// Traduce lo que el contrato deja como texto y el dominio necesita tipado: la
/// categoria y el `HH:mm` del horario silencioso.
class RepositorioPreferenciasAvisosApi
    with RepositorioBase
    implements RepositorioPreferenciasAvisos {
  const RepositorioPreferenciasAvisosApi(this._api);

  final CarecarApi _api;

  @override
  Future<PreferenciasDeAvisos> preferencias() =>
      pedir(() async => _aDominio(await _api.preferenciasDeAvisos()));

  @override
  Future<PreferenciasDeAvisos> guardar(PreferenciasDeAvisos nuevas) =>
      pedir(() async {
        final dto = await _api.guardarPreferenciasDeAvisos(_aDto(nuevas));
        return _aDominio(dto);
      });

  PreferenciasDeAvisos _aDominio(PreferenciasNotificacion dto) {
    final desde = HoraDelDia.deTexto(dto.silencioDesde);
    final hasta = HoraDelDia.deTexto(dto.silencioHasta);
    return PreferenciasDeAvisos(
      porCategoria: {
        for (final c in dto.categorias)
          CategoriaDeAviso.de(c.categoria): c.push,
      },
      // Los dos o ninguno. Una hora que no se puede leer deja el horario en
      // nulo: mejor sin silencio que silenciando a una hora que nadie eligio.
      silencio: desde != null && hasta != null
          ? HorarioSilencioso(desde: desde, hasta: hasta)
          : null,
    );
  }

  PreferenciasNotificacion _aDto(PreferenciasDeAvisos p) =>
      PreferenciasNotificacion(
        categorias: [
          for (final e in p.paraGuardar().entries)
            PreferenciaNotificacion(categoria: _claveDe(e.key), push: e.value),
        ],
        silencioDesde: p.silencio?.desde.aTexto(),
        silencioHasta: p.silencio?.hasta.aTexto(),
      );

  /// La clave que el contrato declara. `desconocida` no llega aqui: la quita
  /// `paraGuardar()`, porque el contrato no la declara y seria un 400.
  String _claveDe(CategoriaDeAviso c) => switch (c) {
    CategoriaDeAviso.taller => 'TALLER',
    CategoriaDeAviso.citas => 'CITAS',
    CategoriaDeAviso.mantenimiento => 'MANTENIMIENTO',
    CategoriaDeAviso.documentos => 'DOCUMENTOS',
    CategoriaDeAviso.promociones => 'PROMOCIONES',
    CategoriaDeAviso.mensajes => 'MENSAJES',
    CategoriaDeAviso.desconocida => 'DESCONOCIDA',
  };
}
