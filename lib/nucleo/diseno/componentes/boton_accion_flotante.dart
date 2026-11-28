import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';

/// La acción principal de una pantalla, en una píldora con icono y texto que
/// flota sobre el contenido (rediseño de navegación).
///
/// Es del color de acento del sistema, con un degradado hacia el marino de
/// marca y un resplandor del mismo color; el texto usa `sobreAcento`, que el
/// sistema define para leer sobre el acento. Solo una por pantalla. Va arriba de
/// la [BarraFlotante] y, como flota, el contenido necesita margen inferior para
/// que no tape el último renglón.
class BotonAccionFlotante extends StatelessWidget {
  const BotonAccionFlotante({
    required this.texto,
    required this.icono,
    required this.alPresionar,
    super.key,
  });

  final String texto;
  final IconData icono;
  final VoidCallback? alPresionar;

  /// Alto del botón; la pantalla lo suma a la reserva de su lista.
  static const double alto = 48;

  /// Por encima de esta escala de letra el botón flotante se esconde: la barra
  /// de pestañas crece y taparía media pantalla.
  static const double escalaMaxima = 1.5;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final habilitado = alPresionar != null;
    final frente = habilitado ? c.sobreAcento : c.textoTerciario;
    return Semantics(
      button: true,
      enabled: habilitado,
      label: texto,
      excludeSemantics: true,
      onTap: alPresionar,
      child: ReboteTactil(
        alPulsar: alPresionar,
        habilitado: habilitado,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: habilitado ? null : c.superficieHundida,
            gradient: habilitado
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.acento, Color.lerp(c.acento, c.marca, 0.45)!],
                  )
                : null,
            borderRadius: Radios.bordePildora,
            boxShadow: [
              BoxShadow(
                color: (habilitado ? c.acento : c.texto).withValues(
                  alpha: habilitado ? 0.40 : 0.10,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: alto),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Espaciado.e4,
                vertical: Espaciado.e2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, size: 20, color: frente),
                  const SizedBox(width: Espaciado.e2),
                  Flexible(
                    child: Text(
                      texto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.tipografia.cuerpoChico.copyWith(
                        color: frente,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
