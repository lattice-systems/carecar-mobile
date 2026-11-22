import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/elevacion.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'boton.dart';

/// Dialogo del sistema de diseno v2.
///
/// Lleva un titulo, un mensaje o contenido propio y hasta dos acciones. La
/// accion principal es la que confirma. Con `peligro` la accion principal usa
/// el estilo de peligro, para acciones que no se pueden deshacer.
class Dialogo extends StatelessWidget {
  const Dialogo({
    required this.titulo,
    required this.textoPrincipal,
    required this.alPrincipal,
    super.key,
    this.mensaje,
    this.contenido,
    this.textoSecundario,
    this.alSecundario,
    this.peligro = false,
  }) : assert(
         mensaje != null || contenido != null,
         'Un dialogo necesita mensaje o contenido',
       );

  final String titulo;
  final String? mensaje;
  final Widget? contenido;
  final String textoPrincipal;
  final VoidCallback? alPrincipal;
  final String? textoSecundario;
  final VoidCallback? alSecundario;
  final bool peligro;

  static const double _anchoMaximo = 400;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: titulo,
      explicitChildNodes: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.e5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _anchoMaximo),
            child: Material(
              color: Elevacion.superficie(c, tokens.brillo, nivel: 2),
              borderRadius: Radios.bordeTarjeta,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: Radios.bordeTarjeta,
                  boxShadow: Elevacion.sombras(tokens.brillo),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Espaciado.e5),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(titulo, style: t.titulo3.copyWith(color: c.texto)),
                        const SizedBox(height: Espaciado.e3),
                        if (mensaje != null)
                          Text(
                            mensaje!,
                            style: t.cuerpo.copyWith(color: c.textoSecundario),
                          ),
                        ?contenido,
                        const SizedBox(height: Espaciado.e5),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: Espaciado.e2,
                          runSpacing: Espaciado.e2,
                          children: [
                            if (textoSecundario != null)
                              Boton(
                                texto: textoSecundario!,
                                variante: VarianteBoton.terciario,
                                alPresionar: alSecundario,
                              ),
                            Boton(
                              texto: textoPrincipal,
                              variante: peligro
                                  ? VarianteBoton.peligro
                                  : VarianteBoton.principal,
                              alPresionar: alPrincipal,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Muestra un [Dialogo] sobre la pantalla actual.
///
/// Devuelve lo que entregue `Navigator.pop`. Se cierra al tocar fuera salvo
/// que `cerrarAlTocarFuera` sea falso, util para acciones de peligro.
Future<T?> mostrarDialogo<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool cerrarAlTocarFuera = true,
}) {
  final tokens = TokensPista.de(context);
  final movimiento = context.movimiento(Movimiento.base);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: cerrarAlTocarFuera,
    barrierLabel: 'Cerrar',
    barrierColor: tokens.colores.velo,
    transitionDuration: movimiento.duracion,
    pageBuilder: (contexto, _, _) => builder(contexto),
    transitionBuilder: (contexto, animacion, _, hijo) {
      final curva = CurvedAnimation(parent: animacion, curve: movimiento.curva);
      return FadeTransition(
        opacity: curva,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curva),
          child: hijo,
        ),
      );
    },
  );
}
