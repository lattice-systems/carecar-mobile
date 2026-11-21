import 'package:flutter/material.dart';

import '../../widgets/dialogos.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../api/carecar_api.dart';
import '../../api/excepciones.dart';
import '../../api/modelos/modelos.dart';
import '../../notificaciones/servicio_notificaciones.dart';
import '../../tema/tema_carecar.dart';
import '../../widgets/tarjeta_intro.dart';
import '../../widgets/pagina_carecar.dart';
import '../../widgets/pantalla.dart';
import 'formato_citas.dart';
import 'ticket_de_cita.dart';
import 'pantalla_agendar_cita.dart';

/// APP-3.3 · Mis citas: las citas de servicio del cliente de la sesion.
class PantallaMisCitas extends StatefulWidget {
  const PantallaMisCitas({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });

  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  static const lista = Key('citas_lista');
  static const botonReintentar = Key('citas_reintentar');
  static const botonAgendar = Key('citas_agendar');
  static const botonCargarMas = Key('citas_cargar_mas');
  static const confirmarCancelacion = Key('citas_confirmar_cancelacion');

  static Key botonCancelar(int citaId) => Key('citas_cancelar_$citaId');

  static Key botonTicket(int citaId) => Key('citas_ticket_$citaId');

  @override
  State<PantallaMisCitas> createState() => _PantallaMisCitasState();
}

/// Lo que necesita la lista: las citas y, para nombrarlos, los vehiculos.
typedef _Datos = ({
  List<Cita> citas,
  Map<int, Vehiculo> vehiculos,
  Pagina<Cita> pagina,
});

class _PantallaMisCitasState extends State<PantallaMisCitas> {
  late Future<_Datos> _datos;

  /// Citas de las paginas que se piden con «Cargar más».
  final _extra = <Cita>[];
  Pagina<Cita>? _ultimaExtra;
  bool _cargandoMas = false;

  /// Ids de las citas que se estan cancelando, para deshabilitar su boton.
  final _cancelando = <int>{};

  static final _deMentira = [
    for (var i = 0; i < 3; i++)
      Cita(
        id: -1 - i,
        vehiculoId: 0,
        fecha: DateTime(2026),
        horaInicio: '09:00',
        horaFin: '10:00',
        estado: EstadoCita.confirmada,
      ),
  ];

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
    // Momento amable para pedir permiso: el cliente vino a ver sus citas.
    Notificaciones.actual.pedirPermisoSiHaceFalta();
  }

  Future<_Datos> _cargar() async {
    final datos = await _leer();
    // Los recordatorios siguen a lo que diga el servidor.
    Notificaciones.actual.sincronizar(
      datos.citas,
      vehiculos: {
        for (final v in datos.vehiculos.values) v.id: '${v.modelo} ${v.anio}',
      },
    );
    return datos;
  }

  Future<_Datos> _leer() async {
    final pagina = await widget.api.paginaDeCitas();
    final citas = pagina.contenido;
    // Si el backend ya manda el nombre del vehiculo no hace falta pedirlos.
    if (citas.every((c) => c.vehiculoNombre != null)) {
      return (citas: citas, vehiculos: const <int, Vehiculo>{}, pagina: pagina);
    }
    // Los vehiculos solo dan el nombre: si fallan, la lista sigue sirviendo.
    final vehiculos = await widget.api.misVehiculos().then<List<Vehiculo>>(
      (v) => v,
      onError: (Object _) => const <Vehiculo>[],
    );
    return (
      citas: citas,
      vehiculos: {for (final v in vehiculos) v.id: v},
      pagina: pagina,
    );
  }

  Future<void> _recargar() async {
    final nuevos = _cargar();
    setState(() {
      _datos = nuevos;
      _extra.clear();
      _ultimaExtra = null;
    });
    try {
      await nuevos;
    } on ExcepcionApi {
      // El FutureBuilder ya muestra el error.
    }
  }

  Future<void> _cargarMas(Pagina<Cita> ultima) async {
    setState(() => _cargandoMas = true);
    try {
      final nueva = await widget.api.paginaDeCitas(pagina: ultima.pagina + 1);
      if (!mounted) return;
      setState(() {
        _extra.addAll(nueva.contenido);
        _ultimaExtra = nueva;
      });
    } on ExcepcionApi catch (e) {
      if (mounted) _avisar(e.mensaje);
    } finally {
      if (mounted) setState(() => _cargandoMas = false);
    }
  }

  Future<void> _agendar() async {
    final agendada = await Navigator.of(context).push<Cita>(
      MaterialPageRoute(
        builder: (_) => PantallaAgendarCita(
          api: widget.api,
          alCerrarSesion: widget.alCerrarSesion,
        ),
      ),
    );
    if (agendada == null || !mounted) return;
    _avisar(
      'Cita agendada para el ${formatoFechaLarga(agendada.fecha)} '
      'a las ${agendada.horaInicio}.',
      exito: true,
    );
    await _recargar();
  }

  Future<void> _cancelar(Cita cita) async {
    final seguro = await confirmarAccion(
      context,
      titulo: '¿Cancelar esta cita?',
      descripcion:
          'Se liberará tu lugar del ${formatoFechaLarga(cita.fecha)} '
          'de ${cita.horaInicio} a ${cita.horaFin}. '
          'Esta acción no se puede deshacer.',
      textoConfirmar: 'Sí, cancelar',
      textoCancelar: 'Conservar',
      destructiva: true,
      llaveConfirmar: PantallaMisCitas.confirmarCancelacion,
    );
    if (!seguro || !mounted) return;

    setState(() => _cancelando.add(cita.id));
    try {
      await widget.api.cancelarCita(cita.id);
      await Notificaciones.actual.alCancelar(cita.id);
      if (!mounted) return;
      _avisar('Tu cita fue cancelada.', exito: true);
    } on Conflicto catch (e) {
      if (!mounted) return;
      _avisar(
        e.mensaje.isNotEmpty
            ? e.mensaje
            : 'Esta cita ya no se puede cancelar desde la app.',
      );
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      _avisar(e.mensaje);
    } finally {
      if (mounted) setState(() => _cancelando.remove(cita.id));
    }
    await _recargar();
  }

  void _avisar(String texto, {bool exito = false}) =>
      mostrarToast(context, texto, exito: exito, error: !exito);

  @override
  Widget build(BuildContext context) {
    return PaginaCareCar(
      titulo: 'Mis citas',
      anchoMaximo: Pantalla.anchoLectura,
      expandir: true,
      alCerrarSesion: widget.alCerrarSesion,
      contenido: _cuerpo(),
    );
  }

  Widget _cuerpo() {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _recargar,
          color: TemaCareCar.azulAgencia,
          child: CustomScrollView(
            key: PantallaMisCitas.lista,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // En horizontal la tarjeta de presentacion se omite: el espacio es
              // para el contenido.
              if (!Pantalla.esBaja(context))
                const SliverToBoxAdapter(child: _Encabezado()),
              FutureBuilder<_Datos>(
                future: _datos,
                builder: (context, foto) {
                  final cargando = foto.connectionState != ConnectionState.done;

                  if (!cargando && foto.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _Error(error: foto.error, alReintentar: _recargar),
                    );
                  }

                  if (cargando) {
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: Skeletonizer.sliver(
                        child: SliverList.separated(
                          itemCount: _deMentira.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) =>
                              TarjetaCita(cita: _deMentira[i]),
                        ),
                      ),
                    );
                  }

                  final datos = foto.data!;
                  if (datos.citas.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _Vacio(alAgendar: _agendar),
                    );
                  }

                  return SliverPadding(
                    // Deja espacio para el boton flotante.
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    sliver: SliverList.list(children: _filas(datos).toList()),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            key: PantallaMisCitas.botonAgendar,
            heroTag: 'agendar-cita',
            onPressed: _agendar,
            backgroundColor: TemaCareCar.azulAgencia,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Agendar cita'),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
        ),
      ],
    );
  }

  /// Primero las proximas (la mas cercana arriba), luego el historial.
  Iterable<Widget> _filas(_Datos datos) sync* {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    bool esProxima(Cita c) =>
        c.estado == EstadoCita.confirmada &&
        !DateTime(c.fecha.year, c.fecha.month, c.fecha.day).isBefore(inicioHoy);

    int porFecha(Cita a, Cita b) {
      final f = a.fecha.compareTo(b.fecha);
      return f != 0 ? f : a.horaInicio.compareTo(b.horaInicio);
    }

    final todas = [...datos.citas, ..._extra];
    final proximas = todas.where(esProxima).toList()..sort(porFecha);
    final pasadas = todas.where((c) => !esProxima(c)).toList()
      ..sort((a, b) => porFecha(b, a));

    var i = 0;
    Widget animar(Widget w) => w
        .animate(delay: (70 * i++).clamp(0, 600).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.12, curve: Curves.easeOutCubic);

    Iterable<Widget> seccion(String titulo, List<Cita> citas) sync* {
      if (citas.isEmpty) return;
      yield animar(_TituloSeccion(titulo: titulo, cuantas: citas.length));
      for (final c in citas) {
        yield Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: animar(
            TarjetaCita(
              cita: c,
              vehiculo: datos.vehiculos[c.vehiculoId],
              cancelando: _cancelando.contains(c.id),
              alVerTicket: () => abrirTicketDeCita(
                context,
                widget.api,
                c,
                widget.alCerrarSesion,
              ),
              alCancelar: esProxima(c) && c.sePuedeCancelar
                  ? () => _cancelar(c)
                  : null,
            ),
          ),
        );
      }
    }

    yield* seccion('Próximas', proximas);
    yield* seccion('Historial', pasadas);

    final ultima = _ultimaExtra ?? datos.pagina;
    if (ultima.hayMas) {
      yield Center(
        child: OutlinedButton.icon(
          key: PantallaMisCitas.botonCargarMas,
          onPressed: _cargandoMas ? null : () => _cargarMas(ultima),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, TemaCareCar.altoMinimoToque),
          ),
          icon: _cargandoMas
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.expand_more),
          label: Text(_cargandoMas ? 'Cargando…' : 'Cargar más'),
        ),
      );
    }
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) => const TarjetaIntro(
    etiqueta: 'SERVICIO EN TALLER',
    titulo: 'Tus citas',
    texto: 'Agenda tu visita al taller y consulta tus citas.',
    icono: Icons.calendar_month_rounded,
    color: Color(0xFF3B5BA9),
    fondo: Color(0xFFEAEFFA),
  );
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.titulo, required this.cuantas});

  final String titulo;
  final int cuantas;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Row(
        children: [
          Text(
            titulo.toUpperCase(),
            style: temas.labelSmall?.copyWith(
              color: TemaCareCar.textoSecundario,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: TemaCareCar.azulSuave,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$cuantas',
              style: temas.labelSmall?.copyWith(
                color: TemaCareCar.azulAgencia,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de una cita: fecha destacada, horario, vehiculo y estado.
class TarjetaCita extends StatelessWidget {
  const TarjetaCita({
    required this.cita,
    this.vehiculo,
    this.alCancelar,
    this.alVerTicket,
    this.cancelando = false,
    super.key,
  });

  final Cita cita;
  final Vehiculo? vehiculo;
  final VoidCallback? alCancelar;

  /// Abre el ticket en PDF; tambien sirve en citas canceladas.
  final VoidCallback? alVerTicket;
  final bool cancelando;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final c = cita;
    final activa = c.estado == EstadoCita.confirmada;
    final v = vehiculo;
    final nombreVehiculo =
        c.vehiculoNombre ??
        (v == null
            ? 'Vehículo #${c.vehiculoId}'
            : [v.marca, v.modelo].whereType<String>().join(' '));

    return Container(
      decoration: BoxDecoration(
        color: TemaCareCar.tarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TemaCareCar.borde),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Calendario(fecha: c.fecha, activa: activa),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatoFechaLarga(c.fecha),
                      style: temas.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: TemaCareCar.turquesaOscuro,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${c.horaInicio} – ${c.horaFin}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: temas.bodyMedium?.copyWith(
                              color: TemaCareCar.textoSecundario,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ChipEstadoCita(estado: c.estado),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: TemaCareCar.fondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car_filled_outlined,
                  size: 18,
                  color: TemaCareCar.turquesaOscuro,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nombreVehiculo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: temas.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (v?.placas != null)
                  Text(
                    v!.placas!,
                    style: TemaCareCar.mono.merge(
                      const TextStyle(
                        fontSize: 13,
                        color: TemaCareCar.textoSecundario,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (alVerTicket != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ShadButton.outline(
                key: PantallaMisCitas.botonTicket(c.id),
                onPressed: alVerTicket,
                leading: const Icon(Icons.receipt_long_outlined, size: 18),
                // Flexible: con letra grande y pantalla angosta el texto se
                // recorta en vez de desbordar la fila del boton.
                child: const Flexible(
                  child: Text(
                    'Ver ticket',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
          if (alCancelar != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: PantallaMisCitas.botonCancelar(c.id),
                onPressed: cancelando ? null : alCancelar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TemaCareCar.peligro,
                  side: const BorderSide(color: TemaCareCar.peligroFondo),
                  backgroundColor: TemaCareCar.peligroFondo.withValues(
                    alpha: 0.4,
                  ),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: cancelando
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close, size: 18),
                label: Text(cancelando ? 'Cancelando…' : 'Cancelar cita'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bloque con el dia y el mes, como una hoja de calendario.
class _Calendario extends StatelessWidget {
  const _Calendario({required this.fecha, required this.activa});

  final DateTime fecha;
  final bool activa;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 56, minHeight: 60),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: activa ? TemaCareCar.degradadoMarca : null,
        color: activa ? null : TemaCareCar.fondo,
        borderRadius: BorderRadius.circular(16),
        border: activa ? null : Border.all(color: TemaCareCar.borde),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            mesCorto(fecha).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: activa
                  ? TemaCareCar.turquesa
                  : TemaCareCar.textoSecundario,
            ),
          ),
          Text(
            '${fecha.day}',
            style: TextStyle(
              fontSize: 22,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: activa ? Colors.white : TemaCareCar.textoPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip con el estado de la cita y su color semantico.
class ChipEstadoCita extends StatelessWidget {
  const ChipEstadoCita({required this.estado, super.key});

  final EstadoCita estado;

  @override
  Widget build(BuildContext context) {
    final (texto, color, fondo, icono) = switch (estado) {
      EstadoCita.confirmada => (
        'Confirmada',
        TemaCareCar.azulAgencia,
        TemaCareCar.azulSuave,
        Icons.event_available,
      ),
      EstadoCita.atendida => (
        'Atendida',
        TemaCareCar.exito,
        TemaCareCar.exitoFondo,
        Icons.check_circle_outline,
      ),
      EstadoCita.noAsistio => (
        'No asistió',
        TemaCareCar.advertencia,
        TemaCareCar.advertenciaFondo,
        Icons.person_off_outlined,
      ),
      EstadoCita.cancelada => (
        'Cancelada',
        TemaCareCar.peligro,
        TemaCareCar.peligroFondo,
        Icons.cancel_outlined,
      ),
      EstadoCita.desconocido => (
        'Sin estado',
        TemaCareCar.textoSecundario,
        TemaCareCar.fondo,
        Icons.help_outline,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.alAgendar});

  final VoidCallback alAgendar;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: TemaCareCar.azulSuave,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 44,
              color: TemaCareCar.azulAgencia,
            ),
          ),
          const SizedBox(height: 16),
          Text('Aún no tienes citas', style: temas.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Elige el día y la hora que te acomoden para llevar tu vehículo '
            'al taller.',
            textAlign: TextAlign.center,
            style: temas.bodyMedium?.copyWith(
              color: TemaCareCar.textoSecundario,
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.error, required this.alReintentar});

  final Object? error;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final sinRed = error is SinConexion;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            sinRed ? Icons.wifi_off_rounded : Icons.error_outline,
            size: 56,
            color: TemaCareCar.peligro,
          ),
          const SizedBox(height: 16),
          Text(
            sinRed ? 'Sin conexión' : 'No pudimos cargar tus citas',
            style: temas.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            sinRed
                ? 'Revisa tu conexión a internet e inténtalo de nuevo.'
                : 'Ocurrió un problema con el servidor. Inténtalo de nuevo.',
            textAlign: TextAlign.center,
            style: temas.bodyMedium?.copyWith(
              color: TemaCareCar.textoSecundario,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: PantallaMisCitas.botonReintentar,
            onPressed: alReintentar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ).animate().fadeIn().shake(hz: 3, offset: const Offset(4, 0)),
    );
  }
}
