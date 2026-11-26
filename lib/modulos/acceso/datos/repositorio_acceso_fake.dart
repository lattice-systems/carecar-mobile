import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/perfil_del_cliente.dart';
import '../dominio/repositorio_acceso.dart';
import '../dominio/sesion_de_la_cuenta.dart';

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

  // --- Perfil · V2-M01.06 ---

  /// Lo que devuelve [perfil]. Si es nulo, uno cualquiera con telefono.
  PerfilDelCliente? perfilDelCliente;

  /// Si no es nulo, **solo** leer el perfil falla con esto.
  Fallo? fallaAlLeerPerfil;

  int llamadasAlPerfil = 0;

  @override
  Future<PerfilDelCliente> perfil() => pedir(() async {
    llamadasAlPerfil++;
    final espera = esperar;
    if (espera != null) await espera;
    final f = fallaAlLeerPerfil ?? falla;
    if (f != null) throw f;
    return perfilDelCliente ??
        PerfilDelCliente(
          nombre: 'Maria Elena Robles',
          correo: 'cliente1@example.com',
          telefono: '477 123 4567',
          clienteDesde: DateTime(2022, 5, 18),
        );
  });

  // --- Sesiones activas · V2-M01.09 ---

  /// Lo que devuelve [sesiones], en el orden en que se le ponga: el repositorio
  /// real conserva el del servidor y el fake tiene que poder mentir igual.
  List<SesionDeLaCuenta> sesionesAbiertas = const [];

  /// Si no es nulo, **solo** leer las sesiones falla con esto.
  ///
  /// Se separa de [falla] para montar el caso de la pantalla: la lista carga y
  /// el cierre es el que truena, o al contrario.
  Fallo? fallaAlLeerSesiones;

  /// Si no es nulo, **solo** cerrar falla con esto.
  Fallo? fallaAlCerrar;

  int llamadasAlLeerSesiones = 0;

  /// Los ids que se mandaron a cerrar, en orden. Cerrar todas se anota en
  /// [cerroTodas], no aqui.
  final sesionesCerradas = <int>[];

  bool cerroTodas = false;

  @override
  Future<List<SesionDeLaCuenta>> sesiones() => pedir(() async {
    llamadasAlLeerSesiones++;
    final espera = esperar;
    if (espera != null) await espera;
    final f = fallaAlLeerSesiones ?? falla;
    if (f != null) throw f;
    return sesionesAbiertas;
  });

  @override
  Future<void> cerrarUnaSesion(int sesionId) => pedir(() async {
    final espera = esperar;
    if (espera != null) await espera;
    final f = fallaAlCerrar ?? falla;
    if (f != null) throw f;
    sesionesCerradas.add(sesionId);
    sesionesAbiertas = sesionesAbiertas
        .where((s) => s.id != sesionId)
        .toList(growable: false);
  });

  @override
  Future<void> cerrarTodasLasSesiones() => pedir(() async {
    final espera = esperar;
    if (espera != null) await espera;
    final f = fallaAlCerrar ?? falla;
    if (f != null) throw f;
    cerroTodas = true;
    sesionesAbiertas = const [];
  });
}
