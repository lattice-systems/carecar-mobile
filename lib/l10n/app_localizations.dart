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

  /// Etiqueta del campo donde se escribe la contraseña temporal que dio la agencia.
  ///
  /// In es, this message translates to:
  /// **'Contraseña temporal'**
  String get accesoCambiarActualEtiqueta;

  /// Única salida de la pantalla de cambio obligatorio.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get accesoCambiarCerrarSesion;

  /// Etiqueta del campo de confirmación.
  ///
  /// In es, this message translates to:
  /// **'Confirma la contraseña nueva'**
  String get accesoCambiarConfirmarEtiqueta;

  /// Error del campo del código cuando no están los seis dígitos.
  ///
  /// In es, this message translates to:
  /// **'El código tiene 6 dígitos'**
  String get accesoCambiarCorreoCodigoCorto;

  /// Etiqueta del campo donde se escribe el código que llegó al correo nuevo.
  ///
  /// In es, this message translates to:
  /// **'Código de 6 dígitos'**
  String get accesoCambiarCorreoCodigoEtiqueta;

  /// Los tres casos llegan iguales del servidor a propósito: responder distinto permitiría averiguar qué códigos existen.
  ///
  /// In es, this message translates to:
  /// **'Ese código no es válido, ya se usó o venció'**
  String get accesoCambiarCorreoCodigoInvalido;

  /// Botón de confirmar mientras el servidor responde.
  ///
  /// In es, this message translates to:
  /// **'Confirmando…'**
  String get accesoCambiarCorreoConfirmando;

  /// Botón que manda el código y aplica el cambio de correo.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get accesoCambiarCorreoConfirmar;

  /// Etiqueta de la contraseña actual, que se pide para cambiar el correo.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get accesoCambiarCorreoContrasenaEtiqueta;

  /// Error del campo de la contraseña cuando está vacío.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu contraseña'**
  String get accesoCambiarCorreoContrasenaFalta;

  /// El servidor dice que la contraseña actual no es la correcta. Llega en el mismo 400 que un correo mal escrito y solo los separa el código, así que la pantalla tiene que culpar al campo correcto.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña no coincide'**
  String get accesoCambiarCorreoContrasenaNoCoincide;

  /// Explica por qué se pide la contraseña para cambiar el correo.
  ///
  /// In es, this message translates to:
  /// **'Con tu correo se entra a la app, así que confirmamos que eres tú.'**
  String get accesoCambiarCorreoContrasenaPista;

  /// El correo nuevo ya es de otro cliente.
  ///
  /// In es, this message translates to:
  /// **'Ese correo ya está en uso'**
  String get accesoCambiarCorreoCorreoEnUso;

  /// Etiqueta del campo del correo nuevo.
  ///
  /// In es, this message translates to:
  /// **'Correo nuevo'**
  String get accesoCambiarCorreoCorreoEtiqueta;

  /// Error del campo del correo cuando no tiene formato. Se detecta en la app, sin viajar al servidor.
  ///
  /// In es, this message translates to:
  /// **'Escribe un correo válido'**
  String get accesoCambiarCorreoCorreoInvalido;

  /// Botón de enviar el código mientras el servidor responde.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get accesoCambiarCorreoEnviando;

  /// Botón que pide el cambio y manda el código al correo nuevo.
  ///
  /// In es, this message translates to:
  /// **'Enviar el código'**
  String get accesoCambiarCorreoEnviar;

  /// Explica el primer paso del cambio de correo.
  ///
  /// In es, this message translates to:
  /// **'Te mandaremos un código al correo nuevo para confirmar que es tuyo. Tu correo no cambia hasta que lo escribas.'**
  String get accesoCambiarCorreoExplicacion;

  /// Título del aviso cuando falla pedir el cambio por una razón que no es la contraseña ni el correo en uso.
  ///
  /// In es, this message translates to:
  /// **'No pudimos pedir el cambio'**
  String get accesoCambiarCorreoFalloTitulo;

  /// Mensaje al terminar el cambio. Dice lo que de verdad cambió: con qué correo se entra.
  ///
  /// In es, this message translates to:
  /// **'A partir de ahora entras con {correo}.'**
  String accesoCambiarCorreoListoMensaje(String correo);

  /// Título al terminar el cambio de correo.
  ///
  /// In es, this message translates to:
  /// **'Tu correo quedó actualizado'**
  String get accesoCambiarCorreoListoTitulo;

  /// Explica el segundo paso y recuerda a qué correo fue el código.
  ///
  /// In es, this message translates to:
  /// **'Te mandamos un código a {correo}. Vence en 15 minutos.'**
  String accesoCambiarCorreoPasoDosExplicacion(String correo);

  /// Vuelve al primer paso para pedir un código nuevo.
  ///
  /// In es, this message translates to:
  /// **'Pedir otro código'**
  String get accesoCambiarCorreoPedirOtro;

  /// Título de la pantalla que cambia el correo del cliente.
  ///
  /// In es, this message translates to:
  /// **'Cambiar mi correo'**
  String get accesoCambiarCorreoTitulo;

  /// Aviso cuando pasaron los 15 minutos antes de escribir el código. Se detecta en la app, sin gastar un viaje condenado.
  ///
  /// In es, this message translates to:
  /// **'El código venció. Pide otro.'**
  String get accesoCambiarCorreoVencio;

  /// Explica por qué no se puede seguir sin cambiarla.
  ///
  /// In es, this message translates to:
  /// **'La agencia te dio una contraseña temporal. Elige una nueva para continuar.'**
  String get accesoCambiarExplicacion;

  /// Título del aviso cuando el servidor rechaza el cambio.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cambiar tu contraseña'**
  String get accesoCambiarFalloTitulo;

  /// Texto del botón mientras el servidor responde.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get accesoCambiarGuardando;

  /// Botón principal de la pantalla de cambio.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get accesoCambiarGuardar;

  /// Error cuando la confirmación no coincide con la contraseña nueva.
  ///
  /// In es, this message translates to:
  /// **'Las dos contraseñas no son iguales.'**
  String get accesoCambiarNoCoincide;

  /// Etiqueta del campo de la contraseña nueva.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get accesoCambiarNuevaEtiqueta;

  /// Regla en vivo: la nueva no puede ser la temporal.
  ///
  /// In es, this message translates to:
  /// **'Distinta de la temporal'**
  String get accesoCambiarReglaDistinta;

  /// Regla en vivo del largo de la contraseña.
  ///
  /// In es, this message translates to:
  /// **'De 8 a 72 caracteres'**
  String get accesoCambiarReglaLargo;

  /// Regla en vivo: debe tener una letra.
  ///
  /// In es, this message translates to:
  /// **'Al menos una letra'**
  String get accesoCambiarReglaLetra;

  /// Regla en vivo: debe tener un número.
  ///
  /// In es, this message translates to:
  /// **'Al menos un número'**
  String get accesoCambiarReglaNumero;

  /// Encabezado de la lista de reglas en vivo.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña nueva debe tener:'**
  String get accesoCambiarReglasTitulo;

  /// Título de la pantalla de cambio obligatorio.
  ///
  /// In es, this message translates to:
  /// **'Cambia tu contraseña'**
  String get accesoCambiarTitulo;

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

  /// Ejemplo dentro del campo de correo del acceso.
  ///
  /// In es, this message translates to:
  /// **'tu@correo.com'**
  String get accesoCorreoSugerencia;

  /// Ejemplo dentro del campo de contraseña del acceso.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get accesoContrasenaSugerencia;

  /// Créditos al pie del acceso: año y equipo que desarrolla la app.
  ///
  /// In es, this message translates to:
  /// **'© {anio} Lattice Systems'**
  String accesoCreditos(int anio);

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

  /// Botón secundario del aviso de cuenta desactivada.
  ///
  /// In es, this message translates to:
  /// **'Escribir un correo'**
  String get accesoDesactivadaEscribir;

  /// Explica por qué no se puede entrar y qué sí se puede hacer.
  ///
  /// In es, this message translates to:
  /// **'La agencia desactivó el acceso de esta cuenta. Desde la app no podemos reactivarla: comunícate con ellos y te ayudan.'**
  String get accesoDesactivadaExplicacion;

  /// Botón principal del aviso de cuenta desactivada.
  ///
  /// In es, this message translates to:
  /// **'Llamar a la agencia'**
  String get accesoDesactivadaLlamar;

  /// Aviso cuando el celular no puede abrir el teléfono o el correo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir en este dispositivo.'**
  String get accesoDesactivadaNoSePudo;

  /// Título de la pantalla de V2-M01.08.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está desactivada'**
  String get accesoDesactivadaTitulo;

  /// Salida del aviso: regresa al login si fue un error.
  ///
  /// In es, this message translates to:
  /// **'Volver a iniciar sesión'**
  String get accesoDesactivadaVolver;

  /// Explica por qué el enlace de recuperación dejó de servir.
  ///
  /// In es, this message translates to:
  /// **'Los enlaces vencen pronto y se pueden usar una sola vez. Pide uno nuevo y revisa tu correo.'**
  String get accesoEnlaceNoValidoMensaje;

  /// Título cuando el enlace de recuperación venció o ya se usó.
  ///
  /// In es, this message translates to:
  /// **'El enlace ya no sirve'**
  String get accesoEnlaceNoValidoTitulo;

  /// Botón que lleva a pedir un enlace de recuperación nuevo.
  ///
  /// In es, this message translates to:
  /// **'Pedir otro enlace'**
  String get accesoEnlacePedirOtro;

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

  /// Casilla opcional de V2-M01.10, apagada por omisión.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión en todos mis dispositivos'**
  String get accesoMiContrasenaCerrarOtras;

  /// Dice que cerrar todas también cierra la de este dispositivo.
  ///
  /// In es, this message translates to:
  /// **'Incluye este celular: tendrás que entrar otra vez con tu contraseña nueva.'**
  String get accesoMiContrasenaCerrarOtrasDetalle;

  /// Explica por qué se pide la contraseña actual.
  ///
  /// In es, this message translates to:
  /// **'Te pedimos la contraseña de ahora para confirmar que eres tú.'**
  String get accesoMiContrasenaExplicacion;

  /// Botón principal de «cambiar mi contraseña».
  ///
  /// In es, this message translates to:
  /// **'Guardar la contraseña nueva'**
  String get accesoMiContrasenaGuardar;

  /// Título del aviso de éxito.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña quedó actualizada'**
  String get accesoMiContrasenaListo;

  /// Mensaje del aviso de éxito.
  ///
  /// In es, this message translates to:
  /// **'Úsala la próxima vez que inicies sesión.'**
  String get accesoMiContrasenaListoMensaje;

  /// Título de la pantalla de V2-M01.10, abierta desde Ajustes.
  ///
  /// In es, this message translates to:
  /// **'Cambiar mi contraseña'**
  String get accesoMiContrasenaTitulo;

  /// Explica qué hace la pantalla a la que abre el enlace.
  ///
  /// In es, this message translates to:
  /// **'Elige una contraseña nueva. Este enlace sirve una sola vez.'**
  String get accesoNuevaExplicacion;

  /// Título del aviso cuando el servidor rechaza la contraseña nueva.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu contraseña'**
  String get accesoNuevaFalloTitulo;

  /// Texto del botón mientras el servidor responde.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get accesoNuevaGuardando;

  /// Botón que guarda la contraseña nueva.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get accesoNuevaGuardar;

  /// Botón que lleva al acceso tras guardar la contraseña nueva.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get accesoNuevaIrAlAcceso;

  /// Detalle del aviso de contraseña guardada.
  ///
  /// In es, this message translates to:
  /// **'Ya puedes iniciar sesión con ella.'**
  String get accesoNuevaListoMensaje;

  /// Título del aviso cuando la contraseña nueva se guardó.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña quedó lista'**
  String get accesoNuevaListoTitulo;

  /// Título de la pantalla a la que abre el enlace del correo.
  ///
  /// In es, this message translates to:
  /// **'Elige tu contraseña nueva'**
  String get accesoNuevaTitulo;

  /// Enlace a la recuperación de contraseña desde la pantalla de acceso.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get accesoOlvide;

  /// Interruptor de V2-M01.05 en mi perfil.
  ///
  /// In es, this message translates to:
  /// **'Entrar con huella o rostro'**
  String get accesoPerfilCandado;

  /// Descripción del interruptor del desbloqueo.
  ///
  /// In es, this message translates to:
  /// **'Para abrir la app sin escribir tu contraseña'**
  String get accesoPerfilCandadoDetalle;

  /// Texto que muestra el sistema al prender el desbloqueo.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu huella para prender el desbloqueo.'**
  String get accesoPerfilCandadoMotivo;

  /// Aviso cuando no se reconoce la huella al prenderlo.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar tu huella. El desbloqueo sigue apagado.'**
  String get accesoPerfilCandadoNoSePudo;

  /// Lo que anuncia el lector de pantalla mientras carga el perfil.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu perfil…'**
  String get accesoPerfilCargando;

  /// Etiqueta de la fecha en que la persona se volvió cliente de la agencia.
  ///
  /// In es, this message translates to:
  /// **'Cliente desde'**
  String get accesoPerfilClienteDesde;

  /// Etiqueta del correo en el perfil.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get accesoPerfilCorreo;

  /// Encabezado de la sección del perfil con las opciones de la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get accesoPerfilCuentaEncabezado;

  /// Encabezado de la sección del perfil con los datos del cliente.
  ///
  /// In es, this message translates to:
  /// **'Tus datos'**
  String get accesoPerfilDatosEncabezado;

  /// Fila del perfil que abre la lista de sesiones abiertas.
  ///
  /// In es, this message translates to:
  /// **'Mis sesiones'**
  String get accesoPerfilMisSesiones;

  /// Explicación de la fila que abre la lista de sesiones abiertas.
  ///
  /// In es, this message translates to:
  /// **'Mira y cierra las sesiones abiertas en otros dispositivos'**
  String get accesoPerfilMisSesionesDetalle;

  /// Etiqueta del nombre en el perfil.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get accesoPerfilNombre;

  /// Pie de los datos del perfil. Son de solo lectura hasta que exista la edición (V2-M01.07), y conviene decir qué hacer mientras tanto en vez de dejar al cliente buscando un botón que no existe.
  ///
  /// In es, this message translates to:
  /// **'Toca tu correo para cambiarlo. Para el teléfono, comunícate con la agencia.'**
  String get accesoPerfilPie;

  /// Lo que se muestra cuando la agencia no capturó el teléfono del cliente, en vez de dejar el renglón vacío.
  ///
  /// In es, this message translates to:
  /// **'Sin teléfono registrado'**
  String get accesoPerfilSinTelefono;

  /// Lo que dice la sección de vehículos del perfil cuando la cuenta no tiene ninguno.
  ///
  /// In es, this message translates to:
  /// **'No tienes vehículos registrados'**
  String get accesoPerfilSinVehiculos;

  /// Etiqueta del teléfono en el perfil.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get accesoPerfilTelefono;

  /// Título de la pantalla del perfil del cliente.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get accesoPerfilTitulo;

  /// Encabezado de la sección del perfil con los vehículos del cliente.
  ///
  /// In es, this message translates to:
  /// **'Tus vehículos'**
  String get accesoPerfilVehiculosEncabezado;

  /// Aviso dentro del perfil cuando la lista de vehículos falla. El resto del perfil se sigue viendo, porque son dos lecturas distintas.
  ///
  /// In es, this message translates to:
  /// **'No pudimos traer tus vehículos'**
  String get accesoPerfilVehiculosFallo;

  /// Título del paso del código de recuperación.
  ///
  /// In es, this message translates to:
  /// **'Escribe el código'**
  String get accesoCodigoTitulo;

  /// Explicación del paso del código; {correo} es el correo al que se envió.
  ///
  /// In es, this message translates to:
  /// **'Te lo enviamos a {correo}. Tiene 6 dígitos y vence en 15 minutos.'**
  String accesoCodigoExplicacion(String correo);

  /// Etiqueta del campo del código de recuperación.
  ///
  /// In es, this message translates to:
  /// **'Código de 6 dígitos'**
  String get accesoCodigoEtiqueta;

  /// Error cuando el código no tiene 6 dígitos.
  ///
  /// In es, this message translates to:
  /// **'Escribe los 6 dígitos del código'**
  String get accesoCodigoIncompleto;

  /// Aviso cuando el servidor rechaza el código.
  ///
  /// In es, this message translates to:
  /// **'Ese código no sirve'**
  String get accesoCodigoNoValidoTitulo;

  /// Mensaje del aviso de código rechazado.
  ///
  /// In es, this message translates to:
  /// **'Puede estar mal escrito, ya usado o vencido. Revisa el correo más reciente o pide otro.'**
  String get accesoCodigoNoValidoMensaje;

  /// Botón para pedir otro código.
  ///
  /// In es, this message translates to:
  /// **'Enviar otro código'**
  String get accesoCodigoReenviar;

  /// Aviso tras pedir otro código.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos otro código'**
  String get accesoCodigoReenviado;

  /// Título cuando se llega al paso del código sin correo ni enlace.
  ///
  /// In es, this message translates to:
  /// **'Pide primero el código'**
  String get accesoCodigoSinCorreo;

  /// Título del aviso tras pedir el enlace de recuperación.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get accesoRecuperarEnviado;

  /// Explica que el enlace puede no llegar si el correo no tiene cuenta, para que nadie se quede esperando.
  ///
  /// In es, this message translates to:
  /// **'Si ese correo tiene una cuenta, te llegará un código de 6 dígitos. Vence en 15 minutos y sirve una sola vez.'**
  String get accesoRecuperarEnviadoMensaje;

  /// Texto del botón mientras el servidor responde.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get accesoRecuperarEnviando;

  /// Botón que pide el enlace de recuperación.
  ///
  /// In es, this message translates to:
  /// **'Enviarme el código'**
  String get accesoRecuperarEnviar;

  /// Explica qué hace la pantalla de recuperación.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y te enviamos un código de 6 dígitos para elegir una contraseña nueva.'**
  String get accesoRecuperarExplicacion;

  /// Título del aviso cuando falla la petición del enlace.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviar el código'**
  String get accesoRecuperarFalloTitulo;

  /// Título de la pantalla de recuperación.
  ///
  /// In es, this message translates to:
  /// **'Recupera tu contraseña'**
  String get accesoRecuperarTitulo;

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

  /// Último uso de una sesión que se usó hace menos de un minuto.
  ///
  /// In es, this message translates to:
  /// **'Activa ahora'**
  String get accesoSesionesActivaAhora;

  /// Aviso cuando cerrar una sesión falla porque su identificador ya cambió: la sesión sigue abierta con otro identificador.
  ///
  /// In es, this message translates to:
  /// **'Esa sesión cambió mientras la veías. Revisa la lista e inténtalo otra vez.'**
  String get accesoSesionesCambio;

  /// Qué hacer cuando cambió la biometría del equipo.
  ///
  /// In es, this message translates to:
  /// **'Por seguridad apagamos el desbloqueo con huella. Entra con tu contraseña y lo puedes volver a prender.'**
  String get desbloqueoCambioMensaje;

  /// Título del aviso cuando la biometría ya no es la de antes.
  ///
  /// In es, this message translates to:
  /// **'La biometría de tu teléfono cambió'**
  String get desbloqueoCambioTitulo;

  /// Salida siempre disponible del desbloqueo: cierra la sesión.
  ///
  /// In es, this message translates to:
  /// **'Entrar con mi contraseña'**
  String get desbloqueoContrasena;

  /// Explicación de la pantalla de desbloqueo.
  ///
  /// In es, this message translates to:
  /// **'Usa tu huella o tu rostro para entrar.'**
  String get desbloqueoExplicacion;

  /// Qué hacer cuando el sistema no reconoció la huella.
  ///
  /// In es, this message translates to:
  /// **'Intenta otra vez o entra con tu contraseña.'**
  String get desbloqueoFalloMensaje;

  /// Título del aviso cuando falla el reconocimiento.
  ///
  /// In es, this message translates to:
  /// **'No te reconocimos'**
  String get desbloqueoFalloTitulo;

  /// Botón que vuelve a pedir la biometría.
  ///
  /// In es, this message translates to:
  /// **'Usar mi huella o mi rostro'**
  String get desbloqueoIntentar;

  /// Texto que muestra el sistema en el diálogo de biometría.
  ///
  /// In es, this message translates to:
  /// **'Confirma que eres tú para entrar a CareCar.'**
  String get desbloqueoMotivo;

  /// Título de la pantalla de V2-M01.05.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea CareCar'**
  String get desbloqueoTitulo;

  /// Acción secundaria del diálogo que confirma cerrar todas las sesiones.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get accesoSesionesCancelar;

  /// Lo que anuncia el lector de pantalla mientras carga la lista de sesiones.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus sesiones…'**
  String get accesoSesionesCargando;

  /// Confirmación después de cerrar una sesión de la lista.
  ///
  /// In es, this message translates to:
  /// **'Listo, esa sesión se cerró.'**
  String get accesoSesionesCerrada;

  /// Botón de cada fila para cerrar esa sesión.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get accesoSesionesCerrar;

  /// Etiqueta para lector de pantalla del botón de cerrar una sesión, para que no diga solo «Cerrar».
  ///
  /// In es, this message translates to:
  /// **'Cerrar la sesión de {dispositivo}'**
  String accesoSesionesCerrarEtiqueta(String dispositivo);

  /// Botón inferior que cierra la sesión en todos los dispositivos.
  ///
  /// In es, this message translates to:
  /// **'Cerrar todas las sesiones'**
  String get accesoSesionesCerrarTodas;

  /// Acción principal del diálogo que confirma cerrar todas las sesiones.
  ///
  /// In es, this message translates to:
  /// **'Cerrar todas'**
  String get accesoSesionesCerrarTodasConfirmar;

  /// Mensaje del diálogo de cerrar todas: avisa que la sesión de este mismo teléfono también se cierra.
  ///
  /// In es, this message translates to:
  /// **'Se cerrarán en todos tus dispositivos, incluido este. Tendrás que entrar otra vez.'**
  String get accesoSesionesCerrarTodasMensaje;

  /// Título del diálogo que confirma cerrar todas las sesiones.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar todas las sesiones?'**
  String get accesoSesionesCerrarTodasTitulo;

  /// Mensaje del diálogo que confirma cerrar una sesión de la lista.
  ///
  /// In es, this message translates to:
  /// **'Ese dispositivo tendrá que entrar otra vez con tu correo y tu contraseña.'**
  String get accesoSesionesCerrarUnaMensaje;

  /// Título del diálogo que confirma cerrar una sesión.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar la sesión de {dispositivo}?'**
  String accesoSesionesCerrarUnaTitulo(String dispositivo);

  /// Encabezado de la lista de sesiones.
  ///
  /// In es, this message translates to:
  /// **'Dispositivos con tu sesión abierta'**
  String get accesoSesionesEncabezado;

  /// Nombre que se muestra cuando la sesión no trae el nombre del dispositivo, como las abiertas antes de esta función.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo sin nombre'**
  String get accesoSesionesEquipoSinNombre;

  /// Aviso cuando cerrar una sesión falla por un error de red o del servidor.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cerrar esa sesión. Inténtalo otra vez.'**
  String get accesoSesionesFalloCerrar;

  /// Último uso de una sesión, en días.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =1{Hace 1 día} other{Hace {dias} días}}'**
  String accesoSesionesHaceDias(int dias);

  /// Último uso de una sesión, en horas.
  ///
  /// In es, this message translates to:
  /// **'{horas, plural, =1{Hace 1 hora} other{Hace {horas} horas}}'**
  String accesoSesionesHaceHoras(int horas);

  /// Último uso de una sesión, en minutos.
  ///
  /// In es, this message translates to:
  /// **'{minutos, plural, =1{Hace 1 minuto} other{Hace {minutos} minutos}}'**
  String accesoSesionesHaceMinutos(int minutos);

  /// Pie de la lista de sesiones: qué hacer si hay un dispositivo desconocido.
  ///
  /// In es, this message translates to:
  /// **'Si ves un dispositivo que no reconoces, ciérralo y cambia tu contraseña.'**
  String get accesoSesionesPie;

  /// Último uso de una sesión abierta antes de esta función, que no guardó ninguna fecha.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad registrada'**
  String get accesoSesionesSinActividad;

  /// Título de la pantalla de sesiones y dispositivos activos.
  ///
  /// In es, this message translates to:
  /// **'Mis sesiones'**
  String get accesoSesionesTitulo;

  /// Último uso de una sesión de hace más de una semana, con la fecha.
  ///
  /// In es, this message translates to:
  /// **'El {fecha}'**
  String accesoSesionesUltimoUsoFecha(String fecha);

  /// Mensaje del estado vacío de la lista de sesiones.
  ///
  /// In es, this message translates to:
  /// **'Cuando entres desde un dispositivo, aparecerá aquí.'**
  String get accesoSesionesVacioMensaje;

  /// Título del estado vacío de la lista de sesiones.
  ///
  /// In es, this message translates to:
  /// **'No hay sesiones abiertas'**
  String get accesoSesionesVacioTitulo;

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

  /// Lema en la portada del acceso, en dos líneas, bajo el logo.
  ///
  /// In es, this message translates to:
  /// **'Tu auto,\nen buenas manos.'**
  String get accesoLema;

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

  /// Encabezado de la lista de guías.
  ///
  /// In es, this message translates to:
  /// **'Guías'**
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

  /// Descripción bajo el título del catálogo de modelos.
  ///
  /// In es, this message translates to:
  /// **'Los modelos vigentes de la agencia con su precio. Toca uno para ver el detalle, o compara varios.'**
  String get catalogoSubtitulo;

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

  /// Descripción bajo el título de Mis citas.
  ///
  /// In es, this message translates to:
  /// **'Tus citas próximas y pasadas, cada una con su estado.'**
  String get citasMisCitasSubtitulo;

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

  /// Título de la pantalla que confirma que la cita se movió a otro horario.
  ///
  /// In es, this message translates to:
  /// **'Cita reprogramada'**
  String get citasReprogramadaTitulo;

  /// Aviso tras reprogramar.
  ///
  /// In es, this message translates to:
  /// **'Te esperamos el {fecha} a las {hora}. El horario anterior quedó libre.'**
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

  /// Falla inesperada en una acción.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Intenta de nuevo.'**
  String get tiendaAccionError;

  /// Falla de red al cambiar un pedido.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e intenta de nuevo.'**
  String get tiendaAccionSinConexion;

  /// Botón hacia agendar una cita.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get tiendaAgendarCita;

  /// Producto sin existencia.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get tiendaAgotado;

  /// Confirmación al agregar.
  ///
  /// In es, this message translates to:
  /// **'Agregado. Llevas {piezas} de este producto.'**
  String tiendaAgregado(int piezas);

  /// Botón para agregar un producto.
  ///
  /// In es, this message translates to:
  /// **'Agregar al carrito'**
  String get tiendaAgregar;

  /// Detalle del cierre del apartado.
  ///
  /// In es, this message translates to:
  /// **'Tu apartado vence el {fecha}. Págalo ahora en la app o en caja al recoger.'**
  String tiendaApartadoMensaje(String fecha);

  /// Cierre del apartado.
  ///
  /// In es, this message translates to:
  /// **'Productos apartados'**
  String get tiendaApartadoTitulo;

  /// Botón que aparta el carrito.
  ///
  /// In es, this message translates to:
  /// **'Apartar'**
  String get tiendaApartar;

  /// Falla de red al apartar.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Tu carrito se conserva: vuelve a intentar y no se apartará dos veces.'**
  String get tiendaApartarSinConexion;

  /// Sección de los estados del pedido.
  ///
  /// In es, this message translates to:
  /// **'Avance'**
  String get tiendaAvanceTitulo;

  /// Etiqueta del buscador.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o código'**
  String get tiendaBuscar;

  /// Elige otra cita para instalar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de cita'**
  String get tiendaCambiarCita;

  /// Confirma la cancelación.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get tiendaCancelarConfirmar;

  /// Detalle de la confirmación.
  ///
  /// In es, this message translates to:
  /// **'Las piezas se liberan y otra persona puede apartarlas.'**
  String get tiendaCancelarMensaje;

  /// Botón para cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar pedido'**
  String get tiendaCancelarPedido;

  /// Confirmación de cancelación.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar el pedido?'**
  String get tiendaCancelarTitulo;

  /// No cancela.
  ///
  /// In es, this message translates to:
  /// **'Conservar'**
  String get tiendaCancelarVolver;

  /// Etiqueta del selector de piezas.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get tiendaCantidad;

  /// Anuncio del esqueleto de carga.
  ///
  /// In es, this message translates to:
  /// **'Cargando la tienda'**
  String get tiendaCargando;

  /// Carrito lleno.
  ///
  /// In es, this message translates to:
  /// **'El carrito admite hasta {maximo} productos distintos.'**
  String tiendaCarritoLleno(int maximo);

  /// Título del carrito.
  ///
  /// In es, this message translates to:
  /// **'Carrito'**
  String get tiendaCarritoTitulo;

  /// Detalle del carrito vacío.
  ///
  /// In es, this message translates to:
  /// **'Agrega productos desde la tienda para apartarlos.'**
  String get tiendaCarritoVacioMensaje;

  /// Estado vacío del carrito.
  ///
  /// In es, this message translates to:
  /// **'Tu carrito está vacío'**
  String get tiendaCarritoVacioTitulo;

  /// Categoría de producto.
  ///
  /// In es, this message translates to:
  /// **'Accesorios'**
  String get tiendaCategoriaAccesorio;

  /// Categoría de producto.
  ///
  /// In es, this message translates to:
  /// **'Cuidado del auto'**
  String get tiendaCategoriaCuidado;

  /// Categoría de producto.
  ///
  /// In es, this message translates to:
  /// **'Refacciones'**
  String get tiendaCategoriaRefaccion;

  /// Filtro sin categoría.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get tiendaCategoriaTodas;

  /// Marca de la cita elegida.
  ///
  /// In es, this message translates to:
  /// **'Elegida'**
  String get tiendaCitaElegida;

  /// Rango de años de un modelo compatible.
  ///
  /// In es, this message translates to:
  /// **'{desde} a {hasta}'**
  String tiendaCompatibilidadAnios(String desde, String hasta);

  /// Encabezado de la lista de compatibilidad.
  ///
  /// In es, this message translates to:
  /// **'Autos compatibles'**
  String get tiendaCompatibilidadTitulo;

  /// Insignia de producto compatible.
  ///
  /// In es, this message translates to:
  /// **'Le queda a tu auto'**
  String get tiendaCompatible;

  /// Título del detalle de un pedido.
  ///
  /// In es, this message translates to:
  /// **'Mi pedido'**
  String get tiendaDetalleTitulo;

  /// Encabezado del selector de citas.
  ///
  /// In es, this message translates to:
  /// **'Elige la cita'**
  String get tiendaElegirCita;

  /// Cierra un diálogo.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get tiendaEntendido;

  /// Texto de la entrada a la tienda desde el catálogo.
  ///
  /// In es, this message translates to:
  /// **'Accesorios y refacciones originales para tu auto'**
  String get tiendaEntradaDetalle;

  /// Entrega con instalación.
  ///
  /// In es, this message translates to:
  /// **'Instalar en mi cita'**
  String get tiendaEntregaCita;

  /// Entrega en mostrador.
  ///
  /// In es, this message translates to:
  /// **'Recoger en mostrador'**
  String get tiendaEntregaMostrador;

  /// Sección de cómo se entrega.
  ///
  /// In es, this message translates to:
  /// **'Entrega'**
  String get tiendaEntregaTitulo;

  /// Falla al leer las citas.
  ///
  /// In es, this message translates to:
  /// **'No pudimos consultar tus citas.'**
  String get tiendaErrorCitas;

  /// Falla al pedir otra página.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más. Intenta de nuevo.'**
  String get tiendaErrorMas;

  /// Detalle del error genérico.
  ///
  /// In es, this message translates to:
  /// **'Intenta de nuevo en un momento.'**
  String get tiendaErrorMensaje;

  /// Error genérico.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar esto'**
  String get tiendaErrorTitulo;

  /// Estado del pedido.
  ///
  /// In es, this message translates to:
  /// **'Apartado'**
  String get tiendaEstadoApartado;

  /// Estado del pedido.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get tiendaEstadoCancelado;

  /// Estado del pedido.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get tiendaEstadoEntregado;

  /// Estado del pedido.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get tiendaEstadoListo;

  /// Piezas disponibles de un producto.
  ///
  /// In es, this message translates to:
  /// **'{piezas, plural, =1{Queda 1 pieza} other{Quedan {piezas} piezas}}'**
  String tiendaExistencia(int piezas);

  /// Encabezado del filtro por vehículo.
  ///
  /// In es, this message translates to:
  /// **'Compatible con'**
  String get tiendaFiltroAuto;

  /// Descripción de la foto de un producto.
  ///
  /// In es, this message translates to:
  /// **'Foto de {producto}'**
  String tiendaFotoDe(String producto);

  /// Sección de instalación del pedido.
  ///
  /// In es, this message translates to:
  /// **'Instalación'**
  String get tiendaInstalacionTitulo;

  /// Botón del producto para instalarlo en la cita.
  ///
  /// In es, this message translates to:
  /// **'Instalar en mi próxima cita'**
  String get tiendaInstalarProxima;

  /// Botón que lleva a la tienda.
  ///
  /// In es, this message translates to:
  /// **'Ir a la tienda'**
  String get tiendaIrALaTienda;

  /// Aviso de compatibilidad en el producto.
  ///
  /// In es, this message translates to:
  /// **'Le queda a tu {auto}'**
  String tiendaLeQueda(String auto);

  /// No se pueden agregar más piezas de ese producto.
  ///
  /// In es, this message translates to:
  /// **'Ya llevas {piezas}, el máximo de este producto.'**
  String tiendaMaximoAlcanzado(int piezas);

  /// Con qué se pagó si no se sabe la marca.
  ///
  /// In es, this message translates to:
  /// **'tarjeta'**
  String get tiendaMedioTarjeta;

  /// Título y botón de la lista de pedidos.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get tiendaMisPedidos;

  /// Motivo de cancelación.
  ///
  /// In es, this message translates to:
  /// **'Lo canceló la agencia'**
  String get tiendaMotivoAgencia;

  /// Motivo de cancelación.
  ///
  /// In es, this message translates to:
  /// **'Lo cancelaste tú'**
  String get tiendaMotivoCliente;

  /// Motivo de cancelación.
  ///
  /// In es, this message translates to:
  /// **'El apartado venció'**
  String get tiendaMotivoVencido;

  /// Aviso de incompatibilidad en el producto.
  ///
  /// In es, this message translates to:
  /// **'No le queda a tu {auto}'**
  String tiendaNoLeQueda(String auto);

  /// Título del diálogo de rechazo al apartar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo apartar'**
  String get tiendaNoSeApartoTitulo;

  /// Título del diálogo de rechazo al cambiar un pedido.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar el pedido'**
  String get tiendaNoSeCambioTitulo;

  /// Un pedido ya pagado en la app (V2-M14.04).
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get tiendaPagado;

  /// Título del aviso de un pedido pagado en la app.
  ///
  /// In es, this message translates to:
  /// **'Pagado con {medio}'**
  String tiendaPagadoAviso(String medio);

  /// En lugar del botón de cancelar de un pedido pagado.
  ///
  /// In es, this message translates to:
  /// **'Ya está pagado: si necesitas cancelarlo, hazlo en el mostrador.'**
  String get tiendaPagadoCancelarEnMostrador;

  /// Cuándo se pagó el pedido.
  ///
  /// In es, this message translates to:
  /// **'El {fecha}. Ya no vence.'**
  String tiendaPagadoMensaje(String fecha);

  /// Botón que abre el pago del pedido.
  ///
  /// In es, this message translates to:
  /// **'Pagar {monto}'**
  String tiendaPagar(String monto);

  /// Cierre del apartado: abre el pago del pedido.
  ///
  /// In es, this message translates to:
  /// **'Pagar ahora'**
  String get tiendaPagarAhora;

  /// Cierre del apartado: abre el pedido para pagarlo al recogerlo.
  ///
  /// In es, this message translates to:
  /// **'Pagar en caja'**
  String get tiendaPagarEnCaja;

  /// Cómo se paga un pedido.
  ///
  /// In es, this message translates to:
  /// **'Paga en la app desde tu pedido o en caja al recoger.'**
  String get tiendaPagoEnAppOCaja;

  /// Cómo se paga.
  ///
  /// In es, this message translates to:
  /// **'No se cobra en la app: pagas en caja.'**
  String get tiendaPagoEnCaja;

  /// Detalle de pedido inexistente.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu lista de pedidos.'**
  String get tiendaPedidoNoEncontradoMensaje;

  /// Pedido ajeno o inexistente.
  ///
  /// In es, this message translates to:
  /// **'No encontramos ese pedido'**
  String get tiendaPedidoNoEncontradoTitulo;

  /// Total y piezas de un pedido.
  ///
  /// In es, this message translates to:
  /// **'{total}, {piezas, plural, =1{1 pieza} other{{piezas} piezas}}'**
  String tiendaPedidoResumen(String total, int piezas);

  /// Título de un pedido.
  ///
  /// In es, this message translates to:
  /// **'Pedido {numero}'**
  String tiendaPedidoTitulo(int numero);

  /// Detalle de mis pedidos vacío.
  ///
  /// In es, this message translates to:
  /// **'Lo que apartes en la tienda aparece aquí.'**
  String get tiendaPedidosVacioMensaje;

  /// Estado vacío de mis pedidos.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes pedidos'**
  String get tiendaPedidosVacioTitulo;

  /// Precio unitario.
  ///
  /// In es, this message translates to:
  /// **'{precio} cada uno'**
  String tiendaPrecioCadaUno(String precio);

  /// Detalle de producto retirado.
  ///
  /// In es, this message translates to:
  /// **'Puede que la agencia lo haya retirado de la tienda.'**
  String get tiendaProductoNoEncontradoMensaje;

  /// Producto retirado o inexistente.
  ///
  /// In es, this message translates to:
  /// **'Ese producto ya no está'**
  String get tiendaProductoNoEncontradoTitulo;

  /// Título de la pantalla de un producto.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get tiendaProductoTitulo;

  /// Sección de renglones del pedido.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get tiendaProductosTitulo;

  /// Quita un producto del carrito.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get tiendaQuitar;

  /// Quita los filtros de la tienda.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los productos'**
  String get tiendaQuitarFiltros;

  /// Rechazo CITA_NO_DISPONIBLE.
  ///
  /// In es, this message translates to:
  /// **'Esa cita está cancelada o ya pasó. Elige otra o recoge en mostrador.'**
  String get tiendaRechazoCitaNoDisponible;

  /// Rechazo PRODUCTO_INCOMPATIBLE.
  ///
  /// In es, this message translates to:
  /// **'Algún producto no le queda al auto de esa cita. Elige otra cita o recoge en mostrador.'**
  String get tiendaRechazoIncompatible;

  /// Rechazo LIMITE_APARTADOS.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes 3 pedidos sin entregar. Recoge o cancela uno para apartar más.'**
  String get tiendaRechazoLimite;

  /// Rechazo PEDIDO_NO_CANCELABLE.
  ///
  /// In es, this message translates to:
  /// **'Este pedido ya se entregó y no se puede cancelar.'**
  String get tiendaRechazoNoCancelable;

  /// Rechazo PEDIDO_NO_MODIFICABLE.
  ///
  /// In es, this message translates to:
  /// **'Este pedido ya se entregó o se canceló y no se puede cambiar.'**
  String get tiendaRechazoNoModificable;

  /// Rechazo PEDIDO_PAGADO.
  ///
  /// In es, this message translates to:
  /// **'Este pedido ya está pagado y no se cancela desde la app: cancélalo en el mostrador.'**
  String get tiendaRechazoPagado;

  /// Rechazo SIN_EXISTENCIA.
  ///
  /// In es, this message translates to:
  /// **'Ya no alcanzan las piezas. Revisa la existencia y ajusta la cantidad.'**
  String get tiendaRechazoSinExistencia;

  /// Botón de reintento.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get tiendaReintentar;

  /// Cantidad y precio de un renglón.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} por {precio}'**
  String tiendaRenglonDetalle(int cantidad, String precio);

  /// El pedido va ligado a una cita.
  ///
  /// In es, this message translates to:
  /// **'Se instala en tu cita'**
  String get tiendaSeInstala;

  /// El pedido se recoge.
  ///
  /// In es, this message translates to:
  /// **'Se recoge en mostrador'**
  String get tiendaSeRecoge;

  /// Regresa a la tienda.
  ///
  /// In es, this message translates to:
  /// **'Seguir en la tienda'**
  String get tiendaSeguirComprando;

  /// Ninguna cita es de un auto compatible.
  ///
  /// In es, this message translates to:
  /// **'No le queda al auto de ninguna de tus próximas citas.'**
  String get tiendaSinCitaCompatible;

  /// No hay cita donde instalar.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas confirmadas por venir. Agenda una para que lo instalen.'**
  String get tiendaSinCitas;

  /// Detalle del error sin conexión.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu internet e intenta de nuevo.'**
  String get tiendaSinConexionMensaje;

  /// Error sin conexión.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get tiendaSinConexionTitulo;

  /// La tarjeta con que se pagó: marca y últimos 4.
  ///
  /// In es, this message translates to:
  /// **'{marca} •••• {ultimos4}'**
  String tiendaTarjeta(String marca, String ultimos4);

  /// Título de la tienda y de su entrada.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get tiendaTitulo;

  /// Opción para no filtrar por vehículo.
  ///
  /// In es, this message translates to:
  /// **'Todos los productos'**
  String get tiendaTodosLosProductos;

  /// Total del carrito o del pedido.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get tiendaTotal;

  /// Producto universal.
  ///
  /// In es, this message translates to:
  /// **'Para cualquier auto'**
  String get tiendaUniversal;

  /// Mensaje del estado vacío de la tienda.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otra búsqueda, otra categoría u otro auto.'**
  String get tiendaVacioMensaje;

  /// Estado vacío de la tienda.
  ///
  /// In es, this message translates to:
  /// **'No encontramos productos'**
  String get tiendaVacioTitulo;

  /// Cuándo vence un apartado.
  ///
  /// In es, this message translates to:
  /// **'Vence el {fecha}'**
  String tiendaVence(String fecha);

  /// Aviso de vencimiento en el pedido.
  ///
  /// In es, this message translates to:
  /// **'Vence el {fecha}. Pasada esa hora se cancela y las piezas se liberan.'**
  String tiendaVenceDetalle(String fecha);

  /// Botón al carrito con el número de piezas.
  ///
  /// In es, this message translates to:
  /// **'Ver carrito ({piezas})'**
  String tiendaVerCarrito(int piezas);

  /// Pide la página siguiente.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get tiendaVerMas;

  /// Abre el pedido recién creado.
  ///
  /// In es, this message translates to:
  /// **'Ver mi pedido'**
  String get tiendaVerMiPedido;

  /// Vigencia del apartado con instalación.
  ///
  /// In es, this message translates to:
  /// **'El apartado dura hasta el final del día siguiente a tu cita.'**
  String get tiendaVigenciaCita;

  /// Vigencia del apartado en mostrador.
  ///
  /// In es, this message translates to:
  /// **'El apartado dura 48 horas. Si vence, las piezas se liberan.'**
  String get tiendaVigenciaMostrador;

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

  /// Descripción bajo el título de la pantalla con los vehículos del cliente.
  ///
  /// In es, this message translates to:
  /// **'Tus autos en un solo lugar. Toca uno para ver su ficha, su historial y agendar su servicio.'**
  String get vehiculosSubtitulo;

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

  /// Título de la pantalla de preferencias de avisos.
  ///
  /// In es, this message translates to:
  /// **'Qué avisos recibo'**
  String get preferenciasAvisosTitulo;

  /// Aclara que no hay botón de guardar.
  ///
  /// In es, this message translates to:
  /// **'Se guarda al momento'**
  String get preferenciasAvisosSubtitulo;

  /// Anuncio al lector de pantalla mientras cargan.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus preferencias'**
  String get preferenciasAvisosCargando;

  /// Título del aviso cuando el guardado falla.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el cambio'**
  String get preferenciasAvisosFalloTitulo;

  /// Explica que el interruptor se revirtió.
  ///
  /// In es, this message translates to:
  /// **'Lo dejamos como estaba. Inténtalo otra vez en un momento.'**
  String get preferenciasAvisosFalloMensaje;

  /// Categoría de avisos del taller.
  ///
  /// In es, this message translates to:
  /// **'Mi auto en el taller'**
  String get preferenciasAvisosTaller;

  /// Detalle de la categoría del taller.
  ///
  /// In es, this message translates to:
  /// **'Cada vez que tu auto avanza de etapa.'**
  String get preferenciasAvisosTallerDetalle;

  /// Categoría de avisos de citas.
  ///
  /// In es, this message translates to:
  /// **'Mis citas'**
  String get preferenciasAvisosCitas;

  /// Detalle de la categoría de citas.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios 24 y 2 horas antes.'**
  String get preferenciasAvisosCitasDetalle;

  /// Categoría de avisos de mantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get preferenciasAvisosMantenimiento;

  /// Categoría de avisos de documentos.
  ///
  /// In es, this message translates to:
  /// **'Documentos'**
  String get preferenciasAvisosDocumentos;

  /// Categoría de avisos de mensajería.
  ///
  /// In es, this message translates to:
  /// **'Mensajes de mi asesor'**
  String get preferenciasAvisosMensajes;

  /// Categoría de avisos comerciales.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get preferenciasAvisosPromociones;

  /// Detalle de la categoría de promociones.
  ///
  /// In es, this message translates to:
  /// **'Ofertas y novedades de la agencia. Vienen apagadas.'**
  String get preferenciasAvisosPromocionesDetalle;

  /// Categoría que esta versión no conoce.
  ///
  /// In es, this message translates to:
  /// **'Otros avisos'**
  String get preferenciasAvisosOtros;

  /// Interruptor del horario silencioso.
  ///
  /// In es, this message translates to:
  /// **'Horario silencioso'**
  String get preferenciasAvisosSilencio;

  /// Detalle del horario silencioso.
  ///
  /// In es, this message translates to:
  /// **'En ese rango no te avisamos nada.'**
  String get preferenciasAvisosSilencioDetalle;

  /// Explica que un rango que cruza la medianoche es correcto.
  ///
  /// In es, this message translates to:
  /// **'El silencio cruza la medianoche, que es lo normal para dormir.'**
  String get preferenciasAvisosCruzaMedianoche;

  /// Explica un rango que no cruza la medianoche.
  ///
  /// In es, this message translates to:
  /// **'El silencio es dentro del mismo día.'**
  String get preferenciasAvisosMismoDia;

  /// Fila del perfil que abre las preferencias de avisos.
  ///
  /// In es, this message translates to:
  /// **'Qué avisos recibo'**
  String get accesoPerfilPreferenciasAvisos;

  /// Boton que elige la hora de inicio del silencio.
  ///
  /// In es, this message translates to:
  /// **'Desde {hora}'**
  String preferenciasAvisosDesde(String hora);

  /// Boton que elige la hora de fin del silencio.
  ///
  /// In es, this message translates to:
  /// **'Hasta {hora}'**
  String preferenciasAvisosHasta(String hora);

  /// Título de la bandeja de avisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get bandejaTitulo;

  /// Anuncio al lector de pantalla mientras carga la bandeja.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus avisos'**
  String get bandejaCargando;

  /// Título de la bandeja vacía.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes avisos'**
  String get bandejaVacioTitulo;

  /// Mensaje de la bandeja vacía.
  ///
  /// In es, this message translates to:
  /// **'Aquí te vamos a decir cómo va tu auto en el taller, cuándo es tu cita y cuándo están listos tus documentos.'**
  String get bandejaVacioMensaje;

  /// Botón que marca toda la bandeja como leída.
  ///
  /// In es, this message translates to:
  /// **'Marcar todos como leídos'**
  String get bandejaMarcarTodos;

  /// Lo que el lector de pantalla dice antes de un aviso sin leer.
  ///
  /// In es, this message translates to:
  /// **'Sin leer'**
  String get bandejaSinLeerUno;

  /// Título del aviso cuando falla cargar otra página.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más avisos'**
  String get bandejaErrorMasTitulo;

  /// Explica que no se perdió lo cargado.
  ///
  /// In es, this message translates to:
  /// **'Lo que ya se cargó sigue aquí. Desliza hacia abajo para intentarlo otra vez.'**
  String get bandejaErrorMasMensaje;

  /// Fila del perfil que abre la bandeja.
  ///
  /// In es, this message translates to:
  /// **'Mis avisos'**
  String get accesoPerfilMisAvisos;

  /// Cuantos avisos sin leer hay en la cuenta.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 sin leer} other{{n} sin leer}}'**
  String bandejaSinLeer(int n);

  /// Título del aviso global cuando el servidor no contesta.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión con la agencia'**
  String get conexionSinRedTitulo;

  /// Explica que la app sigue sirviendo sin red y qué pasa con lo demás.
  ///
  /// In es, this message translates to:
  /// **'Puedes seguir viendo lo que ya tenías guardado. Lo que necesite internet lo intentamos otra vez cuando vuelva la señal.'**
  String get conexionSinRedMensaje;

  /// Explicación de una acción deshabilitada por falta de conexión.
  ///
  /// In es, this message translates to:
  /// **'Necesita internet. Lo intentamos cuando vuelva la señal.'**
  String get conexionAccionSinRed;

  /// Título de la pantalla que explica los avisos antes de pedir el permiso.
  ///
  /// In es, this message translates to:
  /// **'Para qué te avisamos'**
  String get avisosPermisoTitulo;

  /// Entrada de la pantalla previa al permiso de avisos.
  ///
  /// In es, this message translates to:
  /// **'Solo te escribimos cuando pasa algo con tu auto. Nada más.'**
  String get avisosPermisoExplicacion;

  /// Primer motivo por el que la app manda avisos.
  ///
  /// In es, this message translates to:
  /// **'Cómo va tu auto en el taller, paso a paso.'**
  String get avisosPermisoTaller;

  /// Segundo motivo por el que la app manda avisos.
  ///
  /// In es, this message translates to:
  /// **'Tu cita, recordada 24 y 2 horas antes.'**
  String get avisosPermisoCitas;

  /// Tercer motivo por el que la app manda avisos.
  ///
  /// In es, this message translates to:
  /// **'Cuando tu asesor te contesta o tus documentos ya están listos.'**
  String get avisosPermisoRespuestas;

  /// Promesa que cierra la pantalla previa al permiso.
  ///
  /// In es, this message translates to:
  /// **'No mandamos publicidad, y los puedes apagar cuando quieras.'**
  String get avisosPermisoSinPublicidad;

  /// Botón que acepta y dispara el diálogo del sistema.
  ///
  /// In es, this message translates to:
  /// **'Activar avisos'**
  String get avisosPermisoActivar;

  /// Botón que sale sin pedir el permiso al sistema.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get avisosPermisoAhoraNo;

  /// Confirmación cuando el sistema concede el permiso.
  ///
  /// In es, this message translates to:
  /// **'Listo, te vamos a avisar'**
  String get avisosPermisoListoTitulo;

  /// Detalle de la confirmación del permiso de avisos.
  ///
  /// In es, this message translates to:
  /// **'Puedes apagarlos cuando quieras desde tu perfil.'**
  String get avisosPermisoListoMensaje;

  /// Aviso cuando el permiso quedó negado.
  ///
  /// In es, this message translates to:
  /// **'Los avisos están apagados'**
  String get avisosPermisoNegadosTitulo;

  /// Explica por qué hay que ir a los ajustes del sistema para reactivar.
  ///
  /// In es, this message translates to:
  /// **'Tu teléfono ya no nos deja preguntarte otra vez, pero los puedes prender en los ajustes del sistema.'**
  String get avisosPermisoNegadosMensaje;

  /// Botón que lleva a la pantalla de ajustes de la app en el sistema.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get avisosPermisoAbrirAjustes;

  /// Fila del perfil que lleva a los avisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get accesoPerfilAvisos;

  /// Estado de la fila de avisos cuando el permiso está concedido.
  ///
  /// In es, this message translates to:
  /// **'Prendidos'**
  String get accesoPerfilAvisosPrendidos;

  /// Estado de la fila de avisos cuando el permiso está negado.
  ///
  /// In es, this message translates to:
  /// **'Apagados'**
  String get accesoPerfilAvisosApagados;

  /// Estado de la fila de avisos cuando nunca se preguntó.
  ///
  /// In es, this message translates to:
  /// **'Sin configurar'**
  String get accesoPerfilAvisosSinPreguntar;

  /// Nombre de la barra de navegación para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Navegación principal'**
  String get navegacionPrincipal;

  /// Segunda lámina de la bienvenida: las citas.
  ///
  /// In es, this message translates to:
  /// **'Elige el día y la hora que te queden bien, y reagenda o cancela desde aquí.'**
  String get bienvenidaDosTexto;

  /// Título de la segunda lámina.
  ///
  /// In es, this message translates to:
  /// **'Pide tu cita sin llamar'**
  String get bienvenidaDosTitulo;

  /// Botón de la última lámina de la bienvenida.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get bienvenidaEmpezar;

  /// Salida de la bienvenida, disponible desde la primera lámina.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get bienvenidaSaltar;

  /// Avanza a la siguiente lámina de la bienvenida.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get bienvenidaSiguiente;

  /// Tercera lámina de la bienvenida: el seguimiento y los avisos.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos cómo va tu auto en el taller y cuándo lo puedes recoger.'**
  String get bienvenidaTresTexto;

  /// Título de la tercera lámina.
  ///
  /// In es, this message translates to:
  /// **'Sigue tu servicio al día'**
  String get bienvenidaTresTitulo;

  /// Primera lámina de la bienvenida: los vehículos.
  ///
  /// In es, this message translates to:
  /// **'Consulta su historial de servicios, sus documentos y lo que sigue en su mantenimiento.'**
  String get bienvenidaUnoTexto;

  /// Título de la primera lámina.
  ///
  /// In es, this message translates to:
  /// **'Tus autos, en un solo lugar'**
  String get bienvenidaUnoTitulo;

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

  /// Etiqueta del interruptor de analitica.
  ///
  /// In es, this message translates to:
  /// **'Compartir analítica'**
  String get analiticaTitulo;

  /// Explica los datos opcionales de analitica.
  ///
  /// In es, this message translates to:
  /// **'Comparte métricas de uso y diagnóstico para mejorar CareCar.'**
  String get analiticaDescripcion;

  /// Error al guardar la preferencia de analitica.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la preferencia. Intenta de nuevo.'**
  String get analiticaError;

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

  /// Descripción bajo el título del detalle de un modelo del catálogo.
  ///
  /// In es, this message translates to:
  /// **'Conoce sus versiones, pide una prueba de manejo o cotiza.'**
  String get catalogoDetalleSubtitulo;

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

  /// Botón corto del estado vacío de los widgets de inicio.
  ///
  /// In es, this message translates to:
  /// **'Agendar'**
  String get widgetsAgendar;

  /// Encabezado del widget de inicio del taller.
  ///
  /// In es, this message translates to:
  /// **'Taller en vivo'**
  String get widgetsTallerEncabezado;

  /// Estado vacío del widget del taller.
  ///
  /// In es, this message translates to:
  /// **'Tu auto no está en el taller'**
  String get widgetsTallerVacioMensaje;

  /// Avance de etapas del widget del taller.
  ///
  /// In es, this message translates to:
  /// **'Paso {actual} de {total}'**
  String widgetsTallerPaso(int actual, int total);

  /// Encabezado del widget de inicio de mantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get widgetsMantenimientoTitulo;

  /// Kilómetros que faltan para el próximo servicio.
  ///
  /// In es, this message translates to:
  /// **'Faltan {km} km'**
  String widgetsMantenimientoFaltanKm(String km);

  /// El próximo servicio ya toca por km o por fecha.
  ///
  /// In es, this message translates to:
  /// **'Ya toca'**
  String get widgetsMantenimientoYaToca;

  /// Fecha estimada del próximo servicio.
  ///
  /// In es, this message translates to:
  /// **'Hacia el {fecha}'**
  String widgetsMantenimientoFecha(String fecha);

  /// Estado vacío del widget de mantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay un plan para tu auto'**
  String get widgetsMantenimientoVacioMensaje;

  /// Botón del estado vacío del widget de mantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Ver plan'**
  String get widgetsMantenimientoAccion;

  /// Encabezado del widget de inicio de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Bitácora'**
  String get widgetsBitacoraTitulo;

  /// Unidad del rendimiento en el widget de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'km/l'**
  String get widgetsBitacoraRendimientoUnidad;

  /// Etiqueta del gasto del mes en el widget de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Gasto de {mes}'**
  String widgetsBitacoraGastoMes(String mes);

  /// Etiqueta del rendimiento en el widget de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento'**
  String get widgetsBitacoraRendimientoEtiqueta;

  /// Estado vacío del widget de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Registra tu primera carga'**
  String get widgetsBitacoraVacioMensaje;

  /// Botón del estado vacío del widget de la bitácora.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get widgetsBitacoraAccion;

  /// Encabezado del widget de accesos rápidos.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get widgetsAccesosTitulo;

  /// Acceso rápido al comprobante de la próxima cita.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get widgetsAccesoComprobante;

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

  /// Nombre del botón que cierra la pantalla actual (X de los encabezados).
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get cerrarPantalla;

  /// Nombre accesible del botón que regresa a la pantalla anterior, o al inicio si no hay anterior.
  ///
  /// In es, this message translates to:
  /// **'Regresar'**
  String get regresar;

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

  /// Título del aviso cuando el certificado del servidor no valida (certificados fijados). No bloquea la app.
  ///
  /// In es, this message translates to:
  /// **'No pudimos verificar que la conexión sea segura'**
  String get seguridadConexionNoSeguraTitulo;

  /// Explica por qué se cortó la conexión y qué hacer: cambiar de red.
  ///
  /// In es, this message translates to:
  /// **'El certificado que presentó el servidor no es el que la app espera. Puede pasar en una red con filtros (WiFi público, escuela o trabajo). Prueba con datos móviles u otra red.'**
  String get seguridadConexionNoSeguraMensaje;

  /// Saludo del inicio antes del mediodía; va antes del nombre.
  ///
  /// In es, this message translates to:
  /// **'Buenos días,'**
  String get inicioSaludoManana;

  /// Saludo del inicio de las 12 a las 19 h; va antes del nombre.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes,'**
  String get inicioSaludoTarde;

  /// Saludo del inicio desde las 19 h; va antes del nombre.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches,'**
  String get inicioSaludoNoche;

  /// Saludo de la pantalla de inicio con el primer nombre del cliente.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombre}'**
  String inicioSaludo(String nombre);

  /// Rótulo de la tarjeta de la próxima cita en el inicio.
  ///
  /// In es, this message translates to:
  /// **'Próxima cita'**
  String get inicioProximaCita;

  /// Título de la tarjeta de citas cuando no hay ninguna.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas por venir'**
  String get inicioSinCitas;

  /// Detalle de la tarjeta de citas vacía; al tocarla se abre la agenda.
  ///
  /// In es, this message translates to:
  /// **'Agenda la próxima revisión de tu auto'**
  String get inicioSinCitasDetalle;

  /// Título de la tarjeta de autos cuando el cliente no tiene ninguno.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes autos registrados'**
  String get inicioSinAutos;

  /// Detalle de la tarjeta de autos vacía.
  ///
  /// In es, this message translates to:
  /// **'Cuando la agencia registre tu auto, lo verás aquí'**
  String get inicioSinAutosDetalle;

  /// Kilometraje del auto en el inicio.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String inicioKilometros(String km);

  /// Posición del auto en el carrusel del inicio, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Auto {n} de {total}'**
  String inicioAutoDeTotal(int n, int total);

  /// Día de la semana y hora de la próxima cita.
  ///
  /// In es, this message translates to:
  /// **'{dia}, {hora}'**
  String inicioCitaCuando(String dia, String hora);

  /// Botón flotante del inicio: la acción principal.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get inicioAgendarCita;

  /// Nombre del botón del avatar, arriba a la izquierda del inicio.
  ///
  /// In es, this message translates to:
  /// **'Perfil y ajustes'**
  String get inicioPerfilYAjustes;

  /// Destino de la barra inferior.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get inicioDestinoInicio;

  /// Destino de la barra inferior.
  ///
  /// In es, this message translates to:
  /// **'Garaje'**
  String get inicioDestinoVehiculos;

  /// Destino de la barra inferior.
  ///
  /// In es, this message translates to:
  /// **'Citas'**
  String get inicioDestinoCitas;

  /// Destino de la barra inferior.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get inicioDestinoCatalogo;

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

  /// Tarjeta de Inicio cuando la orden está lista para entrega (V2-M04.06).
  ///
  /// In es, this message translates to:
  /// **'Tu {vehiculo} está listo'**
  String tallerTarjetaListoTitulo(String vehiculo);

  /// Total de la orden lista en la tarjeta de Inicio.
  ///
  /// In es, this message translates to:
  /// **'Total a pagar {total}'**
  String tallerTarjetaListoTotal(String total);

  /// Horario para recoger el auto listo, en hora de la agencia.
  ///
  /// In es, this message translates to:
  /// **'Recógelo el {fecha} de {desde} a {hasta}'**
  String tallerHorarioEntrega(String fecha, String desde, String hasta);

  /// El taller no tiene horario cargado para recoger el auto.
  ///
  /// In es, this message translates to:
  /// **'Tu asesor te dirá cuándo recogerlo.'**
  String get tallerHorarioSinFranjas;

  /// Título del aviso de la orden lista para entrega (V2-M04.06).
  ///
  /// In es, this message translates to:
  /// **'Tu auto está listo'**
  String get tallerOrdenListoTitulo;

  /// Subtítulo de la fila con el total de la orden lista o entregada.
  ///
  /// In es, this message translates to:
  /// **'Total a pagar'**
  String get tallerOrdenTotalAPagar;

  /// Título del aviso de la orden entregada (V2-M04.07).
  ///
  /// In es, this message translates to:
  /// **'Ya recogiste tu auto'**
  String get tallerOrdenEntregadaTitulo;

  /// Mensaje del aviso de la orden entregada.
  ///
  /// In es, this message translates to:
  /// **'La orden quedó en el historial de tu vehículo con su ticket.'**
  String get tallerOrdenEntregadaMensaje;

  /// Fila que abre el ticket de la orden lista o entregada (V2-M04.07).
  ///
  /// In es, this message translates to:
  /// **'Ver ticket'**
  String get tallerOrdenVerTicket;

  /// Subtítulo de la fila que abre el ticket.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra y refacciones de la orden'**
  String get tallerOrdenVerTicketResumen;

  /// Fila que abre el historial del vehículo desde la orden entregada.
  ///
  /// In es, this message translates to:
  /// **'Ver historial del vehículo'**
  String get tallerOrdenVerHistorial;

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

  /// Píldora principal del detalle de un modelo (V2-M16.01).
  ///
  /// In es, this message translates to:
  /// **'Quiero probarlo'**
  String get estrenoQuieroProbarlo;

  /// Píldora de vidrio del detalle de un modelo (V2-M16.02).
  ///
  /// In es, this message translates to:
  /// **'Cotizar'**
  String get estrenoCotizar;

  /// Título de la pantalla y tipo de solicitud.
  ///
  /// In es, this message translates to:
  /// **'Prueba de manejo'**
  String get estrenoPruebaTitulo;

  /// Título de la pantalla y tipo de solicitud.
  ///
  /// In es, this message translates to:
  /// **'Cotización'**
  String get estrenoCotizacionTitulo;

  /// Título de la lista de solicitudes de estreno (V2-M16.04).
  ///
  /// In es, this message translates to:
  /// **'Mis solicitudes'**
  String get estrenoMisSolicitudes;

  /// Sección para elegir el día de la prueba.
  ///
  /// In es, this message translates to:
  /// **'¿Qué día?'**
  String get estrenoDia;

  /// Sección para elegir mañana o tarde.
  ///
  /// In es, this message translates to:
  /// **'¿A qué hora?'**
  String get estrenoFranja;

  /// Franja de la mañana.
  ///
  /// In es, this message translates to:
  /// **'Mañana (9 a 13 h)'**
  String get estrenoManana;

  /// Franja de la tarde.
  ///
  /// In es, this message translates to:
  /// **'Tarde (13 a 18 h)'**
  String get estrenoTarde;

  /// Sección para adjuntar una estimación de toma a cuenta (V2-M16.03).
  ///
  /// In es, this message translates to:
  /// **'¿Dejas tu auto a cuenta?'**
  String get estrenoTomaACuenta;

  /// Opción para no adjuntar estimación.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get estrenoSinTomaACuenta;

  /// Botón para pedir la prueba.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get estrenoEnviar;

  /// Botón para mandar la cotización a un asesor.
  ///
  /// In es, this message translates to:
  /// **'Enviar cotización'**
  String get estrenoEnviarCotizacion;

  /// Texto del botón mientras la solicitud viaja al servidor.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get estrenoEnviando;

  /// Se muestra en lugar de la mensualidad mientras el servidor la calcula.
  ///
  /// In es, this message translates to:
  /// **'Calculando tu mensualidad…'**
  String get estrenoCalculando;

  /// Confirmación al enviar.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Un asesor te contactará pronto.'**
  String get estrenoListo;

  /// Lleva a Mis solicitudes.
  ///
  /// In es, this message translates to:
  /// **'Ver mis solicitudes'**
  String get estrenoVerSolicitudes;

  /// 409 ESTRENO_DUPLICADA.
  ///
  /// In es, this message translates to:
  /// **'Ya pediste esto para este modelo; un asesor te contactará.'**
  String get estrenoDuplicada;

  /// 409 ESTRENO_SIN_PRECIO.
  ///
  /// In es, this message translates to:
  /// **'Este modelo aún no tiene precio publicado. Pregúntale a un asesor.'**
  String get estrenoSinPrecio;

  /// Sin conexión.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviarlo. Revisa tu internet y vuelve a intentar.'**
  String get estrenoSinConexion;

  /// Otro error.
  ///
  /// In es, this message translates to:
  /// **'Algo falló. Intenta más tarde.'**
  String get estrenoNoDisponible;

  /// Campo del enganche en pesos.
  ///
  /// In es, this message translates to:
  /// **'Enganche'**
  String get estrenoEnganche;

  /// Ayuda del enganche con el mínimo.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {minimo}'**
  String estrenoEngancheAyuda(String minimo);

  /// Sección de plazos.
  ///
  /// In es, this message translates to:
  /// **'Plazo'**
  String get estrenoPlazo;

  /// Un plazo.
  ///
  /// In es, this message translates to:
  /// **'{meses} meses'**
  String estrenoMeses(int meses);

  /// Etiqueta de la mensualidad.
  ///
  /// In es, this message translates to:
  /// **'Mensualidad estimada'**
  String get estrenoMensualidad;

  /// Precio del modelo.
  ///
  /// In es, this message translates to:
  /// **'Precio desde {precio}'**
  String estrenoPrecioDesde(String precio);

  /// Estado de una solicitud sin vendedor aún.
  ///
  /// In es, this message translates to:
  /// **'Recibida'**
  String get estrenoEstadoRecibida;

  /// Estado con vendedor asignado.
  ///
  /// In es, this message translates to:
  /// **'En atención'**
  String get estrenoEstadoEnAtencion;

  /// Estado cerrado.
  ///
  /// In es, this message translates to:
  /// **'Cerrada'**
  String get estrenoEstadoCerrada;

  /// Vendedor asignado.
  ///
  /// In es, this message translates to:
  /// **'Te atiende {nombre}'**
  String estrenoTeAtiende(String nombre);

  /// Lista vacía.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes solicitudes'**
  String get estrenoVacioTitulo;

  /// Lista vacía.
  ///
  /// In es, this message translates to:
  /// **'Desde el catálogo puedes pedir una prueba de manejo o cotizar un auto nuevo.'**
  String get estrenoVacioMensaje;

  /// Botón al final de Mis solicitudes para traer la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get estrenoVerMas;

  /// Texto del botón Ver más mientras llega la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get estrenoCargandoMas;

  /// Aviso cuando falla Ver más; la lista que ya se veía se conserva.
  ///
  /// In es, this message translates to:
  /// **'No pudimos traer más solicitudes. Intenta de nuevo.'**
  String get estrenoErrorMas;

  /// Lector de pantalla mientras carga.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus solicitudes'**
  String get estrenoCargando;

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

  /// Título de la pantalla del aviso de privacidad (V2-M22.01).
  ///
  /// In es, this message translates to:
  /// **'Aviso de privacidad'**
  String get privacidadTitulo;

  /// Etiqueta con el número de versión del aviso.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String privacidadVersion(int version);

  /// Desde cuándo rige la versión del aviso.
  ///
  /// In es, this message translates to:
  /// **'Vigente desde el {fecha}'**
  String privacidadVigenteDesde(String fecha);

  /// Cuándo aceptó la persona esta versión.
  ///
  /// In es, this message translates to:
  /// **'Lo aceptaste el {fecha}'**
  String privacidadAceptadoEl(String fecha);

  /// Lector de pantalla mientras carga el aviso.
  ///
  /// In es, this message translates to:
  /// **'Cargando el aviso de privacidad'**
  String get privacidadCargando;

  /// Encabezado de la puerta que pide aceptar el aviso.
  ///
  /// In es, this message translates to:
  /// **'Antes de continuar'**
  String get privacidadAntesDeContinuar;

  /// Explica por qué se pide aceptar el aviso.
  ///
  /// In es, this message translates to:
  /// **'Lee el aviso de privacidad. Para usar CareCar necesitas aceptarlo.'**
  String get privacidadIntro;

  /// Botón que registra la aceptación.
  ///
  /// In es, this message translates to:
  /// **'Acepto el aviso de privacidad'**
  String get privacidadAceptar;

  /// Texto del botón de aceptar mientras se registra.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get privacidadGuardando;

  /// Salida de la puerta para quien no acepta el aviso.
  ///
  /// In es, this message translates to:
  /// **'No acepto, cerrar sesión'**
  String get privacidadNoAcepto;

  /// Aviso cuando la agencia publica otra versión mientras se lee (409).
  ///
  /// In es, this message translates to:
  /// **'El aviso cambió mientras lo leías. Ya está el nuevo: léelo y acéptalo si estás de acuerdo.'**
  String get privacidadCambio;

  /// Fallo al registrar la aceptación.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu aceptación. Intenta de nuevo.'**
  String get privacidadErrorAceptar;

  /// Fallo de red al registrar la aceptación.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Conéctate para guardar tu aceptación.'**
  String get privacidadSinConexionAceptar;

  /// Título de la pantalla que reúne el aviso de privacidad y los derechos sobre los datos (V2-M22.02).
  ///
  /// In es, this message translates to:
  /// **'Privacidad y mis datos'**
  String get privacidadHubTitulo;

  /// Fila del aviso de privacidad en Privacidad y mis datos.
  ///
  /// In es, this message translates to:
  /// **'Aviso de privacidad'**
  String get privacidadHubAviso;

  /// Detalle de la fila del aviso de privacidad.
  ///
  /// In es, this message translates to:
  /// **'Qué hacemos con tus datos'**
  String get privacidadHubAvisoDetalle;

  /// Fila que abre la copia de los datos personales.
  ///
  /// In es, this message translates to:
  /// **'Descargar mis datos'**
  String get privacidadHubDatos;

  /// Detalle de la fila de descargar mis datos.
  ///
  /// In es, this message translates to:
  /// **'Una copia de tus datos personales'**
  String get privacidadHubDatosDetalle;

  /// Título de la pantalla para pedir y descargar la copia de los datos.
  ///
  /// In es, this message translates to:
  /// **'Mis datos'**
  String get arcoTitulo;

  /// Explica qué es la copia de los datos (acceso ARCO).
  ///
  /// In es, this message translates to:
  /// **'Puedes pedir una copia de los datos personales que CareCar guarda de tu cuenta. Es un archivo que podrás guardar o compartir.'**
  String get arcoIntro;

  /// Aclara lo que la copia no incluye.
  ///
  /// In es, this message translates to:
  /// **'No incluye lo fiscal y comercial que la agencia conserva por ley (ventas, pagos y facturas): pídelo en la agencia.'**
  String get arcoAlcance;

  /// Botón que pide la copia de los datos.
  ///
  /// In es, this message translates to:
  /// **'Pedir una copia de mis datos'**
  String get arcoPedir;

  /// Texto del botón mientras se pide la copia.
  ///
  /// In es, this message translates to:
  /// **'Pidiendo…'**
  String get arcoPidiendo;

  /// Título mientras la copia se prepara.
  ///
  /// In es, this message translates to:
  /// **'Estamos preparando tu archivo'**
  String get arcoPreparando;

  /// Detalle mientras la copia se prepara.
  ///
  /// In es, this message translates to:
  /// **'Tarda unos segundos. Puedes quedarte en esta pantalla.'**
  String get arcoPreparandoDetalle;

  /// Título cuando la copia ya se puede descargar.
  ///
  /// In es, this message translates to:
  /// **'Tu archivo está listo'**
  String get arcoLista;

  /// Hasta cuándo se puede descargar la copia.
  ///
  /// In es, this message translates to:
  /// **'Disponible hasta el {fecha}'**
  String arcoVence(String fecha);

  /// Recordatorio de cuidado del archivo descargado.
  ///
  /// In es, this message translates to:
  /// **'Contiene información personal: guárdalo en un lugar seguro y no lo compartas.'**
  String get arcoCuidado;

  /// Botón que abre la hoja de compartir con la copia.
  ///
  /// In es, this message translates to:
  /// **'Descargar mi archivo'**
  String get arcoDescargar;

  /// Texto del botón mientras se baja el archivo.
  ///
  /// In es, this message translates to:
  /// **'Preparando…'**
  String get arcoDescargando;

  /// Botón para pedir otra copia cuando ya hay una.
  ///
  /// In es, this message translates to:
  /// **'Pedir una copia nueva'**
  String get arcoPedirOtra;

  /// Aviso cuando la copia no se pudo preparar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos preparar tu archivo. Intenta de nuevo.'**
  String get arcoFallida;

  /// Aviso cuando la copia venció.
  ///
  /// In es, this message translates to:
  /// **'Tu archivo ya no está disponible. Pide una copia nueva.'**
  String get arcoVencida;

  /// Fallo al pedir la copia.
  ///
  /// In es, this message translates to:
  /// **'No pudimos pedir tu copia. Intenta de nuevo.'**
  String get arcoErrorPedir;

  /// Falta de conexión al pedir la copia.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Conéctate para pedir tu copia.'**
  String get arcoSinConexionPedir;

  /// Fallo al descargar la copia.
  ///
  /// In es, this message translates to:
  /// **'No pudimos descargar tu archivo. Intenta de nuevo.'**
  String get arcoErrorDescarga;

  /// Aviso cuando al descargar ya no estaba.
  ///
  /// In es, this message translates to:
  /// **'El archivo ya no está disponible. Pide una copia nueva.'**
  String get arcoArchivoNoDisponible;

  /// Lector de pantalla mientras carga.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus solicitudes'**
  String get arcoCargando;

  /// Fila del centro de privacidad que abre la cancelación de la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get privacidadHubEliminar;

  /// Detalle de la fila de eliminar mi cuenta.
  ///
  /// In es, this message translates to:
  /// **'Borra tu cuenta y tus datos personales'**
  String get privacidadHubEliminarDetalle;

  /// Título de la pantalla para eliminar la cuenta (cancelación ARCO).
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get eliminarCuentaTitulo;

  /// Título del aviso de peligro al eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'No se puede deshacer'**
  String get eliminarCuentaAdvertenciaTitulo;

  /// Mensaje del aviso de peligro al eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta se cierra de inmediato y no podremos recuperarla.'**
  String get eliminarCuentaAdvertencia;

  /// Encabezado de la lista de lo que se borra.
  ///
  /// In es, this message translates to:
  /// **'Qué se borra'**
  String get eliminarCuentaSeBorraTitulo;

  /// Primer elemento de lo que se borra.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre, correo y teléfono.'**
  String get eliminarCuentaBorra1;

  /// Segundo elemento de lo que se borra.
  ///
  /// In es, this message translates to:
  /// **'Tus direcciones, tus preguntas al asistente, tus cotizaciones y tus solicitudes de estreno.'**
  String get eliminarCuentaBorra2;

  /// Tercer elemento de lo que se borra.
  ///
  /// In es, this message translates to:
  /// **'Tu bitácora de gastos y kilometraje, con sus fotos y tickets.'**
  String get eliminarCuentaBorra3;

  /// Cuarto elemento de lo que se borra.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación y tus comentarios en las solicitudes de ayuda en carretera.'**
  String get eliminarCuentaBorra4;

  /// Encabezado de lo que se conserva.
  ///
  /// In es, this message translates to:
  /// **'Qué conservamos'**
  String get eliminarCuentaConservaTitulo;

  /// Explica lo que no se borra al eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Lo que debemos guardar por obligación fiscal, comercial o de garantía: el historial de servicio de tus vehículos, tus compras, pagos y facturas, y la constancia de que aceptaste el aviso de privacidad.'**
  String get eliminarCuentaConserva;

  /// Etiqueta del campo de contraseña al eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get eliminarCuentaContrasena;

  /// Ayuda del campo de contraseña al eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'La pedimos para confirmar que eres tú.'**
  String get eliminarCuentaContrasenaAyuda;

  /// Texto del control de deslizar que elimina la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Desliza para eliminar mi cuenta'**
  String get eliminarCuentaDeslizar;

  /// Mensaje del diálogo de confirmación cuando se usa lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Se borran tus datos personales y ya no podrás entrar con esta cuenta. No se puede deshacer.'**
  String get eliminarCuentaConfirmarMensaje;

  /// Mientras se elimina la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Eliminando tu cuenta…'**
  String get eliminarCuentaEliminando;

  /// Aviso al terminar de eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta se eliminó. Gracias por usar CareCar.'**
  String get eliminarCuentaListo;

  /// Error del campo cuando la contraseña es equivocada.
  ///
  /// In es, this message translates to:
  /// **'La contraseña no es correcta.'**
  String get eliminarCuentaContrasenaIncorrecta;

  /// Bloqueo por contraseñas equivocadas, con los minutos de espera.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Intenta de nuevo en {minutos, plural, =1{1 minuto} other{{minutos} minutos}}.'**
  String eliminarCuentaBloqueada(int minutos);

  /// Bloqueo por contraseñas equivocadas, sin tiempo conocido.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Intenta de nuevo más tarde.'**
  String get eliminarCuentaBloqueadaSinEspera;

  /// Sin red al eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e inténtalo de nuevo.'**
  String get eliminarCuentaSinConexion;

  /// Error genérico al eliminar la cuenta.
  ///
  /// In es, this message translates to:
  /// **'No pudimos eliminar tu cuenta. Inténtalo de nuevo.'**
  String get eliminarCuentaError;

  /// Título de la pantalla de llamadas rápidas.
  ///
  /// In es, this message translates to:
  /// **'Llamar ahora'**
  String get asistenciaLlamarTitulo;

  /// Explica las llamadas rápidas.
  ///
  /// In es, this message translates to:
  /// **'Un toque abre el marcador de tu teléfono con el número. Funciona aunque no tengas datos.'**
  String get asistenciaLlamarIntro;

  /// Encabezado de la lista de contactos.
  ///
  /// In es, this message translates to:
  /// **'A quién llamar'**
  String get asistenciaLlamarGrupo;

  /// Contacto: número de emergencias.
  ///
  /// In es, this message translates to:
  /// **'Emergencias'**
  String get asistenciaLlamarEmergencias;

  /// Detalle del contacto de emergencias.
  ///
  /// In es, this message translates to:
  /// **'911 · policía, ambulancia y bomberos'**
  String get asistenciaLlamarEmergenciasDetalle;

  /// Contacto: la agencia.
  ///
  /// In es, this message translates to:
  /// **'La agencia'**
  String get asistenciaLlamarAgencia;

  /// Contacto: la aseguradora del cliente.
  ///
  /// In es, this message translates to:
  /// **'Mi aseguradora'**
  String get asistenciaLlamarAseguradora;

  /// Detalle cuando no hay aseguradora.
  ///
  /// In es, this message translates to:
  /// **'Aún no registras tu aseguradora'**
  String get asistenciaLlamarAseguradoraFalta;

  /// Aviso que explica cómo agregar la aseguradora.
  ///
  /// In es, this message translates to:
  /// **'Aún no registras tu aseguradora. Agrégala en los documentos de tu auto (póliza) y aparecerá aquí para llamarla con un toque.'**
  String get asistenciaLlamarAseguradoraComoAgregar;

  /// Etiqueta de lector de pantalla del botón de llamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {contacto}'**
  String asistenciaLlamarAccion(String contacto);

  /// Error al abrir el marcador.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el marcador. Marca {numero} a mano.'**
  String asistenciaLlamarNoSePudo(String numero);

  /// Atajo a las llamadas rápidas desde otras pantallas.
  ///
  /// In es, this message translates to:
  /// **'Llamar a la agencia o al 911'**
  String get asistenciaLlamarAtajo;

  /// Botón del comprobante que guarda la cita en el calendario del teléfono.
  ///
  /// In es, this message translates to:
  /// **'Agregar al calendario'**
  String get citasCalendarioAgregar;

  /// Título del evento de calendario.
  ///
  /// In es, this message translates to:
  /// **'Cita en la agencia'**
  String get citasCalendarioTitulo;

  /// Descripción del evento de calendario.
  ///
  /// In es, this message translates to:
  /// **'Vehículo: {vehiculo}'**
  String citasCalendarioDescripcion(String vehiculo);

  /// Error al entregar el evento.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir tu calendario. Intenta de nuevo.'**
  String get citasCalendarioError;

  /// Aviso en vivo de V2-M05.05: el servicio está por tocar.
  ///
  /// In es, this message translates to:
  /// **'Tu próximo servicio ya se acerca. Puedes agendarlo cuando quieras.'**
  String get mantenimientoRecordatorioEnVivo;

  /// Cómo mover el pin del mapa.
  ///
  /// In es, this message translates to:
  /// **'Arrastra el pin, toca el mapa o usa las flechas.'**
  String get mapaAyudaPin;

  /// Nombre del mapa para el lector de pantalla cuando hay pin.
  ///
  /// In es, this message translates to:
  /// **'Mapa con un pin.'**
  String get mapaConPin;

  /// Se suma al nombre del mapa cuando dibuja tu ubicación.
  ///
  /// In es, this message translates to:
  /// **'Se muestra tu ubicación.'**
  String get mapaConUbicacion;

  /// Botón que muestra tu ubicación en el mapa.
  ///
  /// In es, this message translates to:
  /// **'Ver mi ubicación'**
  String get mapaMiUbicacion;

  /// Botón que mueve el pin sin arrastrar.
  ///
  /// In es, this message translates to:
  /// **'Mover el pin al este'**
  String get mapaMoverEste;

  /// Botón que mueve el pin sin arrastrar.
  ///
  /// In es, this message translates to:
  /// **'Mover el pin al norte'**
  String get mapaMoverNorte;

  /// Botón que mueve el pin sin arrastrar.
  ///
  /// In es, this message translates to:
  /// **'Mover el pin al oeste'**
  String get mapaMoverOeste;

  /// Botón que mueve el pin sin arrastrar.
  ///
  /// In es, this message translates to:
  /// **'Mover el pin al sur'**
  String get mapaMoverSur;

  /// Botón que pone el pin sin tocar el mapa.
  ///
  /// In es, this message translates to:
  /// **'Poner el pin en el centro'**
  String get mapaPinAlCentro;

  /// Anuncio del lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Pin movido al este'**
  String get mapaPinMovidoEste;

  /// Anuncio del lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Pin movido al norte'**
  String get mapaPinMovidoNorte;

  /// Anuncio del lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Pin movido al oeste'**
  String get mapaPinMovidoOeste;

  /// Anuncio del lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Pin movido al sur'**
  String get mapaPinMovidoSur;

  /// Botón que vuelve a pedir las imágenes del mapa.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get mapaReintentar;

  /// Nombre del mapa que solo sigue un marcador.
  ///
  /// In es, this message translates to:
  /// **'Mapa de seguimiento.'**
  String get mapaSeguimiento;

  /// Nombre del mapa para el lector de pantalla cuando no hay pin.
  ///
  /// In es, this message translates to:
  /// **'Mapa sin pin.'**
  String get mapaSinPin;

  /// Aviso cuando las imágenes del mapa no cargan.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el mapa. Revisa tu internet y vuelve a intentarlo.'**
  String get mapaSinTeselas;

  /// Aviso cuando el GPS está apagado.
  ///
  /// In es, this message translates to:
  /// **'La ubicación del teléfono está apagada. Enciéndela y vuelve a intentarlo.'**
  String get mapaUbicacionApagada;

  /// Aviso cuando el permiso ya no se puede pedir.
  ///
  /// In es, this message translates to:
  /// **'La ubicación está bloqueada. Actívala para CareCar en los ajustes del teléfono.'**
  String get mapaUbicacionBloqueada;

  /// Aviso cuando se niega el permiso de ubicación.
  ///
  /// In es, this message translates to:
  /// **'No nos diste permiso para ver tu ubicación. Puedes usar el mapa sin ella.'**
  String get mapaUbicacionDenegada;

  /// Aviso cuando la posición no llega a tiempo.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación tardó demasiado. Vuelve a intentarlo.'**
  String get mapaUbicacionTiempo;

  /// Título de la pantalla de garantía (V2-M10.01).
  ///
  /// In es, this message translates to:
  /// **'Garantía'**
  String get garantiaTitulo;

  /// Acceso a la garantía desde el detalle del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Garantía'**
  String get garantiaAcceso;

  /// Subtítulo con el km actual; km ya viene con separadores.
  ///
  /// In es, this message translates to:
  /// **'Tu auto lleva {km} km'**
  String garantiaKmActual(String km);

  /// Estado vacío de la garantía.
  ///
  /// In es, this message translates to:
  /// **'Sin garantía registrada'**
  String get garantiaVaciaTitulo;

  /// Mensaje del estado vacío de la garantía.
  ///
  /// In es, this message translates to:
  /// **'Cuando la agencia registre la garantía de tu auto la verás aquí.'**
  String get garantiaVaciaMensaje;

  /// Insignia de una cobertura vigente.
  ///
  /// In es, this message translates to:
  /// **'Vigente'**
  String get garantiaEstadoVigente;

  /// Insignia de una cobertura a 60 días o 1 000 km del límite.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get garantiaEstadoPorVencer;

  /// Insignia de una cobertura vencida.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get garantiaEstadoVencida;

  /// Fecha límite de una cobertura sin km límite.
  ///
  /// In es, this message translates to:
  /// **'Vence el {fecha}'**
  String garantiaVence(String fecha);

  /// Fecha y km límite de una cobertura; lo que llegue primero.
  ///
  /// In es, this message translates to:
  /// **'Vence el {fecha} o a los {km} km'**
  String garantiaVenceOKm(String fecha, String km);

  /// Días que le quedan a la cobertura.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =1{Queda 1 día} other{Quedan {dias} días}}'**
  String garantiaQuedanDias(int dias);

  /// Km que le quedan a la cobertura; km ya viene con separadores.
  ///
  /// In es, this message translates to:
  /// **'Quedan {km} km'**
  String garantiaQuedanKm(String km);

  /// Por qué venció la cobertura.
  ///
  /// In es, this message translates to:
  /// **'Venció por fecha'**
  String get garantiaVencidaPorFecha;

  /// Por qué venció la cobertura.
  ///
  /// In es, this message translates to:
  /// **'Venció por kilometraje'**
  String get garantiaVencidaPorKm;

  /// Título corto de la pantalla de campañas de seguridad (V2-M10.02).
  ///
  /// In es, this message translates to:
  /// **'Campañas'**
  String get campanasTitulo;

  /// Acceso a las campañas desde el detalle del vehículo y la garantía.
  ///
  /// In es, this message translates to:
  /// **'Campañas de seguridad'**
  String get campanasAcceso;

  /// Subtítulo del acceso a las campañas desde la garantía.
  ///
  /// In es, this message translates to:
  /// **'Llamados del fabricante para tu auto'**
  String get campanasAccesoResumen;

  /// Insignia del garaje cuando el auto tiene una campaña pendiente.
  ///
  /// In es, this message translates to:
  /// **'Campaña de seguridad'**
  String get campanasInsignia;

  /// Estado vacío de las campañas.
  ///
  /// In es, this message translates to:
  /// **'Tu auto no tiene campañas'**
  String get campanasVaciaTitulo;

  /// Mensaje del estado vacío de las campañas.
  ///
  /// In es, this message translates to:
  /// **'Si el fabricante publica una para tu auto, te avisamos.'**
  String get campanasVaciaMensaje;

  /// Código de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Campaña {codigo}'**
  String campanasCodigo(String codigo);

  /// Gravedad de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Gravedad baja'**
  String get campanasGravedadBaja;

  /// Gravedad de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Gravedad media'**
  String get campanasGravedadMedia;

  /// Gravedad de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Gravedad alta'**
  String get campanasGravedadAlta;

  /// Gravedad de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Crítica'**
  String get campanasGravedadCritica;

  /// Estado de la campaña: abierta, sin agendar.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get campanasEstadoAbierta;

  /// Estado de la campaña: con cita.
  ///
  /// In es, this message translates to:
  /// **'Agendada'**
  String get campanasEstadoAgendada;

  /// Estado de la campaña: el taller ya la atendió.
  ///
  /// In es, this message translates to:
  /// **'Atendida'**
  String get campanasEstadoAtendida;

  /// Encabezado de lo que debe hacer el cliente.
  ///
  /// In es, this message translates to:
  /// **'Qué hacer'**
  String get campanasQueHacer;

  /// Aviso de una campaña crítica pendiente.
  ///
  /// In es, this message translates to:
  /// **'Atiende esta campaña cuanto antes'**
  String get campanasAvisoCritica;

  /// Botón para agendar la atención de la campaña (V2-M10.03).
  ///
  /// In es, this message translates to:
  /// **'Agendar atención'**
  String get campanasAgendar;

  /// Botón para reintentar en garantía y campañas.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get garantiaReintentar;

  /// Ayuda mientras no hay día elegido.
  ///
  /// In es, this message translates to:
  /// **'Elige un día para ver sus horarios.'**
  String get campanasAgendarSinDia;

  /// El día elegido ya no tiene horarios con cupo.
  ///
  /// In es, this message translates to:
  /// **'No quedan horarios ese día.'**
  String get campanasAgendarSinHorarios;

  /// Ningún día del rango tiene cupo.
  ///
  /// In es, this message translates to:
  /// **'El taller no tiene horarios libres por ahora. Intenta más tarde.'**
  String get campanasAgendarSinCupoRango;

  /// Botón para volver a la campaña tras agendar.
  ///
  /// In es, this message translates to:
  /// **'Volver a la campaña'**
  String get campanasAgendarVolver;

  /// Botón de una campaña ya agendada.
  ///
  /// In es, this message translates to:
  /// **'Ver mis citas'**
  String get campanasVerCitas;

  /// Título de la pantalla para agendar una campaña.
  ///
  /// In es, this message translates to:
  /// **'Agendar campaña'**
  String get campanasAgendarTitulo;

  /// Encabezado del calendario.
  ///
  /// In es, this message translates to:
  /// **'Elige el día'**
  String get campanasAgendarDia;

  /// Encabezado de los horarios del día.
  ///
  /// In es, this message translates to:
  /// **'Elige la hora'**
  String get campanasAgendarHora;

  /// Botón que confirma la cita de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Agendar'**
  String get campanasAgendarConfirmar;

  /// El horario elegido ya no tiene cupo.
  ///
  /// In es, this message translates to:
  /// **'Ese horario se llenó. Elige otro.'**
  String get campanasAgendarSinCupo;

  /// El vehículo ya tiene cita ese día.
  ///
  /// In es, this message translates to:
  /// **'Tu auto ya tiene una cita ese día. Elige otro día.'**
  String get campanasAgendarDuplicada;

  /// La campaña ya tenía cita o ya se atendió.
  ///
  /// In es, this message translates to:
  /// **'Esta campaña ya está agendada.'**
  String get campanasAgendarYaAgendada;

  /// Error al agendar la campaña.
  ///
  /// In es, this message translates to:
  /// **'No pudimos agendar. Intenta de nuevo.'**
  String get campanasAgendarError;

  /// Confirmación de la cita de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Listo, tu cita quedó agendada'**
  String get campanasAgendadaTitulo;

  /// Día y hora de la cita de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Te esperamos el {fecha} a las {hora}.'**
  String campanasAgendadaMensaje(String fecha, String hora);

  /// Título de la sección con la descripción de la campaña.
  ///
  /// In es, this message translates to:
  /// **'Qué pasa'**
  String get campanasQuePasa;

  /// Estado cuando la campaña abierta ya no aparece en la lista del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Ya no encontramos esta campaña'**
  String get campanasNoEncontradaTitulo;

  /// Mensaje del estado de campaña no encontrada.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a la lista para ver las campañas de tu auto.'**
  String get campanasNoEncontradaMensaje;

  /// Abre el comprobante con QR de la cita.
  ///
  /// In es, this message translates to:
  /// **'Ver comprobante'**
  String get campanasVerComprobante;

  /// Acción que abre la búsqueda dentro del manual.
  ///
  /// In es, this message translates to:
  /// **'Buscar en el manual'**
  String get vehiculosManualBuscarAccion;

  /// Acción que cierra la búsqueda.
  ///
  /// In es, this message translates to:
  /// **'Cerrar la búsqueda'**
  String get vehiculosManualBuscarCerrar;

  /// Texto guía del campo de búsqueda.
  ///
  /// In es, this message translates to:
  /// **'Buscar en el manual'**
  String get vehiculosManualBuscarSugerencia;

  /// Guía cuando la búsqueda es muy corta.
  ///
  /// In es, this message translates to:
  /// **'Escribe al menos dos letras para buscar en el manual.'**
  String get vehiculosManualBuscarAyuda;

  /// Sin coincidencias.
  ///
  /// In es, this message translates to:
  /// **'No encontramos «{consulta}» en el manual.'**
  String vehiculosManualSinResultados(String consulta);

  /// Título de un resultado de búsqueda.
  ///
  /// In es, this message translates to:
  /// **'Página {pagina}'**
  String vehiculosManualResultadoPagina(int pagina);

  /// Texto del control deslizable que acepta la oferta (V2-M26.04).
  ///
  /// In es, this message translates to:
  /// **'Aceptar oferta'**
  String get valuacionAceptar;

  /// Confirmación accesible antes de aceptar la oferta.
  ///
  /// In es, this message translates to:
  /// **'Vas a aceptar la oferta de {monto}. La agencia registra tu decisión.'**
  String valuacionAceptarMensaje(String monto);

  /// Cierre al agendar la inspección (V2-M26.03).
  ///
  /// In es, this message translates to:
  /// **'Te esperamos el {dia} a las {hora} para revisar tu auto.'**
  String valuacionAgendadaMensaje(String dia, String hora);

  /// Título del cierre al agendar la inspección.
  ///
  /// In es, this message translates to:
  /// **'Inspección agendada'**
  String get valuacionAgendadaTitulo;

  /// Acción principal del cierre al agendar.
  ///
  /// In es, this message translates to:
  /// **'Ver mis citas'**
  String get valuacionAgendadaVerCitas;

  /// Acción secundaria del cierre al agendar.
  ///
  /// In es, this message translates to:
  /// **'Volver a la valuación'**
  String get valuacionAgendadaVolver;

  /// Botón y título para agendar la inspección física.
  ///
  /// In es, this message translates to:
  /// **'Agendar inspección'**
  String get valuacionAgendar;

  /// Botón que crea la cita de inspección.
  ///
  /// In es, this message translates to:
  /// **'Confirmar inspección'**
  String get valuacionAgendarConfirmar;

  /// Sección del calendario.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get valuacionAgendarDia;

  /// Rechazo CITA_DUPLICADA.
  ///
  /// In es, this message translates to:
  /// **'Este auto ya tiene una cita ese día. Elige otro día.'**
  String get valuacionAgendarDuplicada;

  /// Fallo genérico al agendar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos agendar la inspección. Intenta de nuevo.'**
  String get valuacionAgendarError;

  /// Sección de franjas horarias.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get valuacionAgendarHorario;

  /// Rechazo VALUACION_NO_AGENDABLE.
  ///
  /// In es, this message translates to:
  /// **'Esta valuación ya tiene cita o ya no se puede agendar. Revisa su detalle.'**
  String get valuacionAgendarNoAgendable;

  /// Rechazo FRANJA_SIN_CUPO.
  ///
  /// In es, this message translates to:
  /// **'Ese horario se acaba de llenar. Elige otro.'**
  String get valuacionAgendarSinCupo;

  /// Ayuda mientras no hay día elegido.
  ///
  /// In es, this message translates to:
  /// **'Elige un día para ver sus horarios.'**
  String get valuacionAgendarSinDia;

  /// El día elegido ya no tiene cupo.
  ///
  /// In es, this message translates to:
  /// **'No quedan horarios ese día.'**
  String get valuacionAgendarSinHorarios;

  /// Ningún día del rango tiene cupo.
  ///
  /// In es, this message translates to:
  /// **'El taller no tiene horarios libres por ahora. Intenta más tarde.'**
  String get valuacionAgendarVacioMensaje;

  /// Título cuando no hay cupo en todo el rango.
  ///
  /// In es, this message translates to:
  /// **'Sin horarios disponibles'**
  String get valuacionAgendarVacioTitulo;

  /// Detalle bajo el nombre del asesor.
  ///
  /// In es, this message translates to:
  /// **'Tu asesor de ventas para esta valuación'**
  String get valuacionAsesorDetalle;

  /// Sección del asesor.
  ///
  /// In es, this message translates to:
  /// **'Tu asesor'**
  String get valuacionAsesorTitulo;

  /// Sección de los tres pasos.
  ///
  /// In es, this message translates to:
  /// **'Avance'**
  String get valuacionAvanceTitulo;

  /// Anuncio del esqueleto de carga.
  ///
  /// In es, this message translates to:
  /// **'Cargando la valuación'**
  String get valuacionCargando;

  /// Título del detalle de una valuación.
  ///
  /// In es, this message translates to:
  /// **'Valuación formal'**
  String get valuacionDetalleTitulo;

  /// Mensaje del error de carga.
  ///
  /// In es, this message translates to:
  /// **'Intenta de nuevo en un momento.'**
  String get valuacionErrorMensaje;

  /// Título del error de carga.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar esto'**
  String get valuacionErrorTitulo;

  /// Estado ACEPTADA.
  ///
  /// In es, this message translates to:
  /// **'Aceptada'**
  String get valuacionEstadoAceptada;

  /// Estado CITA_AGENDADA.
  ///
  /// In es, this message translates to:
  /// **'Inspección agendada'**
  String get valuacionEstadoCitaAgendada;

  /// Estado que la app aún no conoce.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get valuacionEstadoDesconocido;

  /// Estado OFERTADA.
  ///
  /// In es, this message translates to:
  /// **'Con oferta'**
  String get valuacionEstadoOfertada;

  /// Estado RECHAZADA.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get valuacionEstadoRechazada;

  /// Estado SOLICITADA.
  ///
  /// In es, this message translates to:
  /// **'Por agendar'**
  String get valuacionEstadoSolicitada;

  /// Estado VENCIDA.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get valuacionEstadoVencida;

  /// Fecha de la estimación de la que sale la valuación.
  ///
  /// In es, this message translates to:
  /// **'Estimado el {fecha}'**
  String valuacionEstimadaEl(String fecha);

  /// Etiqueta de la cifra del rango.
  ///
  /// In es, this message translates to:
  /// **'Rango estimado'**
  String get valuacionEstimadoRango;

  /// Sección del rango no vinculante.
  ///
  /// In es, this message translates to:
  /// **'Estimación de partida'**
  String get valuacionEstimadoTitulo;

  /// Fallo genérico al subir una toma (V2-M26.02).
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir. La foto sigue aquí.'**
  String get valuacionFotoError;

  /// Botón para elegir una foto guardada.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get valuacionFotoGaleria;

  /// El servidor rechazó el archivo (400).
  ///
  /// In es, this message translates to:
  /// **'La agencia no aceptó esa imagen. Usa una foto JPEG o PNG de hasta 8 MB.'**
  String get valuacionFotoInvalida;

  /// Descripción de una foto que aún no se sube.
  ///
  /// In es, this message translates to:
  /// **'Foto por subir: {toma}'**
  String valuacionFotoPorSubir(String toma);

  /// Fallo de red al subir una toma.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. La foto sigue aquí.'**
  String get valuacionFotoSinConexion;

  /// Descripción de una foto ya subida.
  ///
  /// In es, this message translates to:
  /// **'Foto subida: {toma}'**
  String valuacionFotoSubida(String toma);

  /// Anuncio mientras sube una toma.
  ///
  /// In es, this message translates to:
  /// **'Subiendo la foto'**
  String get valuacionFotoSubiendo;

  /// Botón para abrir la cámara.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get valuacionFotoTomar;

  /// Botón para dar el permiso de cámara o fotos.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get valuacionFotosAbrirAjustes;

  /// Avance de las tomas guiadas.
  ///
  /// In es, this message translates to:
  /// **'{subidas} de {total} fotos'**
  String valuacionFotosAvance(int subidas, int total);

  /// Valuación cerrada (VALUACION_CERRADA).
  ///
  /// In es, this message translates to:
  /// **'Esta valuación ya no admite fotos.'**
  String get valuacionFotosCerrada;

  /// Título de la pantalla de las 8 tomas.
  ///
  /// In es, this message translates to:
  /// **'Fotos guiadas'**
  String get valuacionFotosGuiadasTitulo;

  /// Aviso sobre las fotos.
  ///
  /// In es, this message translates to:
  /// **'Puedes agendar sin tener las 8 fotos. Cada foto se sube sola y la app no la guarda en tu teléfono.'**
  String get valuacionFotosPrivacidad;

  /// El selector de fotos falló.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir la cámara o la galería. Intenta de nuevo.'**
  String get valuacionFotosSinCamara;

  /// Permiso negado.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso para la cámara o las fotos. Actívalo en los ajustes.'**
  String get valuacionFotosSinPermiso;

  /// Botón del detalle hacia las fotos.
  ///
  /// In es, this message translates to:
  /// **'Subir fotos guiadas'**
  String get valuacionFotosSubir;

  /// Sección de fotos del detalle.
  ///
  /// In es, this message translates to:
  /// **'Fotos de tu auto'**
  String get valuacionFotosTitulo;

  /// Galería sin fotos.
  ///
  /// In es, this message translates to:
  /// **'Aún no subes fotos.'**
  String get valuacionFotosVacio;

  /// Horario de la cita de inspección.
  ///
  /// In es, this message translates to:
  /// **'De {inicio} a {fin}'**
  String valuacionInspeccionHorario(String inicio, String fin);

  /// Sección de la cita.
  ///
  /// In es, this message translates to:
  /// **'Inspección'**
  String get valuacionInspeccionTitulo;

  /// Botón hacia Mis citas.
  ///
  /// In es, this message translates to:
  /// **'Ver en Mis citas'**
  String get valuacionInspeccionVerCitas;

  /// Instrucción de la toma de la cajuela.
  ///
  /// In es, this message translates to:
  /// **'Abre la cajuela y toma todo el espacio de carga.'**
  String get valuacionInstruccionCajuela;

  /// Instrucción de la toma de frente.
  ///
  /// In es, this message translates to:
  /// **'Párate de frente, con el auto completo y las placas a la vista.'**
  String get valuacionInstruccionFrente;

  /// Instrucción del interior delantero.
  ///
  /// In es, this message translates to:
  /// **'Abre la puerta del conductor y toma los asientos delanteros y el volante.'**
  String get valuacionInstruccionInteriorDelantero;

  /// Instrucción del interior trasero.
  ///
  /// In es, this message translates to:
  /// **'Abre una puerta trasera y toma el asiento completo.'**
  String get valuacionInstruccionInteriorTrasero;

  /// Instrucción del lateral derecho.
  ///
  /// In es, this message translates to:
  /// **'Toma el costado del lado del pasajero, de defensa a defensa.'**
  String get valuacionInstruccionLateralDerecho;

  /// Instrucción del lateral izquierdo.
  ///
  /// In es, this message translates to:
  /// **'Toma el costado del lado del conductor, de defensa a defensa.'**
  String get valuacionInstruccionLateralIzquierdo;

  /// Instrucción del tablero.
  ///
  /// In es, this message translates to:
  /// **'Enciende el tablero y toma el kilometraje de cerca, sin reflejos.'**
  String get valuacionInstruccionTableroKm;

  /// Instrucción de la toma trasera.
  ///
  /// In es, this message translates to:
  /// **'Párate detrás, con el auto completo y las placas a la vista.'**
  String get valuacionInstruccionTrasera;

  /// Kilometraje del auto.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String valuacionKm(String km);

  /// Falló la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más valuaciones. Intenta de nuevo.'**
  String get valuacionMisErrorMas;

  /// Título de la lista de valuaciones.
  ///
  /// In es, this message translates to:
  /// **'Mis valuaciones'**
  String get valuacionMisTitulo;

  /// Acción del vacío de Mis valuaciones.
  ///
  /// In es, this message translates to:
  /// **'Ir a Mis estimaciones'**
  String get valuacionMisVacioAccion;

  /// Mensaje del vacío.
  ///
  /// In es, this message translates to:
  /// **'Pide una valuación formal desde una estimación hecha con uno de tus autos.'**
  String get valuacionMisVacioMensaje;

  /// Título del vacío.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes valuaciones'**
  String get valuacionMisVacioTitulo;

  /// Botón de la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get valuacionMisVerMas;

  /// Mensaje de valuación no encontrada.
  ///
  /// In es, this message translates to:
  /// **'Puede que ya no exista o que no sea de tu cuenta.'**
  String get valuacionNoEncontradaMensaje;

  /// Título de valuación no encontrada.
  ///
  /// In es, this message translates to:
  /// **'No encontramos esa valuación'**
  String get valuacionNoEncontradaTitulo;

  /// Oferta aceptada.
  ///
  /// In es, this message translates to:
  /// **'Aceptaste esta oferta. La agencia te dará seguimiento.'**
  String get valuacionOfertaAceptada;

  /// Oferta en la tarjeta de la lista.
  ///
  /// In es, this message translates to:
  /// **'Oferta de {monto}, vigente hasta el {fecha}'**
  String valuacionOfertaConVigencia(String monto, String fecha);

  /// Etiqueta del monto ofertado.
  ///
  /// In es, this message translates to:
  /// **'Oferta formal de la agencia'**
  String get valuacionOfertaEtiqueta;

  /// Oferta rechazada.
  ///
  /// In es, this message translates to:
  /// **'Rechazaste esta oferta.'**
  String get valuacionOfertaRechazada;

  /// Sección de la oferta.
  ///
  /// In es, this message translates to:
  /// **'Tu oferta'**
  String get valuacionOfertaTitulo;

  /// Oferta vencida.
  ///
  /// In es, this message translates to:
  /// **'Vencida. Ya no se puede responder, pero la agencia puede renovarla.'**
  String get valuacionOfertaVencida;

  /// Vigencia de la oferta.
  ///
  /// In es, this message translates to:
  /// **'Vigente hasta el {fecha}'**
  String valuacionOfertaVigencia(String fecha);

  /// Primer paso del avance.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get valuacionPasoFotos;

  /// Segundo paso del avance.
  ///
  /// In es, this message translates to:
  /// **'Inspección'**
  String get valuacionPasoInspeccion;

  /// Tercer paso del avance.
  ///
  /// In es, this message translates to:
  /// **'Oferta'**
  String get valuacionPasoOferta;

  /// Fecha en que se pidió la valuación.
  ///
  /// In es, this message translates to:
  /// **'Pedida el {fecha}'**
  String valuacionPedidaEl(String fecha);

  /// Botón en la calculadora y en el detalle de una estimación (V2-M26.01).
  ///
  /// In es, this message translates to:
  /// **'Pedir valuación formal'**
  String get valuacionPedir;

  /// Fallo genérico al pedirla.
  ///
  /// In es, this message translates to:
  /// **'No pudimos pedir la valuación. Intenta de nuevo.'**
  String get valuacionPedirError;

  /// La estimación no existe o es ajena (404).
  ///
  /// In es, this message translates to:
  /// **'No encontramos esa estimación.'**
  String get valuacionPedirNoEncontrada;

  /// Rechazo VALUACION_SIN_VEHICULO.
  ///
  /// In es, this message translates to:
  /// **'Esta estimación se hizo capturando el auto a mano. Para valuarlo, pide la valuación en la agencia.'**
  String get valuacionPedirSinVehiculo;

  /// Botón para rechazar la oferta.
  ///
  /// In es, this message translates to:
  /// **'Rechazar oferta'**
  String get valuacionRechazar;

  /// Cierra el diálogo sin rechazar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get valuacionRechazarCancelar;

  /// Confirma el rechazo.
  ///
  /// In es, this message translates to:
  /// **'Sí, rechazar'**
  String get valuacionRechazarConfirmar;

  /// Mensaje del diálogo de rechazo.
  ///
  /// In es, this message translates to:
  /// **'Vas a rechazar la oferta de {monto}. No se puede deshacer.'**
  String valuacionRechazarMensaje(String monto);

  /// Título del diálogo de rechazo.
  ///
  /// In es, this message translates to:
  /// **'¿Rechazar la oferta?'**
  String get valuacionRechazarTitulo;

  /// Botón para reintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get valuacionReintentar;

  /// Fallo genérico al responder.
  ///
  /// In es, this message translates to:
  /// **'No pudimos registrar tu respuesta. Intenta de nuevo.'**
  String get valuacionRespuestaError;

  /// Rechazo OFERTA_NO_DISPONIBLE.
  ///
  /// In es, this message translates to:
  /// **'La oferta cambió y no se registró nada. Revisa la información actual.'**
  String get valuacionRespuestaNoDisponible;

  /// Rechazo OFERTA_VENCIDA.
  ///
  /// In es, this message translates to:
  /// **'La oferta venció y no se registró tu respuesta.'**
  String get valuacionRespuestaVencida;

  /// Una acción falló por falta de red.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e intenta de nuevo.'**
  String get valuacionSinConexionAccion;

  /// Mensaje del estado sin conexión.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu internet e intenta de nuevo.'**
  String get valuacionSinConexionMensaje;

  /// Título del estado sin conexión.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get valuacionSinConexionTitulo;

  /// Nombre de la toma CAJUELA.
  ///
  /// In es, this message translates to:
  /// **'Cajuela'**
  String get valuacionTomaCajuela;

  /// Nombre de la toma FRENTE.
  ///
  /// In es, this message translates to:
  /// **'Frente'**
  String get valuacionTomaFrente;

  /// Nombre de la toma INTERIOR_DELANTERO.
  ///
  /// In es, this message translates to:
  /// **'Interior delantero'**
  String get valuacionTomaInteriorDelantero;

  /// Nombre de la toma INTERIOR_TRASERO.
  ///
  /// In es, this message translates to:
  /// **'Interior trasero'**
  String get valuacionTomaInteriorTrasero;

  /// Nombre de la toma LATERAL_DERECHO.
  ///
  /// In es, this message translates to:
  /// **'Lateral derecho'**
  String get valuacionTomaLateralDerecho;

  /// Nombre de la toma LATERAL_IZQUIERDO.
  ///
  /// In es, this message translates to:
  /// **'Lateral izquierdo'**
  String get valuacionTomaLateralIzquierdo;

  /// Título de la tarjeta de una toma.
  ///
  /// In es, this message translates to:
  /// **'{numero}. {toma}'**
  String valuacionTomaNumero(int numero, String toma);

  /// Nombre de la toma TABLERO_KM.
  ///
  /// In es, this message translates to:
  /// **'Tablero con el kilometraje'**
  String get valuacionTomaTableroKm;

  /// Nombre de la toma TRASERA.
  ///
  /// In es, this message translates to:
  /// **'Trasera'**
  String get valuacionTomaTrasera;

  /// Título de la gráfica (V2-M26.05).
  ///
  /// In es, this message translates to:
  /// **'Valor estimado medio por mes'**
  String get valuacionValorGrafica;

  /// Etiqueta cuando solo hay un mes.
  ///
  /// In es, this message translates to:
  /// **'Valor estimado medio'**
  String get valuacionValorMedio;

  /// Vehículo no encontrado.
  ///
  /// In es, this message translates to:
  /// **'Puede que ya no esté en tu garaje.'**
  String get valuacionValorNoEncontradoMensaje;

  /// Título de vehículo no encontrado.
  ///
  /// In es, this message translates to:
  /// **'No encontramos ese auto'**
  String get valuacionValorNoEncontradoTitulo;

  /// Rango y kilometraje de un mes.
  ///
  /// In es, this message translates to:
  /// **'{rango}, con {km} km'**
  String valuacionValorRangoDelMes(String rango, String km);

  /// Encabezado de la lista de rangos.
  ///
  /// In es, this message translates to:
  /// **'Rango de cada mes'**
  String get valuacionValorRangos;

  /// Título de la pantalla del valor en el tiempo.
  ///
  /// In es, this message translates to:
  /// **'Valor de mi auto'**
  String get valuacionValorTitulo;

  /// Explicación con un solo mes.
  ///
  /// In es, this message translates to:
  /// **'La tendencia aparece cuando estimes tu auto en otros meses.'**
  String get valuacionValorUnMes;

  /// Acción del vacío del valor.
  ///
  /// In es, this message translates to:
  /// **'Ir a la calculadora'**
  String get valuacionValorVacioAccion;

  /// Mensaje del vacío del valor.
  ///
  /// In es, this message translates to:
  /// **'Estima este auto con la calculadora para ver cómo cambia su valor.'**
  String get valuacionValorVacioMensaje;

  /// Título del vacío del valor.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay estimaciones de este auto'**
  String get valuacionValorVacioTitulo;

  /// Botón hacia el valor en el tiempo.
  ///
  /// In es, this message translates to:
  /// **'Ver cómo cambia el valor'**
  String get valuacionVerValor;

  /// Aviso del ticket con los puntos que dio la orden (V2-M12.02); puntos ya viene con separadores.
  ///
  /// In es, this message translates to:
  /// **'Ganaste {puntos} puntos de lealtad con este servicio.'**
  String historialTicketPuntosGanados(String puntos);

  /// Título de la pantalla de lealtad (V2-M12.01).
  ///
  /// In es, this message translates to:
  /// **'Mis puntos'**
  String get lealtadTitulo;

  /// Subtítulo de Mis puntos.
  ///
  /// In es, this message translates to:
  /// **'Gana puntos en cada servicio y canjéalos en la agencia.'**
  String get lealtadSubtitulo;

  /// Saldo de puntos; puntos ya viene con separadores.
  ///
  /// In es, this message translates to:
  /// **'{puntos} puntos'**
  String lealtadPuntos(String puntos);

  /// Nivel del cliente; nivel es Bronce, Plata u Oro.
  ///
  /// In es, this message translates to:
  /// **'Nivel {nivel}'**
  String lealtadNivel(String nivel);

  /// Nombre del nivel Bronce.
  ///
  /// In es, this message translates to:
  /// **'Bronce'**
  String get lealtadNivelBronce;

  /// Nombre del nivel Plata.
  ///
  /// In es, this message translates to:
  /// **'Plata'**
  String get lealtadNivelPlata;

  /// Nombre del nivel Oro.
  ///
  /// In es, this message translates to:
  /// **'Oro'**
  String get lealtadNivelOro;

  /// Lo que falta para el siguiente nivel.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {puntos} puntos para {nivel}'**
  String lealtadFaltan(String puntos, String nivel);

  /// Detalle en el nivel Oro.
  ///
  /// In es, this message translates to:
  /// **'Ya estás en el nivel más alto.'**
  String get lealtadNivelMaximo;

  /// Etiqueta de la barra de avance; puntos ya viene con separadores.
  ///
  /// In es, this message translates to:
  /// **'{puntos} ganados en 12 meses'**
  String lealtadGanados(String puntos);

  /// Esqueleto de carga de las pantallas de lealtad para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus puntos'**
  String get lealtadCargando;

  /// Botón para volver a pedir los datos de lealtad.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get lealtadReintentar;

  /// Acceso al catálogo de recompensas.
  ///
  /// In es, this message translates to:
  /// **'Recompensas'**
  String get lealtadRecompensas;

  /// Subtítulo del acceso a recompensas.
  ///
  /// In es, this message translates to:
  /// **'Canjea tus puntos'**
  String get lealtadRecompensasResumen;

  /// Acceso a mis canjes.
  ///
  /// In es, this message translates to:
  /// **'Mis canjes'**
  String get lealtadCanjes;

  /// Subtítulo del acceso a mis canjes.
  ///
  /// In es, this message translates to:
  /// **'Códigos para usar en la agencia'**
  String get lealtadCanjesResumen;

  /// Acceso a los movimientos de puntos.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get lealtadMovimientos;

  /// Subtítulo del acceso a movimientos.
  ///
  /// In es, this message translates to:
  /// **'De dónde salen tus puntos'**
  String get lealtadMovimientosResumen;

  /// Acceso a referir.
  ///
  /// In es, this message translates to:
  /// **'Referir a un amigo'**
  String get lealtadReferir;

  /// Subtítulo del acceso a referir.
  ///
  /// In es, this message translates to:
  /// **'Gana puntos si tu amigo compra su auto'**
  String get lealtadReferirResumen;

  /// Título del catálogo de recompensas (V2-M12.03).
  ///
  /// In es, this message translates to:
  /// **'Recompensas'**
  String get recompensasTitulo;

  /// Subtítulo del catálogo con el saldo.
  ///
  /// In es, this message translates to:
  /// **'Tienes {puntos} puntos'**
  String recompensasSaldo(String puntos);

  /// Estado vacío del catálogo.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay recompensas'**
  String get recompensasVaciaTitulo;

  /// Mensaje del catálogo vacío.
  ///
  /// In es, this message translates to:
  /// **'Cuando la agencia publique recompensas las verás aquí.'**
  String get recompensasVaciaMensaje;

  /// Costo de una recompensa.
  ///
  /// In es, this message translates to:
  /// **'{puntos} puntos'**
  String recompensasCosto(String puntos);

  /// Insignia de una recompensa que no alcanza.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {puntos}'**
  String recompensasTeFaltan(String puntos);

  /// Insignia de una recompensa sin existencia.
  ///
  /// In es, this message translates to:
  /// **'Agotada'**
  String get recompensasAgotada;

  /// Insignia de una recompensa que se puede canjear.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get recompensasDisponible;

  /// Título de la confirmación del canje.
  ///
  /// In es, this message translates to:
  /// **'¿Canjear {recompensa}?'**
  String recompensasConfirmarTitulo(String recompensa);

  /// Mensaje de la confirmación con el costo y el saldo que queda.
  ///
  /// In es, this message translates to:
  /// **'Cuesta {costo} puntos. Te quedarán {quedan}.'**
  String recompensasConfirmarMensaje(String costo, String quedan);

  /// Botón que confirma el canje.
  ///
  /// In es, this message translates to:
  /// **'Canjear'**
  String get recompensasConfirmar;

  /// Botón que cancela el canje.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get recompensasCancelar;

  /// Título del diálogo de error al canjear.
  ///
  /// In es, this message translates to:
  /// **'No se pudo canjear'**
  String get recompensasNoSePudoTitulo;

  /// Error SALDO_INSUFICIENTE.
  ///
  /// In es, this message translates to:
  /// **'Ya no te alcanzan los puntos para esta recompensa.'**
  String get recompensasSinSaldo;

  /// Error RECOMPENSA_AGOTADA.
  ///
  /// In es, this message translates to:
  /// **'Esta recompensa se acaba de agotar.'**
  String get recompensasSeAgoto;

  /// Error genérico al canjear.
  ///
  /// In es, this message translates to:
  /// **'No pudimos canjear la recompensa. Intenta de nuevo.'**
  String get recompensasError;

  /// Cierra el diálogo de error.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get recompensasEntendido;

  /// Título de mis canjes (V2-M12.03).
  ///
  /// In es, this message translates to:
  /// **'Mis canjes'**
  String get canjesTitulo;

  /// Estado vacío de mis canjes.
  ///
  /// In es, this message translates to:
  /// **'Aún no canjeas nada'**
  String get canjesVaciaTitulo;

  /// Mensaje de mis canjes vacío.
  ///
  /// In es, this message translates to:
  /// **'Cambia tus puntos por recompensas y aquí tendrás su código.'**
  String get canjesVaciaMensaje;

  /// Acción del estado vacío de mis canjes.
  ///
  /// In es, this message translates to:
  /// **'Ver recompensas'**
  String get canjesVerRecompensas;

  /// Código del canje.
  ///
  /// In es, this message translates to:
  /// **'Código {codigo}'**
  String canjesCodigo(String codigo);

  /// Vigencia de un canje vigente.
  ///
  /// In es, this message translates to:
  /// **'Vence el {fecha}'**
  String canjesVence(String fecha);

  /// Fecha de uso de un canje.
  ///
  /// In es, this message translates to:
  /// **'Usado el {fecha}'**
  String canjesUsado(String fecha);

  /// Detalle de un canje vencido.
  ///
  /// In es, this message translates to:
  /// **'Venció el {fecha}; tus puntos regresaron'**
  String canjesVencio(String fecha);

  /// Estado de canje vigente.
  ///
  /// In es, this message translates to:
  /// **'Vigente'**
  String get canjesEstadoVigente;

  /// Estado de canje usado.
  ///
  /// In es, this message translates to:
  /// **'Usado'**
  String get canjesEstadoUsado;

  /// Estado de canje vencido.
  ///
  /// In es, this message translates to:
  /// **'Vencido'**
  String get canjesEstadoVencido;

  /// Indicación bajo el QR de un canje vigente.
  ///
  /// In es, this message translates to:
  /// **'Muestra este código en caja o en servicio para usar tu recompensa.'**
  String get canjeMuestralo;

  /// Descripción del QR para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Código QR del canje {codigo}'**
  String canjeQr(String codigo);

  /// Aviso de un canje usado.
  ///
  /// In es, this message translates to:
  /// **'Este canje ya se usó.'**
  String get canjeYaUsado;

  /// Aviso de un canje vencido.
  ///
  /// In es, this message translates to:
  /// **'Este canje venció sin usarse y tus puntos regresaron a tu saldo.'**
  String get canjeYaVencio;

  /// Encabezado de los detalles del canje.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get canjeDetalles;

  /// Fila del costo del canje.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get canjeCosto;

  /// Fila de la fecha del canje.
  ///
  /// In es, this message translates to:
  /// **'Canjeado'**
  String get canjeCanjeado;

  /// Fila de la vigencia del canje.
  ///
  /// In es, this message translates to:
  /// **'Vigencia'**
  String get canjeVigencia;

  /// Fila de la fecha de uso del canje.
  ///
  /// In es, this message translates to:
  /// **'Usado'**
  String get canjeUsadoEl;

  /// Estado cuando el canje no aparece en la lista.
  ///
  /// In es, this message translates to:
  /// **'Ya no encontramos este canje'**
  String get canjeNoEncontradoTitulo;

  /// Mensaje del canje no encontrado.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a Mis canjes para ver tus códigos.'**
  String get canjeNoEncontradoMensaje;

  /// Título de los movimientos de puntos (V2-M12.05).
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get movimientosTitulo;

  /// Estado vacío de los movimientos.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes movimientos'**
  String get movimientosVaciaTitulo;

  /// Mensaje de movimientos vacío.
  ///
  /// In es, this message translates to:
  /// **'Ganas puntos cada vez que recoges tu auto del taller.'**
  String get movimientosVaciaMensaje;

  /// Motivo SERVICIO.
  ///
  /// In es, this message translates to:
  /// **'Servicio en el taller'**
  String get movimientosMotivoServicio;

  /// Motivo CANJE.
  ///
  /// In es, this message translates to:
  /// **'Canje de recompensa'**
  String get movimientosMotivoCanje;

  /// Motivo DEVOLUCION_CANJE.
  ///
  /// In es, this message translates to:
  /// **'Canje vencido'**
  String get movimientosMotivoDevolucion;

  /// Motivo REFERIDO.
  ///
  /// In es, this message translates to:
  /// **'Amigo referido'**
  String get movimientosMotivoReferido;

  /// Motivo AJUSTE.
  ///
  /// In es, this message translates to:
  /// **'Ajuste de la agencia'**
  String get movimientosMotivoAjuste;

  /// Motivo que la app no conoce.
  ///
  /// In es, this message translates to:
  /// **'Movimiento'**
  String get movimientosMotivoOtro;

  /// Referencia a una orden de servicio.
  ///
  /// In es, this message translates to:
  /// **'Orden {id}'**
  String movimientosOrden(int id);

  /// Referencia a un canje.
  ///
  /// In es, this message translates to:
  /// **'Canje {id}'**
  String movimientosCanje(int id);

  /// Fecha y a qué se refiere un movimiento.
  ///
  /// In es, this message translates to:
  /// **'{fecha} · {referencia}'**
  String movimientosFechaYReferencia(String fecha, String referencia);

  /// Lectura de un movimiento positivo.
  ///
  /// In es, this message translates to:
  /// **'Ganaste {puntos} puntos'**
  String movimientosGanaste(String puntos);

  /// Lectura de un movimiento negativo.
  ///
  /// In es, this message translates to:
  /// **'Usaste {puntos} puntos'**
  String movimientosUsaste(String puntos);

  /// Indicador al pedir la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'Cargando más movimientos'**
  String get movimientosCargandoMas;

  /// Error al pedir la siguiente página.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más movimientos.'**
  String get movimientosErrorMas;

  /// Título de referir (V2-M12.04).
  ///
  /// In es, this message translates to:
  /// **'Referir a un amigo'**
  String get referirTitulo;

  /// Subtítulo de referir.
  ///
  /// In es, this message translates to:
  /// **'Si tu amigo compra su auto, ganas puntos.'**
  String get referirSubtitulo;

  /// Sección con el código personal.
  ///
  /// In es, this message translates to:
  /// **'Tu código'**
  String get referirCodigoTitulo;

  /// Ayuda bajo el código personal.
  ///
  /// In es, this message translates to:
  /// **'Tu amigo lo menciona al visitar la agencia.'**
  String get referirCodigoAyuda;

  /// Botón que comparte el código con la hoja del sistema.
  ///
  /// In es, this message translates to:
  /// **'Compartir mi código'**
  String get referirCompartir;

  /// Texto que se comparte con el código.
  ///
  /// In es, this message translates to:
  /// **'Te recomiendo la agencia. Menciona mi código {codigo} cuando vayas.'**
  String referirMensaje(String codigo);

  /// Sección del formulario de referido.
  ///
  /// In es, this message translates to:
  /// **'Registra a tu amigo'**
  String get referirFormularioTitulo;

  /// Nota bajo el formulario.
  ///
  /// In es, this message translates to:
  /// **'Escribe su teléfono, su correo o los dos. La agencia solo los usa para contactarlo.'**
  String get referirFormularioNota;

  /// Campo de nombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre de tu amigo'**
  String get referirNombre;

  /// Campo de teléfono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get referirTelefono;

  /// Ayuda del campo de teléfono.
  ///
  /// In es, this message translates to:
  /// **'10 dígitos'**
  String get referirTelefonoAyuda;

  /// Error de teléfono incompleto.
  ///
  /// In es, this message translates to:
  /// **'Escribe los 10 dígitos.'**
  String get referirTelefonoInvalido;

  /// Campo de correo.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get referirCorreo;

  /// Error de correo inválido.
  ///
  /// In es, this message translates to:
  /// **'Revisa el correo.'**
  String get referirCorreoInvalido;

  /// Casilla de consentimiento.
  ///
  /// In es, this message translates to:
  /// **'Mi amigo aceptó que la agencia lo contacte'**
  String get referirConsentimiento;

  /// Botón que registra al amigo.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get referirEnviar;

  /// Aviso tras registrar al amigo.
  ///
  /// In es, this message translates to:
  /// **'Listo, la agencia contactará a {nombre}.'**
  String referirEnviado(String nombre);

  /// Error REFERIDO_DUPLICADO; no dice de quién.
  ///
  /// In es, this message translates to:
  /// **'Esa persona ya está con la agencia.'**
  String get referirDuplicado;

  /// Error LIMITE_REFERIDOS.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes el máximo de amigos en seguimiento. Espera a que la agencia los atienda.'**
  String get referirLimite;

  /// Error genérico al referir.
  ///
  /// In es, this message translates to:
  /// **'No pudimos registrar a tu amigo. Intenta de nuevo.'**
  String get referirError;

  /// Sección con mis referidos.
  ///
  /// In es, this message translates to:
  /// **'Tus referidos'**
  String get referirListaTitulo;

  /// Lista de referidos vacía.
  ///
  /// In es, this message translates to:
  /// **'Aún no refieres a nadie.'**
  String get referirVacio;

  /// Error al pedir los referidos.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus referidos.'**
  String get referirListaError;

  /// Nota bajo la lista de referidos.
  ///
  /// In es, this message translates to:
  /// **'Ganas puntos una sola vez por cada amigo que compre.'**
  String get referirPuntosAyuda;

  /// Estado REGISTRADO.
  ///
  /// In es, this message translates to:
  /// **'Registrado'**
  String get referidoEstadoRegistrado;

  /// Estado EN_SEGUIMIENTO.
  ///
  /// In es, this message translates to:
  /// **'En seguimiento'**
  String get referidoEstadoSeguimiento;

  /// Estado COMPRO.
  ///
  /// In es, this message translates to:
  /// **'Compró'**
  String get referidoEstadoCompro;

  /// Estado DESCARTADO.
  ///
  /// In es, this message translates to:
  /// **'Sin compra'**
  String get referidoEstadoDescartado;

  /// Estado y fecha de un referido.
  ///
  /// In es, this message translates to:
  /// **'{estado} · desde el {fecha}'**
  String referidoDesde(String estado, String fecha);

  /// Puntos ganados por un referido que compró.
  ///
  /// In es, this message translates to:
  /// **'+{puntos}'**
  String referidoGanaste(String puntos);

  /// Título del estado de error de carga (EstadoError) cuando la pantalla no dice otro.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar esto'**
  String get estadoErrorTitulo;

  /// Mensaje del estado de error de carga (EstadoError) cuando la pantalla no dice otro.
  ///
  /// In es, this message translates to:
  /// **'Intenta de nuevo en un momento.'**
  String get estadoErrorMensaje;

  /// Título del estado de error de carga cuando el teléfono no tiene conexión.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get estadoErrorSinConexionTitulo;

  /// Mensaje del estado de error de carga cuando el teléfono no tiene conexión.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu internet e intenta de nuevo.'**
  String get estadoErrorSinConexionMensaje;

  /// Botón que vuelve a pedir lo que no cargó (estado de error de carga).
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get estadoErrorReintentar;

  /// Día de la semana y horario de la próxima cita en «Mis citas».
  ///
  /// In es, this message translates to:
  /// **'{dia}, {inicio} - {fin}'**
  String citasMisCitasCuando(String dia, String inicio, String fin);

  /// Vehículo y motivo de la próxima cita en «Mis citas».
  ///
  /// In es, this message translates to:
  /// **'{vehiculo} · {motivo}'**
  String citasMisCitasVehiculoYMotivo(String vehiculo, String motivo);

  /// Título de mis datos fiscales (V2-M08.05).
  ///
  /// In es, this message translates to:
  /// **'Datos fiscales'**
  String get datosFiscalesTitulo;

  /// Subtítulo de mis datos fiscales.
  ///
  /// In es, this message translates to:
  /// **'Para facturar tus servicios'**
  String get datosFiscalesSubtitulo;

  /// Esqueleto de carga para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Cargando tus datos fiscales'**
  String get datosFiscalesCargando;

  /// Botón para volver a pedir los datos fiscales.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get datosFiscalesReintentar;

  /// Estado vacío de mis datos fiscales.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes datos fiscales'**
  String get datosFiscalesVacioTitulo;

  /// Mensaje del estado vacío.
  ///
  /// In es, this message translates to:
  /// **'Agrégalos para pedir factura de tus servicios.'**
  String get datosFiscalesVacioMensaje;

  /// Botón para dar de alta un perfil fiscal.
  ///
  /// In es, this message translates to:
  /// **'Agregar datos fiscales'**
  String get datosFiscalesAgregar;

  /// Encabezado de la lista de perfiles.
  ///
  /// In es, this message translates to:
  /// **'Tus perfiles'**
  String get datosFiscalesEncabezado;

  /// Pie de la lista: cómo capturarlos y que la facturación es simulada (ADR 0009).
  ///
  /// In es, this message translates to:
  /// **'Escríbelos como en tu constancia de situación fiscal. Por ahora las facturas de la app son simuladas, sin validez fiscal.'**
  String get datosFiscalesPie;

  /// RFC, tipo de persona y régimen de un perfil.
  ///
  /// In es, this message translates to:
  /// **'{rfc} · {persona} · Régimen {regimen}'**
  String datosFiscalesFilaSubtitulo(String rfc, String persona, String regimen);

  /// Insignia del perfil predeterminado.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado'**
  String get datosFiscalesPredeterminado;

  /// Título del alta.
  ///
  /// In es, this message translates to:
  /// **'Nuevos datos fiscales'**
  String get datosFiscalesNuevoTitulo;

  /// Título de la edición.
  ///
  /// In es, this message translates to:
  /// **'Editar datos fiscales'**
  String get datosFiscalesEditarTitulo;

  /// Sección con RFC, nombre y código postal.
  ///
  /// In es, this message translates to:
  /// **'Contribuyente'**
  String get datosFiscalesSeccionContribuyente;

  /// Sección con régimen, uso de CFDI y correo.
  ///
  /// In es, this message translates to:
  /// **'Para facturar'**
  String get datosFiscalesSeccionFacturar;

  /// Campo del RFC.
  ///
  /// In es, this message translates to:
  /// **'RFC'**
  String get datosFiscalesRfc;

  /// Ejemplo de RFC dentro del campo.
  ///
  /// In es, this message translates to:
  /// **'GODE561231GR8'**
  String get datosFiscalesRfcSugerencia;

  /// Ayuda del RFC mientras no se sabe el tipo de persona.
  ///
  /// In es, this message translates to:
  /// **'13 caracteres si eres persona física; 12 si es una empresa.'**
  String get datosFiscalesRfcAyuda;

  /// Tipo de persona física.
  ///
  /// In es, this message translates to:
  /// **'Persona física'**
  String get datosFiscalesPersonaFisica;

  /// Tipo de persona moral.
  ///
  /// In es, this message translates to:
  /// **'Persona moral'**
  String get datosFiscalesPersonaMoral;

  /// Campo de la razón social.
  ///
  /// In es, this message translates to:
  /// **'Nombre o razón social'**
  String get datosFiscalesRazonSocial;

  /// Ayuda de la razón social para CFDI 4.0.
  ///
  /// In es, this message translates to:
  /// **'Igual que en tu constancia, sin el régimen societario (S.A. de C.V.).'**
  String get datosFiscalesRazonSocialAyuda;

  /// Campo del código postal.
  ///
  /// In es, this message translates to:
  /// **'Código postal fiscal'**
  String get datosFiscalesCodigoPostal;

  /// Ayuda del código postal.
  ///
  /// In es, this message translates to:
  /// **'El de tu domicilio fiscal.'**
  String get datosFiscalesCodigoPostalAyuda;

  /// Selector del régimen.
  ///
  /// In es, this message translates to:
  /// **'Régimen fiscal'**
  String get datosFiscalesRegimen;

  /// Texto del selector de régimen vacío.
  ///
  /// In es, this message translates to:
  /// **'Elige tu régimen'**
  String get datosFiscalesRegimenSugerencia;

  /// Selector del uso de CFDI.
  ///
  /// In es, this message translates to:
  /// **'Uso del CFDI'**
  String get datosFiscalesUso;

  /// Texto del selector de uso vacío.
  ///
  /// In es, this message translates to:
  /// **'Elige el uso'**
  String get datosFiscalesUsoSugerencia;

  /// Ayuda del uso de CFDI.
  ///
  /// In es, this message translates to:
  /// **'Solo aparecen los que acepta tu régimen.'**
  String get datosFiscalesUsoAyuda;

  /// Opción de un catálogo del SAT con su clave.
  ///
  /// In es, this message translates to:
  /// **'{clave} · {descripcion}'**
  String datosFiscalesOpcion(String clave, String descripcion);

  /// Campo del correo.
  ///
  /// In es, this message translates to:
  /// **'Correo para la factura (opcional)'**
  String get datosFiscalesCorreo;

  /// Casilla para volverlo el predeterminado.
  ///
  /// In es, this message translates to:
  /// **'Usar como predeterminado'**
  String get datosFiscalesHacerPredeterminado;

  /// Descripción de la casilla.
  ///
  /// In es, this message translates to:
  /// **'Es el que se propone al pagar.'**
  String get datosFiscalesHacerPredeterminadoAyuda;

  /// Botón que guarda el perfil.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get datosFiscalesGuardar;

  /// Botón que borra el perfil.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get datosFiscalesBorrar;

  /// Título de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar estos datos fiscales?'**
  String get datosFiscalesBorrarTitulo;

  /// Mensaje de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'Se borra el perfil {rfc}. Las facturas que ya tengas no cambian.'**
  String datosFiscalesBorrarMensaje(String rfc);

  /// Confirma el borrado.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get datosFiscalesBorrarConfirmar;

  /// Cancela el borrado.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get datosFiscalesBorrarCancelar;

  /// Aviso cuando hay campos con error.
  ///
  /// In es, this message translates to:
  /// **'Revisa los campos marcados.'**
  String get datosFiscalesRevisa;

  /// Aviso sin conexión al guardar o borrar.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e intenta de nuevo.'**
  String get datosFiscalesSinConexion;

  /// Error genérico al guardar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tus datos fiscales. Intenta de nuevo.'**
  String get datosFiscalesErrorGuardar;

  /// Error genérico al borrar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos borrar estos datos fiscales. Intenta de nuevo.'**
  String get datosFiscalesErrorBorrar;

  /// Estado cuando el perfil no aparece.
  ///
  /// In es, this message translates to:
  /// **'Ya no encontramos estos datos fiscales'**
  String get datosFiscalesNoEncontradoTitulo;

  /// Mensaje del perfil no encontrado.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a Datos fiscales para ver tus perfiles.'**
  String get datosFiscalesNoEncontradoMensaje;

  /// Error: RFC vacío.
  ///
  /// In es, this message translates to:
  /// **'Escribe el RFC.'**
  String get datosFiscalesErrorRfcVacio;

  /// Error: largo del RFC.
  ///
  /// In es, this message translates to:
  /// **'El RFC tiene 12 caracteres (persona moral) o 13 (persona física).'**
  String get datosFiscalesErrorRfcLargo;

  /// Error: forma del RFC.
  ///
  /// In es, this message translates to:
  /// **'El RFC no tiene la forma del SAT.'**
  String get datosFiscalesErrorRfcForma;

  /// Error: RFC genérico.
  ///
  /// In es, this message translates to:
  /// **'El RFC genérico no se usa en un perfil.'**
  String get datosFiscalesErrorRfcGenerico;

  /// Error: fecha del RFC.
  ///
  /// In es, this message translates to:
  /// **'La fecha del RFC no existe.'**
  String get datosFiscalesErrorRfcFecha;

  /// Error: dígito verificador del RFC.
  ///
  /// In es, this message translates to:
  /// **'El último carácter no coincide; revisa la homoclave.'**
  String get datosFiscalesErrorRfcDigito;

  /// Error: razón social vacía.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre o la razón social.'**
  String get datosFiscalesErrorRazonVacia;

  /// Error: razón social larga.
  ///
  /// In es, this message translates to:
  /// **'El nombre es demasiado largo.'**
  String get datosFiscalesErrorRazonLarga;

  /// Error: código postal.
  ///
  /// In es, this message translates to:
  /// **'Escribe los 5 dígitos.'**
  String get datosFiscalesErrorCodigoPostal;

  /// Error: falta el régimen.
  ///
  /// In es, this message translates to:
  /// **'Elige tu régimen fiscal.'**
  String get datosFiscalesErrorRegimenFalta;

  /// Error: régimen de otra persona.
  ///
  /// In es, this message translates to:
  /// **'Ese régimen no aplica a tu tipo de persona.'**
  String get datosFiscalesErrorRegimenNoAplica;

  /// Error: falta el uso.
  ///
  /// In es, this message translates to:
  /// **'Elige el uso del CFDI.'**
  String get datosFiscalesErrorUsoFalta;

  /// Error: uso de otra persona.
  ///
  /// In es, this message translates to:
  /// **'Ese uso no aplica a tu tipo de persona.'**
  String get datosFiscalesErrorUsoNoAplica;

  /// Error: uso que el régimen no acepta.
  ///
  /// In es, this message translates to:
  /// **'Ese uso no se puede con tu régimen.'**
  String get datosFiscalesErrorUsoNoAceptaRegimen;

  /// Error: correo.
  ///
  /// In es, this message translates to:
  /// **'Revisa el correo.'**
  String get datosFiscalesErrorCorreo;

  /// Esqueleto de carga de pagos para el lector de pantalla (V2-M08).
  ///
  /// In es, this message translates to:
  /// **'Cargando tus pagos'**
  String get pagosCargando;

  /// Botón para volver a pedir los pagos.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get pagosReintentar;

  /// Aviso fijo de la pantalla de pago (ADR 0009).
  ///
  /// In es, this message translates to:
  /// **'Pago simulado: no se cobra nada. Usa una de las tarjetas de prueba.'**
  String get pagosSimuladoAviso;

  /// Pie de mis pagos (ADR 0009).
  ///
  /// In es, this message translates to:
  /// **'Los pagos de la app son simulados: no se cobró nada.'**
  String get pagosSimuladoPie;

  /// Aviso del detalle de un pago simulado.
  ///
  /// In es, this message translates to:
  /// **'Pago simulado: no se cobró nada.'**
  String get pagosSimuladoCorto;

  /// Aviso del detalle de un pago en caja.
  ///
  /// In es, this message translates to:
  /// **'Se pagó en la caja de la agencia.'**
  String get pagosEnCaja;

  /// Título de la pantalla para pagar una orden (V2-M08.02).
  ///
  /// In es, this message translates to:
  /// **'Pagar orden'**
  String get pagosPagarTitulo;

  /// Número de la orden de servicio.
  ///
  /// In es, this message translates to:
  /// **'Orden {orden}'**
  String pagosOrden(String orden);

  /// Encabezado del desglose del ticket.
  ///
  /// In es, this message translates to:
  /// **'Lo que pagas'**
  String get pagosDesglose;

  /// Renglón del desglose.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra'**
  String get pagosManoDeObra;

  /// Renglón del desglose.
  ///
  /// In es, this message translates to:
  /// **'Refacciones'**
  String get pagosRefacciones;

  /// Renglón del desglose.
  ///
  /// In es, this message translates to:
  /// **'Subtotal sin IVA'**
  String get pagosSubtotal;

  /// Renglón del desglose.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get pagosIva;

  /// Renglón del desglose.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get pagosTotal;

  /// Pie del desglose.
  ///
  /// In es, this message translates to:
  /// **'Los precios incluyen IVA.'**
  String get pagosPreciosConIva;

  /// Sección para elegir la tarjeta.
  ///
  /// In es, this message translates to:
  /// **'Con qué pagas'**
  String get pagosConQue;

  /// Selector de tarjeta guardada.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get pagosTarjeta;

  /// Opción para escribir una tarjeta nueva.
  ///
  /// In es, this message translates to:
  /// **'Otra tarjeta'**
  String get pagosOtraTarjeta;

  /// Tarjeta guardada que ya venció en el selector.
  ///
  /// In es, this message translates to:
  /// **'{tarjeta} (vencida)'**
  String pagosTarjetaVencida(String tarjeta);

  /// Campo del número de tarjeta.
  ///
  /// In es, this message translates to:
  /// **'Número de tarjeta'**
  String get pagosNumero;

  /// Ejemplo dentro del campo del número.
  ///
  /// In es, this message translates to:
  /// **'4242 4242 4242 4242'**
  String get pagosNumeroSugerencia;

  /// Campo del vencimiento.
  ///
  /// In es, this message translates to:
  /// **'Vence (MM/AA)'**
  String get pagosVencimiento;

  /// Ejemplo dentro del campo del vencimiento.
  ///
  /// In es, this message translates to:
  /// **'12/28'**
  String get pagosVencimientoSugerencia;

  /// Campo del código de seguridad.
  ///
  /// In es, this message translates to:
  /// **'CVV'**
  String get pagosCvv;

  /// Ayuda bajo los campos de la tarjeta.
  ///
  /// In es, this message translates to:
  /// **'El número y el CVV no salen de tu teléfono: solo se envía un token de la tarjeta de prueba.'**
  String get pagosCvvAyuda;

  /// Casilla para guardar la tarjeta (V2-M08.04).
  ///
  /// In es, this message translates to:
  /// **'Guardar tarjeta'**
  String get pagosGuardarTarjeta;

  /// Descripción de la casilla para guardar la tarjeta.
  ///
  /// In es, this message translates to:
  /// **'Para pagar más rápido. Solo se guardan la marca, los últimos 4 y el vencimiento.'**
  String get pagosGuardarTarjetaAyuda;

  /// Encabezado de la lista de tarjetas de prueba.
  ///
  /// In es, this message translates to:
  /// **'Tarjetas de prueba'**
  String get pagosTarjetasDePrueba;

  /// Pie de la lista de tarjetas de prueba.
  ///
  /// In es, this message translates to:
  /// **'Toca una para escribir su número. Sirve cualquier vencimiento futuro y cualquier CVV de 3 dígitos.'**
  String get pagosTarjetasDePruebaPie;

  /// Marca y qué hace el banco simulado con la tarjeta de prueba.
  ///
  /// In es, this message translates to:
  /// **'{marca} · {escenario}'**
  String pagosTarjetaDePruebaDetalle(String marca, String escenario);

  /// Tarjeta de prueba aprobada.
  ///
  /// In es, this message translates to:
  /// **'Se aprueba'**
  String get pagosEscenarioAprobada;

  /// Tarjeta de prueba rechazada.
  ///
  /// In es, this message translates to:
  /// **'Se rechaza por fondos insuficientes'**
  String get pagosEscenarioFondos;

  /// Tarjeta de prueba con 3-D Secure.
  ///
  /// In es, this message translates to:
  /// **'Tu banco pide confirmar'**
  String get pagosEscenarioConfirmar;

  /// Tarjeta de prueba cuyo 3-D Secure falla.
  ///
  /// In es, this message translates to:
  /// **'Tu banco no confirma'**
  String get pagosEscenarioConfirmacionFalla;

  /// Sección de datos fiscales al pagar.
  ///
  /// In es, this message translates to:
  /// **'Factura'**
  String get pagosFactura;

  /// Selector del perfil fiscal para facturar.
  ///
  /// In es, this message translates to:
  /// **'Datos fiscales'**
  String get pagosDatosFiscales;

  /// Ayuda del selector de datos fiscales.
  ///
  /// In es, this message translates to:
  /// **'Con tus datos fiscales se emite la factura simulada al pagar.'**
  String get pagosFacturaAyuda;

  /// Opción para pagar sin facturar.
  ///
  /// In es, this message translates to:
  /// **'Sin factura'**
  String get pagosSinFactura;

  /// Un perfil fiscal en el selector.
  ///
  /// In es, this message translates to:
  /// **'{rfc} · {razonSocial}'**
  String pagosPerfilFiscal(String rfc, String razonSocial);

  /// Botón para pagar la orden.
  ///
  /// In es, this message translates to:
  /// **'Pagar {monto}'**
  String pagosPagar(String monto);

  /// Aviso cuando la tarjeta no pasa las reglas.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos de la tarjeta.'**
  String get pagosRevisaTarjeta;

  /// Aviso sin conexión al pagar.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e intenta de nuevo; no se cobrará dos veces.'**
  String get pagosSinConexion;

  /// Aviso de error al pagar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos procesar el pago. Intenta de nuevo.'**
  String get pagosErrorPagar;

  /// 409 ORDEN_NO_PAGABLE.
  ///
  /// In es, this message translates to:
  /// **'Esta orden ya no se puede pagar en la app.'**
  String get pagosOrdenNoPagable;

  /// 409 PAGO_EN_CURSO.
  ///
  /// In es, this message translates to:
  /// **'Ya hay un pago de esta orden esperando la confirmación de tu banco. Revísalo en Mis pagos.'**
  String get pagosPagoEnCurso;

  /// 409 PAGO_NO_PENDIENTE.
  ///
  /// In es, this message translates to:
  /// **'Este pago ya no espera la confirmación de tu banco.'**
  String get pagosPagoNoPendiente;

  /// Error: falta el número.
  ///
  /// In es, this message translates to:
  /// **'Escribe el número de la tarjeta.'**
  String get pagosErrorNumeroVacio;

  /// Error: número incompleto.
  ///
  /// In es, this message translates to:
  /// **'El número tiene 16 dígitos.'**
  String get pagosErrorNumeroIncompleto;

  /// Error: no pasa el algoritmo de Luhn.
  ///
  /// In es, this message translates to:
  /// **'Ese número no es válido; revísalo.'**
  String get pagosErrorNumeroInvalido;

  /// Error: no es una tarjeta de prueba.
  ///
  /// In es, this message translates to:
  /// **'Usa una de las tarjetas de prueba.'**
  String get pagosErrorNoEsDePrueba;

  /// Error: falta el vencimiento.
  ///
  /// In es, this message translates to:
  /// **'Escribe el vencimiento.'**
  String get pagosErrorVencimientoVacio;

  /// Error: vencimiento sin forma.
  ///
  /// In es, this message translates to:
  /// **'Escríbelo como MM/AA.'**
  String get pagosErrorVencimientoInvalido;

  /// Error: tarjeta vencida.
  ///
  /// In es, this message translates to:
  /// **'La tarjeta ya venció.'**
  String get pagosErrorVencida;

  /// Error: CVV.
  ///
  /// In es, this message translates to:
  /// **'El CVV tiene 3 dígitos.'**
  String get pagosErrorCvv;

  /// Título de la pantalla simulada de 3-D Secure.
  ///
  /// In es, this message translates to:
  /// **'Tu banco pide confirmar'**
  String get pagosBancoTitulo;

  /// Mensaje del 3-D Secure simulado.
  ///
  /// In es, this message translates to:
  /// **'Confirma el pago de {monto} con {tarjeta}. Esta pantalla del banco es simulada.'**
  String pagosBancoMensaje(String monto, String tarjeta);

  /// Botón para confirmar el 3-D Secure.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get pagosBancoConfirmar;

  /// Botón para cancelar el 3-D Secure.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get pagosBancoCancelar;

  /// Resultado de un pago aprobado.
  ///
  /// In es, this message translates to:
  /// **'¡Orden pagada!'**
  String get pagosPagadoTitulo;

  /// Mensaje del resultado de un pago aprobado.
  ///
  /// In es, this message translates to:
  /// **'Pagaste {monto}. Referencia {referencia}. Es un pago simulado: no se cobró nada.'**
  String pagosPagadoMensaje(String monto, String referencia);

  /// Botón para cerrar el resultado del pago.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get pagosListo;

  /// Botón para ir a mis pagos.
  ///
  /// In es, this message translates to:
  /// **'Ver mis pagos'**
  String get pagosVerMisPagos;

  /// Resultado de un pago fallido.
  ///
  /// In es, this message translates to:
  /// **'No se pudo pagar'**
  String get pagosFalloTitulo;

  /// Botón para reintentar con una llave nueva.
  ///
  /// In es, this message translates to:
  /// **'Intentar otra vez'**
  String get pagosIntentarOtraVez;

  /// Botón para salir del resultado.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get pagosVolver;

  /// Motivo: fondos insuficientes.
  ///
  /// In es, this message translates to:
  /// **'Tu banco rechazó la tarjeta por fondos insuficientes.'**
  String get pagosMotivoFondos;

  /// Motivo: 3-D Secure fallido o cancelado.
  ///
  /// In es, this message translates to:
  /// **'Tu banco no confirmó el pago.'**
  String get pagosMotivoAutenticacion;

  /// Motivo: 3-D Secure vencido.
  ///
  /// In es, this message translates to:
  /// **'Nadie confirmó el pago a tiempo.'**
  String get pagosMotivoVencida;

  /// Motivo: pagada en caja.
  ///
  /// In es, this message translates to:
  /// **'La orden se pagó en caja.'**
  String get pagosMotivoCaja;

  /// Motivo que esta versión aún no conoce.
  ///
  /// In es, this message translates to:
  /// **'El pago no se completó.'**
  String get pagosMotivoOtro;

  /// Estado de una orden pagada.
  ///
  /// In es, this message translates to:
  /// **'Esta orden ya está pagada'**
  String get pagosYaPagadaTitulo;

  /// Con qué y cuándo se pagó.
  ///
  /// In es, this message translates to:
  /// **'Con {medio} el {fecha}.'**
  String pagosYaPagadaMensaje(String medio, String fecha);

  /// Botón para ver el pago de la orden.
  ///
  /// In es, this message translates to:
  /// **'Ver el pago'**
  String get pagosVerPago;

  /// Estado de una orden que no se paga en la app.
  ///
  /// In es, this message translates to:
  /// **'Esta orden aún no se puede pagar'**
  String get pagosNoPagableTitulo;

  /// Por qué no se paga en la app.
  ///
  /// In es, this message translates to:
  /// **'Se paga en la app cuando está lista para entrega. Un servicio registrado ya hecho se paga en la agencia.'**
  String get pagosNoPagableMensaje;

  /// Título de mis pagos (V2-M08.07).
  ///
  /// In es, this message translates to:
  /// **'Mis pagos'**
  String get pagosMisPagosTitulo;

  /// Subtítulo de mis pagos.
  ///
  /// In es, this message translates to:
  /// **'Del más nuevo al más viejo'**
  String get pagosMisPagosSubtitulo;

  /// Estado vacío de mis pagos.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes pagos'**
  String get pagosMisPagosVacioTitulo;

  /// Mensaje del estado vacío de mis pagos.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás lo que pagues desde la app.'**
  String get pagosMisPagosVacioMensaje;

  /// Estado, con qué y cuándo de un pago en la lista.
  ///
  /// In es, this message translates to:
  /// **'{estado} · {medio} · {fecha}'**
  String pagosFilaSubtitulo(String estado, String medio, String fecha);

  /// Lo que oye el lector al final de la fila de un pago.
  ///
  /// In es, this message translates to:
  /// **'{monto}, {estado}'**
  String pagosMontoConEstado(String monto, String estado);

  /// Indicador de la página siguiente.
  ///
  /// In es, this message translates to:
  /// **'Cargando más pagos'**
  String get pagosCargandoMas;

  /// Error al pedir la página siguiente.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar más pagos.'**
  String get pagosErrorCargarMas;

  /// Estado de un pago.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pagosEstadoPendiente;

  /// Estado de un pago.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get pagosEstadoPagado;

  /// Estado de un pago.
  ///
  /// In es, this message translates to:
  /// **'Fallido'**
  String get pagosEstadoFallido;

  /// Estado de un pago.
  ///
  /// In es, this message translates to:
  /// **'Reembolsado'**
  String get pagosEstadoReembolsado;

  /// Una tarjeta por su marca y últimos 4.
  ///
  /// In es, this message translates to:
  /// **'{marca} •••• {ultimos4}'**
  String pagosMedioTarjeta(String marca, String ultimos4);

  /// Medio de pago: caja de la agencia.
  ///
  /// In es, this message translates to:
  /// **'En caja'**
  String get pagosMedioCaja;

  /// Medio de pago: billetera simulada.
  ///
  /// In es, this message translates to:
  /// **'Apple Pay (simulado)'**
  String get pagosMedioApplePay;

  /// Medio de pago: billetera simulada.
  ///
  /// In es, this message translates to:
  /// **'Google Pay (simulado)'**
  String get pagosMedioGooglePay;

  /// Título del detalle de un pago.
  ///
  /// In es, this message translates to:
  /// **'Pago'**
  String get pagosPagoTitulo;

  /// Etiqueta del monto del pago.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get pagosMonto;

  /// Fila del medio de pago.
  ///
  /// In es, this message translates to:
  /// **'Con qué se pagó'**
  String get pagosMedio;

  /// Fila de la fecha de pago.
  ///
  /// In es, this message translates to:
  /// **'Pagado el'**
  String get pagosFechaPago;

  /// Fila de la fecha de un intento sin pagar.
  ///
  /// In es, this message translates to:
  /// **'Intentado el'**
  String get pagosFechaIntento;

  /// Fila de la referencia del pago.
  ///
  /// In es, this message translates to:
  /// **'Referencia'**
  String get pagosReferencia;

  /// Fila del motivo de un pago fallido.
  ///
  /// In es, this message translates to:
  /// **'Por qué no se cobró'**
  String get pagosMotivo;

  /// Botón para responder un 3-D Secure pendiente.
  ///
  /// In es, this message translates to:
  /// **'Confirmar con tu banco'**
  String get pagosConfirmarBanco;

  /// Botón para abrir el ticket de la orden.
  ///
  /// In es, this message translates to:
  /// **'Ver el ticket'**
  String get pagosVerTicket;

  /// Título del pago de un pedido de la tienda (V2-M14.04).
  ///
  /// In es, this message translates to:
  /// **'Pagar pedido'**
  String get pagosPagarPedidoTitulo;

  /// Número del pedido de la tienda.
  ///
  /// In es, this message translates to:
  /// **'Pedido {pedido}'**
  String pagosPedido(String pedido);

  /// Estado de un pedido pagado.
  ///
  /// In es, this message translates to:
  /// **'Este pedido ya está pagado'**
  String get pagosPedidoYaPagadoTitulo;

  /// Estado de un pedido que no se paga en la app.
  ///
  /// In es, this message translates to:
  /// **'Este pedido ya no se puede pagar en la app'**
  String get pagosPedidoNoPagableTitulo;

  /// Por qué no se paga en la app.
  ///
  /// In es, this message translates to:
  /// **'Se paga en la app mientras está apartado o listo y no ha vencido. Si no, se paga en caja.'**
  String get pagosPedidoNoPagableMensaje;

  /// 409 PEDIDO_NO_PAGABLE.
  ///
  /// In es, this message translates to:
  /// **'Este pedido ya no se puede pagar en la app.'**
  String get pagosPedidoNoPagable;

  /// 409 PAGO_EN_CURSO de un pedido.
  ///
  /// In es, this message translates to:
  /// **'Ya hay un pago de este pedido esperando la confirmación de tu banco. Revísalo en Mis pagos.'**
  String get pagosPedidoPagoEnCurso;

  /// Cierre de un pedido pagado.
  ///
  /// In es, this message translates to:
  /// **'¡Pedido pagado!'**
  String get pagosPedidoPagadoTitulo;

  /// Botón para abrir el pedido de la tienda pagado.
  ///
  /// In es, this message translates to:
  /// **'Ver el pedido'**
  String get pagosVerPedido;

  /// Pago que no existe.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este pago'**
  String get pagosNoEncontradoTitulo;

  /// Mensaje del pago que no existe.
  ///
  /// In es, this message translates to:
  /// **'Puede que sea de otra cuenta. Revisa Mis pagos.'**
  String get pagosNoEncontradoMensaje;

  /// Título de mis tarjetas guardadas (V2-M08.04).
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago'**
  String get pagosMetodosTitulo;

  /// Estado vacío de métodos de pago.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes tarjetas guardadas'**
  String get pagosMetodosVacioTitulo;

  /// Mensaje del estado vacío de métodos de pago.
  ///
  /// In es, this message translates to:
  /// **'Al pagar, marca «Guardar tarjeta» para que aparezca aquí.'**
  String get pagosMetodosVacioMensaje;

  /// Pie de métodos de pago.
  ///
  /// In es, this message translates to:
  /// **'Solo se guardan la marca, los últimos 4 y el vencimiento de tarjetas de prueba.'**
  String get pagosMetodosPie;

  /// Vencimiento de una tarjeta guardada.
  ///
  /// In es, this message translates to:
  /// **'Vence {vence}'**
  String pagosVence(String vence);

  /// Vencimiento y tipo de una tarjeta guardada.
  ///
  /// In es, this message translates to:
  /// **'Vence {vence} · {tipo}'**
  String pagosVenceYTipo(String vence, String tipo);

  /// Tarjeta de crédito.
  ///
  /// In es, this message translates to:
  /// **'Crédito'**
  String get pagosCredito;

  /// Tarjeta de débito.
  ///
  /// In es, this message translates to:
  /// **'Débito'**
  String get pagosDebito;

  /// Insignia de la tarjeta predeterminada.
  ///
  /// In es, this message translates to:
  /// **'Predeterminada'**
  String get pagosPredeterminada;

  /// Insignia de una tarjeta vencida.
  ///
  /// In es, this message translates to:
  /// **'Vencida'**
  String get pagosVencidaInsignia;

  /// Acción sobre una tarjeta guardada.
  ///
  /// In es, this message translates to:
  /// **'Usar como predeterminada'**
  String get pagosUsarPredeterminada;

  /// Acción sobre una tarjeta guardada.
  ///
  /// In es, this message translates to:
  /// **'Borrar tarjeta'**
  String get pagosBorrarTarjeta;

  /// Título de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar esta tarjeta?'**
  String get pagosBorrarTitulo;

  /// Mensaje de la confirmación de borrado.
  ///
  /// In es, this message translates to:
  /// **'{tarjeta} ya no aparecerá al pagar. Los pagos que hiciste con ella se conservan.'**
  String pagosBorrarMensaje(String tarjeta);

  /// Botón para confirmar el borrado.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get pagosBorrarConfirmar;

  /// Botón para cancelar el borrado.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get pagosBorrarCancelar;

  /// Error al cambiar una tarjeta guardada.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el cambio. Intenta de nuevo.'**
  String get pagosErrorMetodo;

  /// Encabezado del pago en el ticket (V2-M08.02).
  ///
  /// In es, this message translates to:
  /// **'Pago'**
  String get historialTicketPago;

  /// La orden ya está pagada.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get historialTicketPagado;

  /// Con qué y cuándo se pagó la orden.
  ///
  /// In es, this message translates to:
  /// **'{medio} · {fecha}'**
  String historialTicketPagadoDetalle(String medio, String fecha);

  /// Se pagó en la caja de la agencia.
  ///
  /// In es, this message translates to:
  /// **'En caja'**
  String get historialTicketPagadoEnCaja;

  /// La tarjeta con que se pagó.
  ///
  /// In es, this message translates to:
  /// **'{marca} •••• {ultimos4}'**
  String historialTicketTarjeta(String marca, String ultimos4);

  /// La referencia del pago en el ticket.
  ///
  /// In es, this message translates to:
  /// **'Referencia'**
  String get historialTicketReferencia;

  /// Botón para pagar la orden desde su ticket.
  ///
  /// In es, this message translates to:
  /// **'Pagar {monto}'**
  String historialTicketPagar(String monto);

  /// Botón para pagar con la billetera simulada en iPhone (V2-M08.03).
  ///
  /// In es, this message translates to:
  /// **'Pagar con Apple Pay'**
  String get pagosBilleteraApplePay;

  /// Botón para pagar con la billetera simulada en Android (V2-M08.03).
  ///
  /// In es, this message translates to:
  /// **'Pagar con Google Pay'**
  String get pagosBilleteraGooglePay;

  /// Ayuda bajo el botón de la billetera (ADR 0009).
  ///
  /// In es, this message translates to:
  /// **'Billetera simulada: siempre se aprueba y no se guarda. Abajo puedes pagar con tarjeta.'**
  String get pagosBilleteraAyuda;

  /// Mensaje de la hoja simulada de la billetera.
  ///
  /// In es, this message translates to:
  /// **'Vas a pagar {monto} con {billetera}. Es simulado: no se cobra nada.'**
  String pagosBilleteraMensaje(String monto, String billetera);

  /// Confirma el pago en la hoja de la billetera.
  ///
  /// In es, this message translates to:
  /// **'Pagar'**
  String get pagosBilleteraConfirmar;

  /// Cierra la hoja de la billetera sin pagar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get pagosBilleteraCancelar;

  /// Resultado de un pago aprobado que pidió factura (V2-M08.06).
  ///
  /// In es, this message translates to:
  /// **'Pagaste {monto}. Referencia {referencia}. La factura simulada queda en el detalle del pago. No se cobró nada.'**
  String pagosPagadoFacturaMensaje(String monto, String referencia);

  /// Lleva del resultado del pago al detalle con su factura.
  ///
  /// In es, this message translates to:
  /// **'Ver la factura'**
  String get pagosVerFactura;

  /// Serie y folio de la factura simulada.
  ///
  /// In es, this message translates to:
  /// **'Factura {folio}'**
  String pagosFacturaFolio(String folio);

  /// Subtítulo de la fecha de timbrado de la factura.
  ///
  /// In es, this message translates to:
  /// **'Timbrada'**
  String get pagosFacturaTimbrada;

  /// Subtítulo del UUID del timbre simulado.
  ///
  /// In es, this message translates to:
  /// **'Folio fiscal'**
  String get pagosFacturaFolioFiscal;

  /// Subtítulo de los datos fiscales de la factura.
  ///
  /// In es, this message translates to:
  /// **'Receptor · uso {usoCfdi}'**
  String pagosFacturaReceptor(String usoCfdi);

  /// Comparte el PDF de la factura.
  ///
  /// In es, this message translates to:
  /// **'Descargar PDF'**
  String get pagosFacturaPdf;

  /// Comparte el XML de la factura.
  ///
  /// In es, this message translates to:
  /// **'Descargar XML'**
  String get pagosFacturaXml;

  /// Aviso fijo de la factura (ADR 0009).
  ///
  /// In es, this message translates to:
  /// **'Factura simulada con estructura de CFDI 4.0, sin validez fiscal.'**
  String get pagosFacturaSimulada;

  /// Error al descargar el PDF o el XML.
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar la factura. Intenta otra vez.'**
  String get pagosFacturaErrorDescargar;

  /// Botón para timbrar la factura de un pago.
  ///
  /// In es, this message translates to:
  /// **'Facturar'**
  String get pagosFacturar;

  /// Ayuda del selector de datos fiscales al facturar.
  ///
  /// In es, this message translates to:
  /// **'Con estos datos se timbra la factura simulada de este pago.'**
  String get pagosFacturarAyuda;

  /// Aviso cuando el cliente no tiene datos fiscales.
  ///
  /// In es, this message translates to:
  /// **'Para facturar este pago agrega tus datos fiscales.'**
  String get pagosFacturaSinPerfiles;

  /// Lleva al alta de datos fiscales.
  ///
  /// In es, this message translates to:
  /// **'Agregar datos fiscales'**
  String get pagosAgregarDatosFiscales;

  /// Encabezado del error 422 TIMBRADO_RECHAZADO.
  ///
  /// In es, this message translates to:
  /// **'El timbrado rechazó tus datos fiscales.'**
  String get pagosTimbradoRechazado;

  /// Qué corregir cuando se rechaza la razón social.
  ///
  /// In es, this message translates to:
  /// **'Escribe la razón social como en tu constancia, sin el régimen societario (sin «S.A. de C.V.»).'**
  String get pagosTimbradoRazonSocial;

  /// Qué corregir cuando se rechaza el código postal.
  ///
  /// In es, this message translates to:
  /// **'Revisa el código postal de tu domicilio fiscal.'**
  String get pagosTimbradoCodigoPostal;

  /// Qué corregir cuando se rechaza otro campo.
  ///
  /// In es, this message translates to:
  /// **'Revisa tus datos fiscales.'**
  String get pagosTimbradoOtro;

  /// Lleva a editar el perfil fiscal rechazado.
  ///
  /// In es, this message translates to:
  /// **'Corregir datos fiscales'**
  String get pagosCorregirDatosFiscales;

  /// Error 409 YA_FACTURADO.
  ///
  /// In es, this message translates to:
  /// **'Este pago ya tiene factura.'**
  String get pagosFacturaYaFacturada;

  /// Error 409 PAGO_NO_FACTURABLE.
  ///
  /// In es, this message translates to:
  /// **'Este pago no se puede facturar desde la app.'**
  String get pagosFacturaNoFacturable;

  /// Error genérico al facturar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo facturar. Intenta otra vez.'**
  String get pagosFacturaErrorFacturar;

  /// Aviso de un pago en caja sin factura.
  ///
  /// In es, this message translates to:
  /// **'Los pagos en caja se facturan en la agencia.'**
  String get pagosFacturaEnLaAgencia;

  /// Sin conexión al facturar o descargar la factura.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet e intenta de nuevo.'**
  String get pagosFacturaSinConexion;

  /// Título de la pantalla de sucursales con mapa y horarios.
  ///
  /// In es, this message translates to:
  /// **'Sucursales'**
  String get sucursalesTitulo;

  /// Lo que anuncia el lector de pantalla mientras cargan las sucursales.
  ///
  /// In es, this message translates to:
  /// **'Cargando sucursales'**
  String get sucursalesCargando;

  /// No description provided for @sucursalesVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay sucursales'**
  String get sucursalesVacioTitulo;

  /// No description provided for @sucursalesVacioMensaje.
  ///
  /// In es, this message translates to:
  /// **'Cuando la agencia publique sus sucursales, las verás aquí con su mapa y sus horarios.'**
  String get sucursalesVacioMensaje;

  /// Nombre del mapa para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Mapa con la ubicación de {nombre}'**
  String sucursalesMapaDe(String nombre);

  /// No description provided for @sucursalesAbiertoAhora.
  ///
  /// In es, this message translates to:
  /// **'Abierto ahora'**
  String get sucursalesAbiertoAhora;

  /// Estado corto de un departamento de la sucursal que atiende en este momento.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get sucursalesAbierto;

  /// No description provided for @sucursalesCerrado.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get sucursalesCerrado;

  /// No description provided for @sucursalesLlamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get sucursalesLlamar;

  /// No description provided for @sucursalesComoLlegar.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get sucursalesComoLlegar;

  /// No description provided for @sucursalesHorarios.
  ///
  /// In es, this message translates to:
  /// **'Horarios'**
  String get sucursalesHorarios;

  /// No description provided for @sucursalesTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas las sucursales'**
  String get sucursalesTodas;

  /// No description provided for @sucursalesSeleccionada.
  ///
  /// In es, this message translates to:
  /// **'Seleccionada'**
  String get sucursalesSeleccionada;

  /// Nombre del departamento de la agencia que tiene su propio horario.
  ///
  /// In es, this message translates to:
  /// **'{departamento, select, ventas{Ventas} servicio{Servicio} refacciones{Refacciones} other{Otro}}'**
  String sucursalesDepartamento(String departamento);

  /// Día de la semana abreviado; 1 es lunes y 7 domingo.
  ///
  /// In es, this message translates to:
  /// **'{dia, select, 1{lun} 2{mar} 3{mié} 4{jue} 5{vie} 6{sáb} 7{dom} other{}}'**
  String sucursalesDiaCorto(String dia);

  /// Tramo de días seguidos de un horario, por ejemplo «lun a vie».
  ///
  /// In es, this message translates to:
  /// **'{desde} a {hasta}'**
  String sucursalesDiasRango(String desde, String hasta);

  /// Una línea de horario, por ejemplo «lun a vie: 08:00 a 18:00».
  ///
  /// In es, this message translates to:
  /// **'{dias}: {abre} a {cierra}'**
  String sucursalesTramo(String dias, String abre, String cierra);

  /// Lo que lee el lector de pantalla en la fila de una sucursal.
  ///
  /// In es, this message translates to:
  /// **'{nombre}, {estado}. {direccion}'**
  String sucursalesDescripcionFila(
    String nombre,
    String estado,
    String direccion,
  );

  /// No description provided for @sucursalesNoSePudoLlamar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el marcador del teléfono.'**
  String get sucursalesNoSePudoLlamar;

  /// No description provided for @sucursalesNoSePudoMapa.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir la app de mapas.'**
  String get sucursalesNoSePudoMapa;

  /// Etiqueta del marcador del chofer en el mapa del seguimiento.
  ///
  /// In es, this message translates to:
  /// **'Tu chofer'**
  String get recoleccionSeguimientoMarcadorChofer;

  /// Título de la pantalla para contactar a la agencia.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contactoTitulo;

  /// Texto de apoyo bajo el título de Contacto.
  ///
  /// In es, this message translates to:
  /// **'Elige cómo prefieres hablar con la agencia. Te atiende la sucursal principal.'**
  String get contactoIntro;

  /// Encabezado del grupo de medios de contacto (llamar y correo).
  ///
  /// In es, this message translates to:
  /// **'Medios de contacto'**
  String get contactoGrupoMedios;

  /// Fila que abre el marcador con el teléfono de la agencia.
  ///
  /// In es, this message translates to:
  /// **'Llamar a la agencia'**
  String get contactoLlamar;

  /// Fila que abre la app de correo con el correo de la agencia.
  ///
  /// In es, this message translates to:
  /// **'Escribir un correo'**
  String get contactoCorreo;

  /// Encabezado del grupo que lleva a las sucursales.
  ///
  /// In es, this message translates to:
  /// **'Dónde estamos'**
  String get contactoGrupoDonde;

  /// Fila que abre la pantalla de sucursales con mapa.
  ///
  /// In es, this message translates to:
  /// **'Sucursales y horarios'**
  String get contactoVerSucursales;

  /// Detalle de la fila de sucursales cuando aún no se conoce la sucursal principal.
  ///
  /// In es, this message translates to:
  /// **'Mapa, horarios y cómo llegar'**
  String get contactoVerSucursalesDetalle;

  /// Aviso cuando el teléfono no tiene app de correo.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir tu app de correo. Escríbenos a {correo}.'**
  String contactoNoSePudoCorreo(String correo);

  /// Título de la pantalla de documentos del vehículo (V2-M09.01) y de su acceso desde el detalle.
  ///
  /// In es, this message translates to:
  /// **'Documentos'**
  String get documentosTitulo;

  /// Lo que oye el lector de pantalla mientras cargan los documentos.
  ///
  /// In es, this message translates to:
  /// **'Cargando documentos'**
  String get documentosCargando;

  /// Título del estado vacío de documentos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay documentos'**
  String get documentosVaciaTitulo;

  /// Mensaje del estado vacío de documentos.
  ///
  /// In es, this message translates to:
  /// **'Aquí vivirán la póliza, la tarjeta de circulación y la verificación de tu auto, con su fecha de vencimiento.'**
  String get documentosVaciaMensaje;

  /// Subtítulo de la pantalla: cuántos documentos hay.
  ///
  /// In es, this message translates to:
  /// **'{total, plural, =1{1 documento} other{{total} documentos}}'**
  String documentosSubtitulo(int total);

  /// Resumen de la portada cuando hay documentos por vencer o vencidos.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{1 documento necesita atención} other{{cantidad} documentos necesitan atención}}'**
  String documentosResumenAtencion(int cantidad);

  /// Resumen de la portada cuando ningún documento está por vencer ni vencido.
  ///
  /// In es, this message translates to:
  /// **'Todo en orden'**
  String get documentosResumenAlDia;

  /// Detalle del resumen cuando todo está en orden.
  ///
  /// In es, this message translates to:
  /// **'Tus documentos están al día.'**
  String get documentosResumenAlDiaDetalle;

  /// Lo más urgente del resumen de portada, cuando aún no vence. «cuando» es «hoy», «mañana» o «en 12 días».
  ///
  /// In es, this message translates to:
  /// **'{nombre} vence {cuando}.'**
  String documentosResumenVence(String nombre, String cuando);

  /// Lo más urgente del resumen de portada, cuando ya venció. «cuando» es «hace 35 días».
  ///
  /// In es, this message translates to:
  /// **'{nombre} venció {cuando}.'**
  String documentosResumenVencio(String nombre, String cuando);

  /// Encabezado del grupo de documentos que vencen en 30 días o menos.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get documentosGrupoPorVencer;

  /// Encabezado del grupo de documentos vencidos.
  ///
  /// In es, this message translates to:
  /// **'Vencidos'**
  String get documentosGrupoVencidos;

  /// Encabezado del grupo de documentos vigentes.
  ///
  /// In es, this message translates to:
  /// **'Vigentes'**
  String get documentosGrupoVigentes;

  /// Encabezado del grupo de documentos sin vencimiento.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de vencimiento'**
  String get documentosGrupoSinFecha;

  /// Insignia de un documento vigente.
  ///
  /// In es, this message translates to:
  /// **'Vigente'**
  String get documentosEstadoVigente;

  /// Insignia de un documento que vence en 30 días o menos.
  ///
  /// In es, this message translates to:
  /// **'Por vencer'**
  String get documentosEstadoPorVencer;

  /// Insignia de un documento vencido.
  ///
  /// In es, this message translates to:
  /// **'Vencido'**
  String get documentosEstadoVencido;

  /// Insignia de un documento sin fecha de vencimiento.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get documentosEstadoSinFecha;

  /// Fecha de vencimiento de un documento vigente o por vencer.
  ///
  /// In es, this message translates to:
  /// **'Vence el {fecha}'**
  String documentosVenceEl(String fecha);

  /// Fecha de vencimiento de un documento vencido.
  ///
  /// In es, this message translates to:
  /// **'Venció el {fecha}'**
  String documentosVencioEl(String fecha);

  /// Cuándo vence: hoy, mañana o en N días.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =0{hoy} =1{mañana} other{en {dias} días}}'**
  String documentosEnDias(int dias);

  /// Hace cuánto venció un documento.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =1{hace 1 día} other{hace {dias} días}}'**
  String documentosHaceDias(int dias);

  /// Número o folio del documento.
  ///
  /// In es, this message translates to:
  /// **'N.º {numero}'**
  String documentosNumero(String numero);

  /// Origen de un documento que subió la agencia.
  ///
  /// In es, this message translates to:
  /// **'Cargado por la agencia'**
  String get documentosCargadoPorAgencia;

  /// Tipo de documento: póliza de seguro.
  ///
  /// In es, this message translates to:
  /// **'Póliza de seguro'**
  String get documentosTipoPoliza;

  /// Tipo de documento: tarjeta de circulación.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de circulación'**
  String get documentosTipoTarjetaCirculacion;

  /// Tipo de documento: verificación vehicular.
  ///
  /// In es, this message translates to:
  /// **'Verificación vehicular'**
  String get documentosTipoVerificacion;

  /// Tipo de documento: tenencia y refrendo.
  ///
  /// In es, this message translates to:
  /// **'Tenencia y refrendo'**
  String get documentosTipoTenencia;

  /// Tipo de documento: licencia de conducir.
  ///
  /// In es, this message translates to:
  /// **'Licencia de conducir'**
  String get documentosTipoLicencia;

  /// Tipo de documento: póliza de garantía.
  ///
  /// In es, this message translates to:
  /// **'Póliza de garantía'**
  String get documentosTipoGarantia;

  /// Tipo de documento: factura de compra.
  ///
  /// In es, this message translates to:
  /// **'Factura de compra'**
  String get documentosTipoFactura;

  /// Tipo de documento: otro, cuando no trae título propio.
  ///
  /// In es, this message translates to:
  /// **'Otro documento'**
  String get documentosTipoOtro;

  /// Detalle de la fila «Mi aseguradora» mientras se lee la póliza de los documentos del auto (V2-M11.02 con V2-M09.01).
  ///
  /// In es, this message translates to:
  /// **'Buscando tu póliza…'**
  String get asistenciaLlamarAseguradoraBuscando;

  /// No description provided for @ayudaAcerca.
  ///
  /// In es, this message translates to:
  /// **'Acerca de CareCar'**
  String get ayudaAcerca;

  /// No description provided for @ayudaVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get ayudaVersion;

  /// No description provided for @ayudaCargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get ayudaCargando;

  /// No description provided for @ayudaLicencias.
  ///
  /// In es, this message translates to:
  /// **'Licencias de software'**
  String get ayudaLicencias;

  /// No description provided for @ayudaLicenciasDetalle.
  ///
  /// In es, this message translates to:
  /// **'Componentes incluidos en la aplicación'**
  String get ayudaLicenciasDetalle;

  /// No description provided for @ayudaPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Aviso de privacidad'**
  String get ayudaPrivacidad;

  /// No description provided for @ayudaTerminos.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get ayudaTerminos;

  /// No description provided for @ayudaTerminosAusentes.
  ///
  /// In es, this message translates to:
  /// **'El documento no está disponible.'**
  String get ayudaTerminosAusentes;

  /// No description provided for @ayudaCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get ayudaCerrar;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Calendario de vencimientos'**
  String get documentosCalendario;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Vencimientos'**
  String get documentosVencimientos;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los vencimientos'**
  String get documentosErrorCalendario;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, one{1 vencimiento} other{{cantidad} vencimientos}}'**
  String documentosCantidad(int cantidad);

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Vencimientos del mes'**
  String get documentosDelMes;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Ver todo el mes'**
  String get documentosVerMes;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'No hay vencimientos este mes.'**
  String get documentosMesVacio;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'No hay vencimientos en este día.'**
  String get documentosDiaVacio;

  /// Texto de documentos del vehículo.
  ///
  /// In es, this message translates to:
  /// **'{fecha} · {vehiculo}'**
  String documentosDetalle(String fecha, String vehiculo);

  /// No description provided for @ayudaBuscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get ayudaBuscar;

  /// No description provided for @ayudaBuscarSugerencia.
  ///
  /// In es, this message translates to:
  /// **'Escribe una pregunta o tema'**
  String get ayudaBuscarSugerencia;

  /// No description provided for @ayudaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get ayudaDescripcion;

  /// No description provided for @ayudaDescripcionPista.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué ocurrió'**
  String get ayudaDescripcionPista;

  /// No description provided for @ayudaEnviado.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado'**
  String get ayudaEnviado;

  /// No description provided for @ayudaEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get ayudaEnviar;

  /// No description provided for @ayudaErrorReporte.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el reporte. Intenta de nuevo.'**
  String get ayudaErrorReporte;

  /// No description provided for @ayudaGracias.
  ///
  /// In es, this message translates to:
  /// **'Gracias por ayudarnos a mejorar.'**
  String get ayudaGracias;

  /// No description provided for @ayudaLongitud.
  ///
  /// In es, this message translates to:
  /// **'Describe el problema con entre 10 y 2000 caracteres.'**
  String get ayudaLongitud;

  /// No description provided for @ayudaOtrasPalabras.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otras palabras.'**
  String get ayudaOtrasPalabras;

  /// No description provided for @ayudaPreguntas.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes'**
  String get ayudaPreguntas;

  /// No description provided for @ayudaPrivacidadReporte.
  ///
  /// In es, this message translates to:
  /// **'Se adjuntan la versión de CareCar, el sistema y el modelo del equipo. Evita incluir datos personales en la descripción.'**
  String get ayudaPrivacidadReporte;

  /// No description provided for @ayudaReporte.
  ///
  /// In es, this message translates to:
  /// **'Reportar un problema'**
  String get ayudaReporte;

  /// No description provided for @ayudaSinResultados.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get ayudaSinResultados;

  /// No description provided for @documentosPdfAgencia.
  ///
  /// In es, this message translates to:
  /// **'Documento de la agencia'**
  String get documentosPdfAgencia;

  /// No description provided for @documentosAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar documento'**
  String get documentosAgregar;

  /// No description provided for @documentosAgregarFecha.
  ///
  /// In es, this message translates to:
  /// **'Agregar fecha de vencimiento'**
  String get documentosAgregarFecha;

  /// No description provided for @documentosCamara.
  ///
  /// In es, this message translates to:
  /// **'Tomar fotografía'**
  String get documentosCamara;

  /// No description provided for @documentosErrorFoto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo preparar la foto.'**
  String get documentosErrorFoto;

  /// No description provided for @documentosErrorGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el documento. Intenta de nuevo.'**
  String get documentosErrorGuardar;

  /// No description provided for @documentosFaltaFoto.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una imagen del documento.'**
  String get documentosFaltaFoto;

  /// No description provided for @documentosGaleria.
  ///
  /// In es, this message translates to:
  /// **'Elegir de galería'**
  String get documentosGaleria;

  /// No description provided for @documentosGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar documento'**
  String get documentosGuardar;

  /// No description provided for @documentosProgreso.
  ///
  /// In es, this message translates to:
  /// **'Carga del documento'**
  String get documentosProgreso;

  /// No description provided for @documentosTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo de documento'**
  String get documentosTipo;

  /// No description provided for @documentosVistaPrevia.
  ///
  /// In es, this message translates to:
  /// **'Vista previa del documento'**
  String get documentosVistaPrevia;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Encuestas de servicio'**
  String get m15Titulo;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Califica tu visita al taller'**
  String get m15Pendientes;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'No tienes encuestas pendientes'**
  String get m15Vacio;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tan probable es que recomiendes nuestro servicio?'**
  String get m15Recomendar;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Tiempo del servicio'**
  String get m15Tiempo;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Trato recibido'**
  String get m15Trato;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Limpieza del vehículo'**
  String get m15Limpieza;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Atención del asesor'**
  String get m15Asesor;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Elige una calificación para cada pregunta. El número más alto es la mejor calificación.'**
  String get m15Escala;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Comentario opcional'**
  String get m15Comentario;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Enviar encuesta'**
  String get m15Enviar;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Posponer por 24 horas'**
  String get m15Posponer;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Gracias por calificar tu servicio'**
  String get m15Gracias;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Pedir que la agencia me contacte'**
  String get m15Contacto;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'La agencia recibió tu solicitud de contacto.'**
  String get m15ContactoListo;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Intenta de nuevo.'**
  String get m15Error;

  /// Texto de encuestas o contacto con la agencia.
  ///
  /// In es, this message translates to:
  /// **'Esta encuesta ya no está disponible'**
  String get m15NoDisponible;

  /// Texto de promociones y novedades.
  ///
  /// In es, this message translates to:
  /// **'Novedades'**
  String get m13Novedades;

  /// Texto de promociones y novedades.
  ///
  /// In es, this message translates to:
  /// **'Para ti'**
  String get m13ParaTi;

  /// Texto de promociones y novedades.
  ///
  /// In es, this message translates to:
  /// **'No hay novedades por ahora'**
  String get m13SinNovedades;

  /// Texto de promociones y novedades.
  ///
  /// In es, this message translates to:
  /// **'Esta publicación ya no está disponible'**
  String get m13NoDisponible;

  /// Texto de promociones y novedades.
  ///
  /// In es, this message translates to:
  /// **'Cupón'**
  String get m13Cupon;

  /// El cupón de la promoción en el resultado de la cita.
  ///
  /// In es, this message translates to:
  /// **'Cupón: {codigo}'**
  String m13CuponCodigo(String codigo);

  /// Texto de promociones y novedades.
  ///
  /// In es, this message translates to:
  /// **'Agendar con esta promoción'**
  String get m13Agendar;
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
