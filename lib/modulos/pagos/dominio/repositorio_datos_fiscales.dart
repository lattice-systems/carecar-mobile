import 'datos_fiscales.dart';

/// El servidor rechazo los datos (`DATOS_FISCALES_INVALIDOS`): que corregir en
/// cada campo, con el texto del servidor escrito para la persona.
class DatosFiscalesRechazados implements Exception {
  const DatosFiscalesRechazados(this.campos);

  final Map<CampoFiscal, String> campos;
}

/// Datos fiscales del cliente y los catalogos del SAT (V2-M08.05).
abstract interface class RepositorioDatosFiscales {
  Future<CatalogoFiscal> catalogo();

  /// El predeterminado primero y luego del mas viejo al mas nuevo.
  Future<List<PerfilFiscal>> perfiles();

  /// Lanza [DatosFiscalesRechazados] si el servidor no acepta un dato.
  Future<PerfilFiscal> crear(BorradorPerfilFiscal borrador);

  /// Lanza [DatosFiscalesRechazados] si el servidor no acepta un dato.
  Future<PerfilFiscal> editar(int id, BorradorPerfilFiscal borrador);

  Future<void> borrar(int id);
}
