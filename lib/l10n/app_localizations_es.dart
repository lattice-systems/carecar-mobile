// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String accesoBloqueoMinutos(int minutos) {
    return 'Espera $minutos min para volver a intentar.';
  }

  @override
  String accesoBloqueoSegundos(int segundos) {
    return 'Espera $segundos s para volver a intentar.';
  }

  @override
  String get accesoBloqueoTitulo => 'Demasiados intentos';

  @override
  String get accesoCambiarActualEtiqueta => 'Contraseña temporal';

  @override
  String get accesoCambiarCerrarSesion => 'Cerrar sesión';

  @override
  String get accesoCambiarConfirmarEtiqueta => 'Confirma la contraseña nueva';

  @override
  String get accesoCambiarExplicacion =>
      'La agencia te dio una contraseña temporal. Elige una nueva para continuar.';

  @override
  String get accesoCambiarFalloTitulo => 'No pudimos cambiar tu contraseña';

  @override
  String get accesoCambiarGuardando => 'Guardando…';

  @override
  String get accesoCambiarGuardar => 'Guardar';

  @override
  String get accesoCambiarNoCoincide => 'Las dos contraseñas no son iguales.';

  @override
  String get accesoCambiarNuevaEtiqueta => 'Contraseña nueva';

  @override
  String get accesoCambiarReglaDistinta => 'Distinta de la temporal';

  @override
  String get accesoCambiarReglaLargo => 'De 8 a 72 caracteres';

  @override
  String get accesoCambiarReglaLetra => 'Al menos una letra';

  @override
  String get accesoCambiarReglaNumero => 'Al menos un número';

  @override
  String get accesoCambiarReglasTitulo => 'Tu contraseña nueva debe tener:';

  @override
  String get accesoCambiarTitulo => 'Cambia tu contraseña';

  @override
  String get accesoContrasenaEtiqueta => 'Contraseña';

  @override
  String get accesoContrasenaVacia => 'Escribe tu contraseña.';

  @override
  String get accesoCorreoAyuda => 'El que le diste a la agencia';

  @override
  String get accesoCorreoEtiqueta => 'Correo';

  @override
  String get accesoCorreoInvalido =>
      'Escribe un correo válido, como nombre@dominio.com.';

  @override
  String get accesoCorreoVacio => 'Escribe tu correo.';

  @override
  String get accesoEntrando => 'Entrando…';

  @override
  String get accesoEntrar => 'Iniciar sesión';

  @override
  String get accesoFalloTitulo => 'No pudimos iniciar sesión';

  @override
  String get accesoMarca => 'CareCar';

  @override
  String get accesoOlvide => '¿Olvidaste tu contraseña?';

  @override
  String get accesoRecuperarEnviado => 'Revisa tu correo';

  @override
  String get accesoRecuperarEnviadoMensaje =>
      'Si ese correo tiene una cuenta, te llegará un enlace para elegir una contraseña nueva. Vence en poco tiempo y sirve una sola vez.';

  @override
  String get accesoRecuperarEnviando => 'Enviando…';

  @override
  String get accesoRecuperarEnviar => 'Enviarme el enlace';

  @override
  String get accesoRecuperarExplicacion =>
      'Escribe tu correo y te enviamos un enlace para elegir una contraseña nueva.';

  @override
  String get accesoRecuperarFalloTitulo => 'No pudimos enviar el enlace';

  @override
  String get accesoRecuperarTitulo => 'Recupera tu contraseña';

  @override
  String get accesoServidorDespertandoMensaje =>
      'La primera vez después de un rato puede tardar hasta un minuto.';

  @override
  String get accesoServidorDespertandoTitulo => 'Despertando el servidor…';

  @override
  String get accesoSinConexionTitulo => 'Sin conexión';

  @override
  String get accesoSinRegistro =>
      'La agencia te entrega tu acceso cuando recibes tu unidad. Si no lo tienes, comunícate con la agencia.';

  @override
  String get accesoSubtitulo => 'Tu acceso a la agencia';

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
  String get citasReprogramadaTitulo => 'Cita reprogramada';

  @override
  String citasReprogramarListo(DateTime fecha, String hora) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Te esperamos el $fechaString a las $hora. El horario anterior quedó libre.';
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
  String get mantenimientoAcceso => 'Mantenimiento';

  @override
  String get mantenimientoAgendar => 'Agendar este servicio';

  @override
  String get mantenimientoCargando => 'Cargando tu plan de mantenimiento';

  @override
  String get mantenimientoCargandoServicio => 'Cargando el servicio';

  @override
  String get mantenimientoCerrar => 'Cerrar';

  @override
  String get mantenimientoDescripcionPortada =>
      'Ilustración de una llave de servicio';

  @override
  String get mantenimientoEncabezadoConceptos => 'Qué incluye';

  @override
  String get mantenimientoEncabezadoKm => 'Tu kilometraje';

  @override
  String get mantenimientoEncabezadoPlan => 'Plan de servicios';

  @override
  String get mantenimientoEstadoHecho => 'Hecho';

  @override
  String get mantenimientoEstadoPendiente => 'Pendiente';

  @override
  String get mantenimientoEstadoProximo => 'Próximo';

  @override
  String get mantenimientoEstadoVencido => 'Vencido';

  @override
  String mantenimientoFaltan(String km, String fecha) {
    return 'Faltan $km km · hacia el $fecha';
  }

  @override
  String mantenimientoHechoEl(String fecha) {
    return 'Hecho el $fecha';
  }

  @override
  String mantenimientoKilometros(String km) {
    return '$km km';
  }

  @override
  String mantenimientoKmAyuda(String km) {
    return 'Tu último registro: $km km';
  }

  @override
  String get mantenimientoKmAyudaSinRegistro =>
      'Escribe el número que marca el tablero de tu auto.';

  @override
  String get mantenimientoKmCampo => 'Kilometraje actual';

  @override
  String mantenimientoKmDelCliente(String fecha) {
    return 'Registrado por ti el $fecha';
  }

  @override
  String mantenimientoKmDelTaller(String fecha) {
    return 'Registrado por el taller el $fecha';
  }

  @override
  String get mantenimientoKmErrorFormato =>
      'Usa solo números enteros mayores que cero.';

  @override
  String mantenimientoKmErrorMenor(String km) {
    return 'No puede ser menor a $km km, el último que tenemos.';
  }

  @override
  String get mantenimientoKmErrorRed =>
      'No pudimos guardar tu kilometraje. Revisa tu internet y vuelve a intentarlo.';

  @override
  String get mantenimientoKmErrorServidor =>
      'Ese kilometraje es menor al último registrado. Revísalo en tu tablero.';

  @override
  String get mantenimientoKmErrorVacio => 'Escribe tu kilometraje.';

  @override
  String get mantenimientoKmGuardado =>
      'Kilometraje guardado. Actualizamos tu próximo servicio.';

  @override
  String get mantenimientoKmGuardando => 'Guardando kilometraje';

  @override
  String get mantenimientoKmGuardar => 'Guardar kilometraje';

  @override
  String get mantenimientoKmNota =>
      'El kilometraje que registra el taller es el oficial: tu registro no lo reemplaza.';

  @override
  String get mantenimientoKmSinDato => 'Sin registrar';

  @override
  String get mantenimientoKmSinFuente => 'Aún no hay una lectura de tu auto';

  @override
  String get mantenimientoKmTitulo => 'Registrar kilometraje';

  @override
  String get mantenimientoMotivoKm => 'Te toca por kilometraje';

  @override
  String get mantenimientoMotivoTiempo => 'Te toca por tiempo transcurrido';

  @override
  String get mantenimientoPrecioEtiqueta => 'Precio estimado';

  @override
  String get mantenimientoPrecioLeyenda => 'Estimación no vinculante';

  @override
  String mantenimientoPromedio(String km) {
    return 'Promedio: $km km al día';
  }

  @override
  String get mantenimientoRegistrarKm => 'Registrar km';

  @override
  String mantenimientoResumenServicio(String km, String meses) {
    return '$km km · $meses meses';
  }

  @override
  String get mantenimientoServicioNoEncontradoMensaje =>
      'Puede que el plan haya cambiado. Vuelve al plan e inténtalo de nuevo.';

  @override
  String get mantenimientoServicioNoEncontradoTitulo =>
      'No encontramos este servicio';

  @override
  String get mantenimientoSinConceptos =>
      'Este servicio no trae conceptos detallados.';

  @override
  String get mantenimientoSinProximoMensaje =>
      'Registra tu kilometraje para calcular cuándo te toca el siguiente servicio.';

  @override
  String get mantenimientoSinProximoTitulo => 'Sin próximo servicio estimado';

  @override
  String get mantenimientoTitulo => 'Mantenimiento';

  @override
  String get mantenimientoVacioMensaje =>
      'Todavía no tenemos el plan de servicios de este modelo. Pregunta a tu asesor en la agencia.';

  @override
  String get mantenimientoVacioTitulo => 'Aún no hay plan para tu auto';

  @override
  String mantenimientoYaToca(String km) {
    return 'Ya te toca · pasó de los $km km';
  }

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
  String get widgetsTallerTitulo => 'Tu auto en el taller';

  @override
  String widgetsTallerEntrega(String hora) {
    return 'Entrega estimada: $hora';
  }

  @override
  String get widgetsAgendar => 'Agendar';

  @override
  String get widgetsTallerEncabezado => 'Taller en vivo';

  @override
  String get widgetsTallerVacioMensaje => 'Tu auto no está en el taller';

  @override
  String widgetsTallerPaso(int actual, int total) {
    return 'Paso $actual de $total';
  }

  @override
  String get widgetsMantenimientoTitulo => 'Mantenimiento';

  @override
  String widgetsMantenimientoFaltanKm(String km) {
    return 'Faltan $km km';
  }

  @override
  String get widgetsMantenimientoYaToca => 'Ya toca';

  @override
  String widgetsMantenimientoFecha(String fecha) {
    return 'Hacia el $fecha';
  }

  @override
  String get widgetsMantenimientoVacioMensaje =>
      'Aún no hay un plan para tu auto';

  @override
  String get widgetsMantenimientoAccion => 'Ver plan';

  @override
  String get widgetsBitacoraTitulo => 'Bitácora';

  @override
  String get widgetsBitacoraRendimientoUnidad => 'km/l';

  @override
  String widgetsBitacoraGastoMes(String mes) {
    return 'Gasto de $mes';
  }

  @override
  String get widgetsBitacoraRendimientoEtiqueta => 'Rendimiento';

  @override
  String get widgetsBitacoraVacioMensaje => 'Registra tu primera carga';

  @override
  String get widgetsBitacoraAccion => 'Registrar';

  @override
  String get widgetsAccesosTitulo => 'Accesos rápidos';

  @override
  String get widgetsAccesoComprobante => 'Comprobante';

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
  String get cerrarPantalla => 'Cerrar';

  @override
  String get regresar => 'Regresar';

  @override
  String get citasCerrar => 'Cerrar';

  @override
  String get citasComprobanteDetalles => 'Detalles de la cita';

  @override
  String get citasComprobanteRecepcion => 'En recepción';

  @override
  String get vehiculosAgendarServicio => 'Agendar';

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
  String get seguridadConexionNoSeguraTitulo =>
      'No pudimos verificar que la conexión sea segura';

  @override
  String get seguridadConexionNoSeguraMensaje =>
      'El certificado que presentó el servidor no es el que la app espera. Puede pasar en una red con filtros (WiFi público, escuela o trabajo). Prueba con datos móviles u otra red.';

  @override
  String inicioSaludo(String nombre) {
    return 'Hola, $nombre';
  }

  @override
  String get inicioProximaCita => 'Próxima cita';

  @override
  String get inicioSinCitas => 'No tienes citas por venir';

  @override
  String get inicioSinCitasDetalle => 'Agenda la próxima revisión de tu auto';

  @override
  String get inicioSinAutos => 'Aún no tienes autos registrados';

  @override
  String get inicioSinAutosDetalle =>
      'Cuando la agencia registre tu auto, lo verás aquí';

  @override
  String inicioKilometros(String km) {
    return '$km km';
  }

  @override
  String inicioAutoDeTotal(int n, int total) {
    return 'Auto $n de $total';
  }

  @override
  String inicioCitaCuando(String dia, String hora) {
    return '$dia, $hora';
  }

  @override
  String get inicioAgendarCita => 'Agendar cita';

  @override
  String get inicioPerfilYAjustes => 'Perfil y ajustes';

  @override
  String get inicioDestinoInicio => 'Inicio';

  @override
  String get inicioDestinoVehiculos => 'Vehículos';

  @override
  String get inicioDestinoCitas => 'Citas';

  @override
  String get inicioDestinoCatalogo => 'Catálogo';

  @override
  String get inicioAccesoVehiculosTitulo => 'Mis vehículos';

  @override
  String get inicioAccesoVehiculosSubtitulo => 'Tus autos, fichas y manuales';

  @override
  String get inicioAccesoCitasTitulo => 'Citas';

  @override
  String get inicioAccesoCitasSubtitulo => 'Agenda y revisa tus citas';

  @override
  String get inicioAccesoCatalogoTitulo => 'Catálogo';

  @override
  String get inicioAccesoCatalogoSubtitulo => 'Conoce los modelos Nissan';

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
  String get asistenciaSeguimientoEncabezado => 'Estado de tu solicitud';

  @override
  String get asistenciaEstadoRecibida => 'Recibida';

  @override
  String get asistenciaEstadoEnCamino => 'En camino';

  @override
  String get asistenciaEstadoAtendida => 'Atendida';

  @override
  String get asistenciaEstadoCancelada => 'Cancelada';

  @override
  String get asistenciaEstadoNotaRecibida =>
      'La agencia ya tiene tu solicitud.';

  @override
  String get asistenciaEstadoNotaEnCamino => 'Hay ayuda en camino hacia ti.';

  @override
  String get asistenciaEstadoNotaAtendida => 'Tu solicitud ya fue atendida.';

  @override
  String get asistenciaEstadoNotaCancelada => 'La solicitud se cerró.';

  @override
  String asistenciaEstadoActual(String estado) {
    return 'Estado: $estado';
  }

  @override
  String get asistenciaSeguimientoActualizar => 'Actualizar estado';

  @override
  String get asistenciaSeguimientoActualizando => 'Actualizando…';

  @override
  String get asistenciaSeguimientoFallo =>
      'No pudimos actualizar el estado. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get asistenciaSeguimientoUbicacionCerrada =>
      'La solicitud ya está cerrada: tu ubicación dejó de compartirse.';

  @override
  String get recoleccionSeguimientoTitulo => 'Seguimiento del traslado';

  @override
  String get recoleccionSeguimientoRecoger => 'Recogemos tu auto';

  @override
  String get recoleccionSeguimientoEntregar => 'Entregamos tu auto';

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

    return '$fechaString, de $inicio a $fin';
  }

  @override
  String get recoleccionSeguimientoAbrir =>
      'Toca un traslado para seguirlo en vivo.';

  @override
  String get recoleccionSeguimientoLineaEncabezado => 'Avance';

  @override
  String get recoleccionEstadoProgramado => 'Programado';

  @override
  String get recoleccionEstadoEnCamino => 'Chofer en camino';

  @override
  String get recoleccionEstadoRecogido => 'Auto recogido';

  @override
  String get recoleccionEstadoEnTaller => 'En el taller';

  @override
  String get recoleccionEstadoDeRegreso => 'De regreso a tu domicilio';

  @override
  String get recoleccionEstadoEntregado => 'Auto entregado';

  @override
  String get recoleccionEstadoCancelado => 'Cancelado';

  @override
  String get recoleccionEstadoNotaEnCamino => 'Sigue su ubicación en el mapa.';

  @override
  String get recoleccionEstadoNotaDeRegreso => 'Sigue su ubicación en el mapa.';

  @override
  String get recoleccionSeguimientoMapaEncabezado => 'Dónde va el chofer';

  @override
  String recoleccionSeguimientoMapaDescripcion(
    String latitud,
    String longitud,
  ) {
    return 'Mapa con la ubicación del chofer: latitud $latitud, longitud $longitud.';
  }

  @override
  String recoleccionSeguimientoActualizadaEn(String hora) {
    return 'Ubicación actualizada a las $hora';
  }

  @override
  String get recoleccionSeguimientoVerChecklist => 'Ver checklist del auto';

  @override
  String get recoleccionSeguimientoActualizar => 'Actualizar';

  @override
  String get recoleccionSeguimientoCargando =>
      'Cargando el seguimiento del traslado';

  @override
  String get recoleccionSeguimientoNoEncontradoTitulo =>
      'No encontramos este traslado';

  @override
  String get recoleccionSeguimientoNoEncontradoMensaje =>
      'Puede que ya no exista. Vuelve a tus citas y ábrelo de nuevo.';

  @override
  String get recoleccionSeguimientoFalloAlActualizar =>
      'No pudimos actualizar. Mostramos lo último que sabemos.';

  @override
  String get recoleccionChecklistTitulo => 'Checklist del auto';

  @override
  String get recoleccionChecklistKm => 'Kilometraje';

  @override
  String recoleccionChecklistKmValor(int km) {
    final intl.NumberFormat kmNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String kmString = kmNumberFormat.format(km);

    return '$kmString km';
  }

  @override
  String get recoleccionChecklistGasolina => 'Gasolina';

  @override
  String get recoleccionGasolinaVacio => 'Vacío';

  @override
  String get recoleccionGasolinaUnCuarto => 'Un cuarto';

  @override
  String get recoleccionGasolinaMedio => 'Medio tanque';

  @override
  String get recoleccionGasolinaTresCuartos => 'Tres cuartos';

  @override
  String get recoleccionGasolinaLleno => 'Lleno';

  @override
  String recoleccionChecklistGasolinaLector(String nivel) {
    return 'Gasolina: $nivel';
  }

  @override
  String get recoleccionChecklistNotas => 'Notas del chofer';

  @override
  String get recoleccionChecklistFotos => 'Fotos del auto';

  @override
  String recoleccionChecklistFotoDescripcion(int numero, int total) {
    return 'Foto $numero de $total del estado del auto';
  }

  @override
  String get recoleccionChecklistSinFotos => 'Este checklist no trae fotos.';

  @override
  String get recoleccionChecklistFirmante => 'Firma de conformidad';

  @override
  String recoleccionChecklistRegistrado(DateTime fecha) {
    final intl.DateFormat fechaDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return 'Registrado el $fechaString';
  }

  @override
  String get recoleccionChecklistVacioTitulo => 'Aún no hay checklist';

  @override
  String get recoleccionChecklistVacioMensaje =>
      'El chofer lo registra al recoger y al entregar tu auto. Cuando lo haga, lo verás aquí.';

  @override
  String get recoleccionChecklistCargando => 'Cargando el checklist del auto';

  @override
  String get bitacoraTitulo => 'Bitácora';

  @override
  String get bitacoraSubtituloSinNombre => 'Tu auto';

  @override
  String get bitacoraDescripcionPortada => 'Ícono de una bomba de gasolina';

  @override
  String get bitacoraNuevaCarga => 'Nueva carga';

  @override
  String get bitacoraOtroGasto => 'Otro gasto';

  @override
  String get bitacoraCerrar => 'Cerrar';

  @override
  String get bitacoraCargando => 'Cargando tu bitácora';

  @override
  String get bitacoraVacioTitulo => 'Aún no hay gastos';

  @override
  String get bitacoraVacioMensaje =>
      'Registra tu primera carga de gasolina para saber cuánto rinde y cuánto te cuesta tu auto.';

  @override
  String get bitacoraResumenTitulo => 'Tu rendimiento';

  @override
  String get bitacoraEtiquetaRendimiento => 'Rendimiento';

  @override
  String bitacoraCifraKmPorLitro(String valor) {
    return '$valor km/l';
  }

  @override
  String get bitacoraEtiquetaCostoPorKm => 'Costo por km';

  @override
  String bitacoraCifraCostoPorKm(String valor) {
    return '$valor/km';
  }

  @override
  String get bitacoraEtiquetaGastoMes => 'Gasto de este mes';

  @override
  String get bitacoraCifraSinDatos => '—';

  @override
  String get bitacoraDetalleSinDatos => 'Necesitas 2 cargas';

  @override
  String get bitacoraVerEstadisticas => 'Rendimiento y gasto por mes';

  @override
  String get bitacoraExportar => 'Exportar bitácora';

  @override
  String get bitacoraTipoGasolina => 'Gasolina';

  @override
  String get bitacoraTipoEstacionamiento => 'Estacionamiento';

  @override
  String get bitacoraTipoCasetas => 'Casetas';

  @override
  String get bitacoraTipoLavado => 'Lavado';

  @override
  String get bitacoraTipoOtro => 'Otro';

  @override
  String bitacoraDetalleCarga(String fecha, String litros, String km) {
    return '$fecha · $litros l · $km km';
  }

  @override
  String get bitacoraFormCargaTitulo => 'Nueva carga';

  @override
  String get bitacoraFormEditarCargaTitulo => 'Editar carga';

  @override
  String get bitacoraFormGastoTitulo => 'Nuevo gasto';

  @override
  String get bitacoraFormEditarGastoTitulo => 'Editar gasto';

  @override
  String get bitacoraCampoTipo => 'Tipo de gasto';

  @override
  String get bitacoraCampoLitros => 'Litros';

  @override
  String get bitacoraCampoMonto => 'Monto total';

  @override
  String get bitacoraCampoKm => 'Kilometraje del tablero';

  @override
  String bitacoraAyudaKm(String km) {
    return 'Tu última lectura es de $km km.';
  }

  @override
  String get bitacoraCampoFecha => 'Fecha';

  @override
  String get bitacoraElegirFecha => 'Elegir fecha';

  @override
  String get bitacoraCampoDescripcion => 'Descripción';

  @override
  String get bitacoraAyudaDescripcion =>
      'Obligatoria en «Otro», máximo 200 caracteres.';

  @override
  String get bitacoraErrorMonto => 'Escribe un monto mayor a 0.';

  @override
  String get bitacoraErrorLitros => 'Escribe los litros, mayores a 0.';

  @override
  String get bitacoraErrorKm => 'Escribe el kilometraje como número entero.';

  @override
  String bitacoraErrorKmMenor(String km) {
    return 'No puede ser menor a tu última lectura ($km km).';
  }

  @override
  String get bitacoraErrorKmServidor =>
      'El servidor lo rechazó: es menor a tu última lectura. Revisa el kilometraje.';

  @override
  String get bitacoraErrorFecha => 'Elige una fecha que no sea futura.';

  @override
  String get bitacoraErrorDescripcion =>
      'Describe el gasto, en máximo 200 caracteres.';

  @override
  String get bitacoraErrorGuardar => 'No se pudo guardar. Intenta de nuevo.';

  @override
  String get bitacoraErrorBorrar => 'No se pudo borrar. Intenta de nuevo.';

  @override
  String get bitacoraErrorSinConexion =>
      'Sin conexión. Revisa tu internet e intenta de nuevo.';

  @override
  String get bitacoraGuardar => 'Guardar';

  @override
  String get bitacoraBorrar => 'Borrar gasto';

  @override
  String get bitacoraBorrarTitulo => '¿Borrar este gasto?';

  @override
  String bitacoraBorrarMensaje(String descripcion) {
    return 'Se borrará «$descripcion». No se puede deshacer.';
  }

  @override
  String get bitacoraBorrarConfirmar => 'Borrar';

  @override
  String get bitacoraBorrarCancelar => 'Cancelar';

  @override
  String get bitacoraGastoGuardado => 'Gasto guardado.';

  @override
  String get bitacoraGastoBorrado => 'Gasto borrado.';

  @override
  String get bitacoraTicketTitulo => 'Llenar desde el ticket';

  @override
  String get bitacoraTicketPrivacidad =>
      'La foto se lee en tu teléfono; no se guarda ni se sube.';

  @override
  String get bitacoraTicketTomar => 'Tomar foto';

  @override
  String get bitacoraTicketElegir => 'Elegir de fotos';

  @override
  String get bitacoraTicketLeyendo => 'Leyendo el ticket…';

  @override
  String get bitacoraTicketLeido =>
      'Esto fue lo que leímos. Revísalo y corrige lo que haga falta.';

  @override
  String get bitacoraTicketNoLeyo =>
      'No pudimos leer el ticket. Llena los datos a mano.';

  @override
  String get bitacoraTicketSinPermiso =>
      'No tenemos permiso para usar la cámara o tus fotos. Actívalo en los ajustes o llena los datos a mano.';

  @override
  String get bitacoraTicketError =>
      'No se pudo abrir la foto. Llena los datos a mano.';

  @override
  String get bitacoraEstadisticasTitulo => 'Rendimiento y gasto';

  @override
  String get bitacoraGraficaTitulo => 'Gasto por mes';

  @override
  String get bitacoraGraficaVacia => 'Aún no hay gastos que graficar.';

  @override
  String get bitacoraSinRendimientoTitulo => 'Aún no hay rendimiento';

  @override
  String bitacoraSinRendimientoMensaje(int cargas) {
    String _temp0 = intl.Intl.pluralLogic(
      cargas,
      locale: localeName,
      other: 'Tienes $cargas cargas, pero sus kilometrajes no avanzan.',
      one: 'Tienes 1 carga.',
      zero: 'Todavía no registras ninguna.',
    );
    return 'Para calcular los km/l y el costo por km necesitamos al menos 2 cargas con su kilometraje. $_temp0';
  }

  @override
  String bitacoraBaseDelCalculo(String km, int tramos) {
    String _temp0 = intl.Intl.pluralLogic(
      tramos,
      locale: localeName,
      other: '$tramos tramos',
      one: '1 tramo',
    );
    return 'Calculado con $km km recorridos en $_temp0 entre cargas.';
  }

  @override
  String get bitacoraExportarTitulo => 'Exportar bitácora';

  @override
  String get bitacoraExportarIntro =>
      'Elige los meses y comparte tu bitácora con la hoja del sistema.';

  @override
  String get bitacoraExportarDesde => 'Desde';

  @override
  String get bitacoraExportarHasta => 'Hasta';

  @override
  String get bitacoraExportarCsv => 'Compartir CSV';

  @override
  String get bitacoraExportarPdf => 'Compartir PDF';

  @override
  String get bitacoraExportarVacio => 'No hay gastos en esos meses.';

  @override
  String get bitacoraExportarRangoInvalido =>
      'El mes inicial no puede ser posterior al final.';

  @override
  String get bitacoraExportarError =>
      'No se pudo compartir el archivo. Intenta de nuevo.';

  @override
  String bitacoraPdfTitulo(String vehiculo) {
    return 'Bitácora de $vehiculo';
  }

  @override
  String bitacoraPdfPeriodo(String desde, String hasta) {
    return '$desde a $hasta';
  }

  @override
  String bitacoraPdfTotal(String monto) {
    return 'Total: $monto';
  }

  @override
  String get bitacoraColumnaFecha => 'Fecha';

  @override
  String get bitacoraColumnaTipo => 'Tipo';

  @override
  String get bitacoraColumnaMonto => 'Monto';

  @override
  String get bitacoraColumnaLitros => 'Litros';

  @override
  String get bitacoraColumnaKm => 'Km';

  @override
  String get bitacoraColumnaDetalle => 'Detalle';

  @override
  String get bitacoraAccesoFila => 'Bitácora';

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

  @override
  String get asistenteAgendarRevision => 'Agendar revisión';

  @override
  String get asistenteMeSirvio => 'Me sirvió';

  @override
  String get asistenteNoMeSirvio => 'No me sirvió';

  @override
  String tallerTarjetaTitulo(String vehiculo) {
    return 'Tu $vehiculo está en el taller';
  }

  @override
  String tallerTarjetaEtapaYEntrega(String etapa, String hora) {
    return '$etapa · entrega $hora';
  }

  @override
  String tallerTarjetaPendientes(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad trabajos por aprobar',
      one: '1 trabajo por aprobar',
    );
    return '$_temp0';
  }

  @override
  String tallerTarjetaAvance(int avance) {
    return 'Avance de $avance %';
  }

  @override
  String get tallerTarjetaAbrir => 'Ver el avance de tu orden';

  @override
  String get tallerEtapaRecibido => 'Recibido';

  @override
  String get tallerEtapaDiagnostico => 'Diagnóstico';

  @override
  String get tallerEtapaEsperandoAprobacion => 'Esperando aprobación';

  @override
  String get tallerEtapaEnReparacion => 'En reparación';

  @override
  String get tallerEtapaControlDeCalidad => 'Control de calidad';

  @override
  String get tallerEtapaLavado => 'Lavado';

  @override
  String get tallerEtapaListoParaEntrega => 'Listo para entrega';

  @override
  String get tallerEtapaEntregado => 'Entregado';

  @override
  String get tallerOrdenTitulo => 'Tu orden';

  @override
  String get tallerOrdenEtapaActual => 'Etapa actual';

  @override
  String get tallerOrdenEntregaEstimada => 'Entrega estimada';

  @override
  String get tallerOrdenSinEntrega => 'Aún sin estimar';

  @override
  String get tallerOrdenAsesor => 'Tu asesor';

  @override
  String get tallerOrdenLineaDeTiempo => 'Línea de tiempo';

  @override
  String tallerOrdenNotaEntrega(String hora) {
    return 'Entrega estimada $hora';
  }

  @override
  String tallerOrdenNotaYEntrega(String nota, String hora) {
    return '$nota · entrega estimada $hora';
  }

  @override
  String get tallerOrdenInspeccion => 'Inspección multipunto';

  @override
  String tallerOrdenInspeccionResumen(int puntos) {
    String _temp0 = intl.Intl.pluralLogic(
      puntos,
      locale: localeName,
      other: '$puntos puntos revisados',
      one: '1 punto revisado',
      zero: 'Aún sin puntos revisados',
    );
    return '$_temp0';
  }

  @override
  String get tallerOrdenAdicionales => 'Trabajos adicionales';

  @override
  String tallerOrdenAdicionalesResumen(int pendientes) {
    String _temp0 = intl.Intl.pluralLogic(
      pendientes,
      locale: localeName,
      other: '$pendientes por aprobar',
      one: '1 por aprobar',
      zero: 'Nada por aprobar',
    );
    return '$_temp0';
  }

  @override
  String tallerOrdenAvisoPendientes(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'El taller te propone $cantidad trabajos adicionales',
      one: 'El taller te propone 1 trabajo adicional',
    );
    return '$_temp0';
  }

  @override
  String get tallerOrdenAvisoMensaje =>
      'Revísalos y apruébalos o recházalos con tu firma.';

  @override
  String get tallerOrdenRevisar => 'Revisar';

  @override
  String get tallerReintentar => 'Reintentar';

  @override
  String get tallerInspeccionTitulo => 'Inspección';

  @override
  String get tallerInspeccionVacia => 'Aún sin inspección';

  @override
  String get tallerInspeccionVaciaMensaje =>
      'El técnico todavía no registra los puntos revisados.';

  @override
  String tallerInspeccionFotoDe(String punto) {
    return 'Foto de $punto';
  }

  @override
  String get tallerInspeccionDeLaOrden => 'De la orden';

  @override
  String get tallerInspeccionFotoDeLaOrden => 'Foto de la orden';

  @override
  String tallerInspeccionVerVideo(int numero) {
    return 'Ver video $numero';
  }

  @override
  String get tallerInspeccionVideoAbre =>
      'Se abre en el reproductor del teléfono';

  @override
  String get tallerInspeccionVideoError =>
      'No se pudo abrir el video. Jala hacia abajo para recargar e intenta de nuevo.';

  @override
  String get tallerAdicionalesTitulo => 'Adicionales';

  @override
  String get tallerAdicionalesVacio => 'Sin trabajos adicionales';

  @override
  String get tallerAdicionalesVacioMensaje =>
      'Si el taller encuentra algo más, aquí te lo propone para que decidas.';

  @override
  String get tallerAdicionalManoDeObra => 'Mano de obra';

  @override
  String get tallerAdicionalRefacciones => 'Refacciones';

  @override
  String get tallerAdicionalTotal => 'Total';

  @override
  String get tallerAdicionalPendiente => 'Por aprobar';

  @override
  String get tallerAdicionalAprobado => 'Aprobado';

  @override
  String get tallerAdicionalRechazado => 'Rechazado';

  @override
  String tallerAdicionalRespondidoEl(String fecha) {
    return 'Respondido el $fecha';
  }

  @override
  String get tallerAdicionalAprobar => 'Aprobar';

  @override
  String get tallerAdicionalRechazar => 'Rechazar';

  @override
  String get tallerTotales => 'Totales';

  @override
  String get tallerTotalOrden => 'Total de la orden';

  @override
  String get tallerTotalAprobados => 'Adicionales aprobados';

  @override
  String get tallerTotalPendientes => 'Adicionales por aprobar';

  @override
  String get tallerTotalEstimado => 'Total estimado';

  @override
  String get tallerFirmaAprobarTitulo => 'Firma para aprobar';

  @override
  String get tallerFirmaRechazarTitulo => 'Firma para rechazar';

  @override
  String tallerFirmaInstruccion(String concepto, String total) {
    return '$concepto por $total. Firma con el dedo dentro del recuadro: tu firma queda guardada con tu respuesta.';
  }

  @override
  String get tallerFirmaArea => 'Área para firmar con el dedo';

  @override
  String get tallerFirmaBorrar => 'Borrar firma';

  @override
  String get tallerFirmaConfirmarAprobar => 'Aprobar con mi firma';

  @override
  String get tallerFirmaConfirmarRechazar => 'Rechazar con mi firma';

  @override
  String tallerRespuestaAprobada(String concepto) {
    return 'Aprobaste «$concepto». El total estimado ya lo incluye.';
  }

  @override
  String tallerRespuestaRechazada(String concepto) {
    return 'Rechazaste «$concepto».';
  }

  @override
  String get tallerRespuestaYaRespondida =>
      'Ese trabajo ya tenía respuesta. Recarga para ver su estado.';

  @override
  String get tallerRespuestaOrdenCerrada =>
      'La orden ya está terminada. Habla con tu asesor.';

  @override
  String get tallerRespuestaSinConexion =>
      'Sin conexión. Tu respuesta no se envió.';

  @override
  String get tallerRespuestaError =>
      'No se pudo enviar tu respuesta. Intenta de nuevo.';

  @override
  String tallerTarjetaListoTitulo(String vehiculo) {
    return 'Tu $vehiculo está listo';
  }

  @override
  String tallerTarjetaListoTotal(String total) {
    return 'Total a pagar $total';
  }

  @override
  String tallerHorarioEntrega(String fecha, String desde, String hasta) {
    return 'Recógelo el $fecha de $desde a $hasta';
  }

  @override
  String get tallerHorarioSinFranjas => 'Tu asesor te dirá cuándo recogerlo.';

  @override
  String get tallerOrdenListoTitulo => 'Tu auto está listo';

  @override
  String get tallerOrdenTotalAPagar => 'Total a pagar';

  @override
  String get tallerOrdenEntregadaTitulo => 'Ya recogiste tu auto';

  @override
  String get tallerOrdenEntregadaMensaje =>
      'La orden quedó en el historial de tu vehículo con su ticket.';

  @override
  String get tallerOrdenVerTicket => 'Ver ticket';

  @override
  String get tallerOrdenVerTicketResumen =>
      'Mano de obra y refacciones de la orden';

  @override
  String get tallerOrdenVerHistorial => 'Ver historial del vehículo';

  @override
  String get asistenteFotoAdjuntar => 'Foto de una luz del tablero';

  @override
  String get asistenteFotoTomar => 'Tomar foto';

  @override
  String get asistenteFotoGaleria => 'Elegir de tus fotos';

  @override
  String get asistenteFotoEnviada => 'Foto del tablero';

  @override
  String get asistenteRevisandoFoto => 'Revisando tu foto…';

  @override
  String get asistenteTestigoRoja => 'Detente';

  @override
  String get asistenteTestigoAmarilla => 'Revisar pronto';

  @override
  String get asistenteTestigoInformativa => 'Informativa';

  @override
  String get asistenteTestigoDetente =>
      'Detente en un lugar seguro lo antes posible y apaga el motor.';

  @override
  String get asistentePedirAyuda => 'Pedir ayuda';

  @override
  String get asistenteTestigoNoReconocido =>
      'No reconocí una luz en la foto. Descríbela con palabras: color, forma y si parpadea.';

  @override
  String get asistentePermisoCamara =>
      'Para tomar la foto, permite el acceso a la cámara y a tus fotos en los ajustes del teléfono.';

  @override
  String get asistenteAbrirAjustes => 'Abrir ajustes';

  @override
  String get estrenoQuieroProbarlo => 'Quiero probarlo';

  @override
  String get estrenoCotizar => 'Cotizar';

  @override
  String get estrenoPruebaTitulo => 'Prueba de manejo';

  @override
  String get estrenoCotizacionTitulo => 'Cotización';

  @override
  String get estrenoMisSolicitudes => 'Mis solicitudes';

  @override
  String get estrenoDia => '¿Qué día?';

  @override
  String get estrenoFranja => '¿A qué hora?';

  @override
  String get estrenoManana => 'Mañana (9 a 13 h)';

  @override
  String get estrenoTarde => 'Tarde (13 a 18 h)';

  @override
  String get estrenoTomaACuenta => '¿Dejas tu auto a cuenta?';

  @override
  String get estrenoSinTomaACuenta => 'No';

  @override
  String get estrenoEnviar => 'Enviar solicitud';

  @override
  String get estrenoEnviarCotizacion => 'Enviar cotización';

  @override
  String get estrenoEnviando => 'Enviando…';

  @override
  String get estrenoCalculando => 'Calculando tu mensualidad…';

  @override
  String get estrenoListo => '¡Listo! Un asesor te contactará pronto.';

  @override
  String get estrenoVerSolicitudes => 'Ver mis solicitudes';

  @override
  String get estrenoDuplicada =>
      'Ya pediste esto para este modelo; un asesor te contactará.';

  @override
  String get estrenoSinPrecio =>
      'Este modelo aún no tiene precio publicado. Pregúntale a un asesor.';

  @override
  String get estrenoSinConexion =>
      'No pudimos enviarlo. Revisa tu internet y vuelve a intentar.';

  @override
  String get estrenoNoDisponible => 'Algo falló. Intenta más tarde.';

  @override
  String get estrenoEnganche => 'Enganche';

  @override
  String estrenoEngancheAyuda(String minimo) {
    return 'Mínimo $minimo';
  }

  @override
  String get estrenoPlazo => 'Plazo';

  @override
  String estrenoMeses(int meses) {
    return '$meses meses';
  }

  @override
  String get estrenoMensualidad => 'Mensualidad estimada';

  @override
  String estrenoPrecioDesde(String precio) {
    return 'Precio desde $precio';
  }

  @override
  String get estrenoEstadoRecibida => 'Recibida';

  @override
  String get estrenoEstadoEnAtencion => 'En atención';

  @override
  String get estrenoEstadoCerrada => 'Cerrada';

  @override
  String estrenoTeAtiende(String nombre) {
    return 'Te atiende $nombre';
  }

  @override
  String get estrenoVacioTitulo => 'Aún no tienes solicitudes';

  @override
  String get estrenoVacioMensaje =>
      'Desde el catálogo puedes pedir una prueba de manejo o cotizar un auto nuevo.';

  @override
  String get estrenoVerMas => 'Ver más';

  @override
  String get estrenoCargandoMas => 'Cargando…';

  @override
  String get estrenoErrorMas =>
      'No pudimos traer más solicitudes. Intenta de nuevo.';

  @override
  String get estrenoCargando => 'Cargando tus solicitudes';

  @override
  String citasMisCitasRecoleccionEncabezado(String cita) {
    return 'Recolección · $cita';
  }

  @override
  String get citasChecklistRecoger => 'Checklist al recoger';

  @override
  String get citasChecklistEntregar => 'Checklist al entregar';

  @override
  String get citasChecklistSubtitulo => 'Kilometraje, gasolina y fotos';

  @override
  String get citasChecklistComparar => 'Comparar recoger y entregar';

  @override
  String get citasChecklistCompararSubtitulo =>
      'Lo que cambió entre una y otra';

  @override
  String get recoleccionChecklistPestanaRecoger => 'Al recoger';

  @override
  String get recoleccionChecklistPestanaEntregar => 'Al entregar';

  @override
  String get recoleccionChecklistPestanaComparar => 'Comparar';

  @override
  String recoleccionComparacionKmDetalle(int recoger, int entregar) {
    final intl.NumberFormat recogerNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recogerString = recogerNumberFormat.format(recoger);
    final intl.NumberFormat entregarNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String entregarString = entregarNumberFormat.format(entregar);

    return '$recogerString km al recoger, $entregarString km al entregar';
  }

  @override
  String recoleccionComparacionGasolinaDetalle(
    String recoger,
    String entregar,
  ) {
    return '$recoger al recoger, $entregar al entregar';
  }

  @override
  String get recoleccionComparacionFotosTitulo =>
      'Fotos al recoger y al entregar';

  @override
  String get recoleccionComparacionFotosAyuda =>
      'Arrastra la barra: a la izquierda ves la foto al recoger y a la derecha la foto al entregar.';

  @override
  String recoleccionComparacionFotoRecoger(int numero, int total) {
    return 'Foto $numero de $total al recoger';
  }

  @override
  String recoleccionComparacionFotoEntregar(int numero, int total) {
    return 'Foto $numero de $total al entregar';
  }

  @override
  String recoleccionComparacionFotosDesiguales(
    int recoger,
    int entregar,
    int comparadas,
  ) {
    return 'Hay $recoger fotos al recoger y $entregar al entregar; se comparan las primeras $comparadas.';
  }

  @override
  String get recoleccionComparacionSinFotos =>
      'Alguno de los dos checklists no trae fotos para comparar.';

  @override
  String get recoleccionComparacionFaltaTitulo => 'Aún no se puede comparar';

  @override
  String get recoleccionComparacionFaltaRecoger =>
      'El chofer todavía no registra el checklist de recoger.';

  @override
  String get recoleccionComparacionFaltaEntregar =>
      'El chofer todavía no registra el checklist de entregar. Cuando devuelva tu auto podrás compararlo.';

  @override
  String get recoleccionComparacionFaltaAmbos =>
      'El chofer todavía no registra ningún checklist de esta recolección.';

  @override
  String get privacidadTitulo => 'Aviso de privacidad';

  @override
  String privacidadVersion(int version) {
    return 'Versión $version';
  }

  @override
  String privacidadVigenteDesde(String fecha) {
    return 'Vigente desde el $fecha';
  }

  @override
  String privacidadAceptadoEl(String fecha) {
    return 'Lo aceptaste el $fecha';
  }

  @override
  String get privacidadCargando => 'Cargando el aviso de privacidad';

  @override
  String get privacidadAntesDeContinuar => 'Antes de continuar';

  @override
  String get privacidadIntro =>
      'Lee el aviso de privacidad. Para usar CareCar necesitas aceptarlo.';

  @override
  String get privacidadAceptar => 'Acepto el aviso de privacidad';

  @override
  String get privacidadGuardando => 'Guardando…';

  @override
  String get privacidadNoAcepto => 'No acepto, cerrar sesión';

  @override
  String get privacidadCambio =>
      'El aviso cambió mientras lo leías. Ya está el nuevo: léelo y acéptalo si estás de acuerdo.';

  @override
  String get privacidadErrorAceptar =>
      'No pudimos guardar tu aceptación. Intenta de nuevo.';

  @override
  String get privacidadSinConexionAceptar =>
      'Sin conexión. Conéctate para guardar tu aceptación.';

  @override
  String get privacidadHubTitulo => 'Privacidad y mis datos';

  @override
  String get privacidadHubAviso => 'Aviso de privacidad';

  @override
  String get privacidadHubAvisoDetalle => 'Qué hacemos con tus datos';

  @override
  String get privacidadHubDatos => 'Descargar mis datos';

  @override
  String get privacidadHubDatosDetalle => 'Una copia de tus datos personales';

  @override
  String get arcoTitulo => 'Mis datos';

  @override
  String get arcoIntro =>
      'Puedes pedir una copia de los datos personales que CareCar guarda de tu cuenta. Es un archivo que podrás guardar o compartir.';

  @override
  String get arcoAlcance =>
      'No incluye lo fiscal y comercial que la agencia conserva por ley (ventas, pagos y facturas): pídelo en la agencia.';

  @override
  String get arcoPedir => 'Pedir una copia de mis datos';

  @override
  String get arcoPidiendo => 'Pidiendo…';

  @override
  String get arcoPreparando => 'Estamos preparando tu archivo';

  @override
  String get arcoPreparandoDetalle =>
      'Tarda unos segundos. Puedes quedarte en esta pantalla.';

  @override
  String get arcoLista => 'Tu archivo está listo';

  @override
  String arcoVence(String fecha) {
    return 'Disponible hasta el $fecha';
  }

  @override
  String get arcoCuidado =>
      'Contiene información personal: guárdalo en un lugar seguro y no lo compartas.';

  @override
  String get arcoDescargar => 'Descargar mi archivo';

  @override
  String get arcoDescargando => 'Preparando…';

  @override
  String get arcoPedirOtra => 'Pedir una copia nueva';

  @override
  String get arcoFallida => 'No pudimos preparar tu archivo. Intenta de nuevo.';

  @override
  String get arcoVencida =>
      'Tu archivo ya no está disponible. Pide una copia nueva.';

  @override
  String get arcoErrorPedir => 'No pudimos pedir tu copia. Intenta de nuevo.';

  @override
  String get arcoSinConexionPedir =>
      'Sin conexión. Conéctate para pedir tu copia.';

  @override
  String get arcoErrorDescarga =>
      'No pudimos descargar tu archivo. Intenta de nuevo.';

  @override
  String get arcoArchivoNoDisponible =>
      'El archivo ya no está disponible. Pide una copia nueva.';

  @override
  String get arcoCargando => 'Cargando tus solicitudes';

  @override
  String get privacidadHubEliminar => 'Eliminar mi cuenta';

  @override
  String get privacidadHubEliminarDetalle =>
      'Borra tu cuenta y tus datos personales';

  @override
  String get eliminarCuentaTitulo => 'Eliminar mi cuenta';

  @override
  String get eliminarCuentaAdvertenciaTitulo => 'No se puede deshacer';

  @override
  String get eliminarCuentaAdvertencia =>
      'Tu cuenta se cierra de inmediato y no podremos recuperarla.';

  @override
  String get eliminarCuentaSeBorraTitulo => 'Qué se borra';

  @override
  String get eliminarCuentaBorra1 => 'Tu nombre, correo y teléfono.';

  @override
  String get eliminarCuentaBorra2 =>
      'Tus direcciones, tus preguntas al asistente, tus cotizaciones y tus solicitudes de estreno.';

  @override
  String get eliminarCuentaBorra3 =>
      'Tu bitácora de gastos y kilometraje, con sus fotos y tickets.';

  @override
  String get eliminarCuentaBorra4 =>
      'Tu ubicación y tus comentarios en las solicitudes de ayuda en carretera.';

  @override
  String get eliminarCuentaConservaTitulo => 'Qué conservamos';

  @override
  String get eliminarCuentaConserva =>
      'Lo que debemos guardar por obligación fiscal, comercial o de garantía: el historial de servicio de tus vehículos, tus compras, pagos y facturas, y la constancia de que aceptaste el aviso de privacidad.';

  @override
  String get eliminarCuentaContrasena => 'Tu contraseña';

  @override
  String get eliminarCuentaContrasenaAyuda =>
      'La pedimos para confirmar que eres tú.';

  @override
  String get eliminarCuentaDeslizar => 'Desliza para eliminar mi cuenta';

  @override
  String get eliminarCuentaConfirmarMensaje =>
      'Se borran tus datos personales y ya no podrás entrar con esta cuenta. No se puede deshacer.';

  @override
  String get eliminarCuentaEliminando => 'Eliminando tu cuenta…';

  @override
  String get eliminarCuentaListo =>
      'Tu cuenta se eliminó. Gracias por usar CareCar.';

  @override
  String get eliminarCuentaContrasenaIncorrecta =>
      'La contraseña no es correcta.';

  @override
  String eliminarCuentaBloqueada(int minutos) {
    String _temp0 = intl.Intl.pluralLogic(
      minutos,
      locale: localeName,
      other: '$minutos minutos',
      one: '1 minuto',
    );
    return 'Demasiados intentos. Intenta de nuevo en $_temp0.';
  }

  @override
  String get eliminarCuentaBloqueadaSinEspera =>
      'Demasiados intentos. Intenta de nuevo más tarde.';

  @override
  String get eliminarCuentaSinConexion =>
      'Sin conexión. Revisa tu internet e inténtalo de nuevo.';

  @override
  String get eliminarCuentaError =>
      'No pudimos eliminar tu cuenta. Inténtalo de nuevo.';

  @override
  String get asistenciaLlamarTitulo => 'Llamar ahora';

  @override
  String get asistenciaLlamarIntro =>
      'Un toque abre el marcador de tu teléfono con el número. Funciona aunque no tengas datos.';

  @override
  String get asistenciaLlamarGrupo => 'A quién llamar';

  @override
  String get asistenciaLlamarEmergencias => 'Emergencias';

  @override
  String get asistenciaLlamarEmergenciasDetalle =>
      '911 · policía, ambulancia y bomberos';

  @override
  String get asistenciaLlamarAgencia => 'La agencia';

  @override
  String get asistenciaLlamarAseguradora => 'Mi aseguradora';

  @override
  String get asistenciaLlamarAseguradoraFalta =>
      'Aún no registras tu aseguradora';

  @override
  String get asistenciaLlamarAseguradoraComoAgregar =>
      'Aún no registras tu aseguradora. Agrégala en los documentos de tu auto (póliza) y aparecerá aquí para llamarla con un toque.';

  @override
  String asistenciaLlamarAccion(String contacto) {
    return 'Llamar a $contacto';
  }

  @override
  String asistenciaLlamarNoSePudo(String numero) {
    return 'No pudimos abrir el marcador. Marca $numero a mano.';
  }

  @override
  String get asistenciaLlamarAtajo => 'Llamar a la agencia o al 911';

  @override
  String get citasCalendarioAgregar => 'Agregar al calendario';

  @override
  String get citasCalendarioTitulo => 'Cita en la agencia';

  @override
  String citasCalendarioDescripcion(String vehiculo) {
    return 'Vehículo: $vehiculo';
  }

  @override
  String get citasCalendarioError =>
      'No pudimos abrir tu calendario. Intenta de nuevo.';

  @override
  String get mantenimientoRecordatorioEnVivo =>
      'Tu próximo servicio ya se acerca. Puedes agendarlo cuando quieras.';
}
