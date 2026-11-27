/// Interruptor v1/v2 por modulo (V2-T01.05).
///
/// Mientras dura la migracion, cada modulo que tiene version v1
/// (`lib/pantallas`) y version v2 (`lib/modulos/<m>`) se enciende o se apaga
/// por separado. Es una decision de compilacion: un valor por defecto en
/// codigo que se sobrescribe con `--dart-define`; no hay servidor ni secretos.
///
/// Desde V2-T01.09 el valor por defecto es **v2 en todo lo que existia en
/// v1**, con una excepcion a proposito: `recuperacion` sigue en v1 (V2-T01.10)
/// hasta que el enlace del correo abra la app. La v1 queda como salida de
/// emergencia hasta que se retire:
///
/// ```bash
/// flutter run --dart-define=MODULOS_V1=todos        # todo vuelve a la v1
/// flutter run --dart-define=MODULOS_V1=catalogo     # solo el catalogo
/// flutter run --dart-define=MODULOS_V2=recuperacion # un modulo aun no encendido
/// ```
///
/// Se retira completo en V2-T01.07 (guia en `plan/arquitectura-v2.md`).
library;

import 'package:go_router/go_router.dart';

/// Version de un modulo que ve la persona usuaria.
enum VersionModulo { v1, v2 }

/// Modulos con equivalente en v1. Para migrar uno se agrega aqui su valor
/// (ver la guia de migracion en `plan/arquitectura-v2.md`).
enum ModuloMigrable {
  /// Inicio de sesion y cambio obligatorio de la contrasena temporal.
  acceso,
  asistencia,
  catalogo,
  citas,

  /// Recuperar y restablecer la contrasena. Es un modulo aparte del acceso a
  /// proposito: la v2 depende de un enlace del correo que abra la app, y eso
  /// necesita un dominio con enlaces universales que todavia no existe, asi
  /// que sigue en v1 (codigo de 6 digitos) mientras el acceso ya va en v2.
  recuperacion,
  vehiculos;

  /// Nombre que se escribe en `MODULOS_V1` / `MODULOS_V2`.
  String get clave => name;
}

class InterruptorModulos {
  const InterruptorModulos(this._versiones);

  /// Valor por defecto en codigo: los modulos que ya existian en v1 van en v2
  /// (V2-T01.09, y el acceso en V2-T01.10), salvo la recuperacion de la
  /// contrasena: su v2 usa el enlace del correo y mientras ese enlace no abra
  /// la app, quien olvida su contrasena solo puede entrar con el codigo de la
  /// v1. Un modulo nuevo se enciende aqui cuando esta completo y se decide que
  /// llegue a todos; mientras no este, [de] responde v1 y solo se prueba con
  /// `--dart-define=MODULOS_V2=<modulo>`. Volver atras sin tocar codigo:
  /// `--dart-define=MODULOS_V1=todos`.
  static const porDefecto = InterruptorModulos({
    ModuloMigrable.acceso: VersionModulo.v2,
    ModuloMigrable.asistencia: VersionModulo.v2,
    ModuloMigrable.catalogo: VersionModulo.v2,
    ModuloMigrable.citas: VersionModulo.v2,
    ModuloMigrable.vehiculos: VersionModulo.v2,
  });

  /// Todo en v1. Para las pruebas de la v1 (que se retiran con V2-T01.07) y
  /// para comprobar que la salida de emergencia sigue en pie.
  static const todoV1 = InterruptorModulos({});

  /// Todo en v2. Para desarrollo y pruebas.
  static final todoV2 = InterruptorModulos({
    for (final m in ModuloMigrable.values) m: VersionModulo.v2,
  });

  /// Lo que se pasa con `--dart-define=MODULOS_V2=...` y `MODULOS_V1=...`.
  static const _v2Entorno = String.fromEnvironment('MODULOS_V2');
  static const _v1Entorno = String.fromEnvironment('MODULOS_V1');

  /// Lee los `--dart-define` de esta compilacion.
  factory InterruptorModulos.desdeEntorno() =>
      InterruptorModulos.desdeValores(v2: _v2Entorno, v1: _v1Entorno);

  /// Aplica sobre [porDefecto] dos listas separadas por comas (o `todos`).
  /// Primero se encienden los de [v2] y luego se apagan los de [v1], asi que
  /// si un modulo esta en ambas gana v1. Un nombre desconocido lanza
  /// [ArgumentError]: un error de dedo no debe dejar un modulo sin migrar en
  /// silencio.
  factory InterruptorModulos.desdeValores({String v2 = '', String v1 = ''}) {
    final versiones = <ModuloMigrable, VersionModulo>{...porDefecto._versiones};
    for (final m in _leer(v2)) {
      versiones[m] = VersionModulo.v2;
    }
    for (final m in _leer(v1)) {
      versiones[m] = VersionModulo.v1;
    }
    return InterruptorModulos(versiones);
  }

  final Map<ModuloMigrable, VersionModulo> _versiones;

  VersionModulo de(ModuloMigrable modulo) =>
      _versiones[modulo] ?? VersionModulo.v1;

  bool esV2(ModuloMigrable modulo) => de(modulo) == VersionModulo.v2;

  /// Las rutas v2 de [modulo] solo existen si el modulo esta en v2: en v1 un
  /// enlace a ellas cae en el inicio, como cualquier ruta inexistente.
  List<RouteBase> rutas(ModuloMigrable modulo, List<RouteBase> rutasV2) =>
      esV2(modulo) ? rutasV2 : const [];

  static Iterable<ModuloMigrable> _leer(String texto) {
    final claves = texto
        .split(',')
        .map((c) => c.trim().toLowerCase())
        .where((c) => c.isNotEmpty);
    final resultado = <ModuloMigrable>{};
    for (final clave in claves) {
      if (clave == 'todos') {
        resultado.addAll(ModuloMigrable.values);
        continue;
      }
      final modulo = ModuloMigrable.values
          .where((m) => m.clave == clave)
          .firstOrNull;
      if (modulo == null) {
        throw ArgumentError(
          'Modulo desconocido "$clave" en MODULOS_V1/MODULOS_V2. '
          'Validos: todos, ${ModuloMigrable.values.map((m) => m.clave).join(', ')}.',
        );
      }
      resultado.add(modulo);
    }
    return resultado;
  }
}
