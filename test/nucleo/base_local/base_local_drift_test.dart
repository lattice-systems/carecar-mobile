import 'dart:io';

import 'package:carecar_mobile/nucleo/base_local/base_local.dart';
import 'package:carecar_mobile/nucleo/base_local/base_local_drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../ayudas/almacenamiento_en_memoria.dart';
import 'contrato_base_local.dart';

/// V2-M21.01: base local cifrada (drift + SQLCipher, ADR 0005).
void main() {
  late Directory carpeta;
  late File archivo;
  late AlmacenamientoEnMemoria almacen;

  setUp(() {
    carpeta = Directory.systemTemp.createTempSync('base_local_');
    archivo = File('${carpeta.path}/carecar.db');
    almacen = AlmacenamientoEnMemoria();
  });

  tearDown(() {
    if (carpeta.existsSync()) carpeta.deleteSync(recursive: true);
  });

  BaseLocalDrift abrir({DateTime Function()? reloj}) =>
      BaseLocalDrift(archivo: archivo, almacenamiento: almacen, reloj: reloj);

  /// El archivo y los que SQLite deja al lado mientras escribe.
  List<File> archivosDeLaBase() => [
    for (final sufijo in ['', '-wal', '-shm', '-journal'])
      File('${archivo.path}$sufijo'),
  ];

  String llaveGuardada() => almacen.valores[BaseLocalDrift.claveEnAlmacen]!;

  /// Abre el archivo a mano, con [llave], para mirar lo que de verdad quedó.
  sqlite.Database abrirCrudo(String llave) {
    final raw = sqlite.sqlite3.open(archivo.path)
      ..execute("pragma key = \"x'$llave'\"");
    addTearDown(raw.close);
    return raw;
  }

  group('contrato', () {
    ejecutarContratoBaseLocal(
      (reloj) => BaseLocalDrift(
        archivo: File(
          '${Directory.systemTemp.createTempSync('contrato_').path}/c.db',
        ),
        almacenamiento: AlmacenamientoEnMemoria(),
        reloj: reloj,
      ),
    );
  });

  group('cifrado', () {
    test('el archivo no es SQLite legible ni deja ver el contenido', () async {
      final base = abrir();
      await base.guardar(
        coleccion: 'vehiculos',
        clave: 'v1',
        contenido: '{"vin":"VIN-SECRETO","placas":"ABC-1"}',
      );
      await base.cerrar();

      final texto = String.fromCharCodes(archivo.readAsBytesSync());

      expect(texto, isNot(startsWith('SQLite format 3')));
      expect(texto, isNot(contains('VIN-SECRETO')));
      expect(texto, isNot(contains('ABC-1')));
      expect(texto, isNot(contains('vehiculos')));
    });

    test('sin la llave, o con otra, SQLite no abre el archivo', () async {
      final base = abrir();
      await base.guardar(coleccion: 'a', clave: 'b', contenido: 'c');
      await base.cerrar();

      final sinLlave = sqlite.sqlite3.open(archivo.path);
      addTearDown(sinLlave.close);
      expect(
        () => sinLlave.select('select count(*) from sqlite_master'),
        throwsA(isA<sqlite.SqliteException>()),
      );

      final otra = abrirCrudo('ab' * 32);
      expect(
        () => otra.select('select count(*) from sqlite_master'),
        throwsA(isA<sqlite.SqliteException>()),
      );
    });

    test(
      'la llave está en el almacenamiento seguro y abre el archivo',
      () async {
        final base = abrir();
        await base.guardar(coleccion: 'a', clave: 'b', contenido: 'dato');
        await base.cerrar();

        expect(llaveGuardada(), matches(RegExp(r'^[0-9a-f]{64}$')));
        final raw = abrirCrudo(llaveGuardada());
        expect(
          raw
              .select('select contenido from copias_locales')
              .single['contenido'],
          'dato',
        );
      },
    );

    test('la llave se crea una vez y se reutiliza al reabrir', () async {
      final primera = abrir();
      await primera.guardar(coleccion: 'a', clave: 'b', contenido: 'dato');
      await primera.cerrar();
      final llave = llaveGuardada();

      final segunda = abrir();
      final copia = await segunda.leer(coleccion: 'a', clave: 'b');
      await segunda.cerrar();

      expect(copia!.contenido, 'dato');
      expect(llaveGuardada(), llave);
      expect(almacen.escrituras, 1);
    });

    test(
      'si el almacenamiento seguro falla, no se escribe nada en claro',
      () async {
        almacen.falla = StateError('Keystore no responde');
        final base = abrir();

        await expectLater(
          base.guardar(coleccion: 'a', clave: 'b', contenido: 'dato'),
          throwsA(isA<BaseLocalNoDisponible>()),
        );
        expect(archivosDeLaBase().any((f) => f.existsSync()), isFalse);

        // Y cuando el almacenamiento vuelve, la base funciona sin reiniciar.
        almacen.falla = null;
        await base.guardar(coleccion: 'a', clave: 'b', contenido: 'dato');
        expect(
          (await base.leer(coleccion: 'a', clave: 'b'))!.contenido,
          'dato',
        );
        await base.cerrar();
      },
    );
  });

  group('borrar al cerrar sesión', () {
    test('no queda archivo, ni llave, ni un dato del cliente', () async {
      final base = abrir();
      await base.guardar(
        coleccion: 'vehiculos',
        clave: 'v1',
        contenido: 'VIN-SECRETO',
      );
      await base.guardar(coleccion: 'citas', clave: 'c1', contenido: 'cita');

      await base.borrarTodo();

      expect(archivosDeLaBase().any((f) => f.existsSync()), isFalse);
      expect(
        almacen.valores.containsKey(BaseLocalDrift.claveEnAlmacen),
        isFalse,
      );
      await base.cerrar();
    });

    test(
      'lo que se guarde después usa llave nueva y no ve lo anterior',
      () async {
        final base = abrir();
        await base.guardar(
          coleccion: 'a',
          clave: 'b',
          contenido: 'otra cuenta',
        );
        final llaveVieja = llaveGuardada();

        await base.borrarTodo();
        await base.guardar(
          coleccion: 'a',
          clave: 'c',
          contenido: 'esta cuenta',
        );

        expect(llaveGuardada(), isNot(llaveVieja));
        expect(await base.leer(coleccion: 'a', clave: 'b'), isNull);
        expect(await base.listar(coleccion: 'a'), hasLength(1));
        await base.cerrar();
      },
    );

    test('si no hay base abierta ni archivo, borrar no falla', () async {
      await expectLater(abrir().borrarTodo(), completes);
    });

    test('borrar mientras se guarda no deja la base a medias', () async {
      final base = abrir();
      await Future.wait([
        base.guardar(coleccion: 'a', clave: '1', contenido: 'x'),
        base.borrarTodo(),
        base.guardar(coleccion: 'a', clave: '2', contenido: 'y'),
      ]);

      // Las operaciones se atienden en el orden en que llegaron.
      final claves = (await base.listar(coleccion: 'a')).map((c) => c.clave);
      expect(claves, ['2']);
      await base.cerrar();
    });
  });

  group('migraciones', () {
    const llaveDePrueba =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

    /// Crea a mano una base como la dejaba la **versión 1** del esquema (sin
    /// `actualizado_en`), cifrada con la llave que ya está en el almacén.
    void crearBaseVersion1() {
      almacen.valores[BaseLocalDrift.claveEnAlmacen] = llaveDePrueba;
      sqlite.sqlite3.open(archivo.path)
        ..execute("pragma key = \"x'$llaveDePrueba'\"")
        ..execute('''
          create table copias_locales (
            coleccion text not null,
            clave text not null,
            contenido text not null,
            primary key (coleccion, clave)
          )''')
        ..execute(
          "insert into copias_locales values "
          "('vehiculos', 'v1', 'del esquema 1')",
        )
        ..execute('pragma user_version = 1')
        ..close();
    }

    test('la versión actual del esquema es la 2', () {
      expect(BaseLocalDrift.versionDelEsquema, 2);
    });

    test('una base de la versión 1 se migra y conserva sus datos', () async {
      crearBaseVersion1();

      final base = abrir(reloj: () => DateTime.utc(2026, 11, 27));
      final vieja = await base.leer(coleccion: 'vehiculos', clave: 'v1');

      expect(vieja, isNotNull);
      expect(vieja!.contenido, 'del esquema 1');
      // La hora de lo guardado antes de que existiera la columna no se sabe:
      // queda en el origen, no se inventa.
      expect(vieja.actualizadoEn, DateTime.utc(1970));

      await base.guardar(coleccion: 'vehiculos', clave: 'v2', contenido: 'n');
      expect(
        (await base.leer(coleccion: 'vehiculos', clave: 'v2'))!.actualizadoEn,
        DateTime.utc(2026, 11, 27),
      );
      await base.cerrar();

      final raw = abrirCrudo(llaveDePrueba);
      expect(raw.select('pragma user_version').single.values.single, 2);
    });

    test('una base de una versión futura se descarta y se recrea', () async {
      crearBaseVersion1();
      sqlite.sqlite3.open(archivo.path)
        ..execute("pragma key = \"x'$llaveDePrueba'\"")
        ..execute('pragma user_version = 99')
        ..close();

      final base = abrir();

      expect(await base.listar(coleccion: 'vehiculos'), isEmpty);
      await base.guardar(coleccion: 'vehiculos', clave: 'x', contenido: 'ok');
      expect(await base.listar(coleccion: 'vehiculos'), hasLength(1));
      await base.cerrar();
    });

    test('con el archivo pero sin la llave, se descarta y se recrea', () async {
      final primera = abrir();
      await primera.guardar(coleccion: 'a', clave: 'b', contenido: 'dato');
      await primera.cerrar();
      almacen.valores.clear(); // el Keystore se reinició

      final base = abrir();

      expect(await base.leer(coleccion: 'a', clave: 'b'), isNull);
      await base.guardar(coleccion: 'a', clave: 'c', contenido: 'otro');
      expect(await base.listar(coleccion: 'a'), hasLength(1));
      await base.cerrar();
    });
  });
}
