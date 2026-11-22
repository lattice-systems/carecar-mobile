import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/nucleo/api/proveedores_api.dart';
import 'package:carecar_mobile/nucleo/navegacion/proveedores_navegacion.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// La app con el enrutador real (V2-T01.03) y la API y la sesion que se le
/// pasen. Es lo que `main.dart` arma, sin cortina ni almacen del sistema.
class AppEnrutadaDePrueba extends StatelessWidget {
  const AppEnrutadaDePrueba({
    required this.api,
    required this.controlador,
    this.overrides = const [],
    super.key,
  });

  final CarecarApi api;
  final ControladorSesion controlador;

  /// Proveedores extra a sustituir (repositorios de un modulo, por ejemplo).
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      carecarApiProvider.overrideWithValue(api),
      controladorSesionProvider.overrideWithValue(controlador),
      ...overrides,
    ],
    child: ShadApp.custom(
      theme: TemaCareCar.shad,
      appBuilder: (context) => Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          theme: TemaCareCar.claro,
          routerConfig: ref.watch(enrutadorProvider),
          builder: (context, child) => ShadAppBuilder(child: child!),
        ),
      ),
    ),
  );
}

/// El enrutador que usa la app montada con [AppEnrutadaDePrueba].
GoRouter enrutadorDe(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(enrutadorProvider);
