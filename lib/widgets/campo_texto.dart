import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/tema_carecar.dart';

/// Campo de formulario con la etiqueta siempre visible arriba.
///
/// La guia de estilos lo pide asi: «nunca se usa solo el placeholder». Y el
/// texto va siempre a 16 px, porque con menos iOS hace zoom al enfocar.
///
/// Es compartido: lo usan el login y las tres pantallas de APP-2.3.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    required this.llave,
    required this.controlador,
    required this.etiqueta,
    required this.habilitado,
    required this.icono,
    required this.validar,
    super.key,
    this.ayuda,
    this.ocultar = false,
    this.sufijo,
    this.textInputAction,
    this.alEnviar,
    this.teclado,
    this.autocompletar,
    this.formatos,
    this.largoMaximo,
    this.enfocar = false,
  });

  final Key llave;
  final TextEditingController controlador;
  final String etiqueta;
  final String? ayuda;
  final bool habilitado;
  final IconData icono;
  final bool ocultar;
  final Widget? sufijo;
  final TextInputAction? textInputAction;
  final VoidCallback? alEnviar;
  final TextInputType? teclado;
  final List<String>? autocompletar;
  final List<TextInputFormatter>? formatos;
  final int? largoMaximo;
  final String? Function(String?) validar;

  /// Pone el foco en este campo al abrir la pantalla.
  ///
  /// La guia pide «foco en el primer campo que necesita atencion».
  final bool enfocar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          key: llave,
          controller: controlador,
          enabled: habilitado,
          obscureText: ocultar,
          keyboardType: teclado,
          autofillHints: autocompletar,
          inputFormatters: formatos,
          maxLength: largoMaximo,
          autofocus: enfocar,
          textInputAction: textInputAction,
          onFieldSubmitted: alEnviar == null ? null : (_) => alEnviar!(),
          autocorrect: false,
          enableSuggestions: false,
          // Siempre 16: con menos, iOS hace zoom al enfocar el campo.
          style: const TextStyle(fontSize: TemaCareCar.tamanoCampo),
          decoration: InputDecoration(
            hintText: ayuda,
            prefixIcon: Icon(icono, size: 20),
            suffixIcon: sufijo,
            counterText: '',
          ),
          validator: validar,
        ),
      ],
    );
  }
}
