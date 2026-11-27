import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../idioma/proveedores_idioma.dart';
import 'analitica.dart';
import 'crashes_android.dart';

const claveConsentimientoAnalitica = 'compartir_analitica';

typedef PreferenciaAnalitica = ({
  bool activa,
  bool guardando,
  bool error,
  int revision,
});

class ConsentimientoAnalitica extends Notifier<PreferenciaAnalitica> {
  @override
  PreferenciaAnalitica build() => (
    activa:
        ref.watch(preferenciasProvider)?.get(claveConsentimientoAnalitica) ==
        true,
    guardando: false,
    error: false,
    revision: 0,
  );

  Future<void> elegir(bool activa) async {
    if (state.guardando) return;
    final revision = state.revision + 1;
    state = (activa: false, guardando: true, error: false, revision: revision);
    final preferencias = ref.read(preferenciasProvider);
    var guardado = false;
    try {
      if (preferencias != null &&
          (!activa ||
              await preferencias.setInt(
                claveInicioDiagnosticoAndroid,
                DateTime.now().millisecondsSinceEpoch,
              ))) {
        guardado = await preferencias.setBool(
          claveConsentimientoAnalitica,
          activa,
        );
      }
    } on Exception {
      // El envío sigue apagado si la plataforma no puede guardar la opción.
    }
    if (!ref.mounted) return;
    state = (
      activa: activa && guardado,
      guardando: false,
      error: !guardado,
      revision: revision,
    );
  }
}

final consentimientoAnaliticaProvider =
    NotifierProvider<ConsentimientoAnalitica, PreferenciaAnalitica>(
      ConsentimientoAnalitica.new,
    );

final transporteAnaliticaProvider = Provider<EnviarAnalitica?>((ref) => null);

final analiticaProvider = Provider<Analitica>((ref) {
  final enviar = ref.watch(transporteAnaliticaProvider);
  return Analitica(
    () =>
        ref.mounted &&
        enviar != null &&
        ref.read(consentimientoAnaliticaProvider).activa,
    enviar ?? (_, _) async {},
    revision: () =>
        ref.mounted ? ref.read(consentimientoAnaliticaProvider).revision : -1,
  );
});
