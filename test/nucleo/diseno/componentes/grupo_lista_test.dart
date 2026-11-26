import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../ayudas/tema_pista.dart';

Widget _grupo({VoidCallback? alToque}) => GrupoLista(
  encabezado: 'Cuenta',
  pie: 'Tus datos se guardan en este telefono.',
  filas: [
    FilaGrupo(
      titulo: 'Perfil',
      subtitulo: 'Nombre y telefono',
      icono: LucideIcons300.user,
      alToque: alToque,
    ),
    FilaGrupo(
      titulo: 'Seguridad',
      icono: LucideIcons300.lock,
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
    expect(find.byIcon(LucideIcons300.chevronRight), findsNWidgets(2));
    await tester.tap(find.text('Perfil'));
    expect(toques, 1);
  });

  testWidgets('una fila con llave se encuentra por ella y responde al toque', (
    tester,
  ) async {
    var toques = 0;
    const llave = Key('fila-cuenta');
    await tester.pumpWidget(
      conTemaPista(
        GrupoLista(
          filas: [
            FilaGrupo(titulo: 'Cuenta', llave: llave, alToque: () => toques++),
            const FilaGrupo(titulo: 'Version'),
          ],
        ),
      ),
    );

    expect(find.byKey(llave), findsOneWidget);
    await tester.tap(find.byKey(llave));
    expect(toques, 1);
  });

  testWidgets('conChevron: false quita la flecha de una fila tocable', (
    tester,
  ) async {
    // Una fila con interruptor responde al toque, pero la flecha dice «hay
    // otra pantalla» y ahí no la hay.
    var toques = 0;
    await tester.pumpWidget(
      conTemaPista(
        GrupoLista(
          filas: [
            FilaGrupo(
              titulo: 'Recordatorios',
              fin: const Icon(Icons.toggle_on),
              conChevron: false,
              alToque: () => toques++,
            ),
            FilaGrupo(titulo: 'Perfil', alToque: () {}),
          ],
        ),
      ),
    );

    // Solo la fila que lleva a otra pantalla muestra la flecha.
    expect(find.byIcon(LucideIcons300.chevronRight), findsOneWidget);
    await tester.tap(find.text('Recordatorios'));
    expect(toques, 1);
  });

  testWidgets('el texto usa el ancho que sobra y el fin toma solo el suyo', (
    tester,
  ) async {
    // Antes el espacio libre se repartía a partes iguales entre el texto y el
    // `fin`: con un interruptor, «Recordatorios de citas» se partía en dos
    // líneas aunque cabía de sobra. En pruebas la letra es Ahem (1 em por
    // carácter), así que se usa un título corto que sí cabe.
    Future<double> alturaDelTitulo({required bool conFin}) async {
      await tester.pumpWidget(
        conTemaPista(
          GrupoLista(
            filas: [
              FilaGrupo(
                titulo: 'Recordatorio',
                icono: Icons.notifications,
                fin: conFin ? const SizedBox(width: 52, height: 32) : null,
              ),
            ],
          ),
        ),
      );
      return tester.getSize(find.text('Recordatorio')).height;
    }

    final sinFin = await alturaDelTitulo(conFin: false);
    final conFin = await alturaDelTitulo(conFin: true);

    expect(conFin, sinFin, reason: 'el título no debe partirse por el fin');
  });

  testWidgets('un fin muy ancho no desborda la fila: se limita a la mitad', (
    tester,
  ) async {
    await tester.pumpWidget(
      conTemaPista(
        GrupoLista(
          filas: [
            FilaGrupo(
              titulo: 'Servicio',
              fin: Text(
                'Un valor muy largo que no cabe en una sola línea ' * 3,
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Servicio'), findsOneWidget);
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
