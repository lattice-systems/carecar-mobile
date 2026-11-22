import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_citas_api.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/repositorio_citas.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioCitasProvider.overrideWithValue(RepositorioCitasFake())`.
final repositorioCitasProvider = Provider<RepositorioCitas>(
  (ref) => RepositorioCitasApi(ref.watch(carecarApiProvider)),
  name: 'repositorioCitasProvider',
);

/// Reloj del modulo: de donde sale "hoy". Se sustituye en pruebas para que no
/// dependan de la fecha real.
final relojCitasProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
  name: 'relojCitasProvider',
);

/// Cuantos dias hacia adelante se puede agendar.
const diasAgendables = 60;

/// Primer y ultimo dia que el calendario deja elegir: de hoy a `diasAgendables`.
final rangoAgendableProvider = Provider<({DateTime desde, DateTime hasta})>((
  ref,
) {
  final ahora = ref.watch(relojCitasProvider)();
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  return (
    desde: hoy,
    hasta: DateTime(hoy.year, hoy.month, hoy.day + diasAgendables),
  );
}, name: 'rangoAgendableProvider');

/// Disponibilidad del taller en el rango agendable. El `AsyncValue` ya trae
/// cargando, datos y error.
final disponibilidadProvider = FutureProvider<DisponibilidadTaller>(
  (ref) {
    final rango = ref.watch(rangoAgendableProvider);
    return ref
        .watch(repositorioCitasProvider)
        .disponibilidad(desde: rango.desde, hasta: rango.hasta);
  },
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'disponibilidadProvider',
);
