import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../../l10n/app_localizations.dart';
import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'barra_navegacion.dart' show DestinoNavegacion;
import 'rebote_tactil.dart';

/// Barra de navegación inferior flotante, en píldora (rediseño de navegación).
///
/// A diferencia de [BarraNavegacion], que ocupa todo el ancho y se pega al
/// borde, esta flota con margen a los lados y abajo, sobre el contenido, con
/// fondo de vidrio y sombra suave. El destino activo va en una píldora más
/// oscura con icono y etiqueta en el color de acento; los demás, solo icono
/// y etiqueta. Siempre se ve el texto: nunca se
/// esconde en los inactivos.
///
/// Es controlada: quien la usa guarda `indice`. Cada destino mide al menos 48,
/// anuncia su posición («Inicio, 1 de 4») y si está seleccionado. El contenido
/// que quede debajo necesita un margen inferior de [altoReservado] para no
/// quedar tapado.
class BarraFlotante extends StatelessWidget {
  const BarraFlotante({
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

  /// Espacio que ocupa la barra con su margen, sin contar la zona segura.
  static const double altoReservado = 64 + Espaciado.e3 + Espaciado.e4;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: AppLocalizations.of(context).navegacionPrincipal,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          Espaciado.e4,
          0,
          Espaciado.e4,
          Espaciado.e3,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: Radios.bordePildora,
            boxShadow: [
              BoxShadow(
                color: c.texto.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: Radios.bordePildora,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // Sólida: con el vidrio translúcido, las tarjetas azules de debajo
                  // teñían la barra y la pastilla activa casi no se veía.
                  color: c.superficie,
                  borderRadius: Radios.bordePildora,
                  border: Border.all(color: c.borde.withValues(alpha: 0.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Espaciado.e1),
                  child: Row(
                    children: [
                      for (var i = 0; i < destinos.length; i++)
                        Expanded(
                          child: _Destino(
                            destino: destinos[i],
                            posicion: i + 1,
                            total: destinos.length,
                            seleccionado: i == indice,
                            alToque: () {
                              HapticFeedback.selectionClick();
                              alCambiar(i);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final textos = AppLocalizations.of(context);
    final color = seleccionado ? c.acento : c.textoSecundario;
    final pendientes = destino.conteo;

    return Semantics(
      button: true,
      selected: seleccionado,
      label: [
        textos.pestanaPosicion(destino.etiqueta, posicion, total),
        if (pendientes > 0) textos.navegacionPendientes(pendientes),
      ].join(', '),
      onTap: alToque,
      excludeSemantics: true,
      child: ReboteTactil(
        escalaAlPresionar: 0.94,
        // El háptico ya lo dispara alToque con selectionClick.
        activarHaptico: false,
        child: InkWell(
          onTap: alToque,
          borderRadius: Radios.bordePildora,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: Espaciado.e1,
              vertical: Espaciado.e2,
            ),
            decoration: BoxDecoration(
              color: seleccionado ? c.superficieHundida : Colors.transparent,
              borderRadius: Radios.bordePildora,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      seleccionado
                          ? (destino.iconoActivo ?? destino.icono)
                          : destino.icono,
                      size: 22,
                      color: color,
                    ),
                    if (pendientes > 0)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.peligro,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 8, height: 8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Espaciado.e1 / 2),
                Text(
                  destino.etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.micro.copyWith(
                    color: color,
                    fontWeight: seleccionado ? FontWeight.w600 : null,
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
