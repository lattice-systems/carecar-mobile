import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Un destino de la [BarraNavegacion].
///
/// `conteo` muestra un globo con el numero de pendientes. El lector de pantalla
/// lo anuncia como "3 pendientes".
class DestinoNavegacion {
  const DestinoNavegacion({
    required this.etiqueta,
    required this.icono,
    this.iconoActivo,
    this.conteo = 0,
  });

  final String etiqueta;
  final IconData icono;
  final IconData? iconoActivo;
  final int conteo;
}

/// Barra inferior del sistema de diseno v2.
///
/// Muestra siempre el icono y la etiqueta, sin ocultar texto en los destinos
/// inactivos. Cada destino mide al menos 48 y avisa su posicion ("Inicio, 1 de
/// 5") y si esta seleccionado. Es controlada: quien la usa guarda `indice`.
class BarraNavegacion extends StatelessWidget {
  const BarraNavegacion({
    required this.destinos,
    required this.indice,
    required this.alCambiar,
    super.key,
  }) : assert(
         destinos.length >= 2 && destinos.length <= 5,
         'Una barra lleva de 2 a 5 destinos',
       );

  final List<DestinoNavegacion> destinos;
  final int indice;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: AppLocalizations.of(context).navegacionPrincipal,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.superficie,
          border: Border(top: BorderSide(color: c.borde)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < destinos.length; i++)
                Expanded(
                  child: _Destino(
                    destino: destinos[i],
                    posicion: i + 1,
                    total: destinos.length,
                    seleccionado: i == indice,
                    alToque: () => alCambiar(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destino extends StatelessWidget {
  const _Destino({
    required this.destino,
    required this.posicion,
    required this.total,
    required this.seleccionado,
    required this.alToque,
  });

  final DestinoNavegacion destino;
  final int posicion;
  final int total;
  final bool seleccionado;
  final VoidCallback alToque;

  static const double _tamanoIcono = 24;
  static const double _anchoPildora = 56;
  static const double _altoPildora = 32;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final mov = context.movimiento(Movimiento.base);
    final color = seleccionado ? c.acento : c.textoSecundario;
    final pendientes = destino.conteo;
    final textos = AppLocalizations.of(context);

    return Semantics(
      button: true,
      selected: seleccionado,
      label: [
        textos.pestanaPosicion(destino.etiqueta, posicion, total),
        if (pendientes > 0) textos.navegacionPendientes(pendientes),
      ].join(', '),
      onTap: alToque,
      excludeSemantics: true,
      child: InkWell(
        onTap: alToque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Espaciado.e2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: mov.duracion,
                      curve: mov.curva,
                      width: _anchoPildora,
                      height: _altoPildora,
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? c.acentoSuave
                            : Colors.transparent,
                        borderRadius: Radios.bordePildora,
                      ),
                      child: Icon(
                        seleccionado
                            ? (destino.iconoActivo ?? destino.icono)
                            : destino.icono,
                        size: _tamanoIcono,
                        color: color,
                      ),
                    ),
                    if (pendientes > 0)
                      Positioned(
                        top: -2,
                        right: 2,
                        child: _Globo(conteo: pendientes),
                      ),
                  ],
                ),
                const SizedBox(height: Espaciado.e1),
                Text(
                  destino.etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.micro.copyWith(
                    color: color,
                    fontWeight: seleccionado ? FontWeight.w700 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Globo extends StatelessWidget {
  const _Globo({required this.conteo});

  final int conteo;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.peligro,
        borderRadius: Radios.bordePildora,
      ),
      child: Text(
        conteo > 99 ? '99+' : '$conteo',
        style: tokens.tipografia.micro.copyWith(color: c.sobreAcento),
      ),
    );
  }
}
