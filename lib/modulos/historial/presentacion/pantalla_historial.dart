import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/orden_historial.dart';
import 'formato_historial.dart';
import 'proveedores_historial.dart';
import 'rutas_historial.dart';

/// Historial de servicios de un vehiculo (V2-M02.05): las ordenes de la mas
/// reciente a la mas antigua con su fecha de cierre, estatus y total. Se
/// filtra por año y carga la pagina siguiente al llegar al final. Resuelve los
/// cinco estados: esqueleto, datos, vacio, error con reintento y sin conexion.
class PantallaHistorial extends ConsumerStatefulWidget {
  const PantallaHistorial({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  ConsumerState<PantallaHistorial> createState() => _EstadoPantallaHistorial();
}

class _EstadoPantallaHistorial extends ConsumerState<PantallaHistorial> {
  int? _anio;

  ConsultaHistorial get _consulta =>
      (vehiculoId: widget.vehiculoId, anio: _anio);

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final historial = ref.watch(historialProvider(_consulta));
    final vehiculo = ref.watch(vehiculoProvider(widget.vehiculoId)).value;

    Widget estado(Widget hijo) => SliverFillRemaining(child: hijo);

    final List<Widget> contenido;
    if (historial.hasError && !historial.hasValue) {
      contenido = [
        estado(
          EstadoError(
            causa: historial.error is SinConexion
                ? CausaError.sinConexion
                : CausaError.generico,
            textoReintentar: textos.historialReintentar,
            alReintentar: () => ref.invalidate(historialProvider(_consulta)),
          ),
        ),
      ];
    } else if (!historial.hasValue) {
      contenido = [const SliverToBoxAdapter(child: _Cargando())];
    } else if (historial.requireValue.ordenes.isEmpty) {
      contenido = [
        estado(
          EstadoVacio(
            titulo: textos.historialVacioTitulo,
            mensaje: _anio == null
                ? textos.historialVacioMensaje
                : textos.historialVacioAnioMensaje('$_anio'),
            icono: Icons.history,
          ),
        ),
      ];
    } else {
      contenido = _lista(context, historial.requireValue);
    }

    return Scaffold(
      backgroundColor: TokensPista.de(context).colores.fondo,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(aniosHistorialProvider(widget.vehiculoId));
          ref.invalidate(historialProvider(_consulta));
          await ref.read(historialProvider(_consulta).future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            EncabezadoGrande(
              titulo: textos.historialTitulo,
              subtitulo: vehiculo?.titulo,
              translucido: true,
            ),
            SliverToBoxAdapter(child: _filtro(context)),
            ...contenido,
            const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
          ],
        ),
      ),
    );
  }

  Widget _filtro(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final anios =
        ref.watch(aniosHistorialProvider(widget.vehiculoId)).value ??
        const <int>[];
    if (anios.length < 2 && _anio == null) return const SizedBox.shrink();
    void elegir(int? anio) {
      if (anio != _anio) setState(() => _anio = anio);
    }

    return Semantics(
      container: true,
      label: textos.historialFiltroEtiqueta,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          Espaciado.margenTelefono,
          0,
          Espaciado.margenTelefono,
          Espaciado.e3,
        ),
        child: Row(
          children: [
            ChipPista(
              texto: textos.historialFiltroTodos,
              seleccionado: _anio == null,
              alCambiar: (_) => elegir(null),
            ),
            for (final anio in anios)
              Padding(
                padding: const EdgeInsets.only(left: Espaciado.e2),
                child: ChipPista(
                  texto: anio.toString(),
                  seleccionado: _anio == anio,
                  alCambiar: (_) => elegir(anio),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _lista(BuildContext context, EstadoHistorial estado) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Espaciado.margenTelefono,
          ),
          child: GrupoLista(
            filas: [
              for (final orden in estado.ordenes)
                FilaGrupo(
                  titulo: fechaDe(context, orden.fecha),
                  subtitulo: textos.historialEstatusYCierre(
                    textoEstatus(textos, orden.estatus),
                    orden.fechaCierre == null
                        ? textos.historialSinCierre
                        : textos.historialCerradaEl(
                            fechaHoraDe(context, orden.fechaCierre!),
                          ),
                  ),
                  icono: _iconoEstatus(orden.estatus),
                  colorIcono: _colorEstatus(tokens, orden.estatus),
                  fin: Text(
                    monedaDe(context, orden.total),
                    textAlign: TextAlign.end,
                    style: tokens.tipografia.cuerpoFuerte.copyWith(
                      color: tokens.colores.texto,
                    ),
                  ),
                  alToque: () => context.push(
                    rutaTicketServicio(widget.vehiculoId, orden.id),
                  ),
                ),
            ],
          ),
        ),
      ),
      if (estado.errorAlCargarMas)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Column(
              children: [
                Aviso(mensaje: textos.historialErrorMas, tono: Tono.peligro),
                const SizedBox(height: Espaciado.e2),
                BotonPildora(
                  texto: textos.historialReintentar,
                  variante: VarianteBotonPildora.vidrio,
                  icono: Icons.refresh_rounded,
                  alPresionar: () => ref
                      .read(historialProvider(_consulta).notifier)
                      .cargarMas(),
                ),
              ],
            ),
          ),
        )
      else if (estado.hayMas)
        SliverToBoxAdapter(
          child: _CargarAlLlegar(
            key: ValueKey(('pagina', _anio, estado.pagina)),
            etiqueta: textos.historialCargandoMas,
            alLlegar: () =>
                ref.read(historialProvider(_consulta).notifier).cargarMas(),
          ),
        ),
    ];
  }
}

IconData _iconoEstatus(EstatusOrden estatus) => switch (estatus) {
  EstatusOrden.recibido => Icons.login_rounded,
  EstatusOrden.enProceso => Icons.build_circle_outlined,
  EstatusOrden.terminado => Icons.task_alt_rounded,
  EstatusOrden.entregado => Icons.directions_car_filled_outlined,
  EstatusOrden.desconocido => Icons.help_outline_rounded,
};

Color _colorEstatus(TokensPista tokens, EstatusOrden estatus) {
  final c = tokens.colores;
  return switch (estatus) {
    EstatusOrden.recibido => c.acento,
    EstatusOrden.enProceso => c.advertencia,
    EstatusOrden.terminado => c.exito,
    EstatusOrden.entregado => c.marca,
    EstatusOrden.desconocido => c.textoTerciario,
  };
}

/// Se construye cuando el final de la lista entra en pantalla y pide la pagina
/// siguiente una sola vez. Mientras llega se ve un indicador.
class _CargarAlLlegar extends StatefulWidget {
  const _CargarAlLlegar({
    required this.etiqueta,
    required this.alLlegar,
    super.key,
  });

  final String etiqueta;
  final VoidCallback alLlegar;

  @override
  State<_CargarAlLlegar> createState() => _CargarAlLlegarState();
}

class _CargarAlLlegarState extends State<_CargarAlLlegar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.alLlegar();
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Espaciado.e4),
    child: Center(
      child: Semantics(
        label: widget.etiqueta,
        child: const SizedBox.square(
          dimension: Espaciado.e6,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
  );
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 4; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: Espaciado.e3),
            child: Esqueleto(alto: 64),
          ),
      ],
    ),
  );
}
