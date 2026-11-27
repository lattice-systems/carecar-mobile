import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analitica.dart';

const claveInicioDiagnosticoAndroid = 'inicio_diagnostico_android';
const _ultimoCrash = 'ultimo_crash_android_procesado';
const _canal = MethodChannel('mx.carecar/diagnostico');

/// Consulta el historial del sistema una vez por arranque con sesión activa.
Future<void> reportarCrashesAndroid(
  Analitica analitica,
  SharedPreferences preferencias,
) async {
  if (!analitica.habilitada) return;
  final revision = analitica.revision;
  bool siguePermitido() =>
      analitica.habilitada && analitica.revision == revision;

  try {
    var desde = preferencias.getInt(claveInicioDiagnosticoAndroid);
    if (desde == null) {
      // Una instalación que ya compartía analítica empieza a contar desde hoy.
      await preferencias.setInt(
        claveInicioDiagnosticoAndroid,
        DateTime.now().millisecondsSinceEpoch,
      );
      return;
    }
    desde = max(desde, preferencias.getInt(_ultimoCrash) ?? 0);
    final historial = await _canal.invokeListMethod<int>('crashesDesde', desde);
    if (historial == null || historial.isEmpty || !siguePermitido()) return;

    // Avanza antes de enviar para evitar duplicados si el proceso vuelve a fallar.
    if (!await preferencias.setInt(_ultimoCrash, historial.reduce(max))) return;
    for (final _ in historial) {
      if (!siguePermitido()) return;
      await analitica.registrar({'tipo': 'CRASH_ANDROID'});
    }
  } on Exception {
    // La consulta de diagnóstico es de mejor esfuerzo.
  }
}
