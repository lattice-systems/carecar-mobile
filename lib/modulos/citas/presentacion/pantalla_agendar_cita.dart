import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../notificaciones/notificaciones.dart';
import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/analitica/ambito_analitica.dart';
import '../../../nucleo/analitica/analitica.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/resultado_pantalla.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/estante.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../recoleccion/recoleccion.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/cita_agendada.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/fallos_agenda.dart';
import '../dominio/motivo_cita.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'componentes/grupo_recoleccion_cita.dart';
import 'componentes/seleccion_dia_horario.dart';
import 'componentes/tarjeta_vehiculo_cita.dart';
import 'pantalla_comprobante_cita.dart';
import 'proveedores_citas.dart';

enum _Paso { formulario, resumen, listo }

/// Por que fallo el ultimo intento de confirmar.
enum _Fallo { sinCupo, duplicada, cobertura, direccion, generico }

/// Agendar una cita: vehiculo, dia, horario y motivo (V2-M02.08).
///
/// Tres pasos en la misma pantalla: formulario, resumen para confirmar y
/// cita confirmada. Si el horario se llena mientras la persona confirma, ofrece
/// los mas cercanos; si ya tenia cita ese dia, muestra la que existe. Resuelve
/// los cinco estados: cargando, datos, vacio (sin vehiculos o sin lugares),
/// error con reintento y sin conexion.
class PantallaAgendarCita extends ConsumerStatefulWidget {
  const PantallaAgendarCita({
    super.key,
    this.vehiculoInicial,
    this.motivoInicial,
    this.promocionId,
    this.vehiculosConPromocion,
  });

  /// Vehiculo ya elegido al abrir (V2-M24.06, desde el asistente). Si no esta
  /// en el garaje se ignora.
  final int? vehiculoInicial;

  /// Motivo ya elegido al abrir; la persona lo puede cambiar.
  final MotivoCita? motivoInicial;

  final int? promocionId;
  final Set<int>? vehiculosConPromocion;

  @override
  ConsumerState<PantallaAgendarCita> createState() =>
      _EstadoPantallaAgendarCita();
}

class _EstadoPantallaAgendarCita extends ConsumerState<PantallaAgendarCita> {
  final _embudo = EmbudoCitas();
  _Paso _paso = _Paso.formulario;
  int? _vehiculoId;
  DateTime? _mes;
  DateTime? _dia;
  FranjaDisponible? _franja;
  MotivoCita? _motivo;

  // Recoleccion a domicilio (V2-M17.02): si se pidio y en que direccion.
  bool _recoleccion = false;
  int? _direccionId;

  bool _enviando = false;
  _Fallo? _fallo;
  List<FranjaDisponible> _cercanas = const [];
  CitaAgendada? _existente;
  CitaAgendada? _confirmada;

  @override
  void initState() {
    super.initState();
    _vehiculoId = widget.vehiculoInicial;
    _motivo = widget.motivoInicial;
  }

  bool get _completo =>
      _vehiculoId != null && _dia != null && _franja != null && _motivo != null;

  /// La cotizacion de la recoleccion pedida; nula si no se pidio, falta la
  /// direccion o el dia, o el servidor aun no responde (o la rechazo).
  AsyncValue<CotizacionRecoleccion>? _cotizacion() {
    final direccionId = _direccionId;
    final dia = _dia;
    if (!_recoleccion || direccionId == null || dia == null) return null;
    return ref.watch(
      cotizacionRecoleccionProvider((direccionId: direccionId, fecha: dia)),
    );
  }

  /// Pidieron recoleccion pero aun no hay un costo valido que mostrar: la
  /// cita no se puede revisar hasta que la direccion este cotizada.
  bool get _recoleccionPendiente =>
      _recoleccion && !(_cotizacion()?.hasValue ?? false);

  void _reintentar() {
    ref.invalidate(garajeProvider);
    ref.invalidate(disponibilidadProvider);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final garaje = ref.watch(garajeProvider);
    final disponibilidad = ref.watch(disponibilidadProvider);

    Widget estado(Widget hijo) => MarcoPantalla.estado(
      icono: LucideIcons300.calendarPlus,
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
    final elegibles = widget.vehiculosConPromocion;
    final vehiculos = elegibles == null
        ? garaje.requireValue
        : garaje.requireValue
              .where((auto) => elegibles.contains(auto.id))
              .toList();
    // Un vehiculo precargado que ya no esta en el garaje no cuenta.
    if (_vehiculoId != null && !vehiculos.any((v) => v.id == _vehiculoId)) {
      _vehiculoId = null;
    }
    if (vehiculos.isEmpty) {
      return estado(
        EstadoVacio(
          titulo: textos.citasSinVehiculosTitulo,
          mensaje: textos.citasSinVehiculosMensaje,
          icono: LucideIcons300.car,
        ),
      );
    }
    if (_paso == _Paso.formulario) {
      final analitica = AmbitoAnalitica.de(context);
      if (analitica != null && analitica.habilitada) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_embudo.mostrarDisponibilidad(analitica));
        });
      }
    }
    if (disponibilidad.requireValue.sinCupoEnTodoElRango &&
        _paso == _Paso.formulario) {
      return estado(
        EstadoVacio(
          titulo: textos.citasVacioTitulo,
          mensaje: textos.citasVacioMensaje,
          icono: LucideIcons300.calendarX,
        ),
      );
    }
    return switch (_paso) {
      _Paso.formulario => _formulario(
        context,
        vehiculos,
        disponibilidad.requireValue,
      ),
      _Paso.resumen => _resumen(context, vehiculos),
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

    return MarcoPantalla(
      icono: LucideIcons300.calendarPlus,
      titulo: textos.citasAgendarTitulo,
      alRefrescar: () async {
        ref.invalidate(garajeProvider);
        ref.invalidate(disponibilidadProvider);
        await ref.read(disponibilidadProvider.future);
      },
      barraInferior: BarraInferior(
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
            alPresionar: _completo && !_recoleccionPendiente
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
                alElegirFranja: (i) {
                  setState(() => _franja = franjas[i]);
                  final analitica = AmbitoAnalitica.de(context);
                  if (analitica != null) {
                    unawaited(_embudo.mostrarDisponibilidad(analitica));
                    unawaited(_embudo.elegirFranja(analitica));
                  }
                },
              ),
              SeccionPantalla(
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
              SeleccionRecoleccion(
                pedida: _recoleccion,
                direccionId: _direccionId,
                fecha: dia,
                alCambiarPedida: (pedida) => setState(() {
                  _recoleccion = pedida;
                  if (!pedida) _direccionId = null;
                }),
                alElegirDireccion: (id) => setState(() => _direccionId = id),
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

    return MarcoPantalla(
      icono: LucideIcons300.calendarPlus,
      titulo: textos.citasResumenTitulo,
      subtitulo: vehiculo.titulo,
      acciones: const [],
      barraInferior: BarraInferior(
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
            variante: VarianteBotonPildora.vidrio,
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
              GrupoLista(
                filas: [
                  FilaGrupo(
                    titulo: textos.citasResumenFecha,
                    subtitulo: fecha,
                    icono: LucideIcons300.calendar,
                    colorIcono: c.acento,
                  ),
                  FilaGrupo(
                    titulo: textos.citasResumenHorario,
                    subtitulo: textos.citasResumenHorarioValor(
                      franja.horaInicio,
                      franja.horaFin,
                    ),
                    icono: LucideIcons300.clock,
                    colorIcono: c.exito,
                  ),
                  FilaGrupo(
                    titulo: textos.citasResumenMotivo,
                    subtitulo: _textoMotivo(textos, _motivo!),
                    icono: LucideIcons300.wrench,
                    colorIcono: c.marca,
                  ),
                ],
              ),
              ..._resumenRecoleccion(context),
              ..._avisoDelFallo(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Direccion, franjas y costo de la recoleccion pedida, para revisarlos
  /// antes de confirmar. Vacio si la persona lleva el auto.
  List<Widget> _resumenRecoleccion(BuildContext context) {
    final cotizacion = _cotizacion()?.value;
    if (!_recoleccion || cotizacion == null) return const [];
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final direccion = ref
        .watch(direccionesProvider)
        .value
        ?.where((d) => d.id == _direccionId)
        .firstOrNull;

    String ventana(VentanaHoraria v) => textos.citasResumenRecoleccionVentana(
      cotizacion.fecha,
      v.inicio,
      v.fin,
    );

    return [
      const SizedBox(height: Espaciado.e4),
      GrupoLista(
        encabezado: textos.citasResumenRecoleccionEncabezado,
        filas: [
          FilaGrupo(
            titulo: textos.citasResumenRecoleccion,
            subtitulo: direccion == null
                ? null
                : textos.citasResumenRecoleccionValor(
                    direccion.alias,
                    direccion.resumen,
                  ),
            icono: LucideIcons300.mapPin,
            colorIcono: c.acento,
          ),
          FilaGrupo(
            titulo: textos.citasResumenRecogemos,
            subtitulo: ventana(cotizacion.recoleccion),
            icono: LucideIcons300.truck,
            colorIcono: c.marca,
          ),
          FilaGrupo(
            titulo: textos.citasResumenEntregamos,
            subtitulo: ventana(cotizacion.entrega),
            icono: LucideIcons300.house,
            colorIcono: c.exito,
          ),
          FilaGrupo(
            titulo: textos.citasResumenRecoleccionCosto,
            subtitulo: formatearPesos(context, cotizacion.costoTotal),
            icono: LucideIcons300.banknote,
            colorIcono: c.advertencia,
          ),
        ],
      ),
    ];
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
      case _Fallo.cobertura:
        return [
          margen(
            Aviso(
              titulo: textos.recoleccionCoberturaTitulo,
              mensaje: textos.citasErrorCobertura,
              tono: Tono.advertencia,
            ),
          ),
        ];
      case _Fallo.direccion:
        return [
          margen(
            Aviso(mensaje: textos.citasErrorRecoleccion, tono: Tono.peligro),
          ),
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
                variante: VarianteBotonPildora.vidrio,
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
    final cita = _confirmada!;
    final tema = Theme.of(context);
    return ResultadoPantalla(
      titulo: textos.citasListoTitulo,
      mensaje: textos.citasListoMensaje(cita.fecha, cita.horaInicio),
      principal: AccionPantalla(
        texto: textos.citasListoVerComprobante,
        icono: LucideIcons300.qrCode,
        // La ruta nueva no cuelga del tema Pista de esta pantalla: se le pasa
        // el mismo para que el comprobante se vea igual.
        alPresionar: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => Theme(
              data: tema,
              child: PantallaComprobanteCita(
                citaId: cita.id,
                recoleccion: cita.recoleccion,
              ),
            ),
          ),
        ),
      ),
      secundaria: AccionPantalla(
        texto: textos.citasListoCerrar,
        alPresionar: () => Navigator.of(context).maybePop(),
      ),
      contenido: cita.cupon == null && cita.recoleccion == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cita.cupon case final cupon?)
                  Text('${textos.m13Cupon}: $cupon'),
                if (cita.recoleccion case final recoleccion?)
                  GrupoRecoleccionCita(recoleccion: recoleccion),
              ],
            ),
    );
  }

  Future<void> _confirmar() async {
    final franja = _franja!;
    final intento = _embudo.intento;
    final analitica = AmbitoAnalitica.de(context);
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
        direccionRecoleccionId: _recoleccion ? _direccionId : null,
        promocionId: widget.promocionId,
      );
      if (analitica != null) {
        unawaited(_embudo.confirmar(analitica, cita.id, intento));
      }
      ref.invalidate(disponibilidadProvider);
      // La lista de citas ya cargada quedo vieja: «Mis citas» y el widget de
      // inicio (V2-M25.01) deben ver la nueva.
      ref.invalidate(misCitasProvider);
      if (!mounted) return;
      // V2-M06.06: los recordatorios son locales, asi que suenan sin red. Se
      // dejan DESPUES de pintar el comprobante y sin esperarlos: programarlos
      // toca el sistema, y la cita ya esta hecha. Esperarlos dejaba la
      // pantalla colgada detras del dialogo de permiso, y lo encontro la
      // prueba de integracion en el emulador.
      unawaited(ref.read(recordatoriosDeCitaProvider).alConfirmar(cita));
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
    } on FueraDeCobertura {
      // La zona cambio despues de cotizar: la cotizacion guardada ya no vale.
      ref.invalidate(cotizacionRecoleccionProvider);
      if (!mounted) return;
      setState(() => _fallo = _Fallo.cobertura);
    } on NoEncontrado {
      if (!mounted) return;
      setState(
        () => _fallo = _recoleccion ? _Fallo.direccion : _Fallo.generico,
      );
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
class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).citasCargandoAgendar,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
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
      ),
    );
  }
}
