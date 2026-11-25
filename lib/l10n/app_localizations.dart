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

  /// Cuenta regresiva del bloqueo por intentos, cuando falta más de un minuto.
  ///
  /// In es, this message translates to:
  /// **'Espera {minutos} min para volver a intentar.'**
  String accesoBloqueoMinutos(int minutos);

  /// Cuenta regresiva del bloqueo por intentos en su último minuto.
  ///
  /// In es, this message translates to:
  /// **'Espera {segundos} s para volver a intentar.'**
  String accesoBloqueoSegundos(int segundos);

  /// Título del aviso cuando el servidor bloqueó el acceso por demasiados intentos fallidos.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos'**
  String get accesoBloqueoTitulo;

  /// Etiqueta del campo de contraseña en la pantalla de acceso.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get accesoContrasenaEtiqueta;

  /// Error bajo el campo cuando se intenta entrar sin contraseña.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu contraseña.'**
  String get accesoContrasenaVacia;

  /// Ayuda bajo el campo de correo: con cuál de sus correos entra el cliente.
  ///
  /// In es, this message translates to:
  /// **'El que le diste a la agencia'**
  String get accesoCorreoAyuda;

  /// Etiqueta del campo de correo en la pantalla de acceso.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get accesoCorreoEtiqueta;

  /// Error bajo el campo cuando el correo no tiene forma de correo.
  ///
  /// In es, this message translates to:
  /// **'Escribe un correo válido, como nombre@dominio.com.'**
  String get accesoCorreoInvalido;

  /// Error bajo el campo cuando se intenta entrar sin correo.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo.'**
  String get accesoCorreoVacio;

  /// Texto del botón mientras el servidor responde al inicio de sesión.
  ///
  /// In es, this message translates to:
  /// **'Entrando…'**
  String get accesoEntrando;

  /// Botón principal de la pantalla de acceso.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get accesoEntrar;

  /// Título del aviso cuando el acceso falla por credenciales u otro error.
  ///
  /// In es, this message translates to:
  /// **'No pudimos iniciar sesión'**
  String get accesoFalloTitulo;

  /// Nombre de la app en el encabezado del acceso. Es un nombre propio: no se traduce.
  ///
  /// In es, this message translates to:
  /// **'CareCar'**
  String get accesoMarca;

  /// Enlace a la recuperación de contraseña desde la pantalla de acceso.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get accesoOlvide;

  /// Detalle del aviso cuando el servidor está despertando y la petición sigue en curso.
  ///
  /// In es, this message translates to:
  /// **'La primera vez después de un rato puede tardar hasta un minuto.'**
  String get accesoServidorDespertandoMensaje;

  /// Título del aviso cuando el servidor tarda más de unos segundos en responder al acceso.
  ///
  /// In es, this message translates to:
  /// **'Despertando el servidor…'**
  String get accesoServidorDespertandoTitulo;

  /// Título del aviso cuando no se pudo llegar al servidor al intentar entrar.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get accesoSinConexionTitulo;

  /// Nota que explica por qué no hay registro: la cuenta la entrega la agencia.
  ///
  /// In es, this message translates to:
  /// **'La agencia te entrega tu acceso cuando recibes tu unidad. Si no lo tienes, comunícate con la agencia.'**
  String get accesoSinRegistro;

  /// Frase bajo el nombre de la app en la pantalla de acceso.
  ///
  /// In es, this message translates to:
  /// **'Tu acceso a la agencia'**
  String get accesoSubtitulo;

  /// No description provided for @asistenciaGuiaChoquePaso1.
  ///
  /// In es, this message translates to:
  /// **'Detén el auto en un lugar seguro, apaga el motor y enciende las luces intermitentes.'**
  String get asistenciaGuiaChoquePaso1;

  /// No description provided for @asistenciaGuiaChoquePaso2.
  ///
  /// In es, this message translates to:
  /// **'Revisa si hay personas heridas. Si las hay, llama al 911 de inmediato y no muevas a quien tenga dolor de cuello o espalda.'**
  String get asistenciaGuiaChoquePaso2;

  /// No description provided for @asistenciaGuiaChoquePaso3.
  ///
  /// In es, this message translates to:
  /// **'Si puedes, baja del auto y ponte detrás de una barrera, lejos del tráfico. Coloca los triángulos de advertencia.'**
  String get asistenciaGuiaChoquePaso3;

  /// No description provided for @asistenciaGuiaChoquePaso4.
  ///
  /// In es, this message translates to:
  /// **'Llama a tu aseguradora y espera al ajustador. No aceptes ni firmes acuerdos con el otro conductor sin ella.'**
  String get asistenciaGuiaChoquePaso4;

  /// No description provided for @asistenciaGuiaChoquePaso5.
  ///
  /// In es, this message translates to:
  /// **'Toma fotos de los vehículos, las placas, los daños y el lugar. Anota el nombre, el teléfono y los datos del seguro del otro conductor.'**
  String get asistenciaGuiaChoquePaso5;

  /// No description provided for @asistenciaGuiaChoquePaso6.
  ///
  /// In es, this message translates to:
  /// **'No muevas el auto hasta que lo autorice la autoridad o el ajustador, salvo que estorbe y sea seguro hacerlo.'**
  String get asistenciaGuiaChoquePaso6;

  /// No description provided for @asistenciaGuiaChoqueResumen.
  ///
  /// In es, this message translates to:
  /// **'Pasos para cuidar a todos y proteger tu reclamación.'**
  String get asistenciaGuiaChoqueResumen;

  /// No description provided for @asistenciaGuiaChoqueTitulo.
  ///
  /// In es, this message translates to:
  /// **'Qué hacer en un choque'**
  String get asistenciaGuiaChoqueTitulo;

  /// No description provided for @asistenciaGuiaCorrientePaso1.
  ///
  /// In es, this message translates to:
  /// **'Estaciona el otro auto de frente, sin que se toquen. Apaga ambos motores y los accesorios.'**
  String get asistenciaGuiaCorrientePaso1;

  /// No description provided for @asistenciaGuiaCorrientePaso2.
  ///
  /// In es, this message translates to:
  /// **'Conecta una pinza roja al polo positivo (+) de tu batería descargada y el otro extremo al polo positivo del auto que da corriente.'**
  String get asistenciaGuiaCorrientePaso2;

  /// No description provided for @asistenciaGuiaCorrientePaso3.
  ///
  /// In es, this message translates to:
  /// **'Conecta una pinza negra al polo negativo (−) de la batería buena y el otro extremo a una parte metálica sin pintar del motor de tu auto, lejos de la batería.'**
  String get asistenciaGuiaCorrientePaso3;

  /// No description provided for @asistenciaGuiaCorrientePaso4.
  ///
  /// In es, this message translates to:
  /// **'Enciende el auto que da corriente y déjalo funcionando unos minutos.'**
  String get asistenciaGuiaCorrientePaso4;

  /// No description provided for @asistenciaGuiaCorrientePaso5.
  ///
  /// In es, this message translates to:
  /// **'Intenta encender tu auto. Si no arranca, espera unos minutos más e inténtalo de nuevo.'**
  String get asistenciaGuiaCorrientePaso5;

  /// No description provided for @asistenciaGuiaCorrientePaso6.
  ///
  /// In es, this message translates to:
  /// **'Quita las pinzas en orden inverso, sin que se toquen entre sí, y deja tu auto encendido al menos 20 minutos.'**
  String get asistenciaGuiaCorrientePaso6;

  /// No description provided for @asistenciaGuiaCorrienteResumen.
  ///
  /// In es, this message translates to:
  /// **'Cómo arrancar tu auto con cables de otro vehículo.'**
  String get asistenciaGuiaCorrienteResumen;

  /// No description provided for @asistenciaGuiaCorrienteTitulo.
  ///
  /// In es, this message translates to:
  /// **'Pasar corriente'**
  String get asistenciaGuiaCorrienteTitulo;

  /// No description provided for @asistenciaGuiaLlantaPaso1.
  ///
  /// In es, this message translates to:
  /// **'Estaciona en terreno plano y firme, pon el freno de mano y enciende las luces intermitentes.'**
  String get asistenciaGuiaLlantaPaso1;

  /// No description provided for @asistenciaGuiaLlantaPaso2.
  ///
  /// In es, this message translates to:
  /// **'Saca la llanta de refacción, el gato y la llave de cruz. Afloja un poco las tuercas de la llanta ponchada sin quitarlas.'**
  String get asistenciaGuiaLlantaPaso2;

  /// No description provided for @asistenciaGuiaLlantaPaso3.
  ///
  /// In es, this message translates to:
  /// **'Coloca el gato en el punto indicado en el manual y levanta el auto hasta que la llanta quede en el aire.'**
  String get asistenciaGuiaLlantaPaso3;

  /// No description provided for @asistenciaGuiaLlantaPaso4.
  ///
  /// In es, this message translates to:
  /// **'Quita las tuercas y la llanta ponchada. Monta la de refacción y aprieta las tuercas con la mano.'**
  String get asistenciaGuiaLlantaPaso4;

  /// No description provided for @asistenciaGuiaLlantaPaso5.
  ///
  /// In es, this message translates to:
  /// **'Baja el auto, aprieta las tuercas en cruz con la llave y revisa la presión en cuanto puedas.'**
  String get asistenciaGuiaLlantaPaso5;

  /// No description provided for @asistenciaGuiaLlantaResumen.
  ///
  /// In es, this message translates to:
  /// **'Cámbiala por la de refacción en pocos pasos.'**
  String get asistenciaGuiaLlantaResumen;

  /// No description provided for @asistenciaGuiaLlantaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cambiar una llanta'**
  String get asistenciaGuiaLlantaTitulo;

  /// Encabezado de cada paso de una guía.
  ///
  /// In es, this message translates to:
  /// **'Paso {numero} de {total}'**
  String asistenciaGuiaPasoNumero(int numero, int total);

  /// Título grande de la lista de guías de emergencia.
  ///
  /// In es, this message translates to:
  /// **'Emergencias'**
  String get asistenciaListaTitulo;

  /// Título de la tarjeta principal de emergencias.
  ///
  /// In es, this message translates to:
  /// **'¿Necesitas ayuda ahora?'**
  String get asistenciaHeroeTitulo;

  /// Explica por qué el botón de pedir ayuda aún no está disponible.
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda con tu ubicación estará disponible pronto. Mientras tanto, estas guías te dicen qué hacer.'**
  String get asistenciaHeroeTexto;

  /// Botón de pedir ayuda, deshabilitado hasta que exista la solicitud de asistencia.
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda'**
  String get asistenciaHeroeAccion;

  /// Título del carrusel de guías.
  ///
  /// In es, this message translates to:
  /// **'Guías rápidas'**
  String get asistenciaEstanteGuias;

  /// Encabezado de la lista de guías.
  ///
  /// In es, this message translates to:
  /// **'Todas las guías'**
  String get asistenciaGrupoGuias;

  /// Cuántos pasos tiene una guía.
  ///
  /// In es, this message translates to:
  /// **'{pasos} pasos'**
  String asistenciaGuiaCantidadPasos(int pasos);

  /// Subtítulo de la cabecera de una guía.
  ///
  /// In es, this message translates to:
  /// **'{pasos} pasos · sin conexión'**
  String asistenciaGuiaSubtituloSinConexion(int pasos);

  /// Aviso de que las guías no necesitan red.
  ///
  /// In es, this message translates to:
  /// **'Estas guías están guardadas en la app y funcionan sin conexión.'**
  String get asistenciaGuiasAvisoSinConexion;

  /// Título de la pantalla de guías de emergencia.
  ///
  /// In es, this message translates to:
  /// **'Guías de emergencia'**
  String get asistenciaGuiasTitulo;

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

  /// No description provided for @citasComprobanteCargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu comprobante'**
  String get citasComprobanteCargando;

  /// Día y horario de la cita en el comprobante.
  ///
  /// In es, this message translates to:
  /// **'{fecha}, de {inicio} a {fin}'**
  String citasComprobanteCuando(DateTime fecha, String inicio, String fin);

  /// Número de la cita en el comprobante.
  ///
  /// In es, this message translates to:
  /// **'Folio {id}'**
  String citasComprobanteFolio(int id);

  /// No description provided for @citasComprobanteIndicacion.
  ///
  /// In es, this message translates to:
  /// **'Muestra este código en recepción para registrar tu llegada.'**
  String get citasComprobanteIndicacion;

  /// No description provided for @citasComprobanteQrDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Código QR de tu cita para recepción'**
  String get citasComprobanteQrDescripcion;

  /// No description provided for @citasComprobanteTitulo.
  ///
  /// In es, this message translates to:
  /// **'Comprobante de cita'**
  String get citasComprobanteTitulo;

  /// No description provided for @citasComprobanteVerPdf.
  ///
  /// In es, this message translates to:
  /// **'Ver comprobante en PDF'**
  String get citasComprobanteVerPdf;

  /// No description provided for @citasComprobanteVerPdfDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Comprobante en PDF de tu cita'**
  String get citasComprobanteVerPdfDescripcion;

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

  /// No description provided for @citasListoVerComprobante.
  ///
  /// In es, this message translates to:
  /// **'Ver comprobante'**
  String get citasListoVerComprobante;

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

  /// Fila del detalle del vehículo que abre el plan.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get mantenimientoAcceso;

  /// Abre agendar cita con el servicio.
  ///
  /// In es, this message translates to:
  /// **'Agendar este servicio'**
  String get mantenimientoAgendar;

  /// Anuncio mientras carga el plan.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu plan de mantenimiento'**
  String get mantenimientoCargando;

  /// Anuncio mientras carga un servicio.
  ///
  /// In es, this message translates to:
  /// **'Cargando el servicio'**
  String get mantenimientoCargandoServicio;

  /// Cerrar una pantalla de mantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get mantenimientoCerrar;

  /// Descripción de la portada del plan para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Ilustración de una llave de servicio'**
  String get mantenimientoDescripcionPortada;

  /// Encabezado de los conceptos del servicio.
  ///
  /// In es, this message translates to:
  /// **'Qué incluye'**
  String get mantenimientoEncabezadoConceptos;

  /// Encabezado del grupo de kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Tu kilometraje'**
  String get mantenimientoEncabezadoKm;

  /// Encabezado de la lista de servicios.
  ///
  /// In es, this message translates to:
  /// **'Plan de servicios'**
  String get mantenimientoEncabezadoPlan;

  /// Estado del servicio.
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get mantenimientoEstadoHecho;

  /// Estado del servicio.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get mantenimientoEstadoPendiente;

  /// Estado del servicio.
  ///
  /// In es, this message translates to:
  /// **'Próximo'**
  String get mantenimientoEstadoProximo;

  /// Estado del servicio.
  ///
  /// In es, this message translates to:
  /// **'Vencido'**
  String get mantenimientoEstadoVencido;

  /// Cuánto falta y la fecha estimada.
  ///
  /// In es, this message translates to:
  /// **'Faltan {km} km · hacia el {fecha}'**
  String mantenimientoFaltan(String km, String fecha);

  /// Cuándo se hizo el servicio.
  ///
  /// In es, this message translates to:
  /// **'Hecho el {fecha}'**
  String mantenimientoHechoEl(String fecha);

  /// Kilometraje.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String mantenimientoKilometros(String km);

  /// Ayuda con el último kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Tu último registro: {km} km'**
  String mantenimientoKmAyuda(String km);

  /// Ayuda sin lectura previa.
  ///
  /// In es, this message translates to:
  /// **'Escribe el número que marca el tablero de tu auto.'**
  String get mantenimientoKmAyudaSinRegistro;

  /// Etiqueta del campo.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje actual'**
  String get mantenimientoKmCampo;

  /// Fuente cliente del kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Registrado por ti el {fecha}'**
  String mantenimientoKmDelCliente(String fecha);

  /// Fuente taller del kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Registrado por el taller el {fecha}'**
  String mantenimientoKmDelTaller(String fecha);

  /// Validación.
  ///
  /// In es, this message translates to:
  /// **'Usa solo números enteros mayores que cero.'**
  String get mantenimientoKmErrorFormato;

  /// Validación contra la última lectura.
  ///
  /// In es, this message translates to:
  /// **'No puede ser menor a {km} km, el último que tenemos.'**
  String mantenimientoKmErrorMenor(String km);

  /// Fallo al guardar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu kilometraje. Revisa tu internet y vuelve a intentarlo.'**
  String get mantenimientoKmErrorRed;

  /// Respuesta 422 KM_INVALIDO.
  ///
  /// In es, this message translates to:
  /// **'Ese kilometraje es menor al último registrado. Revísalo en tu tablero.'**
  String get mantenimientoKmErrorServidor;

  /// Validación.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu kilometraje.'**
  String get mantenimientoKmErrorVacio;

  /// Aviso de éxito.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje guardado. Actualizamos tu próximo servicio.'**
  String get mantenimientoKmGuardado;

  /// Anuncio al guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardando kilometraje'**
  String get mantenimientoKmGuardando;

  /// Botón de guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar kilometraje'**
  String get mantenimientoKmGuardar;

  /// Nota sobre el km oficial.
  ///
  /// In es, this message translates to:
  /// **'El kilometraje que registra el taller es el oficial: tu registro no lo reemplaza.'**
  String get mantenimientoKmNota;

  /// Aún no hay kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Sin registrar'**
  String get mantenimientoKmSinDato;

  /// Sin fuente del kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay una lectura de tu auto'**
  String get mantenimientoKmSinFuente;

  /// Título del formulario de kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Registrar kilometraje'**
  String get mantenimientoKmTitulo;

  /// Motivo del próximo servicio: kilómetros.
  ///
  /// In es, this message translates to:
  /// **'Te toca por kilometraje'**
  String get mantenimientoMotivoKm;

  /// Motivo del próximo servicio: meses.
  ///
  /// In es, this message translates to:
  /// **'Te toca por tiempo transcurrido'**
  String get mantenimientoMotivoTiempo;

  /// Etiqueta del precio.
  ///
  /// In es, this message translates to:
  /// **'Precio estimado'**
  String get mantenimientoPrecioEtiqueta;

  /// Leyenda obligatoria junto a todo precio estimado.
  ///
  /// In es, this message translates to:
  /// **'Estimación no vinculante'**
  String get mantenimientoPrecioLeyenda;

  /// Promedio de kilómetros diarios.
  ///
  /// In es, this message translates to:
  /// **'Promedio: {km} km al día'**
  String mantenimientoPromedio(String km);

  /// Abre el registro de kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Registrar km'**
  String get mantenimientoRegistrarKm;

  /// Resumen de un servicio.
  ///
  /// In es, this message translates to:
  /// **'{km} km · {meses} meses'**
  String mantenimientoResumenServicio(String km, String meses);

  /// Servicio ausente del plan.
  ///
  /// In es, this message translates to:
  /// **'Puede que el plan haya cambiado. Vuelve al plan e inténtalo de nuevo.'**
  String get mantenimientoServicioNoEncontradoMensaje;

  /// Servicio ausente del plan.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este servicio'**
  String get mantenimientoServicioNoEncontradoTitulo;

  /// Servicio sin conceptos.
  ///
  /// In es, this message translates to:
  /// **'Este servicio no trae conceptos detallados.'**
  String get mantenimientoSinConceptos;

  /// Invita a registrar el kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Registra tu kilometraje para calcular cuándo te toca el siguiente servicio.'**
  String get mantenimientoSinProximoMensaje;

  /// Héroe cuando no se puede estimar el próximo servicio.
  ///
  /// In es, this message translates to:
  /// **'Sin próximo servicio estimado'**
  String get mantenimientoSinProximoTitulo;

  /// Título de la pantalla del plan de mantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get mantenimientoTitulo;

  /// Mensaje cuando el modelo no tiene plan.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenemos el plan de servicios de este modelo. Pregunta a tu asesor en la agencia.'**
  String get mantenimientoVacioMensaje;

  /// Título cuando el modelo no tiene plan.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay plan para tu auto'**
  String get mantenimientoVacioTitulo;

  /// El servicio ya llegó o pasó.
  ///
  /// In es, this message translates to:
  /// **'Ya te toca · pasó de los {km} km'**
  String mantenimientoYaToca(String km);

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

  /// Mensaje que lee el lector de pantalla mientras carga la ficha técnica.
  ///
  /// In es, this message translates to:
  /// **'Cargando la ficha técnica'**
  String get vehiculosFichaCargando;

  /// Etiqueta de una especificación del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Carrocería'**
  String get vehiculosFichaClaveCarroceria;

  /// Etiqueta de una especificación del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Motor'**
  String get vehiculosFichaClaveMotor;

  /// Etiqueta de una especificación del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Pasajeros'**
  String get vehiculosFichaClavePasajeros;

  /// Etiqueta de una especificación del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Potencia'**
  String get vehiculosFichaClavePotencia;

  /// Etiqueta de una especificación del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Propulsión'**
  String get vehiculosFichaClavePropulsion;

  /// Etiqueta de una especificación del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Tracción'**
  String get vehiculosFichaClaveTraccion;

  /// Etiqueta de una especificación del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Transmisión'**
  String get vehiculosFichaClaveTransmision;

  /// Aviso al pie de la ficha técnica.
  ///
  /// In es, this message translates to:
  /// **'Datos del modelo y año. La ficha exacta de tu unidad está en su manual.'**
  String get vehiculosFichaNota;

  /// Aviso cuando la ficha sale del respaldo local y no de la agencia.
  ///
  /// In es, this message translates to:
  /// **'Mostrando la ficha guardada en la app'**
  String get vehiculosFichaRespaldo;

  /// Título de una sección del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get vehiculosFichaSeccionGeneral;

  /// Título de una sección del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Motor'**
  String get vehiculosFichaSeccionMotor;

  /// Título de una sección del respaldo local de la ficha.
  ///
  /// In es, this message translates to:
  /// **'Transmisión'**
  String get vehiculosFichaSeccionTransmision;

  /// Título de la pantalla de ficha técnica.
  ///
  /// In es, this message translates to:
  /// **'Ficha técnica'**
  String get vehiculosFichaTitulo;

  /// Mensaje del estado vacío de la ficha técnica.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenemos las especificaciones de este modelo y año. La agencia las publicará pronto.'**
  String get vehiculosFichaVacioMensaje;

  /// Título del estado vacío de la ficha técnica.
  ///
  /// In es, this message translates to:
  /// **'Sin ficha técnica'**
  String get vehiculosFichaVacioTitulo;

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

  /// Mensaje que lee el lector de pantalla mientras carga el manual.
  ///
  /// In es, this message translates to:
  /// **'Cargando el manual'**
  String get vehiculosManualCargando;

  /// Botón para compartir el PDF del manual.
  ///
  /// In es, this message translates to:
  /// **'Compartir manual'**
  String get vehiculosManualCompartir;

  /// Botón para guardar el PDF del manual en el teléfono.
  ///
  /// In es, this message translates to:
  /// **'Descargar manual'**
  String get vehiculosManualDescargar;

  /// Nombre del documento para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Manual de {vehiculo}'**
  String vehiculosManualDescripcion(String vehiculo);

  /// Aviso cuando el manual se guardó.
  ///
  /// In es, this message translates to:
  /// **'Manual guardado'**
  String get vehiculosManualGuardado;

  /// Aviso cuando falla guardar el manual.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el manual. Inténtalo de nuevo.'**
  String get vehiculosManualGuardadoError;

  /// Título de la pantalla del manual.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get vehiculosManualTitulo;

  /// Mensaje del estado vacío del manual.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenemos el manual de este modelo y año. La agencia lo publicará pronto.'**
  String get vehiculosManualVacioMensaje;

  /// Título del estado vacío del manual.
  ///
  /// In es, this message translates to:
  /// **'Manual no disponible'**
  String get vehiculosManualVacioTitulo;

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

  /// Acceso rápido del ícono: agendar una cita.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get widgetsAccesoAgendar;

  /// Acceso rápido del ícono: abrir el garaje.
  ///
  /// In es, this message translates to:
  /// **'Mi auto'**
  String get widgetsAccesoMiAuto;

  /// Acceso rápido del ícono: pedir ayuda en carretera.
  ///
  /// In es, this message translates to:
  /// **'SOS'**
  String get widgetsAccesoSos;

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

  /// Enlace al final del titulo de un estante para abrir la lista completa.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get estanteVerTodo;

  /// Lo que anuncia el enlace Ver todo de un estante: incluye el titulo del estante.
  ///
  /// In es, this message translates to:
  /// **'Ver todo: {titulo}'**
  String estanteVerTodoDe(String titulo);

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

  /// Lector de pantalla mientras llega la página siguiente del historial.
  ///
  /// In es, this message translates to:
  /// **'Cargando más servicios'**
  String get historialCargandoMas;

  /// Fecha y hora de cierre de una orden en el historial.
  ///
  /// In es, this message translates to:
  /// **'Cerrada el {fecha}'**
  String historialCerradaEl(String fecha);

  /// Aviso cuando falla la página siguiente del historial.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más servicios.'**
  String get historialErrorMas;

  /// Estatus de una orden: el taller trabaja en el vehículo.
  ///
  /// In es, this message translates to:
  /// **'En proceso'**
  String get historialEstatusEnProceso;

  /// Estatus de una orden: el cliente ya recogió el vehículo.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get historialEstatusEntregado;

  /// Estatus de una orden que la app aún no conoce.
  ///
  /// In es, this message translates to:
  /// **'Sin estatus'**
  String get historialEstatusOtro;

  /// Estatus de una orden: el vehículo entró al taller.
  ///
  /// In es, this message translates to:
  /// **'Recibido'**
  String get historialEstatusRecibido;

  /// Estatus de una orden: el servicio está hecho.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get historialEstatusTerminado;

  /// Estatus y cierre de una orden en el historial; el estatus va con texto, no solo con color.
  ///
  /// In es, this message translates to:
  /// **'{estatus} · {cierre}'**
  String historialEstatusYCierre(String estatus, String cierre);

  /// Lector de pantalla del filtro de años del historial.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por año'**
  String get historialFiltroEtiqueta;

  /// Opción del filtro del historial que muestra todos los años.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get historialFiltroTodos;

  /// Botón para reintentar una carga del historial o del ticket.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get historialReintentar;

  /// Una orden que todavía no se cierra.
  ///
  /// In es, this message translates to:
  /// **'Orden abierta'**
  String get historialSinCierre;

  /// Cantidad por precio unitario de un renglón del ticket.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} × {precio}'**
  String historialTicketCantidadPorPrecio(int cantidad, String precio);

  /// Etiqueta de la fecha de cierre en el ticket.
  ///
  /// In es, this message translates to:
  /// **'Fecha de cierre'**
  String get historialTicketCierre;

  /// Botón para descargar y compartir el PDF del ticket.
  ///
  /// In es, this message translates to:
  /// **'Compartir PDF'**
  String get historialTicketCompartir;

  /// Aviso cuando falla la descarga del PDF del ticket.
  ///
  /// In es, this message translates to:
  /// **'No pudimos descargar el PDF. Intenta de nuevo.'**
  String get historialTicketCompartirError;

  /// Etiqueta de la fecha del servicio en el ticket.
  ///
  /// In es, this message translates to:
  /// **'Fecha del servicio'**
  String get historialTicketFecha;

  /// Renglón del IVA en los totales del ticket.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get historialTicketIva;

  /// Etiqueta del kilometraje en el ticket.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje'**
  String get historialTicketKilometraje;

  /// Kilometraje del vehículo en el ticket.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String historialTicketKilometrajeValor(String km);

  /// Encabezado y total de la mano de obra del ticket.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra'**
  String get historialTicketManoDeObra;

  /// Aviso si la suma de los renglones no da el total.
  ///
  /// In es, this message translates to:
  /// **'Los importes de este ticket no cuadran. Pide a la agencia que lo revise.'**
  String get historialTicketNoCuadra;

  /// Pie de los totales del ticket.
  ///
  /// In es, this message translates to:
  /// **'Los precios incluyen IVA.'**
  String get historialTicketPreciosConIva;

  /// Encabezado y total de las refacciones del ticket.
  ///
  /// In es, this message translates to:
  /// **'Refacciones'**
  String get historialTicketRefacciones;

  /// Grupo del ticket sin mano de obra o sin refacciones.
  ///
  /// In es, this message translates to:
  /// **'Sin renglones'**
  String get historialTicketSinRenglones;

  /// Renglón del subtotal en los totales del ticket.
  ///
  /// In es, this message translates to:
  /// **'Subtotal sin IVA'**
  String get historialTicketSubtotal;

  /// Título de la pantalla del ticket. Corto: con subtítulo, el encabezado grande reserva una sola línea.
  ///
  /// In es, this message translates to:
  /// **'Ticket'**
  String get historialTicketTitulo;

  /// Renglón del total del ticket.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get historialTicketTotal;

  /// Encabezado de los totales del ticket.
  ///
  /// In es, this message translates to:
  /// **'Totales'**
  String get historialTicketTotales;

  /// Título de la pantalla del historial de servicios. Corto: con subtítulo, el encabezado grande reserva una sola línea.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historialTitulo;

  /// Estado vacío del historial con un año elegido.
  ///
  /// In es, this message translates to:
  /// **'No hay servicios en {anio}.'**
  String historialVacioAnioMensaje(String anio);

  /// Mensaje del estado vacío del historial.
  ///
  /// In es, this message translates to:
  /// **'Cuando el taller cierre una orden de este auto, aparecerá aquí.'**
  String get historialVacioMensaje;

  /// Título del estado vacío del historial.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay servicios'**
  String get historialVacioTitulo;

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

  /// Título de la tarjeta con lo que faltaría pagar por el modelo nuevo.
  ///
  /// In es, this message translates to:
  /// **'Diferencia a pagar'**
  String get calculadoraDiferenciaTitulo;

  /// Explica cómo sale la diferencia a pagar.
  ///
  /// In es, this message translates to:
  /// **'Es el precio de lista, {precio}, menos el rango estimado de tu auto. También es una estimación no vinculante.'**
  String calculadoraDiferenciaExplicacion(String precio);

  /// Cuando incluso el valor más bajo del auto cubre el precio del modelo.
  ///
  /// In es, this message translates to:
  /// **'Con lo que podría valer tu auto alcanzaría para el precio de lista, {precio}. Es una estimación no vinculante.'**
  String calculadoraDiferenciaCubierta(String precio);

  /// Título de la lista de estimaciones de toma a cuenta guardadas.
  ///
  /// In es, this message translates to:
  /// **'Mis estimaciones'**
  String get misEstimacionesTitulo;

  /// Lo que anuncia el lector de pantalla mientras carga la lista.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus estimaciones'**
  String get misEstimacionesCargando;

  /// Título cuando el cliente no ha estimado nada.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes estimaciones'**
  String get misEstimacionesVacioTitulo;

  /// Explicación de la lista vacía.
  ///
  /// In es, this message translates to:
  /// **'Cuando calcules cuánto valdría tu auto a cuenta de uno nuevo, la verás aquí.'**
  String get misEstimacionesVacioMensaje;

  /// Botón de la lista vacía que abre la calculadora.
  ///
  /// In es, this message translates to:
  /// **'Calcular una estimación'**
  String get misEstimacionesVacioAccion;

  /// Subtítulo de cada estimación guardada: fecha y rango.
  ///
  /// In es, this message translates to:
  /// **'{fecha}, {rango}'**
  String misEstimacionesFila(DateTime fecha, String rango);

  /// Botón que pide la siguiente página de estimaciones.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get misEstimacionesVerMas;

  /// Aviso cuando falla la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más estimaciones. Intenta de nuevo.'**
  String get misEstimacionesErrorMas;

  /// Encabezado del widget de pantalla de inicio con la próxima cita.
  ///
  /// In es, this message translates to:
  /// **'Próxima cita'**
  String get widgetsProximaCitaTitulo;

  /// Día de la próxima cita en el widget de inicio.
  ///
  /// In es, this message translates to:
  /// **'{fecha}'**
  String widgetsProximaCitaFecha(DateTime fecha);

  /// Horario de la próxima cita en el widget de inicio.
  ///
  /// In es, this message translates to:
  /// **'{inicio} a {fin}'**
  String widgetsProximaCitaHorario(String inicio, String fin);

  /// Texto del widget de inicio cuando no hay una cita confirmada por venir.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas próximas'**
  String get widgetsSinCitaMensaje;

  /// Encabezado del widget de inicio cuando el auto está en el taller (V2-M25.02).
  ///
  /// In es, this message translates to:
  /// **'Tu auto en el taller'**
  String get widgetsTallerTitulo;

  /// Hora estimada de entrega en el widget de inicio con el auto en el taller.
  ///
  /// In es, this message translates to:
  /// **'Entrega estimada: {hora}'**
  String widgetsTallerEntrega(String hora);

  /// Botón del comprobante que guarda la cita como pase en Google Wallet o Apple Wallet.
  ///
  /// In es, this message translates to:
  /// **'Agregar a Wallet'**
  String get citasWalletAgregar;

  /// Error del botón de Wallet cuando algo falla sin causa conocida.
  ///
  /// In es, this message translates to:
  /// **'No pudimos preparar tu pase. Intenta de nuevo.'**
  String get citasWalletErrorGenerico;

  /// Error del botón de Wallet cuando no hay red.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu red e intenta de nuevo.'**
  String get citasWalletErrorSinConexion;

  /// Error del botón de Wallet cuando la cita está cancelada.
  ///
  /// In es, this message translates to:
  /// **'Tu cita está cancelada, así que ya no tiene pase.'**
  String get citasWalletErrorCancelada;

  /// Error del botón de Wallet cuando el servidor no tiene certificados.
  ///
  /// In es, this message translates to:
  /// **'El pase de Wallet no está disponible por ahora. Muestra el código QR en recepción.'**
  String get citasWalletErrorNoDisponible;

  /// Título de la sección de día al agendar.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get citasAgendarDia;

  /// Título de la sección de horario al agendar.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get citasAgendarHorario;

  /// Etiqueta sobre la tarjeta principal de la próxima cita.
  ///
  /// In es, this message translates to:
  /// **'Tu próxima cita'**
  String get citasMisCitasProximaEtiqueta;

  /// Píldora de la tarjeta principal que abre el comprobante con QR.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get citasHeroComprobante;

  /// Título de la hoja con las acciones de una cita próxima.
  ///
  /// In es, this message translates to:
  /// **'Opciones de tu cita'**
  String get citasAccionesCita;

  /// Acción para cerrar una pantalla del flujo de citas.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get citasCerrar;

  /// Encabezado de la lista de detalles del comprobante.
  ///
  /// In es, this message translates to:
  /// **'Detalles de la cita'**
  String get citasComprobanteDetalles;

  /// Título de la indicación para recepción en el comprobante.
  ///
  /// In es, this message translates to:
  /// **'En recepción'**
  String get citasComprobanteRecepcion;

  /// Botón de la portada del detalle que abre el flujo de agendar cita.
  ///
  /// In es, this message translates to:
  /// **'Agendar'**
  String get vehiculosAgendarServicio;

  /// Botón de la portada del detalle que abre el manual del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get vehiculosBotonManual;

  /// Botón de la portada del manual que guarda el PDF.
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get vehiculosBotonDescargar;

  /// Botón de la portada del manual que comparte el PDF.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get vehiculosBotonCompartir;

  /// Botón de la portada del garaje cuando hay un solo vehículo.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get vehiculosVerDetalle;

  /// Encabezado del grupo de datos del vehículo en el detalle.
  ///
  /// In es, this message translates to:
  /// **'Datos'**
  String get vehiculosEncabezadoDatos;

  /// Encabezado del grupo de accesos del detalle.
  ///
  /// In es, this message translates to:
  /// **'Tu auto'**
  String get vehiculosEncabezadoTuAuto;

  /// Encabezado del grupo de datos rápidos del garaje.
  ///
  /// In es, this message translates to:
  /// **'Datos rápidos'**
  String get vehiculosEncabezadoRapidos;

  /// Pista bajo el VIN que indica que se puede copiar.
  ///
  /// In es, this message translates to:
  /// **'Toca para copiar'**
  String get vehiculosToqueCopiarVin;

  /// Cierra una pantalla de direcciones.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get recoleccionCerrar;

  /// Título de la lista de direcciones guardadas.
  ///
  /// In es, this message translates to:
  /// **'Mis direcciones'**
  String get recoleccionDireccionesTitulo;

  /// Botón para guardar una dirección nueva.
  ///
  /// In es, this message translates to:
  /// **'Agregar dirección'**
  String get recoleccionDireccionesAgregar;

  /// Anuncio mientras cargan las direcciones.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus direcciones'**
  String get recoleccionDireccionesCargando;

  /// Título cuando no hay direcciones guardadas.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes direcciones'**
  String get recoleccionDireccionesVacioTitulo;

  /// Mensaje cuando no hay direcciones guardadas.
  ///
  /// In es, this message translates to:
  /// **'Guarda una para que recojamos tu auto sin escribirla cada vez.'**
  String get recoleccionDireccionesVacioMensaje;

  /// Encabezado del grupo de direcciones.
  ///
  /// In es, this message translates to:
  /// **'Guardadas'**
  String get recoleccionDireccionesEncabezado;

  /// Pie de la lista de direcciones.
  ///
  /// In es, this message translates to:
  /// **'Toca una para editarla o borrarla.'**
  String get recoleccionDireccionesPie;

  /// Pista de la fila de una dirección.
  ///
  /// In es, this message translates to:
  /// **'Editar {alias}'**
  String recoleccionDireccionEditar(String alias);

  /// Aviso tras borrar una dirección.
  ///
  /// In es, this message translates to:
  /// **'Dirección borrada'**
  String get recoleccionDireccionBorrada;

  /// Título del formulario de alta.
  ///
  /// In es, this message translates to:
  /// **'Nueva dirección'**
  String get recoleccionFormNuevaTitulo;

  /// Título del formulario de edición.
  ///
  /// In es, this message translates to:
  /// **'Editar dirección'**
  String get recoleccionFormEditarTitulo;

  /// Título de la sección del mapa.
  ///
  /// In es, this message translates to:
  /// **'Ubicación en el mapa'**
  String get recoleccionFormUbicacionTitulo;

  /// Ayuda bajo el mapa.
  ///
  /// In es, this message translates to:
  /// **'Toca el mapa para poner el pin donde recogeremos tu auto.'**
  String get recoleccionFormPinAyuda;

  /// Error cuando falta el pin.
  ///
  /// In es, this message translates to:
  /// **'Pon el pin en el mapa.'**
  String get recoleccionFormPinFalta;

  /// Descripción del mapa para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Mapa para elegir la ubicación. Pin en {latitud}, {longitud}.'**
  String recoleccionFormMapaDescripcion(String latitud, String longitud);

  /// Descripción del mapa sin pin.
  ///
  /// In es, this message translates to:
  /// **'Mapa para elegir la ubicación. Todavía no hay pin.'**
  String get recoleccionFormMapaSinPin;

  /// Botón que pone el pin donde está el teléfono.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación'**
  String get recoleccionFormUsarUbicacion;

  /// Etiqueta del campo de búsqueda.
  ///
  /// In es, this message translates to:
  /// **'Buscar dirección'**
  String get recoleccionFormBuscarEtiqueta;

  /// Sugerencia del campo de búsqueda.
  ///
  /// In es, this message translates to:
  /// **'Calle, número y colonia'**
  String get recoleccionFormBuscarSugerencia;

  /// Acción de buscar la dirección escrita.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get recoleccionFormBuscarAccion;

  /// Anuncio mientras se busca.
  ///
  /// In es, this message translates to:
  /// **'Buscando la dirección'**
  String get recoleccionFormBuscando;

  /// Etiqueta del campo alias.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get recoleccionFormAliasEtiqueta;

  /// Sugerencia del campo alias.
  ///
  /// In es, this message translates to:
  /// **'Casa, oficina…'**
  String get recoleccionFormAliasSugerencia;

  /// Etiqueta del campo calle.
  ///
  /// In es, this message translates to:
  /// **'Calle y número'**
  String get recoleccionFormCalleEtiqueta;

  /// Etiqueta del campo colonia.
  ///
  /// In es, this message translates to:
  /// **'Colonia'**
  String get recoleccionFormColoniaEtiqueta;

  /// Etiqueta del campo código postal.
  ///
  /// In es, this message translates to:
  /// **'Código postal'**
  String get recoleccionFormCpEtiqueta;

  /// Etiqueta del campo ciudad.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get recoleccionFormCiudadEtiqueta;

  /// Error del alias.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre de hasta 40 caracteres.'**
  String get recoleccionErrorAlias;

  /// Error de la calle.
  ///
  /// In es, this message translates to:
  /// **'Escribe la calle y el número, hasta 120 caracteres.'**
  String get recoleccionErrorCalle;

  /// Error de la colonia.
  ///
  /// In es, this message translates to:
  /// **'Escribe la colonia, hasta 80 caracteres.'**
  String get recoleccionErrorColonia;

  /// Error del código postal.
  ///
  /// In es, this message translates to:
  /// **'El código postal tiene 5 dígitos.'**
  String get recoleccionErrorCp;

  /// Error de la ciudad.
  ///
  /// In es, this message translates to:
  /// **'Escribe la ciudad, hasta 80 caracteres.'**
  String get recoleccionErrorCiudad;

  /// Botón que guarda la dirección.
  ///
  /// In es, this message translates to:
  /// **'Guardar dirección'**
  String get recoleccionGuardar;

  /// Botón que borra la dirección.
  ///
  /// In es, this message translates to:
  /// **'Borrar dirección'**
  String get recoleccionBorrar;

  /// Título de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar esta dirección?'**
  String get recoleccionBorrarTitulo;

  /// Mensaje de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'Se borrará «{alias}». No se puede deshacer.'**
  String recoleccionBorrarMensaje(String alias);

  /// Confirma el borrado.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get recoleccionBorrarConfirmar;

  /// Descarta el borrado.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get recoleccionBorrarCancelar;

  /// Aviso de dirección en uso (409).
  ///
  /// In es, this message translates to:
  /// **'Esta dirección ya tiene recolecciones y no se puede borrar.'**
  String get recoleccionErrorEnUso;

  /// Título del aviso de cobertura.
  ///
  /// In es, this message translates to:
  /// **'Fuera de cobertura'**
  String get recoleccionCoberturaTitulo;

  /// Aviso de dirección fuera de cobertura (422).
  ///
  /// In es, this message translates to:
  /// **'Todavía no recogemos autos en esa zona. Mueve el pin o elige otra dirección.'**
  String get recoleccionCoberturaMensaje;

  /// Error genérico al guardar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar la dirección. Intenta de nuevo.'**
  String get recoleccionErrorGuardar;

  /// Error genérico al borrar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos borrar la dirección. Intenta de nuevo.'**
  String get recoleccionErrorBorrar;

  /// Aviso sin conexión en el formulario.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu red e intenta de nuevo.'**
  String get recoleccionErrorSinConexion;

  /// Aviso de permiso de ubicación denegado.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos tu permiso para usar la ubicación. También puedes poner el pin a mano.'**
  String get recoleccionUbicacionDenegada;

  /// Aviso de ubicación apagada.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación del teléfono o pon el pin a mano.'**
  String get recoleccionUbicacionApagada;

  /// Aviso de tiempo agotado.
  ///
  /// In es, this message translates to:
  /// **'No pudimos ubicarte a tiempo. Intenta de nuevo o pon el pin a mano.'**
  String get recoleccionUbicacionTiempo;

  /// Aviso de búsqueda sin resultados.
  ///
  /// In es, this message translates to:
  /// **'No encontramos esa dirección. Prueba con otra o pon el pin a mano.'**
  String get recoleccionBusquedaSinResultados;

  /// Aviso de error al buscar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos buscar la dirección. Pon el pin a mano.'**
  String get recoleccionBusquedaError;

  /// Título de la sección de recolección al agendar.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo llega tu auto al taller?'**
  String get recoleccionSelectorTitulo;

  /// Opción sin recolección.
  ///
  /// In es, this message translates to:
  /// **'Lo llevo yo'**
  String get recoleccionSelectorLoLlevo;

  /// Opción con recolección.
  ///
  /// In es, this message translates to:
  /// **'Que recojan mi auto'**
  String get recoleccionSelectorQueRecojan;

  /// Encabezado de la lista de direcciones al agendar.
  ///
  /// In es, this message translates to:
  /// **'Dirección de recolección'**
  String get recoleccionSelectorDireccion;

  /// Lleva a la lista de direcciones.
  ///
  /// In es, this message translates to:
  /// **'Administrar mis direcciones'**
  String get recoleccionSelectorAdministrar;

  /// Mensaje sin direcciones al agendar.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes direcciones guardadas.'**
  String get recoleccionSelectorSinDirecciones;

  /// Pide elegir fecha antes de cotizar.
  ///
  /// In es, this message translates to:
  /// **'Elige día y horario para cotizar la recolección.'**
  String get recoleccionSelectorElegirDia;

  /// Pide elegir dirección.
  ///
  /// In es, this message translates to:
  /// **'Elige una dirección para ver el costo.'**
  String get recoleccionSelectorElegirDireccion;

  /// Anuncio mientras se cotiza.
  ///
  /// In es, this message translates to:
  /// **'Calculando el costo de la recolección'**
  String get recoleccionSelectorCotizando;

  /// Estado de la dirección elegida para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Elegida'**
  String get recoleccionSelectorElegida;

  /// Encabezado de la cotización.
  ///
  /// In es, this message translates to:
  /// **'Costo y horario'**
  String get recoleccionCotizacionEncabezado;

  /// Fila de la franja de recoger.
  ///
  /// In es, this message translates to:
  /// **'Recogemos tu auto'**
  String get recoleccionCotizacionRecogemos;

  /// Fila de la franja de entregar.
  ///
  /// In es, this message translates to:
  /// **'Te lo entregamos'**
  String get recoleccionCotizacionEntregamos;

  /// Fila del costo por traslado.
  ///
  /// In es, this message translates to:
  /// **'Cada traslado'**
  String get recoleccionCotizacionPorTraslado;

  /// Fila del costo total.
  ///
  /// In es, this message translates to:
  /// **'Total de la recolección'**
  String get recoleccionCotizacionTotal;

  /// Día y franja de un traslado.
  ///
  /// In es, this message translates to:
  /// **'{fecha}, de {inicio} a {fin}'**
  String recoleccionCotizacionVentana(
    DateTime fecha,
    String inicio,
    String fin,
  );

  /// Título del error de cotización.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cotizar la recolección'**
  String get recoleccionCotizacionErrorTitulo;

  /// Mensaje del error de cotización.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e intenta de nuevo. Mientras tanto puedes llevar tú el auto.'**
  String get recoleccionCotizacionErrorMensaje;

  /// Reintenta la cotización.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get recoleccionCotizacionReintentar;

  /// Aviso de cotización fuera de cobertura.
  ///
  /// In es, this message translates to:
  /// **'Esa dirección queda fuera de nuestra zona de cobertura. Elige otra o lleva tú el auto.'**
  String get recoleccionCotizacionFueraDeCobertura;

  /// Fila de la recolección en el resumen y el comprobante.
  ///
  /// In es, this message translates to:
  /// **'Recolección'**
  String get citasResumenRecoleccion;

  /// Alias y dirección de la recolección.
  ///
  /// In es, this message translates to:
  /// **'{alias} · {direccion}'**
  String citasResumenRecoleccionValor(String alias, String direccion);

  /// Franja en que recogemos el auto.
  ///
  /// In es, this message translates to:
  /// **'Recogemos tu auto'**
  String get citasResumenRecogemos;

  /// Franja en que entregamos el auto.
  ///
  /// In es, this message translates to:
  /// **'Te lo entregamos'**
  String get citasResumenEntregamos;

  /// Día y franja de un traslado en el resumen.
  ///
  /// In es, this message translates to:
  /// **'{fecha}, de {inicio} a {fin}'**
  String citasResumenRecoleccionVentana(
    DateTime fecha,
    String inicio,
    String fin,
  );

  /// Costo total de los dos traslados.
  ///
  /// In es, this message translates to:
  /// **'Costo de la recolección'**
  String get citasResumenRecoleccionCosto;

  /// Encabezado del grupo de recolección.
  ///
  /// In es, this message translates to:
  /// **'Recolección a domicilio'**
  String get citasResumenRecoleccionEncabezado;

  /// Error al confirmar una cita con recolección fuera de cobertura.
  ///
  /// In es, this message translates to:
  /// **'Esa dirección ya no está en nuestra zona de cobertura. Elige otra o lleva tú el auto.'**
  String get citasErrorCobertura;

  /// Error al confirmar una cita con una dirección que ya no existe.
  ///
  /// In es, this message translates to:
  /// **'No encontramos esa dirección. Elige otra e intenta de nuevo.'**
  String get citasErrorRecoleccion;

  /// Texto de la tarjeta principal cuando pedir ayuda ya está disponible.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué pasó y comparte tu ubicación para que la agencia te encuentre. Mientras llega la ayuda, estas guías te dicen qué hacer.'**
  String get asistenciaHeroeTextoDisponible;

  /// Título de la pantalla de pedir ayuda.
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda'**
  String get asistenciaPedirTitulo;

  /// Etiqueta de lector de pantalla mientras carga la pantalla de pedir ayuda.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get asistenciaPedirCargando;

  /// Encabezado de la lista de vehículos.
  ///
  /// In es, this message translates to:
  /// **'¿Qué vehículo necesita ayuda?'**
  String get asistenciaPedirVehiculoEncabezado;

  /// Etiqueta de lector de pantalla del vehículo elegido.
  ///
  /// In es, this message translates to:
  /// **'Seleccionado'**
  String get asistenciaPedirSeleccionado;

  /// Encabezado de los tipos de problema.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasó?'**
  String get asistenciaPedirTipoEncabezado;

  /// Tipo de problema: llanta.
  ///
  /// In es, this message translates to:
  /// **'Llanta'**
  String get asistenciaTipoLlanta;

  /// Tipo de problema: batería.
  ///
  /// In es, this message translates to:
  /// **'Batería'**
  String get asistenciaTipoBateria;

  /// Tipo de problema: choque.
  ///
  /// In es, this message translates to:
  /// **'Choque'**
  String get asistenciaTipoChoque;

  /// Tipo de problema: sin gasolina.
  ///
  /// In es, this message translates to:
  /// **'Sin gasolina'**
  String get asistenciaTipoSinGasolina;

  /// Tipo de problema: otro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get asistenciaTipoOtro;

  /// Encabezado de la sección de ubicación.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación'**
  String get asistenciaUbicacionEncabezado;

  /// Interruptor para compartir la ubicación.
  ///
  /// In es, this message translates to:
  /// **'Compartir mi ubicación'**
  String get asistenciaUbicacionCompartir;

  /// Explica cómo se usa la ubicación.
  ///
  /// In es, this message translates to:
  /// **'La agencia sabrá dónde estás. Se envía una sola vez, con la app abierta, y no se vuelve a usar cuando la ayuda termina.'**
  String get asistenciaUbicacionExplicacion;

  /// Mientras se lee la ubicación.
  ///
  /// In es, this message translates to:
  /// **'Buscando tu ubicación…'**
  String get asistenciaUbicacionObteniendo;

  /// Cuando ya se tiene la ubicación.
  ///
  /// In es, this message translates to:
  /// **'Ubicación lista para enviar'**
  String get asistenciaUbicacionLista;

  /// Permiso de ubicación negado.
  ///
  /// In es, this message translates to:
  /// **'No diste permiso de ubicación. Puedes intentarlo otra vez o enviar la solicitud sin ubicación y escribir dónde estás.'**
  String get asistenciaUbicacionPermisoDenegado;

  /// Permiso de ubicación negado para siempre.
  ///
  /// In es, this message translates to:
  /// **'El permiso de ubicación está bloqueado. Actívalo en Ajustes o envía la solicitud sin ubicación y escribe dónde estás.'**
  String get asistenciaUbicacionPermisoBloqueado;

  /// Servicio de ubicación apagado.
  ///
  /// In es, this message translates to:
  /// **'La ubicación del teléfono está apagada. Enciéndela o envía la solicitud sin ubicación y escribe dónde estás.'**
  String get asistenciaUbicacionServicioApagado;

  /// Se agotó el tiempo para leer la ubicación.
  ///
  /// In es, this message translates to:
  /// **'No pudimos encontrarte a tiempo. Intenta otra vez o envía la solicitud sin ubicación y escribe dónde estás.'**
  String get asistenciaUbicacionTiempoAgotado;

  /// Reintenta leer la ubicación.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get asistenciaUbicacionReintentar;

  /// Apaga la ubicación y deja enviar sin ella.
  ///
  /// In es, this message translates to:
  /// **'Enviar sin ubicación'**
  String get asistenciaUbicacionSinUbicacion;

  /// Etiqueta del comentario cuando se comparte la ubicación.
  ///
  /// In es, this message translates to:
  /// **'Comentario (opcional)'**
  String get asistenciaComentarioEtiqueta;

  /// Etiqueta del comentario cuando no se comparte la ubicación.
  ///
  /// In es, this message translates to:
  /// **'Dónde estás y qué pasó'**
  String get asistenciaComentarioEtiquetaSinUbicacion;

  /// Ayuda del campo de comentario.
  ///
  /// In es, this message translates to:
  /// **'Máximo 500 caracteres'**
  String get asistenciaComentarioAyuda;

  /// Texto del control de deslizar para confirmar.
  ///
  /// In es, this message translates to:
  /// **'Desliza para pedir ayuda'**
  String get asistenciaConfirmarTexto;

  /// Mientras se envía la solicitud.
  ///
  /// In es, this message translates to:
  /// **'Enviando tu solicitud…'**
  String get asistenciaEnviando;

  /// Error de red al pedir ayuda.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: no pudimos enviar tu solicitud. Si es urgente, llama al 911 o a tu aseguradora.'**
  String get asistenciaErrorSinConexion;

  /// Error genérico al pedir ayuda.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviar tu solicitud. Intenta de nuevo.'**
  String get asistenciaErrorEnviar;

  /// El vehículo no existe o no es del cliente.
  ///
  /// In es, this message translates to:
  /// **'No encontramos ese vehículo. Elige otro e intenta de nuevo.'**
  String get asistenciaErrorVehiculo;

  /// Título cuando el garaje está vacío.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes vehículos'**
  String get asistenciaGarajeVacioTitulo;

  /// Mensaje cuando el garaje está vacío.
  ///
  /// In es, this message translates to:
  /// **'Para pedir ayuda necesitamos saber qué vehículo es. Pide a la agencia que registre el tuyo.'**
  String get asistenciaGarajeVacioMensaje;

  /// Folio de la solicitud.
  ///
  /// In es, this message translates to:
  /// **'Folio {id}'**
  String asistenciaSolicitudFolio(int id);

  /// Estado de la solicitud recién creada.
  ///
  /// In es, this message translates to:
  /// **'Solicitud recibida'**
  String get asistenciaSolicitudRecibida;

  /// Mensaje tras enviar la solicitud.
  ///
  /// In es, this message translates to:
  /// **'La agencia ya sabe que necesitas ayuda. Mantén el teléfono contigo y ponte en un lugar seguro.'**
  String get asistenciaSolicitudTexto;

  /// Aviso cuando ya hay una solicitud abierta.
  ///
  /// In es, this message translates to:
  /// **'Ya tenías una solicitud abierta. Te la mostramos aquí.'**
  String get asistenciaSolicitudYaAbierta;

  /// Fila de vehículo en el detalle de la solicitud.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get asistenciaSolicitudVehiculo;

  /// Fila de problema en el detalle de la solicitud.
  ///
  /// In es, this message translates to:
  /// **'Problema'**
  String get asistenciaSolicitudProblema;

  /// Fila de ubicación en el detalle de la solicitud.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get asistenciaSolicitudUbicacion;

  /// La ubicación se envió.
  ///
  /// In es, this message translates to:
  /// **'Compartida con la agencia'**
  String get asistenciaSolicitudUbicacionCompartida;

  /// La ubicación no se envió.
  ///
  /// In es, this message translates to:
  /// **'No compartida'**
  String get asistenciaSolicitudUbicacionNoCompartida;

  /// Fila de comentario en el detalle de la solicitud.
  ///
  /// In es, this message translates to:
  /// **'Comentario'**
  String get asistenciaSolicitudComentario;

  /// Recordatorio de privacidad.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación solo se comparte mientras la solicitud esté abierta.'**
  String get asistenciaSolicitudPrivacidad;

  /// Lleva a las guías.
  ///
  /// In es, this message translates to:
  /// **'Ver guías de emergencia'**
  String get asistenciaSolicitudVerGuias;

  /// Título del aviso cuando se detecta root o jailbreak. No bloquea la app.
  ///
  /// In es, this message translates to:
  /// **'Este equipo parece modificado'**
  String get seguridadEquipoComprometidoTitulo;

  /// Explica que la app sigue funcionando pero no deja copias locales de los datos del cliente.
  ///
  /// In es, this message translates to:
  /// **'Puedes seguir usando CareCar, pero por tu seguridad no guardamos tus datos en este equipo. Sin internet no verás información guardada.'**
  String get seguridadEquipoComprometidoMensaje;

  /// Título de la pantalla del asistente y acceso desde el detalle del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Pregúntale a tu auto'**
  String get asistenteTitulo;

  /// Aviso fijo de que las respuestas las genera una IA (ADR 0007).
  ///
  /// In es, this message translates to:
  /// **'Respuestas generadas con IA a partir del manual de tu auto. Ante una falla, consulta a tu asesor.'**
  String get asistenteAvisoIa;

  /// Título cuando aún no hay preguntas.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres saber de tu auto?'**
  String get asistenteVacioTitulo;

  /// Explica cómo responde el asistente.
  ///
  /// In es, this message translates to:
  /// **'Respondo con el manual de tu auto y te digo en qué página lo dice.'**
  String get asistenteVacioMensaje;

  /// Texto de ayuda del campo para preguntar.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu pregunta'**
  String get asistenteSugerencia;

  /// Nombre del botón para enviar la pregunta.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get asistenteEnviar;

  /// Quién habla, para el lector de pantalla, en las preguntas del cliente.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get asistenteTu;

  /// Quién habla, para el lector de pantalla, en las respuestas.
  ///
  /// In es, this message translates to:
  /// **'CareCar'**
  String get asistenteNombre;

  /// Mientras espera la respuesta.
  ///
  /// In es, this message translates to:
  /// **'Buscando en tu manual…'**
  String get asistentePensando;

  /// Debajo de una pregunta que falló.
  ///
  /// In es, this message translates to:
  /// **'No se envió'**
  String get asistenteNoSeEnvio;

  /// Botón para volver a mandar una pregunta que falló.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get asistenteReintentar;

  /// Respuesta cuando no hay conexión.
  ///
  /// In es, this message translates to:
  /// **'No me pude conectar. Revisa tu internet y vuelve a intentar.'**
  String get asistenteSinConexion;

  /// Respuesta cuando el servicio de IA no responde o se acabó la cuota del día.
  ///
  /// In es, this message translates to:
  /// **'El asistente no está disponible por ahora. Intenta más tarde o pregúntale a tu asesor.'**
  String get asistenteNoDisponible;

  /// Respuesta cuando el modelo y año no tienen manual con texto.
  ///
  /// In es, this message translates to:
  /// **'Tu auto aún no tiene un manual que pueda leer. Pregúntale a tu asesor en la agencia.'**
  String get asistenteSinManual;

  /// Respuesta cuando se pasa del límite diario.
  ///
  /// In es, this message translates to:
  /// **'Ya hiciste tus preguntas de hoy. Mañana puedes hacer más.'**
  String get asistenteLimite;

  /// Cita de una página del manual al pie de una respuesta.
  ///
  /// In es, this message translates to:
  /// **'Manual, pág. {pagina}'**
  String asistenteFuente(int pagina);

  /// Lo que oye el lector de pantalla en una cita del manual.
  ///
  /// In es, this message translates to:
  /// **'Manual, página {pagina}, abrir'**
  String asistenteFuenteLector(int pagina);

  /// Encabezado de la línea de tiempo de la solicitud.
  ///
  /// In es, this message translates to:
  /// **'Estado de tu solicitud'**
  String get asistenciaSeguimientoEncabezado;

  /// Primer paso de la solicitud de ayuda.
  ///
  /// In es, this message translates to:
  /// **'Recibida'**
  String get asistenciaEstadoRecibida;

  /// La ayuda va hacia el cliente.
  ///
  /// In es, this message translates to:
  /// **'En camino'**
  String get asistenciaEstadoEnCamino;

  /// La ayuda ya llegó y se atendió.
  ///
  /// In es, this message translates to:
  /// **'Atendida'**
  String get asistenciaEstadoAtendida;

  /// La solicitud se canceló.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get asistenciaEstadoCancelada;

  /// Nota del paso Recibida.
  ///
  /// In es, this message translates to:
  /// **'La agencia ya tiene tu solicitud.'**
  String get asistenciaEstadoNotaRecibida;

  /// Nota del paso En camino.
  ///
  /// In es, this message translates to:
  /// **'Hay ayuda en camino hacia ti.'**
  String get asistenciaEstadoNotaEnCamino;

  /// Nota del paso Atendida.
  ///
  /// In es, this message translates to:
  /// **'Tu solicitud ya fue atendida.'**
  String get asistenciaEstadoNotaAtendida;

  /// Nota del paso Cancelada.
  ///
  /// In es, this message translates to:
  /// **'La solicitud se cerró.'**
  String get asistenciaEstadoNotaCancelada;

  /// Estado actual que anuncia el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Estado: {estado}'**
  String asistenciaEstadoActual(String estado);

  /// Botón para consultar de nuevo el estado.
  ///
  /// In es, this message translates to:
  /// **'Actualizar estado'**
  String get asistenciaSeguimientoActualizar;

  /// Botón mientras consulta el estado.
  ///
  /// In es, this message translates to:
  /// **'Actualizando…'**
  String get asistenciaSeguimientoActualizando;

  /// Aviso cuando falla la consulta del estado.
  ///
  /// In es, this message translates to:
  /// **'No pudimos actualizar el estado. Revisa tu conexión e inténtalo de nuevo.'**
  String get asistenciaSeguimientoFallo;

  /// Aviso al quedar atendida o cancelada.
  ///
  /// In es, this message translates to:
  /// **'La solicitud ya está cerrada: tu ubicación dejó de compartirse.'**
  String get asistenciaSeguimientoUbicacionCerrada;

  /// Título de la pantalla de seguimiento.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento del traslado'**
  String get recoleccionSeguimientoTitulo;

  /// Título del traslado de recoger.
  ///
  /// In es, this message translates to:
  /// **'Recogemos tu auto'**
  String get recoleccionSeguimientoRecoger;

  /// Título del traslado de entregar.
  ///
  /// In es, this message translates to:
  /// **'Entregamos tu auto'**
  String get recoleccionSeguimientoEntregar;

  /// Día y franja del traslado.
  ///
  /// In es, this message translates to:
  /// **'{fecha}, de {inicio} a {fin}'**
  String recoleccionSeguimientoVentana(
    DateTime fecha,
    String inicio,
    String fin,
  );

  /// Pie del grupo de recolección: invita a abrir el seguimiento.
  ///
  /// In es, this message translates to:
  /// **'Toca un traslado para seguirlo en vivo.'**
  String get recoleccionSeguimientoAbrir;

  /// Encabezado de la línea de tiempo del traslado.
  ///
  /// In es, this message translates to:
  /// **'Avance'**
  String get recoleccionSeguimientoLineaEncabezado;

  /// Traslado agendado.
  ///
  /// In es, this message translates to:
  /// **'Programado'**
  String get recoleccionEstadoProgramado;

  /// El chofer va al domicilio.
  ///
  /// In es, this message translates to:
  /// **'Chofer en camino'**
  String get recoleccionEstadoEnCamino;

  /// El chofer ya tiene el auto.
  ///
  /// In es, this message translates to:
  /// **'Auto recogido'**
  String get recoleccionEstadoRecogido;

  /// El auto está en el taller.
  ///
  /// In es, this message translates to:
  /// **'En el taller'**
  String get recoleccionEstadoEnTaller;

  /// El chofer lleva el auto de vuelta.
  ///
  /// In es, this message translates to:
  /// **'De regreso a tu domicilio'**
  String get recoleccionEstadoDeRegreso;

  /// El auto ya se entregó.
  ///
  /// In es, this message translates to:
  /// **'Auto entregado'**
  String get recoleccionEstadoEntregado;

  /// El traslado se canceló.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get recoleccionEstadoCancelado;

  /// Nota del paso en camino.
  ///
  /// In es, this message translates to:
  /// **'Sigue su ubicación en el mapa.'**
  String get recoleccionEstadoNotaEnCamino;

  /// Nota del paso de regreso.
  ///
  /// In es, this message translates to:
  /// **'Sigue su ubicación en el mapa.'**
  String get recoleccionEstadoNotaDeRegreso;

  /// Encabezado del mapa del chofer.
  ///
  /// In es, this message translates to:
  /// **'Dónde va el chofer'**
  String get recoleccionSeguimientoMapaEncabezado;

  /// Descripción del mapa para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Mapa con la ubicación del chofer: latitud {latitud}, longitud {longitud}.'**
  String recoleccionSeguimientoMapaDescripcion(String latitud, String longitud);

  /// Hora de la última ubicación del chofer.
  ///
  /// In es, this message translates to:
  /// **'Ubicación actualizada a las {hora}'**
  String recoleccionSeguimientoActualizadaEn(String hora);

  /// Botón que abre el checklist del traslado.
  ///
  /// In es, this message translates to:
  /// **'Ver checklist del auto'**
  String get recoleccionSeguimientoVerChecklist;

  /// Botón para volver a consultar el traslado.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get recoleccionSeguimientoActualizar;

  /// Etiqueta del esqueleto de carga.
  ///
  /// In es, this message translates to:
  /// **'Cargando el seguimiento del traslado'**
  String get recoleccionSeguimientoCargando;

  /// Título cuando el traslado no existe.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este traslado'**
  String get recoleccionSeguimientoNoEncontradoTitulo;

  /// Mensaje cuando el traslado no existe.
  ///
  /// In es, this message translates to:
  /// **'Puede que ya no exista. Vuelve a tus citas y ábrelo de nuevo.'**
  String get recoleccionSeguimientoNoEncontradoMensaje;

  /// Aviso cuando falla recargar con datos ya visibles.
  ///
  /// In es, this message translates to:
  /// **'No pudimos actualizar. Mostramos lo último que sabemos.'**
  String get recoleccionSeguimientoFalloAlActualizar;

  /// Título de la pantalla del checklist.
  ///
  /// In es, this message translates to:
  /// **'Checklist del auto'**
  String get recoleccionChecklistTitulo;

  /// Etiqueta del kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje'**
  String get recoleccionChecklistKm;

  /// Kilometraje con unidad.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String recoleccionChecklistKmValor(int km);

  /// Etiqueta del nivel de gasolina.
  ///
  /// In es, this message translates to:
  /// **'Gasolina'**
  String get recoleccionChecklistGasolina;

  /// Nivel de gasolina.
  ///
  /// In es, this message translates to:
  /// **'Vacío'**
  String get recoleccionGasolinaVacio;

  /// Nivel de gasolina.
  ///
  /// In es, this message translates to:
  /// **'Un cuarto'**
  String get recoleccionGasolinaUnCuarto;

  /// Nivel de gasolina.
  ///
  /// In es, this message translates to:
  /// **'Medio tanque'**
  String get recoleccionGasolinaMedio;

  /// Nivel de gasolina.
  ///
  /// In es, this message translates to:
  /// **'Tres cuartos'**
  String get recoleccionGasolinaTresCuartos;

  /// Nivel de gasolina.
  ///
  /// In es, this message translates to:
  /// **'Lleno'**
  String get recoleccionGasolinaLleno;

  /// Nivel de gasolina para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Gasolina: {nivel}'**
  String recoleccionChecklistGasolinaLector(String nivel);

  /// Etiqueta de las notas.
  ///
  /// In es, this message translates to:
  /// **'Notas del chofer'**
  String get recoleccionChecklistNotas;

  /// Encabezado de la galería.
  ///
  /// In es, this message translates to:
  /// **'Fotos del auto'**
  String get recoleccionChecklistFotos;

  /// Descripción de cada foto para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Foto {numero} de {total} del estado del auto'**
  String recoleccionChecklistFotoDescripcion(int numero, int total);

  /// Galería vacía.
  ///
  /// In es, this message translates to:
  /// **'Este checklist no trae fotos.'**
  String get recoleccionChecklistSinFotos;

  /// Quien firma el checklist.
  ///
  /// In es, this message translates to:
  /// **'Firma de conformidad'**
  String get recoleccionChecklistFirmante;

  /// Fecha del checklist.
  ///
  /// In es, this message translates to:
  /// **'Registrado el {fecha}'**
  String recoleccionChecklistRegistrado(DateTime fecha);

  /// Título cuando no hay checklist.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay checklist'**
  String get recoleccionChecklistVacioTitulo;

  /// Mensaje cuando no hay checklist.
  ///
  /// In es, this message translates to:
  /// **'El chofer lo registra al recoger y al entregar tu auto. Cuando lo haga, lo verás aquí.'**
  String get recoleccionChecklistVacioMensaje;

  /// Etiqueta del esqueleto de carga.
  ///
  /// In es, this message translates to:
  /// **'Cargando el checklist del auto'**
  String get recoleccionChecklistCargando;

  /// Título de la bitácora del conductor.
  ///
  /// In es, this message translates to:
  /// **'Bitácora'**
  String get bitacoraTitulo;

  /// Subtítulo de la portada cuando no se conoce el nombre del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Tu auto'**
  String get bitacoraSubtituloSinNombre;

  /// Descripción para el lector de pantalla del arte de la portada de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Ícono de una bomba de gasolina'**
  String get bitacoraDescripcionPortada;

  /// Botón que abre el alta de una carga de gasolina.
  ///
  /// In es, this message translates to:
  /// **'Nueva carga'**
  String get bitacoraNuevaCarga;

  /// Botón que abre el alta de un gasto que no es gasolina.
  ///
  /// In es, this message translates to:
  /// **'Otro gasto'**
  String get bitacoraOtroGasto;

  /// Cierra la pantalla de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get bitacoraCerrar;

  /// Lo que anuncia el lector de pantalla mientras carga la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu bitácora'**
  String get bitacoraCargando;

  /// Título de la bitácora sin gastos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay gastos'**
  String get bitacoraVacioTitulo;

  /// Mensaje de la bitácora sin gastos.
  ///
  /// In es, this message translates to:
  /// **'Registra tu primera carga de gasolina para saber cuánto rinde y cuánto te cuesta tu auto.'**
  String get bitacoraVacioMensaje;

  /// Encabezado del estante con las cifras de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Tu rendimiento'**
  String get bitacoraResumenTitulo;

  /// Etiqueta de la cifra de kilómetros por litro.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento'**
  String get bitacoraEtiquetaRendimiento;

  /// Rendimiento en kilómetros por litro.
  ///
  /// In es, this message translates to:
  /// **'{valor} km/l'**
  String bitacoraCifraKmPorLitro(String valor);

  /// Etiqueta de la cifra de pesos por kilómetro.
  ///
  /// In es, this message translates to:
  /// **'Costo por km'**
  String get bitacoraEtiquetaCostoPorKm;

  /// Costo en pesos por kilómetro.
  ///
  /// In es, this message translates to:
  /// **'{valor}/km'**
  String bitacoraCifraCostoPorKm(String valor);

  /// Etiqueta de la cifra del gasto del mes en curso.
  ///
  /// In es, this message translates to:
  /// **'Gasto de este mes'**
  String get bitacoraEtiquetaGastoMes;

  /// Cifra cuando todavía no se puede calcular.
  ///
  /// In es, this message translates to:
  /// **'—'**
  String get bitacoraCifraSinDatos;

  /// Detalle de una cifra que aún no se puede calcular.
  ///
  /// In es, this message translates to:
  /// **'Necesitas 2 cargas'**
  String get bitacoraDetalleSinDatos;

  /// Fila que abre las estadísticas.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento y gasto por mes'**
  String get bitacoraVerEstadisticas;

  /// Fila que abre la exportación.
  ///
  /// In es, this message translates to:
  /// **'Exportar bitácora'**
  String get bitacoraExportar;

  /// Tipo de gasto.
  ///
  /// In es, this message translates to:
  /// **'Gasolina'**
  String get bitacoraTipoGasolina;

  /// Tipo de gasto.
  ///
  /// In es, this message translates to:
  /// **'Estacionamiento'**
  String get bitacoraTipoEstacionamiento;

  /// Tipo de gasto.
  ///
  /// In es, this message translates to:
  /// **'Casetas'**
  String get bitacoraTipoCasetas;

  /// Tipo de gasto.
  ///
  /// In es, this message translates to:
  /// **'Lavado'**
  String get bitacoraTipoLavado;

  /// Tipo de gasto.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get bitacoraTipoOtro;

  /// Subtítulo de una carga de gasolina en la lista.
  ///
  /// In es, this message translates to:
  /// **'{fecha} · {litros} l · {km} km'**
  String bitacoraDetalleCarga(String fecha, String litros, String km);

  /// Título del formulario de alta de una carga.
  ///
  /// In es, this message translates to:
  /// **'Nueva carga'**
  String get bitacoraFormCargaTitulo;

  /// Título del formulario de edición de una carga.
  ///
  /// In es, this message translates to:
  /// **'Editar carga'**
  String get bitacoraFormEditarCargaTitulo;

  /// Título del formulario de alta de otro gasto.
  ///
  /// In es, this message translates to:
  /// **'Nuevo gasto'**
  String get bitacoraFormGastoTitulo;

  /// Título del formulario de edición de otro gasto.
  ///
  /// In es, this message translates to:
  /// **'Editar gasto'**
  String get bitacoraFormEditarGastoTitulo;

  /// Etiqueta del selector de tipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo de gasto'**
  String get bitacoraCampoTipo;

  /// Etiqueta del campo de litros.
  ///
  /// In es, this message translates to:
  /// **'Litros'**
  String get bitacoraCampoLitros;

  /// Etiqueta del campo de monto en pesos.
  ///
  /// In es, this message translates to:
  /// **'Monto total'**
  String get bitacoraCampoMonto;

  /// Etiqueta del campo de km.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje del tablero'**
  String get bitacoraCampoKm;

  /// Ayuda bajo el campo de km con la última lectura.
  ///
  /// In es, this message translates to:
  /// **'Tu última lectura es de {km} km.'**
  String bitacoraAyudaKm(String km);

  /// Etiqueta del selector de fecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get bitacoraCampoFecha;

  /// Acción que abre el calendario del formulario.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha'**
  String get bitacoraElegirFecha;

  /// Etiqueta del campo de descripción.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get bitacoraCampoDescripcion;

  /// Ayuda del campo de descripción.
  ///
  /// In es, this message translates to:
  /// **'Obligatoria en «Otro», máximo 200 caracteres.'**
  String get bitacoraAyudaDescripcion;

  /// Error del campo de monto.
  ///
  /// In es, this message translates to:
  /// **'Escribe un monto mayor a 0.'**
  String get bitacoraErrorMonto;

  /// Error del campo de litros.
  ///
  /// In es, this message translates to:
  /// **'Escribe los litros, mayores a 0.'**
  String get bitacoraErrorLitros;

  /// Error del campo de km cuando falta o no es entero.
  ///
  /// In es, this message translates to:
  /// **'Escribe el kilometraje como número entero.'**
  String get bitacoraErrorKm;

  /// Error del campo de km cuando es menor a la última lectura.
  ///
  /// In es, this message translates to:
  /// **'No puede ser menor a tu última lectura ({km} km).'**
  String bitacoraErrorKmMenor(String km);

  /// Error del campo de km cuando el servidor contesta 422.
  ///
  /// In es, this message translates to:
  /// **'El servidor lo rechazó: es menor a tu última lectura. Revisa el kilometraje.'**
  String get bitacoraErrorKmServidor;

  /// Error del campo de fecha.
  ///
  /// In es, this message translates to:
  /// **'Elige una fecha que no sea futura.'**
  String get bitacoraErrorFecha;

  /// Error del campo de descripción.
  ///
  /// In es, this message translates to:
  /// **'Describe el gasto, en máximo 200 caracteres.'**
  String get bitacoraErrorDescripcion;

  /// Aviso de un fallo al guardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Intenta de nuevo.'**
  String get bitacoraErrorGuardar;

  /// Aviso de un fallo al borrar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo borrar. Intenta de nuevo.'**
  String get bitacoraErrorBorrar;

  /// Aviso de falta de conexión al guardar o borrar.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e intenta de nuevo.'**
  String get bitacoraErrorSinConexion;

  /// Guarda el gasto.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get bitacoraGuardar;

  /// Borra el gasto que se edita.
  ///
  /// In es, this message translates to:
  /// **'Borrar gasto'**
  String get bitacoraBorrar;

  /// Título de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar este gasto?'**
  String get bitacoraBorrarTitulo;

  /// Mensaje de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'Se borrará «{descripcion}». No se puede deshacer.'**
  String bitacoraBorrarMensaje(String descripcion);

  /// Confirma el borrado.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get bitacoraBorrarConfirmar;

  /// Cancela el borrado.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get bitacoraBorrarCancelar;

  /// Aviso tras guardar.
  ///
  /// In es, this message translates to:
  /// **'Gasto guardado.'**
  String get bitacoraGastoGuardado;

  /// Aviso tras borrar.
  ///
  /// In es, this message translates to:
  /// **'Gasto borrado.'**
  String get bitacoraGastoBorrado;

  /// Encabezado de la sección que lee el ticket.
  ///
  /// In es, this message translates to:
  /// **'Llenar desde el ticket'**
  String get bitacoraTicketTitulo;

  /// Aclaración de privacidad de la lectura del ticket.
  ///
  /// In es, this message translates to:
  /// **'La foto se lee en tu teléfono; no se guarda ni se sube.'**
  String get bitacoraTicketPrivacidad;

  /// Abre la cámara para fotografiar el ticket.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get bitacoraTicketTomar;

  /// Abre la galería para elegir la foto del ticket.
  ///
  /// In es, this message translates to:
  /// **'Elegir de fotos'**
  String get bitacoraTicketElegir;

  /// Se anuncia mientras se reconoce el texto.
  ///
  /// In es, this message translates to:
  /// **'Leyendo el ticket…'**
  String get bitacoraTicketLeyendo;

  /// Aviso tras leer el ticket.
  ///
  /// In es, this message translates to:
  /// **'Esto fue lo que leímos. Revísalo y corrige lo que haga falta.'**
  String get bitacoraTicketLeido;

  /// Aviso cuando no se leyó nada.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer el ticket. Llena los datos a mano.'**
  String get bitacoraTicketNoLeyo;

  /// Aviso cuando se negó el permiso.
  ///
  /// In es, this message translates to:
  /// **'No tenemos permiso para usar la cámara o tus fotos. Actívalo en los ajustes o llena los datos a mano.'**
  String get bitacoraTicketSinPermiso;

  /// Aviso de un fallo al leer la foto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la foto. Llena los datos a mano.'**
  String get bitacoraTicketError;

  /// Título de la pantalla de estadísticas.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento y gasto'**
  String get bitacoraEstadisticasTitulo;

  /// Título de la gráfica de gasto mensual.
  ///
  /// In es, this message translates to:
  /// **'Gasto por mes'**
  String get bitacoraGraficaTitulo;

  /// Mensaje de la gráfica sin datos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay gastos que graficar.'**
  String get bitacoraGraficaVacia;

  /// Título cuando no se puede calcular el rendimiento.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay rendimiento'**
  String get bitacoraSinRendimientoTitulo;

  /// Explica por qué aún no hay rendimiento, según cuántas cargas hay.
  ///
  /// In es, this message translates to:
  /// **'Para calcular los km/l y el costo por km necesitamos al menos 2 cargas con su kilometraje. {cargas, plural, =0{Todavía no registras ninguna.} =1{Tienes 1 carga.} other{Tienes {cargas} cargas, pero sus kilometrajes no avanzan.}}'**
  String bitacoraSinRendimientoMensaje(int cargas);

  /// Base del cálculo del rendimiento.
  ///
  /// In es, this message translates to:
  /// **'Calculado con {km} km recorridos en {tramos, plural, =1{1 tramo} other{{tramos} tramos}} entre cargas.'**
  String bitacoraBaseDelCalculo(String km, int tramos);

  /// Título de la pantalla de exportación.
  ///
  /// In es, this message translates to:
  /// **'Exportar bitácora'**
  String get bitacoraExportarTitulo;

  /// Explicación de la pantalla de exportación.
  ///
  /// In es, this message translates to:
  /// **'Elige los meses y comparte tu bitácora con la hoja del sistema.'**
  String get bitacoraExportarIntro;

  /// Selector del primer mes a exportar.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get bitacoraExportarDesde;

  /// Selector del último mes a exportar.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get bitacoraExportarHasta;

  /// Exporta la bitácora como CSV.
  ///
  /// In es, this message translates to:
  /// **'Compartir CSV'**
  String get bitacoraExportarCsv;

  /// Exporta la bitácora como PDF.
  ///
  /// In es, this message translates to:
  /// **'Compartir PDF'**
  String get bitacoraExportarPdf;

  /// Aviso cuando el rango no tiene gastos.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos en esos meses.'**
  String get bitacoraExportarVacio;

  /// Aviso de un rango al revés.
  ///
  /// In es, this message translates to:
  /// **'El mes inicial no puede ser posterior al final.'**
  String get bitacoraExportarRangoInvalido;

  /// Aviso de un fallo al exportar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo compartir el archivo. Intenta de nuevo.'**
  String get bitacoraExportarError;

  /// Título del PDF exportado.
  ///
  /// In es, this message translates to:
  /// **'Bitácora de {vehiculo}'**
  String bitacoraPdfTitulo(String vehiculo);

  /// Periodo que cubre el PDF.
  ///
  /// In es, this message translates to:
  /// **'{desde} a {hasta}'**
  String bitacoraPdfPeriodo(String desde, String hasta);

  /// Total gastado en el PDF.
  ///
  /// In es, this message translates to:
  /// **'Total: {monto}'**
  String bitacoraPdfTotal(String monto);

  /// Encabezado de columna del PDF.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get bitacoraColumnaFecha;

  /// Encabezado de columna del PDF.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get bitacoraColumnaTipo;

  /// Encabezado de columna del PDF.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get bitacoraColumnaMonto;

  /// Encabezado de columna del PDF.
  ///
  /// In es, this message translates to:
  /// **'Litros'**
  String get bitacoraColumnaLitros;

  /// Encabezado de columna del PDF.
  ///
  /// In es, this message translates to:
  /// **'Km'**
  String get bitacoraColumnaKm;

  /// Encabezado de columna del PDF.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get bitacoraColumnaDetalle;

  /// Fila del detalle del vehículo que abre la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Bitácora'**
  String get bitacoraAccesoFila;

  /// Encabezado de las preguntas sugeridas con la conversación vacía (V2-M24.08).
  ///
  /// In es, this message translates to:
  /// **'Prueba con una de estas'**
  String get asistenteSugerenciasTitulo;

  /// Pregunta sugerida sobre el mantenimiento. Al tocarla se envía tal cual.
  ///
  /// In es, this message translates to:
  /// **'¿Cada cuánto le toca servicio?'**
  String get asistentePreguntaMantenimiento;

  /// Pregunta sugerida sobre la presión de las llantas.
  ///
  /// In es, this message translates to:
  /// **'¿Qué presión llevan las llantas?'**
  String get asistentePreguntaLlantas;

  /// Pregunta sugerida sobre los testigos del tablero.
  ///
  /// In es, this message translates to:
  /// **'¿Qué significa una luz roja en el tablero?'**
  String get asistentePreguntaTestigos;

  /// Pregunta sugerida sobre la capacidad de aceite.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto aceite le cabe al motor?'**
  String get asistentePreguntaAceite;

  /// Pregunta sugerida sobre el combustible recomendado.
  ///
  /// In es, this message translates to:
  /// **'¿Qué gasolina le pongo?'**
  String get asistentePreguntaGasolina;

  /// Botón bajo cada respuesta del asistente: abre Agendar cita con el vehículo y el motivo Revisión ya elegidos (V2-M24.06).
  ///
  /// In es, this message translates to:
  /// **'Agendar revisión'**
  String get asistenteAgendarRevision;

  /// Botón 👍 bajo una respuesta del asistente; lo oye el lector de pantalla (V2-M24.07).
  ///
  /// In es, this message translates to:
  /// **'Me sirvió'**
  String get asistenteMeSirvio;

  /// Botón 👎 bajo una respuesta del asistente (V2-M24.07).
  ///
  /// In es, this message translates to:
  /// **'No me sirvió'**
  String get asistenteNoMeSirvio;

  /// Tarjeta de Inicio cuando hay una orden abierta (V2-M04.01).
  ///
  /// In es, this message translates to:
  /// **'Tu {vehiculo} está en el taller'**
  String tallerTarjetaTitulo(String vehiculo);

  /// Etapa actual y entrega estimada en la tarjeta de Inicio.
  ///
  /// In es, this message translates to:
  /// **'{etapa} · entrega {hora}'**
  String tallerTarjetaEtapaYEntrega(String etapa, String hora);

  /// Insignia de la tarjeta de Inicio con los trabajos adicionales pendientes.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{1 trabajo por aprobar} other{{cantidad} trabajos por aprobar}}'**
  String tallerTarjetaPendientes(int cantidad);

  /// Lector de pantalla de la barra de avance de la orden.
  ///
  /// In es, this message translates to:
  /// **'Avance de {avance} %'**
  String tallerTarjetaAvance(int avance);

  /// Pista del lector de pantalla al tocar la tarjeta de la orden en Inicio.
  ///
  /// In es, this message translates to:
  /// **'Ver el avance de tu orden'**
  String get tallerTarjetaAbrir;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'Recibido'**
  String get tallerEtapaRecibido;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico'**
  String get tallerEtapaDiagnostico;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'Esperando aprobación'**
  String get tallerEtapaEsperandoAprobacion;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'En reparación'**
  String get tallerEtapaEnReparacion;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'Control de calidad'**
  String get tallerEtapaControlDeCalidad;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'Lavado'**
  String get tallerEtapaLavado;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'Listo para entrega'**
  String get tallerEtapaListoParaEntrega;

  /// Etapa de la orden.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get tallerEtapaEntregado;

  /// Título de la pantalla de la orden en el taller (V2-M04.02). Corto: con subtítulo, el encabezado grande reserva una sola línea.
  ///
  /// In es, this message translates to:
  /// **'Tu orden'**
  String get tallerOrdenTitulo;

  /// Subtítulo de la fila con la etapa actual de la orden.
  ///
  /// In es, this message translates to:
  /// **'Etapa actual'**
  String get tallerOrdenEtapaActual;

  /// Subtítulo de la fila con la hora estimada de entrega.
  ///
  /// In es, this message translates to:
  /// **'Entrega estimada'**
  String get tallerOrdenEntregaEstimada;

  /// La orden todavía no tiene hora estimada de entrega.
  ///
  /// In es, this message translates to:
  /// **'Aún sin estimar'**
  String get tallerOrdenSinEntrega;

  /// Subtítulo de la fila con el nombre del asesor.
  ///
  /// In es, this message translates to:
  /// **'Tu asesor'**
  String get tallerOrdenAsesor;

  /// Encabezado de la línea de tiempo de la orden.
  ///
  /// In es, this message translates to:
  /// **'Línea de tiempo'**
  String get tallerOrdenLineaDeTiempo;

  /// Nota bajo la etapa actual con la hora estimada de entrega.
  ///
  /// In es, this message translates to:
  /// **'Entrega estimada {hora}'**
  String tallerOrdenNotaEntrega(String hora);

  /// Nota del taller y hora estimada de entrega bajo la etapa actual.
  ///
  /// In es, this message translates to:
  /// **'{nota} · entrega estimada {hora}'**
  String tallerOrdenNotaYEntrega(String nota, String hora);

  /// Fila que abre la inspección de la orden.
  ///
  /// In es, this message translates to:
  /// **'Inspección multipunto'**
  String get tallerOrdenInspeccion;

  /// Resumen de la inspección en la pantalla de la orden.
  ///
  /// In es, this message translates to:
  /// **'{puntos, plural, =0{Aún sin puntos revisados} =1{1 punto revisado} other{{puntos} puntos revisados}}'**
  String tallerOrdenInspeccionResumen(int puntos);

  /// Fila que abre los trabajos adicionales de la orden.
  ///
  /// In es, this message translates to:
  /// **'Trabajos adicionales'**
  String get tallerOrdenAdicionales;

  /// Resumen de los trabajos adicionales pendientes.
  ///
  /// In es, this message translates to:
  /// **'{pendientes, plural, =0{Nada por aprobar} =1{1 por aprobar} other{{pendientes} por aprobar}}'**
  String tallerOrdenAdicionalesResumen(int pendientes);

  /// Título del aviso cuando hay trabajos adicionales por aprobar.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{El taller te propone 1 trabajo adicional} other{El taller te propone {cantidad} trabajos adicionales}}'**
  String tallerOrdenAvisoPendientes(int cantidad);

  /// Mensaje del aviso de trabajos adicionales por aprobar.
  ///
  /// In es, this message translates to:
  /// **'Revísalos y apruébalos o recházalos con tu firma.'**
  String get tallerOrdenAvisoMensaje;

  /// Botón que abre los trabajos adicionales desde el aviso.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get tallerOrdenRevisar;

  /// Botón de reintento en las pantallas del taller.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get tallerReintentar;

  /// Título de la pantalla de inspección multipunto (V2-M04.04). Corto: con subtítulo, el encabezado grande reserva una sola línea.
  ///
  /// In es, this message translates to:
  /// **'Inspección'**
  String get tallerInspeccionTitulo;

  /// Título del estado vacío de la inspección.
  ///
  /// In es, this message translates to:
  /// **'Aún sin inspección'**
  String get tallerInspeccionVacia;

  /// Mensaje del estado vacío de la inspección.
  ///
  /// In es, this message translates to:
  /// **'El técnico todavía no registra los puntos revisados.'**
  String get tallerInspeccionVaciaMensaje;

  /// Descripción de una foto de la inspección para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Foto de {punto}'**
  String tallerInspeccionFotoDe(String punto);

  /// Encabezado de las fotos y videos que no son de un punto.
  ///
  /// In es, this message translates to:
  /// **'De la orden'**
  String get tallerInspeccionDeLaOrden;

  /// Descripción de una foto general de la orden para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Foto de la orden'**
  String get tallerInspeccionFotoDeLaOrden;

  /// Fila que abre un video del técnico en el reproductor del teléfono.
  ///
  /// In es, this message translates to:
  /// **'Ver video {numero}'**
  String tallerInspeccionVerVideo(int numero);

  /// Subtítulo de la fila de un video.
  ///
  /// In es, this message translates to:
  /// **'Se abre en el reproductor del teléfono'**
  String get tallerInspeccionVideoAbre;

  /// Aviso cuando el teléfono no puede abrir un video de la inspección.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el video. Jala hacia abajo para recargar e intenta de nuevo.'**
  String get tallerInspeccionVideoError;

  /// Título de la pantalla de trabajos adicionales (V2-M04.05). Corto: con subtítulo, el encabezado grande reserva una sola línea.
  ///
  /// In es, this message translates to:
  /// **'Adicionales'**
  String get tallerAdicionalesTitulo;

  /// Título del estado vacío de los trabajos adicionales.
  ///
  /// In es, this message translates to:
  /// **'Sin trabajos adicionales'**
  String get tallerAdicionalesVacio;

  /// Mensaje del estado vacío de los trabajos adicionales.
  ///
  /// In es, this message translates to:
  /// **'Si el taller encuentra algo más, aquí te lo propone para que decidas.'**
  String get tallerAdicionalesVacioMensaje;

  /// Renglón de un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra'**
  String get tallerAdicionalManoDeObra;

  /// Renglón de un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Refacciones'**
  String get tallerAdicionalRefacciones;

  /// Total de un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get tallerAdicionalTotal;

  /// Estado de un trabajo adicional sin respuesta.
  ///
  /// In es, this message translates to:
  /// **'Por aprobar'**
  String get tallerAdicionalPendiente;

  /// Estado de un trabajo adicional aprobado.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get tallerAdicionalAprobado;

  /// Estado de un trabajo adicional rechazado.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get tallerAdicionalRechazado;

  /// Cuándo respondió el cliente un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Respondido el {fecha}'**
  String tallerAdicionalRespondidoEl(String fecha);

  /// Botón para aprobar un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get tallerAdicionalAprobar;

  /// Botón para rechazar un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get tallerAdicionalRechazar;

  /// Encabezado de los totales en los trabajos adicionales.
  ///
  /// In es, this message translates to:
  /// **'Totales'**
  String get tallerTotales;

  /// Total de la orden sin adicionales.
  ///
  /// In es, this message translates to:
  /// **'Total de la orden'**
  String get tallerTotalOrden;

  /// Suma de los trabajos adicionales aprobados.
  ///
  /// In es, this message translates to:
  /// **'Adicionales aprobados'**
  String get tallerTotalAprobados;

  /// Suma de los trabajos adicionales sin respuesta.
  ///
  /// In es, this message translates to:
  /// **'Adicionales por aprobar'**
  String get tallerTotalPendientes;

  /// Total de la orden más los adicionales aprobados.
  ///
  /// In es, this message translates to:
  /// **'Total estimado'**
  String get tallerTotalEstimado;

  /// Título de la hoja de firma al aprobar.
  ///
  /// In es, this message translates to:
  /// **'Firma para aprobar'**
  String get tallerFirmaAprobarTitulo;

  /// Título de la hoja de firma al rechazar.
  ///
  /// In es, this message translates to:
  /// **'Firma para rechazar'**
  String get tallerFirmaRechazarTitulo;

  /// Instrucción de la hoja de firma.
  ///
  /// In es, this message translates to:
  /// **'{concepto} por {total}. Firma con el dedo dentro del recuadro: tu firma queda guardada con tu respuesta.'**
  String tallerFirmaInstruccion(String concepto, String total);

  /// Lector de pantalla del recuadro de firma.
  ///
  /// In es, this message translates to:
  /// **'Área para firmar con el dedo'**
  String get tallerFirmaArea;

  /// Botón que borra la firma dibujada.
  ///
  /// In es, this message translates to:
  /// **'Borrar firma'**
  String get tallerFirmaBorrar;

  /// Botón que confirma la aprobación.
  ///
  /// In es, this message translates to:
  /// **'Aprobar con mi firma'**
  String get tallerFirmaConfirmarAprobar;

  /// Botón que confirma el rechazo.
  ///
  /// In es, this message translates to:
  /// **'Rechazar con mi firma'**
  String get tallerFirmaConfirmarRechazar;

  /// Aviso después de aprobar un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Aprobaste «{concepto}». El total estimado ya lo incluye.'**
  String tallerRespuestaAprobada(String concepto);

  /// Aviso después de rechazar un trabajo adicional.
  ///
  /// In es, this message translates to:
  /// **'Rechazaste «{concepto}».'**
  String tallerRespuestaRechazada(String concepto);

  /// Aviso cuando el trabajo adicional ya tenía respuesta (409).
  ///
  /// In es, this message translates to:
  /// **'Ese trabajo ya tenía respuesta. Recarga para ver su estado.'**
  String get tallerRespuestaYaRespondida;

  /// Aviso cuando la orden ya no acepta respuestas (409).
  ///
  /// In es, this message translates to:
  /// **'La orden ya está terminada. Habla con tu asesor.'**
  String get tallerRespuestaOrdenCerrada;

  /// Aviso cuando no hay red al responder.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Tu respuesta no se envió.'**
  String get tallerRespuestaSinConexion;

  /// Aviso cuando falla la respuesta por otro motivo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar tu respuesta. Intenta de nuevo.'**
  String get tallerRespuestaError;

  /// Botón de cámara junto al campo del asistente (V2-M24.05).
  ///
  /// In es, this message translates to:
  /// **'Foto de una luz del tablero'**
  String get asistenteFotoAdjuntar;

  /// Opción de la hoja para usar la cámara.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get asistenteFotoTomar;

  /// Opción de la hoja para elegir una foto guardada.
  ///
  /// In es, this message translates to:
  /// **'Elegir de tus fotos'**
  String get asistenteFotoGaleria;

  /// Burbuja propia cuando se manda la foto de un testigo.
  ///
  /// In es, this message translates to:
  /// **'Foto del tablero'**
  String get asistenteFotoEnviada;

  /// Mientras el asistente identifica el testigo.
  ///
  /// In es, this message translates to:
  /// **'Revisando tu foto…'**
  String get asistenteRevisandoFoto;

  /// Insignia de un testigo rojo.
  ///
  /// In es, this message translates to:
  /// **'Detente'**
  String get asistenteTestigoRoja;

  /// Insignia de un testigo amarillo.
  ///
  /// In es, this message translates to:
  /// **'Revisar pronto'**
  String get asistenteTestigoAmarilla;

  /// Insignia de un testigo informativo.
  ///
  /// In es, this message translates to:
  /// **'Informativa'**
  String get asistenteTestigoInformativa;

  /// Aviso fijo de un testigo rojo.
  ///
  /// In es, this message translates to:
  /// **'Detente en un lugar seguro lo antes posible y apaga el motor.'**
  String get asistenteTestigoDetente;

  /// Botón de un testigo rojo que abre Pedir ayuda (SOS).
  ///
  /// In es, this message translates to:
  /// **'Pedir ayuda'**
  String get asistentePedirAyuda;

  /// Cuando la foto no muestra un testigo claro.
  ///
  /// In es, this message translates to:
  /// **'No reconocí una luz en la foto. Descríbela con palabras: color, forma y si parpadea.'**
  String get asistenteTestigoNoReconocido;

  /// Aviso cuando se negó el permiso de cámara o fotos.
  ///
  /// In es, this message translates to:
  /// **'Para tomar la foto, permite el acceso a la cámara y a tus fotos en los ajustes del teléfono.'**
  String get asistentePermisoCamara;

  /// Botón del aviso de permiso.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get asistenteAbrirAjustes;

  /// Encabezado del grupo de traslados de una cita en Mis citas.
  ///
  /// In es, this message translates to:
  /// **'Recolección · {cita}'**
  String citasMisCitasRecoleccionEncabezado(String cita);

  /// Fila que abre el checklist del chofer al recoger el auto.
  ///
  /// In es, this message translates to:
  /// **'Checklist al recoger'**
  String get citasChecklistRecoger;

  /// Fila que abre el checklist del chofer al entregar el auto.
  ///
  /// In es, this message translates to:
  /// **'Checklist al entregar'**
  String get citasChecklistEntregar;

  /// Subtítulo de las filas de checklist.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje, gasolina y fotos'**
  String get citasChecklistSubtitulo;

  /// Fila que abre el checklist con la comparación activa.
  ///
  /// In es, this message translates to:
  /// **'Comparar recoger y entregar'**
  String get citasChecklistComparar;

  /// Subtítulo de la fila de comparación.
  ///
  /// In es, this message translates to:
  /// **'Lo que cambió entre una y otra'**
  String get citasChecklistCompararSubtitulo;

  /// Pestaña del checklist al recoger el auto.
  ///
  /// In es, this message translates to:
  /// **'Al recoger'**
  String get recoleccionChecklistPestanaRecoger;

  /// Pestaña del checklist al entregar el auto.
  ///
  /// In es, this message translates to:
  /// **'Al entregar'**
  String get recoleccionChecklistPestanaEntregar;

  /// Pestaña que pone lado a lado los dos checklists.
  ///
  /// In es, this message translates to:
  /// **'Comparar'**
  String get recoleccionChecklistPestanaComparar;

  /// Kilometraje de los dos checklists.
  ///
  /// In es, this message translates to:
  /// **'{recoger} km al recoger, {entregar} km al entregar'**
  String recoleccionComparacionKmDetalle(int recoger, int entregar);

  /// Nivel de gasolina de los dos checklists.
  ///
  /// In es, this message translates to:
  /// **'{recoger} al recoger, {entregar} al entregar'**
  String recoleccionComparacionGasolinaDetalle(String recoger, String entregar);

  /// Encabezado de la comparación de fotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos al recoger y al entregar'**
  String get recoleccionComparacionFotosTitulo;

  /// Cómo se usa la comparación de fotos.
  ///
  /// In es, this message translates to:
  /// **'Arrastra la barra: a la izquierda ves la foto al recoger y a la derecha la foto al entregar.'**
  String get recoleccionComparacionFotosAyuda;

  /// Descripción de la foto de recoger para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Foto {numero} de {total} al recoger'**
  String recoleccionComparacionFotoRecoger(int numero, int total);

  /// Descripción de la foto de entregar para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Foto {numero} de {total} al entregar'**
  String recoleccionComparacionFotoEntregar(int numero, int total);

  /// Aviso cuando los checklists traen distinto número de fotos.
  ///
  /// In es, this message translates to:
  /// **'Hay {recoger} fotos al recoger y {entregar} al entregar; se comparan las primeras {comparadas}.'**
  String recoleccionComparacionFotosDesiguales(
    int recoger,
    int entregar,
    int comparadas,
  );

  /// Aviso cuando no hay fotos que comparar.
  ///
  /// In es, this message translates to:
  /// **'Alguno de los dos checklists no trae fotos para comparar.'**
  String get recoleccionComparacionSinFotos;

  /// Título cuando falta un checklist.
  ///
  /// In es, this message translates to:
  /// **'Aún no se puede comparar'**
  String get recoleccionComparacionFaltaTitulo;

  /// Falta el checklist de recoger.
  ///
  /// In es, this message translates to:
  /// **'El chofer todavía no registra el checklist de recoger.'**
  String get recoleccionComparacionFaltaRecoger;

  /// Falta el checklist de entregar.
  ///
  /// In es, this message translates to:
  /// **'El chofer todavía no registra el checklist de entregar. Cuando devuelva tu auto podrás compararlo.'**
  String get recoleccionComparacionFaltaEntregar;

  /// Faltan los dos checklists.
  ///
  /// In es, this message translates to:
  /// **'El chofer todavía no registra ningún checklist de esta recolección.'**
  String get recoleccionComparacionFaltaAmbos;
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
