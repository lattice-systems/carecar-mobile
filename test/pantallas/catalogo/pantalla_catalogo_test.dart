import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/pantallas/catalogo/pantalla_catalogo.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../ayudas/api_falsa.dart';

void main() {
  test('ModeloCatalogo lee los campos opcionales', () {
    final m = ModeloCatalogo.fromJson({
      'modelo': 'Versa',
      'marca': 'Nissan',
      'anio': 2025,
      'precioDesde': 350000,
      'imagenUrl': null,
    });
    expect(m.marca, 'Nissan');
    expect(m.precioDesde, 350000);
    expect(m.imagenUrl, isNull);
    expect(textoPrecio(m), 'Desde \$350,000');
  });

  testWidgets(
    'catalogo usa la foto incluida y un marcador si el modelo no tiene',
    (tester) async {
      final api = ApiFalsa()
        ..modelosCatalogo = const [
          ModeloCatalogo(
            modelo: 'Versa',
            marca: 'Nissan',
            anio: 2025,
            version: 'Advance',
            precioDesde: 350000,
            descripcion: 'Sedan compacto',
          ),
          // Sin foto incluida ni URL: cae al marcador.
          ModeloCatalogo(modelo: 'Modelo Raro', marca: 'Nissan', anio: 2025),
        ];
      await tester.pumpWidget(
        ShadApp.custom(
          theme: TemaCareCar.shad,
          appBuilder: (context) => MaterialApp(
            theme: TemaCareCar.claro,
            builder: (context, child) => ShadAppBuilder(child: child!),
            home: PantallaCatalogo(api: api, alCerrarSesion: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nissan · Versa · 2025'), findsOneWidget);
      expect(find.text('Desde \$350,000'), findsOneWidget);
      // Versa trae su foto; solo el modelo sin foto muestra el marcador.
      expect(find.byKey(ImagenModelo.marcador), findsOneWidget);
    },
  );
}
