import 'gasto.dart';

/// Rendimiento y costo por kilómetro entre cargas de gasolina (V2-M18.03).
class Rendimiento {
  const Rendimiento({
    required this.kmPorLitro,
    required this.costoPorKm,
    required this.kmRecorridos,
    required this.tramos,
  });

  final double kmPorLitro;

  /// Pesos de gasolina por kilómetro recorrido.
  final double costoPorKm;
  final int kmRecorridos;

  /// Cuántos tramos entre cargas se usaron.
  final int tramos;
}

/// Gasto total (todos los tipos) de un mes; [mes] es el día 1.
class GastoDelMes {
  const GastoDelMes({required this.mes, required this.total});

  final DateTime mes;
  final double total;
}

/// Calcula km/l y $/km con el método del tanque lleno.
///
/// Las cargas con km se ordenan por km (y por fecha si empatan). Cada par
/// consecutivo es un tramo: los km recorridos son la diferencia y el consumo
/// son los litros y el monto de la carga que cierra el tramo. Un tramo sin
/// avance de km se descarta. El resultado pondera por km: suma de km entre
/// suma de litros, no promedio de promedios. Con menos de un tramo válido
/// devuelve nulo.
Rendimiento? calcularRendimiento(List<Gasto> gastos) {
  final cargas =
      [
        for (final g in gastos)
          if (g.esCarga && g.km != null && (g.litros ?? 0) > 0) g,
      ]..sort((a, b) {
        final porKm = a.km!.compareTo(b.km!);
        return porKm != 0 ? porKm : a.fecha.compareTo(b.fecha);
      });

  var km = 0;
  var litros = 0.0;
  var monto = 0.0;
  var tramos = 0;
  for (var i = 1; i < cargas.length; i++) {
    final avance = cargas[i].km! - cargas[i - 1].km!;
    if (avance <= 0) continue;
    km += avance;
    litros += cargas[i].litros!;
    monto += cargas[i].monto;
    tramos++;
  }
  if (tramos == 0) return null;
  return Rendimiento(
    kmPorLitro: km / litros,
    costoPorKm: monto / km,
    kmRecorridos: km,
    tramos: tramos,
  );
}

/// Total de cada mes con gastos, del más viejo al más nuevo.
List<GastoDelMes> gastoPorMes(List<Gasto> gastos) {
  final totales = <DateTime, double>{};
  for (final g in gastos) {
    final mes = DateTime(g.fecha.year, g.fecha.month);
    totales[mes] = (totales[mes] ?? 0) + g.monto;
  }
  final meses = totales.keys.toList()..sort();
  return [for (final m in meses) GastoDelMes(mes: m, total: totales[m]!)];
}

/// Total gastado en el mes de [referencia].
double gastoDelMes(List<Gasto> gastos, DateTime referencia) {
  var total = 0.0;
  for (final g in gastos) {
    if (g.fecha.year == referencia.year && g.fecha.month == referencia.month) {
      total += g.monto;
    }
  }
  return total;
}

/// El km más alto registrado en las cargas: la última lectura que conoce la
/// app para validar el km de la siguiente.
int? kmMasAlto(List<Gasto> gastos) {
  int? alto;
  for (final g in gastos) {
    final k = g.km;
    if (k != null && (alto == null || k > alto)) alto = k;
  }
  return alto;
}
