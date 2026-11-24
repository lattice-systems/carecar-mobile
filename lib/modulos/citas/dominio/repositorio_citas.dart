import 'dart:typed_data';

import 'cita_agendada.dart';
import 'cita_cliente.dart';
import 'comprobante_de_cita.dart';
import 'disponibilidad_taller.dart';
import 'motivo_cita.dart';

/// Contrato que la presentacion usa para leer y agendar citas.
abstract interface class RepositorioCitas {
  /// Lo que el taller tiene libre entre `desde` y `hasta`, ambos incluidos.
  Future<DisponibilidadTaller> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  });

  /// Agenda una cita en `franja` para el vehiculo.
  ///
  /// Con `direccionRecoleccionId` pide que recojan y entreguen el auto en esa
  /// direccion guardada (V2-M17.02) y la cita trae los traslados.
  ///
  /// Lanza `FranjaSinCupo` si la franja se lleno, `CitaDuplicada` si el
  /// cliente ya tiene cita ese dia con ese vehiculo y `FueraDeCobertura` si la
  /// direccion de recoleccion ya no esta en la zona.
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
    int? direccionRecoleccionId,
  });

  /// Una página de las citas del cliente, de la más reciente a la más antigua
  /// según el orden del servidor. `pagina` empieza en 0.
  Future<PaginaDeCitas> misCitas({int pagina = 0, int tamano = 20});

  /// Cancela una cita confirmada futura y libera su cupo.
  ///
  /// Lanza `CitaNoModificable` si ya no está confirmada o pasó el plazo.
  Future<CitaCliente> cancelar(int citaId);

  /// Cambia la cita a `franja` y libera la anterior en la misma operación.
  ///
  /// Lanza `FranjaSinCupo` si la franja nueva se llenó y `CitaNoModificable`
  /// si la cita ya no se puede cambiar.
  Future<CitaCliente> reprogramar({
    required int citaId,
    required FranjaDisponible franja,
  });

  /// Comprobante de la cita `citaId`, con el codigo firmado para el QR
  /// (V2-M02.11).
  Future<ComprobanteDeCita> comprobante(int citaId);

  /// Bytes del PDF que entrega `GET /citas/{id}/ticket`.
  Future<Uint8List> ticketPdf(int citaId);
}
