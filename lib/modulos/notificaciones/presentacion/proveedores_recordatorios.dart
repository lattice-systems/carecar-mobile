import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notificaciones/servicio_notificaciones.dart';
import '../datos/recordatorios_del_servicio_v1.dart';
import '../dominio/recordatorios_de_cita.dart';

/// Los recordatorios de cita que usa el modulo de citas · V2-M06.06.
///
/// Toma el servicio de la v1 por `Notificaciones.actual`, que es como lo
/// alcanza hoy el resto de la app; el dia que el servicio se mude a la v2 se
/// cambia aqui y nadie mas se entera.
///
/// En pruebas se sustituye con `overrideWithValue`, o se deja el real con un
/// plugin espia -que es lo que hacen las pruebas de esta historia-.
final recordatoriosDeCitaProvider = Provider<RecordatoriosDeCita>(
  (ref) => RecordatoriosDelServicioV1(Notificaciones.actual),
  name: 'recordatoriosDeCitaProvider',
);
