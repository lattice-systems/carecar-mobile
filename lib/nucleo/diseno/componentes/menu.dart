import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Opcion de un [Menu]. Con `peligro` se pinta con el color de peligro.
class ItemMenu<T> {
  const ItemMenu({
    required this.valor,
    required this.texto,
    this.icono,
    this.peligro = false,
    this.habilitado = true,
  });

  final T valor;
  final String texto;
  final IconData? icono;
  final bool peligro;
  final bool habilitado;
}

/// Menu desplegable del sistema de diseno v2.
///
/// `etiqueta` es el texto que lee el lector de pantalla en el disparador. Si no
/// se pasa `disparador` se usa un boton de tres puntos de 48 de zona tactil.
class Menu<T> extends StatelessWidget {
  const Menu({
    required this.items,
    required this.alSeleccionar,
    required this.etiqueta,
    super.key,
    this.disparador,
  });

  final List<ItemMenu<T>> items;
  final ValueChanged<T> alSeleccionar;
  final String etiqueta;
  final Widget? disparador;

  static const double _tamanoIcono = 20;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return PopupMenuButton<T>(
      tooltip: etiqueta,
      onSelected: alSeleccionar,
      color: c.superficieElevada,
      surfaceTintColor: Colors.transparent,
      elevation: tokens.brillo == Brightness.light ? 6 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: Radios.bordeTarjeta,
        side: BorderSide(color: c.borde),
      ),
      constraints: const BoxConstraints(minWidth: 180),
      icon: disparador == null ? Icon(Icons.more_vert, color: c.texto) : null,
      child: disparador == null
          ? null
          : Semantics(
              button: true,
              label: etiqueta,
              excludeSemantics: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(child: disparador),
              ),
            ),
      itemBuilder: (_) => [
        for (final item in items)
          PopupMenuItem<T>(
            value: item.valor,
            enabled: item.habilitado,
            height: 48,
            child: Row(
              children: [
                if (item.icono != null) ...[
                  Icon(
                    item.icono,
                    size: _tamanoIcono,
                    color: _color(item, c.texto, c.peligro, c.textoTerciario),
                  ),
                  const SizedBox(width: Espaciado.e3),
                ],
                Flexible(
                  child: Text(
                    item.texto,
                    style: t.cuerpo.copyWith(
                      color: _color(item, c.texto, c.peligro, c.textoTerciario),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _color(ItemMenu<T> item, Color normal, Color peligro, Color apagado) {
    if (!item.habilitado) return apagado;
    return item.peligro ? peligro : normal;
  }
}
