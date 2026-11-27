import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/excepciones.dart';

/// Si la agencia contesta o no · V2-M21.04.
///
/// ## Por que se deduce y no se consulta
///
/// Un paquete de conectividad dice si hay **interfaz de red**, no si el
/// servidor contesta. En el sotano del taller -que es el caso que esta
/// historia existe para resolver- el telefono se ve conectado al wifi de la
/// agencia y no llega nada. Un aviso que dijera «tienes internet» ahi seria
/// peor que ninguno.
///
/// Asi que la senal se deduce de lo que ya pasa: **toda** llamada de
/// repositorio pasa por `RepositorioBase.pedir`, y ahi se sabe si hubo
/// respuesta. Eso da tres cosas gratis: ninguna dependencia nueva, ningun
/// sondeo periodico y ningun gasto de bateria.
///
/// Lo que no da: si la app esta quieta, la senal tampoco se entera de que la
/// red volvio. Es aceptable porque el aviso se apaga con la primera respuesta
/// buena, y cualquier cosa que la persona intente produce una.
class SenalDeConexion extends ChangeNotifier {
  /// La senal que usa la app. `RepositorioBase` es un mixin sin acceso a
  /// Riverpod, asi que la alcanza por aqui; las pruebas la sustituyen.
  static SenalDeConexion actual = SenalDeConexion();

  bool _sinConexion = false;

  /// Lo ultimo que se supo. **Nace en linea**: no se asume lo peor sin motivo.
  bool get sinConexion => _sinConexion;

  /// Hubo respuesta del servidor, sea buena o un error suyo.
  void acerto() => _poner(false);

  /// Una llamada fallo. Solo [SinConexion] cuenta.
  ///
  /// Un 500 significa que el servidor **si** contesto: decir «sin conexion»
  /// mandaria a la persona a revisar su wifi por un problema que no es suyo.
  void fallo(Object error) {
    if (error is SinConexion) _poner(true);
  }

  void _poner(bool valor) {
    if (_sinConexion == valor) return;
    _sinConexion = valor;
    notifyListeners();
  }
}

/// La senal, para que las pantallas la escuchen.
///
/// Una accion que necesita servidor se deshabilita con esto y explica por que,
/// que es el otro criterio de la historia. Cada modulo lo aplica a sus propias
/// acciones: no hay forma de saber desde el nucleo cual de ellas necesita red.
final senalDeConexionProvider = Provider<SenalDeConexion>(
  (ref) => SenalDeConexion.actual,
  name: 'senalDeConexionProvider',
);

/// Si ahora mismo no hay conexion, **y repinta cuando cambia**.
///
/// Existe porque `ref.watch(senalDeConexionProvider).sinConexion` NO repinta:
/// `Provider` entrega el objeto y no escucha sus avisos, asi que una pantalla
/// que lea asi se queda con el primer valor para siempre. Lo destapo la prueba
/// del boton deshabilitado, no la lectura del codigo.
///
/// Esto es lo que usan las pantallas; [senalDeConexionProvider] queda para
/// quien necesite el objeto, como el aviso global con su `ListenableBuilder`.
class EstaSinConexion extends Notifier<bool> {
  @override
  bool build() {
    final senal = ref.watch(senalDeConexionProvider);
    void avisar() => state = senal.sinConexion;
    senal.addListener(avisar);
    ref.onDispose(() => senal.removeListener(avisar));
    return senal.sinConexion;
  }
}

final sinConexionProvider = NotifierProvider<EstaSinConexion, bool>(
  EstaSinConexion.new,
  name: 'sinConexionProvider',
);
