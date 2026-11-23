import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/estante.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/movimiento_contexto.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/movimiento.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/cita_agendada.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/fallos_agenda.dart';
import '../dominio/motivo_cita.dart';
import 'componentes/barra_inferior_cita.dart';
import 'componentes/marco_pantalla_cita.dart';
import 'componentes/seccion_cita.dart';
import 'componentes/seleccion_dia_horario.dart';
import 'componentes/tarjeta_vehiculo_cita.dart';
import 'pantalla_comprobante_cita.dart';
import 'proveedores_citas.dart';

enum _Paso { formulario, resumen, listo }

/// Por que fallo el ultimo intento de confirmar.
enum _Fallo { sinCupo, duplicada, generico }

/// Agendar una cita: vehiculo, dia, horario y motivo (V2-M02.08).
///
/// Tres pasos en la misma pantalla: formulario, resumen para confirmar y
/// cita confirmada. Si el horario se llena mientras la persona confirma, ofrece
/// los mas cercanos; si ya tenia cita ese dia, muestra la que existe. Resuelve
/// los cinco estados: cargando, datos, vacio (sin vehiculos o sin lugares),
/// error con reintento y sin conexion.
class PantallaAgendarCita extends ConsumerStatefulWidget {
  const PantallaAgendarCita({super.key});

  @override
  ConsumerState<PantallaAgendarCita> createState() =>
      _EstadoPantallaAgendarCita();
}

class _EstadoPantallaAgendarCita extends ConsumerState<PantallaAgendarCita> {
  _Paso _paso = _Paso.formulario;
  int? _vehiculoId;
  DateTime? _mes;
  DateTime? _dia;
  FranjaDisponible? _franja;
  MotivoCita? _motivo;

  bool _enviando = false;
  _Fallo? _fallo;
  List<FranjaDisponible> _cercanas = const [];
  CitaAgendada? _existente;
  CitaAgendada? _confirmada;

  bool get _completo =>
      _vehiculoId != null && _dia != null && _franja != null && _motivo != null;

  void _reintentar() {
    ref.invalidate(garajeProvider);
    ref.invalidate(disponibilidadProvider);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final garaje = ref.watch(garajeProvider);
    final disponibilidad = ref.watch(disponibilidadProvider);

    Widget estado(Widget hijo) => MarcoPantallaCita.estado(
      titulo: textos.citasAgendarTitulo,
      estado: hijo,
    );

    final error = garaje.error ?? disponibilidad.error;
    if (error != null && !(garaje.hasValue && disponibilidad.hasValue)) {
      return estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: _reintentar,
        ),
      );
    }
    if (!garaje.hasValue || !disponibilidad.hasValue) {
      return estado(const _Cargando());
    }
    if (garaje.requireValue.isEmpty) {
      return estado(
        EstadoVacio(
          titulo: textos.citasSinVehiculosTitulo,
          mensaje: textos.citasSinVehiculosMensaje,
          icono: Icons.directions_car_outlined,
        ),
      );
    }
    if (disponibilidad.requireValue.sinCupoEnTodoElRango &&
        _paso == _Paso.formulario) {
      return estado(
        EstadoVacio(
          titulo: textos.citasVacioTitulo,
          mensaje: textos.citasVacioMensaje,
          icono: Icons.event_busy_outlined,
        ),
      );
    }
    return switch (_paso) {
      _Paso.formulario => _formulario(
        context,
        garaje.requireValue,
        disponibilidad.requireValue,
      ),
      _Paso.resumen => _resumen(context, garaje.requireValue),
      _Paso.listo => _listo(context),
    };
  }

  Widget _formulario(
    BuildContext context,
    List<VehiculoGaraje> vehiculos,
    DisponibilidadTaller taller,
  ) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final rango = ref.watch(rangoAgendableProvider);
    final dia = _dia;
    final franjas = dia == null
        ? const <FranjaDisponible>[]
        : taller.franjasDe(dia);
    final indice = franjas.indexWhere((f) => f.franjaId == _franja?.franjaId);
    final escala = MediaQuery.textScalerOf(context).scale(1);

    return MarcoPantallaCita(
      titulo: textos.citasAgendarTitulo,
      alRefrescar: () async {
        ref.invalidate(garajeProvider);
        ref.invalidate(disponibilidadProvider);
        await ref.read(disponibilidadProvider.future);
      },
      barraInferior: BarraInferiorCita(
        hijos: [
          if (!_completo) ...[
            Text(
              textos.citasAgendarSinDatos,
              textAlign: TextAlign.center,
              style: tokens.tipografia.cuerpoChico.copyWith(
                color: tokens.colores.textoSecundario,
              ),
            ),
            const SizedBox(height: Espaciado.e2),
          ],
          BotonPildora(
            texto: textos.citasAgendarContinuar,
            expandido: true,
            alPresionar: _completo
                ? () => setState(() {
                    _paso = _Paso.resumen;
                    _fallo = null;
                  })
                : null,
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Espaciado.e2),
              Estante(
                titulo: textos.citasAgendarVehiculo,
                anchoTarjeta: 160,
                alto: 184 + (escala - 1).clamp(0.0, 1.0) * 120,
                hijos: [
                  for (final v in vehiculos)
                    TarjetaVehiculoCita(
                      nombre: v.titulo,
                      seleccionada: _vehiculoId == v.id,
                      alElegir: () => setState(() => _vehiculoId = v.id),
                    ),
                ],
              ),
              SeleccionDiaHorario(
                taller: taller,
                rango: rango,
                mes: _mes ?? rango.desde,
                dia: dia,
                franjas: franjas,
                franjaSeleccionada: indice < 0 ? null : indice,
                alCambiarMes: (mes) => setState(() => _mes = mes),
                alElegirDia: (d) => setState(() {
                  _dia = d;
                  _franja = null;
                }),
                alElegirFranja: (i) => setState(() => _franja = franjas[i]),
              ),
              SeccionCita(
                titulo: textos.citasAgendarMotivo,
                hijo: Wrap(
                  spacing: Espaciado.e2,
                  runSpacing: Espaciado.e1,
                  children: [
                    for (final m in MotivoCita.values)
                      ChipPista(
                        texto: _textoMotivo(textos, m),
                        seleccionado: _motivo == m,
                        alCambiar: (_) => setState(() => _motivo = m),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resumen(BuildContext context, List<VehiculoGaraje> vehiculos) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final vehiculo = vehiculos.firstWhere((v) => v.id == _vehiculoId);
    final franja = _franja!;
    final fecha = DateFormat.yMMMMEEEEd(
      Localizations.localeOf(context).toString(),
    ).format(franja.fecha);

    return MarcoPantallaCita(
      titulo: textos.citasAgendarTitulo,
      acciones: const [],
      barraInferior: BarraInferiorCita(
        hijos: [
          if (_fallo != _Fallo.duplicada) ...[
            BotonPildora(
              texto: textos.citasConfirmar,
              expandido: true,
              alPresionar: _enviando ? null : _confirmar,
            ),
            const SizedBox(height: Espaciado.e2),
          ],
          BotonPildora(
            texto: textos.citasEditar,
            variante: VarianteBotonPildora.tonal,
            expandido: true,
            alPresionar: _enviando
                ? null
                : () => setState(() {
                    _paso = _Paso.formulario;
                    _fallo = null;
                  }),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CabeceraPortada(
                titulo: textos.citasResumenTitulo,
                subtitulo: vehiculo.titulo,
                portada: ColoredBox(
                  color: c.acentoSuave,
                  child: Icon(
                    Icons.event_available_outlined,
                    size: 96,
                    color: c.acento,
                  ),
                ),
              ),
              GrupoLista(
                filas: [
                  FilaGrupo(
                    titulo: textos.citasResumenFecha,
                    subtitulo: fecha,
                    icono: Icons.calendar_today_outlined,
                    colorIcono: c.acento,
                  ),
                  FilaGrupo(
                    titulo: textos.citasResumenHorario,
                    subtitulo: textos.citasResumenHorarioValor(
                      franja.horaInicio,
                      franja.horaFin,
                    ),
                    icono: Icons.schedule_outlined,
                    colorIcono: c.exito,
                  ),
                  FilaGrupo(
                    titulo: textos.citasResumenMotivo,
                    subtitulo: _textoMotivo(textos, _motivo!),
                    icono: Icons.build_outlined,
                    colorIcono: c.marca,
                  ),
                ],
              ),
              ..._avisoDelFallo(context),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _avisoDelFallo(BuildContext context) {
    final textos = AppLocalizations.of(context);
    Widget margen(Widget hijo) => Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaciado.e4,
        Espaciado.e4,
        Espaciado.e4,
        0,
      ),
      child: hijo,
    );
    switch (_fallo) {
      case null:
        return const [];
      case _Fallo.generico:
        return [
          margen(Aviso(mensaje: textos.citasErrorAgendar, tono: Tono.peligro)),
        ];
      case _Fallo.duplicada:
        final e = _existente!;
        return [
          margen(
            Aviso(
              titulo: textos.citasDuplicadaTitulo,
              mensaje: textos.citasDuplicadaMensaje(
                e.fecha,
                e.horaInicio,
                e.horaFin,
              ),
              tono: Tono.advertencia,
            ),
          ),
        ];
      case _Fallo.sinCupo:
        return [
          margen(
            Aviso(
              titulo: textos.citasSinCupoTitulo,
              mensaje: _cercanas.isEmpty
                  ? textos.citasSinCupoNinguna
                  : textos.citasSinCupoMensaje,
              tono: Tono.advertencia,
            ),
          ),
          for (final f in _cercanas)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Espaciado.e4,
                Espaciado.e2,
                Espaciado.e4,
                0,
              ),
              child: BotonPildora(
                texto: textos.citasFranjaCercana(f.fecha, f.horaInicio),
                variante: VarianteBotonPildora.tonal,
                expandido: true,
                alPresionar: () => setState(() {
                  _franja = f;
                  _dia = f.fecha;
                  _fallo = null;
                }),
              ),
            ),
        ];
    }
  }

  Widget _listo(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final cita = _confirmada!;
    final tema = Theme.of(context);
    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Espaciado.anchoMaximoContenido,
            ),
            child: SingleChildScrollView(
              child: CabeceraPortada(
                titulo: textos.citasListoTitulo,
                subtitulo: textos.citasListoMensaje(
                  cita.fecha,
                  cita.horaInicio,
                ),
                tinte: c.exito,
                lado: 200,
                portada: const _Celebracion(),
                principal: AccionPortada(
                  texto: textos.citasListoVerComprobante,
                  icono: Icons.qr_code_2_rounded,
                  // La ruta nueva no cuelga del tema Pista de esta pantalla:
                  // se le pasa el mismo para que el comprobante se vea igual.
                  alPresionar: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => Theme(
                        data: tema,
                        child: PantallaComprobanteCita(citaId: cita.id),
                      ),
                    ),
                  ),
                ),
                secundaria: AccionPortada(
                  texto: textos.citasListoCerrar,
                  alPresionar: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmar() async {
    final franja = _franja!;
    setState(() {
      _enviando = true;
      _fallo = null;
    });
    final repositorio = ref.read(repositorioCitasProvider);
    try {
      final cita = await repositorio.agendar(
        vehiculoId: _vehiculoId!,
        franja: franja,
        motivo: _motivo!,
      );
      ref.invalidate(disponibilidadProvider);
      // La lista de citas ya cargada quedo vieja: «Mis citas» y el widget de
      // inicio (V2-M25.01) deben ver la nueva.
      ref.invalidate(misCitasProvider);
      if (!mounted) return;
      setState(() {
        _confirmada = cita;
        _paso = _Paso.listo;
      });
    } on FranjaSinCupo {
      var cercanas = const <FranjaDisponible>[];
      try {
        final taller = await ref.refresh(disponibilidadProvider.future);
        cercanas = taller.cercanas(franja);
      } on Object {
        // Sin la lista nueva igual se explica que se lleno; la pantalla dira
        // que elija otro dia.
      }
      if (!mounted) return;
      setState(() {
        _cercanas = cercanas;
        _fallo = _Fallo.sinCupo;
      });
    } on CitaDuplicada catch (duplicada) {
      if (!mounted) return;
      setState(() {
        _existente = duplicada.existente;
        _fallo = _Fallo.duplicada;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _fallo = _Fallo.generico);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  static String _textoMotivo(AppLocalizations textos, MotivoCita m) =>
      switch (m) {
        MotivoCita.mantenimiento => textos.citasMotivoMantenimiento,
        MotivoCita.reparacion => textos.citasMotivoReparacion,
        MotivoCita.revision => textos.citasMotivoRevision,
        MotivoCita.garantia => textos.citasMotivoGarantia,
        MotivoCita.otro => textos.citasMotivoOtro,
      };
}

/// Palomita de «cita confirmada» sobre el color de éxito.
///
/// Entra con un resorte suave de escala; con «reducir movimiento» aparece ya
/// en su sitio. Sobria a propósito: una sola pieza, sin confeti.
class _Celebracion extends StatelessWidget {
  const _Celebracion();

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final reducir = MediaQuery.disableAnimationsOf(context);
    final palomita = Icon(
      Icons.check_circle_rounded,
      size: 104,
      color: c.exito,
    );

    return ColoredBox(
      color: c.exitoSuave,
      child: Center(
        child: reducir
            ? palomita
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: context.movimiento(Movimiento.enfatico).duracion,
                curve: Curves.easeOutBack,
                builder: (_, escala, hijo) =>
                    Transform.scale(scale: escala, child: hijo),
                child: palomita,
              ),
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).citasCargandoAgendar,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 184, radio: 16),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 320, radio: 16),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
