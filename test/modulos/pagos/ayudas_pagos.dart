import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_datos_fiscales_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/datos_fiscales.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_datos_fiscales.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/tema_pista.dart';

const _deActividad = {
  '601',
  '603',
  '606',
  '612',
  '620',
  '621',
  '622',
  '623',
  '624',
  '625',
  '626',
};
const _deduccionesPersonales = {
  '605',
  '606',
  '607',
  '608',
  '611',
  '612',
  '614',
  '615',
  '625',
};
const _todos = {
  '601',
  '603',
  '605',
  '606',
  '607',
  '608',
  '611',
  '612',
  '614',
  '615',
  '620',
  '621',
  '622',
  '623',
  '624',
  '625',
  '626',
};

/// Un recorte del catalogo del SAT con todas sus reglas: regimenes de cada
/// persona y de las dos, y usos de actividad, de deduccion personal y «sin
/// efectos fiscales».
const catalogoDeEjemplo = CatalogoFiscal(
  regimenes: [
    RegimenFiscal(
      clave: '601',
      descripcion: 'General de Ley Personas Morales',
      fisica: false,
      moral: true,
    ),
    RegimenFiscal(
      clave: '605',
      descripcion: 'Sueldos y Salarios e Ingresos Asimilados a Salarios',
      fisica: true,
      moral: false,
    ),
    RegimenFiscal(
      clave: '612',
      descripcion:
          'Personas Físicas con Actividades Empresariales y Profesionales',
      fisica: true,
      moral: false,
    ),
    RegimenFiscal(
      clave: '626',
      descripcion: 'Régimen Simplificado de Confianza',
      fisica: true,
      moral: true,
    ),
  ],
  usosCfdi: [
    UsoCfdi(
      clave: 'G03',
      descripcion: 'Gastos en general',
      fisica: true,
      moral: true,
      regimenes: _deActividad,
    ),
    UsoCfdi(
      clave: 'I03',
      descripcion: 'Equipo de transporte',
      fisica: true,
      moral: true,
      regimenes: _deActividad,
    ),
    UsoCfdi(
      clave: 'D01',
      descripcion: 'Honorarios médicos, dentales y gastos hospitalarios',
      fisica: true,
      moral: false,
      regimenes: _deduccionesPersonales,
    ),
    UsoCfdi(
      clave: 'S01',
      descripcion: 'Sin efectos fiscales',
      fisica: true,
      moral: true,
      regimenes: _todos,
    ),
  ],
);

/// Persona fisica, predeterminada.
final perfilFisica = PerfilFiscal(
  id: 10,
  rfc: 'GODE561231GR8',
  tipoPersona: TipoPersona.fisica,
  razonSocial: 'DOLORES GÓMEZ',
  regimenFiscal: '612',
  codigoPostal: '76000',
  usoCfdi: 'G03',
  correo: 'lola@correo.mx',
  predeterminado: true,
  creadoEn: DateTime.utc(2026, 11, 20, 18),
);

/// Persona moral, no predeterminada.
final perfilMoral = PerfilFiscal(
  id: 11,
  rfc: 'EKU9003173C9',
  tipoPersona: TipoPersona.moral,
  razonSocial: 'ESCUELA KEMPER URGATE',
  regimenFiscal: '601',
  codigoPostal: '42501',
  usoCfdi: 'I03',
  predeterminado: false,
  creadoEn: DateTime.utc(2026, 11, 21, 18),
);

RepositorioDatosFiscalesFake repoDeEjemplo({List<PerfilFiscal>? perfiles}) =>
    RepositorioDatosFiscalesFake(
      catalogo: catalogoDeEjemplo,
      perfiles: perfiles ?? [perfilFisica, perfilMoral],
      reloj: () => DateTime.utc(2026, 11, 26, 18),
    );

/// Una pantalla del modulo con su fake y el tema Pista sin movimiento.
Widget appPagos(
  Widget pantalla,
  RepositorioDatosFiscalesFake repo, {
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  overrides: [repositorioDatosFiscalesProvider.overrideWithValue(repo)],
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

/// Las rutas del modulo desde `inicial`, para probar que se va y se vuelve.
Widget appPagosEnrutada(
  RepositorioDatosFiscalesFake repo, {
  String inicial = rutaDatosFiscales,
  ProteccionDeCapturaFake? proteccion,
}) => ProviderScope(
  overrides: [
    repositorioDatosFiscalesProvider.overrideWithValue(repo),
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
    routerConfig: GoRouter(initialLocation: inicial, routes: rutasPagos),
  ),
);

/// Pantalla alta para que todo quepa sin desplazar.
void pruebaPagos(
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
