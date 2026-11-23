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

  @override
  String get avisoCerrar => 'Cerrar aviso';

  @override
  String get navegacionPrincipal => 'Navegación principal';

  @override
  String botonCargando(String texto) {
    return '$texto, cargando';
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
}
