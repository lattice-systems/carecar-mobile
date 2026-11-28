import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grafica.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/valuacion.dart';
import 'formato_valuacion.dart';
import 'piezas_valuacion.dart';
import 'proveedores_valuacion.dart';
import 'rutas_valuacion.dart';

/// Valor de mi auto (V2-M26.05): una grafica de lineas con el valor estimado
/// medio de cada mes y, debajo, el rango de cada mes. Los meses sin
/// estimacion no se inventan. La leyenda de estimacion no vinculante esta
/// siempre visible. Resuelve cargando, datos, vacio, error y sin conexion.
class PantallaValorVehiculo extends ConsumerWidget {
  const PantallaValorVehiculo({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final proveedor = valorEstimadoProvider(vehiculoId);

    final cuerpo = ref
        .watch(proveedor)
        .when(
          skipLoadingOnReload: true,
          loading: () => const SliverFillRemaining(
            child: EsqueletoValuacion(altos: [220, 160]),
          ),
          error: (error, _) => SliverFillRemaining(
            child: error is NoEncontrado
                ? EstadoVacio(
                    titulo: t.valuacionValorNoEncontradoTitulo,
                    mensaje: t.valuacionValorNoEncontradoMensaje,
                    icono: LucideIcons300.searchX,
                  )
                : ErrorValuacion(
                    error: error,
                    alReintentar: () => ref.invalidate(proveedor),
                  ),
          ),
          data: (puntos) => puntos.isEmpty
              ? SliverFillRemaining(
                  child: EstadoVacio(
                    titulo: t.valuacionValorVacioTitulo,
                    mensaje: t.valuacionValorVacioMensaje,
                    icono: LucideIcons300.chartLine,
                    textoAccion: t.valuacionValorVacioAccion,
                    alAccion: () => context.push(rutaDeLaCalculadora),
                  ),
                )
              : SliverToBoxAdapter(child: _Historial(puntos)),
        );

    return MarcoPantalla(
      icono: LucideIcons300.badgeDollarSign,
      titulo: t.valuacionValorTitulo,
      conRegreso: true,
      alRefrescar: () => ref.refresh(proveedor.future),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e2,
            Espaciado.e4,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Aviso(mensaje: t.calculadoraLeyenda),
          ),
        ),
        cuerpo,
      ],
    );
  }
}

class _Historial extends StatelessWidget {
  const _Historial(this.puntos);

  /// Del mas antiguo al mas reciente, y al menos uno.
  final List<PuntoValorEstimado> puntos;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (puntos.length == 1) ...[
            TarjetaMetrica(
              etiqueta: t.valuacionValorMedio,
              cifra: pesosValuacion(puntos.single.medio),
              detalle: mesValuacion(context, puntos.single.mes),
            ),
            const SizedBox(height: Espaciado.e2),
            Aviso(mensaje: t.valuacionValorUnMes),
          ] else
            SuperficieValuacion(
              hijo: Grafica(
                titulo: t.valuacionValorGrafica,
                tipo: TipoGrafica.lineas,
                formatoValor: pesosValuacion,
                puntos: [
                  for (final p in puntos)
                    PuntoGrafica(
                      etiqueta: mesCortoValuacion(context, p.mes),
                      valor: p.medio,
                    ),
                ],
              ),
            ),
          const SizedBox(height: Espaciado.e5),
          GrupoLista(
            encabezado: t.valuacionValorRangos,
            filas: [
              for (final p in puntos)
                FilaGrupo(
                  titulo: mesValuacion(context, p.mes),
                  subtitulo: t.valuacionValorRangoDelMes(
                    rangoValuacion(t, p.minimo, p.maximo),
                    milesValuacion(p.km),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
