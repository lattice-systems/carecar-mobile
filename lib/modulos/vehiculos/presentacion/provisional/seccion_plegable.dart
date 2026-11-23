// PROVISIONAL: se reemplaza por Acordeon del sistema de diseno cuando exista su
// historia V2-T02.xx (pendiente de crear por el planificador).
import 'package:flutter/material.dart';

import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Seccion que se pliega y despliega al tocar su encabezado.
///
/// Solo usa tokens del sistema v2. El encabezado es una zona tactil de al menos
/// 48 y el lector de pantalla oye "expandido" o "colapsado".
class SeccionPlegable extends StatefulWidget {
  const SeccionPlegable({
    required this.titulo,
    required this.hijo,
    super.key,
    this.inicialmenteAbierta = false,
  });

  final String titulo;
  final Widget hijo;
  final bool inicialmenteAbierta;

  @override
  State<SeccionPlegable> createState() => _SeccionPlegableState();
}

class _SeccionPlegableState extends State<SeccionPlegable> {
  late bool _abierta = widget.inicialmenteAbierta;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        border: Border.all(color: c.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _abierta,
            child: InkWell(
              borderRadius: BorderRadius.circular(Radios.tarjeta),
              onTap: () => setState(() => _abierta = !_abierta),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Espaciado.objetivoTactilMinimo,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Espaciado.e4,
                    vertical: Espaciado.e2,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.titulo,
                          style: t.cuerpoFuerte.copyWith(color: c.texto),
                        ),
                      ),
                      Icon(
                        _abierta ? Icons.expand_less : Icons.expand_more,
                        color: c.textoSecundario,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_abierta)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Espaciado.e4,
                0,
                Espaciado.e4,
                Espaciado.e3,
              ),
              child: widget.hijo,
            ),
        ],
      ),
    );
  }
}
