import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grafica.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/estadisticas.dart';
import '../dominio/gasto.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'formato_bitacora.dart';
import 'proveedores_bitacora.dart';

/// Rendimiento y gasto por mes (V2-M18.03).
///
/// Muestra km/l y $/km entre cargas y una gráfica del gasto de los últimos
/// 12 meses con su tabla alternativa para el lector de pantalla. Con menos de
/// dos cargas útiles explica por qué todavía no hay rendimiento.
class PantallaEstadisticas extends ConsumerWidget {
  const PantallaEstadisticas({required this.vehiculoId, super.key});

  final int vehiculoId;

  static const int _mesesEnGrafica = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final gastos = ref.watch(gastosProvider(vehiculoId));

    Widget estado(Widget hijo) => MarcoPantalla.estado(
      titulo: textos.bitacoraEstadisticasTitulo,
      estado: hijo,
    );

    return gastos.when(
      skipLoadingOnReload: true,
      loading: () => estado(
        Semantics(
          label: textos.bitacoraCargando,
          liveRegion: true,
          child: const Padding(
            padding: EdgeInsets.all(Espaciado.e4),
            child: Column(
              children: [
                Esqueleto(alto: 96),
                SizedBox(height: Espaciado.e3),
                Esqueleto(alto: 180),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(gastosProvider(vehiculoId)),
        ),
      ),
      data: (lista) {
        if (lista.isEmpty) {
          return estado(
            EstadoVacio(
              titulo: textos.bitacoraVacioTitulo,
              mensaje: textos.bitacoraVacioMensaje,
              icono: Icons.insights_outlined,
            ),
          );
        }
        return _Estadisticas(gastos: lista);
      },
    );
  }
}

class _Estadisticas extends StatelessWidget {
  const _Estadisticas({required this.gastos});

  final List<Gasto> gastos;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final rendimiento = calcularRendimiento(gastos);
    final meses = gastoPorMes(gastos);
    final recientes = meses.length > PantallaEstadisticas._mesesEnGrafica
        ? meses.sublist(meses.length - PantallaEstadisticas._mesesEnGrafica)
        : meses;
    final cargas = gastos.where((g) => g.esCarga && g.km != null).length;

    return MarcoPantalla(
      titulo: textos.bitacoraEstadisticasTitulo,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SeccionPantalla(
                titulo: textos.bitacoraResumenTitulo,
                hijo: rendimiento == null
                    ? Semantics(
                        container: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              textos.bitacoraSinRendimientoTitulo,
                              style: t.cuerpoFuerte.copyWith(color: c.texto),
                            ),
                            const SizedBox(height: Espaciado.e1),
                            Text(
                              textos.bitacoraSinRendimientoMensaje(cargas),
                              style: t.cuerpo.copyWith(
                                color: c.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TarjetaMetrica(
                            cifra: textos.bitacoraCifraKmPorLitro(
                              numero(
                                context,
                                rendimiento.kmPorLitro,
                                decimales: 1,
                              ),
                            ),
                            etiqueta: textos.bitacoraEtiquetaRendimiento,
                          ),
                          const SizedBox(height: Espaciado.e3),
                          TarjetaMetrica(
                            cifra: textos.bitacoraCifraCostoPorKm(
                              pesos(context, rendimiento.costoPorKm),
                            ),
                            etiqueta: textos.bitacoraEtiquetaCostoPorKm,
                          ),
                          const SizedBox(height: Espaciado.e2),
                          Text(
                            textos.bitacoraBaseDelCalculo(
                              numero(context, rendimiento.kmRecorridos),
                              rendimiento.tramos,
                            ),
                            style: t.cuerpoChico.copyWith(
                              color: c.textoSecundario,
                            ),
                          ),
                        ],
                      ),
              ),
              SeccionPantalla(
                titulo: textos.bitacoraGraficaTitulo,
                hijo: Grafica(
                  titulo: textos.bitacoraGraficaTitulo,
                  mensajeVacio: textos.bitacoraGraficaVacia,
                  formatoValor: (v) => pesos(context, v),
                  puntos: [
                    for (final m in recientes)
                      PuntoGrafica(
                        etiqueta: mesLegible(context, m.mes),
                        valor: m.total,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
