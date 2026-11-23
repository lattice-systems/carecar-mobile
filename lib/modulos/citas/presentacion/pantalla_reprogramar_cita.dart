import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/cita_cliente.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/fallos_agenda.dart';
import 'proveedores_citas.dart';

/// Por qué falló el último intento de reprogramar.
enum _Fallo { sinCupo, noModificable, generico }

/// Reprogramar una cita sin cancelarla (V2-M02.13).
///
/// Muestra la cita actual, el calendario y las franjas del taller; al confirmar,
/// el servidor ocupa la franja nueva y libera la anterior en la misma operación.
/// La cita se busca en la lista cargada de «Mis citas»: si no está o ya no es
/// una confirmada futura, se explica. Resuelve los cinco estados: cargando,
/// datos, vacío, error con reintento y sin conexión.
class PantallaReprogramarCita extends ConsumerStatefulWidget {
  const PantallaReprogramarCita({required this.citaId, super.key});

  final int citaId;

  @override
  ConsumerState<PantallaReprogramarCita> createState() =>
      _EstadoPantallaReprogramarCita();
}

class _EstadoPantallaReprogramarCita
    extends ConsumerState<PantallaReprogramarCita> {
  DateTime? _mes;
  DateTime? _dia;
  FranjaDisponible? _franja;

  bool _enviando = false;
  _Fallo? _fallo;
  List<FranjaDisponible> _cercanas = const [];
  CitaCliente? _reprogramada;

  void _reintentar() {
    ref.invalidate(misCitasProvider);
    ref.invalidate(disponibilidadProvider);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final citas = ref.watch(misCitasProvider);
    final disponibilidad = ref.watch(disponibilidadProvider);
    final ahora = ref.watch(relojCitasProvider)();

    final Widget cuerpo;
    final error = citas.error ?? disponibilidad.error;
    if (_reprogramada != null) {
      cuerpo = _listo(context, _reprogramada!);
    } else if (error != null && !(citas.hasValue && disponibilidad.hasValue)) {
      cuerpo = EstadoError(
        causa: error is SinConexion
            ? CausaError.sinConexion
            : CausaError.generico,
        alReintentar: _reintentar,
      );
    } else if (!citas.hasValue || !disponibilidad.hasValue) {
      cuerpo = const _Cargando();
    } else {
      final cita = _buscar(citas.requireValue.citas);
      if (cita == null || !cita.sePuedeModificar(ahora)) {
        cuerpo = EstadoVacio(
          titulo: textos.citasReprogramarNoEncontradaTitulo,
          mensaje: textos.citasReprogramarNoEncontradaMensaje,
          icono: Icons.event_busy_outlined,
        );
      } else {
        cuerpo = _formulario(context, cita, disponibilidad.requireValue);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(textos.citasReprogramarTitulo)),
      body: cuerpo,
    );
  }

  CitaCliente? _buscar(List<CitaCliente> citas) {
    for (final c in citas) {
      if (c.id == widget.citaId) return c;
    }
    return null;
  }

  Widget _formulario(
    BuildContext context,
    CitaCliente cita,
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
        ref.invalidate(disponibilidadProvider);
        await ref.read(disponibilidadProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Espaciado.e4),
        children: [
          Aviso(
            mensaje: textos.citasReprogramarActual(cita.fecha, cita.horaInicio),
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
              alSeleccionar: (i) => setState(() {
                _franja = franjas[i];
                _fallo = null;
              }),
            ),
          ],
          const SizedBox(height: Espaciado.e4),
          ..._avisoDelFallo(context),
          if (_franja == null) ...[
            Text(
              textos.citasReprogramarSinFranja,
              style: tokens.tipografia.cuerpoChico.copyWith(
                color: tokens.colores.textoSecundario,
              ),
            ),
            const SizedBox(height: Espaciado.e2),
          ],
          Boton(
            texto: textos.citasReprogramarConfirmar,
            anchoCompleto: true,
            cargando: _enviando,
            alPresionar: _franja == null ? null : () => _confirmar(cita),
          ),
        ],
      ),
    );
  }

  List<Widget> _avisoDelFallo(BuildContext context) {
    final textos = AppLocalizations.of(context);
    switch (_fallo) {
      case null:
        return const [];
      case _Fallo.generico:
        return [
          Aviso(mensaje: textos.citasReprogramarError, tono: Tono.peligro),
          const SizedBox(height: Espaciado.e2),
        ];
      case _Fallo.noModificable:
        return [
          Aviso(
            mensaje: textos.citasReprogramarNoDisponible,
            tono: Tono.advertencia,
          ),
          const SizedBox(height: Espaciado.e2),
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
          const SizedBox(height: Espaciado.e2),
        ];
    }
  }

  Widget _listo(BuildContext context, CitaCliente cita) {
    final textos = AppLocalizations.of(context);
    return EstadoVacio(
      titulo: textos.citasReprogramarTitulo,
      mensaje: textos.citasReprogramarListo(cita.fecha, cita.horaInicio),
      icono: Icons.check_circle_outline,
      textoAccion: textos.citasListoCerrar,
      alAccion: () => Navigator.of(context).maybePop(),
    );
  }

  Future<void> _confirmar(CitaCliente cita) async {
    final franja = _franja!;
    setState(() {
      _enviando = true;
      _fallo = null;
    });
    final repositorio = ref.read(repositorioCitasProvider);
    try {
      final movida = await repositorio.reprogramar(
        citaId: cita.id,
        franja: franja,
      );
      // La franja anterior quedo libre y la nueva se ocupo.
      ref.invalidate(disponibilidadProvider);
      if (!mounted) return;
      ref.read(misCitasProvider.notifier).reemplazar(movida);
      setState(() => _reprogramada = movida);
    } on FranjaSinCupo {
      var cercanas = const <FranjaDisponible>[];
      try {
        final taller = await ref.refresh(disponibilidadProvider.future);
        cercanas = taller.cercanas(franja);
      } on Object {
        // Sin la lista nueva igual se explica que se lleno.
      }
      if (!mounted) return;
      setState(() {
        _cercanas = cercanas;
        _fallo = _Fallo.sinCupo;
      });
    } on CitaNoModificable {
      // La cita cambio por otro lado: se vuelve a pedir la lista real.
      ref.invalidate(misCitasProvider);
      if (!mounted) return;
      setState(() => _fallo = _Fallo.noModificable);
    } on Object {
      if (!mounted) return;
      setState(() => _fallo = _Fallo.generico);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).citasReprogramarCargando,
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
