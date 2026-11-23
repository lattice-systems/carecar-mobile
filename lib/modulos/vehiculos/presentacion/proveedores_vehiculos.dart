import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/modelos/vehiculo.dart';
import '../../../manuales/guardar_pdf.dart';
import '../../../manuales/servicio_manuales.dart';
import '../../../nucleo/api/proveedores_api.dart';
import '../datos/compartir_manual.dart';
import '../datos/repositorio_ficha_tecnica_api.dart';
import '../datos/repositorio_garaje_api.dart';
import '../dominio/ficha_tecnica_vehiculo.dart';
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

/// Repositorio de la ficha tecnica (V2-M02.04): API con respaldo local.
final repositorioFichaTecnicaProvider = Provider<RepositorioFichaTecnica>(
  (ref) => RepositorioFichaTecnicaApi(ref.watch(apiClienteProvider)),
  name: 'repositorioFichaTecnicaProvider',
);

/// Ficha tecnica del vehiculo `id`, o `null` si el vehiculo ya no esta en el
/// garaje o nadie tiene su ficha.
final fichaTecnicaProvider =
    FutureProvider.family<FichaTecnicaVehiculo?, int>((ref, id) async {
      final vehiculo = await ref.watch(vehiculoProvider(id).future);
      if (vehiculo == null) return null;
      return ref.watch(repositorioFichaTecnicaProvider).ficha(vehiculo);
    }, name: 'fichaTecnicaProvider');

/// Fuente de manuales (V2-M02.03): el de la agencia y, si no hay, el PDF
/// incluido en la app.
final servicioManualesProvider = Provider<ServicioManuales>(
  (ref) => ManualesDeLaAgencia(api: ref.watch(carecarApiProvider)),
  name: 'servicioManualesProvider',
);

/// Manual del vehiculo `id` por su modelo y ano, o `null` si el vehiculo ya no
/// esta o no hay manual ni en la agencia ni en la app.
final manualProvider = FutureProvider.family<DocumentoManual?, int>((
  ref,
  id,
) async {
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
}, name: 'manualProvider');

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
