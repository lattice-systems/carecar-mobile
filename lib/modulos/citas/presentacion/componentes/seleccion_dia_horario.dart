import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/componentes/calendario.dart';
import '../../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../dominio/disponibilidad_taller.dart';
import '../../../../nucleo/diseno/componentes/marco_pantalla.dart';

/// Secciones «Día» y «Horario» compartidas por disponibilidad, agendar y
/// reprogramar: calendario en tarjeta redondeada y franjas del día elegido.
///
/// No guarda estado: la pantalla dueña decide qué día, mes y franja hay y
/// qué pasa al elegirlos.
class SeleccionDiaHorario extends StatelessWidget {
  const SeleccionDiaHorario({
    required this.taller,
    required this.rango,
    required this.mes,
    required this.dia,
    required this.franjas,
    required this.franjaSeleccionada,
    required this.alCambiarMes,
    required this.alElegirDia,
    required this.alElegirFranja,
    super.key,
  });

  final DisponibilidadTaller taller;
  final ({DateTime desde, DateTime hasta}) rango;
  final DateTime mes;
  final DateTime? dia;

  /// Franjas del [dia]; vacío mientras no hay día.
  final List<FranjaDisponible> franjas;

  /// Posición en [franjas] de la franja elegida, o nulo.
  final int? franjaSeleccionada;
  final ValueChanged<DateTime> alCambiarMes;
  final ValueChanged<DateTime> alElegirDia;
  final ValueChanged<int> alElegirFranja;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final elegido = dia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeccionPantalla(
          titulo: textos.citasAgendarDia,
          nota: textos.citasNotaDiasSinCupo,
          hijo: DecoratedBox(
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: Radios.bordeTarjeta,
              boxShadow: tokens.sombras,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e3),
              child: Calendario(
                mes: mes,
                seleccionado: elegido,
                primerDia: rango.desde,
                ultimoDia: rango.hasta,
                hoy: rango.desde,
                habilitado: taller.tieneCupo,
                alCambiarMes: alCambiarMes,
                alSeleccionar: alElegirDia,
              ),
            ),
          ),
        ),
        SeccionPantalla(
          titulo: textos.citasAgendarHorario,
          hijo: elegido == null
              ? Text(
                  textos.citasSinDiaElegido,
                  style: t.cuerpo.copyWith(color: c.textoSecundario),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        textos.citasHorariosDelDia(elegido),
                        style: t.cuerpoFuerte.copyWith(color: c.texto),
                      ),
                    ),
                    const SizedBox(height: Espaciado.e2),
                    SelectorFranja(
                      franjas: [
                        for (final f in franjas)
                          FranjaHoraria(etiqueta: f.horaInicio, cupo: f.cupo),
                      ],
                      seleccionada: franjaSeleccionada,
                      mensajeVacio: textos.citasHorariosVacio,
                      alSeleccionar: alElegirFranja,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
