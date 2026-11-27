import 'dart:async';

import 'package:carecar_mobile/nucleo/analitica/analitica.dart';
import 'package:carecar_mobile/nucleo/analitica/crashes_android.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const canal = MethodChannel('mx.carecar/diagnostico');
  final mensajero =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late SharedPreferences preferencias;
  late Analitica analitica;
  late List<Map<String, Object>> enviados;
  late bool activa;
  late int revision;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      claveInicioDiagnosticoAndroid: 100,
    });
    preferencias = await SharedPreferences.getInstance();
    enviados = [];
    activa = true;
    revision = 0;
    analitica = Analitica(() => activa, (evento, puedeEnviar) async {
      if (puedeEnviar()) enviados.add(evento);
    }, revision: () => revision);
  });
  tearDown(() => mensajero.setMockMethodCallHandler(canal, null));

  test(
    'V2-M23.01: solo registra fallos nuevos del periodo consentido',
    () async {
      final consultas = <int>[];
      mensajero.setMockMethodCallHandler(canal, (llamada) async {
        expect(llamada.method, 'crashesDesde');
        final desde = llamada.arguments as int;
        consultas.add(desde);
        return [95, 105, 110].where((marca) => marca > desde).toList();
      });

      activa = false;
      await reportarCrashesAndroid(analitica, preferencias);
      expect(consultas, isEmpty);
      activa = true;
      await reportarCrashesAndroid(analitica, preferencias);
      await reportarCrashesAndroid(analitica, preferencias);
      expect(consultas, [100, 110]);
      expect(enviados, [
        {'tipo': 'CRASH_ANDROID'},
        {'tipo': 'CRASH_ANDROID'},
      ]);
    },
  );

  test('V2-M23.01: descarta la consulta si cambia el consentimiento', () async {
    final respuesta = Completer<List<int>>();
    mensajero.setMockMethodCallHandler(canal, (_) => respuesta.future);

    final pendiente = reportarCrashesAndroid(analitica, preferencias);
    revision += 2;
    respuesta.complete([105]);
    await pendiente;
    expect(enviados, isEmpty);
  });

  test('V2-M23.01: una preferencia previa empieza sin historial', () async {
    await preferencias.remove(claveInicioDiagnosticoAndroid);
    mensajero.setMockMethodCallHandler(
      canal,
      (_) async => fail('El historial previo queda fuera del consentimiento'),
    );

    await reportarCrashesAndroid(analitica, preferencias);
    expect(preferencias.getInt(claveInicioDiagnosticoAndroid), greaterThan(0));
    expect(enviados, isEmpty);
  });
}
