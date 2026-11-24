import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/nucleo/datos/vista_asincrona.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// V2-T01.08 · criterio 3: una vista que pinta los cinco estados desde un
/// `AsyncValue`, igual en todos los modulos.
///
/// Antes de esta historia cada pantalla repetia a mano
/// `error is SinConexion ? CausaError.sinConexion : CausaError.generico` y
/// decidia por su cuenta cuando algo estaba vacio.
void main() {
  Widget vista(
    AsyncValue<List<String>> estado, {
    VoidCallback? alReintentar,
    bool Function(List<String>)? estaVacio,
    WidgetBuilder? vacio,
  }) => conTemaPista(
    VistaAsincrona<List<String>>(
      estado: estado,
      cargando: (_) => const Esqueleto(alto: 72),
      datos: (_, lista) => Text(lista.join(', ')),
      estaVacio: estaVacio,
      vacio: vacio,
      alReintentar: alReintentar,
    ),
  );

  Widget vacioDePrueba(BuildContext _) =>
      const EstadoVacio(titulo: 'Aun no tienes nada');

  group('los cinco estados', () {
    testWidgets('cargando pinta el esqueleto que dio el modulo', (
      tester,
    ) async {
      await tester.pumpWidget(vista(const AsyncValue.loading()));
      expect(find.byType(Esqueleto), findsOneWidget);
      expect(find.byType(EstadoError), findsNothing);
    });

    testWidgets('con datos pinta el contenido', (tester) async {
      await tester.pumpWidget(vista(const AsyncValue.data(['uno', 'dos'])));
      expect(find.text('uno, dos'), findsOneWidget);
    });

    testWidgets('una lista vacia pinta el estado vacio', (tester) async {
      await tester.pumpWidget(
        vista(const AsyncValue.data([]), vacio: vacioDePrueba),
      );
      expect(find.byType(EstadoVacio), findsOneWidget);
      expect(find.text('Aun no tienes nada'), findsOneWidget);
    });

    testWidgets('un error pinta EstadoError con la causa generica', (
      tester,
    ) async {
      await tester.pumpWidget(
        vista(
          AsyncValue.error(
            const NoEncontrado('No encontramos lo que buscas.'),
            StackTrace.empty,
          ),
        ),
      );

      final error = tester.widget<EstadoError>(find.byType(EstadoError));
      expect(error.causa, CausaError.generico);
      expect(error.mensaje, 'No encontramos lo que buscas.');
    });

    testWidgets('sin conexion pinta EstadoError con su propia causa', (
      tester,
    ) async {
      await tester.pumpWidget(
        vista(AsyncValue.error(const SinConexion(), StackTrace.empty)),
      );

      final error = tester.widget<EstadoError>(find.byType(EstadoError));
      expect(error.causa, CausaError.sinConexion);
      // Sin conexion es del telefono, no del servidor: el texto lo pone el
      // sistema de diseno, que ademas dice que hacer.
      expect(error.mensaje, isNull);
      expect(
        find.text('Revisa tu internet e intenta de nuevo.'),
        findsOneWidget,
      );
    });
  });

  group('el error llega tipado pase lo que pase', () {
    testWidgets('un error sin tipar no rompe la vista ni filtra detalle', (
      tester,
    ) async {
      await tester.pumpWidget(
        vista(
          AsyncValue.error(
            ArgumentError('contrasenaNueva: must not be null'),
            StackTrace.empty,
          ),
        ),
      );

      final error = tester.widget<EstadoError>(find.byType(EstadoError));
      expect(error.causa, CausaError.generico);
      expect(error.mensaje, isNot(contains('contrasenaNueva')));
      expect(tester.takeException(), isNull);
    });
  });

  group('reintentar', () {
    testWidgets('el boton llama al callback del modulo', (tester) async {
      var veces = 0;
      await tester.pumpWidget(
        vista(
          AsyncValue.error(const SinConexion(), StackTrace.empty),
          alReintentar: () => veces++,
        ),
      );

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(veces, 1);
    });
  });

  group('recargar no parpadea', () {
    testWidgets('mientras recarga con un dato previo sigue viendose el dato', (
      tester,
    ) async {
      // Se provoca una recarga de verdad con un proveedor, en vez de fabricar
      // el `AsyncValue` a mano: `copyWithPrevious` es interno de Riverpod y el
      // analizador lo rechaza, con razon.
      var respuesta = Completer<List<String>>()..complete(['uno']);
      final provider = FutureProvider<List<String>>((ref) => respuesta.future);

      late WidgetRef refDeLaVista;
      await tester.pumpWidget(
        ProviderScope(
          child: conTemaPista(
            Consumer(
              builder: (context, ref, _) {
                refDeLaVista = ref;
                return VistaAsincrona<List<String>>(
                  estado: ref.watch(provider),
                  cargando: (_) => const Esqueleto(alto: 72),
                  datos: (_, lista) => Text(lista.join(', ')),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('uno'), findsOneWidget);

      // La recarga empieza y todavia no termina: ese es el instante que
      // importa. Si pintaramos el esqueleto, la lista desapareceria en cada
      // refresco y volveria. Es el parpadeo que la guia de estilos prohibe.
      respuesta = Completer<List<String>>();
      refDeLaVista.invalidate(provider);
      await tester.pump();

      expect(find.text('uno'), findsOneWidget);
      expect(find.byType(Esqueleto), findsNothing);

      respuesta.complete(['uno', 'dos']);
      await tester.pumpAndSettle();
      expect(find.text('uno, dos'), findsOneWidget);
    });
  });

  group('cuando esta vacio lo decide el modulo si quiere', () {
    testWidgets('un predicado propio manda sobre el automatico', (
      tester,
    ) async {
      await tester.pumpWidget(
        vista(
          const AsyncValue.data(['marcador']),
          estaVacio: (lista) => lista.single == 'marcador',
          vacio: vacioDePrueba,
        ),
      );
      expect(find.byType(EstadoVacio), findsOneWidget);
    });

    testWidgets('sin estado vacio definido, una lista vacia pinta datos', (
      tester,
    ) async {
      // El nucleo no inventa un estado que el modulo no pidio: hay pantallas
      // donde la lista vacia es un error de datos, no un estado normal.
      await tester.pumpWidget(vista(const AsyncValue.data([])));
      expect(find.byType(EstadoVacio), findsNothing);
      expect(find.text(''), findsOneWidget);
    });
  });
}
