import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/orden_taller.dart';
import 'formato_taller.dart';
import 'proveedores_taller.dart';
import 'rutas_taller.dart';

/// Tarjeta de Inicio que dice que el auto esta en el taller (V2-M04.01). Solo
/// aparece si hay una orden sin entregar; mientras carga, si falla o al
/// entregarse la orden, no ocupa lugar. Al tocarla abre la orden y, al volver,
/// se recarga. Cuando la orden queda lista cambia sola a «Listo» con el total
/// y el horario para recogerlo (V2-M04.06).
///
/// Es la misma [TarjetaResumen] que usan la próxima cita y el próximo
/// servicio, para que las tarjetas del inicio se lean como una sola familia.
/// Cada una lleva su separación inferior, así que el inicio no suma huecos
/// cuando no hay ninguna.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final orden in ordenes)
            Padding(
              padding: const EdgeInsets.only(bottom: Espaciado.e4),
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
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.orden, required this.alToque});

  final OrdenEnCurso orden;
  final VoidCallback alToque;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final lista = orden.lista;
    final entrega = orden.entregaEstimada;
    final total = orden.totalEstimado;
    final pendientes = orden.adicionalesPendientes;
    final etapa = textoEtapa(textos, orden.etapa);

    // Lista: lo que hay que pagar y cuándo recogerlo. En proceso: la etapa con
    // la hora de entrega y, debajo de la barra, el avance. Lo que pide una
    // respuesta del cliente (trabajos por aprobar) va como insignia de alerta.
    return TarjetaResumen(
      titulo: lista
          ? textos.tallerTarjetaListoTitulo(orden.vehiculo)
          : textos.tallerTarjetaTitulo(orden.vehiculo),
      subtitulo: lista
          ? (total == null
                ? null
                : textos.tallerTarjetaListoTotal(monedaTaller(context, total)))
          : (entrega == null
                ? etapa
                : textos.tallerTarjetaEtapaYEntrega(
                    etapa,
                    horaTaller(context, entrega),
                  )),
      detalle: lista
          ? textoHorarioEntrega(context, orden.horarioEntrega)
          : null,
      icono: lista ? LucideIcons300.circleCheck : LucideIcons300.wrench,
      tono: lista ? Tono.exito : Tono.informacion,
      estado: lista
          ? textos.tallerEtapaListoParaEntrega
          : (pendientes > 0
                ? textos.tallerTarjetaPendientes(pendientes)
                : null),
      tonoEstado: lista ? Tono.exito : Tono.advertencia,
      estadoConIcono: true,
      progreso: lista ? null : (orden.avance / 100).clamp(0.0, 1.0),
      etiquetaProgreso: lista ? null : textos.tallerTarjetaAvance(orden.avance),
      pista: textos.tallerTarjetaAbrir,
      alToque: alToque,
    );
  }
}
