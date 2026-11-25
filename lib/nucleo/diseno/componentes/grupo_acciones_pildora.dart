import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Una acción de [GrupoAccionesPildora]: solo icono, con [etiqueta] para el
/// lector de pantalla y el tooltip.
class AccionIcono {
  const AccionIcono({
    required this.icono,
    required this.etiqueta,
    required this.alPresionar,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback? alPresionar;
}

/// Dos o tres acciones de icono dentro de una misma píldora de vidrio
/// (rediseño de navegación): el grupo que va a la derecha del encabezado, junto
/// al botón circular de la izquierda. Cada acción mide 48 × 48.
class GrupoAccionesPildora extends StatelessWidget {
  const GrupoAccionesPildora({required this.acciones, super.key})
    : assert(
        acciones.length >= 1 && acciones.length <= 3,
        'Un grupo lleva de 1 a 3 acciones',
      );

  final List<AccionIcono> acciones;

  static const double _alfaVidrio = 0.06;
  static const double _alfaBorde = 0.14;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.texto.withValues(alpha: _alfaVidrio),
        borderRadius: Radios.bordePildora,
        border: Border.all(color: c.texto.withValues(alpha: _alfaBorde)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Espaciado.e1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (final a in acciones) _Accion(accion: a)],
        ),
      ),
    );
  }
}

class _Accion extends StatelessWidget {
  const _Accion({required this.accion});

  final AccionIcono accion;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final habilitada = accion.alPresionar != null;
    return Semantics(
      button: true,
      enabled: habilitada,
      label: accion.etiqueta,
      excludeSemantics: true,
      child: Tooltip(
        message: accion.etiqueta,
        child: InkResponse(
          onTap: accion.alPresionar,
          radius: 28,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              accion.icono,
              size: 22,
              color: habilitada ? c.texto : c.textoTerciario,
            ),
          ),
        ),
      ),
    );
  }
}
