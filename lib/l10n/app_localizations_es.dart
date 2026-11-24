// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get asistenciaGuiaChoquePaso1 =>
      'Detén el auto en un lugar seguro, apaga el motor y enciende las luces intermitentes.';

  @override
  String get asistenciaGuiaChoquePaso2 =>
      'Revisa si hay personas heridas. Si las hay, llama al 911 de inmediato y no muevas a quien tenga dolor de cuello o espalda.';

  @override
  String get asistenciaGuiaChoquePaso3 =>
      'Si puedes, baja del auto y ponte detrás de una barrera, lejos del tráfico. Coloca los triángulos de advertencia.';

  @override
  String get asistenciaGuiaChoquePaso4 =>
      'Llama a tu aseguradora y espera al ajustador. No aceptes ni firmes acuerdos con el otro conductor sin ella.';

  @override
  String get asistenciaGuiaChoquePaso5 =>
      'Toma fotos de los vehículos, las placas, los daños y el lugar. Anota el nombre, el teléfono y los datos del seguro del otro conductor.';

  @override
  String get asistenciaGuiaChoquePaso6 =>
      'No muevas el auto hasta que lo autorice la autoridad o el ajustador, salvo que estorbe y sea seguro hacerlo.';

  @override
  String get asistenciaGuiaChoqueResumen =>
      'Pasos para cuidar a todos y proteger tu reclamación.';

  @override
  String get asistenciaGuiaChoqueTitulo => 'Qué hacer en un choque';

  @override
  String get asistenciaGuiaCorrientePaso1 =>
      'Estaciona el otro auto de frente, sin que se toquen. Apaga ambos motores y los accesorios.';

  @override
  String get asistenciaGuiaCorrientePaso2 =>
      'Conecta una pinza roja al polo positivo (+) de tu batería descargada y el otro extremo al polo positivo del auto que da corriente.';

  @override
  String get asistenciaGuiaCorrientePaso3 =>
      'Conecta una pinza negra al polo negativo (−) de la batería buena y el otro extremo a una parte metálica sin pintar del motor de tu auto, lejos de la batería.';

  @override
  String get asistenciaGuiaCorrientePaso4 =>
      'Enciende el auto que da corriente y déjalo funcionando unos minutos.';

  @override
  String get asistenciaGuiaCorrientePaso5 =>
      'Intenta encender tu auto. Si no arranca, espera unos minutos más e inténtalo de nuevo.';

  @override
  String get asistenciaGuiaCorrientePaso6 =>
      'Quita las pinzas en orden inverso, sin que se toquen entre sí, y deja tu auto encendido al menos 20 minutos.';

  @override
  String get asistenciaGuiaCorrienteResumen =>
      'Cómo arrancar tu auto con cables de otro vehículo.';

  @override
  String get asistenciaGuiaCorrienteTitulo => 'Pasar corriente';

  @override
  String get asistenciaGuiaLlantaPaso1 =>
      'Estaciona en terreno plano y firme, pon el freno de mano y enciende las luces intermitentes.';

  @override
  String get asistenciaGuiaLlantaPaso2 =>
      'Saca la llanta de refacción, el gato y la llave de cruz. Afloja un poco las tuercas de la llanta ponchada sin quitarlas.';

  @override
  String get asistenciaGuiaLlantaPaso3 =>
      'Coloca el gato en el punto indicado en el manual y levanta el auto hasta que la llanta quede en el aire.';

  @override
  String get asistenciaGuiaLlantaPaso4 =>
      'Quita las tuercas y la llanta ponchada. Monta la de refacción y aprieta las tuercas con la mano.';

  @override
  String get asistenciaGuiaLlantaPaso5 =>
      'Baja el auto, aprieta las tuercas en cruz con la llave y revisa la presión en cuanto puedas.';

  @override
  String get asistenciaGuiaLlantaResumen =>
      'Cámbiala por la de refacción en pocos pasos.';

  @override
  String get asistenciaGuiaLlantaTitulo => 'Cambiar una llanta';

  @override
  String asistenciaGuiaPasoNumero(int numero, int total) {
    return 'Paso $numero de $total';
  }

  @override
  String get asistenciaListaTitulo => 'Emergencias';

  @override
  String get asistenciaHeroeTitulo => '¿Necesitas ayuda ahora?';

  @override
  String get asistenciaHeroeTexto =>
      'Pedir ayuda con tu ubicación estará disponible pronto. Mientras tanto, estas guías te dicen qué hacer.';

  @override
  String get asistenciaHeroeAccion => 'Pedir ayuda';

  @override
  String get asistenciaEstanteGuias => 'Guías rápidas';

  @override
  String get asistenciaGrupoGuias => 'Todas las guías';

  @override
  String asistenciaGuiaCantidadPasos(int pasos) {
    return '$pasos pasos';
  }

  @override
  String asistenciaGuiaSubtituloSinConexion(int pasos) {
    return '$pasos pasos · sin conexión';
  }

  @override
  String get asistenciaGuiasAvisoSinConexion =>
      'Estas guías están guardadas en la app y funcionan sin conexión.';

  @override
  String get asistenciaGuiasTitulo => 'Guías de emergencia';

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
  String get citasCancelada => 'Cita cancelada. El horario quedó libre.';

  @override
  String get citasCancelar => 'Cancelar cita';

  @override
  String get citasCancelarConfirmar => 'Sí, cancelar';

  @override
  String citasCancelarDialogoMensaje(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Tu cita del $fechaString a las $hora se cancelará y el horario quedará libre para otras personas.';
  }

  @override
  String get citasCancelarDialogoTitulo => '¿Cancelar esta cita?';

  @override
  String get citasCancelarError =>
      'No pudimos cancelar tu cita. Intenta de nuevo.';

  @override
  String get citasCancelarMantener => 'Mantener cita';

  @override
  String get citasCancelarNoDisponible => 'Esta cita ya no se puede cancelar.';

  @override
  String get citasCargando => 'Cargando disponibilidad del taller';

  @override
  String get citasCargandoAgendar =>
      'Cargando tus vehículos y los horarios del taller';

  @override
  String get citasComprobanteCargando => 'Cargando tu comprobante';

  @override
  String citasComprobanteCuando(DateTime fecha, String inicio, String fin) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString, de $inicio a $fin';
  }

  @override
  String citasComprobanteFolio(int id) {
    return 'Folio $id';
  }

  @override
  String get citasComprobanteIndicacion =>
      'Muestra este código en recepción para registrar tu llegada.';

  @override
  String get citasComprobanteQrDescripcion =>
      'Código QR de tu cita para recepción';

  @override
  String get citasComprobanteTitulo => 'Comprobante de cita';

  @override
  String get citasComprobanteVerPdf => 'Ver comprobante en PDF';

  @override
  String get citasComprobanteVerPdfDescripcion =>
      'Comprobante en PDF de tu cita';

  @override
  String get citasCargarMas => 'Cargar más citas';

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
  String get citasErrorMas => 'No pudimos cargar más citas. Intenta de nuevo.';

  @override
  String get citasEstadoAtendida => 'Atendida';

  @override
  String get citasEstadoCancelada => 'Cancelada';

  @override
  String get citasEstadoConfirmada => 'Confirmada';

  @override
  String get citasEstadoDesconocido => 'Sin estado';

  @override
  String get citasEstadoNoAsistio => 'No asistió';

  @override
  String citasFilaTitulo(DateTime fecha, String inicio) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString · $inicio';
  }

  @override
  String get citasFilaVehiculoGenerico => 'Tu vehículo';

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
  String get citasListoVerComprobante => 'Ver comprobante';

  @override
  String get citasMisCitasAgendar => 'Agendar cita';

  @override
  String get citasMisCitasCargando => 'Cargando tus citas';

  @override
  String get citasMisCitasTitulo => 'Mis citas';

  @override
  String get citasMisCitasVacioMensaje =>
      'Cuando agendes una cita aparecerá aquí con su estado.';

  @override
  String get citasMisCitasVacioTitulo => 'Aún no tienes citas';

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
  String get citasPasadas => 'Pasadas';

  @override
  String get citasPasadasVacio => 'Aún no tienes citas pasadas.';

  @override
  String get citasProximas => 'Próximas';

  @override
  String get citasProximasVacio => 'No tienes citas próximas.';

  @override
  String get citasReprogramar => 'Reprogramar';

  @override
  String citasReprogramarActual(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Tu cita actual: $fechaString · $hora';
  }

  @override
  String get citasReprogramarCargando =>
      'Cargando tu cita y los horarios del taller';

  @override
  String get citasReprogramarConfirmar => 'Cambiar a este horario';

  @override
  String get citasReprogramarError =>
      'No pudimos reprogramar tu cita. Intenta de nuevo.';

  @override
  String citasReprogramarListo(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Cita reprogramada para el $fechaString a las $hora. El horario anterior quedó libre.';
  }

  @override
  String get citasReprogramarNoDisponible =>
      'Esta cita ya no se puede cambiar.';

  @override
  String get citasReprogramarNoEncontradaMensaje =>
      'Puede que ya no esté disponible para cambiarla.';

  @override
  String get citasReprogramarNoEncontradaTitulo => 'No encontramos esta cita';

  @override
  String get citasReprogramarSinFranja =>
      'Elige un día y un horario nuevos para continuar.';

  @override
  String get citasReprogramarTitulo => 'Reprogramar cita';

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
  String get vehiculosFichaCargando => 'Cargando la ficha técnica';

  @override
  String get vehiculosFichaClaveCarroceria => 'Carrocería';

  @override
  String get vehiculosFichaClaveMotor => 'Motor';

  @override
  String get vehiculosFichaClavePasajeros => 'Pasajeros';

  @override
  String get vehiculosFichaClavePotencia => 'Potencia';

  @override
  String get vehiculosFichaClavePropulsion => 'Propulsión';

  @override
  String get vehiculosFichaClaveTraccion => 'Tracción';

  @override
  String get vehiculosFichaClaveTransmision => 'Transmisión';

  @override
  String get vehiculosFichaNota =>
      'Datos del modelo y año. La ficha exacta de tu unidad está en su manual.';

  @override
  String get vehiculosFichaRespaldo => 'Mostrando la ficha guardada en la app';

  @override
  String get vehiculosFichaSeccionGeneral => 'General';

  @override
  String get vehiculosFichaSeccionMotor => 'Motor';

  @override
  String get vehiculosFichaSeccionTransmision => 'Transmisión';

  @override
  String get vehiculosFichaTitulo => 'Ficha técnica';

  @override
  String get vehiculosFichaVacioMensaje =>
      'Todavía no tenemos las especificaciones de este modelo y año. La agencia las publicará pronto.';

  @override
  String get vehiculosFichaVacioTitulo => 'Sin ficha técnica';

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
  String get vehiculosManualCargando => 'Cargando el manual';

  @override
  String get vehiculosManualCompartir => 'Compartir manual';

  @override
  String get vehiculosManualDescargar => 'Descargar manual';

  @override
  String vehiculosManualDescripcion(String vehiculo) {
    return 'Manual de $vehiculo';
  }

  @override
  String get vehiculosManualGuardado => 'Manual guardado';

  @override
  String get vehiculosManualGuardadoError =>
      'No pudimos guardar el manual. Inténtalo de nuevo.';

  @override
  String get vehiculosManualTitulo => 'Manual';

  @override
  String get vehiculosManualVacioMensaje =>
      'Todavía no tenemos el manual de este modelo y año. La agencia lo publicará pronto.';

  @override
  String get vehiculosManualVacioTitulo => 'Manual no disponible';

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

  @override
  String get widgetsAccesoAgendar => 'Agendar cita';

  @override
  String get widgetsAccesoMiAuto => 'Mi auto';

  @override
  String get widgetsAccesoSos => 'SOS';

  @override
  String get avisoCerrar => 'Cerrar aviso';

  @override
  String get navegacionPrincipal => 'Navegación principal';

  @override
  String botonCargando(String texto) {
    return '$texto, cargando';
  }

  @override
  String get estanteVerTodo => 'Ver todo';

  @override
  String estanteVerTodoDe(String titulo) {
    return 'Ver todo: $titulo';
  }

  @override
  String calendarioDelMes(DateTime mes) {
    final intl.DateFormat mesDateFormat = intl.DateFormat.yMMMM(localeName);
    final String mesString = mesDateFormat.format(mes);

    return 'Calendario de $mesString';
  }

  @override
  String calendarioTituloMes(DateTime mes) {
    final intl.DateFormat mesDateFormat = intl.DateFormat.yMMMM(localeName);
    final String mesString = mesDateFormat.format(mes);

    return '$mesString';
  }

  @override
  String get calendarioMesAnterior => 'Mes anterior';

  @override
  String get calendarioMesSiguiente => 'Mes siguiente';

  @override
  String calendarioDia(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString';
  }

  @override
  String get calendarioHoy => 'hoy';

  @override
  String get calendarioSeleccionado => 'seleccionado';

  @override
  String get calendarioSinCupo => 'sin cupo';

  @override
  String get calendarioInicialesDias => 'L,M,X,J,V,S,D';

  @override
  String get deslizarConfirmar => 'Confirmar';

  @override
  String get deslizarCancelar => 'Cancelar';

  @override
  String deslizarEtiqueta(String texto) {
    return '$texto, desliza para confirmar';
  }

  @override
  String firmaSinFirma(String firmante) {
    return 'Sin firma de $firmante';
  }

  @override
  String firmaDe(String pie) {
    return 'Firma de $pie';
  }

  @override
  String get firmaAunSinFirma => 'Aún sin firma';

  @override
  String galeriaEtiqueta(int actual, int total) {
    return 'Galería de fotos, $actual de $total';
  }

  @override
  String galeriaContador(int actual, int total) {
    return '$actual de $total';
  }

  @override
  String get galeriaFotoAnterior => 'Foto anterior';

  @override
  String get galeriaFotoSiguiente => 'Foto siguiente';

  @override
  String get galeriaCerrarFoto => 'Cerrar foto';

  @override
  String get graficaSinDatos => 'Aún no hay datos para mostrar.';

  @override
  String get graficaVerGrafica => 'Ver gráfica';

  @override
  String get graficaVerTabla => 'Ver como tabla';

  @override
  String graficaPunto(String etiqueta, String valor) {
    return '$etiqueta: $valor';
  }

  @override
  String get lineaPasoHecho => 'completado';

  @override
  String get lineaPasoActual => 'en curso';

  @override
  String get lineaPasoPendiente => 'pendiente';

  @override
  String get lineaVerMas => 'Ver más';

  @override
  String lineaEtapa(int posicion, int total) {
    return 'Etapa $posicion de $total';
  }

  @override
  String pestanaPosicion(String texto, int posicion, int total) {
    return '$texto, $posicion de $total';
  }

  @override
  String get franjasSinHorarios => 'No hay horarios para este día.';

  @override
  String get franjasDisponibles => 'Horarios disponibles';

  @override
  String pdfPagina(int pagina, int total) {
    return 'Página $pagina de $total';
  }

  @override
  String get pdfCargando => 'Cargando documento';

  @override
  String comparacionEtiqueta(String antes, String despues) {
    return 'Comparación. $antes contra $despues';
  }

  @override
  String comparacionValor(int porcentaje) {
    return '$porcentaje % del antes';
  }

  @override
  String comparacionPorcentaje(int porcentaje) {
    return '$porcentaje %';
  }

  @override
  String navegacionPendientes(int conteo) {
    return '$conteo pendientes';
  }

  @override
  String franjaSinCupo(String hora) {
    return '$hora · sin cupo';
  }

  @override
  String franjaConCupo(String hora, int cupo) {
    String _temp0 = intl.Intl.pluralLogic(
      cupo,
      locale: localeName,
      other: '$cupo lugares',
      one: '1 lugar',
    );
    return '$hora · $_temp0';
  }

  @override
  String get galeriaAmpliar => 'Ampliar';

  @override
  String get galeriaSinFotos => 'Aún no hay fotos.';

  @override
  String get deslizarMensajeConfirmacion => 'Confirma que quieres continuar.';

  @override
  String get historialCargandoMas => 'Cargando más servicios';

  @override
  String historialCerradaEl(String fecha) {
    return 'Cerrada el $fecha';
  }

  @override
  String get historialErrorMas => 'No pudimos cargar más servicios.';

  @override
  String get historialEstatusEnProceso => 'En proceso';

  @override
  String get historialEstatusEntregado => 'Entregado';

  @override
  String get historialEstatusOtro => 'Sin estatus';

  @override
  String get historialEstatusRecibido => 'Recibido';

  @override
  String get historialEstatusTerminado => 'Terminado';

  @override
  String historialEstatusYCierre(String estatus, String cierre) {
    return '$estatus · $cierre';
  }

  @override
  String get historialFiltroEtiqueta => 'Filtrar por año';

  @override
  String get historialFiltroTodos => 'Todos';

  @override
  String get historialReintentar => 'Reintentar';

  @override
  String get historialSinCierre => 'Orden abierta';

  @override
  String historialTicketCantidadPorPrecio(int cantidad, String precio) {
    return '$cantidad × $precio';
  }

  @override
  String get historialTicketCierre => 'Fecha de cierre';

  @override
  String get historialTicketCompartir => 'Compartir PDF';

  @override
  String get historialTicketCompartirError =>
      'No pudimos descargar el PDF. Intenta de nuevo.';

  @override
  String get historialTicketFecha => 'Fecha del servicio';

  @override
  String get historialTicketIva => 'IVA';

  @override
  String get historialTicketKilometraje => 'Kilometraje';

  @override
  String historialTicketKilometrajeValor(String km) {
    return '$km km';
  }

  @override
  String get historialTicketManoDeObra => 'Mano de obra';

  @override
  String get historialTicketNoCuadra =>
      'Los importes de este ticket no cuadran. Pide a la agencia que lo revise.';

  @override
  String get historialTicketPreciosConIva => 'Los precios incluyen IVA.';

  @override
  String get historialTicketRefacciones => 'Refacciones';

  @override
  String get historialTicketSinRenglones => 'Sin renglones';

  @override
  String get historialTicketSubtotal => 'Subtotal sin IVA';

  @override
  String get historialTicketTitulo => 'Ticket';

  @override
  String get historialTicketTotal => 'Total';

  @override
  String get historialTicketTotales => 'Totales';

  @override
  String get historialTitulo => 'Historial';

  @override
  String historialVacioAnioMensaje(String anio) {
    return 'No hay servicios en $anio.';
  }

  @override
  String get historialVacioMensaje =>
      'Cuando el taller cierre una orden de este auto, aparecerá aquí.';

  @override
  String get historialVacioTitulo => 'Aún no hay servicios';

  @override
  String get idiomaEtiqueta => 'Idioma';

  @override
  String get idiomaSistema => 'Automático (idioma del sistema)';

  @override
  String get idiomaEspanol => 'Español';

  @override
  String get idiomaIngles => 'English';

  @override
  String get catalogoDetalleTitulo => 'Detalle del modelo';

  @override
  String get catalogoDetalleCargando => 'Cargando el modelo';

  @override
  String get catalogoNoEncontradoTitulo => 'No encontramos el modelo';

  @override
  String get catalogoNoEncontradoMensaje =>
      'Es posible que la agencia ya no lo ofrezca. Vuelve al catálogo para ver los modelos actuales.';

  @override
  String get catalogoGaleria => 'Galería';

  @override
  String get catalogoVersiones => 'Versiones';

  @override
  String get catalogoVersionActual => 'La que estás viendo';

  @override
  String get catalogoFicha => 'Ficha técnica';

  @override
  String get catalogoSinPrecio => 'Precio por confirmar';

  @override
  String catalogoFotoDe(String modelo, int numero) {
    return '$modelo, foto $numero';
  }

  @override
  String catalogoFotoDeColor(String modelo, String color, int numero) {
    return '$modelo, color $color, foto $numero';
  }

  @override
  String get catalogoComparar => 'Comparar modelos';

  @override
  String get catalogoSalirDeComparar => 'Salir de comparar';

  @override
  String catalogoCompararElegidos(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Comparar $cantidad modelos',
      one: 'Elige otro modelo',
      zero: 'Elige de 2 a 3 modelos',
    );
    return '$_temp0';
  }

  @override
  String catalogoCompararModelo(String modelo) {
    return 'Comparar $modelo';
  }

  @override
  String get catalogoComparadorTitulo => 'Comparar modelos';

  @override
  String get catalogoComparadorCargando => 'Cargando la comparativa';

  @override
  String get catalogoComparadorIdsMalosTitulo => 'Elige de dos a tres modelos';

  @override
  String get catalogoComparadorIdsMalosMensaje =>
      'Vuelve al catálogo, activa comparar y marca los modelos que quieras ver lado a lado.';

  @override
  String get catalogoComparadorPrecio => 'Precio desde';

  @override
  String get catalogoComparadorSinDato => 'Sin dato';

  @override
  String get catalogoComparadorMasBajo => 'Precio más bajo';

  @override
  String catalogoComparadorCelda(String dato, String modelo, String valor) {
    return '$dato, $modelo: $valor';
  }

  @override
  String get catalogoCalcularTomaACuenta => 'Calcular toma a cuenta';

  @override
  String get calculadoraTitulo => 'Toma a cuenta';

  @override
  String get calculadoraLeyenda =>
      'Estimación no vinculante. No es una oferta de compra: el valor final lo define la agencia cuando revise tu auto.';

  @override
  String calculadoraContra(String modelo) {
    return 'Contra: $modelo';
  }

  @override
  String get calculadoraAuto => 'Tu auto';

  @override
  String get calculadoraOtroAuto => 'Otro auto';

  @override
  String get calculadoraCargandoAutos => 'Cargando tus autos';

  @override
  String get calculadoraMarca => 'Marca';

  @override
  String get calculadoraModelo => 'Modelo';

  @override
  String get calculadoraAnio => 'Año';

  @override
  String get calculadoraKm => 'Kilometraje';

  @override
  String get calculadoraKmAyuda => 'En kilómetros, como marca el tablero hoy';

  @override
  String get calculadoraEstado => 'Estado general';

  @override
  String get calculadoraEstadoExcelente => 'Excelente';

  @override
  String get calculadoraEstadoBueno => 'Bueno';

  @override
  String get calculadoraEstadoRegular => 'Regular';

  @override
  String get calculadoraEstadoMalo => 'Malo';

  @override
  String get calculadoraCalcular => 'Calcular estimación';

  @override
  String get calculadoraErrorMarca => 'Escribe la marca';

  @override
  String get calculadoraErrorModelo => 'Escribe el modelo';

  @override
  String calculadoraErrorAnio(int maximo) {
    return 'Escribe un año de cuatro cifras, de 1900 a $maximo';
  }

  @override
  String get calculadoraErrorKm => 'Escribe un kilometraje de 0 a 999,999';

  @override
  String get calculadoraResultadoTitulo => 'Estimación de toma a cuenta';

  @override
  String calculadoraRango(String minimo, String maximo) {
    return '$minimo a $maximo';
  }

  @override
  String calculadoraRangoLector(String minimo, String maximo) {
    return 'Entre $minimo y $maximo';
  }

  @override
  String calculadoraSupuestos(int edad, String km, int margen) {
    String _temp0 = intl.Intl.pluralLogic(
      edad,
      locale: localeName,
      other: 'un auto de $edad años',
      one: 'un auto de 1 año',
      zero: 'un auto de este año',
    );
    return 'Se calculó para $_temp0, con $km km esperados para esa edad y un margen de más y menos $margen %.';
  }

  @override
  String get calculadoraSinParametrosTitulo => 'Todavía no estimamos ese auto';

  @override
  String get calculadoraSinParametrosMensaje =>
      'La agencia aún no tiene datos para esa marca, modelo y año. Pide una valuación formal en la agencia.';

  @override
  String get calculadoraErrorDatos =>
      'No pudimos calcular la estimación. Revisa los datos e intenta de nuevo.';

  @override
  String get calculadoraErrorSinConexion =>
      'Sin conexión. Conéctate e intenta de nuevo.';

  @override
  String get calculadoraErrorNoEncontrado =>
      'No encontramos ese auto o ese modelo. Vuelve atrás e intenta de nuevo.';

  @override
  String get calculadoraErrorGenerico =>
      'Algo salió mal al calcular. Intenta de nuevo en un momento.';

  @override
  String get calculadoraDiferenciaTitulo => 'Diferencia a pagar';

  @override
  String calculadoraDiferenciaExplicacion(String precio) {
    return 'Es el precio de lista, $precio, menos el rango estimado de tu auto. También es una estimación no vinculante.';
  }

  @override
  String calculadoraDiferenciaCubierta(String precio) {
    return 'Con lo que podría valer tu auto alcanzaría para el precio de lista, $precio. Es una estimación no vinculante.';
  }

  @override
  String get misEstimacionesTitulo => 'Mis estimaciones';

  @override
  String get misEstimacionesCargando => 'Cargando tus estimaciones';

  @override
  String get misEstimacionesVacioTitulo => 'Aún no tienes estimaciones';

  @override
  String get misEstimacionesVacioMensaje =>
      'Cuando calcules cuánto valdría tu auto a cuenta de uno nuevo, la verás aquí.';

  @override
  String get misEstimacionesVacioAccion => 'Calcular una estimación';

  @override
  String misEstimacionesFila(DateTime fecha, String rango) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.yMMMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString, $rango';
  }

  @override
  String get misEstimacionesVerMas => 'Ver más';

  @override
  String get misEstimacionesErrorMas =>
      'No pudimos cargar más estimaciones. Intenta de nuevo.';

  @override
  String get widgetsProximaCitaTitulo => 'Próxima cita';

  @override
  String widgetsProximaCitaFecha(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString';
  }

  @override
  String widgetsProximaCitaHorario(String inicio, String fin) {
    return '$inicio a $fin';
  }

  @override
  String get widgetsSinCitaMensaje => 'No tienes citas próximas';

  @override
  String get citasWalletAgregar => 'Agregar a Wallet';

  @override
  String get citasWalletErrorGenerico =>
      'No pudimos preparar tu pase. Intenta de nuevo.';

  @override
  String get citasWalletErrorSinConexion =>
      'Sin conexión. Revisa tu red e intenta de nuevo.';

  @override
  String get citasWalletErrorCancelada =>
      'Tu cita está cancelada, así que ya no tiene pase.';

  @override
  String get citasWalletErrorNoDisponible =>
      'El pase de Wallet no está disponible por ahora. Muestra el código QR en recepción.';

  @override
  String get citasAgendarDia => 'Día';

  @override
  String get citasAgendarHorario => 'Horario';

  @override
  String get citasMisCitasProximaEtiqueta => 'Tu próxima cita';

  @override
  String get citasHeroComprobante => 'Comprobante';

  @override
  String get citasAccionesCita => 'Opciones de tu cita';

  @override
  String get citasCerrar => 'Cerrar';

  @override
  String get citasComprobanteDetalles => 'Detalles de la cita';

  @override
  String get citasComprobanteRecepcion => 'En recepción';

  @override
  String get vehiculosAgendarServicio => 'Agendar servicio';

  @override
  String get vehiculosBotonManual => 'Manual';

  @override
  String get vehiculosBotonDescargar => 'Descargar';

  @override
  String get vehiculosBotonCompartir => 'Compartir';

  @override
  String get vehiculosVerDetalle => 'Ver detalle';

  @override
  String get vehiculosEncabezadoDatos => 'Datos';

  @override
  String get vehiculosEncabezadoTuAuto => 'Tu auto';

  @override
  String get vehiculosEncabezadoRapidos => 'Datos rápidos';

  @override
  String get vehiculosToqueCopiarVin => 'Toca para copiar';

  @override
  String get recoleccionCerrar => 'Cerrar';

  @override
  String get recoleccionDireccionesTitulo => 'Mis direcciones';

  @override
  String get recoleccionDireccionesAgregar => 'Agregar dirección';

  @override
  String get recoleccionDireccionesCargando => 'Cargando tus direcciones';

  @override
  String get recoleccionDireccionesVacioTitulo => 'Aún no tienes direcciones';

  @override
  String get recoleccionDireccionesVacioMensaje =>
      'Guarda una para que recojamos tu auto sin escribirla cada vez.';

  @override
  String get recoleccionDireccionesEncabezado => 'Guardadas';

  @override
  String get recoleccionDireccionesPie => 'Toca una para editarla o borrarla.';

  @override
  String recoleccionDireccionEditar(String alias) {
    return 'Editar $alias';
  }

  @override
  String get recoleccionDireccionBorrada => 'Dirección borrada';

  @override
  String get recoleccionFormNuevaTitulo => 'Nueva dirección';

  @override
  String get recoleccionFormEditarTitulo => 'Editar dirección';

  @override
  String get recoleccionFormUbicacionTitulo => 'Ubicación en el mapa';

  @override
  String get recoleccionFormPinAyuda =>
      'Toca el mapa para poner el pin donde recogeremos tu auto.';

  @override
  String get recoleccionFormPinFalta => 'Pon el pin en el mapa.';

  @override
  String recoleccionFormMapaDescripcion(String latitud, String longitud) {
    return 'Mapa para elegir la ubicación. Pin en $latitud, $longitud.';
  }

  @override
  String get recoleccionFormMapaSinPin =>
      'Mapa para elegir la ubicación. Todavía no hay pin.';

  @override
  String get recoleccionFormUsarUbicacion => 'Usar mi ubicación';

  @override
  String get recoleccionFormBuscarEtiqueta => 'Buscar dirección';

  @override
  String get recoleccionFormBuscarSugerencia => 'Calle, número y colonia';

  @override
  String get recoleccionFormBuscarAccion => 'Buscar';

  @override
  String get recoleccionFormBuscando => 'Buscando la dirección';

  @override
  String get recoleccionFormAliasEtiqueta => 'Nombre';

  @override
  String get recoleccionFormAliasSugerencia => 'Casa, oficina…';

  @override
  String get recoleccionFormCalleEtiqueta => 'Calle y número';

  @override
  String get recoleccionFormColoniaEtiqueta => 'Colonia';

  @override
  String get recoleccionFormCpEtiqueta => 'Código postal';

  @override
  String get recoleccionFormCiudadEtiqueta => 'Ciudad';

  @override
  String get recoleccionErrorAlias =>
      'Escribe un nombre de hasta 40 caracteres.';

  @override
  String get recoleccionErrorCalle =>
      'Escribe la calle y el número, hasta 120 caracteres.';

  @override
  String get recoleccionErrorColonia =>
      'Escribe la colonia, hasta 80 caracteres.';

  @override
  String get recoleccionErrorCp => 'El código postal tiene 5 dígitos.';

  @override
  String get recoleccionErrorCiudad =>
      'Escribe la ciudad, hasta 80 caracteres.';

  @override
  String get recoleccionGuardar => 'Guardar dirección';

  @override
  String get recoleccionBorrar => 'Borrar dirección';

  @override
  String get recoleccionBorrarTitulo => '¿Borrar esta dirección?';

  @override
  String recoleccionBorrarMensaje(String alias) {
    return 'Se borrará «$alias». No se puede deshacer.';
  }

  @override
  String get recoleccionBorrarConfirmar => 'Borrar';

  @override
  String get recoleccionBorrarCancelar => 'Cancelar';

  @override
  String get recoleccionErrorEnUso =>
      'Esta dirección ya tiene recolecciones y no se puede borrar.';

  @override
  String get recoleccionCoberturaTitulo => 'Fuera de cobertura';

  @override
  String get recoleccionCoberturaMensaje =>
      'Todavía no recogemos autos en esa zona. Mueve el pin o elige otra dirección.';

  @override
  String get recoleccionErrorGuardar =>
      'No pudimos guardar la dirección. Intenta de nuevo.';

  @override
  String get recoleccionErrorBorrar =>
      'No pudimos borrar la dirección. Intenta de nuevo.';

  @override
  String get recoleccionErrorSinConexion =>
      'Sin conexión. Revisa tu red e intenta de nuevo.';

  @override
  String get recoleccionUbicacionDenegada =>
      'Necesitamos tu permiso para usar la ubicación. También puedes poner el pin a mano.';

  @override
  String get recoleccionUbicacionApagada =>
      'Activa la ubicación del teléfono o pon el pin a mano.';

  @override
  String get recoleccionUbicacionTiempo =>
      'No pudimos ubicarte a tiempo. Intenta de nuevo o pon el pin a mano.';

  @override
  String get recoleccionBusquedaSinResultados =>
      'No encontramos esa dirección. Prueba con otra o pon el pin a mano.';

  @override
  String get recoleccionBusquedaError =>
      'No pudimos buscar la dirección. Pon el pin a mano.';

  @override
  String get recoleccionSelectorTitulo => '¿Cómo llega tu auto al taller?';

  @override
  String get recoleccionSelectorLoLlevo => 'Lo llevo yo';

  @override
  String get recoleccionSelectorQueRecojan => 'Que recojan mi auto';

  @override
  String get recoleccionSelectorDireccion => 'Dirección de recolección';

  @override
  String get recoleccionSelectorAdministrar => 'Administrar mis direcciones';

  @override
  String get recoleccionSelectorSinDirecciones =>
      'Aún no tienes direcciones guardadas.';

  @override
  String get recoleccionSelectorElegirDia =>
      'Elige día y horario para cotizar la recolección.';

  @override
  String get recoleccionSelectorElegirDireccion =>
      'Elige una dirección para ver el costo.';

  @override
  String get recoleccionSelectorCotizando =>
      'Calculando el costo de la recolección';

  @override
  String get recoleccionSelectorElegida => 'Elegida';

  @override
  String get recoleccionCotizacionEncabezado => 'Costo y horario';

  @override
  String get recoleccionCotizacionRecogemos => 'Recogemos tu auto';

  @override
  String get recoleccionCotizacionEntregamos => 'Te lo entregamos';

  @override
  String get recoleccionCotizacionPorTraslado => 'Cada traslado';

  @override
  String get recoleccionCotizacionTotal => 'Total de la recolección';

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

    return '$fechaString, de $inicio a $fin';
  }

  @override
  String get recoleccionCotizacionErrorTitulo =>
      'No pudimos cotizar la recolección';

  @override
  String get recoleccionCotizacionErrorMensaje =>
      'Revisa tu conexión e intenta de nuevo. Mientras tanto puedes llevar tú el auto.';

  @override
  String get recoleccionCotizacionReintentar => 'Reintentar';

  @override
  String get recoleccionCotizacionFueraDeCobertura =>
      'Esa dirección queda fuera de nuestra zona de cobertura. Elige otra o lleva tú el auto.';

  @override
  String get citasResumenRecoleccion => 'Recolección';

  @override
  String citasResumenRecoleccionValor(String alias, String direccion) {
    return '$alias · $direccion';
  }

  @override
  String get citasResumenRecogemos => 'Recogemos tu auto';

  @override
  String get citasResumenEntregamos => 'Te lo entregamos';

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

    return '$fechaString, de $inicio a $fin';
  }

  @override
  String get citasResumenRecoleccionCosto => 'Costo de la recolección';

  @override
  String get citasResumenRecoleccionEncabezado => 'Recolección a domicilio';

  @override
  String get citasErrorCobertura =>
      'Esa dirección ya no está en nuestra zona de cobertura. Elige otra o lleva tú el auto.';

  @override
  String get citasErrorRecoleccion =>
      'No encontramos esa dirección. Elige otra e intenta de nuevo.';

  @override
  String get asistenciaHeroeTextoDisponible =>
      'Cuéntanos qué pasó y comparte tu ubicación para que la agencia te encuentre. Mientras llega la ayuda, estas guías te dicen qué hacer.';

  @override
  String get asistenciaPedirTitulo => 'Pedir ayuda';

  @override
  String get asistenciaPedirCargando => 'Cargando';

  @override
  String get asistenciaPedirVehiculoEncabezado =>
      '¿Qué vehículo necesita ayuda?';

  @override
  String get asistenciaPedirSeleccionado => 'Seleccionado';

  @override
  String get asistenciaPedirTipoEncabezado => '¿Qué pasó?';

  @override
  String get asistenciaTipoLlanta => 'Llanta';

  @override
  String get asistenciaTipoBateria => 'Batería';

  @override
  String get asistenciaTipoChoque => 'Choque';

  @override
  String get asistenciaTipoSinGasolina => 'Sin gasolina';

  @override
  String get asistenciaTipoOtro => 'Otro';

  @override
  String get asistenciaUbicacionEncabezado => 'Tu ubicación';

  @override
  String get asistenciaUbicacionCompartir => 'Compartir mi ubicación';

  @override
  String get asistenciaUbicacionExplicacion =>
      'La agencia sabrá dónde estás. Se envía una sola vez, con la app abierta, y no se vuelve a usar cuando la ayuda termina.';

  @override
  String get asistenciaUbicacionObteniendo => 'Buscando tu ubicación…';

  @override
  String get asistenciaUbicacionLista => 'Ubicación lista para enviar';

  @override
  String get asistenciaUbicacionPermisoDenegado =>
      'No diste permiso de ubicación. Puedes intentarlo otra vez o enviar la solicitud sin ubicación y escribir dónde estás.';

  @override
  String get asistenciaUbicacionPermisoBloqueado =>
      'El permiso de ubicación está bloqueado. Actívalo en Ajustes o envía la solicitud sin ubicación y escribe dónde estás.';

  @override
  String get asistenciaUbicacionServicioApagado =>
      'La ubicación del teléfono está apagada. Enciéndela o envía la solicitud sin ubicación y escribe dónde estás.';

  @override
  String get asistenciaUbicacionTiempoAgotado =>
      'No pudimos encontrarte a tiempo. Intenta otra vez o envía la solicitud sin ubicación y escribe dónde estás.';

  @override
  String get asistenciaUbicacionReintentar => 'Intentar de nuevo';

  @override
  String get asistenciaUbicacionSinUbicacion => 'Enviar sin ubicación';

  @override
  String get asistenciaComentarioEtiqueta => 'Comentario (opcional)';

  @override
  String get asistenciaComentarioEtiquetaSinUbicacion =>
      'Dónde estás y qué pasó';

  @override
  String get asistenciaComentarioAyuda => 'Máximo 500 caracteres';

  @override
  String get asistenciaConfirmarTexto => 'Desliza para pedir ayuda';

  @override
  String get asistenciaEnviando => 'Enviando tu solicitud…';

  @override
  String get asistenciaErrorSinConexion =>
      'Sin conexión: no pudimos enviar tu solicitud. Si es urgente, llama al 911 o a tu aseguradora.';

  @override
  String get asistenciaErrorEnviar =>
      'No pudimos enviar tu solicitud. Intenta de nuevo.';

  @override
  String get asistenciaErrorVehiculo =>
      'No encontramos ese vehículo. Elige otro e intenta de nuevo.';

  @override
  String get asistenciaGarajeVacioTitulo => 'Aún no tienes vehículos';

  @override
  String get asistenciaGarajeVacioMensaje =>
      'Para pedir ayuda necesitamos saber qué vehículo es. Pide a la agencia que registre el tuyo.';

  @override
  String asistenciaSolicitudFolio(int id) {
    return 'Folio $id';
  }

  @override
  String get asistenciaSolicitudRecibida => 'Solicitud recibida';

  @override
  String get asistenciaSolicitudTexto =>
      'La agencia ya sabe que necesitas ayuda. Mantén el teléfono contigo y ponte en un lugar seguro.';

  @override
  String get asistenciaSolicitudYaAbierta =>
      'Ya tenías una solicitud abierta. Te la mostramos aquí.';

  @override
  String get asistenciaSolicitudVehiculo => 'Vehículo';

  @override
  String get asistenciaSolicitudProblema => 'Problema';

  @override
  String get asistenciaSolicitudUbicacion => 'Ubicación';

  @override
  String get asistenciaSolicitudUbicacionCompartida =>
      'Compartida con la agencia';

  @override
  String get asistenciaSolicitudUbicacionNoCompartida => 'No compartida';

  @override
  String get asistenciaSolicitudComentario => 'Comentario';

  @override
  String get asistenciaSolicitudPrivacidad =>
      'Tu ubicación solo se comparte mientras la solicitud esté abierta.';

  @override
  String get asistenciaSolicitudVerGuias => 'Ver guías de emergencia';

  @override
  String get seguridadEquipoComprometidoTitulo =>
      'Este equipo parece modificado';

  @override
  String get seguridadEquipoComprometidoMensaje =>
      'Puedes seguir usando CareCar, pero por tu seguridad no guardamos tus datos en este equipo. Sin internet no verás información guardada.';

  @override
  String get asistenteTitulo => 'Pregúntale a tu auto';

  @override
  String get asistenteAvisoIa =>
      'Respuestas generadas con IA a partir del manual de tu auto. Ante una falla, consulta a tu asesor.';

  @override
  String get asistenteVacioTitulo => '¿Qué quieres saber de tu auto?';

  @override
  String get asistenteVacioMensaje =>
      'Respondo con el manual de tu auto y te digo en qué página lo dice.';

  @override
  String get asistenteSugerencia => 'Escribe tu pregunta';

  @override
  String get asistenteEnviar => 'Enviar';

  @override
  String get asistenteTu => 'Tú';

  @override
  String get asistenteNombre => 'CareCar';

  @override
  String get asistentePensando => 'Buscando en tu manual…';

  @override
  String get asistenteNoSeEnvio => 'No se envió';

  @override
  String get asistenteReintentar => 'Reintentar';

  @override
  String get asistenteSinConexion =>
      'No me pude conectar. Revisa tu internet y vuelve a intentar.';

  @override
  String get asistenteNoDisponible =>
      'El asistente no está disponible por ahora. Intenta más tarde o pregúntale a tu asesor.';

  @override
  String get asistenteSinManual =>
      'Tu auto aún no tiene un manual que pueda leer. Pregúntale a tu asesor en la agencia.';

  @override
  String get asistenteLimite =>
      'Ya hiciste tus preguntas de hoy. Mañana puedes hacer más.';

  @override
  String asistenteFuente(int pagina) {
    return 'Manual, pág. $pagina';
  }

  @override
  String asistenteFuenteLector(int pagina) {
    return 'Manual, página $pagina, abrir';
  }

  @override
  String get asistenteSugerenciasTitulo => 'Prueba con una de estas';

  @override
  String get asistentePreguntaMantenimiento => '¿Cada cuánto le toca servicio?';

  @override
  String get asistentePreguntaLlantas => '¿Qué presión llevan las llantas?';

  @override
  String get asistentePreguntaTestigos =>
      '¿Qué significa una luz roja en el tablero?';

  @override
  String get asistentePreguntaAceite => '¿Cuánto aceite le cabe al motor?';

  @override
  String get asistentePreguntaGasolina => '¿Qué gasolina le pongo?';
}
