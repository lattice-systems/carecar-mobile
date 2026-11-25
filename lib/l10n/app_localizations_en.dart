// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String accesoBloqueoMinutos(int minutos) {
    return 'Wait $minutos min before trying again.';
  }

  @override
  String accesoBloqueoSegundos(int segundos) {
    return 'Wait $segundos s before trying again.';
  }

  @override
  String get accesoBloqueoTitulo => 'Too many attempts';

  @override
  String get accesoContrasenaEtiqueta => 'Password';

  @override
  String get accesoContrasenaVacia => 'Enter your password.';

  @override
  String get accesoCorreoAyuda => 'The one you gave the dealership';

  @override
  String get accesoCorreoEtiqueta => 'Email';

  @override
  String get accesoCorreoInvalido =>
      'Enter a valid email, like name@domain.com.';

  @override
  String get accesoCorreoVacio => 'Enter your email.';

  @override
  String get accesoEntrando => 'Signing in…';

  @override
  String get accesoEntrar => 'Sign in';

  @override
  String get accesoFalloTitulo => 'We couldn\'t sign you in';

  @override
  String get accesoMarca => 'CareCar';

  @override
  String get accesoOlvide => 'Forgot your password?';

  @override
  String get accesoServidorDespertandoMensaje =>
      'The first time after a while it can take up to a minute.';

  @override
  String get accesoServidorDespertandoTitulo => 'Waking up the server…';

  @override
  String get accesoSinConexionTitulo => 'No connection';

  @override
  String get accesoSinRegistro =>
      'The dealership gives you your access when you pick up your vehicle. If you don\'t have it, get in touch with them.';

  @override
  String get accesoSubtitulo => 'Your access to the dealership';

  @override
  String get asistenciaGuiaChoquePaso1 =>
      'Stop the car in a safe place, turn off the engine and switch on the hazard lights.';

  @override
  String get asistenciaGuiaChoquePaso2 =>
      'Check for injured people. If there are any, call 911 right away and do not move anyone with neck or back pain.';

  @override
  String get asistenciaGuiaChoquePaso3 =>
      'If you can, get out and stand behind a barrier, away from traffic. Set out the warning triangles.';

  @override
  String get asistenciaGuiaChoquePaso4 =>
      'Call your insurer and wait for the adjuster. Do not accept or sign agreements with the other driver without them.';

  @override
  String get asistenciaGuiaChoquePaso5 =>
      'Take photos of the vehicles, plates, damage and the place. Write down the other driver\'s name, phone and insurance details.';

  @override
  String get asistenciaGuiaChoquePaso6 =>
      'Do not move the car until the authorities or the adjuster allow it, unless it blocks the road and it is safe to move.';

  @override
  String get asistenciaGuiaChoqueResumen =>
      'Steps to look after everyone and protect your claim.';

  @override
  String get asistenciaGuiaChoqueTitulo => 'What to do after a crash';

  @override
  String get asistenciaGuiaCorrientePaso1 =>
      'Park the other car facing yours, without touching. Turn off both engines and all accessories.';

  @override
  String get asistenciaGuiaCorrientePaso2 =>
      'Connect a red clamp to the positive (+) terminal of your dead battery and the other end to the positive terminal of the car giving the charge.';

  @override
  String get asistenciaGuiaCorrientePaso3 =>
      'Connect a black clamp to the negative (−) terminal of the good battery and the other end to an unpainted metal part of your engine, away from the battery.';

  @override
  String get asistenciaGuiaCorrientePaso4 =>
      'Start the car giving the charge and let it run for a few minutes.';

  @override
  String get asistenciaGuiaCorrientePaso5 =>
      'Try to start your car. If it does not start, wait a few more minutes and try again.';

  @override
  String get asistenciaGuiaCorrientePaso6 =>
      'Remove the clamps in reverse order, without letting them touch, and keep your car running for at least 20 minutes.';

  @override
  String get asistenciaGuiaCorrienteResumen =>
      'How to start your car with cables from another vehicle.';

  @override
  String get asistenciaGuiaCorrienteTitulo => 'Jump-start the battery';

  @override
  String get asistenciaGuiaLlantaPaso1 =>
      'Park on flat, firm ground, set the parking brake and switch on the hazard lights.';

  @override
  String get asistenciaGuiaLlantaPaso2 =>
      'Take out the spare tire, the jack and the lug wrench. Slightly loosen the nuts of the flat tire without removing them.';

  @override
  String get asistenciaGuiaLlantaPaso3 =>
      'Place the jack at the point shown in the manual and lift the car until the tire is off the ground.';

  @override
  String get asistenciaGuiaLlantaPaso4 =>
      'Remove the nuts and the flat tire. Mount the spare and tighten the nuts by hand.';

  @override
  String get asistenciaGuiaLlantaPaso5 =>
      'Lower the car, tighten the nuts in a star pattern with the wrench and check the pressure as soon as you can.';

  @override
  String get asistenciaGuiaLlantaResumen =>
      'Swap it for the spare in a few steps.';

  @override
  String get asistenciaGuiaLlantaTitulo => 'Change a tire';

  @override
  String asistenciaGuiaPasoNumero(int numero, int total) {
    return 'Step $numero of $total';
  }

  @override
  String get asistenciaListaTitulo => 'Emergencies';

  @override
  String get asistenciaHeroeTitulo => 'Need help right now?';

  @override
  String get asistenciaHeroeTexto =>
      'Asking for help with your location will be available soon. Meanwhile, these guides tell you what to do.';

  @override
  String get asistenciaHeroeAccion => 'Ask for help';

  @override
  String get asistenciaEstanteGuias => 'Quick guides';

  @override
  String get asistenciaGrupoGuias => 'All guides';

  @override
  String asistenciaGuiaCantidadPasos(int pasos) {
    return '$pasos steps';
  }

  @override
  String asistenciaGuiaSubtituloSinConexion(int pasos) {
    return '$pasos steps · offline';
  }

  @override
  String get asistenciaGuiasAvisoSinConexion =>
      'These guides are stored in the app and work offline.';

  @override
  String get asistenciaGuiasTitulo => 'Emergency guides';

  @override
  String get catalogoTitulo => 'Catalog';

  @override
  String get catalogoCargando => 'Loading catalog';

  @override
  String get catalogoVacioTitulo => 'No models yet';

  @override
  String get catalogoVacioMensaje =>
      'When the dealership publishes models, you\'ll see them here.';

  @override
  String get citasAgendarContinuar => 'Review and confirm';

  @override
  String get citasAgendarMotivo => 'Reason for the visit';

  @override
  String get citasAgendarMotivoSugerencia => 'Pick a reason';

  @override
  String get citasAgendarSinDatos =>
      'Pick a vehicle, day, time and reason to continue.';

  @override
  String get citasAgendarTitulo => 'Book an appointment';

  @override
  String get citasAgendarVehiculo => 'Vehicle';

  @override
  String get citasAgendarVehiculoSugerencia => 'Pick your vehicle';

  @override
  String get citasCancelada =>
      'Appointment cancelled. The time slot is free again.';

  @override
  String get citasCancelar => 'Cancel appointment';

  @override
  String get citasCancelarConfirmar => 'Yes, cancel';

  @override
  String citasCancelarDialogoMensaje(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Your appointment on $fechaString at $hora will be cancelled and the time slot will be freed for others.';
  }

  @override
  String get citasCancelarDialogoTitulo => 'Cancel this appointment?';

  @override
  String get citasCancelarError =>
      'We could not cancel your appointment. Try again.';

  @override
  String get citasCancelarMantener => 'Keep appointment';

  @override
  String get citasCancelarNoDisponible =>
      'This appointment can no longer be cancelled.';

  @override
  String get citasCargando => 'Loading workshop availability';

  @override
  String get citasCargandoAgendar =>
      'Loading your vehicles and the workshop times';

  @override
  String get citasComprobanteCargando => 'Loading your confirmation';

  @override
  String citasComprobanteCuando(DateTime fecha, String inicio, String fin) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString, from $inicio to $fin';
  }

  @override
  String citasComprobanteFolio(int id) {
    return 'Reference $id';
  }

  @override
  String get citasComprobanteIndicacion =>
      'Show this code at reception to check in.';

  @override
  String get citasComprobanteQrDescripcion =>
      'QR code of your appointment for reception';

  @override
  String get citasComprobanteTitulo => 'Appointment confirmation';

  @override
  String get citasComprobanteVerPdf => 'View confirmation as PDF';

  @override
  String get citasComprobanteVerPdfDescripcion =>
      'PDF confirmation of your appointment';

  @override
  String get citasCargarMas => 'Load more appointments';

  @override
  String get citasConfirmar => 'Confirm appointment';

  @override
  String citasDuplicadaMensaje(DateTime fecha, String inicio, String fin) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'You already have an appointment on $fechaString from $inicio to $fin. To change it, cancel it first.';
  }

  @override
  String get citasDuplicadaTitulo => 'You already have an appointment that day';

  @override
  String get citasEditar => 'Change details';

  @override
  String get citasErrorAgendar =>
      'We could not book your appointment. Try again.';

  @override
  String get citasErrorMas => 'We could not load more appointments. Try again.';

  @override
  String get citasEstadoAtendida => 'Attended';

  @override
  String get citasEstadoCancelada => 'Cancelled';

  @override
  String get citasEstadoConfirmada => 'Confirmed';

  @override
  String get citasEstadoDesconocido => 'No status';

  @override
  String get citasEstadoNoAsistio => 'No-show';

  @override
  String citasFilaTitulo(DateTime fecha, String inicio) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString · $inicio';
  }

  @override
  String get citasFilaVehiculoGenerico => 'Your vehicle';

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

    return 'Times for $diaString';
  }

  @override
  String get citasHorariosVacio => 'This day has no spots left.';

  @override
  String get citasListoCerrar => 'Done';

  @override
  String citasListoMensaje(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'We will see you on $fechaString at $hora.';
  }

  @override
  String get citasListoTitulo => 'Appointment confirmed';

  @override
  String get citasListoVerComprobante => 'View confirmation';

  @override
  String get citasMisCitasAgendar => 'Book an appointment';

  @override
  String get citasMisCitasCargando => 'Loading your appointments';

  @override
  String get citasMisCitasTitulo => 'My appointments';

  @override
  String get citasMisCitasVacioMensaje =>
      'When you book an appointment it will show up here with its status.';

  @override
  String get citasMisCitasVacioTitulo => 'You have no appointments yet';

  @override
  String get citasMotivoGarantia => 'Warranty';

  @override
  String get citasMotivoMantenimiento => 'Maintenance';

  @override
  String get citasMotivoOtro => 'Other';

  @override
  String get citasMotivoReparacion => 'Repair';

  @override
  String get citasMotivoRevision => 'Inspection';

  @override
  String get citasNotaDiasSinCupo =>
      'Crossed-out days have no spots available.';

  @override
  String get citasPasadas => 'Past';

  @override
  String get citasPasadasVacio => 'You have no past appointments yet.';

  @override
  String get citasProximas => 'Upcoming';

  @override
  String get citasProximasVacio => 'You have no upcoming appointments.';

  @override
  String get citasReprogramar => 'Reschedule';

  @override
  String citasReprogramarActual(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Your current appointment: $fechaString · $hora';
  }

  @override
  String get citasReprogramarCargando =>
      'Loading your appointment and the workshop times';

  @override
  String get citasReprogramarConfirmar => 'Move to this time';

  @override
  String get citasReprogramarError =>
      'We could not reschedule your appointment. Try again.';

  @override
  String citasReprogramarListo(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Appointment moved to $fechaString at $hora. The previous time slot is free again.';
  }

  @override
  String get citasReprogramarNoDisponible =>
      'This appointment can no longer be changed.';

  @override
  String get citasReprogramarNoEncontradaMensaje =>
      'It may no longer be available to change.';

  @override
  String get citasReprogramarNoEncontradaTitulo =>
      'We could not find this appointment';

  @override
  String get citasReprogramarSinFranja =>
      'Pick a new day and time to continue.';

  @override
  String get citasReprogramarTitulo => 'Reschedule appointment';

  @override
  String get citasResumenFecha => 'Day';

  @override
  String get citasResumenHorario => 'Time';

  @override
  String citasResumenHorarioValor(String inicio, String fin) {
    return '$inicio to $fin';
  }

  @override
  String get citasResumenMotivo => 'Reason';

  @override
  String get citasResumenTitulo => 'Your appointment summary';

  @override
  String get citasResumenVehiculo => 'Vehicle';

  @override
  String get citasSinCupoMensaje =>
      'Someone took it while you were deciding. These are close by:';

  @override
  String get citasSinCupoNinguna =>
      'There are no other close times right now. Pick another day.';

  @override
  String get citasSinCupoTitulo => 'That time has no spots left';

  @override
  String get citasSinDiaElegido => 'Pick a day to see its times.';

  @override
  String get citasSinVehiculosMensaje =>
      'The dealership registers your car when it hands it over. You will be able to book here afterwards.';

  @override
  String get citasSinVehiculosTitulo => 'You have no vehicles yet';

  @override
  String get citasTitulo => 'Workshop availability';

  @override
  String get citasVacioMensaje =>
      'The workshop has no spots in the coming days. Check back soon.';

  @override
  String get citasVacioTitulo => 'No spots available';

  @override
  String get mantenimientoAcceso => 'Maintenance';

  @override
  String get mantenimientoAgendar => 'Book this service';

  @override
  String get mantenimientoCargando => 'Loading your maintenance plan';

  @override
  String get mantenimientoCargandoServicio => 'Loading the service';

  @override
  String get mantenimientoCerrar => 'Close';

  @override
  String get mantenimientoDescripcionPortada =>
      'Illustration of a service wrench';

  @override
  String get mantenimientoEncabezadoConceptos => 'What is included';

  @override
  String get mantenimientoEncabezadoKm => 'Your mileage';

  @override
  String get mantenimientoEncabezadoPlan => 'Service plan';

  @override
  String get mantenimientoEstadoHecho => 'Done';

  @override
  String get mantenimientoEstadoPendiente => 'Pending';

  @override
  String get mantenimientoEstadoProximo => 'Next';

  @override
  String get mantenimientoEstadoVencido => 'Overdue';

  @override
  String mantenimientoFaltan(String km, String fecha) {
    return '$km km to go · around $fecha';
  }

  @override
  String mantenimientoHechoEl(String fecha) {
    return 'Done on $fecha';
  }

  @override
  String mantenimientoKilometros(String km) {
    return '$km km';
  }

  @override
  String mantenimientoKmAyuda(String km) {
    return 'Your last reading: $km km';
  }

  @override
  String get mantenimientoKmAyudaSinRegistro =>
      'Enter the number your dashboard shows.';

  @override
  String get mantenimientoKmCampo => 'Current mileage';

  @override
  String mantenimientoKmDelCliente(String fecha) {
    return 'Logged by you on $fecha';
  }

  @override
  String mantenimientoKmDelTaller(String fecha) {
    return 'Logged by the workshop on $fecha';
  }

  @override
  String get mantenimientoKmErrorFormato =>
      'Use whole numbers greater than zero.';

  @override
  String mantenimientoKmErrorMenor(String km) {
    return 'It cannot be lower than $km km, the last one we have.';
  }

  @override
  String get mantenimientoKmErrorRed =>
      'We could not save your mileage. Check your connection and try again.';

  @override
  String get mantenimientoKmErrorServidor =>
      'That mileage is lower than the last one logged. Check your dashboard.';

  @override
  String get mantenimientoKmErrorVacio => 'Enter your mileage.';

  @override
  String get mantenimientoKmGuardado =>
      'Mileage saved. We updated your next service.';

  @override
  String get mantenimientoKmGuardando => 'Saving mileage';

  @override
  String get mantenimientoKmGuardar => 'Save mileage';

  @override
  String get mantenimientoKmNota =>
      'The mileage the workshop logs is the official one: your entry does not replace it.';

  @override
  String get mantenimientoKmSinDato => 'Not logged';

  @override
  String get mantenimientoKmSinFuente => 'There is no reading for your car yet';

  @override
  String get mantenimientoKmTitulo => 'Log mileage';

  @override
  String get mantenimientoMotivoKm => 'Due by mileage';

  @override
  String get mantenimientoMotivoTiempo => 'Due by elapsed time';

  @override
  String get mantenimientoPrecioEtiqueta => 'Estimated price';

  @override
  String get mantenimientoPrecioLeyenda => 'Non-binding estimate';

  @override
  String mantenimientoPromedio(String km) {
    return 'Average: $km km per day';
  }

  @override
  String get mantenimientoRegistrarKm => 'Log mileage';

  @override
  String mantenimientoResumenServicio(String km, String meses) {
    return '$km km · $meses months';
  }

  @override
  String get mantenimientoServicioNoEncontradoMensaje =>
      'The plan may have changed. Go back to the plan and try again.';

  @override
  String get mantenimientoServicioNoEncontradoTitulo =>
      'We could not find this service';

  @override
  String get mantenimientoSinConceptos => 'This service has no detailed items.';

  @override
  String get mantenimientoSinProximoMensaje =>
      'Log your mileage to estimate when your next service is due.';

  @override
  String get mantenimientoSinProximoTitulo => 'No next service estimated';

  @override
  String get mantenimientoTitulo => 'Maintenance';

  @override
  String get mantenimientoVacioMensaje =>
      'We do not have the service plan for this model yet. Ask your advisor at the dealership.';

  @override
  String get mantenimientoVacioTitulo => 'There is no plan for your car yet';

  @override
  String mantenimientoYaToca(String km) {
    return 'Due now · past $km km';
  }

  @override
  String precioDesde(String precio) {
    return 'From $precio';
  }

  @override
  String fotoDeModelo(String modelo) {
    return 'Photo of the $modelo';
  }

  @override
  String get vehiculosAccesoFicha => 'Technical specs';

  @override
  String get vehiculosAccesoHistorial => 'Service history';

  @override
  String get vehiculosAccesoManuales => 'Manuals';

  @override
  String get vehiculosAccesoPronto => 'Coming soon';

  @override
  String get vehiculosAnio => 'Year';

  @override
  String get vehiculosCargando => 'Loading your garage';

  @override
  String get vehiculosColor => 'Color';

  @override
  String get vehiculosCopiarVin => 'Copy VIN';

  @override
  String get vehiculosDetalleTitulo => 'Vehicle details';

  @override
  String get vehiculosFichaCargando => 'Loading the specifications';

  @override
  String get vehiculosFichaClaveCarroceria => 'Body';

  @override
  String get vehiculosFichaClaveMotor => 'Engine';

  @override
  String get vehiculosFichaClavePasajeros => 'Passengers';

  @override
  String get vehiculosFichaClavePotencia => 'Power';

  @override
  String get vehiculosFichaClavePropulsion => 'Fuel';

  @override
  String get vehiculosFichaClaveTraccion => 'Drive';

  @override
  String get vehiculosFichaClaveTransmision => 'Transmission';

  @override
  String get vehiculosFichaNota =>
      'Model and year data. The exact specifications of your unit are in its manual.';

  @override
  String get vehiculosFichaRespaldo =>
      'Showing the specifications saved in the app';

  @override
  String get vehiculosFichaSeccionGeneral => 'General';

  @override
  String get vehiculosFichaSeccionMotor => 'Engine';

  @override
  String get vehiculosFichaSeccionTransmision => 'Transmission';

  @override
  String get vehiculosFichaTitulo => 'Specifications';

  @override
  String get vehiculosFichaVacioMensaje =>
      'We do not have the specifications for this model and year yet. The dealership will publish them soon.';

  @override
  String get vehiculosFichaVacioTitulo => 'No specifications';

  @override
  String get vehiculosKilometraje => 'Mileage';

  @override
  String vehiculosKilometros(String km) {
    return '$km km';
  }

  @override
  String vehiculosKmActualizado(String fecha) {
    return 'Updated by the workshop on $fecha';
  }

  @override
  String get vehiculosKmSinActualizar => 'Not updated by the workshop yet';

  @override
  String get vehiculosKmSinDato => 'No mileage recorded';

  @override
  String get vehiculosManualCargando => 'Loading the manual';

  @override
  String get vehiculosManualCompartir => 'Share manual';

  @override
  String get vehiculosManualDescargar => 'Download manual';

  @override
  String vehiculosManualDescripcion(String vehiculo) {
    return 'Manual of $vehiculo';
  }

  @override
  String get vehiculosManualGuardado => 'Manual saved';

  @override
  String get vehiculosManualGuardadoError =>
      'We could not save the manual. Please try again.';

  @override
  String get vehiculosManualTitulo => 'Manual';

  @override
  String get vehiculosManualVacioMensaje =>
      'We do not have the manual for this model and year yet. The dealership will publish it soon.';

  @override
  String get vehiculosManualVacioTitulo => 'Manual not available';

  @override
  String get vehiculosNoEncontradoMensaje =>
      'That vehicle is no longer in your garage. Go back to your garage to pick another.';

  @override
  String get vehiculosNoEncontradoTitulo => 'We could not find the vehicle';

  @override
  String vehiculosPlacas(String placas) {
    return 'Plates $placas';
  }

  @override
  String get vehiculosPlacasEtiqueta => 'Plates';

  @override
  String get vehiculosSinPlacas => 'No plates';

  @override
  String get vehiculosTitulo => 'My garage';

  @override
  String get vehiculosVacioMensaje =>
      'The dealership registers your cars when it hands them over. Once it does, they will show up here.';

  @override
  String get vehiculosVacioTitulo => 'You have no vehicles yet';

  @override
  String get vehiculosVersion => 'Trim';

  @override
  String get vehiculosVin => 'VIN';

  @override
  String get vehiculosVinCopiado => 'VIN copied';

  @override
  String get widgetsAccesoAgendar => 'Book appointment';

  @override
  String get widgetsAccesoMiAuto => 'My car';

  @override
  String get widgetsAccesoSos => 'SOS';

  @override
  String get avisoCerrar => 'Close notice';

  @override
  String get navegacionPrincipal => 'Main navigation';

  @override
  String botonCargando(String texto) {
    return '$texto, loading';
  }

  @override
  String get estanteVerTodo => 'See all';

  @override
  String estanteVerTodoDe(String titulo) {
    return 'See all: $titulo';
  }

  @override
  String calendarioDelMes(DateTime mes) {
    final intl.DateFormat mesDateFormat = intl.DateFormat.yMMMM(localeName);
    final String mesString = mesDateFormat.format(mes);

    return 'Calendar for $mesString';
  }

  @override
  String calendarioTituloMes(DateTime mes) {
    final intl.DateFormat mesDateFormat = intl.DateFormat.yMMMM(localeName);
    final String mesString = mesDateFormat.format(mes);

    return '$mesString';
  }

  @override
  String get calendarioMesAnterior => 'Previous month';

  @override
  String get calendarioMesSiguiente => 'Next month';

  @override
  String calendarioDia(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString';
  }

  @override
  String get calendarioHoy => 'today';

  @override
  String get calendarioSeleccionado => 'selected';

  @override
  String get calendarioSinCupo => 'fully booked';

  @override
  String get calendarioInicialesDias => 'M,T,W,T,F,S,S';

  @override
  String get deslizarConfirmar => 'Confirm';

  @override
  String get deslizarCancelar => 'Cancel';

  @override
  String deslizarEtiqueta(String texto) {
    return '$texto, slide to confirm';
  }

  @override
  String firmaSinFirma(String firmante) {
    return 'No signature from $firmante';
  }

  @override
  String firmaDe(String pie) {
    return 'Signature of $pie';
  }

  @override
  String get firmaAunSinFirma => 'Not signed yet';

  @override
  String galeriaEtiqueta(int actual, int total) {
    return 'Photo gallery, $actual of $total';
  }

  @override
  String galeriaContador(int actual, int total) {
    return '$actual of $total';
  }

  @override
  String get galeriaFotoAnterior => 'Previous photo';

  @override
  String get galeriaFotoSiguiente => 'Next photo';

  @override
  String get galeriaCerrarFoto => 'Close photo';

  @override
  String get graficaSinDatos => 'There is no data to show yet.';

  @override
  String get graficaVerGrafica => 'View chart';

  @override
  String get graficaVerTabla => 'View as table';

  @override
  String graficaPunto(String etiqueta, String valor) {
    return '$etiqueta: $valor';
  }

  @override
  String get lineaPasoHecho => 'completed';

  @override
  String get lineaPasoActual => 'in progress';

  @override
  String get lineaPasoPendiente => 'pending';

  @override
  String get lineaVerMas => 'See more';

  @override
  String lineaEtapa(int posicion, int total) {
    return 'Stage $posicion of $total';
  }

  @override
  String pestanaPosicion(String texto, int posicion, int total) {
    return '$texto, $posicion of $total';
  }

  @override
  String get franjasSinHorarios => 'There are no time slots for this day.';

  @override
  String get franjasDisponibles => 'Available times';

  @override
  String pdfPagina(int pagina, int total) {
    return 'Page $pagina of $total';
  }

  @override
  String get pdfCargando => 'Loading document';

  @override
  String comparacionEtiqueta(String antes, String despues) {
    return 'Comparison. $antes versus $despues';
  }

  @override
  String comparacionValor(int porcentaje) {
    return '$porcentaje % of the before';
  }

  @override
  String comparacionPorcentaje(int porcentaje) {
    return '$porcentaje %';
  }

  @override
  String navegacionPendientes(int conteo) {
    return '$conteo pending';
  }

  @override
  String franjaSinCupo(String hora) {
    return '$hora · fully booked';
  }

  @override
  String franjaConCupo(String hora, int cupo) {
    String _temp0 = intl.Intl.pluralLogic(
      cupo,
      locale: localeName,
      other: '$cupo spots',
      one: '1 spot',
    );
    return '$hora · $_temp0';
  }

  @override
  String get galeriaAmpliar => 'Enlarge';

  @override
  String get galeriaSinFotos => 'There are no photos yet.';

  @override
  String get deslizarMensajeConfirmacion =>
      'Confirm that you want to continue.';

  @override
  String get historialCargandoMas => 'Loading more services';

  @override
  String historialCerradaEl(String fecha) {
    return 'Closed on $fecha';
  }

  @override
  String get historialErrorMas => 'We couldn\'t load more services.';

  @override
  String get historialEstatusEnProceso => 'In progress';

  @override
  String get historialEstatusEntregado => 'Delivered';

  @override
  String get historialEstatusOtro => 'No status';

  @override
  String get historialEstatusRecibido => 'Received';

  @override
  String get historialEstatusTerminado => 'Finished';

  @override
  String historialEstatusYCierre(String estatus, String cierre) {
    return '$estatus · $cierre';
  }

  @override
  String get historialFiltroEtiqueta => 'Filter by year';

  @override
  String get historialFiltroTodos => 'All';

  @override
  String get historialReintentar => 'Try again';

  @override
  String get historialSinCierre => 'Open order';

  @override
  String historialTicketCantidadPorPrecio(int cantidad, String precio) {
    return '$cantidad × $precio';
  }

  @override
  String get historialTicketCierre => 'Closing date';

  @override
  String get historialTicketCompartir => 'Share PDF';

  @override
  String get historialTicketCompartirError =>
      'We couldn\'t download the PDF. Please try again.';

  @override
  String get historialTicketFecha => 'Service date';

  @override
  String get historialTicketIva => 'VAT';

  @override
  String get historialTicketKilometraje => 'Mileage';

  @override
  String historialTicketKilometrajeValor(String km) {
    return '$km km';
  }

  @override
  String get historialTicketManoDeObra => 'Labor';

  @override
  String get historialTicketNoCuadra =>
      'The amounts on this ticket don\'t add up. Ask the dealership to review it.';

  @override
  String get historialTicketPreciosConIva => 'Prices include VAT.';

  @override
  String get historialTicketRefacciones => 'Parts';

  @override
  String get historialTicketSinRenglones => 'No items';

  @override
  String get historialTicketSubtotal => 'Subtotal before VAT';

  @override
  String get historialTicketTitulo => 'Ticket';

  @override
  String get historialTicketTotal => 'Total';

  @override
  String get historialTicketTotales => 'Totals';

  @override
  String get historialTitulo => 'History';

  @override
  String historialVacioAnioMensaje(String anio) {
    return 'There are no services in $anio.';
  }

  @override
  String get historialVacioMensaje =>
      'When the shop closes an order for this car, it will show up here.';

  @override
  String get historialVacioTitulo => 'No services yet';

  @override
  String get idiomaEtiqueta => 'Language';

  @override
  String get idiomaSistema => 'Automatic (system language)';

  @override
  String get idiomaEspanol => 'Español';

  @override
  String get idiomaIngles => 'English';

  @override
  String get catalogoDetalleTitulo => 'Model details';

  @override
  String get catalogoDetalleCargando => 'Loading the model';

  @override
  String get catalogoNoEncontradoTitulo => 'We could not find the model';

  @override
  String get catalogoNoEncontradoMensaje =>
      'The dealership may no longer offer it. Go back to the catalog to see the current models.';

  @override
  String get catalogoGaleria => 'Gallery';

  @override
  String get catalogoVersiones => 'Trims';

  @override
  String get catalogoVersionActual => 'The one you are viewing';

  @override
  String get catalogoFicha => 'Specifications';

  @override
  String get catalogoSinPrecio => 'Price to be confirmed';

  @override
  String catalogoFotoDe(String modelo, int numero) {
    return '$modelo, photo $numero';
  }

  @override
  String catalogoFotoDeColor(String modelo, String color, int numero) {
    return '$modelo, $color, photo $numero';
  }

  @override
  String get catalogoComparar => 'Compare models';

  @override
  String get catalogoSalirDeComparar => 'Exit compare mode';

  @override
  String catalogoCompararElegidos(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Compare $cantidad models',
      one: 'Pick one more model',
      zero: 'Pick 2 or 3 models',
    );
    return '$_temp0';
  }

  @override
  String catalogoCompararModelo(String modelo) {
    return 'Compare $modelo';
  }

  @override
  String get catalogoComparadorTitulo => 'Compare models';

  @override
  String get catalogoComparadorCargando => 'Loading the comparison';

  @override
  String get catalogoComparadorIdsMalosTitulo => 'Pick two or three models';

  @override
  String get catalogoComparadorIdsMalosMensaje =>
      'Go back to the catalog, turn on compare and tick the models you want to see side by side.';

  @override
  String get catalogoComparadorPrecio => 'Price from';

  @override
  String get catalogoComparadorSinDato => 'No data';

  @override
  String get catalogoComparadorMasBajo => 'Lowest price';

  @override
  String catalogoComparadorCelda(String dato, String modelo, String valor) {
    return '$dato, $modelo: $valor';
  }

  @override
  String get catalogoCalcularTomaACuenta => 'Estimate my trade-in';

  @override
  String get calculadoraTitulo => 'Trade-in';

  @override
  String get calculadoraLeyenda =>
      'Non-binding estimate. This is not a purchase offer: the dealership sets the final value after inspecting your car.';

  @override
  String calculadoraContra(String modelo) {
    return 'Toward: $modelo';
  }

  @override
  String get calculadoraAuto => 'Your car';

  @override
  String get calculadoraOtroAuto => 'Another car';

  @override
  String get calculadoraCargandoAutos => 'Loading your cars';

  @override
  String get calculadoraMarca => 'Make';

  @override
  String get calculadoraModelo => 'Model';

  @override
  String get calculadoraAnio => 'Year';

  @override
  String get calculadoraKm => 'Mileage';

  @override
  String get calculadoraKmAyuda =>
      'In kilometers, as the dashboard shows today';

  @override
  String get calculadoraEstado => 'Overall condition';

  @override
  String get calculadoraEstadoExcelente => 'Excellent';

  @override
  String get calculadoraEstadoBueno => 'Good';

  @override
  String get calculadoraEstadoRegular => 'Fair';

  @override
  String get calculadoraEstadoMalo => 'Poor';

  @override
  String get calculadoraCalcular => 'Calculate estimate';

  @override
  String get calculadoraErrorMarca => 'Enter the make';

  @override
  String get calculadoraErrorModelo => 'Enter the model';

  @override
  String calculadoraErrorAnio(int maximo) {
    return 'Enter a four-digit year, from 1900 to $maximo';
  }

  @override
  String get calculadoraErrorKm => 'Enter a mileage from 0 to 999,999';

  @override
  String get calculadoraResultadoTitulo => 'Trade-in estimate';

  @override
  String calculadoraRango(String minimo, String maximo) {
    return '$minimo to $maximo';
  }

  @override
  String calculadoraRangoLector(String minimo, String maximo) {
    return 'Between $minimo and $maximo';
  }

  @override
  String calculadoraSupuestos(int edad, String km, int margen) {
    String _temp0 = intl.Intl.pluralLogic(
      edad,
      locale: localeName,
      other: 'a $edad-year-old car',
      one: 'a 1-year-old car',
      zero: 'a car from this year',
    );
    return 'Calculated for $_temp0, with $km km expected for that age and a margin of plus or minus $margen %.';
  }

  @override
  String get calculadoraSinParametrosTitulo =>
      'We cannot estimate that car yet';

  @override
  String get calculadoraSinParametrosMensaje =>
      'The dealership does not have data for that make, model and year yet. Ask for a formal appraisal at the dealership.';

  @override
  String get calculadoraErrorDatos =>
      'We could not calculate the estimate. Check the data and try again.';

  @override
  String get calculadoraErrorSinConexion =>
      'No connection. Connect and try again.';

  @override
  String get calculadoraErrorNoEncontrado =>
      'We could not find that car or model. Go back and try again.';

  @override
  String get calculadoraErrorGenerico =>
      'Something went wrong while calculating. Try again in a moment.';

  @override
  String get calculadoraDiferenciaTitulo => 'Amount left to pay';

  @override
  String calculadoraDiferenciaExplicacion(String precio) {
    return 'It is the list price, $precio, minus the estimated range for your car. It is also a non-binding estimate.';
  }

  @override
  String calculadoraDiferenciaCubierta(String precio) {
    return 'What your car could be worth would cover the list price, $precio. This is a non-binding estimate.';
  }

  @override
  String get misEstimacionesTitulo => 'My estimates';

  @override
  String get misEstimacionesCargando => 'Loading your estimates';

  @override
  String get misEstimacionesVacioTitulo => 'You have no estimates yet';

  @override
  String get misEstimacionesVacioMensaje =>
      'When you estimate what your car would be worth as a trade-in, you will see it here.';

  @override
  String get misEstimacionesVacioAccion => 'Calculate an estimate';

  @override
  String misEstimacionesFila(DateTime fecha, String rango) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.yMMMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString, $rango';
  }

  @override
  String get misEstimacionesVerMas => 'Show more';

  @override
  String get misEstimacionesErrorMas =>
      'We could not load more estimates. Try again.';

  @override
  String get widgetsProximaCitaTitulo => 'Next appointment';

  @override
  String widgetsProximaCitaFecha(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString';
  }

  @override
  String widgetsProximaCitaHorario(String inicio, String fin) {
    return '$inicio to $fin';
  }

  @override
  String get widgetsSinCitaMensaje => 'You have no upcoming appointments';

  @override
  String get widgetsTallerTitulo => 'Your car at the workshop';

  @override
  String widgetsTallerEntrega(String hora) {
    return 'Estimated pickup: $hora';
  }

  @override
  String get widgetsAgendar => 'Book';

  @override
  String get widgetsTallerEncabezado => 'Live workshop';

  @override
  String get widgetsTallerVacioMensaje => 'Your car is not at the workshop';

  @override
  String widgetsTallerPaso(int actual, int total) {
    return 'Step $actual of $total';
  }

  @override
  String get widgetsMantenimientoTitulo => 'Maintenance';

  @override
  String widgetsMantenimientoFaltanKm(String km) {
    return '$km km to go';
  }

  @override
  String get widgetsMantenimientoYaToca => 'Due now';

  @override
  String widgetsMantenimientoFecha(String fecha) {
    return 'Around $fecha';
  }

  @override
  String get widgetsMantenimientoVacioMensaje =>
      'There is no plan for your car yet';

  @override
  String get widgetsMantenimientoAccion => 'View plan';

  @override
  String get widgetsBitacoraTitulo => 'Logbook';

  @override
  String get widgetsBitacoraRendimientoUnidad => 'km/l';

  @override
  String widgetsBitacoraGastoMes(String mes) {
    return '$mes spending';
  }

  @override
  String get widgetsBitacoraRendimientoEtiqueta => 'Fuel economy';

  @override
  String get widgetsBitacoraVacioMensaje => 'Log your first fill-up';

  @override
  String get widgetsBitacoraAccion => 'Log it';

  @override
  String get widgetsAccesosTitulo => 'Quick actions';

  @override
  String get widgetsAccesoComprobante => 'Receipt';

  @override
  String get citasWalletAgregar => 'Add to Wallet';

  @override
  String get citasWalletErrorGenerico =>
      'We could not prepare your pass. Try again.';

  @override
  String get citasWalletErrorSinConexion =>
      'No connection. Check your network and try again.';

  @override
  String get citasWalletErrorCancelada =>
      'Your appointment is cancelled, so it no longer has a pass.';

  @override
  String get citasWalletErrorNoDisponible =>
      'The Wallet pass is not available right now. Show the QR code at reception.';

  @override
  String get citasAgendarDia => 'Day';

  @override
  String get citasAgendarHorario => 'Time';

  @override
  String get citasMisCitasProximaEtiqueta => 'Your next appointment';

  @override
  String get citasHeroComprobante => 'Receipt';

  @override
  String get citasAccionesCita => 'Appointment options';

  @override
  String get regresar => 'Back';

  @override
  String get citasCerrar => 'Close';

  @override
  String get citasComprobanteDetalles => 'Appointment details';

  @override
  String get citasComprobanteRecepcion => 'At reception';

  @override
  String get vehiculosAgendarServicio => 'Book';

  @override
  String get vehiculosBotonManual => 'Manual';

  @override
  String get vehiculosBotonDescargar => 'Download';

  @override
  String get vehiculosBotonCompartir => 'Share';

  @override
  String get vehiculosVerDetalle => 'View details';

  @override
  String get vehiculosEncabezadoDatos => 'Details';

  @override
  String get vehiculosEncabezadoTuAuto => 'Your car';

  @override
  String get vehiculosEncabezadoRapidos => 'Quick facts';

  @override
  String get vehiculosToqueCopiarVin => 'Tap to copy';

  @override
  String get recoleccionCerrar => 'Close';

  @override
  String get recoleccionDireccionesTitulo => 'My addresses';

  @override
  String get recoleccionDireccionesAgregar => 'Add address';

  @override
  String get recoleccionDireccionesCargando => 'Loading your addresses';

  @override
  String get recoleccionDireccionesVacioTitulo => 'You have no addresses yet';

  @override
  String get recoleccionDireccionesVacioMensaje =>
      'Save one so we can pick up your car without typing it every time.';

  @override
  String get recoleccionDireccionesEncabezado => 'Saved';

  @override
  String get recoleccionDireccionesPie => 'Tap one to edit or delete it.';

  @override
  String recoleccionDireccionEditar(String alias) {
    return 'Edit $alias';
  }

  @override
  String get recoleccionDireccionBorrada => 'Address deleted';

  @override
  String get recoleccionFormNuevaTitulo => 'New address';

  @override
  String get recoleccionFormEditarTitulo => 'Edit address';

  @override
  String get recoleccionFormUbicacionTitulo => 'Location on the map';

  @override
  String get recoleccionFormPinAyuda =>
      'Tap the map to drop the pin where we will pick up your car.';

  @override
  String get recoleccionFormPinFalta => 'Drop the pin on the map.';

  @override
  String recoleccionFormMapaDescripcion(String latitud, String longitud) {
    return 'Map to choose the location. Pin at $latitud, $longitud.';
  }

  @override
  String get recoleccionFormMapaSinPin =>
      'Map to choose the location. There is no pin yet.';

  @override
  String get recoleccionFormUsarUbicacion => 'Use my location';

  @override
  String get recoleccionFormBuscarEtiqueta => 'Search address';

  @override
  String get recoleccionFormBuscarSugerencia =>
      'Street, number and neighborhood';

  @override
  String get recoleccionFormBuscarAccion => 'Search';

  @override
  String get recoleccionFormBuscando => 'Looking up the address';

  @override
  String get recoleccionFormAliasEtiqueta => 'Name';

  @override
  String get recoleccionFormAliasSugerencia => 'Home, office…';

  @override
  String get recoleccionFormCalleEtiqueta => 'Street and number';

  @override
  String get recoleccionFormColoniaEtiqueta => 'Neighborhood';

  @override
  String get recoleccionFormCpEtiqueta => 'Postal code';

  @override
  String get recoleccionFormCiudadEtiqueta => 'City';

  @override
  String get recoleccionErrorAlias => 'Enter a name of up to 40 characters.';

  @override
  String get recoleccionErrorCalle =>
      'Enter the street and number, up to 120 characters.';

  @override
  String get recoleccionErrorColonia =>
      'Enter the neighborhood, up to 80 characters.';

  @override
  String get recoleccionErrorCp => 'The postal code has 5 digits.';

  @override
  String get recoleccionErrorCiudad => 'Enter the city, up to 80 characters.';

  @override
  String get recoleccionGuardar => 'Save address';

  @override
  String get recoleccionBorrar => 'Delete address';

  @override
  String get recoleccionBorrarTitulo => 'Delete this address?';

  @override
  String recoleccionBorrarMensaje(String alias) {
    return '“$alias” will be deleted. This can\'t be undone.';
  }

  @override
  String get recoleccionBorrarConfirmar => 'Delete';

  @override
  String get recoleccionBorrarCancelar => 'Cancel';

  @override
  String get recoleccionErrorEnUso =>
      'This address already has pick-ups and can\'t be deleted.';

  @override
  String get recoleccionCoberturaTitulo => 'Outside our coverage area';

  @override
  String get recoleccionCoberturaMensaje =>
      'We don\'t pick up cars in that area yet. Move the pin or choose another address.';

  @override
  String get recoleccionErrorGuardar =>
      'We couldn\'t save the address. Try again.';

  @override
  String get recoleccionErrorBorrar =>
      'We couldn\'t delete the address. Try again.';

  @override
  String get recoleccionErrorSinConexion =>
      'No connection. Check your network and try again.';

  @override
  String get recoleccionUbicacionDenegada =>
      'We need your permission to use your location. You can also drop the pin by hand.';

  @override
  String get recoleccionUbicacionApagada =>
      'Turn on your phone\'s location or drop the pin by hand.';

  @override
  String get recoleccionUbicacionTiempo =>
      'We couldn\'t find you in time. Try again or drop the pin by hand.';

  @override
  String get recoleccionBusquedaSinResultados =>
      'We couldn\'t find that address. Try another or drop the pin by hand.';

  @override
  String get recoleccionBusquedaError =>
      'We couldn\'t look up the address. Drop the pin by hand.';

  @override
  String get recoleccionSelectorTitulo =>
      'How does your car get to the workshop?';

  @override
  String get recoleccionSelectorLoLlevo => 'I\'ll bring it';

  @override
  String get recoleccionSelectorQueRecojan => 'Pick up my car';

  @override
  String get recoleccionSelectorDireccion => 'Pick-up address';

  @override
  String get recoleccionSelectorAdministrar => 'Manage my addresses';

  @override
  String get recoleccionSelectorSinDirecciones =>
      'You have no saved addresses yet.';

  @override
  String get recoleccionSelectorElegirDia =>
      'Choose a day and time to quote the pick-up.';

  @override
  String get recoleccionSelectorElegirDireccion =>
      'Choose an address to see the cost.';

  @override
  String get recoleccionSelectorCotizando => 'Calculating the pick-up cost';

  @override
  String get recoleccionSelectorElegida => 'Selected';

  @override
  String get recoleccionCotizacionEncabezado => 'Cost and time';

  @override
  String get recoleccionCotizacionRecogemos => 'We pick up your car';

  @override
  String get recoleccionCotizacionEntregamos => 'We bring it back';

  @override
  String get recoleccionCotizacionPorTraslado => 'Each trip';

  @override
  String get recoleccionCotizacionTotal => 'Pick-up total';

  @override
  String recoleccionCotizacionVentana(
    DateTime fecha,
    String inicio,
    String fin,
  ) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString, $inicio to $fin';
  }

  @override
  String get recoleccionCotizacionErrorTitulo =>
      'We couldn\'t quote the pick-up';

  @override
  String get recoleccionCotizacionErrorMensaje =>
      'Check your connection and try again. Meanwhile you can bring the car yourself.';

  @override
  String get recoleccionCotizacionReintentar => 'Try again';

  @override
  String get recoleccionCotizacionFueraDeCobertura =>
      'That address is outside our coverage area. Choose another or bring the car yourself.';

  @override
  String get citasResumenRecoleccion => 'Pick-up';

  @override
  String citasResumenRecoleccionValor(String alias, String direccion) {
    return '$alias · $direccion';
  }

  @override
  String get citasResumenRecogemos => 'We pick up your car';

  @override
  String get citasResumenEntregamos => 'We bring it back';

  @override
  String citasResumenRecoleccionVentana(
    DateTime fecha,
    String inicio,
    String fin,
  ) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString, $inicio to $fin';
  }

  @override
  String get citasResumenRecoleccionCosto => 'Pick-up cost';

  @override
  String get citasResumenRecoleccionEncabezado => 'Home pick-up';

  @override
  String get citasErrorCobertura =>
      'That address is no longer in our coverage area. Choose another or bring the car yourself.';

  @override
  String get citasErrorRecoleccion =>
      'We couldn\'t find that address. Choose another and try again.';

  @override
  String get asistenciaHeroeTextoDisponible =>
      'Tell us what happened and share your location so the agency can find you. While help arrives, these guides tell you what to do.';

  @override
  String get asistenciaPedirTitulo => 'Ask for help';

  @override
  String get asistenciaPedirCargando => 'Loading';

  @override
  String get asistenciaPedirVehiculoEncabezado => 'Which vehicle needs help?';

  @override
  String get asistenciaPedirSeleccionado => 'Selected';

  @override
  String get asistenciaPedirTipoEncabezado => 'What happened?';

  @override
  String get asistenciaTipoLlanta => 'Flat tire';

  @override
  String get asistenciaTipoBateria => 'Battery';

  @override
  String get asistenciaTipoChoque => 'Crash';

  @override
  String get asistenciaTipoSinGasolina => 'Out of fuel';

  @override
  String get asistenciaTipoOtro => 'Other';

  @override
  String get asistenciaUbicacionEncabezado => 'Your location';

  @override
  String get asistenciaUbicacionCompartir => 'Share my location';

  @override
  String get asistenciaUbicacionExplicacion =>
      'The agency will know where you are. It is sent once, with the app open, and it is not used again when help ends.';

  @override
  String get asistenciaUbicacionObteniendo => 'Finding your location…';

  @override
  String get asistenciaUbicacionLista => 'Location ready to send';

  @override
  String get asistenciaUbicacionPermisoDenegado =>
      'Location permission was not granted. You can try again or send the request without a location and write where you are.';

  @override
  String get asistenciaUbicacionPermisoBloqueado =>
      'Location permission is blocked. Turn it on in Settings or send the request without a location and write where you are.';

  @override
  String get asistenciaUbicacionServicioApagado =>
      'Location services are off. Turn them on or send the request without a location and write where you are.';

  @override
  String get asistenciaUbicacionTiempoAgotado =>
      'We could not find you in time. Try again or send the request without a location and write where you are.';

  @override
  String get asistenciaUbicacionReintentar => 'Try again';

  @override
  String get asistenciaUbicacionSinUbicacion => 'Send without location';

  @override
  String get asistenciaComentarioEtiqueta => 'Comment (optional)';

  @override
  String get asistenciaComentarioEtiquetaSinUbicacion =>
      'Where you are and what happened';

  @override
  String get asistenciaComentarioAyuda => '500 characters at most';

  @override
  String get asistenciaConfirmarTexto => 'Slide to ask for help';

  @override
  String get asistenciaEnviando => 'Sending your request…';

  @override
  String get asistenciaErrorSinConexion =>
      'No connection: we could not send your request. If it is urgent, call 911 or your insurer.';

  @override
  String get asistenciaErrorEnviar =>
      'We could not send your request. Try again.';

  @override
  String get asistenciaErrorVehiculo =>
      'We could not find that vehicle. Choose another and try again.';

  @override
  String get asistenciaGarajeVacioTitulo => 'You have no vehicles yet';

  @override
  String get asistenciaGarajeVacioMensaje =>
      'To ask for help we need to know which vehicle it is. Ask the agency to register yours.';

  @override
  String asistenciaSolicitudFolio(int id) {
    return 'Reference $id';
  }

  @override
  String get asistenciaSolicitudRecibida => 'Request received';

  @override
  String get asistenciaSolicitudTexto =>
      'The agency knows you need help. Keep your phone with you and stay somewhere safe.';

  @override
  String get asistenciaSolicitudYaAbierta =>
      'You already had an open request. It is shown here.';

  @override
  String get asistenciaSolicitudVehiculo => 'Vehicle';

  @override
  String get asistenciaSolicitudProblema => 'Problem';

  @override
  String get asistenciaSolicitudUbicacion => 'Location';

  @override
  String get asistenciaSolicitudUbicacionCompartida => 'Shared with the agency';

  @override
  String get asistenciaSolicitudUbicacionNoCompartida => 'Not shared';

  @override
  String get asistenciaSolicitudComentario => 'Comment';

  @override
  String get asistenciaSolicitudPrivacidad =>
      'Your location is only shared while the request is open.';

  @override
  String get asistenciaSolicitudVerGuias => 'See emergency guides';

  @override
  String get seguridadEquipoComprometidoTitulo => 'This device looks modified';

  @override
  String get seguridadEquipoComprometidoMensaje =>
      'You can keep using CareCar, but for your safety we do not store your data on this device. Offline, you will not see saved information.';

  @override
  String get asistenteTitulo => 'Ask your car';

  @override
  String get asistenteAvisoIa =>
      'Answers generated by AI from your car\'s manual. If something is wrong with your car, talk to your advisor.';

  @override
  String get asistenteVacioTitulo => 'What do you want to know about your car?';

  @override
  String get asistenteVacioMensaje =>
      'I answer from your car\'s manual and tell you which page says it.';

  @override
  String get asistenteSugerencia => 'Type your question';

  @override
  String get asistenteEnviar => 'Send';

  @override
  String get asistenteTu => 'You';

  @override
  String get asistenteNombre => 'CareCar';

  @override
  String get asistentePensando => 'Searching your manual…';

  @override
  String get asistenteNoSeEnvio => 'Not sent';

  @override
  String get asistenteReintentar => 'Retry';

  @override
  String get asistenteSinConexion =>
      'I couldn\'t connect. Check your internet and try again.';

  @override
  String get asistenteNoDisponible =>
      'The assistant isn\'t available right now. Try later or ask your advisor.';

  @override
  String get asistenteSinManual =>
      'Your car doesn\'t have a manual I can read yet. Ask your advisor at the dealership.';

  @override
  String get asistenteLimite =>
      'You\'ve used today\'s questions. You can ask more tomorrow.';

  @override
  String asistenteFuente(int pagina) {
    return 'Manual, p. $pagina';
  }

  @override
  String asistenteFuenteLector(int pagina) {
    return 'Manual, page $pagina, open';
  }

  @override
  String get asistenciaSeguimientoEncabezado => 'Your request status';

  @override
  String get asistenciaEstadoRecibida => 'Received';

  @override
  String get asistenciaEstadoEnCamino => 'On the way';

  @override
  String get asistenciaEstadoAtendida => 'Assisted';

  @override
  String get asistenciaEstadoCancelada => 'Cancelled';

  @override
  String get asistenciaEstadoNotaRecibida => 'The dealership has your request.';

  @override
  String get asistenciaEstadoNotaEnCamino => 'Help is on its way to you.';

  @override
  String get asistenciaEstadoNotaAtendida => 'Your request has been handled.';

  @override
  String get asistenciaEstadoNotaCancelada => 'The request was closed.';

  @override
  String asistenciaEstadoActual(String estado) {
    return 'Status: $estado';
  }

  @override
  String get asistenciaSeguimientoActualizar => 'Refresh status';

  @override
  String get asistenciaSeguimientoActualizando => 'Refreshing…';

  @override
  String get asistenciaSeguimientoFallo =>
      'We couldn\'t refresh the status. Check your connection and try again.';

  @override
  String get asistenciaSeguimientoUbicacionCerrada =>
      'The request is closed: your location is no longer shared.';

  @override
  String get recoleccionSeguimientoTitulo => 'Transfer tracking';

  @override
  String get recoleccionSeguimientoRecoger => 'We pick up your car';

  @override
  String get recoleccionSeguimientoEntregar => 'We deliver your car';

  @override
  String recoleccionSeguimientoVentana(
    DateTime fecha,
    String inicio,
    String fin,
  ) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString, $inicio to $fin';
  }

  @override
  String get recoleccionSeguimientoAbrir => 'Tap a transfer to follow it live.';

  @override
  String get recoleccionSeguimientoLineaEncabezado => 'Progress';

  @override
  String get recoleccionEstadoProgramado => 'Scheduled';

  @override
  String get recoleccionEstadoEnCamino => 'Driver on the way';

  @override
  String get recoleccionEstadoRecogido => 'Car picked up';

  @override
  String get recoleccionEstadoEnTaller => 'At the workshop';

  @override
  String get recoleccionEstadoDeRegreso => 'Heading back to you';

  @override
  String get recoleccionEstadoEntregado => 'Car delivered';

  @override
  String get recoleccionEstadoCancelado => 'Cancelled';

  @override
  String get recoleccionEstadoNotaEnCamino => 'Follow its location on the map.';

  @override
  String get recoleccionEstadoNotaDeRegreso =>
      'Follow its location on the map.';

  @override
  String get recoleccionSeguimientoMapaEncabezado => 'Where the driver is';

  @override
  String recoleccionSeguimientoMapaDescripcion(
    String latitud,
    String longitud,
  ) {
    return 'Map with the driver\'s location: latitude $latitud, longitude $longitud.';
  }

  @override
  String recoleccionSeguimientoActualizadaEn(String hora) {
    return 'Location updated at $hora';
  }

  @override
  String get recoleccionSeguimientoVerChecklist => 'View car checklist';

  @override
  String get recoleccionSeguimientoActualizar => 'Refresh';

  @override
  String get recoleccionSeguimientoCargando => 'Loading the transfer tracking';

  @override
  String get recoleccionSeguimientoNoEncontradoTitulo =>
      'We couldn\'t find this transfer';

  @override
  String get recoleccionSeguimientoNoEncontradoMensaje =>
      'It may no longer exist. Go back to your appointments and open it again.';

  @override
  String get recoleccionSeguimientoFalloAlActualizar =>
      'We couldn\'t refresh. Showing the latest we know.';

  @override
  String get recoleccionChecklistTitulo => 'Car checklist';

  @override
  String get recoleccionChecklistKm => 'Mileage';

  @override
  String recoleccionChecklistKmValor(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String kmString = kmNumberFormat.format(km);

    return '$kmString km';
  }

  @override
  String get recoleccionChecklistGasolina => 'Fuel';

  @override
  String get recoleccionGasolinaVacio => 'Empty';

  @override
  String get recoleccionGasolinaUnCuarto => 'A quarter';

  @override
  String get recoleccionGasolinaMedio => 'Half a tank';

  @override
  String get recoleccionGasolinaTresCuartos => 'Three quarters';

  @override
  String get recoleccionGasolinaLleno => 'Full';

  @override
  String recoleccionChecklistGasolinaLector(String nivel) {
    return 'Fuel: $nivel';
  }

  @override
  String get recoleccionChecklistNotas => 'Driver\'s notes';

  @override
  String get recoleccionChecklistFotos => 'Car photos';

  @override
  String recoleccionChecklistFotoDescripcion(int numero, int total) {
    return 'Photo $numero of $total of the car\'s condition';
  }

  @override
  String get recoleccionChecklistSinFotos => 'This checklist has no photos.';

  @override
  String get recoleccionChecklistFirmante => 'Signature of acceptance';

  @override
  String recoleccionChecklistRegistrado(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Recorded on $fechaString';
  }

  @override
  String get recoleccionChecklistVacioTitulo => 'No checklist yet';

  @override
  String get recoleccionChecklistVacioMensaje =>
      'The driver records it when picking up and delivering your car. Once done, you\'ll see it here.';

  @override
  String get recoleccionChecklistCargando => 'Loading the car checklist';

  @override
  String get bitacoraTitulo => 'Logbook';

  @override
  String get bitacoraSubtituloSinNombre => 'Your car';

  @override
  String get bitacoraDescripcionPortada => 'Gas pump icon';

  @override
  String get bitacoraNuevaCarga => 'New fill-up';

  @override
  String get bitacoraOtroGasto => 'Other expense';

  @override
  String get bitacoraCerrar => 'Close';

  @override
  String get bitacoraCargando => 'Loading your logbook';

  @override
  String get bitacoraVacioTitulo => 'No expenses yet';

  @override
  String get bitacoraVacioMensaje =>
      'Log your first fill-up to see your fuel economy and what your car costs you.';

  @override
  String get bitacoraResumenTitulo => 'Your numbers';

  @override
  String get bitacoraEtiquetaRendimiento => 'Fuel economy';

  @override
  String bitacoraCifraKmPorLitro(String valor) {
    return '$valor km/l';
  }

  @override
  String get bitacoraEtiquetaCostoPorKm => 'Cost per km';

  @override
  String bitacoraCifraCostoPorKm(String valor) {
    return '$valor/km';
  }

  @override
  String get bitacoraEtiquetaGastoMes => 'Spent this month';

  @override
  String get bitacoraCifraSinDatos => '—';

  @override
  String get bitacoraDetalleSinDatos => 'You need 2 fill-ups';

  @override
  String get bitacoraVerEstadisticas => 'Fuel economy and monthly spending';

  @override
  String get bitacoraExportar => 'Export logbook';

  @override
  String get bitacoraTipoGasolina => 'Fuel';

  @override
  String get bitacoraTipoEstacionamiento => 'Parking';

  @override
  String get bitacoraTipoCasetas => 'Tolls';

  @override
  String get bitacoraTipoLavado => 'Car wash';

  @override
  String get bitacoraTipoOtro => 'Other';

  @override
  String bitacoraDetalleCarga(String fecha, String litros, String km) {
    return '$fecha · $litros l · $km km';
  }

  @override
  String get bitacoraFormCargaTitulo => 'New fill-up';

  @override
  String get bitacoraFormEditarCargaTitulo => 'Edit fill-up';

  @override
  String get bitacoraFormGastoTitulo => 'New expense';

  @override
  String get bitacoraFormEditarGastoTitulo => 'Edit expense';

  @override
  String get bitacoraCampoTipo => 'Expense type';

  @override
  String get bitacoraCampoLitros => 'Liters';

  @override
  String get bitacoraCampoMonto => 'Total amount';

  @override
  String get bitacoraCampoKm => 'Odometer reading';

  @override
  String bitacoraAyudaKm(String km) {
    return 'Your last reading is $km km.';
  }

  @override
  String get bitacoraCampoFecha => 'Date';

  @override
  String get bitacoraElegirFecha => 'Pick a date';

  @override
  String get bitacoraCampoDescripcion => 'Description';

  @override
  String get bitacoraAyudaDescripcion =>
      'Required for “Other”, up to 200 characters.';

  @override
  String get bitacoraErrorMonto => 'Enter an amount greater than 0.';

  @override
  String get bitacoraErrorLitros => 'Enter the liters, greater than 0.';

  @override
  String get bitacoraErrorKm => 'Enter the odometer reading as a whole number.';

  @override
  String bitacoraErrorKmMenor(String km) {
    return 'It can\'t be lower than your last reading ($km km).';
  }

  @override
  String get bitacoraErrorKmServidor =>
      'The server rejected it: it is lower than your last reading. Check the odometer.';

  @override
  String get bitacoraErrorFecha => 'Pick a date that is not in the future.';

  @override
  String get bitacoraErrorDescripcion =>
      'Describe the expense, in up to 200 characters.';

  @override
  String get bitacoraErrorGuardar => 'It couldn\'t be saved. Try again.';

  @override
  String get bitacoraErrorBorrar => 'It couldn\'t be deleted. Try again.';

  @override
  String get bitacoraErrorSinConexion =>
      'No connection. Check your internet and try again.';

  @override
  String get bitacoraGuardar => 'Save';

  @override
  String get bitacoraBorrar => 'Delete expense';

  @override
  String get bitacoraBorrarTitulo => 'Delete this expense?';

  @override
  String bitacoraBorrarMensaje(String descripcion) {
    return '“$descripcion” will be deleted. This can\'t be undone.';
  }

  @override
  String get bitacoraBorrarConfirmar => 'Delete';

  @override
  String get bitacoraBorrarCancelar => 'Cancel';

  @override
  String get bitacoraGastoGuardado => 'Expense saved.';

  @override
  String get bitacoraGastoBorrado => 'Expense deleted.';

  @override
  String get bitacoraTicketTitulo => 'Fill in from the receipt';

  @override
  String get bitacoraTicketPrivacidad =>
      'The photo is read on your phone; it is not saved or uploaded.';

  @override
  String get bitacoraTicketTomar => 'Take photo';

  @override
  String get bitacoraTicketElegir => 'Choose from photos';

  @override
  String get bitacoraTicketLeyendo => 'Reading the receipt…';

  @override
  String get bitacoraTicketLeido =>
      'This is what we read. Check it and fix anything that\'s off.';

  @override
  String get bitacoraTicketNoLeyo =>
      'We couldn\'t read the receipt. Fill in the details by hand.';

  @override
  String get bitacoraTicketSinPermiso =>
      'We don\'t have permission to use the camera or your photos. Turn it on in settings or fill in the details by hand.';

  @override
  String get bitacoraTicketError =>
      'The photo couldn\'t be opened. Fill in the details by hand.';

  @override
  String get bitacoraEstadisticasTitulo => 'Fuel economy and spending';

  @override
  String get bitacoraGraficaTitulo => 'Spending by month';

  @override
  String get bitacoraGraficaVacia => 'There are no expenses to chart yet.';

  @override
  String get bitacoraSinRendimientoTitulo => 'No fuel economy yet';

  @override
  String bitacoraSinRendimientoMensaje(int cargas) {
    String _temp0 = intl.Intl.pluralLogic(
      cargas,
      locale: localeName,
      other:
          'You have $cargas fill-ups, but their odometer readings don\'t advance.',
      one: 'You have 1 fill-up.',
      zero: 'You haven\'t logged any yet.',
    );
    return 'To work out km/l and cost per km we need at least 2 fill-ups with their odometer reading. $_temp0';
  }

  @override
  String bitacoraBaseDelCalculo(String km, int tramos) {
    String _temp0 = intl.Intl.pluralLogic(
      tramos,
      locale: localeName,
      other: '$tramos stretches',
      one: '1 stretch',
    );
    return 'Based on $km km driven across $_temp0 between fill-ups.';
  }

  @override
  String get bitacoraExportarTitulo => 'Export logbook';

  @override
  String get bitacoraExportarIntro =>
      'Pick the months and share your logbook with the system sheet.';

  @override
  String get bitacoraExportarDesde => 'From';

  @override
  String get bitacoraExportarHasta => 'To';

  @override
  String get bitacoraExportarCsv => 'Share CSV';

  @override
  String get bitacoraExportarPdf => 'Share PDF';

  @override
  String get bitacoraExportarVacio => 'There are no expenses in those months.';

  @override
  String get bitacoraExportarRangoInvalido =>
      'The first month can\'t be after the last one.';

  @override
  String get bitacoraExportarError =>
      'The file couldn\'t be shared. Try again.';

  @override
  String bitacoraPdfTitulo(String vehiculo) {
    return 'Logbook for $vehiculo';
  }

  @override
  String bitacoraPdfPeriodo(String desde, String hasta) {
    return '$desde to $hasta';
  }

  @override
  String bitacoraPdfTotal(String monto) {
    return 'Total: $monto';
  }

  @override
  String get bitacoraColumnaFecha => 'Date';

  @override
  String get bitacoraColumnaTipo => 'Type';

  @override
  String get bitacoraColumnaMonto => 'Amount';

  @override
  String get bitacoraColumnaLitros => 'Liters';

  @override
  String get bitacoraColumnaKm => 'Km';

  @override
  String get bitacoraColumnaDetalle => 'Details';

  @override
  String get bitacoraAccesoFila => 'Logbook';

  @override
  String get asistenteSugerenciasTitulo => 'Try one of these';

  @override
  String get asistentePreguntaMantenimiento =>
      'How often does it need service?';

  @override
  String get asistentePreguntaLlantas => 'What tire pressure should I use?';

  @override
  String get asistentePreguntaTestigos =>
      'What does a red light on the dashboard mean?';

  @override
  String get asistentePreguntaAceite => 'How much oil does the engine take?';

  @override
  String get asistentePreguntaGasolina => 'What fuel should I use?';

  @override
  String get asistenteAgendarRevision => 'Book a check-up';

  @override
  String get asistenteMeSirvio => 'Helpful';

  @override
  String get asistenteNoMeSirvio => 'Not helpful';

  @override
  String tallerTarjetaTitulo(String vehiculo) {
    return 'Your $vehiculo is at the shop';
  }

  @override
  String tallerTarjetaEtapaYEntrega(String etapa, String hora) {
    return '$etapa · pickup $hora';
  }

  @override
  String tallerTarjetaPendientes(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad jobs to approve',
      one: '1 job to approve',
    );
    return '$_temp0';
  }

  @override
  String tallerTarjetaAvance(int avance) {
    return '$avance % done';
  }

  @override
  String get tallerTarjetaAbrir => 'See your order progress';

  @override
  String get tallerEtapaRecibido => 'Received';

  @override
  String get tallerEtapaDiagnostico => 'Diagnosis';

  @override
  String get tallerEtapaEsperandoAprobacion => 'Waiting for approval';

  @override
  String get tallerEtapaEnReparacion => 'In repair';

  @override
  String get tallerEtapaControlDeCalidad => 'Quality check';

  @override
  String get tallerEtapaLavado => 'Car wash';

  @override
  String get tallerEtapaListoParaEntrega => 'Ready for pickup';

  @override
  String get tallerEtapaEntregado => 'Delivered';

  @override
  String get tallerOrdenTitulo => 'Your order';

  @override
  String get tallerOrdenEtapaActual => 'Current stage';

  @override
  String get tallerOrdenEntregaEstimada => 'Estimated pickup';

  @override
  String get tallerOrdenSinEntrega => 'Not estimated yet';

  @override
  String get tallerOrdenAsesor => 'Your advisor';

  @override
  String get tallerOrdenLineaDeTiempo => 'Timeline';

  @override
  String tallerOrdenNotaEntrega(String hora) {
    return 'Estimated pickup $hora';
  }

  @override
  String tallerOrdenNotaYEntrega(String nota, String hora) {
    return '$nota · estimated pickup $hora';
  }

  @override
  String get tallerOrdenInspeccion => 'Multi-point inspection';

  @override
  String tallerOrdenInspeccionResumen(int puntos) {
    String _temp0 = intl.Intl.pluralLogic(
      puntos,
      locale: localeName,
      other: '$puntos points checked',
      one: '1 point checked',
      zero: 'No points checked yet',
    );
    return '$_temp0';
  }

  @override
  String get tallerOrdenAdicionales => 'Extra work';

  @override
  String tallerOrdenAdicionalesResumen(int pendientes) {
    String _temp0 = intl.Intl.pluralLogic(
      pendientes,
      locale: localeName,
      other: '$pendientes to approve',
      one: '1 to approve',
      zero: 'Nothing to approve',
    );
    return '$_temp0';
  }

  @override
  String tallerOrdenAvisoPendientes(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'The shop suggests $cantidad extra jobs',
      one: 'The shop suggests 1 extra job',
    );
    return '$_temp0';
  }

  @override
  String get tallerOrdenAvisoMensaje =>
      'Review them and approve or decline them with your signature.';

  @override
  String get tallerOrdenRevisar => 'Review';

  @override
  String get tallerReintentar => 'Try again';

  @override
  String get tallerInspeccionTitulo => 'Inspection';

  @override
  String get tallerInspeccionVacia => 'No inspection yet';

  @override
  String get tallerInspeccionVaciaMensaje =>
      'The technician has not recorded the checked points yet.';

  @override
  String tallerInspeccionFotoDe(String punto) {
    return 'Photo of $punto';
  }

  @override
  String get tallerInspeccionDeLaOrden => 'From the order';

  @override
  String get tallerInspeccionFotoDeLaOrden => 'Order photo';

  @override
  String tallerInspeccionVerVideo(int numero) {
    return 'Watch video $numero';
  }

  @override
  String get tallerInspeccionVideoAbre => 'Opens in your phone player';

  @override
  String get tallerInspeccionVideoError =>
      'The video could not be opened. Pull down to reload and try again.';

  @override
  String get tallerAdicionalesTitulo => 'Extra work';

  @override
  String get tallerAdicionalesVacio => 'No extra work';

  @override
  String get tallerAdicionalesVacioMensaje =>
      'If the shop finds something else, it will suggest it here for you to decide.';

  @override
  String get tallerAdicionalManoDeObra => 'Labor';

  @override
  String get tallerAdicionalRefacciones => 'Parts';

  @override
  String get tallerAdicionalTotal => 'Total';

  @override
  String get tallerAdicionalPendiente => 'To approve';

  @override
  String get tallerAdicionalAprobado => 'Approved';

  @override
  String get tallerAdicionalRechazado => 'Declined';

  @override
  String tallerAdicionalRespondidoEl(String fecha) {
    return 'Answered on $fecha';
  }

  @override
  String get tallerAdicionalAprobar => 'Approve';

  @override
  String get tallerAdicionalRechazar => 'Decline';

  @override
  String get tallerTotales => 'Totals';

  @override
  String get tallerTotalOrden => 'Order total';

  @override
  String get tallerTotalAprobados => 'Approved extra work';

  @override
  String get tallerTotalPendientes => 'Extra work to approve';

  @override
  String get tallerTotalEstimado => 'Estimated total';

  @override
  String get tallerFirmaAprobarTitulo => 'Sign to approve';

  @override
  String get tallerFirmaRechazarTitulo => 'Sign to decline';

  @override
  String tallerFirmaInstruccion(String concepto, String total) {
    return '$concepto for $total. Sign with your finger inside the box: your signature is saved with your answer.';
  }

  @override
  String get tallerFirmaArea => 'Area to sign with your finger';

  @override
  String get tallerFirmaBorrar => 'Clear signature';

  @override
  String get tallerFirmaConfirmarAprobar => 'Approve with my signature';

  @override
  String get tallerFirmaConfirmarRechazar => 'Decline with my signature';

  @override
  String tallerRespuestaAprobada(String concepto) {
    return 'You approved “$concepto”. The estimated total already includes it.';
  }

  @override
  String tallerRespuestaRechazada(String concepto) {
    return 'You declined “$concepto”.';
  }

  @override
  String get tallerRespuestaYaRespondida =>
      'That job was already answered. Reload to see its status.';

  @override
  String get tallerRespuestaOrdenCerrada =>
      'The order is already finished. Talk to your advisor.';

  @override
  String get tallerRespuestaSinConexion =>
      'No connection. Your answer was not sent.';

  @override
  String get tallerRespuestaError =>
      'Your answer could not be sent. Try again.';

  @override
  String get asistenteFotoAdjuntar => 'Photo of a dashboard light';

  @override
  String get asistenteFotoTomar => 'Take photo';

  @override
  String get asistenteFotoGaleria => 'Choose from your photos';

  @override
  String get asistenteFotoEnviada => 'Dashboard photo';

  @override
  String get asistenteRevisandoFoto => 'Checking your photo…';

  @override
  String get asistenteTestigoRoja => 'Stop';

  @override
  String get asistenteTestigoAmarilla => 'Check soon';

  @override
  String get asistenteTestigoInformativa => 'For your information';

  @override
  String get asistenteTestigoDetente =>
      'Pull over somewhere safe as soon as you can and turn off the engine.';

  @override
  String get asistentePedirAyuda => 'Get help';

  @override
  String get asistenteTestigoNoReconocido =>
      'I couldn\'t recognize a light in the photo. Describe it in words: color, shape and whether it blinks.';

  @override
  String get asistentePermisoCamara =>
      'To take the photo, allow access to the camera and your photos in your phone settings.';

  @override
  String get asistenteAbrirAjustes => 'Open settings';

  @override
  String citasMisCitasRecoleccionEncabezado(String cita) {
    return 'Pickup · $cita';
  }

  @override
  String get citasChecklistRecoger => 'Checklist at pickup';

  @override
  String get citasChecklistEntregar => 'Checklist at delivery';

  @override
  String get citasChecklistSubtitulo => 'Mileage, fuel and photos';

  @override
  String get citasChecklistComparar => 'Compare pickup and delivery';

  @override
  String get citasChecklistCompararSubtitulo => 'What changed between the two';

  @override
  String get recoleccionChecklistPestanaRecoger => 'At pickup';

  @override
  String get recoleccionChecklistPestanaEntregar => 'At delivery';

  @override
  String get recoleccionChecklistPestanaComparar => 'Compare';

  @override
  String recoleccionComparacionKmDetalle(int recoger, int entregar) {
    final intl.NumberFormat recogerNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recogerString = recogerNumberFormat.format(recoger);
    final intl.NumberFormat entregarNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String entregarString = entregarNumberFormat.format(entregar);

    return '$recogerString km at pickup, $entregarString km at delivery';
  }

  @override
  String recoleccionComparacionGasolinaDetalle(
    String recoger,
    String entregar,
  ) {
    return '$recoger at pickup, $entregar at delivery';
  }

  @override
  String get recoleccionComparacionFotosTitulo =>
      'Photos at pickup and delivery';

  @override
  String get recoleccionComparacionFotosAyuda =>
      'Drag the bar: on the left you see the photo at pickup and on the right the photo at delivery.';

  @override
  String recoleccionComparacionFotoRecoger(int numero, int total) {
    return 'Photo $numero of $total at pickup';
  }

  @override
  String recoleccionComparacionFotoEntregar(int numero, int total) {
    return 'Photo $numero of $total at delivery';
  }

  @override
  String recoleccionComparacionFotosDesiguales(
    int recoger,
    int entregar,
    int comparadas,
  ) {
    return 'There are $recoger photos at pickup and $entregar at delivery; the first $comparadas are compared.';
  }

  @override
  String get recoleccionComparacionSinFotos =>
      'One of the two checklists has no photos to compare.';

  @override
  String get recoleccionComparacionFaltaTitulo => 'Can\'t compare yet';

  @override
  String get recoleccionComparacionFaltaRecoger =>
      'The driver hasn\'t recorded the pickup checklist yet.';

  @override
  String get recoleccionComparacionFaltaEntregar =>
      'The driver hasn\'t recorded the delivery checklist yet. You can compare once your car is returned.';

  @override
  String get recoleccionComparacionFaltaAmbos =>
      'The driver hasn\'t recorded any checklist for this pickup yet.';
}
