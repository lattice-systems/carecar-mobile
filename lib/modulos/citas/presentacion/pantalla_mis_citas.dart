import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../notificaciones/notificaciones.dart';
import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/cuadro_fecha.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/cita_cliente.dart';
import '../dominio/fallos_agenda.dart';
import '../dominio/motivo_cita.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import 'componentes/grupo_citas.dart';
import 'componentes/grupo_recoleccion_cita.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'componentes/vacio_ilustrado.dart';
import 'proveedores_citas.dart';
import 'rutas_citas.dart';

/// Mis citas: próximas y pasadas con su estado (V2-M02.09).
///
/// Las próximas son las confirmadas que aún no empiezan; todo lo demás
/// (atendidas, no asistió, canceladas y vencidas) va en pasadas. El estado se
/// dice con texto, icono y color. Pagina con «Cargar más citas». Resuelve los
/// cinco estados: cargando, datos, vacío, error con reintento y sin conexión.
class PantallaMisCitas extends ConsumerStatefulWidget {
  const PantallaMisCitas({super.key});

  @override
  ConsumerState<PantallaMisCitas> createState() => _EstadoPantallaMisCitas();
}

class _EstadoPantallaMisCitas extends ConsumerState<PantallaMisCitas> {
  /// Aviso del resultado de la última acción sobre una cita.
  Widget? _aviso;

  /// Cita que se está cancelando, para no mandar dos veces la misma petición.
  int? _cancelandoId;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final citas = ref.watch(misCitasProvider);

    // V2-M06.06: la lista recien llegada pone al dia los recordatorios
    // locales. Importa para quien reinstalo la app o cambio de telefono: sus
    // avisos no existen hasta que algo los vuelve a programar.
    //
    // La paginacion no estorba: `sincronizar` solo toca las citas que recibe
    // -programa las confirmadas, cancela las que no-, no borra las que no
    // vinieron en esta pagina.
    ref.listen(misCitasProvider, (_, nuevas) {
      final lista = nuevas.value?.citas;
      if (lista != null) {
        ref.read(recordatoriosDeCitaProvider).sincronizar(lista);
      }
    });

    if (citas.hasError && !citas.hasValue) {
      return MarcoPantalla.estado(
        titulo: textos.citasMisCitasTitulo,
        conRegreso: true,
        acciones: const [],
        estado: EstadoError(
          causa: citas.error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(misCitasProvider),
        ),
      );
    }
    if (!citas.hasValue) {
      return MarcoPantalla.estado(
        titulo: textos.citasMisCitasTitulo,
        conRegreso: true,
        acciones: const [],
        estado: const _Cargando(),
      );
    }
    if (citas.requireValue.citas.isEmpty) {
      return MarcoPantalla.estado(
        titulo: textos.citasMisCitasTitulo,
        conRegreso: true,
        acciones: const [],
        estado: VacioIlustrado(
          titulo: textos.citasMisCitasVacioTitulo,
          mensaje: textos.citasMisCitasVacioMensaje,
          icono: LucideIcons300.calendarDays,
          textoAccion: textos.citasMisCitasAgendar,
          alAccion: () => context.push(rutaAgendarCita),
        ),
      );
    }
    return _lista(context, citas.requireValue);
  }

  Widget _lista(BuildContext context, EstadoMisCitas estado) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final ahora = ref.watch(relojCitasProvider)();
    final vehiculos = {
      for (final v
          in ref.watch(garajeProvider).value ?? const <VehiculoGaraje>[])
        v.id: v.titulo,
    };
    final proximas = [
      for (final c in estado.citas)
        if (c.esProxima(ahora)) c,
    ]..sort((a, b) => a.inicio.compareTo(b.inicio));
    final pasadas = [
      for (final c in estado.citas)
        if (!c.esProxima(ahora)) c,
    ]..sort((a, b) => b.inicio.compareTo(a.inicio));
    final destacada = proximas.isEmpty ? null : proximas.first;
    final otras = proximas.length > 1 ? proximas.sublist(1) : <CitaCliente>[];

    Widget seccionVacia(String encabezado, String texto) => SeccionPantalla(
      titulo: encabezado,
      hijo: Text(
        texto,
        style: tokens.tipografia.cuerpo.copyWith(
          color: tokens.colores.textoSecundario,
        ),
      ),
    );

    return MarcoPantalla(
      titulo: textos.citasMisCitasTitulo,
      conRegreso: true,
      acciones: [
        BotonCircular(
          etiqueta: textos.citasMisCitasAgendar,
          icono: LucideIcons300.plus,
          variante: VarianteBotonCircular.acento,
          alPresionar: () => context.push(rutaAgendarCita),
        ),
      ],
      alRefrescar: () async {
        ref.invalidate(misCitasProvider);
        await ref.read(misCitasProvider.future);
      },
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_aviso != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Espaciado.e2),
                  child: _aviso,
                ),
              if (destacada != null)
                _TarjetaProxima(
                  cita: destacada,
                  vehiculo: _nombreVehiculo(textos, destacada, vehiculos),
                  cancelando: _cancelandoId == destacada.id,
                  ocupado: _cancelandoId != null,
                  alCancelar: () => _cancelar(destacada),
                  textoEstado: _textoEstado(textos, destacada.estado),
                  textoMotivo: destacada.motivo == null
                      ? null
                      : _textoMotivo(textos, destacada.motivo!),
                )
              else
                seccionVacia(textos.citasProximas, textos.citasProximasVacio),
              if (otras.isNotEmpty)
                GrupoCitas(
                  encabezado: textos.citasProximas,
                  filas: [
                    for (final c in otras)
                      _fila(
                        context,
                        c,
                        vehiculos,
                        alToque: () => _abrirAcciones(c, vehiculos),
                      ),
                  ],
                ),
              ..._traslados(textos, proximas),
              if (pasadas.isEmpty)
                seccionVacia(textos.citasPasadas, textos.citasPasadasVacio)
              else
                GrupoCitas(
                  encabezado: textos.citasPasadas,
                  filas: [
                    for (final c in pasadas) _fila(context, c, vehiculos),
                  ],
                ),
              ..._traslados(textos, pasadas),
              if (estado.errorAlCargarMas)
                Padding(
                  padding: const EdgeInsets.all(Espaciado.e4),
                  child: Aviso(
                    mensaje: textos.citasErrorMas,
                    tono: Tono.peligro,
                  ),
                ),
              if (estado.hayMas)
                Padding(
                  padding: const EdgeInsets.all(Espaciado.e4),
                  child: Center(
                    child: BotonPildora(
                      texto: textos.citasCargarMas,
                      variante: VarianteBotonPildora.vidrio,
                      icono: LucideIcons300.chevronDown,
                      alPresionar: estado.cargandoMas
                          ? null
                          : () =>
                                ref.read(misCitasProvider.notifier).cargarMas(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Un grupo de traslados por cada cita que lleva recolección y sigue en pie
  /// (V2-M17.03): desde aquí se abre el seguimiento del chofer y su checklist.
  /// Una cita cancelada ya no tiene a quién seguir.
  List<Widget> _traslados(AppLocalizations textos, List<CitaCliente> citas) => [
    for (final c in citas)
      if (c.recoleccion != null && c.estado != EstadoDeCita.cancelada)
        GrupoRecoleccionCita(
          recoleccion: c.recoleccion!,
          encabezado: textos.citasMisCitasRecoleccionEncabezado(
            textos.citasFilaTitulo(c.fecha, c.horaInicio),
          ),
        ),
  ];

  String _nombreVehiculo(
    AppLocalizations textos,
    CitaCliente cita,
    Map<int, String> vehiculos,
  ) =>
      cita.vehiculoNombre ??
      vehiculos[cita.vehiculoId] ??
      textos.citasFilaVehiculoGenerico;

  FilaCita _fila(
    BuildContext context,
    CitaCliente cita,
    Map<int, String> vehiculos, {
    VoidCallback? alToque,
  }) {
    final textos = AppLocalizations.of(context);
    final vehiculo = _nombreVehiculo(textos, cita, vehiculos);
    final motivo = cita.motivo;
    final titulo = textos.citasFilaTitulo(cita.fecha, cita.horaInicio);
    final estado = _textoEstado(textos, cita.estado);
    final subtitulo = motivo == null
        ? vehiculo
        : '$vehiculo · ${_textoMotivo(textos, motivo)}';
    return FilaCita(
      fecha: cita.fecha,
      tono: _tonoEstado(cita.estado),
      titulo: titulo,
      subtitulo: subtitulo,
      etiquetaSemantica: '$titulo. $subtitulo. $estado',
      fin: Insignia(
        texto: estado,
        tono: _tonoEstado(cita.estado),
        conIcono: true,
      ),
      alToque: alToque,
    );
  }

  /// Hoja con las acciones de una cita próxima que no es la destacada.
  Future<void> _abrirAcciones(CitaCliente cita, Map<int, String> vehiculos) {
    final textos = AppLocalizations.of(context);
    return mostrarHojaInferior<void>(
      context,
      titulo: textos.citasAccionesCita,
      builder: (hoja) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Espaciado.e4,
          0,
          Espaciado.e4,
          Espaciado.e4,
        ),
        child: _AccionesCita(
          cita: cita,
          ocupado: _cancelandoId != null,
          cancelando: _cancelandoId == cita.id,
          antes: () => Navigator.of(hoja).pop(),
          alCancelar: () => _cancelar(cita),
        ),
      ),
    );
  }

  Future<void> _cancelar(CitaCliente cita) async {
    final textos = AppLocalizations.of(context);
    final confirmada = await mostrarDialogo<bool>(
      context,
      cerrarAlTocarFuera: false,
      builder: (dialogo) => Dialogo(
        titulo: textos.citasCancelarDialogoTitulo,
        mensaje: textos.citasCancelarDialogoMensaje(
          cita.fecha,
          cita.horaInicio,
        ),
        textoPrincipal: textos.citasCancelarConfirmar,
        alPrincipal: () => Navigator.of(dialogo).pop(true),
        textoSecundario: textos.citasCancelarMantener,
        alSecundario: () => Navigator.of(dialogo).pop(false),
        peligro: true,
      ),
    );
    if (confirmada != true || !mounted) return;

    setState(() {
      _cancelandoId = cita.id;
      _aviso = null;
    });
    try {
      final cancelada = await ref
          .read(repositorioCitasProvider)
          .cancelar(cita.id);
      // El cupo de la franja se libero: la disponibilidad ya no es la misma.
      ref.invalidate(disponibilidadProvider);
      if (!mounted) return;
      ref.read(misCitasProvider.notifier).reemplazar(cancelada);
      // V2-M06.06: ya no hay a que recordarle.
      await ref.read(recordatoriosDeCitaProvider).alCancelar(cita.id);
      _mostrarAviso(textos.citasCancelada, Tono.exito);
    } on CitaNoModificable {
      // Alguien la cambio por otro lado: se vuelve a pedir la lista real.
      ref.invalidate(misCitasProvider);
      _mostrarAviso(textos.citasCancelarNoDisponible, Tono.advertencia);
    } on Object {
      _mostrarAviso(textos.citasCancelarError, Tono.peligro);
    } finally {
      if (mounted) setState(() => _cancelandoId = null);
    }
  }

  void _mostrarAviso(String mensaje, Tono tono) {
    if (!mounted) return;
    setState(() => _aviso = Aviso(mensaje: mensaje, tono: tono));
  }

  static String _textoEstado(AppLocalizations textos, EstadoDeCita e) =>
      switch (e) {
        EstadoDeCita.confirmada => textos.citasEstadoConfirmada,
        EstadoDeCita.atendida => textos.citasEstadoAtendida,
        EstadoDeCita.noAsistio => textos.citasEstadoNoAsistio,
        EstadoDeCita.cancelada => textos.citasEstadoCancelada,
        EstadoDeCita.desconocido => textos.citasEstadoDesconocido,
      };

  static Tono _tonoEstado(EstadoDeCita e) => switch (e) {
    EstadoDeCita.confirmada => Tono.exito,
    EstadoDeCita.atendida => Tono.informacion,
    EstadoDeCita.noAsistio => Tono.advertencia,
    EstadoDeCita.cancelada => Tono.peligro,
    EstadoDeCita.desconocido => Tono.neutro,
  };

  static String _textoMotivo(AppLocalizations textos, MotivoCita m) =>
      switch (m) {
        MotivoCita.mantenimiento => textos.citasMotivoMantenimiento,
        MotivoCita.reparacion => textos.citasMotivoReparacion,
        MotivoCita.revision => textos.citasMotivoRevision,
        MotivoCita.garantia => textos.citasMotivoGarantia,
        MotivoCita.otro => textos.citasMotivoOtro,
      };
}

/// La próxima cita: la misma tarjeta del inicio (el cuadro con el día, qué día
/// y a qué hora, el vehículo y el motivo) con su estado, y debajo lo que se
/// puede hacer con ella. Sin degradados ni cifras gigantes: lo que destaca es
/// el dato, y el estado va con texto e icono además del color.
class _TarjetaProxima extends StatelessWidget {
  const _TarjetaProxima({
    required this.cita,
    required this.vehiculo,
    required this.textoEstado,
    required this.cancelando,
    required this.ocupado,
    required this.alCancelar,
    this.textoMotivo,
  });

  final CitaCliente cita;
  final String vehiculo;
  final String textoEstado;
  final String? textoMotivo;
  final bool cancelando;
  final bool ocupado;
  final VoidCallback alCancelar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).toString();
    final semana = toBeginningOfSentenceCase(
      DateFormat.EEEE(idioma).format(cita.fecha),
    );
    final tono = _EstadoPantallaMisCitas._tonoEstado(cita.estado);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaciado.e4,
        Espaciado.e2,
        Espaciado.e4,
        Espaciado.e2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TarjetaResumen(
            titulo: textos.citasMisCitasProximaEtiqueta,
            subtitulo: textos.citasMisCitasCuando(
              semana,
              cita.horaInicio,
              cita.horaFin,
            ),
            detalle: switch (textoMotivo) {
              final motivo? => textos.citasMisCitasVehiculoYMotivo(
                vehiculo,
                motivo,
              ),
              null => vehiculo,
            },
            visual: CuadroFecha(fecha: cita.fecha, tono: tono),
            estado: textoEstado,
            tonoEstado: tono,
            estadoConIcono: true,
          ),
          const SizedBox(height: Espaciado.e3),
          _AccionesCita(
            cita: cita,
            ocupado: ocupado,
            cancelando: cancelando,
            alCancelar: alCancelar,
          ),
        ],
      ),
    );
  }
}

/// Comprobante y Reprogramar como píldoras; Cancelar como acción terciaria de
/// peligro. Se usa en la tarjeta héroe y en la hoja de las otras próximas.
class _AccionesCita extends StatelessWidget {
  const _AccionesCita({
    required this.cita,
    required this.ocupado,
    required this.cancelando,
    required this.alCancelar,
    this.antes,
  });

  final CitaCliente cita;

  /// Hay una cancelación en curso: se bloquea lo demás.
  final bool ocupado;
  final bool cancelando;
  final VoidCallback alCancelar;

  /// Se ejecuta antes de cualquier acción (cerrar la hoja).
  final VoidCallback? antes;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Espaciado.e2,
          runSpacing: Espaciado.e2,
          children: [
            BotonPildora(
              texto: textos.citasHeroComprobante,
              icono: LucideIcons300.qrCode,
              alPresionar: ocupado
                  ? null
                  : () {
                      antes?.call();
                      context.push(rutaComprobanteCita(cita.id));
                    },
            ),
            BotonPildora(
              texto: textos.citasReprogramar,
              icono: LucideIcons300.calendarSync,
              variante: VarianteBotonPildora.vidrio,
              alPresionar: ocupado
                  ? null
                  : () {
                      antes?.call();
                      context.push(rutaReprogramarCita(cita.id));
                    },
            ),
          ],
        ),
        const SizedBox(height: Espaciado.e2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: BotonPildora(
            texto: textos.citasCancelar,
            variante: VarianteBotonPildora.peligro,
            cargando: cancelando,
            alPresionar: ocupado
                ? null
                : () {
                    antes?.call();
                    alCancelar();
                  },
          ),
        ),
      ],
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).citasMisCitasCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 176, radio: Radios.tarjeta),
              SizedBox(height: Espaciado.e4),
              Esqueleto(alto: 72),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 72),
            ],
          ),
        ),
      ),
    );
  }
}
