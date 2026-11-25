import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../navegacion/rutas.dart';
import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';

/// Flecha de regreso de las pantallas raiz de un modulo.
///
/// Con pantalla anterior la saca de la pila; si no la hay (se abrio desde un
/// enlace o un widget) lleva al inicio, para que nunca falte una salida.
/// `alRegresar` sustituye ese comportamiento. Mide 48 x 48 y se anuncia como
/// boton «Regresar».
class BotonRegresar extends StatelessWidget {
  const BotonRegresar({super.key, this.alRegresar});

  final VoidCallback? alRegresar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final etiqueta = AppLocalizations.of(context).regresar;
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: etiqueta,
      excludeSemantics: true,
      onTap: () => _regresar(context),
      child: IconButton(
        tooltip: etiqueta,
        constraints: const BoxConstraints(
          minWidth: Espaciado.objetivoTactilMinimo,
          minHeight: Espaciado.objetivoTactilMinimo,
        ),
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: c.texto),
        onPressed: () => _regresar(context),
      ),
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
