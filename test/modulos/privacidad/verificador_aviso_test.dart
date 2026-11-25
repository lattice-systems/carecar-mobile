import 'dart:async';

import 'package:carecar_mobile/modulos/privacidad/dominio/privacidad.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/proveedores_privacidad.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/verificador_aviso.dart';
import 'package:carecar_mobile/nucleo/privacidad/estado_aviso.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import 'repositorio_privacidad_falso.dart';

AvisoDePrivacidad _aviso({bool aceptado = false}) => AvisoDePrivacidad(
  id: 3,
  version: 2,
  texto: 'Texto.',
  vigenteDesde: DateTime.utc(2026, 11, 25, 18),
  aceptado: aceptado,
  aceptadoEn: aceptado ? DateTime.utc(2026, 11, 26) : null,
);

Future<ControladorSesion> _montar(
  WidgetTester tester,
  RepositorioPrivacidadFalso repo, {
  bool conSesion = false,
}) async {
  final sesion = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioPrivacidadProvider.overrideWithValue(repo),
        controladorSesionProvider.overrideWithValue(sesion),
      ],
      child: const MaterialApp(home: VerificadorDeAviso(child: Text('la app'))),
    ),
  );
  await tester.pump();
  return sesion;
}

EstadoAviso _estado(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(estadoAvisoProvider);

Future<void> _dejarCorrer(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

void main() {
  group('VerificadorDeAviso (V2-M22.01)', () {
    testWidgets('muestra lo que envuelve', (tester) async {
      await _montar(tester, RepositorioPrivacidadFalso()..avisos.add(_aviso()));
      expect(find.text('la app'), findsOneWidget);
    });

    testWidgets('sin sesion no pregunta nada ni bloquea', (tester) async {
      final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
      await _montar(tester, repo);
      await _dejarCorrer(tester);

      expect(repo.lecturas, 0);
      expect(_estado(tester), EstadoAviso.noRequerido);
    });

    testWidgets('al iniciar sesion espera al servidor y queda pendiente', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(_aviso())
        ..esperaAlLeer = Completer<void>();
      final sesion = await _montar(tester, repo);

      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      await tester.pump();

      // Mientras responde, la guardia ya retiene al usuario en la puerta.
      expect(_estado(tester), EstadoAviso.verificando);

      repo.esperaAlLeer!.complete();
      await _dejarCorrer(tester);

      expect(repo.lecturas, 1);
      expect(_estado(tester), EstadoAviso.pendiente);
    });

    testWidgets('si ya lo acepto, queda aceptado', (tester) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(_aviso(aceptado: true));
      final sesion = await _montar(tester, repo);

      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      await _dejarCorrer(tester);

      expect(_estado(tester), EstadoAviso.aceptado);
    });

    testWidgets('con una sesion restaurada al arrancar, tambien verifica', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
      await _montar(tester, repo, conSesion: true);
      await _dejarCorrer(tester);

      expect(repo.lecturas, 1);
      expect(_estado(tester), EstadoAviso.pendiente);
    });

    testWidgets('sin conexion no deja a nadie fuera', (tester) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(const PrivacidadSinConexion());
      final sesion = await _montar(tester, repo);

      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      await _dejarCorrer(tester);

      expect(_estado(tester), EstadoAviso.noRequerido);
    });

    testWidgets('un error inesperado tampoco bloquea', (tester) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(const PrivacidadNoDisponible());
      final sesion = await _montar(tester, repo);

      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      await _dejarCorrer(tester);

      expect(_estado(tester), EstadoAviso.noRequerido);
    });

    testWidgets('otra cuenta en el mismo telefono vuelve a preguntar', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.addAll([_aviso(aceptado: true), _aviso()]);
      final sesion = await _montar(tester, repo);

      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      await _dejarCorrer(tester);
      expect(_estado(tester), EstadoAviso.aceptado);

      await sesion.cerrarSesion();
      await _dejarCorrer(tester);
      expect(_estado(tester), EstadoAviso.noRequerido);

      await sesion.iniciarSesion(correo: 'otra@b.mx', contrasena: 'x');
      await _dejarCorrer(tester);

      expect(repo.lecturas, 2);
      expect(_estado(tester), EstadoAviso.pendiente);
    });
  });
}
