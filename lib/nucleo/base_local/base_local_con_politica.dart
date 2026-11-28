import 'dart:async';

import '../seguridad/politica_datos_locales.dart';
import 'base_local.dart';

/// Aplica la política de datos locales (V2-M22.05) a una [BaseLocal].
///
/// En un equipo con root o jailbreak el sistema ya no protege los datos de la
/// app de otras apps, así que la base no guarda ni entrega nada y borra lo que
/// hubiera, en cuanto se detecta y también si la app arranca ya así. Es el
/// contrato que `PoliticaDatosLocales` pide a todo lo que guarde datos del
/// cliente fuera del almacenamiento seguro.
class BaseLocalConPolitica implements BaseLocal {
  BaseLocalConPolitica(this._base, this._politica) {
    _politica.addListener(_alCambiarLaPolitica);
    _alCambiarLaPolitica();
  }

  final BaseLocal _base;
  final PoliticaDatosLocales _politica;

  void _alCambiarLaPolitica() {
    if (!_politica.permiteCacheLocal) {
      // Si borrar falla no hay nada más que hacer aquí; mientras la política
      // no permita, nada se guarda ni se entrega.
      unawaited(_base.borrarTodo().catchError((Object _) {}));
    }
  }

  /// Deja de escuchar la política. No cierra la base de abajo.
  void dispose() => _politica.removeListener(_alCambiarLaPolitica);

  @override
  Future<void> guardar({
    required String coleccion,
    required String clave,
    required String contenido,
  }) async {
    if (!_politica.permiteCacheLocal) return;
    await _base.guardar(
      coleccion: coleccion,
      clave: clave,
      contenido: contenido,
    );
  }

  @override
  Future<CopiaLocal?> leer({
    required String coleccion,
    required String clave,
  }) async => _politica.permiteCacheLocal
      ? _base.leer(coleccion: coleccion, clave: clave)
      : null;

  @override
  Future<List<CopiaLocal>> listar({required String coleccion}) async =>
      _politica.permiteCacheLocal
      ? _base.listar(coleccion: coleccion)
      : const [];

  @override
  Future<void> borrarTodo() => _base.borrarTodo();

  @override
  Future<void> cerrar() => _base.cerrar();
}
