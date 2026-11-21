// Portado de feat/app-perfil (07a2b5c), adaptado a miPerfil() y PantallaAjustes.
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/pantallas/pantalla_ajustes.dart';
import 'package:carecar_mobile/pantallas/pantalla_inicio.dart';
import 'package:carecar_mobile/pantallas/perfil/pantalla_perfil.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

Future<void> _montar(
  WidgetTester tester,
  ApiFalsa api, {
  VoidCallback? alCerrarSesion,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaCareCar.claro,
      home: PantallaAjustes(api: api, alCerrarSesion: alCerrarSesion ?? () {}),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el nombre, las iniciales y el correo', (tester) async {
    final api = ApiFalsa();
    await _montar(tester, api);

    expect(find.text('María Robles'), findsOneWidget);
    expect(find.text('MR'), findsOneWidget);
    expect(find.text('cliente1@example.com'), findsWidgets);
    expect(api.llamadasAPerfil, 1);
  });

  testWidgets('si falla muestra el error y reintenta', (tester) async {
    var intentos = 0;
    final api = ApiFalsa()
      ..alPedirPerfil = () async {
        intentos++;
        if (intentos == 1) throw const SinConexion();
        return const Perfil(
          id: 1,
          nombre: 'María Robles',
          correo: 'cliente1@example.com',
        );
      };
    await _montar(tester, api);

    expect(find.text('Sin conexión'), findsOneWidget);
    await tester.tap(find.byKey(PantallaPerfil.botonReintentar));
    await tester.pumpAndSettle();

    expect(intentos, 2);
    expect(find.text('María Robles'), findsOneWidget);
  });

  testWidgets('cerrar sesion pide confirmacion', (tester) async {
    var cierres = 0;
    await _montar(tester, ApiFalsa(), alCerrarSesion: () => cierres++);
    // El encabezado de PaginaCareCar tambien tiene un boton con la misma
    // llave: se usa el de la lista del perfil (el ultimo).
    final boton = find.byKey(PantallaInicio.botonCerrarSesion).last;

    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);

    await tester.tap(find.byKey(PantallaPerfil.botonCancelarCierre));
    await tester.pumpAndSettle();
    expect(cierres, 0);

    await tester.tap(boton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PantallaPerfil.botonConfirmarCierre));
    await tester.pumpAndSettle();
    expect(cierres, 1);
  });
}
