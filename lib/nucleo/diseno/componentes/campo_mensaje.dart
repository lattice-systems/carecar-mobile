import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Campo para escribir un mensaje de chat (V2-T02.15), compartido por el
/// asistente (M24) y la mensajería con el asesor (M07).
///
/// Crece con el texto hasta cinco líneas y después se desplaza por dentro.
/// Enviar queda deshabilitado mientras no haya texto (sin contar espacios);
/// al enviar entrega el texto recortado y se vacía. Adjuntar solo aparece si
/// hay [alAdjuntar]. Los dos botones miden al menos 48 y tienen nombre para
/// el lector de pantalla.
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
  });

  final ValueChanged<String> alEnviar;
  final VoidCallback? alAdjuntar;
  final TextEditingController? controlador;
  final bool habilitado;
  final String sugerencia;
  final String etiquetaEnviar;
  final String etiquetaAdjuntar;

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

    const tamBoton = BoxConstraints(
      minWidth: Espaciado.objetivoTactilMinimo,
      minHeight: Espaciado.objetivoTactilMinimo,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.alAdjuntar != null)
          _BotonConNombre(
            etiqueta: widget.etiquetaAdjuntar,
            alPresionar: widget.habilitado ? widget.alAdjuntar : null,
            child: IconButton(
              key: const ValueKey('campo-mensaje-adjuntar'),
              onPressed: widget.habilitado ? widget.alAdjuntar : null,
              constraints: tamBoton,
              tooltip: widget.etiquetaAdjuntar,
              color: c.textoSecundario,
              icon: const Icon(Icons.attach_file),
            ),
          ),
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
                borderRadius: Radios.bordeTarjeta,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Radios.bordeTarjeta,
                borderSide: BorderSide(color: c.acento, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: Espaciado.e1),
        _BotonConNombre(
          etiqueta: widget.etiquetaEnviar,
          alPresionar: _puedeEnviar ? _enviar : null,
          child: IconButton(
            key: const ValueKey('campo-mensaje-enviar'),
            onPressed: _puedeEnviar ? _enviar : null,
            constraints: tamBoton,
            tooltip: widget.etiquetaEnviar,
            color: c.acento,
            disabledColor: c.textoTerciario,
            icon: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}

/// Da al botón de ícono un nombre propio para el lector de pantalla (el
/// tooltip solo se anuncia como pista) y su estado habilitado.
class _BotonConNombre extends StatelessWidget {
  const _BotonConNombre({
    required this.etiqueta,
    required this.alPresionar,
    required this.child,
  });

  final String etiqueta;
  final VoidCallback? alPresionar;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    enabled: alPresionar != null,
    label: etiqueta,
    onTap: alPresionar,
    excludeSemantics: true,
    child: child,
  );
}
