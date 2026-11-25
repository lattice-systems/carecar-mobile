import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'verificador_registro.dart';

/// V2-M22.07: nada escribe en el registro sin pasar por `Registro`, y lo que
/// se le pasa no interpola un correo, telefono, VIN ni token.
///
/// Los dos primeros grupos prueban al propio verificador con codigo de
/// ejemplo (una guarda que nunca falla no protege nada); el ultimo lo corre
/// sobre `lib/`. Detalle y limites: `docs/seguridad/registro-sin-datos-personales.md`.
void main() {
  group('escritura directa en la consola', () {
    test('rechaza debugPrint, print, developer.log y stdout', () {
      const codigo = '''
void f() {
  debugPrint('hola');
  print('hola');
  developer.log('hola');
  stdout.writeln('hola');
  stderr.write('hola');
  debugPrintStack();
}
''';
      final hallazgos = revisarCodigoDeRegistro('lib/modulos/x/a.dart', codigo);
      expect(hallazgos.map((h) => h.linea), [2, 3, 4, 5, 6, 7]);
      expect(hallazgos.first.mensaje, contains('Registro.depurar'));
    });

    test('rechaza log() cuando el archivo importa dart:developer', () {
      const codigo = '''
import 'dart:developer';

void f() => log('hola');
''';
      final hallazgos = revisarCodigoDeRegistro('lib/modulos/x/a.dart', codigo);
      expect(hallazgos.map((h) => h.linea), [3]);
    });

    test('no confunde otros nombres, metodos ni comentarios', () {
      const codigo = '''
// debugPrint('esto es un comentario');
/// print('y esto tambien');
void f() {
  imprimir('hola');
  documento.print('hola');
  final reprint = 3;
  unprint(reprint);
  log(2);
}
''';
      expect(revisarCodigoDeRegistro('lib/modulos/x/a.dart', codigo), isEmpty);
    });

    test('la carpeta del registro y el codigo generado quedan fuera', () {
      const codigo = "void f() => debugPrint('ok');";
      expect(
        revisarCodigoDeRegistro('lib/nucleo/registro/registro.dart', codigo),
        isEmpty,
      );
      expect(
        revisarCodigoDeRegistro('lib/l10n/app_localizations.dart', codigo),
        isEmpty,
      );
    });
  });

  group('datos personales en lo que se registra', () {
    test('rechaza interpolar un correo, telefono, VIN o token', () {
      const codigo = r'''
void f() {
  Registro.depurar('Fallo para ${usuario.correo}');
  Registro.depurar('Llamada a $telefono');
  Registro.depurar(
    'Auto ${vehiculo.vin} sin manual',
    error: e,
  );
  Registro.depurar('Sesion $accessToken');
  Registro.depurar('Clave $nuevaContrasena');
}
''';
      final hallazgos = revisarCodigoDeRegistro('lib/modulos/x/a.dart', codigo);
      expect(hallazgos.map((h) => h.linea), [2, 3, 4, 8, 9]);
      expect(hallazgos.first.mensaje, contains('correo'));
    });

    test('deja pasar lo que no es un dato personal', () {
      const codigo = r'''
void f() {
  Registro.depurar('Fallo: $e');
  Registro.depurar('Cita $citaId del vehiculo $vehiculoId', error: error);
  Registro.depurar('Sin vinculo ni vineta: $vinculo');
  Registro.depurar('Cuenta $cuentaId');
}
''';
      expect(revisarCodigoDeRegistro('lib/modulos/x/a.dart', codigo), isEmpty);
    });
  });

  test('el arbol real de lib/ registra solo con Registro y sin datos', () {
    final hallazgos = revisarArbolDeRegistro(Directory('lib'));
    expect(
      hallazgos,
      isEmpty,
      reason:
          'Registro con datos personales o sin pasar por Registro '
          '(${hallazgos.length}):\n${hallazgos.join('\n')}\n'
          'Usa Registro.depurar y no incluyas correo, telefono, VIN ni token. '
          'Detalle: docs/seguridad/registro-sin-datos-personales.md',
    );
  });
}
