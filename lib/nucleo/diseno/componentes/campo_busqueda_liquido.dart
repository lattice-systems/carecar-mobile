import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'superficie_liquida.dart';

/// Campo de búsqueda en cápsula con acabado translúcido estilo Telegram / iOS.
///
/// Incluye ícono de búsqueda, botón de borrado suave, foco elástico animado
/// y respuesta háptica.
class CampoBusquedaLiquido extends StatefulWidget {
  const CampoBusquedaLiquido({
    required this.sugerencia,
    this.controlador,
    this.alCambiar,
    this.alEnviar,
    this.alLimpiar,
    this.habilitado = true,
    this.autoFoco = false,
    super.key,
  });

  final String sugerencia;
  final TextEditingController? controlador;
  final ValueChanged<String>? alCambiar;
  final ValueChanged<String>? alEnviar;
  final VoidCallback? alLimpiar;
  final bool habilitado;
  final bool autoFoco;

  @override
  State<CampoBusquedaLiquido> createState() => _CampoBusquedaLiquidoState();
}

class _CampoBusquedaLiquidoState extends State<CampoBusquedaLiquido> {
  late final TextEditingController _controladorInterno;
  late final FocusNode _nodoFoco;
  bool _tieneTexto = false;
  bool _conFoco = false;

  TextEditingController get _controladorEfectivo =>
      widget.controlador ?? _controladorInterno;

  @override
  void initState() {
    super.initState();
    if (widget.controlador == null) {
      _controladorInterno = TextEditingController();
    }
    _nodoFoco = FocusNode();
    _nodoFoco.addListener(_alCambiarFoco);
    _tieneTexto = _controladorEfectivo.text.isNotEmpty;
    _controladorEfectivo.addListener(_alCambiarTexto);
  }

  @override
  void dispose() {
    _nodoFoco.removeListener(_alCambiarFoco);
    _nodoFoco.dispose();
    _controladorEfectivo.removeListener(_alCambiarTexto);
    if (widget.controlador == null) {
      _controladorInterno.dispose();
    }
    super.dispose();
  }

  void _alCambiarFoco() {
    if (mounted) {
      setState(() => _conFoco = _nodoFoco.hasFocus);
    }
  }

  void _alCambiarTexto() {
    final nuevoTiene = _controladorEfectivo.text.isNotEmpty;
    if (nuevoTiene != _tieneTexto && mounted) {
      setState(() => _tieneTexto = nuevoTiene);
    }
  }

  void _limpiar() {
    HapticFeedback.lightImpact();
    _controladorEfectivo.clear();
    widget.alCambiar?.call('');
    widget.alLimpiar?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return AnimatedContainer(
      duration: Movimiento.rapido.duracion,
      curve: Movimiento.rapido.curva,
      decoration: BoxDecoration(
        borderRadius: Radios.bordePildora,
        boxShadow: _conFoco
            ? [
                BoxShadow(
                  color: c.acento.withValues(alpha: 0.18),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: SuperficieLiquida(
        radio: Radios.pildora,
        intensidadDesenfoque: 16,
        opacidad: _conFoco ? 0.90 : 0.72,
        colorFondo: _conFoco
            ? c.superficie
            : c.superficieHundida.withValues(alpha: 0.85),
        colorBorde: _conFoco
            ? c.acento.withValues(alpha: 0.6)
            : c.borde.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: Espaciado.e3),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Icon(
                LucideIcons300.search,
                size: 20,
                color: _conFoco ? c.acento : c.textoSecundario,
              ),
              const SizedBox(width: Espaciado.e2),
              Expanded(
                child: TextField(
                  controller: _controladorEfectivo,
                  focusNode: _nodoFoco,
                  enabled: widget.habilitado,
                  autofocus: widget.autoFoco,
                  onChanged: widget.alCambiar,
                  onSubmitted: (v) {
                    HapticFeedback.selectionClick();
                    widget.alEnviar?.call(v);
                  },
                  textInputAction: TextInputAction.search,
                  style: t.cuerpo.copyWith(color: c.texto),
                  decoration: InputDecoration(
                    hintText: widget.sugerencia,
                    hintStyle: t.cuerpo.copyWith(color: c.textoTerciario),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: Espaciado.e2,
                    ),
                  ),
                ),
              ),
              if (_tieneTexto)
                GestureDetector(
                  onTap: _limpiar,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Espaciado.e1),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: c.textoTerciario.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons300.x,
                        size: 14,
                        color: c.textoSecundario,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
