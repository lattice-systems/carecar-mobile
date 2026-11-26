import 'dart:convert';

import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/presentacion/proveedores_valuacion.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/nucleo/camara/selector_foto.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

const leyenda =
    'Estimación no vinculante. No es una oferta de compra: el valor final lo '
    'define la agencia cuando revise tu auto.';

/// Un PNG de 1x1, para no salir a la red.
final pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGA'
  'WjR9awAAAABJRU5ErkJggg==',
);

FotoValuacion foto(TomaValuacion toma) => FotoValuacion(
  toma: toma,
  url: '/api/v1/archivos/valuacion-fotos/${toma.index + 1}',
  subidaEn: DateTime.utc(2026, 11, 24, 12),
);

Valuacion valuacion({
  int id = 1,
  EstadoValuacion estado = EstadoValuacion.solicitada,
  List<FotoValuacion> fotos = const [],
  bool? puedeAgendar,
  InspeccionValuacion? cita,
  OfertaValuacion? oferta,
  String? asesor,
}) => Valuacion(
  id: id,
  estado: estado,
  creadaEn: DateTime.utc(2026, 11, 20, 12),
  vehiculoId: 5,
  estimacion: EstimacionDeValuacion(
    id: 10 + id,
    creadaEn: DateTime.utc(2026, 11, 19, 12),
    marca: 'Nissan',
    modelo: 'March',
    anio: 2020,
    km: 48000,
    minimo: 100000,
    maximo: 120000,
  ),
  fotos: fotos,
  puedeAgendar: puedeAgendar ?? estado == EstadoValuacion.solicitada,
  cita: cita,
  oferta: oferta,
  asesor: asesor,
);

final inspeccion = InspeccionValuacion(
  citaId: 31,
  fecha: DateTime(2026, 11, 27),
  horaInicio: '09:00',
  horaFin: '10:00',
);

final oferta = OfertaValuacion(
  monto: 112500,
  vigenciaHasta: DateTime(2026, 12, 4),
  ofertadaEn: DateTime.utc(2026, 11, 27, 18),
  nota: 'Incluye el juego de llantas.',
);

Valuacion ofertada({int id = 1, String? asesor = 'Vera Vendedora'}) =>
    valuacion(
      id: id,
      estado: EstadoValuacion.ofertada,
      cita: inspeccion,
      oferta: oferta,
      asesor: asesor,
    );

PuntoValorEstimado punto(int mes, double medio) => PuntoValorEstimado(
  mes: DateTime(2026, mes),
  estimacionId: mes,
  creadaEn: DateTime.utc(2026, mes, 10),
  minimo: medio - 10000,
  maximo: medio + 10000,
  medio: medio,
  km: 40000 + mes * 1000,
);

/// Camara falsa: entrega un pixel, cancela o niega el permiso.
class SelectorFalso implements SelectorFoto {
  SelectorFalso({this.negado = false, this.cancela = false});

  bool negado;
  bool cancela;
  final pedidos = <OrigenFoto>[];
  var ajustesAbiertos = 0;

  @override
  Future<FotoElegida?> elegir(OrigenFoto origen) async {
    pedidos.add(origen);
    if (negado) throw const PermisoFotoDenegado();
    if (cancela) return null;
    return FotoElegida(bytes: pixel, tipo: 'image/jpeg');
  }

  @override
  Future<void> abrirAjustes() async => ajustesAbiertos++;
}

final lunes = DateTime(2026, 11, 25);

RepositorioCitasFake citasConCupo() => RepositorioCitasFake(
  franjas: [
    FranjaDisponible(
      franjaId: 3,
      fecha: DateTime(2026, 11, 27),
      horaInicio: '09:00',
      horaFin: '10:00',
      cupo: 2,
    ),
  ],
);

List<Override> sustitutos({
  required RepositorioValuacionFake repositorio,
  EventosEnVivoFake? eventos,
  SelectorFoto? selector,
  List<Override> extra = const [],
}) => [
  repositorioValuacionProvider.overrideWithValue(repositorio),
  eventosEnVivoProvider.overrideWithValue(eventos ?? EventosEnVivoFake()),
  imagenValuacionProvider.overrideWithValue((_) => MemoryImage(pixel)),
  if (selector != null) selectorValuacionProvider.overrideWithValue(selector),
  ...extra,
];

/// Monta una pantalla del modulo con el tema Pista y sus falsos.
Widget app(
  Widget pantalla, {
  required RepositorioValuacionFake repositorio,
  EventosEnVivoFake? eventos,
  SelectorFoto? selector,
  List<Override> extra = const [],
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  // Cada escenario monta proveedores nuevos.
  key: UniqueKey(),
  overrides: sustitutos(
    repositorio: repositorio,
    eventos: eventos,
    selector: selector,
    extra: extra,
  ),
  child: conTemaPista(pantalla, escenario: escenario, ancho: ancho),
);

void pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
