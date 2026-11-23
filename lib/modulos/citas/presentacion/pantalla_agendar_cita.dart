import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/cita_agendada.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/fallos_agenda.dart';
import '../dominio/motivo_cita.dart';
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

    final Widget cuerpo;
    final error = garaje.error ?? disponibilidad.error;
    if (error != null && !(garaje.hasValue && disponibilidad.hasValue)) {
      cuerpo = EstadoError(
        causa: error is SinConexion
            ? CausaError.sinConexion
            : CausaError.generico,
        alReintentar: _reintentar,
      );
    } else if (!garaje.hasValue || !disponibilidad.hasValue) {
      cuerpo = const _Cargando();
    } else if (garaje.requireValue.isEmpty) {
      cuerpo = EstadoVacio(
        titulo: textos.citasSinVehiculosTitulo,
        mensaje: textos.citasSinVehiculosMensaje,
        icono: Icons.directions_car_outlined,
      );
    } else if (disponibilidad.requireValue.sinCupoEnTodoElRango &&
        _paso == _Paso.formulario) {
      cuerpo = EstadoVacio(
        titulo: textos.citasVacioTitulo,
        mensaje: textos.citasVacioMensaje,
        icono: Icons.event_busy_outlined,
      );
    } else {
      cuerpo = switch (_paso) {
        _Paso.formulario => _formulario(
          context,
          garaje.requireValue,
          disponibilidad.requireValue,
        ),
        _Paso.resumen => _resumen(context, garaje.requireValue),
        _Paso.listo => _listo(context),
      };
    }

    return Scaffold(
      appBar: AppBar(title: Text(textos.citasAgendarTitulo)),
      body: cuerpo,
    );
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

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(garajeProvider);
        ref.invalidate(disponibilidadProvider);
        await ref.read(disponibilidadProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Espaciado.e4),
        children: [
          Selector<int>(
            etiqueta: textos.citasAgendarVehiculo,
            sugerencia: textos.citasAgendarVehiculoSugerencia,
            valor: _vehiculoId,
            opciones: [
              for (final v in vehiculos)
                OpcionSelector(valor: v.id, texto: v.titulo),
            ],
            alCambiar: (id) => setState(() => _vehiculoId = id),
          ),
          const SizedBox(height: Espaciado.e4),
          Calendario(
            mes: _mes ?? rango.desde,
            seleccionado: dia,
            primerDia: rango.desde,
            ultimoDia: rango.hasta,
            hoy: rango.desde,
            habilitado: taller.tieneCupo,
            alCambiarMes: (mes) => setState(() => _mes = mes),
            alSeleccionar: (d) => setState(() {
              _dia = d;
              _franja = null;
            }),
          ),
          const SizedBox(height: Espaciado.e2),
          Text(
            textos.citasNotaDiasSinCupo,
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: tokens.colores.textoSecundario,
            ),
          ),
          const SizedBox(height: Espaciado.e4),
          if (dia == null)
            Text(
              textos.citasSinDiaElegido,
              style: tokens.tipografia.cuerpo.copyWith(
                color: tokens.colores.textoSecundario,
              ),
            )
          else ...[
            Semantics(
              header: true,
              child: Text(
                textos.citasHorariosDelDia(dia),
                style: tokens.tipografia.cuerpoFuerte.copyWith(
                  color: tokens.colores.texto,
                ),
              ),
            ),
            const SizedBox(height: Espaciado.e2),
            SelectorFranja(
              franjas: [
                for (final f in franjas)
                  FranjaHoraria(etiqueta: f.horaInicio, cupo: f.cupo),
              ],
              seleccionada: indice < 0 ? null : indice,
              mensajeVacio: textos.citasHorariosVacio,
              alSeleccionar: (i) => setState(() => _franja = franjas[i]),
            ),
          ],
          const SizedBox(height: Espaciado.e4),
          Selector<MotivoCita>(
            etiqueta: textos.citasAgendarMotivo,
            sugerencia: textos.citasAgendarMotivoSugerencia,
            valor: _motivo,
            opciones: [
              for (final m in MotivoCita.values)
                OpcionSelector(valor: m, texto: _textoMotivo(textos, m)),
            ],
            alCambiar: (m) => setState(() => _motivo = m),
          ),
          const SizedBox(height: Espaciado.e6),
          if (!_completo) ...[
            Text(
              textos.citasAgendarSinDatos,
              style: tokens.tipografia.cuerpoChico.copyWith(
                color: tokens.colores.textoSecundario,
              ),
            ),
            const SizedBox(height: Espaciado.e2),
          ],
          Boton(
            texto: textos.citasAgendarContinuar,
            anchoCompleto: true,
            alPresionar: _completo
                ? () => setState(() {
                    _paso = _Paso.resumen;
                    _fallo = null;
                  })
                : null,
          ),
        ],
      ),
    );
  }

  Widget _resumen(BuildContext context, List<VehiculoGaraje> vehiculos) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final vehiculo = vehiculos.firstWhere((v) => v.id == _vehiculoId);
    final franja = _franja!;
    final fecha = DateFormat.yMMMMEEEEd(
      Localizations.localeOf(context).toString(),
    ).format(franja.fecha);

    return ListView(
      padding: const EdgeInsets.all(Espaciado.e4),
      children: [
        Semantics(
          header: true,
          child: Text(
            textos.citasResumenTitulo,
            style: tokens.tipografia.titulo2.copyWith(
              color: tokens.colores.texto,
            ),
          ),
        ),
        const SizedBox(height: Espaciado.e2),
        FilaLista(
          titulo: textos.citasResumenVehiculo,
          subtitulo: vehiculo.titulo,
          conChevron: false,
        ),
        FilaLista(
          titulo: textos.citasResumenFecha,
          subtitulo: fecha,
          conChevron: false,
        ),
        FilaLista(
          titulo: textos.citasResumenHorario,
          subtitulo: textos.citasResumenHorarioValor(
            franja.horaInicio,
            franja.horaFin,
          ),
          conChevron: false,
        ),
        FilaLista(
          titulo: textos.citasResumenMotivo,
          subtitulo: _textoMotivo(textos, _motivo!),
          conChevron: false,
          conDivisor: false,
        ),
        const SizedBox(height: Espaciado.e4),
        ..._avisoDelFallo(context),
        if (_fallo != _Fallo.duplicada) ...[
          const SizedBox(height: Espaciado.e2),
          Boton(
            texto: textos.citasConfirmar,
            anchoCompleto: true,
            cargando: _enviando,
            alPresionar: _confirmar,
          ),
        ],
        const SizedBox(height: Espaciado.e2),
        Boton(
          texto: textos.citasEditar,
          variante: VarianteBoton.terciario,
          anchoCompleto: true,
          alPresionar: _enviando
              ? null
              : () => setState(() {
                  _paso = _Paso.formulario;
                  _fallo = null;
                }),
        ),
      ],
    );
  }

  List<Widget> _avisoDelFallo(BuildContext context) {
    final textos = AppLocalizations.of(context);
    switch (_fallo) {
      case null:
        return const [];
      case _Fallo.generico:
        return [Aviso(mensaje: textos.citasErrorAgendar, tono: Tono.peligro)];
      case _Fallo.duplicada:
        final e = _existente!;
        return [
          Aviso(
            titulo: textos.citasDuplicadaTitulo,
            mensaje: textos.citasDuplicadaMensaje(
              e.fecha,
              e.horaInicio,
              e.horaFin,
            ),
            tono: Tono.advertencia,
          ),
        ];
      case _Fallo.sinCupo:
        return [
          Aviso(
            titulo: textos.citasSinCupoTitulo,
            mensaje: _cercanas.isEmpty
                ? textos.citasSinCupoNinguna
                : textos.citasSinCupoMensaje,
            tono: Tono.advertencia,
          ),
          for (final f in _cercanas) ...[
            const SizedBox(height: Espaciado.e2),
            Boton(
              texto: textos.citasFranjaCercana(f.fecha, f.horaInicio),
              variante: VarianteBoton.secundario,
              anchoCompleto: true,
              alPresionar: () => setState(() {
                _franja = f;
                _dia = f.fecha;
                _fallo = null;
              }),
            ),
          ],
        ];
    }
  }

  Widget _listo(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final cita = _confirmada!;
    final tema = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: EstadoVacio(
            titulo: textos.citasListoTitulo,
            mensaje: textos.citasListoMensaje(cita.fecha, cita.horaInicio),
            icono: Icons.check_circle_outline,
            textoAccion: textos.citasListoVerComprobante,
            // La ruta nueva no cuelga del tema Pista de esta pantalla: se le
            // pasa el mismo para que el comprobante se vea igual.
            alAccion: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => Theme(
                  data: tema,
                  child: PantallaComprobanteCita(citaId: cita.id),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Boton(
              texto: textos.citasListoCerrar,
              anchoCompleto: true,
              alPresionar: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
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
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 320),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
