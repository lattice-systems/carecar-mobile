import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/tokens_pista.dart';
import 'boton_circular.dart';

/// Botón redondo «Cerrar» de los encabezados: sale de la pantalla actual.
///
/// Es el hermano de [BotonRegresar]: mismo círculo de vidrio y mismo icono
/// neutro. Se usa en las pantallas que se abren encima de otra (formularios,
/// comprobantes), mientras que «Regresar» es para las raíces de un módulo.
class BotonCerrar extends StatelessWidget {
  const BotonCerrar({super.key, this.alCerrar});

  /// Sustituye el cierre normal (`Navigator.maybePop`).
  final VoidCallback? alCerrar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return BotonCircular(
      icono: LucideIcons300.x,
      etiqueta: AppLocalizations.of(context).cerrarPantalla,
      colorIcono: c.texto,
      alPresionar: alCerrar ?? () => Navigator.of(context).maybePop(),
    );
  }
}
