import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../config/agencia.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/comprobante_de_cita.dart';
import '../dominio/evento_de_calendario.dart';
import 'proveedores_calendario.dart';

/// Boton «Agregar al calendario» del comprobante (V2-M02.12).
///
/// Arma el evento de la cita (direccion del taller y un recordatorio) y lo
/// entrega al sistema como `.ics`. No pide permisos ni guarda nada: cada toque
/// lo arma de nuevo. Un fallo se muestra en linea y se puede reintentar.
class BotonAgregarAlCalendario extends ConsumerStatefulWidget {
  const BotonAgregarAlCalendario({required this.cita, super.key});

  final ComprobanteDeCita cita;

  @override
  ConsumerState<BotonAgregarAlCalendario> createState() => _EstadoBoton();
}

class _EstadoBoton extends ConsumerState<BotonAgregarAlCalendario> {
  bool _cargando = false;
  bool _fallo = false;

  Future<void> _agregar() async {
    final textos = AppLocalizations.of(context);
    final cita = widget.cita;
    final evento = EventoDeCalendario(
      citaId: cita.citaId,
      fecha: cita.fecha,
      horaInicio: cita.horaInicio,
      horaFin: cita.horaFin,
      titulo: textos.citasCalendarioTitulo,
      // SUPUESTO (V2-M27.02 es de Haziel): hasta que existan las sucursales,
      // la direccion es la de la config de la agencia.
      direccion: Agencia.direccion,
      descripcion: cita.vehiculoNombre == null
          ? null
          : textos.citasCalendarioDescripcion(cita.vehiculoNombre!),
      minutosAntes: minutosAntesDeLaCita,
    );
    setState(() {
      _cargando = true;
      _fallo = false;
    });
    var fallo = false;
    try {
      await ref
          .read(entregaDeEventoProvider)
          .entregar(
            evento.aIcs(creado: DateTime.now().toUtc()),
            citaId: cita.citaId,
          );
    } on Object {
      fallo = true;
    }
    if (!mounted) return;
    setState(() {
      _cargando = false;
      _fallo = fallo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final pildora = BotonPildora(
      texto: textos.citasCalendarioAgregar,
      icono: LucideIcons300.calendar,
      variante: VarianteBotonPildora.vidrio,
      expandido: true,
      alPresionar: _cargando ? null : _agregar,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_cargando)
          Semantics(
            button: true,
            label: textos.botonCargando(textos.citasCalendarioAgregar),
            excludeSemantics: true,
            child: pildora,
          )
        else
          pildora,
        if (_fallo) ...[
          const SizedBox(height: Espaciado.e3),
          Aviso(tono: Tono.advertencia, mensaje: textos.citasCalendarioError),
        ],
      ],
    );
  }
}
