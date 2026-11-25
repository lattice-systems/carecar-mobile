import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../../../nucleo/seguridad/politica_datos_locales.dart';
import '../../../nucleo/seguridad/proveedores_seguridad.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../../../sesion/controlador_sesion.dart';
import '../../bitacora/bitacora.dart';
import '../../citas/citas.dart';
import '../../mantenimiento/mantenimiento.dart';
import '../../taller/taller.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/contenido_widgets.dart';
import '../dominio/proxima_cita_widget.dart';
import 'constructores_de_widgets.dart';
import 'proveedores_widgets.dart';

/// Mantiene al día los widgets de pantalla de inicio (V2-M25): próxima cita,
/// taller en vivo, mantenimiento, bitácora y accesos rápidos. Cada uno se
/// agrega por separado desde el selector del sistema; aquí se publican los
/// cinco con sus claves propias y cada widget nativo pinta solo las suyas.
///
/// Va una sola vez, por dentro del `MaterialApp` (en su `builder`) para tener
/// los textos del idioma activo. No pinta nada propio: devuelve [child].
///
/// De dónde sale cada uno:
/// - **Próxima cita y accesos:** `misCitasProvider` (la confirmada que empieza
///   primero; el comprobante de los accesos apunta a ella).
/// - **Taller en vivo:** `ordenesEnCursoProvider`, la primera orden abierta.
/// - **Mantenimiento y bitácora:** el primer vehículo del garaje
///   (`garajeProvider`): su plan de mantenimiento y sus gastos.
///
/// Publica de nuevo cuando cambian esas fuentes, llega el evento `orden` por el
/// canal en vivo (o el canal se reconecta), cambia el idioma o la sesión, o la
/// app vuelve al primer plano (la cita pudo empezar, el mes pudo cambiar). Un
/// contenido igual al último publicado no se repinta.
///
/// Si una fuente falla o aún no carga, ese widget conserva lo último que
/// mostraba. Al cerrar sesión, o en un equipo comprometido
/// (`PoliticaDatosLocales`), se borran los datos de todos los widgets y no se
/// consulta nada. Un sistema sin widgets no afecta a la app. No se escribe
/// nada en logs: el contenido es del cliente.
class SincronizadorDeWidgets extends ConsumerStatefulWidget {
  const SincronizadorDeWidgets({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SincronizadorDeWidgets> createState() =>
      _SincronizadorDeWidgetsState();
}

class _SincronizadorDeWidgetsState extends ConsumerState<SincronizadorDeWidgets>
    with WidgetsBindingObserver {
  Locale? _idioma;
  final _fuentes = <ProviderSubscription<Object?>>[];
  final _fuentesDelVehiculo = <ProviderSubscription<Object?>>[];
  int? _vehiculoSuscrito;
  final _ultimo = <TipoWidget, ContenidoWidget>{};

  bool get _suscrito => _fuentes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(estadoSesionProvider, (_, _) => _sincronizar());
    // En un equipo con root o jailbreak los widgets no conservan datos del
    // cliente (V2-M22.05): si la detección llega tarde, se vacían al llegar.
    _politica = ref.read(politicaDatosLocalesProvider)
      ..addListener(_sincronizar);
  }

  late final PoliticaDatosLocales _politica;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final idioma = Localizations.localeOf(context);
    if (idioma == _idioma) return;
    _idioma = idioma;
    _sincronizar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed && _suscrito) {
      // La orden o el plan pudieron avanzar con la app en segundo plano.
      _refrescarOrdenesYPlan();
      _publicar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _politica.removeListener(_sincronizar);
    _cerrarFuentes();
    super.dispose();
  }

  /// Decide de dónde salen los contenidos según la sesión.
  void _sincronizar() {
    if (ref.read(estadoSesionProvider) is! Autenticada ||
        !_politica.permiteCacheLocal) {
      // Sin sesión (o en un equipo comprometido) no se piden datos y los
      // widgets no conservan ninguno.
      _cerrarFuentes();
      _ultimo.clear();
      unawaited(_borrar());
      return;
    }
    if (!_suscrito) {
      _fuentes
        ..add(ref.listenManual(ordenesEnCursoProvider, (_, _) => _publicar()))
        ..add(ref.listenManual(garajeProvider, (_, _) => _alCambiarElGaraje()))
        ..add(ref.listenManual(misCitasProvider, (_, _) => _publicar()));
      _fuentes.add(
        ref.listenManual<AsyncValue<EventoEnVivo>>(
          eventosProvider,
          (_, evento) => evento.whenData(_alLlegar),
        ),
      );
      _alCambiarElGaraje();
    } else {
      _publicar();
    }
  }

  void _cerrarFuentes() {
    for (final fuente in [..._fuentes, ..._fuentesDelVehiculo]) {
      fuente.close();
    }
    _fuentes.clear();
    _fuentesDelVehiculo.clear();
    _vehiculoSuscrito = null;
  }

  /// El taller avisó que cambió una orden, o el canal volvió tras una caída
  /// (pudo perderse algún aviso): se consultan de nuevo las órdenes y el plan
  /// (al cerrarse una orden el taller deja un km nuevo).
  void _alLlegar(EventoEnVivo evento) {
    if (evento.nombre == 'orden' || evento.nombre == eventoReconectado) {
      _refrescarOrdenesYPlan();
    }
  }

  void _refrescarOrdenesYPlan() {
    ref.invalidate(ordenesEnCursoProvider);
    final vehiculo = _vehiculoSuscrito;
    if (vehiculo != null) ref.invalidate(planMantenimientoProvider(vehiculo));
  }

  /// El vehículo de mantenimiento y bitácora es el primero del garaje; si
  /// cambia, se escuchan su plan y sus gastos.
  void _alCambiarElGaraje() {
    final id = ref.read(garajeProvider).value?.firstOrNull?.id;
    if (id != _vehiculoSuscrito) {
      for (final fuente in _fuentesDelVehiculo) {
        fuente.close();
      }
      _fuentesDelVehiculo.clear();
      _vehiculoSuscrito = id;
      if (id != null) {
        _fuentesDelVehiculo.addAll([
          ref.listenManual(
            planMantenimientoProvider(id),
            (_, _) => _publicar(),
          ),
          ref.listenManual(gastosProvider(id), (_, _) => _publicar()),
        ]);
      }
    }
    _publicar();
  }

  /// Construye cada widget con lo que ya se cargó y publica los que cambiaron.
  /// Una fuente que carga o falla sin dato previo no se publica: el widget
  /// conserva lo último.
  void _publicar() {
    if (!mounted || !_suscrito) return;
    final textos = AppLocalizations.of(context);

    final citas = ref.read(misCitasProvider).value;
    final proxima = citas == null
        ? null
        : proximaCita(citas.citas, ref.read(relojCitasProvider)());
    if (citas != null) _enviar(contenidoDeCita(textos, proxima));
    // Los accesos no dependen de la red: sin citas cargadas, el comprobante
    // apunta a la lista de citas.
    _enviar(contenidoDeAccesos(textos, proxima));

    final ordenes = ref.read(ordenesEnCursoProvider).value;
    if (ordenes != null) {
      _enviar(contenidoDeTaller(textos, ordenes.firstOrNull));
    }

    final autos = ref.read(garajeProvider).value;
    if (autos == null) return;
    final vehiculo = autos.firstOrNull;
    if (vehiculo == null) {
      _enviar(contenidoDeMantenimiento(textos, null, null));
      _enviar(contenidoDeBitacora(textos, null, null, DateTime.now()));
      return;
    }
    final plan = ref.read(planMantenimientoProvider(vehiculo.id)).value;
    if (plan != null) {
      _enviar(contenidoDeMantenimiento(textos, plan, vehiculo));
    }
    final gastos = ref.read(gastosProvider(vehiculo.id)).value;
    if (gastos != null) {
      _enviar(
        contenidoDeBitacora(
          textos,
          gastos,
          vehiculo,
          ref.read(relojBitacoraProvider)(),
        ),
      );
    }
  }

  void _enviar(ContenidoWidget contenido) {
    if (_ultimo[contenido.tipo] == contenido) return;
    _ultimo[contenido.tipo] = contenido;
    unawaited(_entregar(contenido));
  }

  Future<void> _entregar(ContenidoWidget contenido) async {
    try {
      await ref.read(puertoWidgetsProvider).publicar(contenido);
    } on Object {
      // Un sistema sin widgets (escritorio, emulador sin lanzador) no debe
      // afectar a la app. No se registra nada: el contenido es del cliente.
    }
  }

  Future<void> _borrar() async {
    try {
      await ref.read(puertoWidgetsProvider).borrarTodo();
    } on Object {
      // Igual que al publicar: sin widgets no hay nada que borrar.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
