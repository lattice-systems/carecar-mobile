import '../../../api/modelos/comun.dart';
import 'gasto.dart';

/// Gastos entre el mes [desde] y el mes [hasta], ambos incluidos, del más
/// reciente al más viejo (V2-M18.05).
List<Gasto> gastosEnRango(List<Gasto> gastos, DateTime desde, DateTime hasta) {
  final inicio = DateTime(desde.year, desde.month);
  final fin = DateTime(hasta.year, hasta.month + 1);
  return [
    for (final g in gastos)
      if (!g.fecha.isBefore(inicio) && g.fecha.isBefore(fin)) g,
  ]..sort((a, b) {
    final porFecha = b.fecha.compareTo(a.fecha);
    return porFecha != 0 ? porFecha : b.id.compareTo(a.id);
  });
}

/// La bitácora como CSV (UTF-8 con marca BOM para que Excel lea los acentos).
///
/// Fechas ISO, decimales con punto y campo vacío donde el dato no aplica.
String gastosACsv(List<Gasto> gastos) {
  final filas = [
    'fecha,tipo,monto,litros,km,descripcion',
    for (final g in gastos)
      [
        escribirFecha(g.fecha),
        g.tipo.enContrato,
        g.monto.toStringAsFixed(2),
        g.litros == null ? '' : _sinCeros(g.litros!),
        g.km?.toString() ?? '',
        _campo(g.descripcion),
      ].join(','),
  ];
  return '﻿${filas.join('\r\n')}\r\n';
}

String _sinCeros(double v) {
  final texto = v.toStringAsFixed(3);
  return texto
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Entrecomilla el texto si lleva coma, comilla o salto de línea.
String _campo(String? texto) {
  if (texto == null || texto.isEmpty) return '';
  if (!texto.contains(RegExp(r'[",\r\n]'))) return texto;
  return '"${texto.replaceAll('"', '""')}"';
}

/// Nombre de archivo sin extensión: `bitacora-aveo-2022-2026-09-a-2026-11`.
String nombreArchivoBitacora(String vehiculo, DateTime desde, DateTime hasta) {
  String mes(DateTime m) => '${m.year}-${m.month.toString().padLeft(2, '0')}';
  const acentos = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n'};
  var limpio = vehiculo.toLowerCase();
  acentos.forEach((k, v) => limpio = limpio.replaceAll(k, v));
  limpio = limpio
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final nombre = limpio.isEmpty ? 'vehiculo' : limpio;
  return 'bitacora-$nombre-${mes(desde)}-a-${mes(hasta)}';
}
