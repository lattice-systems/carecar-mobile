import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/cita_cliente.dart';
import '../dominio/fallos_agenda.dart';
import '../dominio/motivo_cita.dart';
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

    final Widget cuerpo;
    if (citas.hasError && !citas.hasValue) {
      cuerpo = EstadoError(
        causa: citas.error is SinConexion
            ? CausaError.sinConexion
            : CausaError.generico,
        alReintentar: () => ref.invalidate(misCitasProvider),
      );
    } else if (!citas.hasValue) {
      cuerpo = const _Cargando();
    } else if (citas.requireValue.citas.isEmpty) {
      cuerpo = EstadoVacio(
        titulo: textos.citasMisCitasVacioTitulo,
        mensaje: textos.citasMisCitasVacioMensaje,
        icono: Icons.event_note_outlined,
        textoAccion: textos.citasMisCitasAgendar,
        alAccion: () => context.push(rutaAgendarCita),
      );
    } else {
      cuerpo = _lista(context, citas.requireValue);
    }

    return Scaffold(
      appBar: AppBar(title: Text(textos.citasMisCitasTitulo)),
      body: cuerpo,
    );
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

    Widget encabezado(String texto) => Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaciado.e4,
        Espaciado.e4,
        Espaciado.e4,
        Espaciado.e1,
      ),
      child: Semantics(
        header: true,
        child: Text(
          texto,
          style: tokens.tipografia.titulo3.copyWith(
            color: tokens.colores.texto,
          ),
        ),
      ),
    );

    Widget vacio(String texto) => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaciado.e4,
        vertical: Espaciado.e2,
      ),
      child: Text(
        texto,
        style: tokens.tipografia.cuerpo.copyWith(
          color: tokens.colores.textoSecundario,
        ),
      ),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(misCitasProvider);
        await ref.read(misCitasProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ?_aviso,
          encabezado(textos.citasProximas),
          if (proximas.isEmpty) vacio(textos.citasProximasVacio),
          for (final c in proximas) _fila(context, c, vehiculos, ahora),
          encabezado(textos.citasPasadas),
          if (pasadas.isEmpty) vacio(textos.citasPasadasVacio),
          for (final c in pasadas) _fila(context, c, vehiculos, ahora),
          if (estado.errorAlCargarMas)
            Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Aviso(mensaje: textos.citasErrorMas, tono: Tono.peligro),
            ),
          if (estado.hayMas)
            Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Boton(
                texto: textos.citasCargarMas,
                variante: VarianteBoton.secundario,
                anchoCompleto: true,
                cargando: estado.cargandoMas,
                alPresionar: () =>
                    ref.read(misCitasProvider.notifier).cargarMas(),
              ),
            ),
          const SizedBox(height: Espaciado.e4),
        ],
      ),
    );
  }

  Widget _fila(
    BuildContext context,
    CitaCliente cita,
    Map<int, String> vehiculos,
    DateTime ahora,
  ) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final vehiculo =
        cita.vehiculoNombre ??
        vehiculos[cita.vehiculoId] ??
        textos.citasFilaVehiculoGenerico;
    final motivo = cita.motivo;
    final modificable = cita.sePuedeModificar(ahora);
    final fila = FilaLista(
      titulo: textos.citasFilaTitulo(cita.fecha, cita.horaInicio),
      subtitulo: motivo == null
          ? vehiculo
          : '$vehiculo · ${_textoMotivo(textos, motivo)}',
      fin: Insignia(
        texto: _textoEstado(textos, cita.estado),
        tono: _tonoEstado(cita.estado),
        conIcono: true,
      ),
      conChevron: false,
      conDivisor: !modificable,
    );
    if (!modificable) return fila;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fila,
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            0,
            Espaciado.e4,
            Espaciado.e2,
          ),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: Espaciado.e2,
            children: [
              Boton(
                texto: textos.citasCancelar,
                variante: VarianteBoton.terciario,
                tamano: TamanoBoton.chico,
                cargando: _cancelandoId == cita.id,
                alPresionar: _cancelandoId == null
                    ? () => _cancelar(cita)
                    : null,
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: tokens.colores.borde),
      ],
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

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).citasMisCitasCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 72),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 72),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 72),
          ],
        ),
      ),
    );
  }
}
