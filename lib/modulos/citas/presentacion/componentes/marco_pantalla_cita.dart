import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Marco de las pantallas de citas: título grande translúcido que se contrae,
/// contenido que se desplaza y, si hace falta, una barra fija al pie.
///
/// Los estados de pantalla completa (cargando, vacío, error) se pasan con
/// [MarcoPantallaCita.estado]: conservan el título y se centran en el resto.
class MarcoPantallaCita extends StatelessWidget {
  const MarcoPantallaCita({
    required this.titulo,
    required this.slivers,
    super.key,
    this.subtitulo,
    this.acciones,
    this.barraInferior,
    this.alRefrescar,
  });

  /// Marco con un solo estado que ocupa el resto de la pantalla.
  MarcoPantallaCita.estado({
    required this.titulo,
    required Widget estado,
    super.key,
    this.subtitulo,
    this.acciones,
  }) : slivers = [SliverFillRemaining(hasScrollBody: false, child: estado)],
       barraInferior = null,
       alRefrescar = null;

  final String titulo;
  final String? subtitulo;
  final List<Widget> slivers;

  /// Botones al final del encabezado; por defecto, «Cerrar».
  final List<Widget>? acciones;
  final Widget? barraInferior;

  /// Jalar para recargar; nulo lo desactiva.
  final Future<void> Function()? alRefrescar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;

    Widget desplazable = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        EncabezadoGrande(
          titulo: titulo,
          subtitulo: subtitulo,
          translucido: true,
          acciones: acciones ?? [BotonCerrarCita()],
        ),
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
      ],
    );
    if (alRefrescar != null) {
      desplazable = RefreshIndicator(
        onRefresh: alRefrescar!,
        edgeOffset: Espaciado.e14,
        child: desplazable,
      );
    }

    return Scaffold(
      backgroundColor: c.fondo,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Espaciado.anchoMaximoContenido,
                ),
                child: desplazable,
              ),
            ),
          ),
          ?barraInferior,
        ],
      ),
    );
  }
}

/// Botón «Cerrar» del encabezado: sale de la pantalla actual.
class BotonCerrarCita extends StatelessWidget {
  const BotonCerrarCita({super.key});

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return IconButton(
      tooltip: AppLocalizations.of(context).citasCerrar,
      constraints: const BoxConstraints(
        minWidth: Espaciado.objetivoTactilMinimo,
        minHeight: Espaciado.objetivoTactilMinimo,
      ),
      icon: Icon(Icons.close_rounded, color: c.texto),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
