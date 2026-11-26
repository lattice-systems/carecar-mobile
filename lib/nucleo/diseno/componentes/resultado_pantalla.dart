import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/tokens_pista.dart';
import 'fila_acciones.dart';
import 'tono.dart';

/// Pantalla de resultado: lo que se pidió salió bien (o mal) y qué sigue.
///
/// Una marca redonda del tono (palomita en éxito), el título, el mensaje y las
/// acciones. Es el cierre de un flujo, así que no lleva encabezado ni regreso:
/// la acción principal es la salida. La marca entra con un pequeño rebote, el
/// único movimiento de la pantalla; con «reducir movimiento» aparece quieta.
///
/// `contenido` es opcional y va entre el mensaje y las acciones (por ejemplo,
/// el detalle de una recolección). El título es el encabezado para el lector.
class ResultadoPantalla extends StatelessWidget {
  const ResultadoPantalla({
    required this.titulo,
    required this.principal,
    super.key,
    this.mensaje,
    this.tono = Tono.exito,
    this.icono,
    this.secundaria,
    this.contenido,
  });

  final String titulo;
  final String? mensaje;
  final Tono tono;

  /// Icono de la marca; por omisión el del tono (palomita en éxito).
  final IconData? icono;
  final AccionPantalla principal;
  final AccionPantalla? secundaria;
  final Widget? contenido;

  static const double _marca = 96;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final colores = ColoresTono.de(tono, c);
    final reducir = MediaQuery.disableAnimationsOf(context);
    final movimiento = context.movimiento(Movimiento.enfatico);

    final marca = DecoratedBox(
      decoration: BoxDecoration(color: colores.fondo, shape: BoxShape.circle),
      child: SizedBox(
        width: _marca,
        height: _marca,
        child: Icon(
          icono ?? LucideIcons300.check,
          size: 52,
          color: colores.frente,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Espaciado.anchoMaximoContenido,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Espaciado.e6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Espaciado.e8),
                  ExcludeSemantics(
                    child: Center(
                      child: reducir
                          ? marca
                          : TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.6, end: 1),
                              duration: movimiento.duracion,
                              curve: movimiento.curva,
                              builder: (_, escala, hijo) =>
                                  Transform.scale(scale: escala, child: hijo),
                              child: marca,
                            ),
                    ),
                  ),
                  const SizedBox(height: Espaciado.e6),
                  Semantics(
                    header: true,
                    child: Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: t.titulo1.copyWith(color: c.texto),
                    ),
                  ),
                  if (mensaje != null) ...[
                    const SizedBox(height: Espaciado.e2),
                    Text(
                      mensaje!,
                      textAlign: TextAlign.center,
                      style: t.cuerpo.copyWith(color: c.textoSecundario),
                    ),
                  ],
                  if (contenido != null) ...[
                    const SizedBox(height: Espaciado.e6),
                    contenido!,
                  ],
                  const SizedBox(height: Espaciado.e8),
                  FilaAcciones(
                    principal: principal,
                    secundaria: secundaria,
                    apiladas: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
