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
import '../../citas/citas.dart';
import '../../taller/taller.dart';
import '../dominio/proxima_cita_widget.dart';
import 'proveedores_widgets.dart';

/// Mantiene al dia el widget de pantalla de inicio: el estado del auto en el
/// taller si hay una orden abierta (V2-M25.02) y, si no, la proxima cita
/// (V2-M25.01).
///
/// Va una sola vez, por dentro del `MaterialApp` (en su `builder`) para tener
/// los textos del idioma activo. No pinta nada propio: devuelve [child].
///
/// Publica de nuevo cuando:
/// - cambian las citas del cliente (agendar, cancelar o reprogramar actualizan
///   `misCitasProvider`) o sus ordenes abiertas (`ordenesEnCursoProvider`);
/// - llega el evento `orden` por el canal en vivo, o el canal se reconecta
///   (se consultan de nuevo las ordenes; el canal solo se abre con sesion);
/// - la persona abre o cierra sesion (o el equipo resulta comprometido, ver
///   `PoliticaDatosLocales`): al salir, el widget queda sin datos de
///   ninguna cita para no dejar informacion en la pantalla de inicio;
/// - cambia el idioma, o la app vuelve al primer plano (la cita pudo empezar).
///
/// Si no se pueden cargar las citas, deja lo ultimo que se mostro. Si no se
/// pueden cargar las ordenes y nunca se cargaron, se muestra la cita. Un sistema
/// sin widgets no afecta a la app. Nada de esto se escribe en logs.
class SincronizadorDelWidgetDeCita extends ConsumerStatefulWidget {
  const SincronizadorDelWidgetDeCita({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SincronizadorDelWidgetDeCita> createState() =>
      _SincronizadorDelWidgetDeCitaState();
}

class _SincronizadorDelWidgetDeCitaState
    extends ConsumerState<SincronizadorDelWidgetDeCita>
    with WidgetsBindingObserver {
  Locale? _idioma;
  ProviderSubscription<Object?>? _citas;
  ProviderSubscription<Object?>? _ordenes;
  ProviderSubscription<AsyncValue<EventoEnVivo>>? _eventos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(estadoSesionProvider, (_, _) => _sincronizar());
    // En un equipo con root o jailbreak el widget no conserva datos del cliente
    // (V2-M22.05): si la deteccion llega tarde, se vacia en cuanto llega.
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
    if (estado == AppLifecycleState.resumed && _citas != null) {
      // La orden pudo avanzar mientras la app estaba en segundo plano.
      ref.invalidate(ordenesEnCursoProvider);
      _publicar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _politica.removeListener(_sincronizar);
    _cerrarSuscripciones();
    super.dispose();
  }

  /// Decide de donde sale el contenido segun la sesion.
  void _sincronizar() {
    if (ref.read(estadoSesionProvider) is! Autenticada ||
        !_politica.permiteCacheLocal) {
      // Sin sesion (o en un equipo comprometido) no se piden citas y el widget
      // no conserva ninguna.
      _cerrarSuscripciones();
      _enviar(_sinCita(AppLocalizations.of(context)));
      return;
    }
    if (_citas == null) {
      _ordenes = ref.listenManual(
        ordenesEnCursoProvider,
        (_, _) => _publicar(),
      );
      _eventos = ref.listenManual(
        eventosProvider,
        (_, evento) => evento.whenData(_alLlegar),
      );
      _citas = ref.listenManual(
        misCitasProvider,
        (_, _) => _publicar(),
        fireImmediately: true,
      );
    } else {
      _publicar();
    }
  }

  void _cerrarSuscripciones() {
    _citas?.close();
    _ordenes?.close();
    _eventos?.close();
    _citas = null;
    _ordenes = null;
    _eventos = null;
  }

  /// El taller aviso que cambio una orden, o el canal volvio tras una caida
  /// (pudo perderse algun aviso): se consultan de nuevo las ordenes.
  void _alLlegar(EventoEnVivo evento) {
    if (evento.nombre == 'orden' || evento.nombre == eventoReconectado) {
      ref.invalidate(ordenesEnCursoProvider);
    }
  }

  /// Con una orden abierta se muestra el auto en el taller; sin ella, la
  /// proxima cita.
  void _publicar() {
    if (!mounted) return;
    final ordenes = ref.read(ordenesEnCursoProvider);
    // Las ordenes aun no llegan: se espera para no mostrar la cita un instante.
    // Si fallan, `value` es nulo y se sigue con la cita.
    if (ordenes.isLoading && !ordenes.hasValue) return;
    final abierta = ordenes.value?.firstOrNull;
    if (abierta != null) {
      _enviar(_enTaller(abierta));
    } else {
      _publicarCitas();
    }
  }

  ContenidoWidgetCita _enTaller(OrdenEnCurso orden) {
    final textos = AppLocalizations.of(context);
    final entrega = orden.entregaEstimada;
    return ContenidoWidgetCita.enTaller(
      titulo: textos.widgetsTallerTitulo,
      etapa: textoEtapa(textos, orden.etapa),
      entrega: entrega == null
          ? null
          : textos.widgetsTallerEntrega(horaTaller(context, entrega)),
      vehiculo: orden.vehiculo,
      ordenId: orden.id,
    );
  }

  void _publicarCitas() {
    final estado = ref.read(misCitasProvider).value;
    // Cargando o con error: se conserva lo ultimo que se mostro.
    if (estado == null) return;
    final textos = AppLocalizations.of(context);
    final ahora = ref.read(relojCitasProvider)();
    final cita = proximaCita(estado.citas, ahora);
    _enviar(
      cita == null
          ? _sinCita(textos)
          : ContenidoWidgetCita.conCita(
              titulo: textos.widgetsProximaCitaTitulo,
              fecha: textos.widgetsProximaCitaFecha(cita.fecha),
              horario: textos.widgetsProximaCitaHorario(
                cita.horaInicio,
                cita.horaFin,
              ),
              vehiculo: cita.vehiculoNombre,
              citaId: cita.id,
            ),
    );
  }

  ContenidoWidgetCita _sinCita(AppLocalizations textos) =>
      ContenidoWidgetCita.sinCita(
        titulo: textos.widgetsProximaCitaTitulo,
        mensaje: textos.widgetsSinCitaMensaje,
        accion: textos.widgetsAccesoAgendar,
      );

  void _enviar(ContenidoWidgetCita contenido) {
    unawaited(_entregar(contenido));
  }

  Future<void> _entregar(ContenidoWidgetCita contenido) async {
    try {
      await ref.read(puertoWidgetCitaProvider).publicar(contenido);
    } on Object {
      // Un sistema sin widgets (escritorio, emulador sin lanzador) no debe
      // afectar a la app. No se registra nada: el contenido es del cliente.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
