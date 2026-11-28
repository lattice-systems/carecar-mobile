import 'package:drift/drift.dart';

part 'esquema_local.g.dart';

/// Las copias de datos del cliente (V2-M21.01).
///
/// Una sola tabla genérica por ahora: cada módulo guarda su contenido como
/// texto bajo su propia [coleccion]. Cuando V2-M21.02 necesite consultar por
/// campos (por ejemplo «las citas de este vehículo»), se agregan tablas
/// tipadas con una migración nueva.
class CopiasLocales extends Table {
  TextColumn get coleccion => text()();
  TextColumn get clave => text()();
  TextColumn get contenido => text()();

  /// Milisegundos desde 1970 (UTC) de la última vez que se guardó. Versión 2
  /// del esquema: las copias de la versión 1 quedan en `0` (se ignora cuándo).
  IntColumn get actualizadoEn => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {coleccion, clave};
}

/// Se lanza al abrir una base que un esquema **más nuevo** que el de esta app
/// dejó (el cliente instaló una versión anterior de la app). No hay forma de
/// leerla sin riesgo, así que quien abre la descarta y la recrea.
class EsquemaMasNuevoQueLaApp implements Exception {
  const EsquemaMasNuevoQueLaApp(this.encontrado, this.actual);

  final int encontrado;
  final int actual;

  @override
  String toString() =>
      'La base local es de la version $encontrado y esta app llega a la $actual';
}

/// La base de datos de drift. **Nadie fuera de `lib/nucleo/base_local/` la
/// importa**: los módulos usan `BaseLocal`.
///
/// ## Versiones del esquema
///
/// | Versión | Cambio |
/// | --- | --- |
/// | 1 | `copias_locales(coleccion, clave, contenido)` |
/// | 2 | agrega `actualizado_en`, para el sello «actualizado hace X» |
///
/// Cada cambio de esquema sube [schemaVersion], agrega un paso a
/// `onUpgrade` y una prueba que abre una base de la versión anterior
/// (`test/nucleo/base_local/base_local_drift_test.dart`).
@DriftDatabase(tables: [CopiasLocales])
class BaseDeDatosLocal extends _$BaseDeDatosLocal {
  BaseDeDatosLocal(super.ejecutor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, desde, hasta) async {
      // Drift llama aquí también cuando la base es de una versión mayor.
      if (desde > hasta) throw EsquemaMasNuevoQueLaApp(desde, hasta);
      if (desde < 2) {
        await m.addColumn(copiasLocales, copiasLocales.actualizadoEn);
      }
    },
  );
}
