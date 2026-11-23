import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/navegacion/proveedores_navegacion.dart';
import '../dominio/acceso_rapido.dart';
import 'destinos_accesos.dart';
import 'proveedores_widgets.dart';

/// Registra los accesos del icono y abre la pantalla que la persona elige
/// (V2-M25.04).
///
/// Va una sola vez, por dentro del `MaterialApp` (en su `builder`) para tener
/// los textos del idioma activo. No pinta nada propio: devuelve [child].
///
/// Abre con `go` sobre el enrutador de la app, asi que la guardia de sesion
/// aplica igual: sin sesion pide acceso y luego vuelve al destino elegido.
class InstaladorDeAccesosRapidos extends ConsumerStatefulWidget {
  const InstaladorDeAccesosRapidos({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<InstaladorDeAccesosRapidos> createState() =>
      _InstaladorDeAccesosRapidosState();
}

class _InstaladorDeAccesosRapidosState
    extends ConsumerState<InstaladorDeAccesosRapidos> {
  Locale? _idioma;

  @override
  void initState() {
    super.initState();
    ref.read(puertoAccesosRapidosProvider).alElegir(_abrir);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Los titulos se vuelven a registrar solo si cambia el idioma.
    final idioma = Localizations.localeOf(context);
    if (idioma == _idioma) return;
    _idioma = idioma;
    _instalar(AppLocalizations.of(context));
  }

  void _abrir(AccesoRapido acceso) {
    ref.read(enrutadorProvider).go(rutaDeAcceso(acceso));
  }

  Future<void> _instalar(AppLocalizations textos) async {
    final atajos = [
      AtajoDeIcono(
        acceso: AccesoRapido.agendar,
        titulo: textos.widgetsAccesoAgendar,
      ),
      AtajoDeIcono(
        acceso: AccesoRapido.miAuto,
        titulo: textos.widgetsAccesoMiAuto,
      ),
      AtajoDeIcono(acceso: AccesoRapido.sos, titulo: textos.widgetsAccesoSos),
    ];
    try {
      await ref.read(puertoAccesosRapidosProvider).instalar(atajos);
    } on Object {
      // Un sistema sin atajos (Android 7.0, emulador, escritorio) no debe
      // afectar a la app: simplemente no hay menu en el icono.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
