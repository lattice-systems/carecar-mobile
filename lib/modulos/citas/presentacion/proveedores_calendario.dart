import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/entrega_de_evento_del_sistema.dart';
import '../dominio/evento_de_calendario.dart';

/// Como se entrega el evento al sistema (hoja de compartir). En pruebas:
/// `entregaDeEventoProvider.overrideWithValue(EntregaDeEventoFake())`.
final entregaDeEventoProvider = Provider<EntregaDeEvento>(
  (ref) => const EntregaDeEventoDelSistema(),
  name: 'entregaDeEventoProvider',
);

/// Cuanto antes de la cita suena el recordatorio del calendario.
const minutosAntesDeLaCita = 60;
