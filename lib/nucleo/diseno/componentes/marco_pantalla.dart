import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'boton_cerrar.dart';
import 'encabezado_grande.dart';

/// El marco de toda pantalla de detalle o de formulario: encabezado grande que
/// se recoge, contenido que se desplaza sin atravesar el título y, si hace
/// falta, una barra fija al pie.
///
/// Es la única implementación: ningún módulo arma su propio `Scaffold` con
/// encabezado. El contenido va en `slivers`; el ancho se limita a
/// [Espaciado.anchoMaximoContenido] y se centra en pantallas anchas.
///
/// - `conRegreso`: pone «Regresar» en la barra; para las raíces de un módulo.
/// - `acciones`: botones al final de la barra. Si no se pasan y no hay regreso,
///   la barra lleva «Cerrar» (la pantalla se abrió encima de otra).
/// - `alRefrescar`: jalar para recargar; nulo lo desactiva.
/// - `barraInferior`: ver [BarraInferior].
///
/// Los estados de pantalla completa (cargando, vacío, error) se pasan con
/// [MarcoPantalla.estado]: conservan el título y se centran en el resto.
class MarcoPantalla extends StatelessWidget {
  const MarcoPantalla({
    required this.titulo,
    required this.slivers,
    super.key,
    this.subtitulo,
    this.acciones,
    this.conRegreso = false,
    this.barraInferior,
    this.alRefrescar,
  });

  /// Marco con un solo estado que ocupa el resto de la pantalla.
  MarcoPantalla.estado({
    required this.titulo,
    required Widget estado,
    super.key,
    this.subtitulo,
    this.acciones,
    this.conRegreso = false,
  }) : // El estado se centra y se desplaza solo (CentradoDesplazable), así que
       // ocupa el resto con alto fijo en vez de medirse con intrínsecos.
       slivers = [SliverFillRemaining(child: estado)],
       barraInferior = null,
       alRefrescar = null;

  final String titulo;
  final String? subtitulo;
  final List<Widget> slivers;
  final List<Widget>? acciones;
  final bool conRegreso;
  final Widget? barraInferior;
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
          conRegreso: conRegreso,
          acciones: acciones ?? (conRegreso ? const [] : const [BotonCerrar()]),
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

/// Barra fija al pie de un [MarcoPantalla] con las acciones del paso; respeta
/// el área segura y el ancho máximo del contenido. Los hijos van apilados.
class BarraInferior extends StatelessWidget {
  const BarraInferior({required this.hijos, super.key});

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
              padding: const EdgeInsets.symmetric(
                horizontal: Espaciado.e4,
                vertical: Espaciado.e3,
              ),
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

/// Sección de una pantalla: título (encabezado para el lector de pantalla) y
/// su contenido, con el margen lateral estándar. `conMargen: false` deja que el
/// contenido llegue a los bordes (carruseles, mapas). `nota` es un texto de
/// apoyo debajo del contenido.
class SeccionPantalla extends StatelessWidget {
  const SeccionPantalla({
    required this.titulo,
    required this.hijo,
    super.key,
    this.nota,
    this.conMargen = true,
  });

  final String titulo;
  final Widget hijo;
  final String? nota;
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
        if (nota != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Espaciado.e4,
              Espaciado.e2,
              Espaciado.e4,
              0,
            ),
            child: Text(
              nota!,
              style: tokens.tipografia.cuerpoChico.copyWith(
                color: c.textoSecundario,
              ),
            ),
          ),
      ],
    );
  }
}
