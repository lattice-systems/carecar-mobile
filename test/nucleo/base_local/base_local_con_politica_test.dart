import 'dart:io';

import 'package:carecar_mobile/nucleo/base_local/base_local_con_politica.dart';
import 'package:carecar_mobile/nucleo/base_local/base_local_drift.dart';
import 'package:carecar_mobile/nucleo/base_local/base_local_en_memoria.dart';
import 'package:carecar_mobile/nucleo/seguridad/detector_integridad.dart';
import 'package:carecar_mobile/nucleo/seguridad/politica_datos_locales.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/almacenamiento_en_memoria.dart';
import '../../ayudas/api_falsa.dart';

void main() {
  group('BaseLocalConPolitica (V2-M22.05 sobre V2-M21.01)', () {
    late BaseLocalEnMemoria debajo;
    late PoliticaDatosLocales politica;
    late BaseLocalConPolitica base;

    setUp(() {
      debajo = BaseLocalEnMemoria();
      politica = PoliticaDatosLocales(EstadoIntegridad.integro);
      base = BaseLocalConPolitica(debajo, politica);
    });

    tearDown(() => base.dispose());

    test('con el equipo íntegro guarda y lee normal', () async {
      await base.guardar(coleccion: 'a', clave: 'b', contenido: 'dato');

      expect((await base.leer(coleccion: 'a', clave: 'b'))!.contenido, 'dato');
    });

    test('con el equipo comprometido no guarda ni lee nada', () async {
      await debajo.guardar(coleccion: 'a', clave: 'b', contenido: 'previo');
      politica.actualizar(EstadoIntegridad.comprometido);

      await base.guardar(coleccion: 'a', clave: 'c', contenido: 'nuevo');

      expect(await base.leer(coleccion: 'a', clave: 'c'), isNull);
      expect(await base.listar(coleccion: 'a'), isEmpty);
      expect(await debajo.listar(coleccion: 'a'), isEmpty);
    });

    test(
      'al detectar que el equipo está comprometido borra lo que había',
      () async {
        await base.guardar(coleccion: 'a', clave: 'b', contenido: 'dato');

        politica.actualizar(EstadoIntegridad.comprometido);
        await Future<void>.delayed(Duration.zero);

        expect(debajo.borrados, 1);
        expect(await debajo.listar(coleccion: 'a'), isEmpty);
      },
    );

    test('si arranca ya comprometido, borra al construirse', () async {
      final enBase = BaseLocalEnMemoria();
      final conRoot = BaseLocalConPolitica(
        enBase,
        PoliticaDatosLocales(EstadoIntegridad.comprometido),
      );
      addTearDown(conRoot.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(enBase.borrados, 1);
    });

    test('borrarTodo y cerrar llegan a la base de abajo', () async {
      await base.borrarTodo();

      expect(debajo.borrados, 1);
    });
  });

  group('cerrar sesión borra la base local (V2-M21.01)', () {
    late Directory carpeta;
    late File archivo;
    late AlmacenamientoEnMemoria llaves;
    late BaseLocalDrift base;
    late AlmacenEnMemoria almacen;
    late ControladorSesion sesion;

    setUp(() {
      carpeta = Directory.systemTemp.createTempSync('cierre_');
      archivo = File('${carpeta.path}/carecar.db');
      llaves = AlmacenamientoEnMemoria();
      base = BaseLocalDrift(archivo: archivo, almacenamiento: llaves);
      almacen = AlmacenEnMemoria();
      sesion = ControladorSesion(ApiFalsa(), almacen);
      sesion.registrarAlTerminarSesion(base.borrarTodo);
    });

    tearDown(() async {
      await base.cerrar();
      if (carpeta.existsSync()) carpeta.deleteSync(recursive: true);
    });

    Future<void> llenarBase() async {
      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'x',
      );
      await base.guardar(
        coleccion: 'vehiculos',
        clave: 'v1',
        contenido: '{"vin":"VIN-SECRETO"}',
      );
      await base.guardar(coleccion: 'citas', clave: 'c1', contenido: 'cita');
    }

    void verificarSinRastro() {
      expect(archivo.existsSync(), isFalse, reason: 'no queda el archivo');
      expect(
        llaves.valores.containsKey(BaseLocalDrift.claveEnAlmacen),
        isFalse,
        reason: 'no queda la llave',
      );
      expect(carpeta.listSync(), isEmpty, reason: 'ni -wal ni -journal');
    }

    test('al cerrar sesión no queda ni un dato del cliente', () async {
      await llenarBase();
      expect(archivo.existsSync(), isTrue);

      await sesion.cerrarSesion();

      verificarSinRastro();
      expect(await base.listar(coleccion: 'vehiculos'), isEmpty);
      expect(await base.listar(coleccion: 'citas'), isEmpty);
    });

    test('al desactivarse la cuenta tampoco queda nada', () async {
      await llenarBase();

      await sesion.terminarPorCuentaDesactivada();

      verificarSinRastro();
    });
  });
}
