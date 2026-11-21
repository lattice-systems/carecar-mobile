import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/modelos/cita.dart';
import 'recordatorios.dart';

/// Lo minimo que se le pide al sistema de notificaciones.
///
/// La implementacion real envuelve flutter_local_notifications
/// (`plugin_notificaciones_local.dart`); en pruebas se usa un doble.
abstract interface class PluginNotificaciones {
  Future<void> inicializar();

  /// Pide permiso al sistema; true si quedo concedido.
  Future<bool> pedirPermiso();

  Future<void> mostrar(int id, String titulo, String cuerpo);

  /// `cuando` es hora de pared en la zona de la agencia.
  Future<void> programar(int id, DateTime cuando, String titulo, String cuerpo);

  Future<void> cancelar(int id);

  Future<void> cancelarTodas();

  /// Ids de las notificaciones programadas que siguen pendientes.
  Future<List<int>> pendientes();

  /// Hora de pared actual en la zona de la agencia.
  DateTime ahora();

  /// true si la app arranco porque se toco un aviso.
  bool get abiertaDesdeAviso;
}

/// Recordatorios de citas: decide que se programa y cuando se cancela.
///
/// Las pantallas lo usan a traves de [Notificaciones.actual]; si nadie lo
/// configura (pruebas de widgets) se usa uno que no hace nada.
class ServicioNotificaciones {
  ServicioNotificaciones(this._plugin, this._prefs);

  final PluginNotificaciones _plugin;
  final SharedPreferences? _prefs;

  static const _claveActivo = 'notificaciones.recordatorios_activos';
  static const _clavePermisoPedido = 'notificaciones.permiso_pedido';

  /// Cambia cada vez que el usuario toca una notificacion de cita.
  final toques = ValueNotifier<int>(0);

  /// Pendiente de abrir «Mis citas» porque la app arranco desde un aviso.
  bool abrirCitasAlEntrar = false;

  bool _listo = false;

  bool get activo => _prefs?.getBool(_claveActivo) ?? true;

  Future<void> iniciar() async {
    if (_listo) return;
    try {
      await _plugin.inicializar();
      abrirCitasAlEntrar = _plugin.abiertaDesdeAviso;
      _listo = true;
    } catch (e) {
      // Sin notificaciones la app sigue funcionando.
      debugPrint('No se pudieron iniciar las notificaciones: $e');
    }
  }

  /// Avisa que se toco una notificacion con la app viva.
  void notificarToque() => toques.value++;

  /// Pide permiso una sola vez; despues el usuario decide en el sistema.
  Future<void> pedirPermisoSiHaceFalta() async {
    if (!_listo || !activo) return;
    if (_prefs?.getBool(_clavePermisoPedido) ?? false) return;
    await _prefs?.setBool(_clavePermisoPedido, true);
    await _seguro(_plugin.pedirPermiso);
  }

  Future<void> cambiarActivo(bool valor) async {
    await _prefs?.setBool(_claveActivo, valor);
    if (!_listo) return;
    if (valor) {
      await _seguro(_plugin.pedirPermiso);
    } else {
      await _seguro(_plugin.cancelarTodas);
    }
  }

  /// Cita recien agendada: aviso inmediato y sus recordatorios.
  Future<void> alAgendar(Cita cita, {String? vehiculo}) async {
    if (!_listo || !activo) return;
    await pedirPermisoSiHaceFalta();
    final texto = textoConfirmacion(cita, vehiculo: vehiculo);
    await _seguro(
      () => _plugin.mostrar(
        IdsNotificacion.confirmacion(cita.id),
        texto.titulo,
        texto.cuerpo,
      ),
    );
    await _programar(cita, vehiculo, const {});
  }

  Future<void> alCancelar(int citaId) async {
    if (!_listo) return;
    for (final id in IdsNotificacion.recordatorios(citaId)) {
      await _seguro(() => _plugin.cancelar(id));
    }
  }

  /// Deja los recordatorios igual que la lista de citas del servidor.
  ///
  /// Cancela los de citas que ya no estan confirmadas y programa los que
  /// falten. Las citas que no vienen en la lista (otras paginas) no se tocan.
  Future<void> sincronizar(
    List<Cita> citas, {
    Map<int, String> vehiculos = const {},
  }) async {
    if (!_listo || !activo) return;
    final pendientes = {...?await _seguro(_plugin.pendientes)};
    for (final cita in citas) {
      if (cita.estado == EstadoCita.confirmada) {
        await _programar(cita, vehiculos[cita.vehiculoId], pendientes);
        continue;
      }
      for (final id in IdsNotificacion.recordatorios(cita.id)) {
        if (pendientes.contains(id)) {
          await _seguro(() => _plugin.cancelar(id));
        }
      }
    }
  }

  Future<void> alCerrarSesion() async {
    if (!_listo) return;
    await _seguro(_plugin.cancelarTodas);
  }

  /// Programa los recordatorios futuros de la cita que no esten en [omitir].
  Future<void> _programar(Cita cita, String? vehiculo, Set<int> omitir) async {
    final lista = recordatoriosDe(
      cita,
      ahora: _plugin.ahora(),
      vehiculo: vehiculo,
    );
    for (final r in lista) {
      if (omitir.contains(r.id)) continue;
      await _seguro(
        () => _plugin.programar(r.id, r.cuando, r.titulo, r.cuerpo),
      );
    }
  }

  Future<T?> _seguro<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } catch (e) {
      debugPrint('Fallo una notificacion: $e');
      return null;
    }
  }
}

/// Punto de acceso global, como un localizador minimo (EQ-1 sigue abierta).
abstract final class Notificaciones {
  static ServicioNotificaciones actual = ServicioNotificaciones(
    PluginNulo(),
    null,
  );
}

/// Plugin que no hace nada: el de las pruebas de widgets y plataformas sin
/// soporte.
class PluginNulo implements PluginNotificaciones {
  @override
  Future<void> inicializar() async {}
  @override
  Future<bool> pedirPermiso() async => false;
  @override
  Future<void> mostrar(int id, String titulo, String cuerpo) async {}
  @override
  Future<void> programar(
    int id,
    DateTime cuando,
    String titulo,
    String cuerpo,
  ) async {}
  @override
  Future<void> cancelar(int id) async {}
  @override
  Future<void> cancelarTodas() async {}
  @override
  Future<List<int>> pendientes() async => const [];
  @override
  DateTime ahora() => DateTime.now();
  @override
  bool get abiertaDesdeAviso => false;
}
