import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';

/// Fila con etiqueta y un control de dos estados. Base de `Casilla` e
/// `Interruptor`: toda la fila es zona tactil de al menos 48 y el lector de
/// pantalla recibe un solo nodo.
class _FilaBinaria extends StatelessWidget {
  const _FilaBinaria({
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
    required this.control,
    required this.esInterruptor,
    this.descripcion,
  });

  final String etiqueta;
  final String? descripcion;
  final bool valor;
  final ValueChanged<bool>? alCambiar;
  final Widget control;
  final bool esInterruptor;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final habilitado = alCambiar != null;

    void alTocar() {
      if (!habilitado) return;
      HapticFeedback.lightImpact();
      alCambiar!(!valor);
    }

    return Semantics(
      container: true,
      label: descripcion == null ? etiqueta : '$etiqueta. $descripcion',
      checked: esInterruptor ? null : valor,
      toggled: esInterruptor ? valor : null,
      enabled: habilitado,
      onTap: habilitado ? alTocar : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: habilitado ? alTocar : null,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Espaciado.e1),
            child: Row(
              children: [
                if (!esInterruptor) ...[
                  control,
                  const SizedBox(width: Espaciado.e3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        etiqueta,
                        style: t.cuerpo.copyWith(
                          color: habilitado ? c.texto : c.textoTerciario,
                        ),
                      ),
                      if (descripcion != null)
                        Text(
                          descripcion!,
                          style: t.cuerpoChico.copyWith(
                            color: habilitado
                                ? c.textoSecundario
                                : c.textoTerciario,
                          ),
                        ),
                    ],
                  ),
                ),
                if (esInterruptor) ...[
                  const SizedBox(width: Espaciado.e3),
                  control,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Casilla con etiqueta. Con `alCambiar` nulo queda deshabilitada.
class Casilla extends StatelessWidget {
  const Casilla({
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
    super.key,
    this.descripcion,
  });

  final String etiqueta;
  final String? descripcion;
  final bool valor;
  final ValueChanged<bool>? alCambiar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return _FilaBinaria(
      etiqueta: etiqueta,
      descripcion: descripcion,
      valor: valor,
      alCambiar: alCambiar,
      esInterruptor: false,
      control: ExcludeFocus(
        child: IgnorePointer(
          child: Checkbox(
            value: valor,
            onChanged: alCambiar == null ? null : (_) {},
            activeColor: c.acento,
            checkColor: c.sobreAcento,
            side: WidgetStateBorderSide.resolveWith(
              (e) => BorderSide(
                color: e.contains(WidgetState.selected)
                    ? c.acento
                    : c.contornoControl,
                width: 2,
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}

/// Interruptor con etiqueta. Con `alCambiar` nulo queda deshabilitado.
class Interruptor extends StatelessWidget {
  const Interruptor({
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
    super.key,
    this.descripcion,
  });

  final String etiqueta;
  final String? descripcion;
  final bool valor;
  final ValueChanged<bool>? alCambiar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return _FilaBinaria(
      etiqueta: etiqueta,
      descripcion: descripcion,
      valor: valor,
      alCambiar: alCambiar,
      esInterruptor: true,
      control: ExcludeFocus(
        child: IgnorePointer(
          child: Switch(
            value: valor,
            onChanged: alCambiar == null ? null : (_) {},
            activeThumbColor: c.sobreAcento,
            activeTrackColor: c.acento,
            inactiveThumbColor: c.textoSecundario,
            inactiveTrackColor: c.superficieHundida,
            trackOutlineColor: WidgetStateProperty.resolveWith(
              (e) => e.contains(WidgetState.selected)
                  ? c.acento
                  : c.contornoControl,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
