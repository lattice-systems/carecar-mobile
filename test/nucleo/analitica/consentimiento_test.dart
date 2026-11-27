import 'dart:async';

import 'package:carecar_mobile/nucleo/analitica/proveedores_analitica.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('V2-M23.04: la opción persiste y apagada bloquea los envíos', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final envios = <Map<String, Object>>[];
    final espera = Completer<void>();
    final contenedor = ProviderContainer(
      overrides: [
        preferenciasProvider.overrideWithValue(prefs),
        transporteAnaliticaProvider.overrideWithValue((
          evento,
          puedeEnviar,
        ) async {
          if (evento['tipo'] == 'FRANJA') await espera.future;
          if (puedeEnviar()) envios.add(evento);
        }),
      ],
    );
    addTearDown(contenedor.dispose);
    final analitica = contenedor.read(analiticaProvider);
    final opcion = contenedor.read(consentimientoAnaliticaProvider.notifier);
    await analitica.registrar({'tipo': 'DISPONIBILIDAD'});
    expect(envios, isEmpty);

    await opcion.elegir(true);
    expect(prefs.getBool(claveConsentimientoAnalitica), isTrue);
    await analitica.registrar({'tipo': 'DISPONIBILIDAD'});
    final pendiente = analitica.registrar({'tipo': 'FRANJA'});
    final guardar = opcion.elegir(false);
    expect(analitica.habilitada, isFalse);
    await guardar;
    expect(prefs.getBool(claveConsentimientoAnalitica), isFalse);
    await opcion.elegir(true);
    espera.complete();
    await pendiente;
    expect(envios, hasLength(1));
  });
}
