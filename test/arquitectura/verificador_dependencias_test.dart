import 'package:flutter_test/flutter_test.dart';

import 'verificador_dependencias.dart';

void main() {
  List<ViolacionDeDependencia> revisar(String archivo, String fuente) =>
      verificarFuente(archivo, fuente);

  group('modulo contra modulo', () {
    test('importar el contrato publico de otro modulo es valido', () {
      expect(
        revisar(
          'lib/modulos/citas/presentacion/pantalla.dart',
          "import '../../vehiculos/vehiculos.dart';",
        ),
        isEmpty,
      );
    });

    test('importar datos o presentacion de otro modulo falla (relativo)', () {
      final v = revisar(
        'lib/modulos/citas/presentacion/pantalla.dart',
        "import 'package:flutter/material.dart';\n"
            "import '../../vehiculos/datos/repositorio.dart';\n",
      );
      expect(v, hasLength(1));
      expect(v.single.archivo, 'lib/modulos/citas/presentacion/pantalla.dart');
      expect(v.single.linea, 2);
      expect(v.single.regla, ReglaDeDependencia.internosDeOtroModulo);
      expect(v.single.mensaje, contains('modulos/vehiculos/vehiculos.dart'));
    });

    test('importar internals de otro modulo falla (package)', () {
      final v = revisar(
        'lib/modulos/citas/citas.dart',
        "import 'package:carecar_mobile/modulos/vehiculos/presentacion/x.dart';",
      );
      expect(v.single.regla, ReglaDeDependencia.internosDeOtroModulo);
    });

    test('export, part y importaciones condicionales tambien cuentan', () {
      final v = revisar(
        'lib/modulos/citas/a.dart',
        "export '../vehiculos/dominio/modelo.dart';\n"
            "part '../vehiculos/datos/parte.dart';\n"
            "import 'a_io.dart'\n"
            "    if (dart.library.html) '../vehiculos/datos/web.dart';\n",
      );
      expect(v.map((e) => e.linea), [1, 2, 3]);
    });

    test('un modulo puede importar sus propios internals', () {
      expect(
        revisar(
          'lib/modulos/citas/presentacion/pantalla.dart',
          "import '../dominio/cita.dart';\n"
              "import 'package:carecar_mobile/modulos/citas/datos/repo.dart';",
        ),
        isEmpty,
      );
    });

    test('el modulo llamado widgets no se confunde con lib/widgets', () {
      expect(
        revisar(
          'lib/modulos/citas/a.dart',
          "import '../widgets/widgets.dart';",
        ),
        isEmpty,
      );
    });

    test('lo comentado no cuenta', () {
      expect(
        revisar(
          'lib/modulos/citas/a.dart',
          "// import '../vehiculos/datos/x.dart';\n"
              "/// import '../vehiculos/datos/y.dart';\n",
        ),
        isEmpty,
      );
    });
  });

  group('nucleo no conoce modulos', () {
    test('nucleo importando un modulo falla', () {
      final v = revisar(
        'lib/nucleo/api/algo.dart',
        "import '../../modulos/citas/citas.dart';",
      );
      expect(v.single.regla, ReglaDeDependencia.nucleoConoceModulos);
    });

    test('registro_de_rutas puede importar solo contratos publicos', () {
      const archivo = 'lib/nucleo/navegacion/registro_de_rutas.dart';
      expect(
        revisar(archivo, "import '../../modulos/citas/citas.dart';"),
        isEmpty,
      );
      final v = revisar(
        archivo,
        "import '../../modulos/citas/presentacion/rutas_citas.dart';",
      );
      expect(v.single.regla, ReglaDeDependencia.internosDeOtroModulo);
    });
  });

  group('v2 no depende de v1', () {
    test('modulos y nucleo no importan pantallas, widgets ni tema de v1', () {
      for (final destino in [
        'pantallas/a.dart',
        'widgets/a.dart',
        'tema/a.dart',
      ]) {
        for (final origen in [
          'lib/modulos/citas/a.dart',
          'lib/nucleo/diseno/a.dart',
        ]) {
          final profundidad = '../' * (origen.split('/').length - 2);
          final v = revisar(origen, "import '$profundidad$destino';");
          expect(v, hasLength(1), reason: '$origen -> $destino');
          expect(v.single.regla, ReglaDeDependencia.v2ConoceV1);
        }
      }
    });

    test('nucleo puede envolver lib/api y lib/sesion (puente documentado)', () {
      expect(
        revisar(
          'lib/nucleo/api/api_cliente.dart',
          "import '../../api/cliente_api.dart';",
        ),
        isEmpty,
      );
    });
  });

  test('las excepciones de v1 son explicitas y solo exentan a su archivo', () {
    expect(
      revisar(
        'lib/nucleo/navegacion/rutas_del_nucleo.dart',
        "import '../../pantallas/pantalla_login.dart';",
      ),
      isEmpty,
    );
    expect(
      revisar(
        'lib/nucleo/navegacion/otra.dart',
        "import '../../pantallas/pantalla_login.dart';",
      ),
      hasLength(1),
    );
    expect(excepcionesV1.keys, everyElement(startsWith('lib/nucleo/')));
  });

  group('fuera de modulos', () {
    test('codigo v1 solo puede usar el contrato publico de un modulo', () {
      final v = revisar(
        'lib/pantallas/inicio.dart',
        "import '../modulos/citas/datos/repo.dart';",
      );
      expect(v.single.regla, ReglaDeDependencia.internosDeOtroModulo);
      expect(
        revisar(
          'lib/pantallas/inicio.dart',
          "import '../modulos/citas/citas.dart';",
        ),
        isEmpty,
      );
    });
  });

  test('el mensaje dice archivo, linea, importacion y regla', () {
    final v = revisar(
      'lib/modulos/citas/a.dart',
      "import '../vehiculos/datos/x.dart';",
    );
    final texto = v.single.toString();
    expect(texto, contains('lib/modulos/citas/a.dart:1'));
    expect(texto, contains('../vehiculos/datos/x.dart'));
    expect(texto, contains('R1'));
  });
}
