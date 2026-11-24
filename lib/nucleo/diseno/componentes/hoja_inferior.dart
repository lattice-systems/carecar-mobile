import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Hoja inferior del sistema de diseno v2.
///
/// Tiene asa, titulo opcional y contenido que se desplaza si no cabe. Se
/// muestra con [mostrarHojaInferior].
class HojaInferior extends StatelessWidget {
  const HojaInferior({required this.hijo, super.key, this.titulo});

  final Widget hijo;
  final String? titulo;

  static const double _anchoAsa = 36;
  static const double _altoAsa = 4;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Semantics(
      scopesRoute: true,
      namesRoute: titulo != null,
      label: titulo,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.superficieElevada,
          borderRadius: Radios.bordeHoja,
          border: Border(
            top: BorderSide(color: c.borde, width: 0.8),
            left: BorderSide(color: c.borde, width: 0.8),
            right: BorderSide(color: c.borde, width: 0.8),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Espaciado.e3),
              Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: _anchoAsa,
                    height: _altoAsa,
                    decoration: BoxDecoration(
                      color: c.borde,
                      borderRadius: Radios.bordePildora,
                    ),
                  ),
                ),
              ),
              if (titulo != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Espaciado.e5,
                    Espaciado.e4,
                    Espaciado.e5,
                    0,
                  ),
                  child: Semantics(
                    header: true,
                    child: Text(
                      titulo!,
                      style: t.titulo3.copyWith(color: c.texto),
                    ),
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Espaciado.e5),
                  child: hijo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Muestra una [HojaInferior] con el contenido de `builder`.
Future<T?> mostrarHojaInferior<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? titulo,
  bool cerrarAlTocarFuera = true,
}) {
  final tokens = TokensPista.de(context);
  final movimiento = context.movimiento(Movimiento.enfatico);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: cerrarAlTocarFuera,
    enableDrag: cerrarAlTocarFuera,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: tokens.colores.velo,
    sheetAnimationStyle: AnimationStyle(
      duration: movimiento.duracion,
      curve: movimiento.curva,
      reverseDuration: context.movimiento(Movimiento.base).duracion,
    ),
    builder: (contexto) =>
        HojaInferior(titulo: titulo, hijo: builder(contexto)),
  );
}
