import 'dart:typed_data';

import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/manuales/servicio_manuales.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/indice_de_manual.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_manual.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

final _bytes = Uint8List.fromList([1, 2, 3]);

class _Servicio implements ServicioManuales {
  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async => DocumentoManual(
    titulo: 'Nissan Versa 2024',
    identificador: 'agencia:1',
    bytes: _bytes,
  );
}

Widget _visor(
  BuildContext context,
  Uint8List bytes,
  ValueChanged<int> alCargar,
  ValueChanged<int> alCambiarPagina,
  int paginaInicial,
) => _VisorFalso(pagina: paginaInicial, alCargar: alCargar);

class _VisorFalso extends StatefulWidget {
  const _VisorFalso({required this.pagina, required this.alCargar});
  final int pagina;
  final ValueChanged<int> alCargar;
  @override
  State<_VisorFalso> createState() => _VisorFalsoState();
}

class _VisorFalsoState extends State<_VisorFalso> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.alCargar(5));
  }

  @override
  Widget build(BuildContext context) =>
      Text('Abierto en página ${widget.pagina}');
}

const _indice = IndiceDeManual(
  manual: 'Nissan Versa 2024',
  paginas: [
    PaginaDeManual(2, 'Cómo revisar los frenos del vehículo'),
    PaginaDeManual(4, 'La presión correcta de las llantas'),
  ],
);

Future<void> _montar(WidgetTester tester, {IndiceDeManual? indice}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        servicioManualesProvider.overrideWithValue(_Servicio()),
        indiceDeManualProvider(1).overrideWith((ref) async => indice),
      ],
      child: conTemaPista(
        const PantallaManual(vehiculoId: 1, fabricaVisor: _visor),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin índice no ofrece buscar', (tester) async {
    await _montar(tester, indice: null);
    expect(find.byIcon(Icons.search_outlined), findsNothing);
  });

  testWidgets('con índice, buscar abre el campo', (tester) async {
    await _montar(tester, indice: _indice);
    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('escribir muestra la página que coincide con su fragmento', (
    tester,
  ) async {
    await _montar(tester, indice: _indice);
    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'llantas');
    await tester.pumpAndSettle();
    expect(find.text('Página 4'), findsOneWidget);
    expect(
      find.textContaining('presión correcta de las llantas'),
      findsOneWidget,
    );
  });

  testWidgets('tocar un resultado abre esa página y cierra la búsqueda', (
    tester,
  ) async {
    await _montar(tester, indice: _indice);
    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'frenos');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Página 2'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Abierto en página 2'), findsOneWidget);
  });

  testWidgets('una búsqueda sin coincidencias lo dice', (tester) async {
    await _montar(tester, indice: _indice);
    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'turbo');
    await tester.pumpAndSettle();
    expect(find.textContaining('No encontramos'), findsOneWidget);
  });
}
