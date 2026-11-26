/// Arma el contenido de cada widget de inicio a partir de los datos de los
/// módulos (V2-M25). Funciones puras: reciben los datos ya cargados y los
/// textos del idioma activo; el sincronizador decide cuándo llamarlas.
///
/// Cada una devuelve el estado con datos o, si no hay nada que mostrar, el
/// estado vacío del mismo widget. Solo se usan los contratos públicos de los
/// otros módulos.
library;

import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../asistencia/asistencia.dart';
import '../../bitacora/bitacora.dart';
import '../../citas/citas.dart';
import '../../mantenimiento/mantenimiento.dart';
import '../../taller/taller.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/contenido_widgets.dart';
import '../dominio/proxima_cita_widget.dart' show enlaceDeCitaWidget;

/// Cifras con punto decimal y coma de millares, como en México.
String _numeros(String idioma) => idioma.startsWith('es') ? 'es_MX' : 'en_US';

String _unir(Iterable<String?> partes) =>
    partes.where((p) => p != null && p.isNotEmpty).join('. ');

/// Próxima cita: día grande, hora y vehículo; abre su comprobante.
ContenidoWidget contenidoDeCita(AppLocalizations t, CitaCliente? cita) {
  if (cita == null) {
    return ContenidoWidget.proximaCitaVacia(
      titulo: t.widgetsProximaCitaTitulo,
      mensaje: t.widgetsSinCitaMensaje,
      accion: t.widgetsAgendar,
    );
  }
  final idioma = t.localeName;
  final horario = t.widgetsProximaCitaHorario(cita.horaInicio, cita.horaFin);
  final mes = DateFormat.MMM(idioma).format(cita.fecha).replaceAll('.', '');
  return ContenidoWidget.proximaCita(
    titulo: t.widgetsProximaCitaTitulo,
    dia: DateFormat.d(idioma).format(cita.fecha),
    mes: mes.toUpperCase(),
    semana: DateFormat.E(idioma).format(cita.fecha).replaceAll('.', ''),
    horario: horario,
    vehiculo: cita.vehiculoNombre,
    descripcion: _unir([
      t.widgetsProximaCitaTitulo,
      t.widgetsProximaCitaFecha(cita.fecha),
      horario,
      cita.vehiculoNombre,
    ]),
    citaId: cita.id,
  );
}

/// Cuántas etapas tiene el recorrido de una orden sin contar «entregado», que
/// es cuando la orden deja de estar abierta.
final int _etapasDelTaller = EtapaTaller.values.length - 1;

/// Taller en vivo: etapa actual con su paso y la entrega estimada.
ContenidoWidget contenidoDeTaller(AppLocalizations t, OrdenEnCurso? orden) {
  if (orden == null) {
    return ContenidoWidget.tallerVacio(
      titulo: t.widgetsTallerEncabezado,
      mensaje: t.widgetsTallerVacioMensaje,
      accion: t.widgetsAgendar,
    );
  }
  final total = _etapasDelTaller;
  final paso = (orden.etapa.index + 1).clamp(1, total);
  final etapa = textoEtapa(t, orden.etapa);
  final pasoTexto = t.widgetsTallerPaso(paso, total);
  final entregaEstimada = orden.entregaEstimada;
  final entrega = entregaEstimada == null
      ? null
      : t.widgetsTallerEntrega(
          DateFormat.MMMd(t.localeName).add_Hm().format(entregaEstimada),
        );
  return ContenidoWidget.taller(
    titulo: t.widgetsTallerEncabezado,
    etapa: etapa,
    paso: paso,
    total: total,
    pasoTexto: pasoTexto,
    entrega: entrega,
    vehiculo: orden.vehiculo,
    descripcion: _unir([
      t.widgetsTallerEncabezado,
      etapa,
      pasoTexto,
      entrega,
      orden.vehiculo,
    ]),
    ordenId: orden.id,
  );
}

/// Avance hacia el próximo servicio: de 0 a 100 entre el servicio anterior del
/// plan (o el km 0) y el objetivo.
int _progresoDelServicio(PlanMantenimiento plan, ProximoServicio proximo) {
  if (proximo.yaToca) return 100;
  var base = 0;
  for (final s in plan.servicios) {
    if (s.km < proximo.kmObjetivo && s.km > base) base = s.km;
  }
  final tramo = proximo.kmObjetivo - base;
  if (tramo <= 0) return 0;
  final recorrido = tramo - proximo.faltanKm;
  return (recorrido * 100 / tramo).round().clamp(0, 100);
}

/// Mantenimiento: próximo servicio con km faltantes, fecha estimada y avance.
ContenidoWidget contenidoDeMantenimiento(
  AppLocalizations t,
  PlanMantenimiento? plan,
  VehiculoGaraje? vehiculo,
) {
  final proximo = plan?.proximo;
  if (plan == null || proximo == null || vehiculo == null) {
    return ContenidoWidget.mantenimientoVacio(
      titulo: t.widgetsMantenimientoTitulo,
      mensaje: t.widgetsMantenimientoVacioMensaje,
      accion: t.widgetsMantenimientoAccion,
    );
  }
  final idioma = t.localeName;
  final faltan = proximo.faltanKm <= 0
      ? t.widgetsMantenimientoYaToca
      : t.widgetsMantenimientoFaltanKm(
          NumberFormat.decimalPattern('en').format(proximo.faltanKm),
        );
  final fecha = t.widgetsMantenimientoFecha(
    DateFormat.MMMd(idioma).format(proximo.fechaEstimada).replaceAll('.', ''),
  );
  return ContenidoWidget.mantenimiento(
    titulo: t.widgetsMantenimientoTitulo,
    servicio: proximo.nombre,
    faltan: faltan,
    fecha: fecha,
    progreso: _progresoDelServicio(plan, proximo),
    urgente: proximo.yaToca,
    vehiculo: vehiculo.titulo,
    descripcion: _unir([
      t.widgetsMantenimientoTitulo,
      proximo.nombre,
      faltan,
      fecha,
      vehiculo.titulo,
    ]),
    vehiculoId: vehiculo.id,
  );
}

/// Bitácora: rendimiento en km/l y gasto del mes, en cifras grandes.
ContenidoWidget contenidoDeBitacora(
  AppLocalizations t,
  List<Gasto>? gastos,
  VehiculoGaraje? vehiculo,
  DateTime ahora,
) {
  if (gastos == null || gastos.isEmpty || vehiculo == null) {
    return ContenidoWidget.bitacoraVacia(
      titulo: t.widgetsBitacoraTitulo,
      mensaje: t.widgetsBitacoraVacioMensaje,
      accion: t.widgetsBitacoraAccion,
    );
  }
  final idioma = t.localeName;
  final rendimiento = calcularRendimiento(gastos);
  final rendimientoTexto = rendimiento == null
      ? null
      : NumberFormat('0.0', _numeros(idioma)).format(rendimiento.kmPorLitro);
  final gasto = NumberFormat.currency(
    locale: _numeros(idioma),
    symbol: r'$',
    decimalDigits: 0,
  ).format(gastoDelMes(gastos, ahora));
  final etiqueta = t.widgetsBitacoraGastoMes(
    DateFormat.MMMM(idioma).format(ahora),
  );
  final unidad = t.widgetsBitacoraRendimientoUnidad;
  final etiquetaRendimiento = t.widgetsBitacoraRendimientoEtiqueta;
  return ContenidoWidget.bitacora(
    titulo: t.widgetsBitacoraTitulo,
    rendimiento: rendimientoTexto,
    unidad: unidad,
    etiquetaRendimiento: etiquetaRendimiento,
    gasto: gasto,
    etiquetaGasto: etiqueta,
    vehiculo: vehiculo.titulo,
    descripcion: _unir([
      t.widgetsBitacoraTitulo,
      if (rendimientoTexto != null)
        '$etiquetaRendimiento $rendimientoTexto $unidad',
      '$etiqueta $gasto',
      vehiculo.titulo,
    ]),
    vehiculoId: vehiculo.id,
  );
}

/// Accesos rápidos. El comprobante abre el de la próxima cita; sin cita, la
/// lista de citas.
ContenidoWidget contenidoDeAccesos(AppLocalizations t, CitaCliente? proxima) =>
    ContenidoWidget.accesos(
      titulo: t.widgetsAccesosTitulo,
      agendar: t.widgetsAgendar,
      miAuto: t.widgetsAccesoMiAuto,
      sos: t.widgetsAccesoSos,
      comprobante: t.widgetsAccesoComprobante,
      enlaceComprobante: proxima == null
          ? enlaceDeRuta(rutaMisCitas)
          : enlaceDeCitaWidget(proxima.id),
      enlaceSos: enlaceDeRuta(rutaSos),
    );
