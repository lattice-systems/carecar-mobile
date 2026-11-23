import 'package:flutter/material.dart';

import '../tokens/tokens_pista.dart';

/// Barra superior de las pantallas con [CabeceraPortada] a pantalla completa.
///
/// Arriba del todo es transparente, para que el fondo difuminado de la portada
/// llegue hasta el borde; en cuanto el contenido pasa por debajo se vuelve del
/// color de `fondo`, opaca, de modo que nada se lee a traves del titulo ni del
/// boton de regreso. Va con `Scaffold(extendBodyBehindAppBar: true)`.
class BarraPortada extends StatelessWidget implements PreferredSizeWidget {
  const BarraPortada({super.key, this.titulo});

  /// Titulo de la barra; `null` cuando el titulo vive en la portada.
  final String? titulo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return AppBar(
      title: titulo == null ? null : Text(titulo!),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: WidgetStateColor.resolveWith(
        (estados) => estados.contains(WidgetState.scrolledUnder)
            ? c.fondo
            : Colors.transparent,
      ),
    );
  }
}
