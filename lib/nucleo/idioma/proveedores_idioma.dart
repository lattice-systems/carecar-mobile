import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/idiomas.dart';

/// Preferencias locales del dispositivo. La app (`main.dart`) las inyecta con
/// `overrideWithValue`. Sin inyectar, la eleccion de idioma sigue funcionando
/// durante la sesion pero no se recuerda al cerrar la app.
final preferenciasProvider = Provider<SharedPreferences?>(
  (ref) => null,
  name: 'preferenciasProvider',
);

/// Clave con la que se guarda el idioma elegido.
const claveIdiomaElegido = 'idioma_elegido';

/// Idioma que la persona eligio en Ajustes. Nulo significa "el del sistema":
/// entonces manda `resolverIdioma`.
class IdiomaElegido extends Notifier<Locale?> {
  @override
  Locale? build() {
    final codigo = ref
        .read(preferenciasProvider)
        ?.getString(claveIdiomaElegido);
    for (final idioma in idiomasSoportados) {
      if (idioma.languageCode == codigo) return idioma;
    }
    return null;
  }

  /// Cambia el idioma de la app al instante y lo recuerda. Con nulo vuelve al
  /// idioma del sistema.
  Future<void> elegir(Locale? idioma) async {
    state = idioma;
    final prefs = ref.read(preferenciasProvider);
    if (prefs == null) return;
    if (idioma == null) {
      await prefs.remove(claveIdiomaElegido);
    } else {
      await prefs.setString(claveIdiomaElegido, idioma.languageCode);
    }
  }
}

final idiomaElegidoProvider = NotifierProvider<IdiomaElegido, Locale?>(
  IdiomaElegido.new,
  name: 'idiomaElegidoProvider',
);
