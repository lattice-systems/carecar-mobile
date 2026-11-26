import 'package:carecar_mobile/nucleo/dispositivo/nombre_del_dispositivo.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M01.09 · el nombre que la app manda al entrar.
///
/// Es lo unico que despues le permite al cliente reconocer sus sesiones en la
/// lista, asi que **fallar aqui no puede impedir entrar**: sin nombre la sesion
/// se abre igual y la lista muestra un texto generico.
void main() {
  group('componer el nombre', () {
    test('equipo y sistema, separados', () {
      expect(
        componerNombreDelDispositivo(equipo: 'Pixel 7', sistema: 'Android 14'),
        'Pixel 7 · Android 14',
      );
    });

    test('solo el equipo si no se sabe el sistema', () {
      expect(componerNombreDelDispositivo(equipo: 'Pixel 7'), 'Pixel 7');
    });

    test('solo el sistema si no se sabe el equipo', () {
      expect(componerNombreDelDispositivo(sistema: 'iOS 18'), 'iOS 18');
    });

    test('sin nada es nulo, no una cadena vacia', () {
      // Nulo significa «no mandes la llave». Una cadena vacia la mandaria y
      // el cliente acabaria con una sesion llamada «».
      expect(componerNombreDelDispositivo(), isNull);
    });

    test('lo que solo trae espacios cuenta como ausente', () {
      // `Build.MODEL` puede venir vacio en equipos raros o emuladores.
      expect(componerNombreDelDispositivo(equipo: '   '), isNull);
      expect(
        componerNombreDelDispositivo(equipo: '  ', sistema: 'Android 14'),
        'Android 14',
      );
    });

    test('recorta los extremos', () {
      expect(
        componerNombreDelDispositivo(
          equipo: ' Pixel 7 ',
          sistema: ' Android 14 ',
        ),
        'Pixel 7 · Android 14',
      );
    });
  });

  group('la marca y el modelo del equipo', () {
    test('se unen', () {
      expect(equipoDe(marca: 'Google', modelo: 'Pixel 7'), 'Google Pixel 7');
    });

    test('no se repite la marca si el modelo ya la trae', () {
      // Android las da por separado y a veces el modelo ya empieza con el
      // fabricante: «Xiaomi Xiaomi Redmi Note 12» se veria roto.
      expect(
        equipoDe(marca: 'Xiaomi', modelo: 'Xiaomi Redmi Note 12'),
        'Xiaomi Redmi Note 12',
      );
    });

    test('sin importar mayusculas', () {
      expect(
        equipoDe(marca: 'samsung', modelo: 'Samsung SM-A546'),
        'Samsung SM-A546',
      );
    });

    test('sin marca, solo el modelo', () {
      expect(equipoDe(marca: '  ', modelo: 'SM-A546'), 'SM-A546');
    });

    test('sin modelo, solo la marca', () {
      expect(equipoDe(marca: 'Google', modelo: ''), 'Google');
    });
  });

  group('leer el nombre del equipo', () {
    test('lo compone con lo que da la plataforma', () async {
      final nombre = await nombreDelDispositivo(
        leer: () async => (equipo: 'iPhone 14', sistema: 'iOS 18'),
      );

      expect(nombre, 'iPhone 14 · iOS 18');
    });

    test('si la plataforma truena, devuelve nulo y no propaga', () async {
      // Este es el caso que importa: el plugin puede fallar en un equipo
      // raro o con permisos recortados, y entrar a la app no puede depender
      // de saber como se llama el telefono.
      final nombre = await nombreDelDispositivo(
        leer: () async => throw StateError('no hay plataforma'),
      );

      expect(nombre, isNull);
    });

    test('tampoco propaga si tarda y falla distinto', () async {
      final nombre = await nombreDelDispositivo(
        leer: () async {
          await Future<void>.delayed(Duration.zero);
          throw const FormatException('respuesta rara del canal');
        },
      );

      expect(nombre, isNull);
    });
  });
}
