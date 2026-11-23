import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/cita_cliente.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/fallos_agenda.dart';
import 'componentes/barra_inferior_cita.dart';
import 'componentes/marco_pantalla_cita.dart';
import 'componentes/seleccion_dia_horario.dart';
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

    Widget estado(Widget hijo) => MarcoPantallaCita.estado(
      titulo: textos.citasReprogramarTitulo,
      estado: hijo,
    );

    final error = citas.error ?? disponibilidad.error;
    if (_reprogramada != null) return _listo(context, _reprogramada!);
    if (error != null && !(citas.hasValue && disponibilidad.hasValue)) {
      return estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: _reintentar,
        ),
      );
    }
    if (!citas.hasValue || !disponibilidad.hasValue) {
      return estado(const _Cargando());
    }
    final cita = _buscar(citas.requireValue.citas);
    if (cita == null || !cita.sePuedeModificar(ahora)) {
      return estado(
        EstadoVacio(
          titulo: textos.citasReprogramarNoEncontradaTitulo,
          mensaje: textos.citasReprogramarNoEncontradaMensaje,
          icono: Icons.event_busy_outlined,
        ),
      );
    }
    return _formulario(context, cita, disponibilidad.requireValue);
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
    final c = tokens.colores;
    final rango = ref.watch(rangoAgendableProvider);
    final dia = _dia;
    final franjas = dia == null
        ? const <FranjaDisponible>[]
        : taller.franjasDe(dia);
    final indice = franjas.indexWhere((f) => f.franjaId == _franja?.franjaId);

    return MarcoPantallaCita(
      titulo: textos.citasReprogramarTitulo,
      alRefrescar: () async {
        ref.invalidate(disponibilidadProvider);
        await ref.read(disponibilidadProvider.future);
      },
      barraInferior: BarraInferiorCita(
        hijos: [
          if (_franja == null) ...[
            Text(
              textos.citasReprogramarSinFranja,
              textAlign: TextAlign.center,
              style: tokens.tipografia.cuerpoChico.copyWith(
                color: c.textoSecundario,
              ),
            ),
            const SizedBox(height: Espaciado.e2),
          ],
          BotonPildora(
            texto: textos.citasReprogramarConfirmar,
            expandido: true,
            alPresionar: _franja == null || _enviando
                ? null
                : () => _confirmar(cita),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Espaciado.e4,
                  vertical: Espaciado.e2,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.acentoSuave,
                    borderRadius: Radios.bordeTarjeta,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Espaciado.e4),
                    child: Row(
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            Icons.event_outlined,
                            color: c.acento,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: Espaciado.e3),
                        Expanded(
                          child: Text(
                            textos.citasReprogramarActual(
                              cita.fecha,
                              cita.horaInicio,
                            ),
                            style: tokens.tipografia.cuerpoFuerte.copyWith(
                              color: c.texto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                alElegirFranja: (i) => setState(() {
                  _franja = franjas[i];
                  _fallo = null;
                }),
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
          margen(
            Aviso(mensaje: textos.citasReprogramarError, tono: Tono.peligro),
          ),
        ];
      case _Fallo.noModificable:
        return [
          margen(
            Aviso(
              mensaje: textos.citasReprogramarNoDisponible,
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

  Widget _listo(BuildContext context, CitaCliente cita) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
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
                titulo: textos.citasReprogramarTitulo,
                subtitulo: textos.citasReprogramarListo(
                  cita.fecha,
                  cita.horaInicio,
                ),
                tinte: c.exito,
                lado: 200,
                portada: ColoredBox(
                  color: c.exitoSuave,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 104,
                    color: c.exito,
                  ),
                ),
                principal: AccionPortada(
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
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
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
      ),
    );
  }
}
