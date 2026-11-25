import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/repositorio_acceso.dart';

/// Repositorio de acceso en memoria, para pruebas y desarrollo · M01.
///
/// Recuerda lo que se le mando y falla a pedido con [falla]. Usa la misma
/// [RepositorioBase] que el de verdad, asi que una prueba no puede ver un
/// error sin tipar que en produccion si vendria tipado.
class RepositorioAccesoFake with RepositorioBase implements RepositorioAcceso {
  RepositorioAccesoFake({this.falla});

  /// Si no es nulo, cada llamada falla con esto.
  Fallo? falla;

  /// Si no es nulo, restablecer con enlace falla con esto.
  ///
  /// Se separa de [falla] para poder montar el caso real: pedir el enlace
  /// funciona y el enlace resulta vencido al usarlo.
  Object? fallaDelEnlace;

  int llamadas = 0;
  String? ultimaActual;
  String? ultimaNueva;

  /// Si no es nulo, las operaciones esperan esto antes de terminar.
  ///
  /// Sirve para probar lo que pasa **mientras** el servidor responde: el
  /// boton bloqueado, el doble toque, el aviso de que tarda.
  Future<void>? esperar;

  int llamadasAlPedirEnlace = 0;
  int llamadasAlRestablecer = 0;
  String? ultimoCorreo;
  String? ultimoToken;
  String? ultimaContrasenaDelEnlace;

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) => pedir(() async {
    llamadas++;
    ultimaActual = actual;
    ultimaNueva = nueva;
    final f = falla;
    if (f != null) throw f;
  });

  @override
  Future<void> pedirEnlaceDeRecuperacion(String correo) => pedir(() async {
    llamadasAlPedirEnlace++;
    ultimoCorreo = correo;
    final espera = esperar;
    if (espera != null) await espera;
    final f = falla;
    if (f != null) throw f;
  });

  /// La falla se lanza **fuera** de [pedir], igual que el repositorio real
  /// traduce ahi su fallo de dominio: dentro, un `EnlaceNoValido` saldria
  /// convertido en `ErrorDelServidor` y el fake mentiria.
  @override
  Future<void> restablecerConEnlace({
    required String token,
    required String contrasenaNueva,
  }) async {
    await pedir(() async {
      llamadasAlRestablecer++;
      ultimoToken = token;
      ultimaContrasenaDelEnlace = contrasenaNueva;
      final espera = esperar;
      if (espera != null) await espera;
    });
    final f = fallaDelEnlace;
    if (f != null) throw f;
  }
}
