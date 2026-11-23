import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../recoleccion/recoleccion.dart';

/// Los traslados de recoger y entregar el auto que trae una cita agendada con
/// recolección (V2-M17.02): cuándo llega el chofer, cuándo devuelve el auto y
/// cuánto cuesta en total. Lo usan la confirmación y el comprobante.
class GrupoRecoleccionCita extends StatelessWidget {
  const GrupoRecoleccionCita({required this.recoleccion, super.key});

  final RecoleccionAgendada recoleccion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final recoger = recoleccion.recoger;
    final entregar = recoleccion.entregar;

    String ventana(TrasladoAgendado t) => textos.citasResumenRecoleccionVentana(
      t.fecha,
      t.ventanaInicio,
      t.ventanaFin,
    );

    return GrupoLista(
      encabezado: textos.citasResumenRecoleccionEncabezado,
      filas: [
        if (recoger != null)
          FilaGrupo(
            titulo: textos.citasResumenRecogemos,
            subtitulo: ventana(recoger),
            icono: Icons.local_shipping_outlined,
            colorIcono: c.marca,
          ),
        if (entregar != null)
          FilaGrupo(
            titulo: textos.citasResumenEntregamos,
            subtitulo: ventana(entregar),
            icono: Icons.home_outlined,
            colorIcono: c.exito,
          ),
        FilaGrupo(
          titulo: textos.citasResumenRecoleccionCosto,
          subtitulo: formatearPesos(context, recoleccion.costoTotal),
          icono: Icons.payments_outlined,
          colorIcono: c.advertencia,
        ),
      ],
    );
  }
}
