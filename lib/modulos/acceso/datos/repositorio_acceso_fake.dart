import '../../../nucleo/datos/fallo.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/cambio_de_correo_pendiente.dart';
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

  /// Si no es nulo, restablecer con código falla con esto.
  Object? fallaDelCodigo;
  String? ultimoCodigo;

  @override
  Future<void> restablecerConCodigo({
    required String correo,
    required String codigo,
    required String contrasenaNueva,
  }) async {
    await pedir(() async {
      llamadasAlRestablecer++;
      ultimoCorreo = correo;
      ultimoCodigo = codigo;
      ultimaContrasenaDelEnlace = contrasenaNueva;
      final espera = esperar;
      if (espera != null) await espera;
      final f = falla;
      if (f != null) throw f;
    });
    final f = fallaDelCodigo;
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

  // --- Cambio de correo · V2-M01.07 ---

  /// Si no es nulo, **pedir** el cambio falla con esto.
  ///
  /// Se separa de [falla] para montar el caso real de la pantalla: pedirlo
  /// funciona y el codigo resulta equivocado, o al reves.
  Object? fallaAlPedirCambio;

  /// Si no es nulo, **confirmar** falla con esto.
  Object? fallaAlConfirmar;

  String? correoPedido;
  String? contrasenaDelCambio;
  int? verificacionConfirmada;
  String? codigoConfirmado;

  /// Lo que devuelve [pedirCambioDeCorreo]; por omision vence en 15 minutos.
  CambioDeCorreoPendiente? cambioPendiente;

  @override
  Future<CambioDeCorreoPendiente> pedirCambioDeCorreo({
    required String correo,
    required String contrasenaActual,
  }) async {
    await pedir(() async {
      correoPedido = correo;
      contrasenaDelCambio = contrasenaActual;
      final espera = esperar;
      if (espera != null) await espera;
    });
    final f = fallaAlPedirCambio;
    if (f != null) throw f;
    return cambioPendiente ??
        CambioDeCorreoPendiente(
          id: 12,
          expira: DateTime.now().toUtc().add(const Duration(minutes: 15)),
        );
  }

  @override
  Future<PerfilDelCliente> confirmarCambioDeCorreo({
    required int id,
    required String codigo,
  }) async {
    await pedir(() async {
      verificacionConfirmada = id;
      codigoConfirmado = codigo;
      final espera = esperar;
      if (espera != null) await espera;
    });
    final f = fallaAlConfirmar;
    if (f != null) throw f;
    final antes = perfilDelCliente;
    // El servidor devuelve el perfil ya actualizado, asi que el fake tambien:
    // si devolviera el viejo, una pantalla rota pasaria la prueba.
    final nuevo = PerfilDelCliente(
      nombre: antes?.nombre ?? 'Maria Elena Robles',
      correo: correoPedido ?? antes?.correo ?? 'cliente1@example.com',
      telefono: antes?.telefono ?? '477 123 4567',
      clienteDesde: antes?.clienteDesde ?? DateTime(2022, 5, 18),
    );
    perfilDelCliente = nuevo;
    return nuevo;
  }

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
