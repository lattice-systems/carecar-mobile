import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../navegacion/rutas.dart';
import '../tokens/tokens_pista.dart';
import 'boton_circular.dart';

/// Botón de regreso de las pantallas raíz de un módulo: un círculo de vidrio
/// con la flecha en el color de texto, igual que el botón de cierre y el resto
/// de los botones redondos de los encabezados.
///
/// Con pantalla anterior la saca de la pila; si no la hay (se abrió desde un
/// enlace o un widget) lleva al inicio, para que nunca falte una salida.
/// `alRegresar` sustituye ese comportamiento. Mide 48 x 48 y se anuncia como
/// botón «Regresar».
class BotonRegresar extends StatelessWidget {
  const BotonRegresar({super.key, this.alRegresar});

  final VoidCallback? alRegresar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return BotonCircular(
      icono: LucideIcons300.chevronLeft,
      etiqueta: AppLocalizations.of(context).regresar,
      colorIcono: c.texto,
      alPresionar: () => _regresar(context),
    );
  }

  void _regresar(BuildContext context) {
    final propio = alRegresar;
    if (propio != null) {
      propio();
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (router != null) {
      router.go(Rutas.inicio);
    }
  }
}
