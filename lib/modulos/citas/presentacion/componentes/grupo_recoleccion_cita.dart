import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../recoleccion/recoleccion.dart';

/// Los traslados de recoger y entregar el auto que trae una cita agendada con
/// recolección (V2-M17.02): cuándo llega el chofer, cuándo devuelve el auto y
/// cuánto cuesta en total. Lo usan la confirmación y el comprobante. Tocar un
/// traslado abre su seguimiento (V2-M17.03).
///
/// Cuando el chofer ya dejó su checklist (V2-M17.04) el grupo suma una fila
/// por checklist y, con los dos, una para compararlos. [encabezado] sustituye
/// al título cuando varias citas se listan juntas y hay que distinguirlas.
class GrupoRecoleccionCita extends StatelessWidget {
  const GrupoRecoleccionCita({
    required this.recoleccion,
    super.key,
    this.encabezado,
  });

  final RecoleccionAgendada recoleccion;
  final String? encabezado;

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
      encabezado: encabezado ?? textos.citasResumenRecoleccionEncabezado,
      pie: textos.recoleccionSeguimientoAbrir,
      filas: [
        if (recoger != null)
          FilaGrupo(
            titulo: textos.citasResumenRecogemos,
            subtitulo: ventana(recoger),
            icono: Icons.local_shipping_outlined,
            colorIcono: c.marca,
            alToque: () => context.push(rutaSeguimientoTraslado(recoger.id)),
          ),
        if (entregar != null)
          FilaGrupo(
            titulo: textos.citasResumenEntregamos,
            subtitulo: ventana(entregar),
            icono: Icons.home_outlined,
            colorIcono: c.exito,
            alToque: () => context.push(rutaSeguimientoTraslado(entregar.id)),
          ),
        if (recoger != null && recoger.tieneChecklist)
          FilaGrupo(
            titulo: textos.citasChecklistRecoger,
            subtitulo: textos.citasChecklistSubtitulo,
            icono: Icons.fact_check_outlined,
            colorIcono: c.marca,
            alToque: () => context.push(
              rutaChecklistTraslado(recoger.id, contrario: entregar?.id),
            ),
          ),
        if (entregar != null && entregar.tieneChecklist)
          FilaGrupo(
            titulo: textos.citasChecklistEntregar,
            subtitulo: textos.citasChecklistSubtitulo,
            icono: Icons.fact_check_outlined,
            colorIcono: c.exito,
            alToque: () => context.push(
              rutaChecklistTraslado(
                entregar.id,
                contrario: recoger?.id,
                tipo: TipoTraslado.entregar,
              ),
            ),
          ),
        if (recoger != null &&
            entregar != null &&
            recoger.tieneChecklist &&
            entregar.tieneChecklist)
          FilaGrupo(
            titulo: textos.citasChecklistComparar,
            subtitulo: textos.citasChecklistCompararSubtitulo,
            icono: Icons.compare_outlined,
            colorIcono: c.acento,
            alToque: () => context.push(
              rutaChecklistTraslado(
                recoger.id,
                contrario: entregar.id,
                comparar: true,
              ),
            ),
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
