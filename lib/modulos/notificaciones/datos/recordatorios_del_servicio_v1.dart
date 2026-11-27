import '../../../api/modelos/cita.dart';
import '../../../notificaciones/servicio_notificaciones.dart';
import '../../citas/citas.dart' show CitaAgendada, CitaCliente, EstadoDeCita;
import '../dominio/recordatorios_de_cita.dart';

/// [RecordatoriosDeCita] sobre el servicio de la v1 · V2-M06.06.
///
/// La logica de cuando suena cada recordatorio -24 h y 2 h antes, y nunca uno
/// que ya paso- vive en `recordatorios.dart` y **ya esta probada**. Duplicarla
/// aqui para que hablara de tipos v2 habria sido copiar reglas de negocio,
/// que es la forma de que un dia dejen de coincidir.
///
/// Asi que esto traduce y reusa. La traduccion es barata porque los dos
/// modelos tienen la misma forma; lo unico que cambia de verdad es el `enum`
/// del estado.
class RecordatoriosDelServicioV1 implements RecordatoriosDeCita {
  const RecordatoriosDelServicioV1(this._servicio);

  final ServicioNotificaciones _servicio;

  @override
  Future<void> alConfirmar(CitaAgendada cita, {String? vehiculo}) =>
      _servicio.alAgendar(_deLaConfirmada(cita), vehiculo: vehiculo);

  @override
  Future<void> alAgendar(CitaCliente cita, {String? vehiculo}) =>
      _servicio.alAgendar(_aCitaV1(cita), vehiculo: vehiculo);

  @override
  Future<void> alCancelar(int citaId) => _servicio.alCancelar(citaId);

  @override
  Future<void> sincronizar(List<CitaCliente> citas) =>
      _servicio.sincronizar(citas.map(_aCitaV1).toList());
}

/// La misma cita, en el modelo que entiende el servicio de la v1.
///
/// `motivo` y `recoleccion` se dejan fuera a proposito: el texto del
/// recordatorio solo usa la fecha, la hora y el nombre del vehiculo, y
/// arrastrar lo demas obligaria a traducir dos modelos mas para nada.
Cita _aCitaV1(CitaCliente cita) => Cita(
  id: cita.id,
  vehiculoId: cita.vehiculoId,
  fecha: cita.fecha,
  horaInicio: cita.horaInicio,
  horaFin: cita.horaFin,
  estado: _aEstadoV1(cita.estado),
  franjaId: cita.franjaId,
  vehiculoNombre: cita.vehiculoNombre,
);

/// Lo que no se reconoce cuenta como desconocido, no como confirmada: un
/// estado nuevo del backend no debe programar avisos por accidente.
EstadoCita _aEstadoV1(EstadoDeCita estado) => switch (estado) {
  EstadoDeCita.confirmada => EstadoCita.confirmada,
  EstadoDeCita.atendida => EstadoCita.atendida,
  EstadoDeCita.noAsistio => EstadoCita.noAsistio,
  EstadoDeCita.cancelada => EstadoCita.cancelada,
  EstadoDeCita.desconocido => EstadoCita.desconocido,
};

/// La cita que acaba de confirmar el taller. El estado no viene en el modelo
/// porque confirmada es lo unico que puede ser.
Cita _deLaConfirmada(CitaAgendada cita) => Cita(
  id: cita.id,
  vehiculoId: cita.vehiculoId,
  fecha: cita.fecha,
  horaInicio: cita.horaInicio,
  horaFin: cita.horaFin,
  estado: EstadoCita.confirmada,
);
