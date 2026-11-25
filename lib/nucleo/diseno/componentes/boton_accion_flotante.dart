import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';

/// La acción principal de una pantalla, en una píldora oscura con icono y texto
/// que flota sobre el contenido (rediseño de navegación), como «Nueva sesión»
/// en la app de Claude.
///
/// Solo una por pantalla. Va arriba de la [BarraFlotante] y, como flota, el
/// contenido necesita margen inferior para que no tape el último renglón. Usa
/// `texto` como fondo y `fondo` como frente: oscura en claro y clara en oscuro,
/// siempre con contraste.
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

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final habilitado = alPresionar != null;
    final fondo = habilitado ? c.texto : c.superficieHundida;
    final frente = habilitado ? c.fondo : c.textoTerciario;
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
            color: fondo,
            borderRadius: Radios.bordePildora,
            boxShadow: [
              BoxShadow(
                color: c.texto.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Espaciado.e5,
                vertical: Espaciado.e3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, size: 22, color: frente),
                  const SizedBox(width: Espaciado.e2),
                  Flexible(
                    child: Text(
                      texto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tokens.tipografia.cuerpoFuerte.copyWith(
                        color: frente,
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
