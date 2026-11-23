import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Título de la pantalla del catálogo de modelos.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get catalogoTitulo;

  /// Lo que anuncia el lector de pantalla mientras carga el catálogo.
  ///
  /// In es, this message translates to:
  /// **'Cargando catálogo'**
  String get catalogoCargando;

  /// No description provided for @catalogoVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay modelos'**
  String get catalogoVacioTitulo;

  /// No description provided for @catalogoVacioMensaje.
  ///
  /// In es, this message translates to:
  /// **'Cuando la agencia publique modelos, los verás aquí.'**
  String get catalogoVacioMensaje;

  /// No description provided for @citasAgendarContinuar.
  ///
  /// In es, this message translates to:
  /// **'Revisar y confirmar'**
  String get citasAgendarContinuar;

  /// No description provided for @citasAgendarMotivo.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la visita'**
  String get citasAgendarMotivo;

  /// No description provided for @citasAgendarMotivoSugerencia.
  ///
  /// In es, this message translates to:
  /// **'Elige un motivo'**
  String get citasAgendarMotivoSugerencia;

  /// No description provided for @citasAgendarSinDatos.
  ///
  /// In es, this message translates to:
  /// **'Elige vehículo, día, horario y motivo para continuar.'**
  String get citasAgendarSinDatos;

  /// No description provided for @citasAgendarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get citasAgendarTitulo;

  /// No description provided for @citasAgendarVehiculo.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get citasAgendarVehiculo;

  /// No description provided for @citasAgendarVehiculoSugerencia.
  ///
  /// In es, this message translates to:
  /// **'Elige tu vehículo'**
  String get citasAgendarVehiculoSugerencia;

  /// Aviso tras cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cita cancelada. El horario quedó libre.'**
  String get citasCancelada;

  /// Botón para cancelar una cita.
  ///
  /// In es, this message translates to:
  /// **'Cancelar cita'**
  String get citasCancelar;

  /// Acción de peligro del diálogo de cancelar.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get citasCancelarConfirmar;

  /// Mensaje del diálogo de cancelar.
  ///
  /// In es, this message translates to:
  /// **'Tu cita del {fecha} a las {hora} se cancelará y el horario quedará libre para otras personas.'**
  String citasCancelarDialogoMensaje(DateTime fecha, String hora);

  /// Título del diálogo de confirmación.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar esta cita?'**
  String get citasCancelarDialogoTitulo;

  /// Fallo al cancelar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cancelar tu cita. Intenta de nuevo.'**
  String get citasCancelarError;

  /// Acción segura del diálogo de cancelar.
  ///
  /// In es, this message translates to:
  /// **'Mantener cita'**
  String get citasCancelarMantener;

  /// 409: la cita ya no está confirmada o pasó el plazo.
  ///
  /// In es, this message translates to:
  /// **'Esta cita ya no se puede cancelar.'**
  String get citasCancelarNoDisponible;

  /// Lo que anuncia el lector de pantalla mientras carga la disponibilidad.
  ///
  /// In es, this message translates to:
  /// **'Cargando disponibilidad del taller'**
  String get citasCargando;

  /// No description provided for @citasCargandoAgendar.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus vehículos y los horarios del taller'**
  String get citasCargandoAgendar;

  /// Botón de paginación.
  ///
  /// In es, this message translates to:
  /// **'Cargar más citas'**
  String get citasCargarMas;

  /// No description provided for @citasConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cita'**
  String get citasConfirmar;

  /// Mensaje cuando el cliente ya tiene cita ese día con ese vehículo.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una cita el {fecha} de {inicio} a {fin}. Si necesitas cambiarla, cancélala primero.'**
  String citasDuplicadaMensaje(DateTime fecha, String inicio, String fin);

  /// No description provided for @citasDuplicadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una cita ese día'**
  String get citasDuplicadaTitulo;

  /// No description provided for @citasEditar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar datos'**
  String get citasEditar;

  /// No description provided for @citasErrorAgendar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos agendar tu cita. Intenta de nuevo.'**
  String get citasErrorAgendar;

  /// Fallo al pedir la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más citas. Intenta de nuevo.'**
  String get citasErrorMas;

  /// Estado de cita atendida.
  ///
  /// In es, this message translates to:
  /// **'Atendida'**
  String get citasEstadoAtendida;

  /// Estado de cita cancelada.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get citasEstadoCancelada;

  /// Estado de cita confirmada.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get citasEstadoConfirmada;

  /// Estado que la app no reconoce.
  ///
  /// In es, this message translates to:
  /// **'Sin estado'**
  String get citasEstadoDesconocido;

  /// Estado de cita a la que el cliente no llegó.
  ///
  /// In es, this message translates to:
  /// **'No asistió'**
  String get citasEstadoNoAsistio;

  /// Título de una cita en la lista.
  ///
  /// In es, this message translates to:
  /// **'{fecha} · {inicio}'**
  String citasFilaTitulo(DateTime fecha, String inicio);

  /// Nombre cuando la cita no trae el vehículo.
  ///
  /// In es, this message translates to:
  /// **'Tu vehículo'**
  String get citasFilaVehiculoGenerico;

  /// Botón que ofrece una franja cercana cuando la elegida se llenó.
  ///
  /// In es, this message translates to:
  /// **'{fecha} · {hora}'**
  String citasFranjaCercana(DateTime fecha, String hora);

  /// Encabezado de las franjas del día elegido en el calendario.
  ///
  /// In es, this message translates to:
  /// **'Horarios del {dia}'**
  String citasHorariosDelDia(DateTime dia);

  /// No description provided for @citasHorariosVacio.
  ///
  /// In es, this message translates to:
  /// **'Este día ya no tiene lugares.'**
  String get citasHorariosVacio;

  /// No description provided for @citasListoCerrar.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get citasListoCerrar;

  /// Confirmación tras agendar.
  ///
  /// In es, this message translates to:
  /// **'Te esperamos el {fecha} a las {hora}.'**
  String citasListoMensaje(DateTime fecha, String hora);

  /// No description provided for @citasListoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cita confirmada'**
  String get citasListoTitulo;

  /// Acción del estado vacío y de la lista.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get citasMisCitasAgendar;

  /// Lo que anuncia el lector de pantalla mientras cargan las citas.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus citas'**
  String get citasMisCitasCargando;

  /// Título de la lista de citas del cliente.
  ///
  /// In es, this message translates to:
  /// **'Mis citas'**
  String get citasMisCitasTitulo;

  /// Mensaje cuando no hay citas.
  ///
  /// In es, this message translates to:
  /// **'Cuando agendes una cita aparecerá aquí con su estado.'**
  String get citasMisCitasVacioMensaje;

  /// Título cuando el cliente no tiene ninguna cita.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes citas'**
  String get citasMisCitasVacioTitulo;

  /// No description provided for @citasMotivoGarantia.
  ///
  /// In es, this message translates to:
  /// **'Garantía'**
  String get citasMotivoGarantia;

  /// No description provided for @citasMotivoMantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get citasMotivoMantenimiento;

  /// No description provided for @citasMotivoOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get citasMotivoOtro;

  /// No description provided for @citasMotivoReparacion.
  ///
  /// In es, this message translates to:
  /// **'Reparación'**
  String get citasMotivoReparacion;

  /// No description provided for @citasMotivoRevision.
  ///
  /// In es, this message translates to:
  /// **'Revisión'**
  String get citasMotivoRevision;

  /// No description provided for @citasNotaDiasSinCupo.
  ///
  /// In es, this message translates to:
  /// **'Los días tachados no tienen lugares disponibles.'**
  String get citasNotaDiasSinCupo;

  /// Encabezado de las citas ya atendidas, canceladas o vencidas.
  ///
  /// In es, this message translates to:
  /// **'Pasadas'**
  String get citasPasadas;

  /// Sección de pasadas sin citas.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes citas pasadas.'**
  String get citasPasadasVacio;

  /// Encabezado de las citas confirmadas que aún no pasan.
  ///
  /// In es, this message translates to:
  /// **'Próximas'**
  String get citasProximas;

  /// Sección de próximas sin citas.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas próximas.'**
  String get citasProximasVacio;

  /// Botón para cambiar la cita de horario.
  ///
  /// In es, this message translates to:
  /// **'Reprogramar'**
  String get citasReprogramar;

  /// Cita que se va a cambiar.
  ///
  /// In es, this message translates to:
  /// **'Tu cita actual: {fecha} · {hora}'**
  String citasReprogramarActual(DateTime fecha, String hora);

  /// Lo que anuncia el lector de pantalla al cargar.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu cita y los horarios del taller'**
  String get citasReprogramarCargando;

  /// Botón de confirmar el cambio.
  ///
  /// In es, this message translates to:
  /// **'Cambiar a este horario'**
  String get citasReprogramarConfirmar;

  /// Fallo al reprogramar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos reprogramar tu cita. Intenta de nuevo.'**
  String get citasReprogramarError;

  /// Aviso tras reprogramar.
  ///
  /// In es, this message translates to:
  /// **'Cita reprogramada para el {fecha} a las {hora}. El horario anterior quedó libre.'**
  String citasReprogramarListo(DateTime fecha, String hora);

  /// 409: la cita ya no está confirmada o pasó el plazo.
  ///
  /// In es, this message translates to:
  /// **'Esta cita ya no se puede cambiar.'**
  String get citasReprogramarNoDisponible;

  /// Mensaje si la cita no está en la lista.
  ///
  /// In es, this message translates to:
  /// **'Puede que ya no esté disponible para cambiarla.'**
  String get citasReprogramarNoEncontradaMensaje;

  /// Título si la cita no está en la lista.
  ///
  /// In es, this message translates to:
  /// **'No encontramos esta cita'**
  String get citasReprogramarNoEncontradaTitulo;

  /// Ayuda cuando falta elegir la franja.
  ///
  /// In es, this message translates to:
  /// **'Elige un día y un horario nuevos para continuar.'**
  String get citasReprogramarSinFranja;

  /// Título de la pantalla de reprogramar.
  ///
  /// In es, this message translates to:
  /// **'Reprogramar cita'**
  String get citasReprogramarTitulo;

  /// No description provided for @citasResumenFecha.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get citasResumenFecha;

  /// No description provided for @citasResumenHorario.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get citasResumenHorario;

  /// Hora de inicio y fin de la franja en el resumen.
  ///
  /// In es, this message translates to:
  /// **'{inicio} a {fin}'**
  String citasResumenHorarioValor(String inicio, String fin);

  /// No description provided for @citasResumenMotivo.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get citasResumenMotivo;

  /// No description provided for @citasResumenTitulo.
  ///
  /// In es, this message translates to:
  /// **'Resumen de tu cita'**
  String get citasResumenTitulo;

  /// No description provided for @citasResumenVehiculo.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get citasResumenVehiculo;

  /// No description provided for @citasSinCupoMensaje.
  ///
  /// In es, this message translates to:
  /// **'Alguien la tomó mientras decidías. Estas opciones están cerca:'**
  String get citasSinCupoMensaje;

  /// No description provided for @citasSinCupoNinguna.
  ///
  /// In es, this message translates to:
  /// **'Por ahora no hay otros horarios cercanos. Elige otro día.'**
  String get citasSinCupoNinguna;

  /// No description provided for @citasSinCupoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ese horario ya no tiene lugar'**
  String get citasSinCupoTitulo;

  /// No description provided for @citasSinDiaElegido.
  ///
  /// In es, this message translates to:
  /// **'Elige un día para ver sus horarios.'**
  String get citasSinDiaElegido;

  /// No description provided for @citasSinVehiculosMensaje.
  ///
  /// In es, this message translates to:
  /// **'La agencia registra tu auto cuando te lo entrega. Después podrás agendar aquí.'**
  String get citasSinVehiculosMensaje;

  /// No description provided for @citasSinVehiculosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes vehículos'**
  String get citasSinVehiculosTitulo;

  /// Título de la pantalla con el calendario de disponibilidad.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad del taller'**
  String get citasTitulo;

  /// No description provided for @citasVacioMensaje.
  ///
  /// In es, this message translates to:
  /// **'Por ahora el taller no tiene lugares en los próximos días. Vuelve a revisar pronto.'**
  String get citasVacioMensaje;

  /// No description provided for @citasVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin lugares disponibles'**
  String get citasVacioTitulo;

  /// Precio de entrada de un modelo.
  ///
  /// In es, this message translates to:
  /// **'Desde {precio}'**
  String precioDesde(String precio);

  /// Descripción de la foto de un modelo para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Foto del {modelo}'**
  String fotoDeModelo(String modelo);

  /// Acceso del detalle a la ficha técnica del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Ficha técnica'**
  String get vehiculosAccesoFicha;

  /// Acceso del detalle al historial de servicios del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Historial de servicios'**
  String get vehiculosAccesoHistorial;

  /// Acceso del detalle a los manuales del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Manuales'**
  String get vehiculosAccesoManuales;

  /// Se dice en un acceso del detalle cuya pantalla aún no existe.
  ///
  /// In es, this message translates to:
  /// **'Disponible pronto'**
  String get vehiculosAccesoPronto;

  /// Etiqueta del año del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get vehiculosAnio;

  /// Lo que anuncia el lector de pantalla mientras carga el garaje.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu garaje'**
  String get vehiculosCargando;

  /// Etiqueta del color del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get vehiculosColor;

  /// Lo que lee el lector de pantalla en el botón que copia el VIN.
  ///
  /// In es, this message translates to:
  /// **'Copiar VIN'**
  String get vehiculosCopiarVin;

  /// Título de la pantalla de detalle de un vehículo.
  ///
  /// In es, this message translates to:
  /// **'Detalle del vehículo'**
  String get vehiculosDetalleTitulo;

  /// Etiqueta del kilometraje del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje'**
  String get vehiculosKilometraje;

  /// Kilometraje de un vehículo.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String vehiculosKilometros(String km);

  /// Fecha de cierre del servicio que dejó el kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Actualizado por el taller el {fecha}'**
  String vehiculosKmActualizado(String fecha);

  /// Se muestra si el kilometraje no trae fecha de cierre.
  ///
  /// In es, this message translates to:
  /// **'Aún sin actualización del taller'**
  String get vehiculosKmSinActualizar;

  /// Se muestra si el vehículo no tiene kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Sin kilometraje registrado'**
  String get vehiculosKmSinDato;

  /// Mensaje cuando el vehículo pedido no existe en el garaje.
  ///
  /// In es, this message translates to:
  /// **'Ese vehículo ya no está en tu garaje. Vuelve al garaje para elegir otro.'**
  String get vehiculosNoEncontradoMensaje;

  /// Título cuando el vehículo pedido no existe en el garaje.
  ///
  /// In es, this message translates to:
  /// **'No encontramos el vehículo'**
  String get vehiculosNoEncontradoTitulo;

  /// Placas de un vehículo.
  ///
  /// In es, this message translates to:
  /// **'Placas {placas}'**
  String vehiculosPlacas(String placas);

  /// Etiqueta de las placas del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Placas'**
  String get vehiculosPlacasEtiqueta;

  /// Se muestra cuando el vehículo aún no tiene placas registradas.
  ///
  /// In es, this message translates to:
  /// **'Sin placas'**
  String get vehiculosSinPlacas;

  /// Título de la pantalla con los vehículos del cliente.
  ///
  /// In es, this message translates to:
  /// **'Mi garaje'**
  String get vehiculosTitulo;

  /// No description provided for @vehiculosVacioMensaje.
  ///
  /// In es, this message translates to:
  /// **'La agencia registra tus autos al entregártelos. Cuando lo haga, aparecerán aquí.'**
  String get vehiculosVacioMensaje;

  /// No description provided for @vehiculosVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes vehículos'**
  String get vehiculosVacioTitulo;

  /// Etiqueta de la versión del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get vehiculosVersion;

  /// Etiqueta del número de serie del vehículo.
  ///
  /// In es, this message translates to:
  /// **'VIN'**
  String get vehiculosVin;

  /// Confirmación al copiar el VIN.
  ///
  /// In es, this message translates to:
  /// **'VIN copiado'**
  String get vehiculosVinCopiado;

  /// Botón para cerrar un aviso.
  ///
  /// In es, this message translates to:
  /// **'Cerrar aviso'**
  String get avisoCerrar;

  /// Nombre de la barra de navegación para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Navegación principal'**
  String get navegacionPrincipal;

  /// Lo que anuncia un botón mientras trabaja.
  ///
  /// In es, this message translates to:
  /// **'{texto}, cargando'**
  String botonCargando(String texto);

  /// Nombre del calendario con el mes visible.
  ///
  /// In es, this message translates to:
  /// **'Calendario de {mes}'**
  String calendarioDelMes(DateTime mes);

  /// Encabezado del calendario con mes y año.
  ///
  /// In es, this message translates to:
  /// **'{mes}'**
  String calendarioTituloMes(DateTime mes);

  /// Botón para ir al mes anterior.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get calendarioMesAnterior;

  /// Botón para ir al mes siguiente.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get calendarioMesSiguiente;

  /// Día del calendario, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'{fecha}'**
  String calendarioDia(DateTime fecha);

  /// Marca el día de hoy en el calendario.
  ///
  /// In es, this message translates to:
  /// **'hoy'**
  String get calendarioHoy;

  /// Marca el día elegido en el calendario.
  ///
  /// In es, this message translates to:
  /// **'seleccionado'**
  String get calendarioSeleccionado;

  /// Marca un día sin lugares en el calendario.
  ///
  /// In es, this message translates to:
  /// **'sin cupo'**
  String get calendarioSinCupo;

  /// Iniciales de los días de la semana, de lunes a domingo, separadas por coma.
  ///
  /// In es, this message translates to:
  /// **'L,M,X,J,V,S,D'**
  String get calendarioInicialesDias;

  /// Botón principal del diálogo de confirmación.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get deslizarConfirmar;

  /// Botón secundario del diálogo de confirmación.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get deslizarCancelar;

  /// Lo que anuncia el control de deslizar para confirmar.
  ///
  /// In es, this message translates to:
  /// **'{texto}, desliza para confirmar'**
  String deslizarEtiqueta(String texto);

  /// Firma ausente, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Sin firma de {firmante}'**
  String firmaSinFirma(String firmante);

  /// Firma presente, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Firma de {pie}'**
  String firmaDe(String pie);

  /// Texto del recuadro de firma vacío.
  ///
  /// In es, this message translates to:
  /// **'Aún sin firma'**
  String get firmaAunSinFirma;

  /// Nombre de la galería con la foto visible.
  ///
  /// In es, this message translates to:
  /// **'Galería de fotos, {actual} de {total}'**
  String galeriaEtiqueta(int actual, int total);

  /// Contador visible de la galería.
  ///
  /// In es, this message translates to:
  /// **'{actual} de {total}'**
  String galeriaContador(int actual, int total);

  /// Botón para ir a la foto anterior.
  ///
  /// In es, this message translates to:
  /// **'Foto anterior'**
  String get galeriaFotoAnterior;

  /// Botón para ir a la foto siguiente.
  ///
  /// In es, this message translates to:
  /// **'Foto siguiente'**
  String get galeriaFotoSiguiente;

  /// Botón para cerrar la foto ampliada.
  ///
  /// In es, this message translates to:
  /// **'Cerrar foto'**
  String get galeriaCerrarFoto;

  /// Mensaje de una gráfica sin puntos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay datos para mostrar.'**
  String get graficaSinDatos;

  /// Botón para volver de la tabla a la gráfica.
  ///
  /// In es, this message translates to:
  /// **'Ver gráfica'**
  String get graficaVerGrafica;

  /// Botón para ver los datos de la gráfica como tabla.
  ///
  /// In es, this message translates to:
  /// **'Ver como tabla'**
  String get graficaVerTabla;

  /// Fila de la tabla de una gráfica.
  ///
  /// In es, this message translates to:
  /// **'{etiqueta}: {valor}'**
  String graficaPunto(String etiqueta, String valor);

  /// Estado de un paso terminado en la línea de tiempo.
  ///
  /// In es, this message translates to:
  /// **'completado'**
  String get lineaPasoHecho;

  /// Estado del paso actual en la línea de tiempo.
  ///
  /// In es, this message translates to:
  /// **'en curso'**
  String get lineaPasoActual;

  /// Estado de un paso por hacer en la línea de tiempo.
  ///
  /// In es, this message translates to:
  /// **'pendiente'**
  String get lineaPasoPendiente;

  /// Botón para cargar más pasos de la línea de tiempo.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get lineaVerMas;

  /// Posición de un paso en la línea de tiempo.
  ///
  /// In es, this message translates to:
  /// **'Etapa {posicion} de {total}'**
  String lineaEtapa(int posicion, int total);

  /// Pestaña con su posición, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'{texto}, {posicion} de {total}'**
  String pestanaPosicion(String texto, int posicion, int total);

  /// Mensaje del selector de horarios vacío.
  ///
  /// In es, this message translates to:
  /// **'No hay horarios para este día.'**
  String get franjasSinHorarios;

  /// Nombre del selector de horarios para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Horarios disponibles'**
  String get franjasDisponibles;

  /// Contador de páginas del visor de documentos.
  ///
  /// In es, this message translates to:
  /// **'Página {pagina} de {total}'**
  String pdfPagina(int pagina, int total);

  /// Lo que anuncia el visor mientras abre un documento.
  ///
  /// In es, this message translates to:
  /// **'Cargando documento'**
  String get pdfCargando;

  /// Nombre del control de comparar antes y después.
  ///
  /// In es, this message translates to:
  /// **'Comparación. {antes} contra {despues}'**
  String comparacionEtiqueta(String antes, String despues);

  /// Valor del control de comparar antes y después.
  ///
  /// In es, this message translates to:
  /// **'{porcentaje} % del antes'**
  String comparacionValor(int porcentaje);

  /// Valor al mover el control de comparar.
  ///
  /// In es, this message translates to:
  /// **'{porcentaje} %'**
  String comparacionPorcentaje(int porcentaje);

  /// Cantidad de pendientes de un destino de la barra de navegación.
  ///
  /// In es, this message translates to:
  /// **'{conteo} pendientes'**
  String navegacionPendientes(int conteo);

  /// Franja horaria sin lugares.
  ///
  /// In es, this message translates to:
  /// **'{hora} · sin cupo'**
  String franjaSinCupo(String hora);

  /// Franja horaria con sus lugares libres.
  ///
  /// In es, this message translates to:
  /// **'{hora} · {cupo, plural, =1{1 lugar} other{{cupo} lugares}}'**
  String franjaConCupo(String hora, int cupo);

  /// Pista de la foto de la galería para ampliarla.
  ///
  /// In es, this message translates to:
  /// **'Ampliar'**
  String get galeriaAmpliar;

  /// Mensaje de la galería sin fotos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay fotos.'**
  String get galeriaSinFotos;

  /// Mensaje por defecto del diálogo de confirmación.
  ///
  /// In es, this message translates to:
  /// **'Confirma que quieres continuar.'**
  String get deslizarMensajeConfirmacion;

  /// Etiqueta del selector de idioma de la app.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idiomaEtiqueta;

  /// Opción que sigue el idioma del sistema.
  ///
  /// In es, this message translates to:
  /// **'Automático (idioma del sistema)'**
  String get idiomaSistema;

  /// Nombre del idioma español, escrito en español.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get idiomaEspanol;

  /// Nombre del idioma inglés, escrito en inglés.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get idiomaIngles;

  /// Título de la pantalla de detalle de un modelo.
  ///
  /// In es, this message translates to:
  /// **'Detalle del modelo'**
  String get catalogoDetalleTitulo;

  /// Lo que anuncia el lector de pantalla mientras carga el detalle.
  ///
  /// In es, this message translates to:
  /// **'Cargando el modelo'**
  String get catalogoDetalleCargando;

  /// Título cuando el modelo ya no está en el catálogo.
  ///
  /// In es, this message translates to:
  /// **'No encontramos el modelo'**
  String get catalogoNoEncontradoTitulo;

  /// Explicación cuando el modelo ya no está en el catálogo.
  ///
  /// In es, this message translates to:
  /// **'Es posible que la agencia ya no lo ofrezca. Vuelve al catálogo para ver los modelos actuales.'**
  String get catalogoNoEncontradoMensaje;

  /// Encabezado de la galería de fotos del modelo.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get catalogoGaleria;

  /// Encabezado de las versiones del modelo.
  ///
  /// In es, this message translates to:
  /// **'Versiones'**
  String get catalogoVersiones;

  /// Marca la versión que se muestra en el detalle.
  ///
  /// In es, this message translates to:
  /// **'La que estás viendo'**
  String get catalogoVersionActual;

  /// Encabezado de la ficha resumida del modelo.
  ///
  /// In es, this message translates to:
  /// **'Ficha técnica'**
  String get catalogoFicha;

  /// Versión sin precio de lista.
  ///
  /// In es, this message translates to:
  /// **'Precio por confirmar'**
  String get catalogoSinPrecio;

  /// Descripción de una foto de la galería que no trae texto propio.
  ///
  /// In es, this message translates to:
  /// **'{modelo}, foto {numero}'**
  String catalogoFotoDe(String modelo, int numero);

  /// Descripción de una foto de la galería con su color.
  ///
  /// In es, this message translates to:
  /// **'{modelo}, color {color}, foto {numero}'**
  String catalogoFotoDeColor(String modelo, String color, int numero);

  /// Botón de la barra del catálogo que activa el modo comparar.
  ///
  /// In es, this message translates to:
  /// **'Comparar modelos'**
  String get catalogoComparar;

  /// Botón de la barra del catálogo que sale del modo comparar.
  ///
  /// In es, this message translates to:
  /// **'Salir de comparar'**
  String get catalogoSalirDeComparar;

  /// Texto del botón de abajo del catálogo en modo comparar, según cuántos modelos hay elegidos.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =0{Elige de 2 a 3 modelos} =1{Elige otro modelo} other{Comparar {cantidad} modelos}}'**
  String catalogoCompararElegidos(int cantidad);

  /// Etiqueta de la casilla que elige un modelo para comparar.
  ///
  /// In es, this message translates to:
  /// **'Comparar {modelo}'**
  String catalogoCompararModelo(String modelo);

  /// Título de la pantalla de comparativa.
  ///
  /// In es, this message translates to:
  /// **'Comparar modelos'**
  String get catalogoComparadorTitulo;

  /// Lo que anuncia el lector de pantalla mientras carga la comparativa.
  ///
  /// In es, this message translates to:
  /// **'Cargando la comparativa'**
  String get catalogoComparadorCargando;

  /// Título cuando la comparativa no trae entre dos y tres modelos válidos.
  ///
  /// In es, this message translates to:
  /// **'Elige de dos a tres modelos'**
  String get catalogoComparadorIdsMalosTitulo;

  /// Explicación cuando la comparativa no trae entre dos y tres modelos válidos.
  ///
  /// In es, this message translates to:
  /// **'Vuelve al catálogo, activa comparar y marca los modelos que quieras ver lado a lado.'**
  String get catalogoComparadorIdsMalosMensaje;

  /// Etiqueta de la fila de precio en la comparativa.
  ///
  /// In es, this message translates to:
  /// **'Precio desde'**
  String get catalogoComparadorPrecio;

  /// Valor de una celda cuando el modelo no tiene ese dato.
  ///
  /// In es, this message translates to:
  /// **'Sin dato'**
  String get catalogoComparadorSinDato;

  /// Marca el modelo con el menor precio en la comparativa.
  ///
  /// In es, this message translates to:
  /// **'Precio más bajo'**
  String get catalogoComparadorMasBajo;

  /// Lo que lee el lector de pantalla en una celda de la comparativa.
  ///
  /// In es, this message translates to:
  /// **'{dato}, {modelo}: {valor}'**
  String catalogoComparadorCelda(String dato, String modelo, String valor);

  /// Botón del detalle de un modelo que abre la calculadora de toma a cuenta.
  ///
  /// In es, this message translates to:
  /// **'Calcular toma a cuenta'**
  String get catalogoCalcularTomaACuenta;

  /// Título de la calculadora de toma a cuenta.
  ///
  /// In es, this message translates to:
  /// **'Toma a cuenta'**
  String get calculadoraTitulo;

  /// Leyenda legal que siempre se ve junto a la calculadora y al resultado. El texto final lo revisa el PO.
  ///
  /// In es, this message translates to:
  /// **'Estimación no vinculante. No es una oferta de compra: el valor final lo define la agencia cuando revise tu auto.'**
  String get calculadoraLeyenda;

  /// Modelo nuevo contra el que se estima.
  ///
  /// In es, this message translates to:
  /// **'Contra: {modelo}'**
  String calculadoraContra(String modelo);

  /// Etiqueta del selector del auto a dar a cuenta.
  ///
  /// In es, this message translates to:
  /// **'Tu auto'**
  String get calculadoraAuto;

  /// Opción para capturar a mano un auto que no está en el garaje.
  ///
  /// In es, this message translates to:
  /// **'Otro auto'**
  String get calculadoraOtroAuto;

  /// Lo que anuncia el lector de pantalla mientras cargan los autos del cliente.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus autos'**
  String get calculadoraCargandoAutos;

  /// Campo de marca del auto capturado.
  ///
  /// In es, this message translates to:
  /// **'Marca'**
  String get calculadoraMarca;

  /// Campo de modelo del auto capturado, por ejemplo Versa.
  ///
  /// In es, this message translates to:
  /// **'Modelo'**
  String get calculadoraModelo;

  /// Campo del año del auto capturado.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get calculadoraAnio;

  /// Campo del kilometraje actual del auto.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje'**
  String get calculadoraKm;

  /// Ayuda del campo de kilometraje.
  ///
  /// In es, this message translates to:
  /// **'En kilómetros, como marca el tablero hoy'**
  String get calculadoraKmAyuda;

  /// Selector del estado general del auto.
  ///
  /// In es, this message translates to:
  /// **'Estado general'**
  String get calculadoraEstado;

  /// Estado del auto.
  ///
  /// In es, this message translates to:
  /// **'Excelente'**
  String get calculadoraEstadoExcelente;

  /// Estado del auto.
  ///
  /// In es, this message translates to:
  /// **'Bueno'**
  String get calculadoraEstadoBueno;

  /// Estado del auto.
  ///
  /// In es, this message translates to:
  /// **'Regular'**
  String get calculadoraEstadoRegular;

  /// Estado del auto.
  ///
  /// In es, this message translates to:
  /// **'Malo'**
  String get calculadoraEstadoMalo;

  /// Botón que pide la estimación.
  ///
  /// In es, this message translates to:
  /// **'Calcular estimación'**
  String get calculadoraCalcular;

  /// Error del campo de marca vacío.
  ///
  /// In es, this message translates to:
  /// **'Escribe la marca'**
  String get calculadoraErrorMarca;

  /// Error del campo de modelo vacío.
  ///
  /// In es, this message translates to:
  /// **'Escribe el modelo'**
  String get calculadoraErrorModelo;

  /// Error del campo de año.
  ///
  /// In es, this message translates to:
  /// **'Escribe un año de cuatro cifras, de 1900 a {maximo}'**
  String calculadoraErrorAnio(int maximo);

  /// Error del campo de kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Escribe un kilometraje de 0 a 999,999'**
  String get calculadoraErrorKm;

  /// Título de la tarjeta con el resultado.
  ///
  /// In es, this message translates to:
  /// **'Estimación de toma a cuenta'**
  String get calculadoraResultadoTitulo;

  /// El rango estimado, por ejemplo $137,800 a $161,800.
  ///
  /// In es, this message translates to:
  /// **'{minimo} a {maximo}'**
  String calculadoraRango(String minimo, String maximo);

  /// El rango estimado como lo lee el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Entre {minimo} y {maximo}'**
  String calculadoraRangoLector(String minimo, String maximo);

  /// Los supuestos con que se calculó la estimación.
  ///
  /// In es, this message translates to:
  /// **'Se calculó para {edad, plural, =0{un auto de este año} =1{un auto de 1 año} other{un auto de {edad} años}}, con {km} km esperados para esa edad y un margen de más y menos {margen} %.'**
  String calculadoraSupuestos(int edad, String km, int margen);

  /// Título cuando la agencia no tiene datos para ese auto (422).
  ///
  /// In es, this message translates to:
  /// **'Todavía no estimamos ese auto'**
  String get calculadoraSinParametrosTitulo;

  /// Explicación cuando la agencia no tiene datos para ese auto (422).
  ///
  /// In es, this message translates to:
  /// **'La agencia aún no tiene datos para esa marca, modelo y año. Pide una valuación formal en la agencia.'**
  String get calculadoraSinParametrosMensaje;

  /// Aviso cuando el servidor rechaza los datos.
  ///
  /// In es, this message translates to:
  /// **'No pudimos calcular la estimación. Revisa los datos e intenta de nuevo.'**
  String get calculadoraErrorDatos;

  /// Aviso cuando no hay red al calcular.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Conéctate e intenta de nuevo.'**
  String get calculadoraErrorSinConexion;

  /// Aviso cuando el vehículo no es del cliente o el modelo ya no está vigente.
  ///
  /// In es, this message translates to:
  /// **'No encontramos ese auto o ese modelo. Vuelve atrás e intenta de nuevo.'**
  String get calculadoraErrorNoEncontrado;

  /// Aviso de error inesperado al calcular.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal al calcular. Intenta de nuevo en un momento.'**
  String get calculadoraErrorGenerico;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
