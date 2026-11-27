import 'package:carecar_mobile/modulos/documentos/dominio/documento_vehiculo.dart';
import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_fake.dart';
import 'package:carecar_mobile/modulos/documentos/presentacion/proveedores_documentos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Un documento con lo minimo; los datos que no se pasan quedan vacios.
DocumentoVehiculo documento({
  int id = 1,
  int vehiculoId = 5,
  TipoDocumento tipo = TipoDocumento.verificacion,
  String? titulo,
  String? numero,
  DateTime? emitidoEn,
  DateTime? venceEn,
  EstadoDocumento estado = EstadoDocumento.vigente,
  int? diasRestantes,
  OrigenDocumento origen = OrigenDocumento.cliente,
  bool tieneArchivo = false,
  String? aseguradora,
  String? telefono,
}) => DocumentoVehiculo(
  id: id,
  vehiculoId: vehiculoId,
  tipo: tipo,
  titulo: titulo,
  numero: numero,
  emitidoEn: emitidoEn,
  venceEn: venceEn,
  estado: estado,
  diasRestantes: diasRestantes,
  origen: origen,
  tieneArchivo: tieneArchivo,
  aseguradora: aseguradora,
  telefonoAseguradora: telefono,
);

/// Los cuatro estados del contrato en un auto: poliza por vencer, tarjeta
/// vigente, verificacion vencida y factura de la agencia sin fecha.
List<DocumentoVehiculo> documentosDeEjemplo({int vehiculoId = 5}) => [
  documento(
    id: 3,
    vehiculoId: vehiculoId,
    tipo: TipoDocumento.verificacion,
    numero: 'VER-0501',
    emitidoEn: DateTime(2025, 10, 23),
    venceEn: DateTime(2026, 10, 23),
    estado: EstadoDocumento.vencido,
    diasRestantes: -35,
  ),
  documento(
    id: 1,
    vehiculoId: vehiculoId,
    tipo: TipoDocumento.poliza,
    numero: 'POL-501-2026',
    emitidoEn: DateTime(2025, 12, 28),
    venceEn: DateTime(2026, 12, 27),
    estado: EstadoDocumento.porVencer,
    diasRestantes: 30,
    aseguradora: 'Seguros Ejemplo',
    telefono: '+52 800 000 1234',
  ),
  documento(
    id: 2,
    vehiculoId: vehiculoId,
    tipo: TipoDocumento.tarjetaCirculacion,
    numero: 'TC-GTO-501-S',
    emitidoEn: DateTime(2026, 5, 11),
    venceEn: DateTime(2028, 5, 10),
    estado: EstadoDocumento.vigente,
    diasRestantes: 530,
  ),
  documento(
    id: 4,
    vehiculoId: vehiculoId,
    tipo: TipoDocumento.factura,
    numero: 'A-1042',
    emitidoEn: DateTime(2026, 7, 30),
    estado: EstadoDocumento.sinFecha,
    origen: OrigenDocumento.agencia,
  ),
];

/// Una pantalla del modulo con su fake y el tema Pista sin movimiento.
Widget appDocumentos(
  Widget pantalla,
  RepositorioDocumentosFake repo, {
  Escenario escenario = Escenario.claro,
  double ancho = 360,
  Locale idioma = const Locale('es'),
}) => ProviderScope(
  overrides: [repositorioDocumentosProvider.overrideWithValue(repo)],
  child: conTemaPista(
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: pantalla,
      ),
    ),
    escenario: escenario,
    ancho: ancho,
    idioma: idioma,
  ),
);

/// Pantalla alta para que todo quepa sin desplazar.
void pruebaDocumentos(
  String descripcion,
  Future<void> Function(WidgetTester) cuerpo,
) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}
