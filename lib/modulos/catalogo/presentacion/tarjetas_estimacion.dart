import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/toma_a_cuenta.dart';

/// Los precios son en pesos mexicanos y se escriben igual en cualquier idioma.
final formatoPesos = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

/// Numeros con separador de miles, como el kilometraje.
final formatoMiles = NumberFormat.decimalPattern('es_MX');

/// El rango estimado y los supuestos con que se calculo.
class ResultadoEstimacion extends StatelessWidget {
  const ResultadoEstimacion({required this.estimacion, super.key});

  final Estimacion estimacion;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final e = estimacion;
    final minimo = formatoPesos.format(e.minimo);
    final maximo = formatoPesos.format(e.maximo);

    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TarjetaMetrica(
            etiqueta: t.calculadoraResultadoTitulo,
            cifra: t.calculadoraRango(minimo, maximo),
            tono: Tono.informacion,
            detalle: e.titulo,
          ),
          const SizedBox(height: Espaciado.e2),
          Text(
            t.calculadoraSupuestos(
              e.edadAnios,
              formatoMiles.format(e.kmEsperado),
              e.margenPorcentaje,
            ),
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: tokens.colores.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuanto faltaria pagar por el modelo nuevo (V2-M03.05). Va pegada al
/// resultado y es igual de no vinculante.
class DiferenciaEstimacion extends StatelessWidget {
  const DiferenciaEstimacion({
    required this.modelo,
    required this.precio,
    required this.diferencia,
    super.key,
  });

  final String? modelo;
  final double precio;
  final DiferenciaAPagar diferencia;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final minimo = formatoPesos.format(diferencia.minimo);
    final maximo = formatoPesos.format(diferencia.maximo);

    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TarjetaMetrica(
            etiqueta: t.calculadoraDiferenciaTitulo,
            cifra: diferencia.cubiertaPorElAuto
                ? formatoPesos.format(0)
                : t.calculadoraRango(minimo, maximo),
            detalle: modelo,
          ),
          const SizedBox(height: Espaciado.e2),
          Text(
            diferencia.cubiertaPorElAuto
                ? t.calculadoraDiferenciaCubierta(formatoPesos.format(precio))
                : t.calculadoraDiferenciaExplicacion(
                    formatoPesos.format(precio),
                  ),
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: tokens.colores.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
