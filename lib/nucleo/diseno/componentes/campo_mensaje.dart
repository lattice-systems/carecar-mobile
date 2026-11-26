import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'boton_circular.dart';

/// Campo para escribir un mensaje de chat (V2-T02.15), compartido por el
/// asistente (M24) y la mensajería con el asesor (M07).
///
/// Forma de píldora (V2-T02.16) con [Radios.bordeCampoChat]. Crece con el
/// texto hasta cinco líneas y después se desplaza por dentro.
/// Enviar queda deshabilitado mientras no haya texto (sin contar espacios);
/// al enviar entrega el texto recortado y se vacía. Adjuntar solo aparece si
/// hay [alAdjuntar]. Los dos botones son [BotonCircular] (V2-T02.17): miden
/// 48, rebotan y tienen nombre para el lector de pantalla; enviar va en acento.
class CampoMensaje extends StatefulWidget {
  const CampoMensaje({
    required this.alEnviar,
    super.key,
    this.alAdjuntar,
    this.controlador,
    this.habilitado = true,
    this.sugerencia = 'Escribe un mensaje',
    this.etiquetaEnviar = 'Enviar',
    this.etiquetaAdjuntar = 'Adjuntar',
    this.iconoAdjuntar = LucideIcons300.paperclip,
  });

  final ValueChanged<String> alEnviar;
  final VoidCallback? alAdjuntar;
  final TextEditingController? controlador;
  final bool habilitado;
  final String sugerencia;
  final String etiquetaEnviar;
  final String etiquetaAdjuntar;

  /// Icono del boton de adjuntar; el asistente usa una camara (V2-M24.05).
  final IconData iconoAdjuntar;

  static const int lineasMaximas = 5;

  @override
  State<CampoMensaje> createState() => _CampoMensajeState();
}

class _CampoMensajeState extends State<CampoMensaje> {
  TextEditingController? _propio;
  TextEditingController get _controlador =>
      widget.controlador ?? (_propio ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controlador.addListener(_alCambiar);
  }

  @override
  void didUpdateWidget(CampoMensaje anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.controlador != widget.controlador) {
      (anterior.controlador ?? _propio)?.removeListener(_alCambiar);
      _controlador.addListener(_alCambiar);
    }
  }

  @override
  void dispose() {
    _controlador.removeListener(_alCambiar);
    _propio?.dispose();
    super.dispose();
  }

  void _alCambiar() => setState(() {});

  bool get _puedeEnviar =>
      widget.habilitado && _controlador.text.trim().isNotEmpty;

  void _enviar() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    widget.alEnviar(texto);
    _controlador.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.alAdjuntar != null) ...[
          BotonCircular(
            key: const ValueKey('campo-mensaje-adjuntar'),
            icono: widget.iconoAdjuntar,
            etiqueta: widget.etiquetaAdjuntar,
            alPresionar: widget.habilitado ? widget.alAdjuntar : null,
          ),
          const SizedBox(width: Espaciado.e2),
        ],
        Expanded(
          child: TextField(
            controller: _controlador,
            enabled: widget.habilitado,
            minLines: 1,
            maxLines: CampoMensaje.lineasMaximas,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: t.cuerpo.copyWith(color: c.texto),
            decoration: InputDecoration(
              hintText: widget.sugerencia,
              hintStyle: t.cuerpo.copyWith(color: c.textoSecundario),
              filled: true,
              fillColor: c.superficieHundida,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Espaciado.e4,
                vertical: Espaciado.e3,
              ),
              border: const OutlineInputBorder(
                borderRadius: Radios.bordeCampoChat,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Radios.bordeCampoChat,
                borderSide: BorderSide(color: c.acento, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: Espaciado.e2),
        BotonCircular(
          key: const ValueKey('campo-mensaje-enviar'),
          icono: LucideIcons300.send,
          etiqueta: widget.etiquetaEnviar,
          variante: VarianteBotonCircular.acento,
          alPresionar: _puedeEnviar ? _enviar : null,
        ),
      ],
    );
  }
}
