import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_datos_fiscales_fake.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_datos_fiscales.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_pagos.dart';

/// El dia de las pruebas: las tarjetas de prueba que vencen en 12/28 sirven.
final hoyDePrueba = DateTime(2026, 11, 26, 12);

/// Una orden lista para pagar: 1,650 con IVA.
final ordenLista = OrdenPorPagar(
  ordenId: 41,
  vehiculoId: 9,
  fecha: DateTime(2026, 11, 26),
  totalManoDeObra: 1200,
  totalRefacciones: 450,
  subtotal: 1422.41,
  iva: 227.59,
  total: 1650,
  pagable: true,
);

/// La Visa 4242 guardada y predeterminada.
const visaGuardada = MetodoPago(
  id: 1,
  marca: 'VISA',
  ultimos4: '4242',
  tipo: TipoTarjeta.credito,
  mesVence: 12,
  anioVence: 2028,
  vencida: false,
  predeterminado: true,
);

/// Una Mastercard guardada que ya vencio.
const masterVencida = MetodoPago(
  id: 2,
  marca: 'MASTERCARD',
  ultimos4: '4444',
  tipo: TipoTarjeta.credito,
  mesVence: 1,
  anioVence: 2025,
  vencida: true,
  predeterminado: false,
);

Pago pagoDeEjemplo({
  int id = 7,
  int ordenId = 41,
  EstadoPago estado = EstadoPago.pagado,
  MotivoFalloPago? motivo,
  bool requiereAutenticacion = false,
  MedioPago medio = MedioPago.tarjeta,
  String ultimos4 = '4242',
  double monto = 1650,
  DateTime? creadoEn,
}) => Pago(
  id: id,
  ordenId: ordenId,
  vehiculoId: 9,
  monto: monto,
  medio: medio,
  marca: medio == MedioPago.caja ? null : 'VISA',
  ultimos4: medio == MedioPago.caja ? null : ultimos4,
  tipoTarjeta: medio == MedioPago.caja ? null : TipoTarjeta.credito,
  estado: estado,
  motivoFallo: motivo,
  requiereAutenticacion: requiereAutenticacion,
  referencia: 'sim_pi_$id',
  simulado: medio != MedioPago.caja,
  creadoEn: creadoEn ?? DateTime.utc(2026, 11, 26, 18),
  pagadoEn: estado == EstadoPago.pagado ? DateTime.utc(2026, 11, 26, 18) : null,
);

RepositorioPagosFake repoCobro({
  List<OrdenPorPagar>? ordenes,
  List<Pago> pagos = const [],
  List<MetodoPago> metodos = const [],
}) => RepositorioPagosFake(
  ordenes: {
    for (final o in ordenes ?? [ordenLista]) o.ordenId: o,
  },
  pagos: pagos,
  metodos: metodos,
);

List<Override> _overrides(
  RepositorioPagosFake pagos,
  RepositorioDatosFiscalesFake? fiscales,
  EventosEnVivoFake? eventos,
) => [
  repositorioPagosProvider.overrideWithValue(pagos),
  repositorioDatosFiscalesProvider.overrideWithValue(
    fiscales ?? repoDeEjemplo(perfiles: const []),
  ),
  eventosEnVivoProvider.overrideWithValue(eventos ?? EventosEnVivoFake()),
  hoyPagosProvider.overrideWithValue(() => hoyDePrueba),
];

/// Una pantalla de pagos con sus fakes y el tema Pista sin movimiento.
Widget appCobro(
  Widget pantalla,
  RepositorioPagosFake pagos, {
  RepositorioDatosFiscalesFake? fiscales,
  EventosEnVivoFake? eventos,
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  overrides: _overrides(pagos, fiscales, eventos),
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

/// Las rutas de pagos desde `inicial`, con un ticket de mentira para probar
/// que se llega a el.
Widget appCobroEnrutada(
  RepositorioPagosFake pagos, {
  required String inicial,
  RepositorioDatosFiscalesFake? fiscales,
  EventosEnVivoFake? eventos,
  ProteccionDeCapturaFake? proteccion,
}) => ProviderScope(
  overrides: [
    ..._overrides(pagos, fiscales, eventos),
    proteccionDeCapturaProvider.overrideWithValue(
      proteccion ?? ProteccionDeCapturaFake(),
    ),
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
    routerConfig: GoRouter(
      initialLocation: inicial,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('inicio')),
        ),
        GoRoute(
          path: '/historial/:vehiculoId/ticket/:servicioId',
          builder: (_, state) => Scaffold(
            body: Text('ticket ${state.pathParameters['servicioId']}'),
          ),
        ),
        ...rutasPagos,
      ],
    ),
  ),
);

/// Escribe en un campo de texto del sistema de diseno.
Future<void> escribir(WidgetTester tester, Key campo, String texto) async {
  await tester.enterText(
    find.descendant(of: find.byKey(campo), matching: find.byType(EditableText)),
    texto,
  );
  await tester.pump();
}
