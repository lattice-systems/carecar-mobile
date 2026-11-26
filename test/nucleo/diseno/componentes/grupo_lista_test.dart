import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Widget _grupo({VoidCallback? alToque}) => GrupoLista(
  encabezado: 'Cuenta',
  pie: 'Tus datos se guardan en este telefono.',
  filas: [
    FilaGrupo(
      titulo: 'Perfil',
      subtitulo: 'Nombre y telefono',
      icono: Icons.person,
      alToque: alToque,
    ),
    FilaGrupo(
      titulo: 'Seguridad',
      icono: Icons.lock,
      colorIcono: Colors.green,
      alToque: alToque,
    ),
    const FilaGrupo(titulo: 'Version', fin: Text('2.0')),
  ],
);

void main() {
  testWidgets('muestra encabezado, filas y pie', (tester) async {
    await tester.pumpWidget(conTemaPista(_grupo()));
    expect(find.text('Cuenta'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Nombre y telefono'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Tus datos se guardan en este telefono.'), findsOneWidget);
  });

  testWidgets('separa las filas con lineas finas: una menos que filas', (
    tester,
  ) async {
    await tester.pumpWidget(conTemaPista(_grupo()));
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('solo las filas con alToque muestran chevron y responden', (
    tester,
  ) async {
    var toques = 0;
    await tester.pumpWidget(conTemaPista(_grupo(alToque: () => toques++)));
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    await tester.tap(find.text('Perfil'));
    expect(toques, 1);
  });

  testWidgets('cada fila es un solo nodo para el lector de pantalla', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(conTemaPista(_grupo(alToque: () {})));
    expect(find.bySemanticsLabel('Perfil. Nombre y telefono'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('el lector oye el final de la fila cuando trae su etiqueta', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(
      conTemaPista(
        const GrupoLista(
          filas: [
            FilaGrupo(
              titulo: 'Servicio',
              subtitulo: '30 ago 2026',
              fin: Text('+230'),
              etiquetaFin: 'Ganaste 230 puntos',
            ),
            FilaGrupo(titulo: 'Version', fin: Text('2.0')),
          ],
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Servicio. 30 ago 2026. Ganaste 230 puntos'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Version'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('el encabezado se anuncia como encabezado', (tester) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(conTemaPista(_grupo()));
    final nodo = tester.getSemantics(find.text('Cuenta'));
    expect(nodo.flagsCollection.isHeader, isTrue);
    semantica.dispose();
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        conTemaPista(
          SingleChildScrollView(child: _grupo(alToque: () {})),
          escenario: escenario,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
