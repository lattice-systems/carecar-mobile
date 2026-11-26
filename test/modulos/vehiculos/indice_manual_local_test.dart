import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/indice_manual_local.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/indice_de_manual.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Vehiculo versa() => const Vehiculo(
    id: 1,
    vin: 'VIN',
    modelo: 'Versa',
    anio: 2024,
    marca: 'Nissan',
  );

  test('desdeJson arma las páginas', () {
    final indice = IndiceDeManual.desdeJson({
      'manual': 'X',
      'paginas': [
        {'p': 3, 't': 'hola'},
      ],
    });
    expect(indice.paginas.single.pagina, 3);
    expect(indice.paginas.single.texto, 'hola');
  });

  test(
    'carga el índice real empaquetado del Versa 2024 y busca en él',
    () async {
      final indice = await cargarIndiceDeManual(versa());
      expect(indice, isNotNull);
      expect(indice!.paginas, isNotEmpty);
      // "nissan" sale seguro en el manual; debe devolver al menos una página.
      expect(indice.buscar('nissan'), isNotEmpty);
    },
  );

  test('un vehículo sin manual empaquetado devuelve null', () async {
    final indice = await cargarIndiceDeManual(
      const Vehiculo(
        id: 2,
        vin: 'V',
        modelo: 'Mustang',
        anio: 1999,
        marca: 'Ford',
      ),
    );
    expect(indice, isNull);
  });
}
