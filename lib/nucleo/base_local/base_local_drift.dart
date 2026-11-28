import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../sesion/almacen_seguro.dart';
import 'base_local.dart';
import 'esquema_local.dart';

/// [BaseLocal] con drift sobre SQLCipher (V2-M21.01, ADR 0005).
///
/// ## Cifrado
///
/// El archivo se cifra entero con SQLCipher (AES-256). La llave son 32 bytes
/// aleatorios que se crean la primera vez y viven en el Keystore o el Keychain
/// (`AlmacenamientoCifrado`, el mismo puerto que la sesión), nunca en
/// preferencias ni en el código. Si el motor cargado no es SQLCipher, la base
/// **no se abre**: se prefiere no tener copia local a guardarla en claro.
///
/// ## Qué pasa cuando algo falla
///
/// Es una copia de lo que tiene el servidor, así que se descarta en vez de
/// arriesgar datos a medias:
///
/// | Caso | Resultado |
/// | --- | --- |
/// | El almacenamiento seguro no da la llave | [BaseLocalNoDisponible]; no se crea archivo. El siguiente intento vuelve a probar |
/// | El archivo no abre con la llave (se perdió o cambió) | Se borra y se recrea vacío |
/// | El archivo es de un esquema más nuevo que la app | Se borra y se recrea vacío |
///
/// ## Orden
///
/// Todas las operaciones se atienden en el orden en que llegan, una a la vez:
/// así [borrarTodo] nunca corre a la mitad de un guardado.
class BaseLocalDrift implements BaseLocal {
  BaseLocalDrift({
    required this.archivo,
    required this.almacenamiento,
    DateTime Function()? reloj,
  }) : _reloj = reloj ?? DateTime.now;

  /// Dónde se guarda la llave. Si cambia, la base existente se descarta.
  static const claveEnAlmacen = 'carecar.base_local.clave.v1';

  /// Versión del esquema de [BaseDeDatosLocal].
  static const versionDelEsquema = 2;

  /// Dónde vive la base cifrada.
  final File archivo;

  /// Dónde se guarda la llave.
  final AlmacenamientoCifrado almacenamiento;
  final DateTime Function() _reloj;

  BaseDeDatosLocal? _base;
  Future<void> _cola = Future<void>.value();

  /// Corre [accion] cuando terminen las anteriores, sin que el error de una
  /// bloquee a las siguientes.
  Future<T> _enCola<T>(Future<T> Function() accion) {
    final resultado = _cola.then((_) => accion());
    _cola = resultado.then<void>((_) {}, onError: (Object _) {});
    return resultado;
  }

  Future<BaseDeDatosLocal> _abierta() async => _base ??= await _abrir();

  Future<BaseDeDatosLocal> _abrir() async {
    final llave = await _cargarOCrearLlave();
    try {
      return await _abrirConLlave(llave);
    } on BaseLocalNoDisponible {
      rethrow;
    } catch (_) {
      // No abre con esta llave o es de un esquema futuro: se recrea. Si ni así
      // abre, `_abrirConLlave` lanza `BaseLocalNoDisponible`.
      await _borrarArchivos();
      try {
        return await _abrirConLlave(llave);
      } catch (e) {
        throw BaseLocalNoDisponible('No se pudo abrir la base local: $e');
      }
    }
  }

  Future<BaseDeDatosLocal> _abrirConLlave(String llave) async {
    await archivo.parent.create(recursive: true);
    final base = BaseDeDatosLocal(
      NativeDatabase.createInBackground(archivo, setup: _prepararMotor(llave)),
    );
    try {
      // Drift abre perezosamente: esto fuerza la apertura y las migraciones
      // ahora, para que un fallo salga aquí y no en el primer guardado.
      await base.customSelect('select 1').get();
      return base;
    } catch (e) {
      await base.close().catchError((Object _) {});
      rethrow;
    }
  }

  /// Aplica la llave y comprueba que el motor sea SQLCipher. Va a otro
  /// aislado, por eso solo captura la [llave] y no `this`.
  static void Function(sqlite.Database) _prepararMotor(String llave) => (db) {
    db.execute("pragma key = \"x'$llave'\"");
    if (db.select('pragma cipher_version').isEmpty) {
      throw const BaseLocalNoDisponible(
        'El motor de SQLite cargado no cifra (no es SQLCipher).',
      );
    }
  };

  Future<String> _cargarOCrearLlave() async {
    try {
      final guardada = await almacenamiento.leer(claveEnAlmacen);
      if (guardada != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(guardada)) {
        return guardada;
      }
      final aleatorio = Random.secure();
      final nueva = [
        for (var i = 0; i < 32; i++)
          aleatorio.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ].join();
      // Una llave nueva deja ilegible lo que hubiera: se parte de cero.
      await _borrarArchivos();
      await almacenamiento.escribir(claveEnAlmacen, nueva);
      return nueva;
    } catch (e) {
      throw BaseLocalNoDisponible('El almacenamiento seguro falló: $e');
    }
  }

  Future<void> _borrarArchivos() async {
    for (final sufijo in ['', '-wal', '-shm', '-journal']) {
      final f = File('${archivo.path}$sufijo');
      if (f.existsSync()) await f.delete();
    }
  }

  @override
  Future<void> guardar({
    required String coleccion,
    required String clave,
    required String contenido,
  }) => _enCola(() async {
    final base = await _abierta();
    await base
        .into(base.copiasLocales)
        .insertOnConflictUpdate(
          CopiasLocalesCompanion.insert(
            coleccion: coleccion,
            clave: clave,
            contenido: contenido,
            actualizadoEn: Value(_reloj().toUtc().millisecondsSinceEpoch),
          ),
        );
  });

  @override
  Future<CopiaLocal?> leer({
    required String coleccion,
    required String clave,
  }) => _enCola(() async {
    final base = await _abierta();
    final fila =
        await (base.select(base.copiasLocales)..where(
              (t) => t.coleccion.equals(coleccion) & t.clave.equals(clave),
            ))
            .getSingleOrNull();
    return fila == null ? null : _aCopia(fila);
  });

  @override
  Future<List<CopiaLocal>> listar({required String coleccion}) =>
      _enCola(() async {
        final base = await _abierta();
        final filas = await (base.select(
          base.copiasLocales,
        )..where((t) => t.coleccion.equals(coleccion))).get();
        return filas.map(_aCopia).toList();
      });

  static CopiaLocal _aCopia(CopiasLocale fila) => CopiaLocal(
    coleccion: fila.coleccion,
    clave: fila.clave,
    contenido: fila.contenido,
    actualizadoEn: DateTime.fromMillisecondsSinceEpoch(
      fila.actualizadoEn,
      isUtc: true,
    ),
  );

  @override
  Future<void> borrarTodo() => _enCola(() async {
    await _soltar();
    await _borrarArchivos();
    await almacenamiento.borrar(claveEnAlmacen);
  });

  @override
  Future<void> cerrar() => _enCola(_soltar);

  Future<void> _soltar() async {
    final base = _base;
    _base = null;
    await base?.close();
  }
}
