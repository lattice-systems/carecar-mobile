/// Interruptor v1/v2 por modulo (V2-T01.05).
///
/// Mientras dura la migracion, cada modulo que tiene version v1
/// (`lib/pantallas`) y version v2 (`lib/modulos/<m>`) se enciende o se apaga
/// por separado. Es una decision de compilacion: un valor por defecto en
/// codigo que se sobrescribe con `--dart-define`; no hay servidor ni secretos.
///
/// ```bash
/// flutter run --dart-define=MODULOS_V2=vehiculos,citas
/// flutter run --dart-define=MODULOS_V2=todos --dart-define=MODULOS_V1=catalogo
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
  asistencia,
  catalogo,
  citas,
  vehiculos;

  /// Nombre que se escribe en `MODULOS_V1` / `MODULOS_V2`.
  String get clave => name;
}

class InterruptorModulos {
  const InterruptorModulos(this._versiones);

  /// Valor por defecto en codigo: todo en v1, tal como hoy. Un modulo se
  /// enciende aqui cuando esta completo y se decide que llegue a todos.
  static const porDefecto = InterruptorModulos({});

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
