import 'package:carecar_mobile/nucleo/base_local/base_local.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que **toda** [BaseLocal] debe cumplir (V2-M21.01).
///
/// Se corre contra la de verdad (drift con SQLCipher) y contra el doble en
/// memoria que usan las pruebas de los demás módulos: así el doble no puede
/// prometer algo que la real no hace.
void ejecutarContratoBaseLocal(
  BaseLocal Function(DateTime Function() reloj) crear,
) {
  late DateTime ahora;
  late BaseLocal base;

  setUp(() {
    ahora = DateTime.utc(2026, 11, 27, 10);
    base = crear(() => ahora);
  });

  tearDown(() => base.cerrar());

  test('leer algo que nunca se guardó da null', () async {
    expect(await base.leer(coleccion: 'vehiculos', clave: 'v1'), isNull);
  });

  test('lo que se guarda se lee igual, con la hora en que se guardó', () async {
    await base.guardar(
      coleccion: 'vehiculos',
      clave: 'v1',
      contenido: '{"placas":"ABC-1"}',
    );

    final copia = await base.leer(coleccion: 'vehiculos', clave: 'v1');

    expect(copia, isNotNull);
    expect(copia!.coleccion, 'vehiculos');
    expect(copia.clave, 'v1');
    expect(copia.contenido, '{"placas":"ABC-1"}');
    expect(copia.actualizadoEn, ahora);
  });

  test('guardar otra vez la misma clave reemplaza y renueva la hora', () async {
    await base.guardar(coleccion: 'citas', clave: 'c1', contenido: 'viejo');
    ahora = ahora.add(const Duration(hours: 2));
    await base.guardar(coleccion: 'citas', clave: 'c1', contenido: 'nuevo');

    final copia = await base.leer(coleccion: 'citas', clave: 'c1');

    expect(copia!.contenido, 'nuevo');
    expect(copia.actualizadoEn, ahora);
    expect(await base.listar(coleccion: 'citas'), hasLength(1));
  });

  test('la misma clave en dos colecciones son dos copias distintas', () async {
    await base.guardar(coleccion: 'citas', clave: '1', contenido: 'cita');
    await base.guardar(coleccion: 'vehiculos', clave: '1', contenido: 'auto');

    expect(
      (await base.leer(coleccion: 'citas', clave: '1'))!.contenido,
      'cita',
    );
    expect(
      (await base.leer(coleccion: 'vehiculos', clave: '1'))!.contenido,
      'auto',
    );
  });

  test('listar trae solo la colección pedida', () async {
    await base.guardar(coleccion: 'citas', clave: 'a', contenido: '1');
    await base.guardar(coleccion: 'citas', clave: 'b', contenido: '2');
    await base.guardar(coleccion: 'vehiculos', clave: 'a', contenido: '3');

    final citas = await base.listar(coleccion: 'citas');

    expect(citas.map((c) => c.clave).toSet(), {'a', 'b'});
    expect(await base.listar(coleccion: 'documentos'), isEmpty);
  });

  test('borrarTodo no deja ninguna copia y la base sigue sirviendo', () async {
    await base.guardar(coleccion: 'citas', clave: 'a', contenido: '1');
    await base.guardar(coleccion: 'vehiculos', clave: 'a', contenido: '2');

    await base.borrarTodo();

    expect(await base.listar(coleccion: 'citas'), isEmpty);
    expect(await base.listar(coleccion: 'vehiculos'), isEmpty);
    expect(await base.leer(coleccion: 'citas', clave: 'a'), isNull);

    await base.guardar(coleccion: 'citas', clave: 'z', contenido: 'otra');
    expect(
      (await base.leer(coleccion: 'citas', clave: 'z'))!.contenido,
      'otra',
    );
  });
}
