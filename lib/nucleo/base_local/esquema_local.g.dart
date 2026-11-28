// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esquema_local.dart';

// ignore_for_file: type=lint
class $CopiasLocalesTable extends CopiasLocales
    with TableInfo<$CopiasLocalesTable, CopiasLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CopiasLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _coleccionMeta = const VerificationMeta(
    'coleccion',
  );
  @override
  late final GeneratedColumn<String> coleccion = GeneratedColumn<String>(
    'coleccion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contenidoMeta = const VerificationMeta(
    'contenido',
  );
  @override
  late final GeneratedColumn<String> contenido = GeneratedColumn<String>(
    'contenido',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<int> actualizadoEn = GeneratedColumn<int>(
    'actualizado_en',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    coleccion,
    clave,
    contenido,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'copias_locales';
  @override
  VerificationContext validateIntegrity(
    Insertable<CopiasLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('coleccion')) {
      context.handle(
        _coleccionMeta,
        coleccion.isAcceptableOrUnknown(data['coleccion']!, _coleccionMeta),
      );
    } else if (isInserting) {
      context.missing(_coleccionMeta);
    }
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('contenido')) {
      context.handle(
        _contenidoMeta,
        contenido.isAcceptableOrUnknown(data['contenido']!, _contenidoMeta),
      );
    } else if (isInserting) {
      context.missing(_contenidoMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {coleccion, clave};
  @override
  CopiasLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CopiasLocale(
      coleccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coleccion'],
      )!,
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      contenido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contenido'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $CopiasLocalesTable createAlias(String alias) {
    return $CopiasLocalesTable(attachedDatabase, alias);
  }
}

class CopiasLocale extends DataClass implements Insertable<CopiasLocale> {
  final String coleccion;
  final String clave;
  final String contenido;

  /// Milisegundos desde 1970 (UTC) de la última vez que se guardó. Versión 2
  /// del esquema: las copias de la versión 1 quedan en `0` (se ignora cuándo).
  final int actualizadoEn;
  const CopiasLocale({
    required this.coleccion,
    required this.clave,
    required this.contenido,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['coleccion'] = Variable<String>(coleccion);
    map['clave'] = Variable<String>(clave);
    map['contenido'] = Variable<String>(contenido);
    map['actualizado_en'] = Variable<int>(actualizadoEn);
    return map;
  }

  CopiasLocalesCompanion toCompanion(bool nullToAbsent) {
    return CopiasLocalesCompanion(
      coleccion: Value(coleccion),
      clave: Value(clave),
      contenido: Value(contenido),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory CopiasLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CopiasLocale(
      coleccion: serializer.fromJson<String>(json['coleccion']),
      clave: serializer.fromJson<String>(json['clave']),
      contenido: serializer.fromJson<String>(json['contenido']),
      actualizadoEn: serializer.fromJson<int>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'coleccion': serializer.toJson<String>(coleccion),
      'clave': serializer.toJson<String>(clave),
      'contenido': serializer.toJson<String>(contenido),
      'actualizadoEn': serializer.toJson<int>(actualizadoEn),
    };
  }

  CopiasLocale copyWith({
    String? coleccion,
    String? clave,
    String? contenido,
    int? actualizadoEn,
  }) => CopiasLocale(
    coleccion: coleccion ?? this.coleccion,
    clave: clave ?? this.clave,
    contenido: contenido ?? this.contenido,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  CopiasLocale copyWithCompanion(CopiasLocalesCompanion data) {
    return CopiasLocale(
      coleccion: data.coleccion.present ? data.coleccion.value : this.coleccion,
      clave: data.clave.present ? data.clave.value : this.clave,
      contenido: data.contenido.present ? data.contenido.value : this.contenido,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CopiasLocale(')
          ..write('coleccion: $coleccion, ')
          ..write('clave: $clave, ')
          ..write('contenido: $contenido, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(coleccion, clave, contenido, actualizadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CopiasLocale &&
          other.coleccion == this.coleccion &&
          other.clave == this.clave &&
          other.contenido == this.contenido &&
          other.actualizadoEn == this.actualizadoEn);
}

class CopiasLocalesCompanion extends UpdateCompanion<CopiasLocale> {
  final Value<String> coleccion;
  final Value<String> clave;
  final Value<String> contenido;
  final Value<int> actualizadoEn;
  final Value<int> rowid;
  const CopiasLocalesCompanion({
    this.coleccion = const Value.absent(),
    this.clave = const Value.absent(),
    this.contenido = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CopiasLocalesCompanion.insert({
    required String coleccion,
    required String clave,
    required String contenido,
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : coleccion = Value(coleccion),
       clave = Value(clave),
       contenido = Value(contenido);
  static Insertable<CopiasLocale> custom({
    Expression<String>? coleccion,
    Expression<String>? clave,
    Expression<String>? contenido,
    Expression<int>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (coleccion != null) 'coleccion': coleccion,
      if (clave != null) 'clave': clave,
      if (contenido != null) 'contenido': contenido,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CopiasLocalesCompanion copyWith({
    Value<String>? coleccion,
    Value<String>? clave,
    Value<String>? contenido,
    Value<int>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return CopiasLocalesCompanion(
      coleccion: coleccion ?? this.coleccion,
      clave: clave ?? this.clave,
      contenido: contenido ?? this.contenido,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (coleccion.present) {
      map['coleccion'] = Variable<String>(coleccion.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (contenido.present) {
      map['contenido'] = Variable<String>(contenido.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<int>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CopiasLocalesCompanion(')
          ..write('coleccion: $coleccion, ')
          ..write('clave: $clave, ')
          ..write('contenido: $contenido, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDeDatosLocal extends GeneratedDatabase {
  _$BaseDeDatosLocal(QueryExecutor e) : super(e);
  $BaseDeDatosLocalManager get managers => $BaseDeDatosLocalManager(this);
  late final $CopiasLocalesTable copiasLocales = $CopiasLocalesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [copiasLocales];
}

typedef $$CopiasLocalesTableCreateCompanionBuilder =
    CopiasLocalesCompanion Function({
      required String coleccion,
      required String clave,
      required String contenido,
      Value<int> actualizadoEn,
      Value<int> rowid,
    });
typedef $$CopiasLocalesTableUpdateCompanionBuilder =
    CopiasLocalesCompanion Function({
      Value<String> coleccion,
      Value<String> clave,
      Value<String> contenido,
      Value<int> actualizadoEn,
      Value<int> rowid,
    });

class $$CopiasLocalesTableFilterComposer
    extends Composer<_$BaseDeDatosLocal, $CopiasLocalesTable> {
  $$CopiasLocalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get coleccion => $composableBuilder(
    column: $table.coleccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contenido => $composableBuilder(
    column: $table.contenido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CopiasLocalesTableOrderingComposer
    extends Composer<_$BaseDeDatosLocal, $CopiasLocalesTable> {
  $$CopiasLocalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get coleccion => $composableBuilder(
    column: $table.coleccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contenido => $composableBuilder(
    column: $table.contenido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CopiasLocalesTableAnnotationComposer
    extends Composer<_$BaseDeDatosLocal, $CopiasLocalesTable> {
  $$CopiasLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get coleccion =>
      $composableBuilder(column: $table.coleccion, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get contenido =>
      $composableBuilder(column: $table.contenido, builder: (column) => column);

  GeneratedColumn<int> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$CopiasLocalesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatosLocal,
          $CopiasLocalesTable,
          CopiasLocale,
          $$CopiasLocalesTableFilterComposer,
          $$CopiasLocalesTableOrderingComposer,
          $$CopiasLocalesTableAnnotationComposer,
          $$CopiasLocalesTableCreateCompanionBuilder,
          $$CopiasLocalesTableUpdateCompanionBuilder,
          (
            CopiasLocale,
            BaseReferences<
              _$BaseDeDatosLocal,
              $CopiasLocalesTable,
              CopiasLocale
            >,
          ),
          CopiasLocale,
          PrefetchHooks Function()
        > {
  $$CopiasLocalesTableTableManager(
    _$BaseDeDatosLocal db,
    $CopiasLocalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CopiasLocalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CopiasLocalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CopiasLocalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> coleccion = const Value.absent(),
                Value<String> clave = const Value.absent(),
                Value<String> contenido = const Value.absent(),
                Value<int> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CopiasLocalesCompanion(
                coleccion: coleccion,
                clave: clave,
                contenido: contenido,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String coleccion,
                required String clave,
                required String contenido,
                Value<int> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CopiasLocalesCompanion.insert(
                coleccion: coleccion,
                clave: clave,
                contenido: contenido,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CopiasLocalesTable, CopiasLocale>(table),
                  BaseReferences<
                    _$BaseDeDatosLocal,
                    $CopiasLocalesTable,
                    CopiasLocale
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CopiasLocalesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatosLocal,
      $CopiasLocalesTable,
      CopiasLocale,
      $$CopiasLocalesTableFilterComposer,
      $$CopiasLocalesTableOrderingComposer,
      $$CopiasLocalesTableAnnotationComposer,
      $$CopiasLocalesTableCreateCompanionBuilder,
      $$CopiasLocalesTableUpdateCompanionBuilder,
      (
        CopiasLocale,
        BaseReferences<_$BaseDeDatosLocal, $CopiasLocalesTable, CopiasLocale>,
      ),
      CopiasLocale,
      PrefetchHooks Function()
    >;

class $BaseDeDatosLocalManager {
  final _$BaseDeDatosLocal _db;
  $BaseDeDatosLocalManager(this._db);
  $$CopiasLocalesTableTableManager get copiasLocales =>
      $$CopiasLocalesTableTableManager(_db, _db.copiasLocales);
}
