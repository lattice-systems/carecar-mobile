import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el canal manda bloquear y permitir; sin plataforma no falla', () async {
    final llamadas = <String>[];
    const canal = MethodChannel(ProteccionDeCapturaCanal.nombreCanal);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, (c) async {
          llamadas.add(c.method);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canal, null),
    );

    final p = ProteccionDeCapturaCanal();
    await p.bloquear();
    await p.permitir();
    expect(llamadas, ['bloquear', 'permitir']);
  });

  test('si el canal no existe (iOS, pruebas) se ignora', () async {
    final p = ProteccionDeCapturaCanal();
    await p.bloquear();
    await p.permitir();
  });

  test('el fake cuenta pantallas seguras activas', () async {
    final f = ProteccionDeCapturaFake();
    await f.bloquear();
    await f.bloquear();
    await f.permitir();
    expect(f.bloqueada, isTrue);
    await f.permitir();
    expect(f.bloqueada, isFalse);
  });
}
