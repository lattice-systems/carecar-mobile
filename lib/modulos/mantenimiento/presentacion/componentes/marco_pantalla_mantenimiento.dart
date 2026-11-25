import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Marco de las pantallas de detalle y de formulario: título grande
/// translúcido que se contrae, contenido que se desplaza y, si hace falta,
/// una barra fija al pie.
///
/// Los estados de pantalla completa (cargando, vacío, error) se pasan con
/// [MarcoPantallaMantenimiento.estado]: conservan el título y se centran en el
/// resto. Mismo ritmo que el resto de las pantallas «Estilo portada».
class MarcoPantallaMantenimiento extends StatelessWidget {
  const MarcoPantallaMantenimiento({
    required this.titulo,
    required this.slivers,
    super.key,
    this.barraInferior,
    this.alRefrescar,
  });

  /// Marco con un solo estado que ocupa el resto de la pantalla.
  MarcoPantallaMantenimiento.estado({
    required this.titulo,
    required Widget estado,
    super.key,
  }) : slivers = [SliverFillRemaining(child: estado)],
       barraInferior = null,
       alRefrescar = null;

  final String titulo;
  final List<Widget> slivers;
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
          acciones: const [_BotonCerrar()],
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
class _BotonCerrar extends StatelessWidget {
  const _BotonCerrar();

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return IconButton(
      tooltip: AppLocalizations.of(context).mantenimientoCerrar,
      constraints: const BoxConstraints(
        minWidth: Espaciado.objetivoTactilMinimo,
        minHeight: Espaciado.objetivoTactilMinimo,
      ),
      icon: Icon(Icons.close_rounded, color: c.texto),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}

/// Barra fija al pie con las acciones del paso; respeta el área segura y el
/// ancho máximo del contenido. Los hijos van apilados.
class BarraInferiorMantenimiento extends StatelessWidget {
  const BarraInferiorMantenimiento({required this.hijos, super.key});

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
