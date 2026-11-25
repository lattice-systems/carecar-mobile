import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../api/modelos/comun.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../datos/pdf_bitacora.dart';
import '../dominio/exportar_bitacora.dart';
import '../dominio/gasto.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'formato_bitacora.dart';
import 'proveedores_bitacora.dart';

enum _Aviso { vacio, rango, error }

/// Exportar la bitácora de un vehículo a CSV o PDF (V2-M18.05).
///
/// Se elige el rango de meses (por defecto, todos los que tienen gastos) y el
/// archivo se comparte con la hoja del sistema; nada se guarda en el teléfono.
class PantallaExportar extends ConsumerWidget {
  const PantallaExportar({required this.vehiculoId, super.key, this.nombre});

  final int vehiculoId;
  final String? nombre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final gastos = ref.watch(gastosProvider(vehiculoId));

    Widget estado(Widget hijo) => MarcoPantalla.estado(
      titulo: textos.bitacoraExportarTitulo,
      estado: hijo,
    );

    return gastos.when(
      skipLoadingOnReload: true,
      loading: () => estado(
        Semantics(
          label: textos.bitacoraCargando,
          liveRegion: true,
          child: const Padding(
            padding: EdgeInsets.all(Espaciado.e4),
            child: Column(
              children: [
                Esqueleto(alto: 56),
                SizedBox(height: Espaciado.e3),
                Esqueleto(alto: 56),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(gastosProvider(vehiculoId)),
        ),
      ),
      data: (lista) => lista.isEmpty
          ? estado(
              EstadoVacio(
                titulo: textos.bitacoraVacioTitulo,
                mensaje: textos.bitacoraVacioMensaje,
                icono: Icons.ios_share_outlined,
              ),
            )
          : _Formulario(gastos: lista, nombre: nombre),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.gastos, required this.nombre});

  final List<Gasto> gastos;
  final String? nombre;

  @override
  ConsumerState<_Formulario> createState() => _EstadoFormulario();
}

class _EstadoFormulario extends ConsumerState<_Formulario> {
  late final List<DateTime> _meses = _mesesDisponibles();
  late DateTime _desde = _meses.first;
  late DateTime _hasta = _meses.last;
  bool _ocupado = false;
  _Aviso? _aviso;

  /// Del primer mes con gastos al último (o al actual, el que sea más tarde).
  List<DateTime> _mesesDisponibles() {
    final fechas = [for (final g in widget.gastos) g.fecha]..sort();
    final hoy = ref.read(relojBitacoraProvider)();
    var mes = DateTime(fechas.first.year, fechas.first.month);
    var ultimo = DateTime(fechas.last.year, fechas.last.month);
    final actual = DateTime(hoy.year, hoy.month);
    if (actual.isAfter(ultimo)) ultimo = actual;
    final meses = <DateTime>[];
    while (!mes.isAfter(ultimo)) {
      meses.add(mes);
      mes = DateTime(mes.year, mes.month + 1);
    }
    return meses;
  }

  Future<void> _exportar({required bool pdf}) async {
    if (_desde.isAfter(_hasta)) {
      setState(() => _aviso = _Aviso.rango);
      return;
    }
    final seleccion = gastosEnRango(widget.gastos, _desde, _hasta);
    if (seleccion.isEmpty) {
      setState(() => _aviso = _Aviso.vacio);
      return;
    }
    setState(() {
      _ocupado = true;
      _aviso = null;
    });
    final textos = AppLocalizations.of(context);
    final compartir = ref.read(compartirBitacoraProvider);
    final base = nombreArchivoBitacora(
      widget.nombre ?? 'vehiculo',
      _desde,
      _hasta,
    );
    try {
      if (pdf) {
        final bytes = await generarPdfBitacora(_datosPdf(textos, seleccion));
        await compartir(bytes, '$base.pdf', 'application/pdf');
      } else {
        final bytes = Uint8List.fromList(utf8.encode(gastosACsv(seleccion)));
        await compartir(bytes, '$base.csv', 'text/csv');
      }
    } on Object {
      if (mounted) setState(() => _aviso = _Aviso.error);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  DatosPdfBitacora _datosPdf(AppLocalizations textos, List<Gasto> gastos) {
    final total = gastos.fold<double>(0, (suma, g) => suma + g.monto);
    return DatosPdfBitacora(
      titulo: textos.bitacoraPdfTitulo(widget.nombre ?? textos.bitacoraTitulo),
      periodo: textos.bitacoraPdfPeriodo(
        mesLegible(context, _desde),
        mesLegible(context, _hasta),
      ),
      columnas: [
        textos.bitacoraColumnaFecha,
        textos.bitacoraColumnaTipo,
        textos.bitacoraColumnaMonto,
        textos.bitacoraColumnaLitros,
        textos.bitacoraColumnaKm,
        textos.bitacoraColumnaDetalle,
      ],
      filas: [
        for (final g in gastos)
          [
            escribirFecha(g.fecha),
            nombreTipo(textos, g.tipo),
            pesos(context, g.monto),
            g.litros == null ? '' : numero(context, g.litros!, decimales: 2),
            g.km == null ? '' : numero(context, g.km!),
            g.descripcion ?? '',
          ],
      ],
      total: textos.bitacoraPdfTotal(pesos(context, total)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;

    List<OpcionSelector<DateTime>> opciones() => [
      for (final m in _meses)
        OpcionSelector(valor: m, texto: mesLegible(context, m)),
    ];

    return MarcoPantalla(
      titulo: textos.bitacoraExportarTitulo,
      barraInferior: BarraInferior(
        hijos: [
          BotonPildora(
            texto: textos.bitacoraExportarCsv,
            icono: Icons.table_chart_outlined,
            expandido: true,
            alPresionar: _ocupado ? null : () => _exportar(pdf: false),
          ),
          const SizedBox(height: Espaciado.e2),
          BotonPildora(
            texto: textos.bitacoraExportarPdf,
            icono: Icons.picture_as_pdf_outlined,
            variante: VarianteBotonPildora.tonal,
            expandido: true,
            alPresionar: _ocupado ? null : () => _exportar(pdf: true),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_aviso != null) ...[
                  switch (_aviso!) {
                    _Aviso.vacio => Aviso(
                      mensaje: textos.bitacoraExportarVacio,
                      tono: Tono.informacion,
                    ),
                    _Aviso.rango => Aviso(
                      mensaje: textos.bitacoraExportarRangoInvalido,
                      tono: Tono.advertencia,
                    ),
                    _Aviso.error => Aviso(
                      mensaje: textos.bitacoraExportarError,
                      tono: Tono.peligro,
                    ),
                  },
                  const SizedBox(height: Espaciado.e3),
                ],
                Text(
                  textos.bitacoraExportarIntro,
                  style: tokens.tipografia.cuerpo.copyWith(
                    color: c.textoSecundario,
                  ),
                ),
                const SizedBox(height: Espaciado.e4),
                Selector<DateTime>(
                  etiqueta: textos.bitacoraExportarDesde,
                  valor: _desde,
                  opciones: opciones(),
                  alCambiar: (m) => setState(() {
                    _desde = m ?? _desde;
                    _aviso = null;
                  }),
                ),
                const SizedBox(height: Espaciado.e3),
                Selector<DateTime>(
                  etiqueta: textos.bitacoraExportarHasta,
                  valor: _hasta,
                  opciones: opciones(),
                  alCambiar: (m) => setState(() {
                    _hasta = m ?? _hasta;
                    _aviso = null;
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
