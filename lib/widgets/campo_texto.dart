import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../nucleo/diseno/componentes/superficie_liquida.dart';
import '../nucleo/diseno/tokens/movimiento.dart';
import '../nucleo/diseno/tokens/radios.dart';
import '../tema/tema_carecar.dart';

/// Campo de formulario estilo cápsula líquida con la etiqueta siempre visible arriba.
///
/// Diseño Telegram / iOS Liquid Glass:
/// - Contenedor en píldora [Radios.bordePildora]
/// - Superficie translúcida vítrea [SuperficieLiquida]
/// - Resplandor de foco cobalto animado
/// - Ícono de prefijo integrado reactivo al foco
/// - Texto siempre a 16 px (evita zoom en iOS)
///
/// Es compartido: lo usan el login y las pantallas de recuperación y cambio.
class CampoTexto extends StatefulWidget {
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
  final bool enfocar;

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  late final FocusNode _nodoFoco;
  bool _conFoco = false;
  FormFieldState<String>? _campoEstado;

  @override
  void initState() {
    super.initState();
    _nodoFoco = FocusNode();
    _nodoFoco.addListener(_alCambiarFoco);
    widget.controlador.addListener(_alCambiarControlador);
  }

  @override
  void dispose() {
    _nodoFoco.removeListener(_alCambiarFoco);
    _nodoFoco.dispose();
    widget.controlador.removeListener(_alCambiarControlador);
    super.dispose();
  }

  void _alCambiarFoco() {
    if (mounted) {
      setState(() => _conFoco = _nodoFoco.hasFocus);
    }
  }

  void _alCambiarControlador() {
    if (_campoEstado != null &&
        _campoEstado!.value != widget.controlador.text) {
      _campoEstado!.didChange(widget.controlador.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return FormField<String>(
      key: widget.llave,
      initialValue: widget.controlador.text,
      validator: widget.validar,
      builder: (FormFieldState<String> field) {
        _campoEstado = field;
        final tieneError = field.hasError;

        final colorFondo = !widget.habilitado
            ? (esOscuro
                  ? const Color(0xFF0F1116).withValues(alpha: 0.5)
                  : const Color(0xFFF0F2F6).withValues(alpha: 0.5))
            : _conFoco
            ? (esOscuro ? const Color(0xFF161A24) : Colors.white)
            : (esOscuro
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF3F5F9));

        final colorBorde = tieneError
            ? const Color(0xFFE54D2E)
            : _conFoco
            ? const Color(0xFF5B8CFF)
            : (esOscuro
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFD4DAE4));

        final colorIcono = tieneError
            ? const Color(0xFFE54D2E)
            : _conFoco
            ? const Color(0xFF5B8CFF)
            : (esOscuro ? const Color(0xFF8E9BAE) : const Color(0xFF6B7280));

        final sombra = tieneError
            ? [
                BoxShadow(
                  color: const Color(0xFFE54D2E).withValues(alpha: 0.22),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : _conFoco
            ? [
                BoxShadow(
                  color: const Color(0xFF2457F5).withValues(alpha: 0.22),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.etiqueta,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: Movimiento.rapido.duracion,
              curve: Movimiento.rapido.curva,
              decoration: BoxDecoration(
                borderRadius: Radios.bordePildora,
                boxShadow: sombra,
              ),
              child: SuperficieLiquida(
                radio: Radios.pildora,
                intensidadDesenfoque: 16,
                opacidad: _conFoco ? 0.92 : 0.82,
                colorFondo: colorFondo,
                colorBorde: colorBorde,
                mostrarBorde: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      Icon(widget.icono, size: 20, color: colorIcono),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: widget.controlador,
                          focusNode: _nodoFoco,
                          enabled: widget.habilitado,
                          obscureText: widget.ocultar,
                          keyboardType: widget.teclado,
                          autofillHints: widget.autocompletar,
                          inputFormatters: widget.formatos,
                          maxLength: widget.largoMaximo,
                          autofocus: widget.enfocar,
                          textInputAction: widget.textInputAction,
                          onSubmitted: widget.alEnviar == null
                              ? null
                              : (_) => widget.alEnviar!(),
                          onChanged: (val) {
                            field.didChange(val);
                            if (tieneError) {
                              field.validate();
                            }
                          },
                          autocorrect: false,
                          enableSuggestions: false,
                          style: TextStyle(
                            fontSize: TemaCareCar.tamanoCampo,
                            color: esOscuro
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.ayuda,
                            hintStyle: TextStyle(
                              fontSize: TemaCareCar.tamanoCampo,
                              color: esOscuro
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                      if (widget.sufijo != null) widget.sufijo!,
                    ],
                  ),
                ),
              ),
            ),
            if (tieneError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Color(0xFFE54D2E),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        field.errorText!,
                        style: const TextStyle(
                          color: Color(0xFFE54D2E),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
