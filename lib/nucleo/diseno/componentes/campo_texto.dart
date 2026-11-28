import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/tokens_pista.dart';
import 'campo_base.dart';

/// Campo de texto con etiqueta siempre visible.
///
/// Con `error` el borde y el mensaje cambian y se anuncia al lector de
/// pantalla. Con `habilitado` en false no recibe foco.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    required this.etiqueta,
    super.key,
    this.controlador,
    this.sugerencia,
    this.ayuda,
    this.error,
    this.alCambiar,
    this.alEnviar,
    this.teclado,
    this.accionTeclado,
    this.formatos,
    this.pistasAutocompletar,
    this.lineas = 1,
    this.habilitado = true,
    this.ocultarTexto = false,
    this.sufijo,
    this.enfoque,
  });

  final String etiqueta;
  final TextEditingController? controlador;
  final String? sugerencia;
  final String? ayuda;
  final String? error;
  final ValueChanged<String>? alCambiar;
  final ValueChanged<String>? alEnviar;
  final TextInputType? teclado;
  final TextInputAction? accionTeclado;
  final List<TextInputFormatter>? formatos;
  final Iterable<String>? pistasAutocompletar;
  final int lineas;
  final bool habilitado;
  final bool ocultarTexto;
  final Widget? sufijo;
  final FocusNode? enfoque;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;

    return CampoBase(
      etiqueta: etiqueta,
      ayuda: ayuda,
      error: error,
      habilitado: habilitado,
      hijo: TextField(
        controller: controlador,
        focusNode: enfoque,
        enabled: habilitado,
        obscureText: ocultarTexto,
        keyboardType: teclado,
        textInputAction: accionTeclado,
        inputFormatters: formatos,
        autofillHints: pistasAutocompletar,
        minLines: lineas,
        maxLines: ocultarTexto ? 1 : lineas,
        onChanged: alCambiar,
        onSubmitted: alEnviar,
        cursorColor: c.acento,
        style: tokens.tipografia.cuerpo.copyWith(
          color: habilitado ? c.texto : c.textoTerciario,
        ),
        decoration: CampoBase.decoracion(
          context,
          sugerencia: sugerencia,
          conError: error != null,
          sufijo: sufijo,
          pildora: lineas <= 1,
        ),
      ),
    );
  }
}

/// Campo de contrasena con boton para mostrar u ocultar lo escrito.
class CampoContrasena extends StatefulWidget {
  const CampoContrasena({
    required this.etiqueta,
    super.key,
    this.controlador,
    this.sugerencia,
    this.ayuda,
    this.error,
    this.alCambiar,
    this.alEnviar,
    this.accionTeclado,
    this.habilitado = true,
  });

  final String etiqueta;
  final TextEditingController? controlador;

  /// Texto de ejemplo dentro del campo vacío.
  final String? sugerencia;
  final String? ayuda;
  final String? error;
  final ValueChanged<String>? alCambiar;
  final ValueChanged<String>? alEnviar;
  final TextInputAction? accionTeclado;
  final bool habilitado;

  @override
  State<CampoContrasena> createState() => _CampoContrasenaState();
}

class _CampoContrasenaState extends State<CampoContrasena> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return CampoTexto(
      etiqueta: widget.etiqueta,
      controlador: widget.controlador,
      sugerencia: widget.sugerencia,
      ayuda: widget.ayuda,
      error: widget.error,
      alCambiar: widget.alCambiar,
      alEnviar: widget.alEnviar,
      accionTeclado: widget.accionTeclado,
      habilitado: widget.habilitado,
      ocultarTexto: _oculta,
      teclado: TextInputType.visiblePassword,
      pistasAutocompletar: const [AutofillHints.password],
      sufijo: IconButton(
        onPressed: widget.habilitado
            ? () => setState(() => _oculta = !_oculta)
            : null,
        tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(
          _oculta ? LucideIcons300.eye : LucideIcons300.eyeOff,
          color: c.textoSecundario,
        ),
      ),
    );
  }
}
