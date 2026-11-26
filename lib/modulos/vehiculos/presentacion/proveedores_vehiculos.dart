import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/modelos/vehiculo.dart';
import '../../../manuales/guardar_pdf.dart';
import '../../../manuales/servicio_manuales.dart';
import '../../../nucleo/api/proveedores_api.dart';
import '../../mantenimiento/mantenimiento.dart';
import '../datos/compartir_manual.dart';
import '../datos/indice_manual_local.dart';
import '../datos/repositorio_ficha_tecnica_api.dart';
import '../datos/repositorio_garaje_api.dart';
import '../dominio/ficha_tecnica_vehiculo.dart';
import '../dominio/indice_de_manual.dart';
import '../dominio/repositorio_ficha_tecnica.dart';
import '../dominio/repositorio_garaje.dart';
import '../dominio/vehiculo_garaje.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioGarajeProvider.overrideWithValue(...)`.
final repositorioGarajeProvider = Provider<RepositorioGaraje>(
  (ref) => RepositorioGarajeApi(ref.watch(carecarApiProvider)),
  name: 'repositorioGarajeProvider',
);

/// Vehiculos del cliente. El `AsyncValue` ya trae cargando, datos y error.
final garajeProvider = FutureProvider<List<VehiculoGaraje>>(
  (ref) => ref.watch(repositorioGarajeProvider).vehiculos(),
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'garajeProvider',
);

/// Un vehiculo del garaje por su id, o `null` si ya no esta. Sale de la misma
/// lectura que el garaje, asi comparte copia guardada y recarga.
final vehiculoProvider = FutureProvider.family<VehiculoGaraje?, int>((
  ref,
  id,
) async {
  final lista = await ref.watch(garajeProvider.future);
  for (final v in lista) {
    if (v.id == id) return v;
  }
  return null;
}, name: 'vehiculoProvider');

/// El km que dejo el taller y cuando: lo que el detalle muestra como
/// «actualizado por el taller el ...».
typedef KmDelTaller = ({int km, DateTime fecha});

/// El km oficial del taller del vehiculo `id` con su fecha, o `null` si no lo
/// hay.
///
/// Desde V2-T05.06 `GET /vehiculos` no trae la fecha: viene en el plan de
/// mantenimiento (`kmActualizadoEn` y `kmFuente`). Una lectura del cliente no
/// se atribuye al taller, y si el plan falla simplemente no hay fecha: el
/// detalle sigue mostrando el km que ya tiene.
final kmDelTallerProvider = FutureProvider.autoDispose
    .family<KmDelTaller?, int>((ref, id) async {
      try {
        final plan = await ref.watch(planMantenimientoProvider(id).future);
        final km = plan.kmActual;
        final fecha = plan.kmActualizadoEn;
        if (plan.kmFuente != FuenteKm.taller || km == null || fecha == null) {
          return null;
        }
        return (km: km, fecha: fecha);
      } on Object {
        return null;
      }
    }, name: 'kmDelTallerProvider');

/// Repositorio de la ficha tecnica (V2-M02.04): API con respaldo local.
final repositorioFichaTecnicaProvider = Provider<RepositorioFichaTecnica>(
  (ref) => RepositorioFichaTecnicaApi(ref.watch(apiClienteProvider)),
  name: 'repositorioFichaTecnicaProvider',
);

/// Ficha tecnica del vehiculo `id`, o `null` si el vehiculo ya no esta en el
/// garaje o nadie tiene su ficha.
final fichaTecnicaProvider = FutureProvider.family<FichaTecnicaVehiculo?, int>(
  (ref, id) async {
    final vehiculo = await ref.watch(vehiculoProvider(id).future);
    if (vehiculo == null) return null;
    return ref.watch(repositorioFichaTecnicaProvider).ficha(vehiculo);
  },
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'fichaTecnicaProvider',
);

/// Fuente de manuales (V2-M02.03): el de la agencia y, si no hay, el PDF
/// incluido en la app.
final servicioManualesProvider = Provider<ServicioManuales>(
  (ref) => ManualesDeLaAgencia(api: ref.watch(carecarApiProvider)),
  name: 'servicioManualesProvider',
);

/// Manual del vehiculo `id` por su modelo y ano, o `null` si el vehiculo ya no
/// esta o no hay manual ni en la agencia ni en la app.
final manualProvider = FutureProvider.family<DocumentoManual?, int>(
  (ref, id) async {
    final v = await ref.watch(vehiculoProvider(id).future);
    if (v == null) return null;
    try {
      return await ref
          .watch(servicioManualesProvider)
          .cargar(
            Vehiculo(
              id: v.id,
              vin: v.vin ?? '',
              modelo: v.modelo,
              anio: v.anio,
              marca: v.marca,
            ),
          );
    } on FalloManual {
      return null;
    }
  },
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'manualProvider',
);

/// Índice de texto del manual empaquetado del vehículo `id`, o `null` si no hay
/// (V2-M02.03). La pantalla ofrece buscar solo cuando este índice existe.
final indiceDeManualProvider = FutureProvider.family<IndiceDeManual?, int>((
  ref,
  id,
) async {
  final v = await ref.watch(vehiculoProvider(id).future);
  if (v == null) return null;
  return cargarIndiceDeManual(
    Vehiculo(
      id: v.id,
      vin: v.vin ?? '',
      modelo: v.modelo,
      anio: v.anio,
      marca: v.marca,
    ),
  );
}, name: 'indiceDeManualProvider');

/// Guarda el PDF con el selector del sistema. Las pruebas lo sustituyen.
final guardarManualProvider =
    Provider<Future<ResultadoGuardado> Function(Uint8List, String)>(
      (ref) =>
          (bytes, titulo) => guardarPdf(bytes, titulo),
      name: 'guardarManualProvider',
    );

/// Abre la hoja de compartir con (bytes, nombre de archivo). Las pruebas lo
/// sustituyen.
final compartirManualProvider =
    Provider<Future<void> Function(Uint8List, String)>(
      (ref) => compartirManualConHojaDelSistema,
      name: 'compartirManualProvider',
    );
