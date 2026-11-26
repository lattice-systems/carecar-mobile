import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/orden_taller.dart';
import 'formato_taller.dart';
import 'pantalla_orden.dart';
import 'proveedores_taller.dart';
import 'rutas_taller.dart';

/// Tarjeta de Inicio que dice que el auto esta en el taller (V2-M04.01). Solo
/// aparece si hay una orden sin entregar; mientras carga, si falla o al
/// entregarse la orden, no ocupa lugar. Al tocarla abre la orden y, al volver,
/// se recarga. Cuando la orden queda lista cambia sola a «Listo» con el total
/// y el horario para recogerlo (V2-M04.06).
class TarjetaOrdenEnCurso extends ConsumerWidget {
  const TarjetaOrdenEnCurso({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordenes = ref.watch(ordenesEnCursoProvider).value ?? const [];
    if (ordenes.isEmpty) return const SizedBox.shrink();
    return Theme(
      data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? TemaPista.oscuro()
          : TemaPista.claro(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: Espaciado.e4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final orden in ordenes)
              Padding(
                padding: const EdgeInsets.only(bottom: Espaciado.e3),
                child: _Tarjeta(
                  orden: orden,
                  alToque: () async {
                    await context.push(rutaOrdenTaller(orden.id));
                    if (context.mounted) ref.invalidate(ordenesEnCursoProvider);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.orden, required this.alToque});

  final OrdenEnCurso orden;
  final VoidCallback alToque;

  static const double _medallon = 44;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final lista = orden.lista;
    final etapa = textoEtapa(textos, orden.etapa);
    final entrega = orden.entregaEstimada;
    final total = orden.totalEstimado;
    final detalles = lista
        ? [
            if (total != null)
              textos.tallerTarjetaListoTotal(monedaTaller(context, total)),
            textoHorarioEntrega(context, orden.horarioEntrega),
          ]
        : [
            entrega == null
                ? etapa
                : textos.tallerTarjetaEtapaYEntrega(
                    etapa,
                    horaTaller(context, entrega),
                  ),
          ];

    return Semantics(
      button: true,
      hint: textos.tallerTarjetaAbrir,
      child: Material(
        color: c.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: Radios.bordeTarjeta,
          side: BorderSide(color: c.borde),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alToque,
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: _medallon,
                  height: _medallon,
                  decoration: BoxDecoration(
                    color: lista ? c.exitoSuave : c.acentoSuave,
                    borderRadius: Radios.bordePildora,
                  ),
                  child: Icon(
                    lista ? LucideIcons300.circleCheck : LucideIcons300.wrench,
                    color: lista ? c.exito : c.acento,
                  ),
                ),
                const SizedBox(width: Espaciado.e3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lista
                            ? textos.tallerTarjetaListoTitulo(orden.vehiculo)
                            : textos.tallerTarjetaTitulo(orden.vehiculo),
                        style: t.cuerpoFuerte.copyWith(color: c.texto),
                      ),
                      for (final detalle in detalles) ...[
                        const SizedBox(height: Espaciado.e1),
                        Text(
                          detalle,
                          style: t.cuerpoChico.copyWith(
                            color: c.textoSecundario,
                          ),
                        ),
                      ],
                      const SizedBox(height: Espaciado.e3),
                      if (lista)
                        Insignia(
                          texto: textos.tallerEtapaListoParaEntrega,
                          tono: Tono.exito,
                          conIcono: true,
                        )
                      else
                        BarraAvance(avance: orden.avance),
                      if (orden.adicionalesPendientes > 0) ...[
                        const SizedBox(height: Espaciado.e3),
                        Insignia(
                          texto: textos.tallerTarjetaPendientes(
                            orden.adicionalesPendientes,
                          ),
                          tono: Tono.advertencia,
                          conIcono: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: Espaciado.e2),
                Icon(LucideIcons300.chevronRight, color: c.textoTerciario),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
