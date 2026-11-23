import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'interruptor_modulos.dart';

/// El interruptor v1/v2 de esta compilacion (V2-T01.05). Lee los
/// `--dart-define=MODULOS_V2/MODULOS_V1`; en pruebas se sustituye con
/// `interruptorModulosProvider.overrideWithValue(...)`.
final interruptorModulosProvider = Provider<InterruptorModulos>(
  (ref) => InterruptorModulos.desdeEntorno(),
  name: 'interruptorModulosProvider',
);
