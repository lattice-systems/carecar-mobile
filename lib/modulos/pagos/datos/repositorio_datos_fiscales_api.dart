import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/datos_fiscales.dart';
import '../dominio/repositorio_datos_fiscales.dart';
import 'lectura_datos_fiscales.dart';

/// `/catalogos-fiscales` y `/perfiles-fiscales` con el cliente del nucleo. Las
/// excepciones de la API pasan tal cual; solo se traduce el 400
/// `DATOS_FISCALES_INVALIDOS`, que trae que corregir en cada campo.
class RepositorioDatosFiscalesApi implements RepositorioDatosFiscales {
  const RepositorioDatosFiscalesApi(this._cliente);

  final ApiCliente _cliente;

  static const _lectura = LecturaDatosFiscales();

  @override
  Future<CatalogoFiscal> catalogo() =>
      _cliente.obtener('/catalogos-fiscales', _lectura.catalogo);

  @override
  Future<List<PerfilFiscal>> perfiles() =>
      _cliente.obtenerLista('/perfiles-fiscales', _lectura.perfil);

  @override
  Future<PerfilFiscal> crear(BorradorPerfilFiscal borrador) => _traducir(
    () => _cliente.enviar(
      '/perfiles-fiscales',
      cuerpo: _cuerpo(borrador),
      leer: _lectura.perfil,
    ),
  );

  @override
  Future<PerfilFiscal> editar(int id, BorradorPerfilFiscal borrador) =>
      _traducir(
        () => _cliente.actualizar(
          '/perfiles-fiscales/$id',
          cuerpo: _cuerpo(borrador),
          leer: _lectura.perfil,
        ),
      );

  @override
  Future<void> borrar(int id) => _cliente.eliminar('/perfiles-fiscales/$id');

  static Map<String, Object?> _cuerpo(BorradorPerfilFiscal b) {
    final correo = b.correo.trim();
    return {
      'rfc': b.rfcNormalizado,
      'razonSocial': b.razonSocial.trim(),
      'regimenFiscal': b.regimenFiscal,
      'codigoPostal': b.codigoPostal.trim(),
      'usoCfdi': b.usoCfdi,
      'correo': correo.isEmpty ? null : correo,
      'predeterminado': b.predeterminado,
    };
  }

  static Future<PerfilFiscal> _traducir(
    Future<PerfilFiscal> Function() pedir,
  ) async {
    try {
      return await pedir();
    } on DatosInvalidos catch (e) {
      final problema = e.problema;
      if (problema == null ||
          problema.codigo != CodigoProblema.datosFiscalesInvalidos) {
        rethrow;
      }
      throw DatosFiscalesRechazados({
        for (final MapEntry(:key, :value) in problema.campos.entries)
          if (CampoFiscal.desde(key) case final campo?) campo: value,
      });
    }
  }
}
