import '../../../api/carecar_api.dart';
import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../api/modelos/sesion.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/fallos_acceso.dart';
import '../dominio/perfil_del_cliente.dart';
import '../dominio/repositorio_acceso.dart';
import '../dominio/sesion_de_la_cuenta.dart';

/// Habla con la API real · M01.
///
/// Usa [RepositorioBase] (V2-T01.08), asi que de aqui sale un dato o sale un
/// `Fallo` tipado: lo que la pantalla reciba ya viene clasificado y nunca le
/// llega un error sin tipar que tenga que pintar como «ocurrio un error».
class RepositorioAccesoApi with RepositorioBase implements RepositorioAcceso {
  const RepositorioAccesoApi(this._api);

  final CarecarApi _api;

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) => pedir(() => _api.cambiarContrasena(actual: actual, nueva: nueva));

  @override
  Future<void> pedirEnlaceDeRecuperacion(String correo) =>
      pedir(() => _api.recuperarContrasena(correo));

  /// La traduccion a [EnlaceNoValido] va **fuera** de [pedir], no dentro.
  ///
  /// Es deliberado y conviene no moverlo: un fallo de dominio es una
  /// `Exception` normal, y `pedir` tipa todo lo que no sea `ExcepcionApi`.
  /// Traducir dentro lo convertiria en `ErrorDelServidor` y la pantalla
  /// perderia el unico dato que necesita para ofrecer «pide otro enlace».
  @override
  Future<void> restablecerConEnlace({
    required String token,
    required String contrasenaNueva,
  }) async {
    try {
      await pedir(
        () => _api.restablecerContrasena(
          PeticionRestablecer.conEnlace(
            token: token,
            contrasenaNueva: contrasenaNueva,
          ),
        ),
      );
    } on DatosInvalidos catch (e) {
      // Vencido y usado llegan igual, y el contrato no los distingue: en los
      // dos casos la salida es pedir otro enlace.
      if (e.problema?.codigo == CodigoProblema.codigoInvalido) {
        throw const EnlaceNoValido();
      }
      rethrow;
    }
  }

  @override
  Future<PerfilDelCliente> perfil() => pedir(() async {
    final dto = await _api.miPerfil();
    return PerfilDelCliente(
      nombre: dto.nombre,
      correo: dto.correo,
      telefono: dto.telefono,
      clienteDesde: dto.clienteDesde,
    );
  });

  @override
  Future<List<SesionDeLaCuenta>> sesiones() => pedir(() async {
    final dto = await _api.misSesiones();
    return dto.map(_aSesion).toList(growable: false);
  });

  @override
  Future<void> cerrarUnaSesion(int sesionId) =>
      pedir(() => _api.cerrarSesionActiva(sesionId));

  @override
  Future<void> cerrarTodasLasSesiones() => pedir(_api.cerrarTodasLasSesiones);

  static SesionDeLaCuenta _aSesion(SesionActiva s) => SesionDeLaCuenta(
    id: s.id,
    dispositivo: s.dispositivo,
    ultimoUso: s.ultimoUso,
    iniciadaEn: s.iniciadaEn,
    expiraEn: s.expiraEn,
  );
}
