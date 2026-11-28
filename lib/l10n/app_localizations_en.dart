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
  String get accesoCambiarActualEtiqueta => 'Temporary password';

  @override
  String get accesoCambiarCerrarSesion => 'Sign out';

  @override
  String get accesoCambiarConfirmarEtiqueta => 'Confirm the new password';

  @override
  String get accesoCambiarCorreoCodigoCorto => 'The code has 6 digits';

  @override
  String get accesoCambiarCorreoCodigoEtiqueta => '6-digit code';

  @override
  String get accesoCambiarCorreoCodigoInvalido =>
      'That code is not valid, was already used or expired';

  @override
  String get accesoCambiarCorreoConfirmando => 'Confirming…';

  @override
  String get accesoCambiarCorreoConfirmar => 'Confirm';

  @override
  String get accesoCambiarCorreoContrasenaEtiqueta => 'Your password';

  @override
  String get accesoCambiarCorreoContrasenaFalta => 'Enter your password';

  @override
  String get accesoCambiarCorreoContrasenaNoCoincide =>
      'Your password doesn\'t match';

  @override
  String get accesoCambiarCorreoContrasenaPista =>
      'You sign in with your email, so we confirm it\'s you.';

  @override
  String get accesoCambiarCorreoCorreoEnUso => 'That email is already in use';

  @override
  String get accesoCambiarCorreoCorreoEtiqueta => 'New email';

  @override
  String get accesoCambiarCorreoCorreoInvalido => 'Enter a valid email';

  @override
  String get accesoCambiarCorreoEnviando => 'Sending…';

  @override
  String get accesoCambiarCorreoEnviar => 'Send the code';

  @override
  String get accesoCambiarCorreoExplicacion =>
      'We\'ll send a code to the new email to confirm it\'s yours. Your email doesn\'t change until you enter it.';

  @override
  String get accesoCambiarCorreoFalloTitulo =>
      'We couldn\'t request the change';

  @override
  String accesoCambiarCorreoListoMensaje(String correo) {
    return 'From now on you sign in with $correo.';
  }

  @override
  String get accesoCambiarCorreoListoTitulo => 'Your email is updated';

  @override
  String accesoCambiarCorreoPasoDosExplicacion(String correo) {
    return 'We sent a code to $correo. It expires in 15 minutes.';
  }

  @override
  String get accesoCambiarCorreoPedirOtro => 'Ask for another code';

  @override
  String get accesoCambiarCorreoTitulo => 'Change my email';

  @override
  String get accesoCambiarCorreoVencio =>
      'The code expired. Ask for another one.';

  @override
  String get accesoCambiarExplicacion =>
      'The dealership gave you a temporary password. Choose a new one to continue.';

  @override
  String get accesoCambiarFalloTitulo => 'We couldn\'t change your password';

  @override
  String get accesoCambiarGuardando => 'Saving…';

  @override
  String get accesoCambiarGuardar => 'Save';

  @override
  String get accesoCambiarNoCoincide => 'The two passwords don\'t match.';

  @override
  String get accesoCambiarNuevaEtiqueta => 'New password';

  @override
  String get accesoCambiarReglaDistinta => 'Different from the temporary one';

  @override
  String get accesoCambiarReglaLargo => 'From 8 to 72 characters';

  @override
  String get accesoCambiarReglaLetra => 'At least one letter';

  @override
  String get accesoCambiarReglaNumero => 'At least one number';

  @override
  String get accesoCambiarReglasTitulo => 'Your new password must have:';

  @override
  String get accesoCambiarTitulo => 'Change your password';

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
  String get accesoDesactivadaEscribir => 'Send an email';

  @override
  String get accesoDesactivadaExplicacion =>
      'The dealership turned off access for this account. We cannot turn it back on from the app: get in touch with them and they will help you.';

  @override
  String get accesoDesactivadaLlamar => 'Call the dealership';

  @override
  String get accesoDesactivadaNoSePudo => 'This device could not open it.';

  @override
  String get accesoDesactivadaTitulo => 'Your account is deactivated';

  @override
  String get accesoDesactivadaVolver => 'Back to sign in';

  @override
  String get accesoEnlaceNoValidoMensaje =>
      'Links expire soon and work only once. Ask for a new one and check your email.';

  @override
  String get accesoEnlaceNoValidoTitulo => 'This link no longer works';

  @override
  String get accesoEnlacePedirOtro => 'Ask for another link';

  @override
  String get accesoEntrando => 'Signing in…';

  @override
  String get accesoEntrar => 'Sign in';

  @override
  String get accesoFalloTitulo => 'We couldn\'t sign you in';

  @override
  String get accesoMarca => 'CareCar';

  @override
  String get accesoMiContrasenaCerrarOtras => 'Sign out on all my devices';

  @override
  String get accesoMiContrasenaCerrarOtrasDetalle =>
      'This phone included: you will have to sign in again with your new password.';

  @override
  String get accesoMiContrasenaExplicacion =>
      'We ask for your current password to confirm it is you.';

  @override
  String get accesoMiContrasenaGuardar => 'Save the new password';

  @override
  String get accesoMiContrasenaListo => 'Your password is updated';

  @override
  String get accesoMiContrasenaListoMensaje =>
      'Use it the next time you sign in.';

  @override
  String get accesoMiContrasenaTitulo => 'Change my password';

  @override
  String get accesoNuevaExplicacion =>
      'Choose a new password. This link works only once.';

  @override
  String get accesoNuevaFalloTitulo => 'We couldn\'t save your password';

  @override
  String get accesoNuevaGuardando => 'Saving…';

  @override
  String get accesoNuevaGuardar => 'Save password';

  @override
  String get accesoNuevaIrAlAcceso => 'Sign in';

  @override
  String get accesoNuevaListoMensaje => 'You can sign in with it now.';

  @override
  String get accesoNuevaListoTitulo => 'Your password is ready';

  @override
  String get accesoNuevaTitulo => 'Choose your new password';

  @override
  String get accesoOlvide => 'Forgot your password?';

  @override
  String get accesoPerfilCandado => 'Sign in with fingerprint or face';

  @override
  String get accesoPerfilCandadoDetalle =>
      'To open the app without typing your password';

  @override
  String get accesoPerfilCandadoMotivo =>
      'Confirm your fingerprint to turn unlocking on.';

  @override
  String get accesoPerfilCandadoNoSePudo =>
      'We could not confirm your fingerprint. Unlocking stays off.';

  @override
  String get accesoPerfilCargando => 'Loading your profile…';

  @override
  String get accesoPerfilClienteDesde => 'Customer since';

  @override
  String get accesoPerfilCorreo => 'Email';

  @override
  String get accesoPerfilCuentaEncabezado => 'Your account';

  @override
  String get accesoPerfilDatosEncabezado => 'Your details';

  @override
  String get accesoPerfilMisSesiones => 'My sessions';

  @override
  String get accesoPerfilMisSesionesDetalle =>
      'See and close the sessions open on other devices';

  @override
  String get accesoPerfilNombre => 'Name';

  @override
  String get accesoPerfilPie =>
      'Tap your email to change it. For your phone, get in touch with the dealership.';

  @override
  String get accesoPerfilSinTelefono => 'No phone on file';

  @override
  String get accesoPerfilSinVehiculos => 'You have no vehicles registered';

  @override
  String get accesoPerfilTelefono => 'Phone';

  @override
  String get accesoPerfilTitulo => 'My profile';

  @override
  String get accesoPerfilVehiculosEncabezado => 'Your vehicles';

  @override
  String get accesoPerfilVehiculosFallo => 'We couldn\'t load your vehicles';

  @override
  String get accesoRecuperarEnviado => 'Check your email';

  @override
  String get accesoRecuperarEnviadoMensaje =>
      'If that email has an account, you\'ll get a link to choose a new password. It expires soon and works only once.';

  @override
  String get accesoRecuperarEnviando => 'Sending…';

  @override
  String get accesoRecuperarEnviar => 'Send me the link';

  @override
  String get accesoRecuperarExplicacion =>
      'Enter your email and we\'ll send you a link to choose a new password.';

  @override
  String get accesoRecuperarFalloTitulo => 'We couldn\'t send the link';

  @override
  String get accesoRecuperarTitulo => 'Recover your password';

  @override
  String get accesoServidorDespertandoMensaje =>
      'The first time after a while it can take up to a minute.';

  @override
  String get accesoServidorDespertandoTitulo => 'Waking up the server…';

  @override
  String get accesoSesionesActivaAhora => 'Active now';

  @override
  String get accesoSesionesCambio =>
      'That session changed while you were looking. Check the list and try again.';

  @override
  String get desbloqueoCambioMensaje =>
      'For your safety we turned fingerprint unlocking off. Sign in with your password and you can turn it back on.';

  @override
  String get desbloqueoCambioTitulo => 'Your phone\'s biometrics changed';

  @override
  String get desbloqueoContrasena => 'Sign in with my password';

  @override
  String get desbloqueoExplicacion =>
      'Use your fingerprint or your face to get in.';

  @override
  String get desbloqueoFalloMensaje =>
      'Try again or sign in with your password.';

  @override
  String get desbloqueoFalloTitulo => 'We did not recognize you';

  @override
  String get desbloqueoIntentar => 'Use my fingerprint or face';

  @override
  String get desbloqueoMotivo => 'Confirm it is you to get into CareCar.';

  @override
  String get desbloqueoTitulo => 'Unlock CareCar';

  @override
  String get accesoSesionesCancelar => 'Cancel';

  @override
  String get accesoSesionesCargando => 'Loading your sessions…';

  @override
  String get accesoSesionesCerrada => 'Done, that session is closed.';

  @override
  String get accesoSesionesCerrar => 'Close';

  @override
  String accesoSesionesCerrarEtiqueta(String dispositivo) {
    return 'Close the session on $dispositivo';
  }

  @override
  String get accesoSesionesCerrarTodas => 'Close all sessions';

  @override
  String get accesoSesionesCerrarTodasConfirmar => 'Close all';

  @override
  String get accesoSesionesCerrarTodasMensaje =>
      'They will close on all your devices, including this one. You\'ll need to sign in again.';

  @override
  String get accesoSesionesCerrarTodasTitulo => 'Close all sessions?';

  @override
  String get accesoSesionesCerrarUnaMensaje =>
      'That device will have to sign in again with your email and password.';

  @override
  String accesoSesionesCerrarUnaTitulo(String dispositivo) {
    return 'Close the session on $dispositivo?';
  }

  @override
  String get accesoSesionesEncabezado => 'Devices with your session open';

  @override
  String get accesoSesionesEquipoSinNombre => 'Unnamed device';

  @override
  String get accesoSesionesFalloCerrar =>
      'We couldn\'t close that session. Try again.';

  @override
  String accesoSesionesHaceDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String accesoSesionesHaceHoras(int horas) {
    String _temp0 = intl.Intl.pluralLogic(
      horas,
      locale: localeName,
      other: '$horas hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String accesoSesionesHaceMinutos(int minutos) {
    String _temp0 = intl.Intl.pluralLogic(
      minutos,
      locale: localeName,
      other: '$minutos minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get accesoSesionesPie =>
      'If you see a device you don\'t recognize, close it and change your password.';

  @override
  String get accesoSesionesSinActividad => 'No recorded activity';

  @override
  String get accesoSesionesTitulo => 'My sessions';

  @override
  String accesoSesionesUltimoUsoFecha(String fecha) {
    return 'On $fecha';
  }

  @override
  String get accesoSesionesVacioMensaje =>
      'When you sign in from a device, it will show up here.';

  @override
  String get accesoSesionesVacioTitulo => 'No sessions open';

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
  String get asistenciaGrupoGuias => 'Guides';

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
  String get citasReprogramadaTitulo => 'Appointment rescheduled';

  @override
  String citasReprogramarListo(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'We will see you on $fechaString at $hora. The previous time slot is free again.';
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
  String get tiendaAccionError => 'Something went wrong. Try again.';

  @override
  String get tiendaAccionSinConexion =>
      'No connection. Check your internet and try again.';

  @override
  String get tiendaAgendarCita => 'Book appointment';

  @override
  String get tiendaAgotado => 'Out of stock';

  @override
  String tiendaAgregado(int piezas) {
    return 'Added. You have $piezas of this product.';
  }

  @override
  String get tiendaAgregar => 'Add to cart';

  @override
  String tiendaApartadoMensaje(String fecha) {
    return 'Your reservation expires on $fecha. Pay now in the app or at the counter when you pick it up.';
  }

  @override
  String get tiendaApartadoTitulo => 'Items reserved';

  @override
  String get tiendaApartar => 'Reserve';

  @override
  String get tiendaApartarSinConexion =>
      'No connection. Your cart is saved: try again and it will not be reserved twice.';

  @override
  String get tiendaAvanceTitulo => 'Progress';

  @override
  String get tiendaBuscar => 'Search by name or code';

  @override
  String get tiendaCambiarCita => 'Change appointment';

  @override
  String get tiendaCancelarConfirmar => 'Yes, cancel it';

  @override
  String get tiendaCancelarMensaje =>
      'The items are released and someone else can reserve them.';

  @override
  String get tiendaCancelarPedido => 'Cancel order';

  @override
  String get tiendaCancelarTitulo => 'Cancel the order?';

  @override
  String get tiendaCancelarVolver => 'Keep it';

  @override
  String get tiendaCantidad => 'Quantity';

  @override
  String get tiendaCargando => 'Loading the store';

  @override
  String tiendaCarritoLleno(int maximo) {
    return 'The cart holds up to $maximo different products.';
  }

  @override
  String get tiendaCarritoTitulo => 'Cart';

  @override
  String get tiendaCarritoVacioMensaje =>
      'Add products from the store to reserve them.';

  @override
  String get tiendaCarritoVacioTitulo => 'Your cart is empty';

  @override
  String get tiendaCategoriaAccesorio => 'Accessories';

  @override
  String get tiendaCategoriaCuidado => 'Car care';

  @override
  String get tiendaCategoriaRefaccion => 'Parts';

  @override
  String get tiendaCategoriaTodas => 'All';

  @override
  String get tiendaCitaElegida => 'Selected';

  @override
  String tiendaCompatibilidadAnios(String desde, String hasta) {
    return '$desde to $hasta';
  }

  @override
  String get tiendaCompatibilidadTitulo => 'Compatible cars';

  @override
  String get tiendaCompatible => 'Fits your car';

  @override
  String get tiendaDetalleTitulo => 'My order';

  @override
  String get tiendaElegirCita => 'Choose the appointment';

  @override
  String get tiendaEntendido => 'Got it';

  @override
  String get tiendaEntradaDetalle =>
      'Genuine accessories and parts for your car';

  @override
  String get tiendaEntregaCita => 'Install at my appointment';

  @override
  String get tiendaEntregaMostrador => 'Pick up at the counter';

  @override
  String get tiendaEntregaTitulo => 'Delivery';

  @override
  String get tiendaErrorCitas => 'We could not load your appointments.';

  @override
  String get tiendaErrorMas => 'We could not load more. Try again.';

  @override
  String get tiendaErrorMensaje => 'Try again in a moment.';

  @override
  String get tiendaErrorTitulo => 'We could not load this';

  @override
  String get tiendaEstadoApartado => 'Reserved';

  @override
  String get tiendaEstadoCancelado => 'Cancelled';

  @override
  String get tiendaEstadoEntregado => 'Delivered';

  @override
  String get tiendaEstadoListo => 'Ready';

  @override
  String tiendaExistencia(int piezas) {
    String _temp0 = intl.Intl.pluralLogic(
      piezas,
      locale: localeName,
      other: '$piezas left',
      one: '1 left',
    );
    return '$_temp0';
  }

  @override
  String get tiendaFiltroAuto => 'Fits';

  @override
  String tiendaFotoDe(String producto) {
    return 'Photo of $producto';
  }

  @override
  String get tiendaInstalacionTitulo => 'Installation';

  @override
  String get tiendaInstalarProxima => 'Install at my next appointment';

  @override
  String get tiendaIrALaTienda => 'Go to the store';

  @override
  String tiendaLeQueda(String auto) {
    return 'Fits your $auto';
  }

  @override
  String tiendaMaximoAlcanzado(int piezas) {
    return 'You already have $piezas, the most for this product.';
  }

  @override
  String get tiendaMedioTarjeta => 'card';

  @override
  String get tiendaMisPedidos => 'My orders';

  @override
  String get tiendaMotivoAgencia => 'The dealership cancelled it';

  @override
  String get tiendaMotivoCliente => 'You cancelled it';

  @override
  String get tiendaMotivoVencido => 'The reservation expired';

  @override
  String tiendaNoLeQueda(String auto) {
    return 'Does not fit your $auto';
  }

  @override
  String get tiendaNoSeApartoTitulo => 'We could not reserve it';

  @override
  String get tiendaNoSeCambioTitulo => 'We could not change the order';

  @override
  String get tiendaPagado => 'Paid';

  @override
  String tiendaPagadoAviso(String medio) {
    return 'Paid with $medio';
  }

  @override
  String get tiendaPagadoCancelarEnMostrador =>
      'It\'s already paid: to cancel it, ask at the counter.';

  @override
  String tiendaPagadoMensaje(String fecha) {
    return 'On $fecha. It no longer expires.';
  }

  @override
  String tiendaPagar(String monto) {
    return 'Pay $monto';
  }

  @override
  String get tiendaPagarAhora => 'Pay now';

  @override
  String get tiendaPagarEnCaja => 'Pay at the counter';

  @override
  String get tiendaPagoEnAppOCaja =>
      'Pay in the app from your order or at the counter when you pick it up.';

  @override
  String get tiendaPagoEnCaja =>
      'The app does not charge you: pay at the counter.';

  @override
  String get tiendaPedidoNoEncontradoMensaje => 'Check your list of orders.';

  @override
  String get tiendaPedidoNoEncontradoTitulo => 'We could not find that order';

  @override
  String tiendaPedidoResumen(String total, int piezas) {
    String _temp0 = intl.Intl.pluralLogic(
      piezas,
      locale: localeName,
      other: '$piezas items',
      one: '1 item',
    );
    return '$total, $_temp0';
  }

  @override
  String tiendaPedidoTitulo(int numero) {
    return 'Order $numero';
  }

  @override
  String get tiendaPedidosVacioMensaje =>
      'What you reserve in the store shows up here.';

  @override
  String get tiendaPedidosVacioTitulo => 'You have no orders yet';

  @override
  String tiendaPrecioCadaUno(String precio) {
    return '$precio each';
  }

  @override
  String get tiendaProductoNoEncontradoMensaje =>
      'The dealership may have removed it from the store.';

  @override
  String get tiendaProductoNoEncontradoTitulo =>
      'This product is no longer available';

  @override
  String get tiendaProductoTitulo => 'Product';

  @override
  String get tiendaProductosTitulo => 'Products';

  @override
  String get tiendaQuitar => 'Remove';

  @override
  String get tiendaQuitarFiltros => 'Show all products';

  @override
  String get tiendaRechazoCitaNoDisponible =>
      'That appointment was cancelled or has passed. Choose another or pick up at the counter.';

  @override
  String get tiendaRechazoIncompatible =>
      'One of the products does not fit the car of that appointment. Choose another or pick up at the counter.';

  @override
  String get tiendaRechazoLimite =>
      'You already have 3 undelivered orders. Pick up or cancel one to reserve more.';

  @override
  String get tiendaRechazoNoCancelable =>
      'This order was already delivered and cannot be cancelled.';

  @override
  String get tiendaRechazoNoModificable =>
      'This order was delivered or cancelled and cannot be changed.';

  @override
  String get tiendaRechazoPagado =>
      'This order is already paid and can\'t be canceled in the app: cancel it at the counter.';

  @override
  String get tiendaRechazoSinExistencia =>
      'There are not enough items left. Check the stock and change the quantity.';

  @override
  String get tiendaReintentar => 'Retry';

  @override
  String tiendaRenglonDetalle(int cantidad, String precio) {
    return '$cantidad at $precio';
  }

  @override
  String get tiendaSeInstala => 'Installed at your appointment';

  @override
  String get tiendaSeRecoge => 'Picked up at the counter';

  @override
  String get tiendaSeguirComprando => 'Back to the store';

  @override
  String get tiendaSinCitaCompatible =>
      'It does not fit the car of any of your upcoming appointments.';

  @override
  String get tiendaSinCitas =>
      'You have no upcoming confirmed appointments. Book one to have it installed.';

  @override
  String get tiendaSinConexionMensaje => 'Check your internet and try again.';

  @override
  String get tiendaSinConexionTitulo => 'No connection';

  @override
  String tiendaTarjeta(String marca, String ultimos4) {
    return '$marca •••• $ultimos4';
  }

  @override
  String get tiendaTitulo => 'Store';

  @override
  String get tiendaTodosLosProductos => 'All products';

  @override
  String get tiendaTotal => 'Total';

  @override
  String get tiendaUniversal => 'Fits any car';

  @override
  String get tiendaVacioMensaje => 'Try another search, category or car.';

  @override
  String get tiendaVacioTitulo => 'No products found';

  @override
  String tiendaVence(String fecha) {
    return 'Expires on $fecha';
  }

  @override
  String tiendaVenceDetalle(String fecha) {
    return 'Expires on $fecha. After that it is cancelled and the items are released.';
  }

  @override
  String tiendaVerCarrito(int piezas) {
    return 'View cart ($piezas)';
  }

  @override
  String get tiendaVerMas => 'Show more';

  @override
  String get tiendaVerMiPedido => 'View my order';

  @override
  String get tiendaVigenciaCita =>
      'The reservation lasts until the end of the day after your appointment.';

  @override
  String get tiendaVigenciaMostrador =>
      'The reservation lasts 48 hours. If it expires, the items are released.';

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
  String get bandejaTitulo => 'Notifications';

  @override
  String get bandejaCargando => 'Loading your notifications';

  @override
  String get bandejaVacioTitulo => 'No notifications yet';

  @override
  String get bandejaVacioMensaje =>
      'Here we will tell you how your car is doing at the shop, when your appointment is, and when your documents are ready.';

  @override
  String get bandejaMarcarTodos => 'Mark all as read';

  @override
  String get bandejaSinLeerUno => 'Unread';

  @override
  String get bandejaErrorMasTitulo => 'We could not load more notifications';

  @override
  String get bandejaErrorMasMensaje =>
      'What already loaded is still here. Pull down to try again.';

  @override
  String get accesoPerfilMisAvisos => 'My notifications';

  @override
  String bandejaSinLeer(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String get conexionSinRedTitulo => 'No connection to the dealership';

  @override
  String get conexionSinRedMensaje =>
      'You can still see what was already saved. Anything that needs the internet will be retried when the signal is back.';

  @override
  String get conexionAccionSinRed =>
      'Needs the internet. We will try when the signal is back.';

  @override
  String get avisosPermisoTitulo => 'Why we notify you';

  @override
  String get avisosPermisoExplicacion =>
      'We only write to you when something happens with your car. Nothing else.';

  @override
  String get avisosPermisoTaller =>
      'How your car is doing at the shop, step by step.';

  @override
  String get avisosPermisoCitas =>
      'Your appointment, reminded 24 and 2 hours ahead.';

  @override
  String get avisosPermisoRespuestas =>
      'When your advisor replies or your documents are ready.';

  @override
  String get avisosPermisoSinPublicidad =>
      'We do not send ads, and you can turn them off whenever you want.';

  @override
  String get avisosPermisoActivar => 'Turn on notifications';

  @override
  String get avisosPermisoAhoraNo => 'Not now';

  @override
  String get avisosPermisoListoTitulo => 'Done, we will keep you posted';

  @override
  String get avisosPermisoListoMensaje =>
      'You can turn them off from your profile whenever you want.';

  @override
  String get avisosPermisoNegadosTitulo => 'Notifications are off';

  @override
  String get avisosPermisoNegadosMensaje =>
      'Your phone will not let us ask again, but you can turn them on in the system settings.';

  @override
  String get avisosPermisoAbrirAjustes => 'Open settings';

  @override
  String get accesoPerfilAvisos => 'Notifications';

  @override
  String get accesoPerfilAvisosPrendidos => 'On';

  @override
  String get accesoPerfilAvisosApagados => 'Off';

  @override
  String get accesoPerfilAvisosSinPreguntar => 'Not set up';

  @override
  String get navegacionPrincipal => 'Main navigation';

  @override
  String get bienvenidaDosTexto =>
      'Pick the day and time that suit you, and reschedule or cancel from here.';

  @override
  String get bienvenidaDosTitulo => 'Book a visit without calling';

  @override
  String get bienvenidaEmpezar => 'Get started';

  @override
  String get bienvenidaSaltar => 'Skip';

  @override
  String get bienvenidaSiguiente => 'Next';

  @override
  String get bienvenidaTresTexto =>
      'We let you know how your car is doing at the shop and when you can pick it up.';

  @override
  String get bienvenidaTresTitulo => 'Follow your service';

  @override
  String get bienvenidaUnoTexto =>
      'Check its service history, its documents and what comes next in its maintenance.';

  @override
  String get bienvenidaUnoTitulo => 'Your cars, all in one place';

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
  String get analiticaTitulo => 'Share analytics';

  @override
  String get analiticaDescripcion =>
      'Share usage and diagnostic metrics to help improve CareCar.';

  @override
  String get analiticaError => 'The preference could not be saved. Try again.';

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
  String get cerrarPantalla => 'Close';

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
  String get seguridadConexionNoSeguraTitulo =>
      'We could not verify that the connection is secure';

  @override
  String get seguridadConexionNoSeguraMensaje =>
      'The certificate the server presented is not the one the app expects. This can happen on a filtered network (public Wi-Fi, school or work). Try mobile data or another network.';

  @override
  String inicioSaludo(String nombre) {
    return 'Hi, $nombre';
  }

  @override
  String get inicioProximaCita => 'Next appointment';

  @override
  String get inicioSinCitas => 'No upcoming appointments';

  @override
  String get inicioSinCitasDetalle => 'Book your car\'s next service';

  @override
  String get inicioSinAutos => 'No cars registered yet';

  @override
  String get inicioSinAutosDetalle =>
      'Once the dealership registers your car, you\'ll see it here';

  @override
  String inicioKilometros(String km) {
    return '$km km';
  }

  @override
  String inicioAutoDeTotal(int n, int total) {
    return 'Car $n of $total';
  }

  @override
  String inicioCitaCuando(String dia, String hora) {
    return '$dia, $hora';
  }

  @override
  String get inicioAgendarCita => 'Book appointment';

  @override
  String get inicioPerfilYAjustes => 'Profile and settings';

  @override
  String get inicioDestinoInicio => 'Home';

  @override
  String get inicioDestinoVehiculos => 'Vehicles';

  @override
  String get inicioDestinoCitas => 'Appointments';

  @override
  String get inicioDestinoCatalogo => 'Catalog';

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
  String tallerTarjetaListoTitulo(String vehiculo) {
    return 'Your $vehiculo is ready';
  }

  @override
  String tallerTarjetaListoTotal(String total) {
    return 'Total to pay $total';
  }

  @override
  String tallerHorarioEntrega(String fecha, String desde, String hasta) {
    return 'Pick it up on $fecha from $desde to $hasta';
  }

  @override
  String get tallerHorarioSinFranjas =>
      'Your advisor will tell you when to pick it up.';

  @override
  String get tallerOrdenListoTitulo => 'Your car is ready';

  @override
  String get tallerOrdenTotalAPagar => 'Total to pay';

  @override
  String get tallerOrdenEntregadaTitulo => 'You picked up your car';

  @override
  String get tallerOrdenEntregadaMensaje =>
      'The order is now in your vehicle history with its ticket.';

  @override
  String get tallerOrdenVerTicket => 'See ticket';

  @override
  String get tallerOrdenVerTicketResumen => 'Labor and parts of the order';

  @override
  String get tallerOrdenVerHistorial => 'See vehicle history';

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
  String get estrenoQuieroProbarlo => 'Test drive';

  @override
  String get estrenoCotizar => 'Get a quote';

  @override
  String get estrenoPruebaTitulo => 'Test drive';

  @override
  String get estrenoCotizacionTitulo => 'Quote';

  @override
  String get estrenoMisSolicitudes => 'My requests';

  @override
  String get estrenoDia => 'Which day?';

  @override
  String get estrenoFranja => 'What time?';

  @override
  String get estrenoManana => 'Morning (9 am–1 pm)';

  @override
  String get estrenoTarde => 'Afternoon (1–6 pm)';

  @override
  String get estrenoTomaACuenta => 'Trading in your car?';

  @override
  String get estrenoSinTomaACuenta => 'No';

  @override
  String get estrenoEnviar => 'Send request';

  @override
  String get estrenoEnviarCotizacion => 'Send quote';

  @override
  String get estrenoEnviando => 'Sending…';

  @override
  String get estrenoCalculando => 'Working out your monthly payment…';

  @override
  String get estrenoListo => 'Done! An advisor will contact you soon.';

  @override
  String get estrenoVerSolicitudes => 'See my requests';

  @override
  String get estrenoDuplicada =>
      'You already asked for this model; an advisor will contact you.';

  @override
  String get estrenoSinPrecio =>
      'This model has no published price yet. Ask an advisor.';

  @override
  String get estrenoSinConexion =>
      'We couldn\'t send it. Check your internet and try again.';

  @override
  String get estrenoNoDisponible => 'Something went wrong. Try again later.';

  @override
  String get estrenoEnganche => 'Down payment';

  @override
  String estrenoEngancheAyuda(String minimo) {
    return 'At least $minimo';
  }

  @override
  String get estrenoPlazo => 'Term';

  @override
  String estrenoMeses(int meses) {
    return '$meses months';
  }

  @override
  String get estrenoMensualidad => 'Estimated monthly payment';

  @override
  String estrenoPrecioDesde(String precio) {
    return 'Price from $precio';
  }

  @override
  String get estrenoEstadoRecibida => 'Received';

  @override
  String get estrenoEstadoEnAtencion => 'In progress';

  @override
  String get estrenoEstadoCerrada => 'Closed';

  @override
  String estrenoTeAtiende(String nombre) {
    return '$nombre is helping you';
  }

  @override
  String get estrenoVacioTitulo => 'You have no requests yet';

  @override
  String get estrenoVacioMensaje =>
      'From the catalog you can book a test drive or get a quote.';

  @override
  String get estrenoVerMas => 'Show more';

  @override
  String get estrenoCargandoMas => 'Loading…';

  @override
  String get estrenoErrorMas =>
      'We could not load more requests. Please try again.';

  @override
  String get estrenoCargando => 'Loading your requests';

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

  @override
  String get privacidadTitulo => 'Privacy notice';

  @override
  String privacidadVersion(int version) {
    return 'Version $version';
  }

  @override
  String privacidadVigenteDesde(String fecha) {
    return 'In effect since $fecha';
  }

  @override
  String privacidadAceptadoEl(String fecha) {
    return 'You accepted it on $fecha';
  }

  @override
  String get privacidadCargando => 'Loading the privacy notice';

  @override
  String get privacidadAntesDeContinuar => 'Before you continue';

  @override
  String get privacidadIntro =>
      'Read the privacy notice. You need to accept it to use CareCar.';

  @override
  String get privacidadAceptar => 'I accept the privacy notice';

  @override
  String get privacidadGuardando => 'Saving…';

  @override
  String get privacidadNoAcepto => 'I don\'t accept, sign out';

  @override
  String get privacidadCambio =>
      'The notice changed while you were reading. The new one is up: read it and accept it if you agree.';

  @override
  String get privacidadErrorAceptar =>
      'We couldn\'t save your acceptance. Try again.';

  @override
  String get privacidadSinConexionAceptar =>
      'You\'re offline. Connect to save your acceptance.';

  @override
  String get privacidadHubTitulo => 'Privacy and my data';

  @override
  String get privacidadHubAviso => 'Privacy notice';

  @override
  String get privacidadHubAvisoDetalle => 'What we do with your data';

  @override
  String get privacidadHubDatos => 'Download my data';

  @override
  String get privacidadHubDatosDetalle => 'A copy of your personal data';

  @override
  String get arcoTitulo => 'My data';

  @override
  String get arcoIntro =>
      'You can ask for a copy of the personal data CareCar keeps for your account. It\'s a file you can save or share.';

  @override
  String get arcoAlcance =>
      'It doesn\'t include the tax and commercial records the dealership keeps by law (sales, payments and invoices): ask for them at the dealership.';

  @override
  String get arcoPedir => 'Ask for a copy of my data';

  @override
  String get arcoPidiendo => 'Requesting…';

  @override
  String get arcoPreparando => 'We\'re preparing your file';

  @override
  String get arcoPreparandoDetalle =>
      'It takes a few seconds. You can stay on this screen.';

  @override
  String get arcoLista => 'Your file is ready';

  @override
  String arcoVence(String fecha) {
    return 'Available until $fecha';
  }

  @override
  String get arcoCuidado =>
      'It contains personal information: keep it somewhere safe and don\'t share it.';

  @override
  String get arcoDescargar => 'Download my file';

  @override
  String get arcoDescargando => 'Preparing…';

  @override
  String get arcoPedirOtra => 'Ask for a new copy';

  @override
  String get arcoFallida => 'We couldn\'t prepare your file. Try again.';

  @override
  String get arcoVencida =>
      'Your file is no longer available. Ask for a new copy.';

  @override
  String get arcoErrorPedir => 'We couldn\'t request your copy. Try again.';

  @override
  String get arcoSinConexionPedir =>
      'You\'re offline. Connect to request your copy.';

  @override
  String get arcoErrorDescarga => 'We couldn\'t download your file. Try again.';

  @override
  String get arcoArchivoNoDisponible =>
      'The file is no longer available. Ask for a new copy.';

  @override
  String get arcoCargando => 'Loading your requests';

  @override
  String get privacidadHubEliminar => 'Delete my account';

  @override
  String get privacidadHubEliminarDetalle =>
      'Deletes your account and your personal data';

  @override
  String get eliminarCuentaTitulo => 'Delete my account';

  @override
  String get eliminarCuentaAdvertenciaTitulo => 'This can\'t be undone';

  @override
  String get eliminarCuentaAdvertencia =>
      'Your account is closed right away and we won\'t be able to recover it.';

  @override
  String get eliminarCuentaSeBorraTitulo => 'What gets deleted';

  @override
  String get eliminarCuentaBorra1 => 'Your name, email and phone number.';

  @override
  String get eliminarCuentaBorra2 =>
      'Your addresses, your questions to the assistant, your quotes and your new-car requests.';

  @override
  String get eliminarCuentaBorra3 =>
      'Your expense and mileage log, with its photos and receipts.';

  @override
  String get eliminarCuentaBorra4 =>
      'Your location and comments in roadside assistance requests.';

  @override
  String get eliminarCuentaConservaTitulo => 'What we keep';

  @override
  String get eliminarCuentaConserva =>
      'What we must keep for tax, commercial or warranty reasons: your vehicles\' service history, your purchases, payments and invoices, and the record that you accepted the privacy notice.';

  @override
  String get eliminarCuentaContrasena => 'Your password';

  @override
  String get eliminarCuentaContrasenaAyuda =>
      'We ask for it to confirm it\'s you.';

  @override
  String get eliminarCuentaDeslizar => 'Slide to delete my account';

  @override
  String get eliminarCuentaConfirmarMensaje =>
      'Your personal data is deleted and you won\'t be able to sign in with this account again. This can\'t be undone.';

  @override
  String get eliminarCuentaEliminando => 'Deleting your account…';

  @override
  String get eliminarCuentaListo =>
      'Your account was deleted. Thanks for using CareCar.';

  @override
  String get eliminarCuentaContrasenaIncorrecta =>
      'The password isn\'t correct.';

  @override
  String eliminarCuentaBloqueada(int minutos) {
    String _temp0 = intl.Intl.pluralLogic(
      minutos,
      locale: localeName,
      other: '$minutos minutes',
      one: '1 minute',
    );
    return 'Too many attempts. Try again in $_temp0.';
  }

  @override
  String get eliminarCuentaBloqueadaSinEspera =>
      'Too many attempts. Try again later.';

  @override
  String get eliminarCuentaSinConexion =>
      'You\'re offline. Check your connection and try again.';

  @override
  String get eliminarCuentaError =>
      'We couldn\'t delete your account. Try again.';

  @override
  String get asistenciaLlamarTitulo => 'Call now';

  @override
  String get asistenciaLlamarIntro =>
      'One tap opens your phone\'s dialer with the number. It works even without data.';

  @override
  String get asistenciaLlamarGrupo => 'Who to call';

  @override
  String get asistenciaLlamarEmergencias => 'Emergencies';

  @override
  String get asistenciaLlamarEmergenciasDetalle =>
      '911 · police, ambulance and fire';

  @override
  String get asistenciaLlamarAgencia => 'The dealership';

  @override
  String get asistenciaLlamarAseguradora => 'My insurer';

  @override
  String get asistenciaLlamarAseguradoraFalta =>
      'You haven\'t added your insurer yet';

  @override
  String get asistenciaLlamarAseguradoraComoAgregar =>
      'You haven\'t added your insurer yet. Add it in your car\'s documents (policy) and it will show up here to call with one tap.';

  @override
  String asistenciaLlamarAccion(String contacto) {
    return 'Call $contacto';
  }

  @override
  String asistenciaLlamarNoSePudo(String numero) {
    return 'We couldn\'t open the dialer. Dial $numero by hand.';
  }

  @override
  String get asistenciaLlamarAtajo => 'Call the dealership or 911';

  @override
  String get citasCalendarioAgregar => 'Add to calendar';

  @override
  String get citasCalendarioTitulo => 'Dealership appointment';

  @override
  String citasCalendarioDescripcion(String vehiculo) {
    return 'Vehicle: $vehiculo';
  }

  @override
  String get citasCalendarioError =>
      'We couldn\'t open your calendar. Try again.';

  @override
  String get mantenimientoRecordatorioEnVivo =>
      'Your next service is coming up. You can book it whenever you like.';

  @override
  String get mapaAyudaPin => 'Drag the pin, tap the map or use the arrows.';

  @override
  String get mapaConPin => 'Map with a pin.';

  @override
  String get mapaConUbicacion => 'Your location is shown.';

  @override
  String get mapaMiUbicacion => 'Show my location';

  @override
  String get mapaMoverEste => 'Move the pin east';

  @override
  String get mapaMoverNorte => 'Move the pin north';

  @override
  String get mapaMoverOeste => 'Move the pin west';

  @override
  String get mapaMoverSur => 'Move the pin south';

  @override
  String get mapaPinAlCentro => 'Place the pin in the center';

  @override
  String get mapaPinMovidoEste => 'Pin moved east';

  @override
  String get mapaPinMovidoNorte => 'Pin moved north';

  @override
  String get mapaPinMovidoOeste => 'Pin moved west';

  @override
  String get mapaPinMovidoSur => 'Pin moved south';

  @override
  String get mapaReintentar => 'Try again';

  @override
  String get mapaSeguimiento => 'Tracking map.';

  @override
  String get mapaSinPin => 'Map without a pin.';

  @override
  String get mapaSinTeselas =>
      'We couldn\'t load the map. Check your internet and try again.';

  @override
  String get mapaUbicacionApagada =>
      'Your phone\'s location is off. Turn it on and try again.';

  @override
  String get mapaUbicacionBloqueada =>
      'Location is blocked. Turn it on for CareCar in your phone settings.';

  @override
  String get mapaUbicacionDenegada =>
      'You didn\'t let us see your location. You can use the map without it.';

  @override
  String get mapaUbicacionTiempo => 'Your location took too long. Try again.';

  @override
  String get garantiaTitulo => 'Warranty';

  @override
  String get garantiaAcceso => 'Warranty';

  @override
  String garantiaKmActual(String km) {
    return 'Your car has $km km';
  }

  @override
  String get garantiaVaciaTitulo => 'No warranty on file';

  @override
  String get garantiaVaciaMensaje =>
      'When the dealership registers your car\'s warranty you\'ll see it here.';

  @override
  String get garantiaEstadoVigente => 'Active';

  @override
  String get garantiaEstadoPorVencer => 'Expiring soon';

  @override
  String get garantiaEstadoVencida => 'Expired';

  @override
  String garantiaVence(String fecha) {
    return 'Expires on $fecha';
  }

  @override
  String garantiaVenceOKm(String fecha, String km) {
    return 'Expires on $fecha or at $km km';
  }

  @override
  String garantiaQuedanDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String garantiaQuedanKm(String km) {
    return '$km km left';
  }

  @override
  String get garantiaVencidaPorFecha => 'Expired by date';

  @override
  String get garantiaVencidaPorKm => 'Expired by mileage';

  @override
  String get campanasTitulo => 'Recalls';

  @override
  String get campanasAcceso => 'Safety recalls';

  @override
  String get campanasAccesoResumen => 'Manufacturer recalls for your car';

  @override
  String get campanasInsignia => 'Safety recall';

  @override
  String get campanasVaciaTitulo => 'Your car has no recalls';

  @override
  String get campanasVaciaMensaje =>
      'If the manufacturer issues one for your car, we\'ll let you know.';

  @override
  String campanasCodigo(String codigo) {
    return 'Recall $codigo';
  }

  @override
  String get campanasGravedadBaja => 'Low severity';

  @override
  String get campanasGravedadMedia => 'Medium severity';

  @override
  String get campanasGravedadAlta => 'High severity';

  @override
  String get campanasGravedadCritica => 'Critical';

  @override
  String get campanasEstadoAbierta => 'Pending';

  @override
  String get campanasEstadoAgendada => 'Scheduled';

  @override
  String get campanasEstadoAtendida => 'Done';

  @override
  String get campanasQueHacer => 'What to do';

  @override
  String get campanasAvisoCritica =>
      'Take care of this recall as soon as possible';

  @override
  String get campanasAgendar => 'Schedule service';

  @override
  String get garantiaReintentar => 'Retry';

  @override
  String get campanasAgendarSinDia => 'Pick a day to see its times.';

  @override
  String get campanasAgendarSinHorarios => 'No times left that day.';

  @override
  String get campanasAgendarSinCupoRango =>
      'The shop has no open times right now. Try again later.';

  @override
  String get campanasAgendarVolver => 'Back to the recall';

  @override
  String get campanasVerCitas => 'See my appointments';

  @override
  String get campanasAgendarTitulo => 'Schedule recall';

  @override
  String get campanasAgendarDia => 'Pick a day';

  @override
  String get campanasAgendarHora => 'Pick a time';

  @override
  String get campanasAgendarConfirmar => 'Schedule';

  @override
  String get campanasAgendarSinCupo =>
      'That time slot filled up. Pick another.';

  @override
  String get campanasAgendarDuplicada =>
      'Your car already has an appointment that day. Pick another day.';

  @override
  String get campanasAgendarYaAgendada => 'This recall is already scheduled.';

  @override
  String get campanasAgendarError => 'We couldn\'t schedule it. Try again.';

  @override
  String get campanasAgendadaTitulo => 'Done, your appointment is booked';

  @override
  String campanasAgendadaMensaje(String fecha, String hora) {
    return 'We\'ll see you on $fecha at $hora.';
  }

  @override
  String get campanasQuePasa => 'What\'s wrong';

  @override
  String get campanasNoEncontradaTitulo => 'We can\'t find this recall anymore';

  @override
  String get campanasNoEncontradaMensaje =>
      'Go back to the list to see your car\'s recalls.';

  @override
  String get campanasVerComprobante => 'See confirmation';

  @override
  String get vehiculosManualBuscarAccion => 'Search the manual';

  @override
  String get vehiculosManualBuscarCerrar => 'Close search';

  @override
  String get vehiculosManualBuscarSugerencia => 'Search the manual';

  @override
  String get vehiculosManualBuscarAyuda =>
      'Type at least two letters to search the manual.';

  @override
  String vehiculosManualSinResultados(String consulta) {
    return 'We couldn’t find “$consulta” in the manual.';
  }

  @override
  String vehiculosManualResultadoPagina(int pagina) {
    return 'Page $pagina';
  }

  @override
  String get valuacionAceptar => 'Accept offer';

  @override
  String valuacionAceptarMensaje(String monto) {
    return 'You are about to accept the $monto offer. The dealer records your decision.';
  }

  @override
  String valuacionAgendadaMensaje(String dia, String hora) {
    return 'See you on $dia at $hora to inspect your car.';
  }

  @override
  String get valuacionAgendadaTitulo => 'Inspection booked';

  @override
  String get valuacionAgendadaVerCitas => 'See my appointments';

  @override
  String get valuacionAgendadaVolver => 'Back to the appraisal';

  @override
  String get valuacionAgendar => 'Book inspection';

  @override
  String get valuacionAgendarConfirmar => 'Confirm inspection';

  @override
  String get valuacionAgendarDia => 'Day';

  @override
  String get valuacionAgendarDuplicada =>
      'This car already has an appointment that day. Pick another day.';

  @override
  String get valuacionAgendarError =>
      'We could not book the inspection. Try again.';

  @override
  String get valuacionAgendarHorario => 'Time';

  @override
  String get valuacionAgendarNoAgendable =>
      'This appraisal already has an appointment or can no longer be booked. Check its details.';

  @override
  String get valuacionAgendarSinCupo =>
      'That time just filled up. Pick another one.';

  @override
  String get valuacionAgendarSinDia => 'Pick a day to see its times.';

  @override
  String get valuacionAgendarSinHorarios => 'No times left that day.';

  @override
  String get valuacionAgendarVacioMensaje =>
      'The workshop has no free times for now. Try again later.';

  @override
  String get valuacionAgendarVacioTitulo => 'No times available';

  @override
  String get valuacionAsesorDetalle => 'Your sales advisor for this appraisal';

  @override
  String get valuacionAsesorTitulo => 'Your advisor';

  @override
  String get valuacionAvanceTitulo => 'Progress';

  @override
  String get valuacionCargando => 'Loading the appraisal';

  @override
  String get valuacionDetalleTitulo => 'Formal appraisal';

  @override
  String get valuacionErrorMensaje => 'Try again in a moment.';

  @override
  String get valuacionErrorTitulo => 'We could not load this';

  @override
  String get valuacionEstadoAceptada => 'Accepted';

  @override
  String get valuacionEstadoCitaAgendada => 'Inspection booked';

  @override
  String get valuacionEstadoDesconocido => 'In review';

  @override
  String get valuacionEstadoOfertada => 'Offer received';

  @override
  String get valuacionEstadoRechazada => 'Declined';

  @override
  String get valuacionEstadoSolicitada => 'To be booked';

  @override
  String get valuacionEstadoVencida => 'Expired';

  @override
  String valuacionEstimadaEl(String fecha) {
    return 'Estimated on $fecha';
  }

  @override
  String get valuacionEstimadoRango => 'Estimated range';

  @override
  String get valuacionEstimadoTitulo => 'Starting estimate';

  @override
  String get valuacionFotoError => 'Upload failed. The photo is still here.';

  @override
  String get valuacionFotoGaleria => 'Choose from gallery';

  @override
  String get valuacionFotoInvalida =>
      'The dealer did not accept that image. Use a JPEG or PNG photo up to 8 MB.';

  @override
  String valuacionFotoPorSubir(String toma) {
    return 'Photo to upload: $toma';
  }

  @override
  String get valuacionFotoSinConexion =>
      'No connection. The photo is still here.';

  @override
  String valuacionFotoSubida(String toma) {
    return 'Uploaded photo: $toma';
  }

  @override
  String get valuacionFotoSubiendo => 'Uploading the photo';

  @override
  String get valuacionFotoTomar => 'Take photo';

  @override
  String get valuacionFotosAbrirAjustes => 'Open settings';

  @override
  String valuacionFotosAvance(int subidas, int total) {
    return '$subidas of $total photos';
  }

  @override
  String get valuacionFotosCerrada =>
      'This appraisal no longer accepts photos.';

  @override
  String get valuacionFotosGuiadasTitulo => 'Guided photos';

  @override
  String get valuacionFotosPrivacidad =>
      'You can book without all 8 photos. Each photo uploads on its own and the app does not keep it on your phone.';

  @override
  String get valuacionFotosSinCamara =>
      'We could not open the camera or the gallery. Try again.';

  @override
  String get valuacionFotosSinPermiso =>
      'No permission for the camera or photos. Turn it on in settings.';

  @override
  String get valuacionFotosSubir => 'Upload guided photos';

  @override
  String get valuacionFotosTitulo => 'Photos of your car';

  @override
  String get valuacionFotosVacio => 'You have not uploaded photos yet.';

  @override
  String valuacionInspeccionHorario(String inicio, String fin) {
    return 'From $inicio to $fin';
  }

  @override
  String get valuacionInspeccionTitulo => 'Inspection';

  @override
  String get valuacionInspeccionVerCitas => 'See in My appointments';

  @override
  String get valuacionInstruccionCajuela =>
      'Open the trunk and capture the whole cargo space.';

  @override
  String get valuacionInstruccionFrente =>
      'Stand in front, with the whole car and the plates in view.';

  @override
  String get valuacionInstruccionInteriorDelantero =>
      'Open the driver door and capture the front seats and the wheel.';

  @override
  String get valuacionInstruccionInteriorTrasero =>
      'Open a rear door and capture the whole back seat.';

  @override
  String get valuacionInstruccionLateralDerecho =>
      'Capture the passenger side, bumper to bumper.';

  @override
  String get valuacionInstruccionLateralIzquierdo =>
      'Capture the driver side, bumper to bumper.';

  @override
  String get valuacionInstruccionTableroKm =>
      'Turn the dashboard on and take a close, glare free shot of the mileage.';

  @override
  String get valuacionInstruccionTrasera =>
      'Stand behind, with the whole car and the plates in view.';

  @override
  String valuacionKm(String km) {
    return '$km km';
  }

  @override
  String get valuacionMisErrorMas =>
      'We could not load more appraisals. Try again.';

  @override
  String get valuacionMisTitulo => 'My appraisals';

  @override
  String get valuacionMisVacioAccion => 'Go to My estimates';

  @override
  String get valuacionMisVacioMensaje =>
      'Request a formal appraisal from an estimate made with one of your cars.';

  @override
  String get valuacionMisVacioTitulo => 'You have no appraisals yet';

  @override
  String get valuacionMisVerMas => 'See more';

  @override
  String get valuacionNoEncontradaMensaje =>
      'It may no longer exist or may not belong to your account.';

  @override
  String get valuacionNoEncontradaTitulo => 'We could not find that appraisal';

  @override
  String get valuacionOfertaAceptada =>
      'You accepted this offer. The dealer will follow up.';

  @override
  String valuacionOfertaConVigencia(String monto, String fecha) {
    return '$monto offer, valid until $fecha';
  }

  @override
  String get valuacionOfertaEtiqueta => 'Formal dealer offer';

  @override
  String get valuacionOfertaRechazada => 'You declined this offer.';

  @override
  String get valuacionOfertaTitulo => 'Your offer';

  @override
  String get valuacionOfertaVencida =>
      'Expired. You can no longer answer, but the dealer can renew it.';

  @override
  String valuacionOfertaVigencia(String fecha) {
    return 'Valid until $fecha';
  }

  @override
  String get valuacionPasoFotos => 'Photos';

  @override
  String get valuacionPasoInspeccion => 'Inspection';

  @override
  String get valuacionPasoOferta => 'Offer';

  @override
  String valuacionPedidaEl(String fecha) {
    return 'Requested on $fecha';
  }

  @override
  String get valuacionPedir => 'Request formal appraisal';

  @override
  String get valuacionPedirError =>
      'We could not request the appraisal. Try again.';

  @override
  String get valuacionPedirNoEncontrada => 'We could not find that estimate.';

  @override
  String get valuacionPedirSinVehiculo =>
      'This estimate was made by typing the car in. To appraise it, ask at the dealership.';

  @override
  String get valuacionRechazar => 'Decline offer';

  @override
  String get valuacionRechazarCancelar => 'Cancel';

  @override
  String get valuacionRechazarConfirmar => 'Yes, decline';

  @override
  String valuacionRechazarMensaje(String monto) {
    return 'You are about to decline the $monto offer. This cannot be undone.';
  }

  @override
  String get valuacionRechazarTitulo => 'Decline the offer?';

  @override
  String get valuacionReintentar => 'Try again';

  @override
  String get valuacionRespuestaError =>
      'We could not record your answer. Try again.';

  @override
  String get valuacionRespuestaNoDisponible =>
      'The offer changed and nothing was recorded. Check the current details.';

  @override
  String get valuacionRespuestaVencida =>
      'The offer expired and your answer was not recorded.';

  @override
  String get valuacionSinConexionAccion =>
      'No connection. Check your internet and try again.';

  @override
  String get valuacionSinConexionMensaje =>
      'Check your internet and try again.';

  @override
  String get valuacionSinConexionTitulo => 'No connection';

  @override
  String get valuacionTomaCajuela => 'Trunk';

  @override
  String get valuacionTomaFrente => 'Front';

  @override
  String get valuacionTomaInteriorDelantero => 'Front interior';

  @override
  String get valuacionTomaInteriorTrasero => 'Rear interior';

  @override
  String get valuacionTomaLateralDerecho => 'Right side';

  @override
  String get valuacionTomaLateralIzquierdo => 'Left side';

  @override
  String valuacionTomaNumero(int numero, String toma) {
    return '$numero. $toma';
  }

  @override
  String get valuacionTomaTableroKm => 'Dashboard with mileage';

  @override
  String get valuacionTomaTrasera => 'Rear';

  @override
  String get valuacionValorGrafica => 'Average estimated value by month';

  @override
  String get valuacionValorMedio => 'Average estimated value';

  @override
  String get valuacionValorNoEncontradoMensaje =>
      'It may no longer be in your garage.';

  @override
  String get valuacionValorNoEncontradoTitulo => 'We could not find that car';

  @override
  String valuacionValorRangoDelMes(String rango, String km) {
    return '$rango, at $km km';
  }

  @override
  String get valuacionValorRangos => 'Range for each month';

  @override
  String get valuacionValorTitulo => 'My car value';

  @override
  String get valuacionValorUnMes =>
      'The trend appears once you estimate your car in other months.';

  @override
  String get valuacionValorVacioAccion => 'Go to the calculator';

  @override
  String get valuacionValorVacioMensaje =>
      'Estimate this car with the calculator to see how its value changes.';

  @override
  String get valuacionValorVacioTitulo => 'No estimates for this car yet';

  @override
  String get valuacionVerValor => 'See how the value changes';

  @override
  String historialTicketPuntosGanados(String puntos) {
    return 'You earned $puntos loyalty points with this service.';
  }

  @override
  String get lealtadTitulo => 'My points';

  @override
  String get lealtadSubtitulo =>
      'Earn points with every service and redeem them at the dealership.';

  @override
  String lealtadPuntos(String puntos) {
    return '$puntos points';
  }

  @override
  String lealtadNivel(String nivel) {
    return '$nivel level';
  }

  @override
  String get lealtadNivelBronce => 'Bronze';

  @override
  String get lealtadNivelPlata => 'Silver';

  @override
  String get lealtadNivelOro => 'Gold';

  @override
  String lealtadFaltan(String puntos, String nivel) {
    return '$puntos more points to reach $nivel';
  }

  @override
  String get lealtadNivelMaximo => 'You\'re already at the top level.';

  @override
  String lealtadGanados(String puntos) {
    return '$puntos earned in 12 months';
  }

  @override
  String get lealtadCargando => 'Loading your points';

  @override
  String get lealtadReintentar => 'Try again';

  @override
  String get lealtadRecompensas => 'Rewards';

  @override
  String get lealtadRecompensasResumen => 'Redeem your points';

  @override
  String get lealtadCanjes => 'My redemptions';

  @override
  String get lealtadCanjesResumen => 'Codes to use at the dealership';

  @override
  String get lealtadMovimientos => 'Activity';

  @override
  String get lealtadMovimientosResumen => 'Where your points come from';

  @override
  String get lealtadReferir => 'Refer a friend';

  @override
  String get lealtadReferirResumen => 'Earn points if your friend buys a car';

  @override
  String get recompensasTitulo => 'Rewards';

  @override
  String recompensasSaldo(String puntos) {
    return 'You have $puntos points';
  }

  @override
  String get recompensasVaciaTitulo => 'No rewards yet';

  @override
  String get recompensasVaciaMensaje =>
      'When the dealership publishes rewards you\'ll see them here.';

  @override
  String recompensasCosto(String puntos) {
    return '$puntos points';
  }

  @override
  String recompensasTeFaltan(String puntos) {
    return '$puntos more needed';
  }

  @override
  String get recompensasAgotada => 'Sold out';

  @override
  String get recompensasDisponible => 'Available';

  @override
  String recompensasConfirmarTitulo(String recompensa) {
    return 'Redeem $recompensa?';
  }

  @override
  String recompensasConfirmarMensaje(String costo, String quedan) {
    return 'It costs $costo points. You\'ll have $quedan left.';
  }

  @override
  String get recompensasConfirmar => 'Redeem';

  @override
  String get recompensasCancelar => 'Cancel';

  @override
  String get recompensasNoSePudoTitulo => 'Couldn\'t redeem';

  @override
  String get recompensasSinSaldo =>
      'You no longer have enough points for this reward.';

  @override
  String get recompensasSeAgoto => 'This reward just sold out.';

  @override
  String get recompensasError =>
      'We couldn\'t redeem the reward. Please try again.';

  @override
  String get recompensasEntendido => 'Got it';

  @override
  String get canjesTitulo => 'My redemptions';

  @override
  String get canjesVaciaTitulo => 'No redemptions yet';

  @override
  String get canjesVaciaMensaje =>
      'Trade your points for rewards and their codes will show up here.';

  @override
  String get canjesVerRecompensas => 'See rewards';

  @override
  String canjesCodigo(String codigo) {
    return 'Code $codigo';
  }

  @override
  String canjesVence(String fecha) {
    return 'Expires on $fecha';
  }

  @override
  String canjesUsado(String fecha) {
    return 'Used on $fecha';
  }

  @override
  String canjesVencio(String fecha) {
    return 'Expired on $fecha; your points were returned';
  }

  @override
  String get canjesEstadoVigente => 'Active';

  @override
  String get canjesEstadoUsado => 'Used';

  @override
  String get canjesEstadoVencido => 'Expired';

  @override
  String get canjeMuestralo =>
      'Show this code at the cashier or service desk to use your reward.';

  @override
  String canjeQr(String codigo) {
    return 'QR code for redemption $codigo';
  }

  @override
  String get canjeYaUsado => 'This redemption was already used.';

  @override
  String get canjeYaVencio =>
      'This redemption expired unused and your points were returned.';

  @override
  String get canjeDetalles => 'Details';

  @override
  String get canjeCosto => 'Cost';

  @override
  String get canjeCanjeado => 'Redeemed';

  @override
  String get canjeVigencia => 'Valid until';

  @override
  String get canjeUsadoEl => 'Used';

  @override
  String get canjeNoEncontradoTitulo =>
      'We can\'t find this redemption anymore';

  @override
  String get canjeNoEncontradoMensaje =>
      'Go back to My redemptions to see your codes.';

  @override
  String get movimientosTitulo => 'Activity';

  @override
  String get movimientosVaciaTitulo => 'No activity yet';

  @override
  String get movimientosVaciaMensaje =>
      'You earn points every time you pick up your car from service.';

  @override
  String get movimientosMotivoServicio => 'Service visit';

  @override
  String get movimientosMotivoCanje => 'Reward redemption';

  @override
  String get movimientosMotivoDevolucion => 'Expired redemption';

  @override
  String get movimientosMotivoReferido => 'Referred friend';

  @override
  String get movimientosMotivoAjuste => 'Dealership adjustment';

  @override
  String get movimientosMotivoOtro => 'Activity';

  @override
  String movimientosOrden(int id) {
    return 'Order $id';
  }

  @override
  String movimientosCanje(int id) {
    return 'Redemption $id';
  }

  @override
  String movimientosFechaYReferencia(String fecha, String referencia) {
    return '$fecha · $referencia';
  }

  @override
  String movimientosGanaste(String puntos) {
    return 'You earned $puntos points';
  }

  @override
  String movimientosUsaste(String puntos) {
    return 'You used $puntos points';
  }

  @override
  String get movimientosCargandoMas => 'Loading more activity';

  @override
  String get movimientosErrorMas => 'We couldn\'t load more activity.';

  @override
  String get referirTitulo => 'Refer a friend';

  @override
  String get referirSubtitulo => 'If your friend buys a car, you earn points.';

  @override
  String get referirCodigoTitulo => 'Your code';

  @override
  String get referirCodigoAyuda =>
      'Your friend mentions it when visiting the dealership.';

  @override
  String get referirCompartir => 'Share my code';

  @override
  String referirMensaje(String codigo) {
    return 'I recommend the dealership. Mention my code $codigo when you go.';
  }

  @override
  String get referirFormularioTitulo => 'Sign up your friend';

  @override
  String get referirFormularioNota =>
      'Enter their phone, email or both. The dealership only uses them to contact your friend.';

  @override
  String get referirNombre => 'Your friend\'s name';

  @override
  String get referirTelefono => 'Phone';

  @override
  String get referirTelefonoAyuda => '10 digits';

  @override
  String get referirTelefonoInvalido => 'Enter all 10 digits.';

  @override
  String get referirCorreo => 'Email';

  @override
  String get referirCorreoInvalido => 'Check the email.';

  @override
  String get referirConsentimiento =>
      'My friend agreed to be contacted by the dealership';

  @override
  String get referirEnviar => 'Send';

  @override
  String referirEnviado(String nombre) {
    return 'Done, the dealership will contact $nombre.';
  }

  @override
  String get referirDuplicado => 'That person is already with the dealership.';

  @override
  String get referirLimite =>
      'You already have the maximum friends in follow-up. Wait until the dealership reaches them.';

  @override
  String get referirError =>
      'We couldn\'t sign up your friend. Please try again.';

  @override
  String get referirListaTitulo => 'Your referrals';

  @override
  String get referirVacio => 'You haven\'t referred anyone yet.';

  @override
  String get referirListaError => 'We couldn\'t load your referrals.';

  @override
  String get referirPuntosAyuda =>
      'You earn points once for each friend who buys.';

  @override
  String get referidoEstadoRegistrado => 'Registered';

  @override
  String get referidoEstadoSeguimiento => 'In follow-up';

  @override
  String get referidoEstadoCompro => 'Bought';

  @override
  String get referidoEstadoDescartado => 'No purchase';

  @override
  String referidoDesde(String estado, String fecha) {
    return '$estado · since $fecha';
  }

  @override
  String referidoGanaste(String puntos) {
    return '+$puntos';
  }

  @override
  String get estadoErrorTitulo => 'We could not load this';

  @override
  String get estadoErrorMensaje => 'Try again in a moment.';

  @override
  String get estadoErrorSinConexionTitulo => 'No connection';

  @override
  String get estadoErrorSinConexionMensaje =>
      'Check your internet and try again.';

  @override
  String get estadoErrorReintentar => 'Retry';

  @override
  String citasMisCitasCuando(String dia, String inicio, String fin) {
    return '$dia, $inicio - $fin';
  }

  @override
  String citasMisCitasVehiculoYMotivo(String vehiculo, String motivo) {
    return '$vehiculo · $motivo';
  }

  @override
  String get datosFiscalesTitulo => 'Tax details';

  @override
  String get datosFiscalesSubtitulo => 'To invoice your services';

  @override
  String get datosFiscalesCargando => 'Loading your tax details';

  @override
  String get datosFiscalesReintentar => 'Try again';

  @override
  String get datosFiscalesVacioTitulo => 'You don\'t have tax details yet';

  @override
  String get datosFiscalesVacioMensaje =>
      'Add them to request invoices for your services.';

  @override
  String get datosFiscalesAgregar => 'Add tax details';

  @override
  String get datosFiscalesEncabezado => 'Your profiles';

  @override
  String get datosFiscalesPie =>
      'Enter them as they appear on your tax certificate. For now the app\'s invoices are simulated and have no tax validity.';

  @override
  String datosFiscalesFilaSubtitulo(
    String rfc,
    String persona,
    String regimen,
  ) {
    return '$rfc · $persona · Regime $regimen';
  }

  @override
  String get datosFiscalesPredeterminado => 'Default';

  @override
  String get datosFiscalesNuevoTitulo => 'New tax details';

  @override
  String get datosFiscalesEditarTitulo => 'Edit tax details';

  @override
  String get datosFiscalesSeccionContribuyente => 'Taxpayer';

  @override
  String get datosFiscalesSeccionFacturar => 'For invoicing';

  @override
  String get datosFiscalesRfc => 'RFC';

  @override
  String get datosFiscalesRfcSugerencia => 'GODE561231GR8';

  @override
  String get datosFiscalesRfcAyuda =>
      '13 characters for an individual; 12 for a company.';

  @override
  String get datosFiscalesPersonaFisica => 'Individual';

  @override
  String get datosFiscalesPersonaMoral => 'Company';

  @override
  String get datosFiscalesRazonSocial => 'Name or company name';

  @override
  String get datosFiscalesRazonSocialAyuda =>
      'As on your certificate, without the company type (S.A. de C.V.).';

  @override
  String get datosFiscalesCodigoPostal => 'Tax postal code';

  @override
  String get datosFiscalesCodigoPostalAyuda => 'The one of your tax address.';

  @override
  String get datosFiscalesRegimen => 'Tax regime';

  @override
  String get datosFiscalesRegimenSugerencia => 'Choose your regime';

  @override
  String get datosFiscalesUso => 'CFDI use';

  @override
  String get datosFiscalesUsoSugerencia => 'Choose the use';

  @override
  String get datosFiscalesUsoAyuda =>
      'Only the ones your regime accepts are shown.';

  @override
  String datosFiscalesOpcion(String clave, String descripcion) {
    return '$clave · $descripcion';
  }

  @override
  String get datosFiscalesCorreo => 'Email for the invoice (optional)';

  @override
  String get datosFiscalesHacerPredeterminado => 'Use as default';

  @override
  String get datosFiscalesHacerPredeterminadoAyuda =>
      'It\'s the one suggested when paying.';

  @override
  String get datosFiscalesGuardar => 'Save';

  @override
  String get datosFiscalesBorrar => 'Delete';

  @override
  String get datosFiscalesBorrarTitulo => 'Delete these tax details?';

  @override
  String datosFiscalesBorrarMensaje(String rfc) {
    return 'Profile $rfc will be deleted. Invoices you already have won\'t change.';
  }

  @override
  String get datosFiscalesBorrarConfirmar => 'Delete';

  @override
  String get datosFiscalesBorrarCancelar => 'Cancel';

  @override
  String get datosFiscalesRevisa => 'Check the highlighted fields.';

  @override
  String get datosFiscalesSinConexion =>
      'No connection. Check your internet and try again.';

  @override
  String get datosFiscalesErrorGuardar =>
      'We couldn\'t save your tax details. Please try again.';

  @override
  String get datosFiscalesErrorBorrar =>
      'We couldn\'t delete these tax details. Please try again.';

  @override
  String get datosFiscalesNoEncontradoTitulo =>
      'We can\'t find these tax details anymore';

  @override
  String get datosFiscalesNoEncontradoMensaje =>
      'Go back to Tax details to see your profiles.';

  @override
  String get datosFiscalesErrorRfcVacio => 'Enter the RFC.';

  @override
  String get datosFiscalesErrorRfcLargo =>
      'The RFC has 12 characters (company) or 13 (individual).';

  @override
  String get datosFiscalesErrorRfcForma =>
      'The RFC doesn\'t have the SAT format.';

  @override
  String get datosFiscalesErrorRfcGenerico =>
      'The generic RFC can\'t be used in a profile.';

  @override
  String get datosFiscalesErrorRfcFecha => 'The RFC date doesn\'t exist.';

  @override
  String get datosFiscalesErrorRfcDigito =>
      'The last character doesn\'t match; check the homoclave.';

  @override
  String get datosFiscalesErrorRazonVacia => 'Enter the name or company name.';

  @override
  String get datosFiscalesErrorRazonLarga => 'The name is too long.';

  @override
  String get datosFiscalesErrorCodigoPostal => 'Enter all 5 digits.';

  @override
  String get datosFiscalesErrorRegimenFalta => 'Choose your tax regime.';

  @override
  String get datosFiscalesErrorRegimenNoAplica =>
      'That regime doesn\'t apply to your taxpayer type.';

  @override
  String get datosFiscalesErrorUsoFalta => 'Choose the CFDI use.';

  @override
  String get datosFiscalesErrorUsoNoAplica =>
      'That use doesn\'t apply to your taxpayer type.';

  @override
  String get datosFiscalesErrorUsoNoAceptaRegimen =>
      'That use isn\'t allowed with your regime.';

  @override
  String get datosFiscalesErrorCorreo => 'Check the email.';

  @override
  String get pagosCargando => 'Loading your payments';

  @override
  String get pagosReintentar => 'Try again';

  @override
  String get pagosSimuladoAviso =>
      'Simulated payment: nothing is charged. Use one of the test cards.';

  @override
  String get pagosSimuladoPie =>
      'App payments are simulated: nothing was charged.';

  @override
  String get pagosSimuladoCorto => 'Simulated payment: nothing was charged.';

  @override
  String get pagosEnCaja => 'It was paid at the dealership\'s cashier.';

  @override
  String get pagosPagarTitulo => 'Pay order';

  @override
  String pagosOrden(String orden) {
    return 'Order $orden';
  }

  @override
  String get pagosDesglose => 'What you pay';

  @override
  String get pagosManoDeObra => 'Labor';

  @override
  String get pagosRefacciones => 'Parts';

  @override
  String get pagosSubtotal => 'Subtotal before VAT';

  @override
  String get pagosIva => 'VAT';

  @override
  String get pagosTotal => 'Total';

  @override
  String get pagosPreciosConIva => 'Prices include VAT.';

  @override
  String get pagosConQue => 'How you pay';

  @override
  String get pagosTarjeta => 'Card';

  @override
  String get pagosOtraTarjeta => 'Another card';

  @override
  String pagosTarjetaVencida(String tarjeta) {
    return '$tarjeta (expired)';
  }

  @override
  String get pagosNumero => 'Card number';

  @override
  String get pagosNumeroSugerencia => '4242 4242 4242 4242';

  @override
  String get pagosVencimiento => 'Expires (MM/YY)';

  @override
  String get pagosVencimientoSugerencia => '12/28';

  @override
  String get pagosCvv => 'CVV';

  @override
  String get pagosCvvAyuda =>
      'The number and the CVV never leave your phone: only a test card token is sent.';

  @override
  String get pagosGuardarTarjeta => 'Save card';

  @override
  String get pagosGuardarTarjetaAyuda =>
      'To pay faster. Only the brand, the last 4 and the expiration date are saved.';

  @override
  String get pagosTarjetasDePrueba => 'Test cards';

  @override
  String get pagosTarjetasDePruebaPie =>
      'Tap one to fill in its number. Any future expiration date and any 3-digit CVV work.';

  @override
  String pagosTarjetaDePruebaDetalle(String marca, String escenario) {
    return '$marca · $escenario';
  }

  @override
  String get pagosEscenarioAprobada => 'Gets approved';

  @override
  String get pagosEscenarioFondos => 'Declined for insufficient funds';

  @override
  String get pagosEscenarioConfirmar => 'Your bank asks you to confirm';

  @override
  String get pagosEscenarioConfirmacionFalla => 'Your bank does not confirm';

  @override
  String get pagosFactura => 'Invoice';

  @override
  String get pagosDatosFiscales => 'Tax details';

  @override
  String get pagosFacturaAyuda =>
      'With your tax details, the simulated invoice is issued when you pay.';

  @override
  String get pagosSinFactura => 'No invoice';

  @override
  String pagosPerfilFiscal(String rfc, String razonSocial) {
    return '$rfc · $razonSocial';
  }

  @override
  String pagosPagar(String monto) {
    return 'Pay $monto';
  }

  @override
  String get pagosRevisaTarjeta => 'Check the card details.';

  @override
  String get pagosSinConexion =>
      'No connection. Check your internet and try again; you won\'t be charged twice.';

  @override
  String get pagosErrorPagar => 'We couldn\'t process the payment. Try again.';

  @override
  String get pagosOrdenNoPagable =>
      'This order can no longer be paid in the app.';

  @override
  String get pagosPagoEnCurso =>
      'A payment for this order is already waiting for your bank\'s confirmation. Check it in My payments.';

  @override
  String get pagosPagoNoPendiente =>
      'This payment is no longer waiting for your bank\'s confirmation.';

  @override
  String get pagosErrorNumeroVacio => 'Enter the card number.';

  @override
  String get pagosErrorNumeroIncompleto => 'The number has 16 digits.';

  @override
  String get pagosErrorNumeroInvalido => 'That number isn\'t valid; check it.';

  @override
  String get pagosErrorNoEsDePrueba => 'Use one of the test cards.';

  @override
  String get pagosErrorVencimientoVacio => 'Enter the expiration date.';

  @override
  String get pagosErrorVencimientoInvalido => 'Write it as MM/YY.';

  @override
  String get pagosErrorVencida => 'The card has expired.';

  @override
  String get pagosErrorCvv => 'The CVV has 3 digits.';

  @override
  String get pagosBancoTitulo => 'Your bank asks you to confirm';

  @override
  String pagosBancoMensaje(String monto, String tarjeta) {
    return 'Confirm the $monto payment with $tarjeta. This bank screen is simulated.';
  }

  @override
  String get pagosBancoConfirmar => 'Confirm';

  @override
  String get pagosBancoCancelar => 'Cancel';

  @override
  String get pagosPagadoTitulo => 'Order paid!';

  @override
  String pagosPagadoMensaje(String monto, String referencia) {
    return 'You paid $monto. Reference $referencia. It\'s a simulated payment: nothing was charged.';
  }

  @override
  String get pagosListo => 'Done';

  @override
  String get pagosVerMisPagos => 'See my payments';

  @override
  String get pagosFalloTitulo => 'The payment didn\'t go through';

  @override
  String get pagosIntentarOtraVez => 'Try again';

  @override
  String get pagosVolver => 'Go back';

  @override
  String get pagosMotivoFondos =>
      'Your bank declined the card for insufficient funds.';

  @override
  String get pagosMotivoAutenticacion =>
      'Your bank didn\'t confirm the payment.';

  @override
  String get pagosMotivoVencida => 'Nobody confirmed the payment in time.';

  @override
  String get pagosMotivoCaja => 'The order was paid at the cashier.';

  @override
  String get pagosMotivoOtro => 'The payment wasn\'t completed.';

  @override
  String get pagosYaPagadaTitulo => 'This order is already paid';

  @override
  String pagosYaPagadaMensaje(String medio, String fecha) {
    return 'With $medio on $fecha.';
  }

  @override
  String get pagosVerPago => 'See the payment';

  @override
  String get pagosNoPagableTitulo => 'This order can\'t be paid yet';

  @override
  String get pagosNoPagableMensaje =>
      'It can be paid in the app when it\'s ready for pickup. A service registered as already done is paid at the dealership.';

  @override
  String get pagosMisPagosTitulo => 'My payments';

  @override
  String get pagosMisPagosSubtitulo => 'Newest first';

  @override
  String get pagosMisPagosVacioTitulo => 'You don\'t have payments yet';

  @override
  String get pagosMisPagosVacioMensaje =>
      'What you pay from the app will show up here.';

  @override
  String pagosFilaSubtitulo(String estado, String medio, String fecha) {
    return '$estado · $medio · $fecha';
  }

  @override
  String pagosMontoConEstado(String monto, String estado) {
    return '$monto, $estado';
  }

  @override
  String get pagosCargandoMas => 'Loading more payments';

  @override
  String get pagosErrorCargarMas => 'We couldn\'t load more payments.';

  @override
  String get pagosEstadoPendiente => 'Pending';

  @override
  String get pagosEstadoPagado => 'Paid';

  @override
  String get pagosEstadoFallido => 'Failed';

  @override
  String get pagosEstadoReembolsado => 'Refunded';

  @override
  String pagosMedioTarjeta(String marca, String ultimos4) {
    return '$marca •••• $ultimos4';
  }

  @override
  String get pagosMedioCaja => 'At the cashier';

  @override
  String get pagosMedioApplePay => 'Apple Pay (simulated)';

  @override
  String get pagosMedioGooglePay => 'Google Pay (simulated)';

  @override
  String get pagosPagoTitulo => 'Payment';

  @override
  String get pagosMonto => 'Amount';

  @override
  String get pagosMedio => 'Paid with';

  @override
  String get pagosFechaPago => 'Paid on';

  @override
  String get pagosFechaIntento => 'Attempted on';

  @override
  String get pagosReferencia => 'Reference';

  @override
  String get pagosMotivo => 'Why it wasn\'t charged';

  @override
  String get pagosConfirmarBanco => 'Confirm with your bank';

  @override
  String get pagosVerTicket => 'See the receipt';

  @override
  String get pagosPagarPedidoTitulo => 'Pay store order';

  @override
  String pagosPedido(String pedido) {
    return 'Store order $pedido';
  }

  @override
  String get pagosPedidoYaPagadoTitulo => 'This store order is already paid';

  @override
  String get pagosPedidoNoPagableTitulo =>
      'This store order can\'t be paid in the app';

  @override
  String get pagosPedidoNoPagableMensaje =>
      'It can be paid in the app while it\'s reserved or ready and hasn\'t expired. Otherwise, pay at the counter.';

  @override
  String get pagosPedidoNoPagable =>
      'This store order can no longer be paid in the app.';

  @override
  String get pagosPedidoPagoEnCurso =>
      'A payment for this store order is already waiting for your bank\'s confirmation. Check it in My payments.';

  @override
  String get pagosPedidoPagadoTitulo => 'Store order paid!';

  @override
  String get pagosVerPedido => 'See the store order';

  @override
  String get pagosNoEncontradoTitulo => 'We couldn\'t find this payment';

  @override
  String get pagosNoEncontradoMensaje =>
      'It may belong to another account. Check My payments.';

  @override
  String get pagosMetodosTitulo => 'Payment methods';

  @override
  String get pagosMetodosVacioTitulo => 'You don\'t have saved cards yet';

  @override
  String get pagosMetodosVacioMensaje =>
      'When you pay, check «Save card» so it shows up here.';

  @override
  String get pagosMetodosPie =>
      'Only the brand, the last 4 and the expiration date of test cards are saved.';

  @override
  String pagosVence(String vence) {
    return 'Expires $vence';
  }

  @override
  String pagosVenceYTipo(String vence, String tipo) {
    return 'Expires $vence · $tipo';
  }

  @override
  String get pagosCredito => 'Credit';

  @override
  String get pagosDebito => 'Debit';

  @override
  String get pagosPredeterminada => 'Default';

  @override
  String get pagosVencidaInsignia => 'Expired';

  @override
  String get pagosUsarPredeterminada => 'Use as default';

  @override
  String get pagosBorrarTarjeta => 'Delete card';

  @override
  String get pagosBorrarTitulo => 'Delete this card?';

  @override
  String pagosBorrarMensaje(String tarjeta) {
    return '$tarjeta will no longer show up when paying. Payments you made with it are kept.';
  }

  @override
  String get pagosBorrarConfirmar => 'Delete';

  @override
  String get pagosBorrarCancelar => 'Cancel';

  @override
  String get pagosErrorMetodo => 'We couldn\'t save the change. Try again.';

  @override
  String get historialTicketPago => 'Payment';

  @override
  String get historialTicketPagado => 'Paid';

  @override
  String historialTicketPagadoDetalle(String medio, String fecha) {
    return '$medio · $fecha';
  }

  @override
  String get historialTicketPagadoEnCaja => 'At the cashier';

  @override
  String historialTicketTarjeta(String marca, String ultimos4) {
    return '$marca •••• $ultimos4';
  }

  @override
  String get historialTicketReferencia => 'Reference';

  @override
  String historialTicketPagar(String monto) {
    return 'Pay $monto';
  }

  @override
  String get pagosBilleteraApplePay => 'Pay with Apple Pay';

  @override
  String get pagosBilleteraGooglePay => 'Pay with Google Pay';

  @override
  String get pagosBilleteraAyuda =>
      'Simulated wallet: it is always approved and never saved. Below you can pay with a card.';

  @override
  String pagosBilleteraMensaje(String monto, String billetera) {
    return 'You are about to pay $monto with $billetera. It is simulated: nothing is charged.';
  }

  @override
  String get pagosBilleteraConfirmar => 'Pay';

  @override
  String get pagosBilleteraCancelar => 'Cancel';

  @override
  String pagosPagadoFacturaMensaje(String monto, String referencia) {
    return 'You paid $monto. Reference $referencia. The simulated invoice is in the payment details. Nothing was charged.';
  }

  @override
  String get pagosVerFactura => 'View the invoice';

  @override
  String pagosFacturaFolio(String folio) {
    return 'Invoice $folio';
  }

  @override
  String get pagosFacturaTimbrada => 'Stamped';

  @override
  String get pagosFacturaFolioFiscal => 'Tax folio';

  @override
  String pagosFacturaReceptor(String usoCfdi) {
    return 'Recipient · use $usoCfdi';
  }

  @override
  String get pagosFacturaPdf => 'Download PDF';

  @override
  String get pagosFacturaXml => 'Download XML';

  @override
  String get pagosFacturaSimulada =>
      'Simulated invoice with a CFDI 4.0 structure, not valid for tax purposes.';

  @override
  String get pagosFacturaErrorDescargar =>
      'The invoice could not be downloaded. Try again.';

  @override
  String get pagosFacturar => 'Invoice';

  @override
  String get pagosFacturarAyuda =>
      'These details are used to stamp the simulated invoice for this payment.';

  @override
  String get pagosFacturaSinPerfiles =>
      'To invoice this payment add your tax details.';

  @override
  String get pagosAgregarDatosFiscales => 'Add tax details';

  @override
  String get pagosTimbradoRechazado =>
      'The stamping rejected your tax details.';

  @override
  String get pagosTimbradoRazonSocial =>
      'Write the company name as on your tax certificate, without the legal form (no «S.A. de C.V.»).';

  @override
  String get pagosTimbradoCodigoPostal =>
      'Check the postal code of your tax address.';

  @override
  String get pagosTimbradoOtro => 'Check your tax details.';

  @override
  String get pagosCorregirDatosFiscales => 'Fix tax details';

  @override
  String get pagosFacturaYaFacturada => 'This payment already has an invoice.';

  @override
  String get pagosFacturaNoFacturable =>
      'This payment cannot be invoiced from the app.';

  @override
  String get pagosFacturaErrorFacturar =>
      'The payment could not be invoiced. Try again.';

  @override
  String get pagosFacturaEnLaAgencia =>
      'Payments at the cashier are invoiced at the dealership.';

  @override
  String get pagosFacturaSinConexion =>
      'No connection. Check your internet and try again.';

  @override
  String get sucursalesTitulo => 'Branches';

  @override
  String get sucursalesCargando => 'Loading branches';

  @override
  String get sucursalesVacioTitulo => 'No branches yet';

  @override
  String get sucursalesVacioMensaje =>
      'When the dealership publishes its branches, you\'ll see them here with a map and opening hours.';

  @override
  String sucursalesMapaDe(String nombre) {
    return 'Map showing the location of $nombre';
  }

  @override
  String get sucursalesAbiertoAhora => 'Open now';

  @override
  String get sucursalesAbierto => 'Open';

  @override
  String get sucursalesCerrado => 'Closed';

  @override
  String get sucursalesLlamar => 'Call';

  @override
  String get sucursalesComoLlegar => 'Get directions';

  @override
  String get sucursalesHorarios => 'Opening hours';

  @override
  String get sucursalesTodas => 'All branches';

  @override
  String get sucursalesSeleccionada => 'Selected';

  @override
  String sucursalesDepartamento(String departamento) {
    String _temp0 = intl.Intl.selectLogic(departamento, {
      'ventas': 'Sales',
      'servicio': 'Service',
      'refacciones': 'Parts',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String sucursalesDiaCorto(String dia) {
    String _temp0 = intl.Intl.selectLogic(dia, {
      '1': 'Mon',
      '2': 'Tue',
      '3': 'Wed',
      '4': 'Thu',
      '5': 'Fri',
      '6': 'Sat',
      '7': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String sucursalesDiasRango(String desde, String hasta) {
    return '$desde to $hasta';
  }

  @override
  String sucursalesTramo(String dias, String abre, String cierra) {
    return '$dias: $abre to $cierra';
  }

  @override
  String sucursalesDescripcionFila(
    String nombre,
    String estado,
    String direccion,
  ) {
    return '$nombre, $estado. $direccion';
  }

  @override
  String get sucursalesNoSePudoLlamar => 'We couldn\'t open the phone dialer.';

  @override
  String get sucursalesNoSePudoMapa => 'We couldn\'t open the maps app.';

  @override
  String get recoleccionSeguimientoMarcadorChofer => 'Your driver';

  @override
  String get contactoTitulo => 'Contact';

  @override
  String get contactoIntro =>
      'Choose how you\'d like to reach the agency. Your main branch will help you.';

  @override
  String get contactoGrupoMedios => 'Ways to reach us';

  @override
  String get contactoLlamar => 'Call the agency';

  @override
  String get contactoCorreo => 'Send an email';

  @override
  String get contactoGrupoDonde => 'Where we are';

  @override
  String get contactoVerSucursales => 'Branches and hours';

  @override
  String get contactoVerSucursalesDetalle => 'Map, hours and directions';

  @override
  String contactoNoSePudoCorreo(String correo) {
    return 'We couldn\'t open your email app. Write to us at $correo.';
  }

  @override
  String get documentosTitulo => 'Documents';

  @override
  String get documentosCargando => 'Loading documents';

  @override
  String get documentosVaciaTitulo => 'No documents yet';

  @override
  String get documentosVaciaMensaje =>
      'Your policy, registration card and inspection will live here, with their due dates.';

  @override
  String documentosSubtitulo(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total documents',
      one: '1 document',
    );
    return '$_temp0';
  }

  @override
  String documentosResumenAtencion(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad documents need attention',
      one: '1 document needs attention',
    );
    return '$_temp0';
  }

  @override
  String get documentosResumenAlDia => 'All in order';

  @override
  String get documentosResumenAlDiaDetalle => 'Your documents are up to date.';

  @override
  String documentosResumenVence(String nombre, String cuando) {
    return '$nombre is due $cuando.';
  }

  @override
  String documentosResumenVencio(String nombre, String cuando) {
    return '$nombre expired $cuando.';
  }

  @override
  String get documentosGrupoPorVencer => 'Due soon';

  @override
  String get documentosGrupoVencidos => 'Expired';

  @override
  String get documentosGrupoVigentes => 'Valid';

  @override
  String get documentosGrupoSinFecha => 'No expiry date';

  @override
  String get documentosEstadoVigente => 'Valid';

  @override
  String get documentosEstadoPorVencer => 'Due soon';

  @override
  String get documentosEstadoVencido => 'Expired';

  @override
  String get documentosEstadoSinFecha => 'No date';

  @override
  String documentosVenceEl(String fecha) {
    return 'Expires on $fecha';
  }

  @override
  String documentosVencioEl(String fecha) {
    return 'Expired on $fecha';
  }

  @override
  String documentosEnDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'in $dias days',
      one: 'tomorrow',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String documentosHaceDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String documentosNumero(String numero) {
    return 'No. $numero';
  }

  @override
  String get documentosCargadoPorAgencia => 'Uploaded by the dealership';

  @override
  String get documentosTipoPoliza => 'Insurance policy';

  @override
  String get documentosTipoTarjetaCirculacion => 'Registration card';

  @override
  String get documentosTipoVerificacion => 'Vehicle inspection';

  @override
  String get documentosTipoTenencia => 'Vehicle tax';

  @override
  String get documentosTipoLicencia => 'Driver\'s license';

  @override
  String get documentosTipoGarantia => 'Warranty policy';

  @override
  String get documentosTipoFactura => 'Purchase invoice';

  @override
  String get documentosTipoOtro => 'Other document';

  @override
  String get asistenciaLlamarAseguradoraBuscando => 'Looking for your policy…';

  @override
  String get ayudaAcerca => 'About CareCar';

  @override
  String get ayudaVersion => 'Version';

  @override
  String get ayudaCargando => 'Loading…';

  @override
  String get ayudaLicencias => 'Software licenses';

  @override
  String get ayudaLicenciasDetalle => 'Components included in the app';

  @override
  String get ayudaPrivacidad => 'Privacy notice';

  @override
  String get ayudaTerminos => 'Terms of use';

  @override
  String get ayudaTerminosAusentes => 'The document is unavailable.';

  @override
  String get ayudaCerrar => 'Close';

  @override
  String get documentosCalendario => 'Expiration calendar';

  @override
  String get documentosVencimientos => 'Expirations';

  @override
  String get documentosErrorCalendario => 'Could not load expirations';

  @override
  String documentosCantidad(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad expirations',
      one: '1 expiration',
    );
    return '$_temp0';
  }

  @override
  String get documentosDelMes => 'Expirations this month';

  @override
  String get documentosVerMes => 'View full month';

  @override
  String get documentosMesVacio => 'No expirations this month.';

  @override
  String get documentosDiaVacio => 'No expirations on this day.';

  @override
  String documentosDetalle(String fecha, String vehiculo) {
    return '$fecha · $vehiculo';
  }

  @override
  String get ayudaBuscar => 'Search';

  @override
  String get ayudaBuscarSugerencia => 'Enter a question or topic';

  @override
  String get ayudaDescripcion => 'Description';

  @override
  String get ayudaDescripcionPista => 'Tell us what happened';

  @override
  String get ayudaEnviado => 'Report sent';

  @override
  String get ayudaEnviar => 'Send report';

  @override
  String get ayudaErrorReporte => 'Could not send your report. Try again.';

  @override
  String get ayudaGracias => 'Thanks for helping us improve.';

  @override
  String get ayudaLongitud => 'Describe the problem in 10 to 2,000 characters.';

  @override
  String get ayudaOtrasPalabras => 'Try different keywords.';

  @override
  String get ayudaPreguntas => 'Frequently asked questions';

  @override
  String get ayudaPrivacidadReporte =>
      'Your report includes the CareCar version, operating system and device model. Avoid including personal details.';

  @override
  String get ayudaReporte => 'Report a problem';

  @override
  String get ayudaSinResultados => 'No results';

  @override
  String get documentosPdfAgencia => 'Dealership document';

  @override
  String get documentosAgregar => 'Add document';

  @override
  String get documentosAgregarFecha => 'Add expiration date';

  @override
  String get documentosCamara => 'Take photo';

  @override
  String get documentosErrorFoto => 'Could not prepare the photo.';

  @override
  String get documentosErrorGuardar =>
      'Could not save the document. Try again.';

  @override
  String get documentosFaltaFoto => 'Select an image of the document.';

  @override
  String get documentosGaleria => 'Choose from gallery';

  @override
  String get documentosGuardar => 'Save document';

  @override
  String get documentosProgreso => 'Document upload';

  @override
  String get documentosTipo => 'Document type';

  @override
  String get documentosVistaPrevia => 'Document preview';
}
