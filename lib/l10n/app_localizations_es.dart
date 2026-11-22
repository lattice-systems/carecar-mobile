// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get catalogoTitulo => 'Catálogo';

  @override
  String get catalogoCargando => 'Cargando catálogo';

  @override
  String get catalogoVacioTitulo => 'Aún no hay modelos';

  @override
  String get catalogoVacioMensaje =>
      'Cuando la agencia publique modelos, los verás aquí.';

  @override
  String precioDesde(String precio) {
    return 'Desde $precio';
  }

  @override
  String fotoDeModelo(String modelo) {
    return 'Foto del $modelo';
  }
}
