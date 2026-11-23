// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get citasCargando => 'Loading workshop availability';

  @override
  String get citasCargandoAgendar =>
      'Loading your vehicles and the workshop times';

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
  String get avisoCerrar => 'Close notice';

  @override
  String get navegacionPrincipal => 'Main navigation';

  @override
  String botonCargando(String texto) {
    return '$texto, loading';
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
}
