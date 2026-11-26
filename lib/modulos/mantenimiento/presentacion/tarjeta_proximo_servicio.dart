import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../dominio/plan_mantenimiento.dart';
import 'formato_mantenimiento.dart';
import 'proveedores_mantenimiento.dart';
import 'rutas_mantenimiento.dart';

/// El próximo servicio de un auto: qué toca, por qué y cuánto falta (V2-M05.02).
///
/// Es la misma tarjeta en el plan de mantenimiento y en el inicio, así que se
/// lee igual en los dos lugares. Cuando toca por kilometraje lleva una barra
/// con el [avance] desde el último servicio hecho y lo que falta debajo; sin
/// ella (toca por tiempo, o no hay kilometraje vigente) lo que falta va como
/// detalle. Si ya toca, el tono pasa a advertencia. Con [alToque] es un botón
/// con chevron.
class TarjetaProximoServicio extends StatelessWidget {
  const TarjetaProximoServicio({
    required this.proximo,
    super.key,
    this.avance,
    this.alToque,
  });

  final ProximoServicio proximo;

  /// De 0 a 1; ver `PlanMantenimiento.avanceDelProximo`.
  final double? avance;
  final VoidCallback? alToque;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final motivo = switch (proximo.motivo) {
      MotivoProximo.km => textos.mantenimientoMotivoKm,
      MotivoProximo.tiempo => textos.mantenimientoMotivoTiempo,
    };
    final falta = proximo.yaToca
        ? textos.mantenimientoYaToca(formatearKm(context, proximo.kmObjetivo))
        : textos.mantenimientoFaltan(
            formatearKm(context, proximo.faltanKm),
            formatearFecha(context, proximo.fechaEstimada),
          );
    return TarjetaResumen(
      titulo: proximo.nombre,
      subtitulo: motivo,
      detalle: avance == null ? falta : null,
      icono: LucideIcons300.wrench,
      tono: proximo.yaToca ? Tono.advertencia : Tono.informacion,
      progreso: avance,
      etiquetaProgreso: avance == null ? null : falta,
      alToque: alToque,
    );
  }
}

/// Alto de la tarjeta con barra de avance; el esqueleto reserva ese lugar para
/// que el inicio no salte cuando llega el plan.
const double _altoDelEsqueleto = 128;

/// La tarjeta del próximo servicio de [vehiculoId] para el inicio.
///
/// Pide el plan al proveedor del módulo. Mientras carga deja un esqueleto; si
/// falla, el modelo no tiene plan o aún no hay un próximo servicio estimado no
/// ocupa lugar: el inicio no muestra errores de lo que es un extra. Al tocarla
/// abre el plan del auto. Lleva su separación inferior solo cuando se ve.
class TarjetaProximoServicioDelAuto extends ConsumerWidget {
  const TarjetaProximoServicioDelAuto({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planMantenimientoProvider(vehiculoId));
    return plan.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: Espaciado.e4),
        child: Esqueleto(alto: _altoDelEsqueleto, radio: Radios.tarjeta),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (datos) {
        final proximo = datos.proximo;
        if (proximo == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: Espaciado.e4),
          child: TarjetaProximoServicio(
            proximo: proximo,
            avance: datos.avanceDelProximo,
            alToque: () => context.push(rutaMantenimientoVehiculo(vehiculoId)),
          ),
        );
      },
    );
  }
}
