import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/ejemplo/dominio/repositorio_avisos.dart';
import 'package:carecar_mobile/modulos/ejemplo/ejemplo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioAvisos {
  _Repo(this.alPedir);
  final Future<List<Aviso>> Function() alPedir;
  @override
  Future<List<Aviso>> avisos() => alPedir();
}

Widget _app(RepositorioAvisos repo) => ProviderScope(
  overrides: [repositorioAvisosProvider.overrideWithValue(repo)],
  child: conTemaPista(const PantallaAvisos()),
);

void main() {
  testWidgets('muestra los avisos del repositorio, urgentes primero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _Repo(
          () async => const [
            Aviso(id: 1, titulo: 'Normal', detalle: 'd1'),
            Aviso(id: 2, titulo: 'Urgente', detalle: 'd2', urgente: true),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Urgente'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Urgente')).dy,
      lessThan(tester.getTopLeft(find.text('Normal')).dy),
    );
  });

  testWidgets('sin avisos muestra el estado vacio', (tester) async {
    await tester.pumpWidget(_app(_Repo(() async => const [])));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
  });

  testWidgets('con error muestra reintento y se recupera', (tester) async {
    var intentos = 0;
    await tester.pumpWidget(
      _app(
        _Repo(() async {
          if (intentos++ == 0) throw const SinConexion();
          return const [Aviso(id: 1, titulo: 'Ya llego', detalle: '')];
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Ya llego'), findsOneWidget);
  });
}
