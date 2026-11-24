import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';

/// Relleno del boton circular: `tonal` para acciones secundarias (adjuntar,
/// 👍/👎 sin marcar) y `acento` para la principal (enviar).
enum VarianteBotonCircular { tonal, acento }

/// Boton redondo de 48 con un icono (V2-T02.17), del estilo vidrio liquido y
/// pildora (V2-T02.16): rebota al tocarlo en vez de salpicar.
///
/// - `acento` habilitado o `marcado`: fondo `acentoSuave` e icono `acento`.
/// - `tonal`: fondo `superficieHundida` e icono `textoSecundario`.
/// - Con `alPresionar` nulo queda deshabilitado: fondo hundido, icono
///   terciario y sin rebote.
///
/// Con [iconoMarcado] es un interruptor (👍/👎): el lector de pantalla anuncia
/// si esta seleccionado. [etiqueta] es su nombre para el lector y el tooltip.
class BotonCircular extends StatelessWidget {
  const BotonCircular({
    required this.icono,
    required this.etiqueta,
    required this.alPresionar,
    super.key,
    this.variante = VarianteBotonCircular.tonal,
    this.iconoMarcado,
    this.marcado = false,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback? alPresionar;
  final VarianteBotonCircular variante;
  final IconData? iconoMarcado;
  final bool marcado;

  static const double _tamanoIcono = 20;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final habilitado = alPresionar != null;
    final resaltado =
        habilitado && (marcado || variante == VarianteBotonCircular.acento);

    final fondo = resaltado ? c.acentoSuave : c.superficieHundida;
    final frente = !habilitado
        ? c.textoTerciario
        : (resaltado ? c.acento : c.textoSecundario);

    return Semantics(
      container: true,
      button: true,
      enabled: habilitado,
      selected: iconoMarcado == null ? null : marcado,
      label: etiqueta,
      onTap: alPresionar,
      excludeSemantics: true,
      child: Tooltip(
        message: etiqueta,
        excludeFromSemantics: true,
        child: ReboteTactil(
          alPulsar: alPresionar,
          habilitado: habilitado,
          // Center evita que un padre con ancho fijo lo estire a ovalo.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Container(
              key: const ValueKey('boton-circular-fondo'),
              width: Espaciado.objetivoTactilMinimo,
              height: Espaciado.objetivoTactilMinimo,
              decoration: BoxDecoration(shape: BoxShape.circle, color: fondo),
              child: Icon(
                marcado ? (iconoMarcado ?? icono) : icono,
                size: _tamanoIcono,
                color: frente,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
