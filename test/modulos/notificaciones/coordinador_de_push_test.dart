import 'package:carecar_mobile/modulos/notificaciones/datos/repositorio_dispositivos_fake.dart';
import 'package:carecar_mobile/modulos/notificaciones/datos/servicio_push_fake.dart';
import 'package:carecar_mobile/modulos/notificaciones/datos/servicio_push_nulo.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/push.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/coordinador_de_push.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M06.02 · «token FCM registrado tras login y borrado al cerrar sesión».
///
/// Se registra solo con sesión **y** con los avisos permitidos (V2-M06.01):
/// sin permiso el teléfono no mostraría nada, así que no tiene caso que el
/// servidor le mande push.
void main() {
  const instalacion = 'instalacion-1234';

  late ServicioPushFake servicio;
  late RepositorioDispositivosFake repositorio;
  late CoordinadorDePush coordinador;
  var idioma = 'es';
  var repositoriosArmados = 0;

  CoordinadorDePush armar(ServicioPush conServicio) => CoordinadorDePush(
    servicio: conServicio,
    repositorio: () {
      repositoriosArmados++;
      return repositorio;
    },
    instalacion: () async => instalacion,
    plataforma: PlataformaPush.android,
    idioma: () => idioma,
  );

  setUp(() {
    servicio = ServicioPushFake(token: 'token-1');
    repositorio = RepositorioDispositivosFake();
    idioma = 'es';
    repositoriosArmados = 0;
    coordinador = armar(servicio);
  });

  tearDown(() => coordinador.detener());

  test('con sesión y avisos permitidos registra el token', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: true);

    expect(repositorio.llamadas, ['PUT $instalacion token-1 android es']);
  });

  test('manda el idioma que la app usa en ese momento', () async {
    idioma = 'en';

    await coordinador.alCambiar(haySesion: true, permitidos: true);

    expect(repositorio.llamadas.single, endsWith(' en'));
  });

  test('sin sesión no registra nada', () async {
    await coordinador.alCambiar(haySesion: false, permitidos: true);

    expect(repositorio.llamadas, isEmpty);
  });

  test('sin permiso de avisos no registra nada', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: false);

    expect(repositorio.llamadas, isEmpty);
  });

  test('repetir el mismo estado no vuelve a llamar al servidor', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: true);
    await coordinador.alCambiar(haySesion: true, permitidos: true);

    expect(repositorio.llamadas, hasLength(1));
  });

  test('un token nuevo se vuelve a registrar', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: true);

    servicio.rotar('token-2');
    await coordinador.pendiente;

    expect(repositorio.llamadas, [
      'PUT $instalacion token-1 android es',
      'PUT $instalacion token-2 android es',
    ]);
  });

  test('cerrar sesión da de baja la instalación', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: true);

    await coordinador.alCerrarSesion();

    expect(repositorio.llamadas.last, 'DELETE $instalacion');
  });

  test('después de cerrar sesión un token nuevo ya no se registra', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: true);
    await coordinador.alCerrarSesion();

    servicio.rotar('token-2');
    await coordinador.pendiente;

    expect(repositorio.llamadas.last, 'DELETE $instalacion');
  });

  test('negar los avisos con la sesión abierta da de baja', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: true);

    await coordinador.alCambiar(haySesion: true, permitidos: false);

    expect(repositorio.llamadas.last, 'DELETE $instalacion');
  });

  test('si la sesión se pierde sin cerrarla no llama al servidor', () async {
    // 403 o refresh vencido: el servidor ya no acepta esa cuenta.
    await coordinador.alCambiar(haySesion: true, permitidos: true);

    await coordinador.alCambiar(haySesion: false, permitidos: true);

    expect(repositorio.llamadas, hasLength(1));
  });

  test(
    'un fallo de red no lanza y se reintenta en el siguiente cambio',
    () async {
      repositorio.fallarCon = Exception('sin red');
      await coordinador.alCambiar(haySesion: true, permitidos: true);
      expect(repositorio.llamadas, isEmpty);

      repositorio.fallarCon = null;
      await coordinador.alCambiar(haySesion: true, permitidos: true);

      expect(repositorio.llamadas, ['PUT $instalacion token-1 android es']);
    },
  );

  test('si la baja falla, cerrar sesión no lanza', () async {
    await coordinador.alCambiar(haySesion: true, permitidos: true);
    repositorio.fallarCon = Exception('sin red');

    await expectLater(coordinador.alCerrarSesion(), completes);
  });

  test('sin token (sin Firebase) no arma el repositorio ni llama', () async {
    coordinador.detener();
    coordinador = armar(const ServicioPushNulo());

    await coordinador.alCambiar(haySesion: true, permitidos: true);
    await coordinador.alCerrarSesion();

    expect(repositorio.llamadas, isEmpty);
    expect(repositoriosArmados, 0);
  });
}
