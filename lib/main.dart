import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_config.dart';
import 'api/carecar_api.dart';
import 'api/carecar_api_http.dart';
import 'api/cliente_api.dart';
import 'cache/carecar_api_con_cache.dart';
import 'config/flavor.dart';
import 'l10n/idiomas.dart';
import 'modulos/widgets/widgets.dart';
import 'nucleo/analitica/ambito_analitica.dart';
import 'nucleo/analitica/analitica.dart';
import 'nucleo/analitica/observador_analitica.dart';
import 'nucleo/analitica/proveedores_analitica.dart';
import 'nucleo/api/proveedores_api.dart';
import 'nucleo/datos/reintento.dart';
import 'nucleo/idioma/proveedores_idioma.dart';
import 'nucleo/navegacion/proveedores_navegacion.dart';
import 'nucleo/privacidad/cubierta_en_segundo_plano.dart';
import 'nucleo/seguridad/aviso_equipo_comprometido.dart';
import 'nucleo/seguridad/detector_integridad.dart';
import 'nucleo/seguridad/politica_datos_locales.dart';
import 'nucleo/seguridad/proveedores_seguridad.dart';
import 'nucleo/sesion/proveedores_sesion.dart';
import 'notificaciones/plugin_notificaciones_local.dart';
import 'notificaciones/servicio_notificaciones.dart';
import 'pantallas/pantalla_arranque.dart';
import 'sesion/almacen_seguro.dart';
import 'sesion/controlador_sesion.dart';
import 'tema/tema_carecar.dart';

/// Entrada sin flavor: equivale a `produccion` (el mas restrictivo).
///
/// Para trabajar usa un punto de entrada por flavor (`main_desarrollo.dart`,
/// `main_pruebas.dart`, `main_produccion.dart`), que llama a [arrancar].
Future<void> main() => arrancar(Flavor.produccion);

/// Arranca la app en el [flavor] dado (V2-T01.04).
Future<void> arrancar(Flavor flavor) async {
  final relojArranque = Stopwatch()..start();
  Flavor.actual = flavor;
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Recordatorios de citas con notificaciones locales (sin servidor).
  late final ServicioNotificaciones servicio;
  servicio = ServicioNotificaciones(
    PluginNotificacionesLocal(alTocar: () => servicio.notificarToque()),
    prefs,
  );
  Notificaciones.actual = servicio;
  await servicio.iniciar();
  // Root o jailbreak (V2-M22.05): se evalua antes de abrir la app para que
  // ninguna copia local se escriba sin saberlo. Nunca lanza y vence a los 3 s.
  final politica = PoliticaDatosLocales(
    await evaluarIntegridad(const DetectorIntegridadDelSistema()),
  );
  // Sin ProviderScope aqui: AppCareCar crea el suyo con las inyecciones, y un
  // alcance anidado no vería los proveedores del enrutador.
  runApp(
    AppCareCar(prefs: prefs, politica: politica, relojArranque: relojArranque),
  );
}

/// Arma la app y conecta las piezas.
///
/// Este es el unico lugar que conoce a la vez la direccion del servidor, el
/// cliente HTTP y las pantallas. Mas abajo nadie sabe de donde vienen los
/// datos: las pantallas solo ven `CarecarApi` y `ControladorSesion`.
///
/// El cableado de la v1 sigue a mano; ademas se publica en Riverpod
/// (`nucleo/api`, `nucleo/sesion`) para que los modulos v2 lo lean sin
/// constructores (ADR 0002, V2-T01.02).
class AppCareCar extends StatefulWidget {
  const AppCareCar({
    super.key,
    this.prefs,
    this.politica,
    this.relojArranque,
    this.duracionArranque = const Duration(milliseconds: 1200),
  });

  /// Tiempo minimo que se ve la cortina de arranque (cero en pruebas).
  final Duration duracionArranque;
  final Stopwatch? relojArranque;

  /// Que se puede guardar en el equipo segun su integridad (V2-M22.05). Sin
  /// ella la app se comporta como en un equipo sin señal de riesgo.
  final PoliticaDatosLocales? politica;

  /// Si viene, las lecturas se guardan para verlas sin conexion.
  final SharedPreferences? prefs;

  @override
  State<AppCareCar> createState() => _AppCareCarState();
}

class _AppCareCarState extends State<AppCareCar> {
  ControladorSesion? _sesion;
  ClienteApi? _cliente;
  CarecarApi? _api;
  EnviarAnalitica? _enviarAnalitica;
  Object? _errorDeArranque;

  /// Mientras se lee la sesion guardada no se sabe si hay que mostrar el login.
  ///
  /// Sin esto se veria el login un instante y la app saltaria a inicio, que es
  /// peor que una espera corta.
  bool _restaurando = true;

  @override
  void initState() {
    super.initState();
    _armar();
  }

  void _armar() {
    try {
      // TEC-6 T3: el almacenamiento cifrado del sistema. Con el refresh token
      // de 30 dias, la sesion sobrevive a cerrar la app.
      final almacen = AlmacenSeguro.delSistema();

      // Se declara antes del cliente porque el cliente necesita poder pedirle
      // un refresco, y el controlador necesita la API que usa ese cliente. La
      // referencia se resuelve cuando corre el callback, no al construirlo.
      late final ControladorSesion sesion;

      // El cliente pide el token al almacen en cada peticion, asi que iniciar
      // o cerrar sesion no obliga a reconstruirlo.
      final cliente = ClienteApi(
        config: ApiConfig.desdeEntorno(),
        obtenerToken: () async => (await almacen.leer())?.accessToken,
        // RIC-3: ante un 401 se intenta refrescar una vez.
        renovarSesion: () => sesion.renovar(),
      );

      final prefs = widget.prefs;
      final CarecarApi api = prefs == null
          ? CarecarApiHttp(cliente)
          : CarecarApiConCache(
              CarecarApiHttp(cliente),
              prefs,
              politica: widget.politica,
            );
      sesion = ControladorSesion(api, almacen);
      _enviarAnalitica = (evento, siguePermitido) async {
        final estado = sesion.estado;
        if (estado is! Autenticada || estado.debeCambiarContrasena) return;
        final guardada = await almacen.leer();
        if (guardada == null ||
            !identical(sesion.estado, estado) ||
            !siguePermitido())
          return;
        await http
            .post(
              cliente.config.ruta('/analitica/eventos'),
              headers: {
                'Authorization': 'Bearer ${guardada.accessToken}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(evento),
            )
            .timeout(const Duration(seconds: 5));
      };

      _cliente = cliente;
      _api = api;
      _sesion = sesion;

      _restaurar(sesion);
    } on ApiConfigInvalida catch (e) {
      // Falta --dart-define=API_BASE_URL. Es preferible decirlo con el comando
      // exacto que arrancar apuntando a ningun lado.
      _errorDeArranque = e;
    }
  }

  /// Recupera la sesion guardada antes de decidir que pantalla se ve.
  Future<void> _restaurar(ControladorSesion sesion) async {
    try {
      await sesion.restaurar();
    } finally {
      // Pase lo que pase hay que dejar de esperar: si no se pudo restaurar, se
      // muestra el login, que es el comportamiento de siempre.
      if (mounted) setState(() => _restaurando = false);
    }
  }

  @override
  void dispose() {
    _cliente?.cerrar();
    _sesion?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // shadcn_ui da los componentes (insignias, botones, dialogos); Material
    // sigue debajo para las pantallas que ya existian.
    //
    // El ProviderScope va por fuera del MaterialApp para que tambien lo vean
    // las rutas que se empujan con Navigator. Inyecta los objetos que arma este
    // estado (V2-T01.02): los modulos v2 los leen con `ref.watch`, y la v1
    // sigue recibiendolos por constructor sin cambios.
    return ProviderScope(
      // Politica de reintento de toda la app (V2-T01.08). Sin ella rige la de
      // Riverpod, que reintenta cualquier fallo hasta 10 veces: un 404 se
      // pediria once veces, y un 429 —que significa «deja de pedir»— otras
      // once. Ver `nucleo/datos/reintento.dart`.
      retry: reintentoDelNucleo,
      overrides: [
        preferenciasProvider.overrideWithValue(widget.prefs),
        if (widget.politica != null)
          politicaDatosLocalesProvider.overrideWithValue(widget.politica!),
        if (_cliente != null) apiClienteProvider.overrideWithValue(_cliente!),
        if (_api != null) carecarApiProvider.overrideWithValue(_api!),
        if (_sesion != null)
          controladorSesionProvider.overrideWithValue(_sesion!),
        if (_enviarAnalitica != null)
          transporteAnaliticaProvider.overrideWithValue(_enviarAnalitica),
      ],
      child: _construirApp(),
    );
  }

  Widget _construirApp() {
    return ShadApp.custom(
      theme: TemaCareCar.shad,
      appBuilder: (context) {
        final error = _errorDeArranque;
        if (error != null) {
          return MaterialApp(
            title: 'CareCar',
            theme: TemaCareCar.conFuentes(),
            localizationsDelegates: delegadasDeIdioma,
            supportedLocales: idiomasSoportados,
            localeResolutionCallback: resolverIdioma,
            debugShowCheckedModeBanner: false,
            builder: (context, child) => ShadAppBuilder(child: child!),
            home: _PantallaDeErrorDeArranque(error: error),
          );
        }
        // Navegacion declarativa (ADR 0003, V2-T01.03): el enrutador junta las
        // rutas del nucleo y de los modulos y decide por la sesion.
        return Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            title: 'CareCar',
            theme: TemaCareCar.conFuentes(),
            localizationsDelegates: delegadasDeIdioma,
            supportedLocales: idiomasSoportados,
            locale: ref.watch(idiomaElegidoProvider),
            localeResolutionCallback: resolverIdioma,
            debugShowCheckedModeBanner: false,
            routerConfig: ref.watch(enrutadorProvider),
            // La cortina tapa la app mientras se restaura la sesion: asi no se
            // ve el login un instante antes de saltar a inicio ni a un enlace.
            // Los accesos del icono (V2-M25.04) se registran aqui porque
            // necesitan los textos del idioma activo y el enrutador. El widget
            // de inicio con la proxima cita (V2-M25.01) se mantiene aqui por
            // lo mismo y porque observa la sesion.
            // La cubierta de privacidad (V2-M22.06) va por fuera de todo para
            // tapar tambien la cortina y los dialogos en el selector de apps.
            builder: (context, child) {
              final analitica = ref.read(analiticaProvider);
              Widget contenido([VoidCallback? primeraPantalla]) =>
                  CubiertaEnSegundoPlano(
                    child: InstaladorDeAccesosRapidos(
                      child: SincronizadorDeWidgets(
                        child: ShadAppBuilder(
                          child: AvisoEquipoComprometido(
                            child: CortinaArranque(
                              listo: !_restaurando,
                              duracionMinima: widget.duracionArranque,
                              alTerminar: primeraPantalla,
                              siguiente: (_) => AmbitoAnalitica(
                                analitica: analitica,
                                child: child!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
              final reloj = widget.relojArranque;
              return reloj == null
                  ? contenido()
                  : ObservadorAnalitica(
                      analitica: analitica,
                      reloj: reloj,
                      construir: contenido,
                    );
            },
          ),
        );
      },
    );
  }
}

/// Lo que se ve si la app se compilo sin la direccion de la API.
class _PantallaDeErrorDeArranque extends StatelessWidget {
  const _PantallaDeErrorDeArranque({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 48,
                color: TemaCareCar.peligro,
              ),
              const SizedBox(height: TemaCareCar.espacioCampos),
              Text(
                'Falta configurar la dirección de la API',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TemaCareCar.espacioCampos),
              SelectableText(
                '$error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
