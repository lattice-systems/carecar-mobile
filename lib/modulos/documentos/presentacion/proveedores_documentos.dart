import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../vehiculos/vehiculos.dart';
import '../datos/repositorio_documentos_api.dart';
import '../dominio/documento_vehiculo.dart';
import '../dominio/repositorio_documentos.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioDocumentosProvider.overrideWithValue(RepositorioDocumentosFake())`.
final repositorioDocumentosProvider = Provider<RepositorioDocumentos>(
  (ref) => RepositorioDocumentosApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioDocumentosProvider',
);

/// Los documentos del vehiculo con su estado (V2-M09.01). El estado lo calcula
/// el servidor con la fecha de la agencia, asi que se pide de nuevo cada vez
/// que se abre la pantalla.
final documentosProvider = FutureProvider.autoDispose
    .family<List<DocumentoVehiculo>, int>(
      (ref, vehiculoId) =>
          ref.watch(repositorioDocumentosProvider).documentos(vehiculoId),
      // El reintento es del usuario (boton de EstadoError), no automatico.
      retry: (_, _) => null,
      name: 'documentosProvider',
    );

typedef VencimientoVehiculo = ({
  VehiculoGaraje vehiculo,
  DocumentoVehiculo documento,
  DateTime fecha,
});

final vencimientosGarajeProvider =
    FutureProvider.autoDispose<List<VencimientoVehiculo>>((ref) async {
      final vehiculos = await ref.watch(garajeProvider.future);
      if (!ref.mounted) return [];
      final documentosPorVehiculo = await Future.wait([
        for (final vehiculo in vehiculos)
          ref.watch(documentosProvider(vehiculo.id).future),
      ]);

      final vencimientos = [
        for (var i = 0; i < vehiculos.length; i++)
          for (final documento in documentosPorVehiculo[i])
            if (documento.venceEn case final fecha?)
              (vehiculo: vehiculos[i], documento: documento, fecha: fecha),
      ];
      vencimientos.sort((a, b) => a.fecha.compareTo(b.fecha));
      return vencimientos;
    }, retry: (_, _) => null);

/// Solicita los bytes del archivo protegido al abrir el visor o reintentar.
final pdfDocumentoProvider = Provider.autoDispose
    .family<Future<Uint8List> Function(), int>((ref, id) {
      final api = ref.watch(apiClienteProvider);
      return () => api.descargar('/documentos/$id/archivo');
    });
