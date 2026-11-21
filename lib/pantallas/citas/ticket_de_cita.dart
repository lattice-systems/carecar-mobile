import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../api/carecar_api.dart';
import '../../api/modelos/modelos.dart';
import '../../manuales/servicio_manuales.dart';
import '../pantalla_manual.dart';
import 'formato_citas.dart';

/// Baja el ticket de la cita con la API y lo pasa al visor de PDF.
class TicketsDeCita implements ServicioManuales {
  TicketsDeCita(this._api, this._cita);

  final CarecarApi _api;
  final Cita _cita;

  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async {
    final Uint8List bytes = await _api.ticketDeCita(_cita.id);
    return DocumentoManual(
      titulo:
          'Cita del ${formatoFechaLarga(_cita.fecha)} a las ${_cita.horaInicio}',
      identificador: 'ticket-cita:${_cita.id}',
      bytes: bytes,
    );
  }
}

/// Abre el visor con el ticket de la cita y espera a que se cierre.
///
/// Si bajar el ticket falla, el visor muestra su propio aviso de error y el
/// flujo de la cita creada sigue sin romperse.
Future<void> abrirTicketDeCita(
  BuildContext context,
  CarecarApi api,
  Cita cita,
  VoidCallback alCerrarSesion,
) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => PantallaManual(
      // Solo el servicio lo recibe y aqui basta con el id.
      vehiculo: Vehiculo(
        id: cita.vehiculoId,
        vin: '',
        modelo: cita.vehiculoNombre ?? '',
        anio: 0,
      ),
      alCerrarSesion: alCerrarSesion,
      etiqueta: 'Ticket',
      servicio: TicketsDeCita(api, cita),
    ),
  ),
);
