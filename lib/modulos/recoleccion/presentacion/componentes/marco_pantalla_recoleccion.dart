import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../../nucleo/diseno/componentes/boton_circular.dart';

/// Marco de las pantallas de direcciones: título grande translúcido que se
/// contrae, contenido que se desplaza y, si hace falta, una barra fija al pie.
///
/// Los estados de pantalla completa (cargando, vacío, error) se pasan con
/// [MarcoPantallaRecoleccion.estado]: conservan el título y se centran en el
/// resto. Mismo ritmo que el resto de las pantallas «Estilo portada».
class MarcoPantallaRecoleccion extends StatelessWidget {
  const MarcoPantallaRecoleccion({
    required this.titulo,
    required this.slivers,
    super.key,
    this.acciones,
    this.barraInferior,
    this.alRefrescar,
  });

  /// Marco con un solo estado que ocupa el resto de la pantalla.
  MarcoPantallaRecoleccion.estado({
    required this.titulo,
    required Widget estado,
    super.key,
    this.acciones,
  }) : slivers = [SliverFillRemaining(child: estado)],
       barraInferior = null,
       alRefrescar = null;

  final String titulo;
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
          translucido: true,
          acciones: acciones ?? [BotonCerrarRecoleccion()],
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
class BotonCerrarRecoleccion extends StatelessWidget {
  const BotonCerrarRecoleccion({super.key});

  @override
  Widget build(BuildContext context) {
    return BotonCircular(
      etiqueta: AppLocalizations.of(context).recoleccionCerrar,
      icono: Icons.close_rounded,
      alPresionar: () => Navigator.of(context).maybePop(),
    );
  }
}

/// Barra fija al pie con las acciones del paso; respeta el área segura y el
/// ancho máximo del contenido. Los hijos van apilados.
class BarraInferiorRecoleccion extends StatelessWidget {
  const BarraInferiorRecoleccion({required this.hijos, super.key});

  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border(top: BorderSide(color: c.borde)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Espaciado.anchoMaximoContenido,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: hijos,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sección grande de una pantalla: título en negrita y su contenido, con el
/// título como encabezado para el lector de pantalla.
class SeccionRecoleccion extends StatelessWidget {
  const SeccionRecoleccion({
    required this.titulo,
    required this.hijo,
    super.key,
    this.conMargen = true,
  });

  final String titulo;
  final Widget hijo;
  final bool conMargen;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e6,
            Espaciado.e4,
            Espaciado.e3,
          ),
          child: Semantics(
            header: true,
            child: Text(
              titulo,
              style: tokens.tipografia.titulo2.copyWith(color: c.texto),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: conMargen ? Espaciado.e4 : 0,
          ),
          child: hijo,
        ),
      ],
    );
  }
}
