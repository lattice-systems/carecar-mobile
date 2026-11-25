import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/estreno.dart';
import 'proveedores_estreno.dart';

/// Pesos sin centavos; se escriben igual en cualquier idioma.
final pesosEstreno = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

/// Texto de un fallo para el cliente.
String textoDeFalloEstreno(AppLocalizations textos, FalloEstreno fallo) =>
    switch (fallo) {
      EstrenoSinConexion() => textos.estrenoSinConexion,
      EstrenoSinPrecio() => textos.estrenoSinPrecio,
      EstrenoDuplicada() => textos.estrenoDuplicada,
      EstrenoDatosInvalidos(:final mensaje) => mensaje,
      EstrenoNoDisponible() => textos.estrenoNoDisponible,
    };

/// Titulo de seccion de los formularios de estreno.
class SeccionEstreno extends StatelessWidget {
  const SeccionEstreno({required this.titulo, required this.hijo, super.key});

  final String titulo;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Padding(
      padding: const EdgeInsets.only(top: Espaciado.e5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              titulo,
              style: tokens.tipografia.titulo3.copyWith(
                color: tokens.colores.texto,
              ),
            ),
          ),
          const SizedBox(height: Espaciado.e2),
          hijo,
        ],
      ),
    );
  }
}

/// Elegir una estimacion de toma a cuenta o ninguna (V2-M16.03). Si el
/// cliente no tiene estimaciones, no se muestra.
class SelectorEstimacion extends ConsumerWidget {
  const SelectorEstimacion({
    required this.elegida,
    required this.alElegir,
    super.key,
  });

  final int? elegida;
  final ValueChanged<int?> alElegir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final estimaciones = ref.watch(estimacionesParaAdjuntarProvider).value;
    if (estimaciones == null || estimaciones.isEmpty) {
      return const SizedBox.shrink();
    }
    return SeccionEstreno(
      titulo: textos.estrenoTomaACuenta,
      hijo: Wrap(
        spacing: Espaciado.e2,
        runSpacing: Espaciado.e1,
        children: [
          ChipPista(
            texto: textos.estrenoSinTomaACuenta,
            seleccionado: elegida == null,
            alCambiar: (_) => alElegir(null),
          ),
          for (final e in estimaciones)
            ChipPista(
              texto: [
                e.titulo,
                textos.calculadoraRango(
                  pesosEstreno.format(e.minimo),
                  pesosEstreno.format(e.maximo),
                ),
              ].join(' · '),
              seleccionado: elegida == e.id,
              alCambiar: (_) => alElegir(e.id),
            ),
        ],
      ),
    );
  }
}
