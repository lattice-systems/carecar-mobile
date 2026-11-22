// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get catalogoTitulo => 'Catálogo';

  @override
  String get catalogoCargando => 'Cargando catálogo';

  @override
  String get catalogoVacioTitulo => 'Aún no hay modelos';

  @override
  String get catalogoVacioMensaje =>
      'Cuando la agencia publique modelos, los verás aquí.';

  @override
  String get citasAgendarContinuar => 'Revisar y confirmar';

  @override
  String get citasAgendarMotivo => 'Motivo de la visita';

  @override
  String get citasAgendarMotivoSugerencia => 'Elige un motivo';

  @override
  String get citasAgendarSinDatos =>
      'Elige vehículo, día, horario y motivo para continuar.';

  @override
  String get citasAgendarTitulo => 'Agendar cita';

  @override
  String get citasAgendarVehiculo => 'Vehículo';

  @override
  String get citasAgendarVehiculoSugerencia => 'Elige tu vehículo';

  @override
  String get citasCargando => 'Cargando disponibilidad del taller';

  @override
  String get citasCargandoAgendar =>
      'Cargando tus vehículos y los horarios del taller';

  @override
  String get citasConfirmar => 'Confirmar cita';

  @override
  String citasDuplicadaMensaje(DateTime fecha, String inicio, String fin) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Ya tienes una cita el $fechaString de $inicio a $fin. Si necesitas cambiarla, cancélala primero.';
  }

  @override
  String get citasDuplicadaTitulo => 'Ya tienes una cita ese día';

  @override
  String get citasEditar => 'Cambiar datos';

  @override
  String get citasErrorAgendar =>
      'No pudimos agendar tu cita. Intenta de nuevo.';

  @override
  String citasFranjaCercana(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString · $hora';
  }

  @override
  String citasHorariosDelDia(DateTime dia) {
    final intl.DateFormat diaDateFormat = intl.DateFormat.MMMMEEEEd(localeName);
    final String diaString = diaDateFormat.format(dia);

    return 'Horarios del $diaString';
  }

  @override
  String get citasHorariosVacio => 'Este día ya no tiene lugares.';

  @override
  String get citasListoCerrar => 'Listo';

  @override
  String citasListoMensaje(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Te esperamos el $fechaString a las $hora.';
  }

  @override
  String get citasListoTitulo => 'Cita confirmada';

  @override
  String get citasMotivoGarantia => 'Garantía';

  @override
  String get citasMotivoMantenimiento => 'Mantenimiento';

  @override
  String get citasMotivoOtro => 'Otro';

  @override
  String get citasMotivoReparacion => 'Reparación';

  @override
  String get citasMotivoRevision => 'Revisión';

  @override
  String get citasNotaDiasSinCupo =>
      'Los días tachados no tienen lugares disponibles.';

  @override
  String get citasResumenFecha => 'Día';

  @override
  String get citasResumenHorario => 'Horario';

  @override
  String citasResumenHorarioValor(String inicio, String fin) {
    return '$inicio a $fin';
  }

  @override
  String get citasResumenMotivo => 'Motivo';

  @override
  String get citasResumenTitulo => 'Resumen de tu cita';

  @override
  String get citasResumenVehiculo => 'Vehículo';

  @override
  String get citasSinCupoMensaje =>
      'Alguien la tomó mientras decidías. Estas opciones están cerca:';

  @override
  String get citasSinCupoNinguna =>
      'Por ahora no hay otros horarios cercanos. Elige otro día.';

  @override
  String get citasSinCupoTitulo => 'Ese horario ya no tiene lugar';

  @override
  String get citasSinDiaElegido => 'Elige un día para ver sus horarios.';

  @override
  String get citasSinVehiculosMensaje =>
      'La agencia registra tu auto cuando te lo entrega. Después podrás agendar aquí.';

  @override
  String get citasSinVehiculosTitulo => 'Aún no tienes vehículos';

  @override
  String get citasTitulo => 'Disponibilidad del taller';

  @override
  String get citasVacioMensaje =>
      'Por ahora el taller no tiene lugares en los próximos días. Vuelve a revisar pronto.';

  @override
  String get citasVacioTitulo => 'Sin lugares disponibles';

  @override
  String precioDesde(String precio) {
    return 'Desde $precio';
  }

  @override
  String fotoDeModelo(String modelo) {
    return 'Foto del $modelo';
  }

  @override
  String get vehiculosAccesoFicha => 'Ficha técnica';

  @override
  String get vehiculosAccesoHistorial => 'Historial de servicios';

  @override
  String get vehiculosAccesoManuales => 'Manuales';

  @override
  String get vehiculosAccesoPronto => 'Disponible pronto';

  @override
  String get vehiculosAnio => 'Año';

  @override
  String get vehiculosCargando => 'Cargando tu garaje';

  @override
  String get vehiculosColor => 'Color';

  @override
  String get vehiculosCopiarVin => 'Copiar VIN';

  @override
  String get vehiculosDetalleTitulo => 'Detalle del vehículo';

  @override
  String get vehiculosKilometraje => 'Kilometraje';

  @override
  String vehiculosKilometros(String km) {
    return '$km km';
  }

  @override
  String vehiculosKmActualizado(String fecha) {
    return 'Actualizado por el taller el $fecha';
  }

  @override
  String get vehiculosKmSinActualizar => 'Aún sin actualización del taller';

  @override
  String get vehiculosKmSinDato => 'Sin kilometraje registrado';

  @override
  String get vehiculosNoEncontradoMensaje =>
      'Ese vehículo ya no está en tu garaje. Vuelve al garaje para elegir otro.';

  @override
  String get vehiculosNoEncontradoTitulo => 'No encontramos el vehículo';

  @override
  String vehiculosPlacas(String placas) {
    return 'Placas $placas';
  }

  @override
  String get vehiculosPlacasEtiqueta => 'Placas';

  @override
  String get vehiculosSinPlacas => 'Sin placas';

  @override
  String get vehiculosTitulo => 'Mi garaje';

  @override
  String get vehiculosVacioMensaje =>
      'La agencia registra tus autos al entregártelos. Cuando lo haga, aparecerán aquí.';

  @override
  String get vehiculosVacioTitulo => 'Aún no tienes vehículos';

  @override
  String get vehiculosVersion => 'Versión';

  @override
  String get vehiculosVin => 'VIN';

  @override
  String get vehiculosVinCopiado => 'VIN copiado';
}
