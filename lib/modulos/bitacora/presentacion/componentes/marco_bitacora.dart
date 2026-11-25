import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/componentes/boton_circular.dart';
import '../../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Marco de las pantallas secundarias de la bitácora (formulario,
/// estadísticas, exportar): título grande translúcido que se contrae, contenido
/// que se desplaza sin atravesar el título y, si hace falta, una barra fija al
/// pie. Mismo ritmo «Estilo portada» que el resto de la v2.
class MarcoBitacora extends StatelessWidget {
  const MarcoBitacora({
    required this.titulo,
    required this.slivers,
    super.key,
    this.barraInferior,
    this.alRefrescar,
  });

  /// Marco con un solo estado (cargando, vacío, error) que ocupa el resto.
  MarcoBitacora.estado({
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
    final textos = AppLocalizations.of(context);

    Widget desplazable = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        EncabezadoGrande(
          titulo: titulo,
          translucido: true,
          acciones: [
            BotonCircular(
              icono: Icons.close_rounded,
              etiqueta: textos.bitacoraCerrar,
              alPresionar: () => Navigator.of(context).maybePop(),
            ),
          ],
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

/// Barra fija al pie con las acciones del paso; respeta el área segura y el
/// ancho máximo del contenido. Los hijos van apilados.
class BarraInferiorBitacora extends StatelessWidget {
  const BarraInferiorBitacora({required this.hijos, super.key});

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

/// Sección de una pantalla: título en negrita (encabezado para el lector de
/// pantalla) y su contenido, con el margen lateral estándar.
class SeccionBitacora extends StatelessWidget {
  const SeccionBitacora({required this.titulo, required this.hijo, super.key});

  final String titulo;
  final Widget hijo;

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
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: hijo,
        ),
      ],
    );
  }
}
