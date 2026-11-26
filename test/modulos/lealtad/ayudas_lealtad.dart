import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/dominio/lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/proveedores_lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/rutas_lealtad.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/tema_pista.dart';

/// Martes.
final hoyLealtad = DateTime(2026, 11, 24, 12);

/// 1,330 puntos en Plata con 1,630 ganados; le faltan 2,370 para Oro.
const resumenPlata = ResumenLealtad(
  saldo: 1330,
  nivel: NivelLealtad.plata,
  ganados: 1630,
  siguienteNivel: NivelLealtad.oro,
  puntosParaSiguiente: 2370,
  codigoReferido: 'CC00001',
);

/// En Oro no hay siguiente nivel.
const resumenOro = ResumenLealtad(
  saldo: 5200,
  nivel: NivelLealtad.oro,
  ganados: 4300,
  puntosParaSiguiente: 0,
  codigoReferido: 'CC00001',
);

/// Lo que alcanza (300), lo que no (1,500) y lo agotado (400).
List<Recompensa> recompensasDeEjemplo() => const [
  Recompensa(
    id: 1,
    nombre: 'Lavado exprés',
    descripcion: 'Lavado exterior a mano mientras esperas.',
    puntos: 300,
  ),
  Recompensa(id: 5, nombre: 'Termo CareCar', puntos: 400, existencia: 0),
  Recompensa(
    id: 4,
    nombre: 'Kit de tapetes',
    descripcion: 'Juego de tapetes de hule a la medida de tu auto.',
    puntos: 1500,
    existencia: 5,
  ),
];

/// Un canje vigente y otro usado.
List<Canje> canjesDeEjemplo() => [
  Canje(
    id: 2,
    codigo: '5A6H4J78',
    recompensa: '10 % en mano de obra',
    puntos: 800,
    estado: EstadoCanje.vigente,
    venceEn: DateTime.utc(2026, 12, 24, 18),
    creadoEn: DateTime.utc(2026, 11, 24, 18),
  ),
  Canje(
    id: 1,
    codigo: 'K7XQ2MPA',
    recompensa: 'Lavado exprés',
    puntos: 300,
    estado: EstadoCanje.usado,
    venceEn: DateTime.utc(2026, 11, 9, 18),
    usadoEn: DateTime.utc(2026, 10, 12, 18),
    creadoEn: DateTime.utc(2026, 10, 10, 18),
  ),
];

/// Un movimiento por motivo, del mas nuevo.
List<MovimientoPuntos> movimientosDeEjemplo() => [
  MovimientoPuntos(
    id: 4,
    puntos: -300,
    motivo: MotivoPuntos.canje,
    referenciaTipo: 'CANJE',
    referenciaId: 1,
    creadoEn: DateTime.utc(2026, 10, 10, 18),
  ),
  MovimientoPuntos(
    id: 3,
    puntos: 500,
    motivo: MotivoPuntos.referido,
    referenciaTipo: 'REFERIDO',
    referenciaId: 1,
    creadoEn: DateTime.utc(2026, 10, 5, 18),
  ),
  MovimientoPuntos(
    id: 2,
    puntos: 230,
    motivo: MotivoPuntos.servicio,
    referenciaTipo: 'ORDEN',
    referenciaId: 2,
    creadoEn: DateTime.utc(2026, 8, 30, 18),
  ),
  MovimientoPuntos(
    id: 1,
    puntos: 900,
    motivo: MotivoPuntos.ajuste,
    creadoEn: DateTime.utc(2026, 7, 1, 18),
  ),
];

/// `cuantos` ajustes de 10 puntos, del mas nuevo, para paginar.
List<MovimientoPuntos> muchosMovimientos(int cuantos) => [
  for (var i = cuantos; i > 0; i--)
    MovimientoPuntos(
      id: i,
      puntos: 10,
      motivo: MotivoPuntos.ajuste,
      creadoEn: DateTime.utc(2026, 1, 1).add(Duration(days: i)),
    ),
];

/// Un referido que compro y otro en seguimiento.
List<Referido> referidosDeEjemplo() => [
  Referido(
    id: 2,
    nombre: 'Jorge Ruiz',
    estado: EstadoReferido.enSeguimiento,
    puntos: 0,
    creadoEn: DateTime.utc(2026, 11, 15, 18),
  ),
  Referido(
    id: 1,
    nombre: 'Laura Méndez',
    estado: EstadoReferido.compro,
    puntos: 500,
    creadoEn: DateTime.utc(2026, 9, 2, 18),
  ),
];

/// Lealtad completa del cliente de ejemplo.
RepositorioLealtadFake repoDeEjemplo({ResumenLealtad resumen = resumenPlata}) =>
    RepositorioLealtadFake(
      resumen: resumen,
      recompensas: recompensasDeEjemplo(),
      canjes: canjesDeEjemplo(),
      movimientos: movimientosDeEjemplo(),
      referidos: referidosDeEjemplo(),
      reloj: () => hoyLealtad,
    );

/// Una pantalla del modulo con su fake, el canal de eventos en memoria, lo
/// que se comparte guardado en `compartidos` y el tema Pista sin movimiento.
Widget appLealtad(
  Widget pantalla,
  RepositorioLealtadFake repo, {
  EventosEnVivoFake? eventos,
  List<String>? compartidos,
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  overrides: [
    repositorioLealtadProvider.overrideWithValue(repo),
    eventosEnVivoProvider.overrideWithValue(eventos ?? EventosEnVivoFake()),
    compartirTextoProvider.overrideWithValue((texto) async {
      compartidos?.add(texto);
    }),
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

/// Las rutas del modulo desde `inicial`, para probar que una pantalla lleva a
/// otra.
Widget appLealtadEnrutada(
  RepositorioLealtadFake repo, {
  String inicial = rutaLealtad,
  EventosEnVivoFake? eventos,
}) => ProviderScope(
  overrides: [
    repositorioLealtadProvider.overrideWithValue(repo),
    eventosEnVivoProvider.overrideWithValue(eventos ?? EventosEnVivoFake()),
    compartirTextoProvider.overrideWithValue((_) async {}),
  ],
  child: MaterialApp.router(
    locale: idiomaBase,
    localizationsDelegates: delegadasDeIdioma,
    supportedLocales: idiomasSoportados,
    theme: TemaPista.claro(),
    builder: (context, hijo) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: hijo!,
    ),
    routerConfig: GoRouter(initialLocation: inicial, routes: rutasLealtad),
  ),
);

/// Pantalla alta para que todo quepa sin desplazar.
void pruebaLealtad(
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
