import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/campana_seguridad.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/garantia_vehiculo.dart';
import 'package:carecar_mobile/modulos/garantia/presentacion/proveedores_garantia.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Lunes. El fake de citas deja sin cupo los fines de semana y los dias que
/// terminan en 0 o 5.
final hoyGarantia = DateTime(2026, 11, 23);

/// Un Nissan March con tres coberturas: bateria por vencer por fecha, motor
/// por vencer por km y corrosion vigente.
GarantiaVehiculo garantiaDeEjemplo({int vehiculoId = 5, int? kmActual}) =>
    GarantiaVehiculo(
      vehiculoId: vehiculoId,
      kmActual: kmActual ?? 59200,
      coberturas: [
        CoberturaGarantia(
          id: 1,
          componente: 'Batería',
          descripcion: 'Falla de fábrica de la batería original.',
          iniciaEn: DateTime(2024, 1, 15),
          venceEn: DateTime(2026, 12, 23),
          diasRestantes: 30,
          consumo: 97,
          estado: EstadoCobertura.porVencer,
          limite: LimiteCobertura.fecha,
        ),
        CoberturaGarantia(
          id: 2,
          componente: 'Motor y transmisión',
          iniciaEn: DateTime(2024, 1, 15),
          venceEn: DateTime(2027, 1, 15),
          kmLimite: 60000,
          diasRestantes: 53,
          kmRestantes: 800,
          consumo: 98,
          estado: EstadoCobertura.porVencer,
          limite: LimiteCobertura.km,
        ),
        CoberturaGarantia(
          id: 3,
          componente: 'Corrosión',
          iniciaEn: DateTime(2024, 1, 15),
          venceEn: DateTime(2030, 1, 15),
          diasRestantes: 1149,
          consumo: 32,
          estado: EstadoCobertura.vigente,
          limite: LimiteCobertura.fecha,
        ),
      ],
    );

/// Una campana critica pendiente y otra atendida.
List<CampanaSeguridad> campanasDeEjemplo() => [
  CampanaSeguridad(
    id: 7,
    codigo: 'RC-24-017',
    titulo: 'Bolsa de aire del conductor',
    descripcion: 'El inflador puede activarse con fuerza de más.',
    queHacer: 'Agenda una revisión; el cambio no tiene costo.',
    gravedad: GravedadCampana.critica,
    estado: EstadoCampana.abierta,
    publicadaEn: DateTime.utc(2026, 11, 20, 15),
  ),
  CampanaSeguridad(
    id: 4,
    codigo: 'RC-23-002',
    titulo: 'Tornillo del soporte del motor',
    descripcion: 'Un tornillo podía aflojarse con el tiempo.',
    queHacer: 'Ya se revisó en tu último servicio.',
    gravedad: GravedadCampana.media,
    estado: EstadoCampana.atendida,
    citaId: 12,
    publicadaEn: DateTime.utc(2025, 3, 2, 15),
  ),
];

/// Una campana con lo minimo, para variar estado y gravedad.
CampanaSeguridad campana({
  int id = 9,
  EstadoCampana estado = EstadoCampana.abierta,
  GravedadCampana gravedad = GravedadCampana.media,
  int? citaId,
}) => CampanaSeguridad(
  id: id,
  codigo: 'RC-26-0$id',
  titulo: 'Campaña $id',
  descripcion: 'Descripción $id',
  queHacer: 'Qué hacer $id',
  gravedad: gravedad,
  estado: estado,
  citaId: citaId,
  publicadaEn: DateTime.utc(2026, 11, 1),
);

/// Una pantalla del modulo con su fake, el canal de eventos en memoria, la
/// agenda del taller falsa con "hoy" fijo y el tema Pista sin movimiento.
Widget appGarantia(
  Widget pantalla,
  RepositorioGarantiaFake repo, {
  EventosEnVivoFake? eventos,
  RepositorioCitasFake? citas,
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  overrides: [
    repositorioGarantiaProvider.overrideWithValue(repo),
    eventosEnVivoProvider.overrideWithValue(eventos ?? EventosEnVivoFake()),
    repositorioCitasProvider.overrideWithValue(
      citas ?? RepositorioCitasFake(reloj: () => hoyGarantia),
    ),
    relojCitasProvider.overrideWithValue(() => hoyGarantia),
  ],
  child: conTemaPista(
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: pantalla,
      ),
    ),
    escenario: escenario,
    ancho: ancho,
  ),
);

/// Pantalla alta para que todo quepa sin desplazar.
void pruebaGarantia(
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
