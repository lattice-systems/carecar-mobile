import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../api/carecar_api.dart';
import '../../api/excepciones.dart';
import '../../api/modelos/modelos.dart';
import '../../tema/tema_carecar.dart';
import '../../widgets/pagina_carecar.dart';
import '../../widgets/pantalla.dart';
import 'formato_citas.dart';

/// APP-3.3 · Agendar cita: vehiculo, dia y franja con cupo.
///
/// Al agendar, cierra la pantalla devolviendo la [Cita] creada.
class PantallaAgendarCita extends StatefulWidget {
  const PantallaAgendarCita({
    required this.api,
    required this.alCerrarSesion,
    this.hoy,
    super.key,
  });

  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  /// El dia de hoy. Las pruebas lo fijan para no depender del reloj.
  final DateTime? hoy;

  /// Cuantos dias hacia adelante se ofrecen.
  static const diasVisibles = 14;

  static const botonConfirmar = Key('agendar_confirmar');
  static const botonReintentar = Key('agendar_reintentar');

  static Key dia(DateTime f) => Key('agendar_dia_${f.month}_${f.day}');
  static Key franja(int franjaId) => Key('agendar_franja_$franjaId');
  static Key vehiculo(int id) => Key('agendar_vehiculo_$id');

  @override
  State<PantallaAgendarCita> createState() => _PantallaAgendarCitaState();
}

class _PantallaAgendarCitaState extends State<PantallaAgendarCita> {
  late final DateTime _hoy;
  late final List<DateTime> _dias;

  late Future<List<Vehiculo>> _vehiculos;
  late Future<List<Disponibilidad>> _franjas;

  int? _vehiculoId;
  late DateTime _dia;
  Disponibilidad? _franja;
  bool _enviando = false;

  /// El dia ya se eligio a mano: al recargar no se mueve solo.
  bool _diaElegido = false;

  static final _franjasDeMentira = [
    for (var i = 0; i < 6; i++)
      Disponibilidad(
        fecha: DateTime(2026),
        franjaId: -1 - i,
        horaInicio: '09:00',
        horaFin: '10:00',
        cupoDisponible: 1,
      ),
  ];

  @override
  void initState() {
    super.initState();
    final ahora = widget.hoy ?? DateTime.now();
    _hoy = DateTime(ahora.year, ahora.month, ahora.day);
    _dias = [
      for (var i = 0; i < PantallaAgendarCita.diasVisibles; i++)
        DateTime(_hoy.year, _hoy.month, _hoy.day + i),
    ];
    _dia = _hoy;
    _vehiculos = widget.api.misVehiculos().then((v) {
      if (mounted && v.length == 1) setState(() => _vehiculoId = v.first.id);
      return v;
    });
    _franjas = _cargarFranjas();
  }

  Future<List<Disponibilidad>> _cargarFranjas() async {
    final franjas = await widget.api.disponibilidad(
      desde: _dias.first,
      hasta: _dias.last,
    );
    // Sin dia elegido, se salta al primero que tenga lugar.
    if (mounted && !_diaElegido) {
      final primero = _dias.where(
        (d) => franjas.any((f) => mismoDia(f.fecha, d)),
      );
      if (primero.isNotEmpty) setState(() => _dia = primero.first);
    }
    return franjas;
  }

  void _recargarFranjas() {
    setState(() {
      _franja = null;
      _franjas = _cargarFranjas();
    });
  }

  void _recargarTodo() {
    setState(() {
      _vehiculos = widget.api.misVehiculos();
      _franja = null;
      _franjas = _cargarFranjas();
    });
  }

  bool get _listo => _vehiculoId != null && _franja != null && !_enviando;

  Future<void> _confirmar() async {
    final franja = _franja;
    final vehiculoId = _vehiculoId;
    if (franja == null || vehiculoId == null) return;

    setState(() => _enviando = true);
    try {
      final cita = await widget.api.agendarCita(
        NuevaCita(
          vehiculoId: vehiculoId,
          franjaId: franja.franjaId,
          fecha: franja.fecha,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(cita);
    } on Conflicto catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      _avisar(
        e.mensaje.isNotEmpty
            ? e.mensaje
            : 'Ese horario se acaba de ocupar. Elige otro, por favor.',
        titulo: 'Horario no disponible',
      );
      _recargarFranjas();
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      _avisar(e.mensaje);
    }
  }

  void _avisar(String texto, {String? titulo}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: TemaCareCar.textoPrincipal,
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titulo != null)
                      Text(
                        titulo,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    Text(texto),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PaginaCareCar(
      titulo: 'Agendar cita',
      anchoMaximo: Pantalla.anchoLectura,
      expandir: true,
      alCerrarSesion: widget.alCerrarSesion,
      contenido: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // En horizontal la tarjeta de presentacion se omite: el espacio es
                // para el contenido.
                if (!Pantalla.esBaja(context))
                  const SliverToBoxAdapter(child: _Encabezado()),
                SliverToBoxAdapter(
                  child: _Seccion(
                    paso: 1,
                    titulo: 'Vehículo',
                    child: _elegirVehiculo(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Seccion(paso: 2, titulo: 'Día', child: _tiraDias()),
                ),
                SliverToBoxAdapter(
                  child: _Seccion(
                    paso: 3,
                    titulo: 'Horario',
                    child: _franjasDelDia(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
          _barraConfirmar(context),
        ],
      ),
    );
  }

  Widget _elegirVehiculo() {
    return FutureBuilder<List<Vehiculo>>(
      future: _vehiculos,
      builder: (context, foto) {
        if (foto.connectionState != ConnectionState.done) {
          return const Skeletonizer(
            child: _OpcionVehiculo(
              vehiculo: Vehiculo(id: 0, vin: 'X', modelo: 'Modelo', anio: 2026),
              elegido: false,
            ),
          );
        }
        if (foto.hasError) {
          return _AvisoEnLinea(
            icono: Icons.error_outline,
            texto: 'No pudimos cargar tus vehículos.',
            alReintentar: _recargarTodo,
          );
        }
        final vehiculos = foto.data!;
        if (vehiculos.isEmpty) {
          return const _AvisoEnLinea(
            icono: Icons.no_crash_outlined,
            texto:
                'No tienes vehículos registrados. La agencia debe registrar '
                'tu unidad antes de agendar.',
          );
        }
        return Column(
          children: [
            for (final (i, v) in vehiculos.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:
                    _OpcionVehiculo(
                          key: PantallaAgendarCita.vehiculo(v.id),
                          vehiculo: v,
                          elegido: v.id == _vehiculoId,
                          alTocar: () => setState(() => _vehiculoId = v.id),
                        )
                        .animate(delay: (60 * i).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.05),
              ),
          ],
        );
      },
    );
  }

  Widget _tiraDias() {
    return FutureBuilder<List<Disponibilidad>>(
      future: _franjas,
      builder: (context, foto) {
        final franjas = foto.connectionState == ConnectionState.done
            ? foto.data ?? const <Disponibilidad>[]
            : const <Disponibilidad>[];
        // Crece con la letra del sistema para que el dia no se recorte.
        final escala = MediaQuery.textScalerOf(context);
        return SizedBox(
          height: 40 + escala.scale(46),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _dias.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final d = _dias[i];
              final conLugar = franjas.any((f) => mismoDia(f.fecha, d));
              return _Dia(
                    key: PantallaAgendarCita.dia(d),
                    fecha: d,
                    esHoy: i == 0,
                    elegido: mismoDia(d, _dia),
                    conLugar: conLugar,
                    alTocar: () => setState(() {
                      _diaElegido = true;
                      _dia = d;
                      _franja = null;
                    }),
                  )
                  .animate(delay: (30 * i).ms)
                  .fadeIn(duration: 250.ms)
                  .slideX(begin: 0.2, curve: Curves.easeOutCubic);
            },
          ),
        );
      },
    );
  }

  Widget _franjasDelDia() {
    return FutureBuilder<List<Disponibilidad>>(
      future: _franjas,
      builder: (context, foto) {
        final cargando = foto.connectionState != ConnectionState.done;
        if (!cargando && foto.hasError) {
          return _AvisoEnLinea(
            icono: foto.error is SinConexion
                ? Icons.wifi_off_rounded
                : Icons.error_outline,
            texto: foto.error is SinConexion
                ? 'Sin conexión. Revisa tu internet.'
                : 'No pudimos consultar los horarios.',
            alReintentar: _recargarFranjas,
          );
        }

        final delDia = cargando
            ? _franjasDeMentira
            : (foto.data!.where((f) => mismoDia(f.fecha, _dia)).toList()
                ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio)));

        if (!cargando && delDia.isEmpty) {
          return _AvisoEnLinea(
            icono: Icons.event_busy_outlined,
            texto:
                'No hay horarios disponibles el '
                '${formatoFechaLarga(_dia).toLowerCase()}. Prueba otro día.',
          );
        }

        return Skeletonizer(
          enabled: cargando,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!cargando)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    formatoFechaLarga(_dia),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: TemaCareCar.textoSecundario),
                  ),
                ),
              // Rejilla de columnas iguales: con Wrap los chips de ancho
              // distinto («Último lugar») dejaban horarios solos en su fila.
              LayoutBuilder(
                builder: (context, limites) {
                  const espacio = 10.0;
                  final minimo = MediaQuery.textScalerOf(context)
                      .scale(104)
                      .clamp(104.0, 220.0);
                  final columnas =
                      ((limites.maxWidth + espacio) / (minimo + espacio))
                          .floor()
                          .clamp(2, 6);
                  final ancho =
                      (limites.maxWidth - espacio * (columnas - 1)) / columnas;
                  return Wrap(
                    spacing: espacio,
                    runSpacing: espacio,
                    children: [
                      for (final (i, f) in delDia.indexed)
                        SizedBox(
                              width: ancho,
                              child: _ChipFranja(
                                key: PantallaAgendarCita.franja(f.franjaId),
                                franja: f,
                                elegida:
                                    _franja?.franjaId == f.franjaId &&
                                    mismoDia(_franja!.fecha, f.fecha),
                                alTocar: cargando
                                    ? null
                                    : () => setState(() => _franja = f),
                              ),
                            )
                            .animate(delay: (40 * i).ms)
                            .fadeIn(duration: 250.ms)
                            .scale(
                              begin: const Offset(0.92, 0.92),
                              curve: Curves.easeOutBack,
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _barraConfirmar(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final f = _franja;
    return Container(
      decoration: const BoxDecoration(
        color: TemaCareCar.tarjeta,
        border: Border(top: BorderSide(color: TemaCareCar.borde)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: 250.ms,
              child: f == null
                  ? Text(
                      'Elige vehículo, día y horario.',
                      key: const ValueKey('sin-resumen'),
                      style: temas.bodyMedium?.copyWith(
                        color: TemaCareCar.textoSecundario,
                      ),
                    )
                  : Row(
                      key: ValueKey('resumen-${f.franjaId}-${f.fecha}'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_available,
                          size: 18,
                          color: TemaCareCar.turquesaOscuro,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${formatoFechaLarga(f.fecha)} · '
                            '${f.horaInicio} – ${f.horaFin}',
                            overflow: TextOverflow.ellipsis,
                            style: temas.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: PantallaAgendarCita.botonConfirmar,
              onPressed: _listo ? _confirmar : null,
              icon: _enviando
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_enviando ? 'Agendando…' : 'Confirmar cita'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: TemaCareCar.degradadoMarca,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NUEVA CITA',
                  style: temas.labelSmall?.copyWith(
                    color: TemaCareCar.turquesa,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tres pasos y listo',
                  style: temas.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elige cuándo llevar tu vehículo al taller.',
                  style: temas.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Bloque numerado de la pantalla: «1 Vehiculo», «2 Dia», «3 Horario».
class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.paso,
    required this.titulo,
    required this.child,
  });

  final int paso;
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: TemaCareCar.azulAgencia,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$paso',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(titulo, style: temas.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OpcionVehiculo extends StatelessWidget {
  const _OpcionVehiculo({
    required this.vehiculo,
    required this.elegido,
    this.alTocar,
    super.key,
  });

  final Vehiculo vehiculo;
  final bool elegido;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final v = vehiculo;
    return Material(
      color: elegido ? TemaCareCar.azulSuave : TemaCareCar.tarjeta,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: AnimatedContainer(
          duration: 200.ms,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: elegido ? TemaCareCar.azulAgencia : TemaCareCar.borde,
              width: elegido ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: TemaCareCar.degradadoMarca,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [v.marca, v.modelo].whereType<String>().join(' '),
                      style: temas.titleMedium?.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [
                        '${v.anio}',
                        if (v.placas != null) v.placas!,
                      ].join(' · '),
                      style: temas.bodyMedium?.copyWith(
                        color: TemaCareCar.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: 200.ms,
                transitionBuilder: (hijo, animacion) =>
                    ScaleTransition(scale: animacion, child: hijo),
                child: elegido
                    ? const Icon(
                        Icons.check_circle,
                        key: ValueKey('si'),
                        color: TemaCareCar.azulAgencia,
                      )
                    : const Icon(
                        Icons.radio_button_unchecked,
                        key: ValueKey('no'),
                        color: TemaCareCar.bordeCampo,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({
    required this.fecha,
    required this.esHoy,
    required this.elegido,
    required this.conLugar,
    required this.alTocar,
    super.key,
  });

  final DateTime fecha;
  final bool esHoy;
  final bool elegido;
  final bool conLugar;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final texto = elegido
        ? Colors.white
        : conLugar
        ? TemaCareCar.textoPrincipal
        : TemaCareCar.textoSecundario.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: alTocar,
      child: AnimatedContainer(
        duration: 220.ms,
        curve: Curves.easeOutCubic,
        width: MediaQuery.textScalerOf(context).scale(44).clamp(60, 120),
        decoration: BoxDecoration(
          gradient: elegido ? TemaCareCar.degradadoMarca : null,
          color: elegido ? null : TemaCareCar.tarjeta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: elegido ? Colors.transparent : TemaCareCar.borde,
          ),
          boxShadow: elegido
              ? [
                  BoxShadow(
                    color: TemaCareCar.azulAgencia.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        // Con letra muy grande el dia se encoge en vez de recortarse.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                esHoy ? 'Hoy' : diaCorto(fecha),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: elegido ? TemaCareCar.turquesa : texto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${fecha.day}',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: texto,
                ),
              ),
              const SizedBox(height: 4),
              // Punto que indica que el dia tiene horarios con cupo.
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: conLugar
                      ? (elegido
                            ? TemaCareCar.turquesa
                            : TemaCareCar.turquesaOscuro)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipFranja extends StatelessWidget {
  const _ChipFranja({
    required this.franja,
    required this.elegida,
    this.alTocar,
    super.key,
  });

  final Disponibilidad franja;
  final bool elegida;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final ultimos = franja.cupoDisponible <= 2;
    return Material(
      color: elegida ? TemaCareCar.azulAgencia : TemaCareCar.tarjeta,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: elegida ? TemaCareCar.azulAgencia : TemaCareCar.borde,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                franja.horaInicio,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: elegida ? Colors.white : TemaCareCar.textoPrincipal,
                ),
              ),
              Text(
                ultimos
                    ? (franja.cupoDisponible == 1
                          ? 'Último lugar'
                          : 'Últimos lugares')
                    : 'hasta ${franja.horaFin}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: elegida
                      ? Colors.white.withValues(alpha: 0.8)
                      : ultimos
                      ? TemaCareCar.advertencia
                      : TemaCareCar.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso dentro de una seccion: sin datos, error, con reintento opcional.
class _AvisoEnLinea extends StatelessWidget {
  const _AvisoEnLinea({
    required this.icono,
    required this.texto,
    this.alReintentar,
  });

  final IconData icono;
  final String texto;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TemaCareCar.tarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TemaCareCar.borde),
      ),
      child: Row(
        children: [
          Icon(icono, color: TemaCareCar.textoSecundario),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: temas.bodyMedium?.copyWith(
                color: TemaCareCar.textoSecundario,
              ),
            ),
          ),
          if (alReintentar != null)
            TextButton(
              key: PantallaAgendarCita.botonReintentar,
              onPressed: alReintentar,
              child: const Text('Reintentar'),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
