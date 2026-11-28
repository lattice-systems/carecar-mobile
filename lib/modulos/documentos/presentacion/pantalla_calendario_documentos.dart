import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import 'formato_documentos.dart';
import 'proveedores_documentos.dart';
import 'rutas_documentos.dart';

class PantallaCalendarioDocumentos extends ConsumerStatefulWidget {
  const PantallaCalendarioDocumentos({super.key});
  @override
  ConsumerState<PantallaCalendarioDocumentos> createState() =>
      _PantallaCalendarioDocumentosState();
}

class _PantallaCalendarioDocumentosState
    extends ConsumerState<PantallaCalendarioDocumentos> {
  DateTime _mes = DateUtils.dateOnly(DateTime.now());
  DateTime? _dia;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final vencimientos = ref.watch(vencimientosGarajeProvider);
    return vencimientos.when(
      loading: () => MarcoPantalla.estado(
        titulo: textos.documentosVencimientos,
        conRegreso: true,
        estado: const Esqueleto(alto: 280),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: textos.documentosVencimientos,
        conRegreso: true,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          titulo: textos.documentosErrorCalendario,
          alReintentar: () {
            ref.invalidate(garajeProvider);
            ref.invalidate(documentosProvider);
            ref.invalidate(vencimientosGarajeProvider);
          },
        ),
      ),
      data: (lista) => _calendario(context, lista),
    );
  }

  Widget _calendario(BuildContext context, List<VencimientoVehiculo> lista) {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final porDia = <int, List<VencimientoVehiculo>>{};
    for (final vencimiento in lista) {
      final fecha = vencimiento.fecha;
      if (fecha.year == _mes.year && fecha.month == _mes.month) {
        porDia.putIfAbsent(fecha.day, () => []).add(vencimiento);
      }
    }

    final seleccion = _dia;
    final visibles = seleccion == null
        ? (porDia.values.expand((documentos) => documentos))
        : (porDia[seleccion.day] ?? const <VencimientoVehiculo>[]);
    final primerDia = lista.isNotEmpty && lista.first.fecha.isBefore(hoy)
        ? lista.first.fecha
        : hoy;
    final ultimoDia = lista.isNotEmpty && lista.last.fecha.isAfter(hoy)
        ? lista.last.fecha
        : hoy;
    final formato = MaterialLocalizations.of(context);
    final textos = AppLocalizations.of(context);

    return MarcoPantalla(
      titulo: textos.documentosVencimientos,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          sliver: SliverList.list(
            children: [
              Calendario(
                mes: _mes,
                seleccionado: seleccion,
                hoy: hoy,
                primerDia: DateTime(primerDia.year, primerDia.month),
                ultimoDia: DateTime(ultimoDia.year, ultimoDia.month + 1, 0),
                alCambiarMes: (mes) => setState(() {
                  _mes = mes;
                  _dia = null;
                }),
                alSeleccionar: (dia) => setState(() {
                  _dia = DateUtils.isSameDay(dia, _dia) ? null : dia;
                }),
                marcaDelDia: (dia) => switch (porDia[dia.day]?.length) {
                  null => null,
                  final cantidad? => textos.documentosCantidad(cantidad),
                },
              ),
              const SizedBox(height: Espaciado.e4),
              Semantics(
                header: true,
                child: Text(
                  seleccion == null
                      ? textos.documentosDelMes
                      : formato.formatFullDate(seleccion),
                  style: TokensPista.de(context).tipografia.cuerpoFuerte,
                ),
              ),
              if (seleccion != null)
                Boton(
                  texto: textos.documentosVerMes,
                  variante: VarianteBoton.secundario,
                  alPresionar: () => setState(() => _dia = null),
                ),
              if (visibles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Espaciado.e3),
                  child: Text(
                    seleccion == null
                        ? textos.documentosMesVacio
                        : textos.documentosDiaVacio,
                  ),
                ),
              for (final vencimiento in visibles)
                FilaLista(
                  titulo: nombreDocumento(textos, vencimiento.documento),
                  subtitulo: textos.documentosDetalle(
                    formato.formatMediumDate(vencimiento.fecha),
                    vencimiento.vehiculo.titulo,
                  ),
                  inicio: const Icon(LucideIcons300.calendarDays),
                  alToque: () => context.push(
                    rutaDocumentosVehiculo(vencimiento.vehiculo.id),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
