import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../../../sesion/controlador_sesion.dart';
import '../../citas/citas.dart';
import '../dominio/proxima_cita_widget.dart';
import 'proveedores_widgets.dart';

/// Mantiene al dia el widget de pantalla de inicio con la proxima cita
/// (V2-M25.01).
///
/// Va una sola vez, por dentro del `MaterialApp` (en su `builder`) para tener
/// los textos del idioma activo. No pinta nada propio: devuelve [child].
///
/// Publica de nuevo cuando:
/// - cambian las citas del cliente (agendar, cancelar o reprogramar actualizan
///   `misCitasProvider`);
/// - la persona abre o cierra sesion: al salir, el widget queda sin datos de
///   ninguna cita para no dejar informacion en la pantalla de inicio;
/// - cambia el idioma, o la app vuelve al primer plano (la cita pudo empezar).
///
/// Si no se pueden cargar las citas, deja lo ultimo que se mostro. Un sistema
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(estadoSesionProvider, (_, _) => _sincronizar());
  }

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
      _publicarCitas();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _citas?.close();
    super.dispose();
  }

  /// Decide de donde sale el contenido segun la sesion.
  void _sincronizar() {
    if (ref.read(estadoSesionProvider) is! Autenticada) {
      // Sin sesion no se piden citas y el widget no conserva ninguna.
      _citas?.close();
      _citas = null;
      _enviar(_sinCita(AppLocalizations.of(context)));
      return;
    }
    if (_citas == null) {
      _citas = ref.listenManual(
        misCitasProvider,
        (_, _) => _publicarCitas(),
        fireImmediately: true,
      );
    } else {
      _publicarCitas();
    }
  }

  void _publicarCitas() {
    if (!mounted) return;
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
