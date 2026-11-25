import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/api/proveedores_api.dart';
import 'package:carecar_mobile/nucleo/migracion/interruptor_modulos.dart';
import 'package:carecar_mobile/nucleo/migracion/proveedores_migracion.dart';
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
    this.interruptor,
    this.envolver,
    super.key,
  });

  final CarecarApi api;
  final ControladorSesion controlador;

  /// Proveedores extra a sustituir (repositorios de un modulo, por ejemplo).
  final List<Override> overrides;

  /// Que modulos estan en v2 (V2-T01.05). Por omision todos, para que las
  /// pruebas de rutas de los modulos v2 no dependan del valor por defecto de
  /// la app (todo en v1).
  final InterruptorModulos? interruptor;

  /// Envuelve la app como lo hace `main.dart` con lo que no pinta nada (el
  /// verificador del aviso de privacidad, por ejemplo).
  final Widget Function(Widget app)? envolver;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      carecarApiProvider.overrideWithValue(api),
      controladorSesionProvider.overrideWithValue(controlador),
      interruptorModulosProvider.overrideWithValue(
        interruptor ?? InterruptorModulos.todoV2,
      ),
      ...overrides,
    ],
    child: ShadApp.custom(
      theme: TemaCareCar.shad,
      appBuilder: (context) => Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          theme: TemaCareCar.claro,
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          localeResolutionCallback: resolverIdioma,
          routerConfig: ref.watch(enrutadorProvider),
          builder: (context, child) {
            final app = ShadAppBuilder(child: child!);
            return envolver?.call(app) ?? app;
          },
        ),
      ),
    ),
  );
}

/// El enrutador que usa la app montada con [AppEnrutadaDePrueba].
GoRouter enrutadorDe(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(enrutadorProvider);
