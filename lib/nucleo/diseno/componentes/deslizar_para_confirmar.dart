import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'boton.dart';
import 'dialogo.dart';

/// Control para acciones que no deben dispararse por error.
///
/// Hay que arrastrar la perilla hasta el final para confirmar. Si se suelta
/// antes de `umbral`, regresa con el resorte del sistema. Con `alConfirmar`
/// nulo queda deshabilitado.
///
/// Con un lector de pantalla activo, o con `forzarAlternativa`, el arrastre se
/// cambia por un [Boton] que pide confirmacion en un [Dialogo], porque deslizar
/// no es un gesto accesible.
class DeslizarParaConfirmar extends StatefulWidget {
  const DeslizarParaConfirmar({
    required this.texto,
    required this.alConfirmar,
    super.key,
    this.peligro = false,
    this.mensajeConfirmacion,
    this.umbral = 0.9,
    this.forzarAlternativa = false,
  }) : assert(umbral > 0 && umbral <= 1, 'El umbral va de 0 a 1');

  final String texto;
  final VoidCallback? alConfirmar;
  final bool peligro;

  /// Texto del dialogo de la alternativa accesible.
  final String? mensajeConfirmacion;

  /// Fraccion del recorrido que confirma, de 0 a 1.
  final double umbral;
  final bool forzarAlternativa;

  @override
  State<DeslizarParaConfirmar> createState() => _DeslizarParaConfirmarState();
}

class _DeslizarParaConfirmarState extends State<DeslizarParaConfirmar>
    with SingleTickerProviderStateMixin {
  static const double _alto = 56;
  static const double _perilla = 48;
  static const double _margen = (_alto - _perilla) / 2;

  late final AnimationController _progreso = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  @override
  void dispose() {
    _progreso.dispose();
    super.dispose();
  }

  bool get _habilitado => widget.alConfirmar != null;

  void _arrastrar(DragUpdateDetails d, double recorrido) {
    if (!_habilitado || recorrido <= 0) return;
    _progreso.stop();
    _progreso.value = (_progreso.value + d.delta.dx / recorrido).clamp(0, 1);
  }

  void _soltar() {
    if (!_habilitado) return;
    final confirmado = _progreso.value >= widget.umbral;
    if (confirmado) widget.alConfirmar!();
    _regresar();
  }

  void _regresar() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _progreso.value = 0;
      return;
    }
    _progreso.animateWith(
      SpringSimulation(Movimiento.resorte, _progreso.value, 0, 0),
    );
  }

  Future<void> _pedirConfirmacion() async {
    final ok = await mostrarDialogo<bool>(
      context,
      builder: (c) => Dialogo(
        titulo: widget.texto,
        mensaje:
            widget.mensajeConfirmacion ??
            AppLocalizations.of(c).deslizarMensajeConfirmacion,
        textoPrincipal: AppLocalizations.of(context).deslizarConfirmar,
        alPrincipal: () => Navigator.of(c).pop(true),
        textoSecundario: AppLocalizations.of(context).deslizarCancelar,
        alSecundario: () => Navigator.of(c).pop(false),
        peligro: widget.peligro,
      ),
    );
    if (ok ?? false) widget.alConfirmar?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forzarAlternativa ||
        MediaQuery.accessibleNavigationOf(context)) {
      return Boton(
        texto: widget.texto,
        variante: widget.peligro
            ? VarianteBoton.peligro
            : VarianteBoton.principal,
        anchoCompleto: true,
        alPresionar: _habilitado ? _pedirConfirmacion : null,
      );
    }

    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final fondo = widget.peligro ? c.peligro : c.acento;
    final apagado = !_habilitado;

    return Semantics(
      container: true,
      label: AppLocalizations.of(context).deslizarEtiqueta(widget.texto),
      enabled: _habilitado,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, caja) {
          final recorrido = caja.maxWidth - _perilla - 2 * _margen;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => _arrastrar(d, recorrido),
            onHorizontalDragEnd: (_) => _soltar(),
            onHorizontalDragCancel: _regresar,
            child: AnimatedBuilder(
              animation: _progreso,
              builder: (context, _) {
                final p = _progreso.value.clamp(0.0, 1.0);
                final avance = p * recorrido;
                return Container(
                  height: _alto,
                  decoration: BoxDecoration(
                    color: c.superficieHundida,
                    borderRadius: Radios.bordePildora,
                    border: Border.all(color: apagado ? c.borde : fondo),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: avance + _perilla + 2 * _margen,
                            decoration: BoxDecoration(
                              color: (apagado ? c.borde : fondo).withValues(
                                alpha: 0.18,
                              ),
                              borderRadius: Radios.bordePildora,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _perilla + Espaciado.e3,
                          ),
                          child: Text(
                            widget.texto,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.cuerpoFuerte.copyWith(
                              color: apagado ? c.textoTerciario : c.texto,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: _margen + avance,
                        child: Container(
                          key: const ValueKey('perilla'),
                          width: _perilla,
                          height: _perilla,
                          decoration: BoxDecoration(
                            color: apagado ? c.textoTerciario : fondo,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons300.chevronRight,
                            color: c.sobreAcento,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
