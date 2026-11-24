import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Relleno del boton pildora: `lleno` para la accion principal, `tonal` para
/// la secundaria y `peligro` (tonal en rojo) para una accion destructiva como
/// cancelar una cita.
enum VarianteBotonPildora { lleno, tonal, peligro }

/// Boton en forma de pildora, para filas de acciones junto a una portada.
///
/// Con `alPresionar` nulo queda deshabilitado. Con `expandido` ocupa todo el
/// ancho que le den, asi dos botones en un `Row` con `Expanded` se reparten la
/// fila. El texto se parte en varias lineas con letra grande y la altura crece,
/// siempre de al menos 48. Al presionar se encoge con una curva corta; con
/// "reducir movimiento" no se encoge.
class BotonPildora extends StatefulWidget {
  const BotonPildora({
    required this.texto,
    required this.alPresionar,
    super.key,
    this.variante = VarianteBotonPildora.lleno,
    this.icono,
    this.expandido = false,
    this.cargando = false,
  });

  final String texto;
  final VoidCallback? alPresionar;
  final VarianteBotonPildora variante;
  final IconData? icono;
  final bool expandido;

  /// Muestra un indicador en lugar del icono, no responde y lo anuncia.
  final bool cargando;

  @override
  State<BotonPildora> createState() => _BotonPildoraState();
}

class _BotonPildoraState extends State<BotonPildora> {
  bool _presionado = false;

  static const double _escalaPresionado = 0.975;
  static const double _tamanoIcono = 20;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final habilitado = widget.alPresionar != null;
    final alToque = widget.cargando ? null : widget.alPresionar;

    final (fondo, frente) = !habilitado
        ? (c.superficieHundida, c.textoTerciario)
        : switch (widget.variante) {
            VarianteBotonPildora.lleno => (c.acento, c.sobreAcento),
            VarianteBotonPildora.tonal => (c.acentoSuave, c.acento),
            VarianteBotonPildora.peligro => (c.peligroSuave, c.peligro),
          };

    final movimiento = context.movimiento(Movimiento.rapido);
    final reducir = MediaQuery.disableAnimationsOf(context);
    final escala = _presionado && !reducir ? _escalaPresionado : 1.0;

    final contenido = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.cargando) ...[
          SizedBox.square(
            dimension: _tamanoIcono,
            child: CircularProgressIndicator(strokeWidth: 2, color: frente),
          ),
          const SizedBox(width: Espaciado.e2),
        ] else if (widget.icono != null) ...[
          ExcludeSemantics(
            child: Icon(widget.icono, size: _tamanoIcono, color: frente),
          ),
          const SizedBox(width: Espaciado.e2),
        ],
        Flexible(
          child: Text(
            widget.texto,
            textAlign: TextAlign.center,
            style: tokens.tipografia.cuerpoFuerte.copyWith(color: frente),
          ),
        ),
      ],
    );

    final boton = AnimatedScale(
      scale: escala,
      duration: movimiento.duracion,
      curve: movimiento.curva,
      child: Material(
        color: fondo,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alToque,
          splashFactory: NoSplash.splashFactory,
          onHighlightChanged: (v) => setState(() => _presionado = v),
          customBorder: const RoundedRectangleBorder(
            borderRadius: Radios.bordePildora,
          ),
          overlayColor: WidgetStateProperty.resolveWith((e) {
            if (e.contains(WidgetState.pressed)) {
              return frente.withValues(alpha: 0.16);
            }
            if (e.contains(WidgetState.focused) ||
                e.contains(WidgetState.hovered)) {
              return frente.withValues(alpha: 0.10);
            }
            return null;
          }),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Espaciado.objetivoTactilMinimo,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Espaciado.e4,
                vertical: Espaciado.e2,
              ),
              child: Center(widthFactor: 1, child: contenido),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: habilitado && !widget.cargando,
      label: widget.cargando
          ? AppLocalizations.of(context).botonCargando(widget.texto)
          : widget.texto,
      onTap: alToque,
      excludeSemantics: true,
      child: widget.expandido
          ? SizedBox(width: double.infinity, child: boton)
          : boton,
    );
  }
}
