import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'boton_pildora.dart';

/// Una accion de la fila de botones de [CabeceraPortada].
class AccionPortada {
  const AccionPortada({
    required this.texto,
    required this.alPresionar,
    this.icono,
  });

  final String texto;
  final VoidCallback? alPresionar;
  final IconData? icono;
}

/// Cabecera protagonista de una pantalla: una pieza grande y redondeada (foto
/// o silueta del auto, o un icono grande) sobre un fondo de color difuminado
/// que se funde con la superficie, con titulo, subtitulo y hasta dos botones
/// pildora.
///
/// `portada` es la pieza; se recorta con el radio de hoja. Si no hay `tinte`
/// usa el acento. El fondo es el mismo `portada` desenfocado mas el tinte, y
/// termina en el color de `fondo`, asi que no hay borde duro. `descripcion` es
/// lo que lee el lector de pantalla en lugar de la imagen. Con letra grande los
/// botones pasan a una columna para no desbordar.
class CabeceraPortada extends StatelessWidget {
  const CabeceraPortada({
    required this.titulo,
    required this.portada,
    super.key,
    this.subtitulo,
    this.descripcion,
    this.tinte,
    this.principal,
    this.secundaria,
    this.lado = 240,
  });

  final String titulo;
  final String? subtitulo;
  final Widget portada;
  final String? descripcion;
  final Color? tinte;
  final AccionPortada? principal;
  final AccionPortada? secundaria;

  /// Lado de la pieza cuadrada, en pixeles logicos.
  final double lado;

  static const double _desenfoque = 40;

  /// Alto que la barra superior le quita a la portada: la barra mas la zona
  /// del reloj, solo cuando el `Scaffold` que la contiene deja el cuerpo
  /// detras de la barra (`extendBodyBehindAppBar`). Sin esa reserva la pieza
  /// queda debajo del titulo de la barra.
  static double _reservaDeBarra(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold == null || !scaffold.widget.extendBodyBehindAppBar) return 0;
    return scaffold.appBarMaxHeight ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final color = tinte ?? c.acento;
    final oscuro = tokens.brillo == Brightness.dark;
    final letraGrande = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final reserva = _reservaDeBarra(context);

    final pieza = Semantics(
      image: true,
      label: descripcion,
      excludeSemantics: descripcion != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: Radios.bordeHoja,
          boxShadow: tokens.sombras,
        ),
        child: ClipRRect(
          borderRadius: Radios.bordeHoja,
          child: SizedBox(width: lado, height: lado, child: portada),
        ),
      ),
    );

    final botones = <Widget>[
      if (principal != null)
        BotonPildora(
          texto: principal!.texto,
          icono: principal!.icono,
          alPresionar: principal!.alPresionar,
          expandido: true,
        ),
      if (secundaria != null)
        BotonPildora(
          texto: secundaria!.texto,
          icono: secundaria!.icono,
          alPresionar: secundaria!.alPresionar,
          variante: VarianteBotonPildora.vidrio,
          expandido: true,
        ),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _desenfoque,
                      sigmaY: _desenfoque,
                    ),
                    child: portada,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withValues(alpha: oscuro ? 0.55 : 0.42),
                          c.fondo.withValues(alpha: 0.55),
                          c.fondo,
                        ],
                        stops: const [0, 0.6, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            Espaciado.e4,
            reserva > 0 ? reserva + Espaciado.e4 : Espaciado.e6,
            Espaciado.e4,
            Espaciado.e6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: pieza),
              const SizedBox(height: Espaciado.e5),
              Semantics(
                header: true,
                child: Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: t.titulo1.copyWith(color: c.texto),
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: Espaciado.e1),
                Text(
                  subtitulo!,
                  textAlign: TextAlign.center,
                  style: t.cuerpo.copyWith(color: c.textoSecundario),
                ),
              ],
              if (botones.isNotEmpty) ...[
                const SizedBox(height: Espaciado.e5),
                if (letraGrande || botones.length == 1)
                  Column(
                    children: [
                      for (var i = 0; i < botones.length; i++) ...[
                        if (i > 0) const SizedBox(height: Espaciado.e2),
                        botones[i],
                      ],
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: botones[0]),
                      const SizedBox(width: Espaciado.e3),
                      Expanded(child: botones[1]),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
