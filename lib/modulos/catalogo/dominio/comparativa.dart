import 'detalle_modelo.dart';

/// Cuantos modelos se pueden comparar a la vez.
const minimoComparables = 2;
const maximoComparables = 3;

/// Una fila de la comparativa: un dato y su valor en cada modelo.
///
/// `valores` va en el mismo orden que los modelos comparados. Un modelo que no
/// tiene ese dato queda en `null`.
class FilaComparativa {
  const FilaComparativa({required this.etiqueta, required this.valores});

  final String etiqueta;
  final List<String?> valores;
}

/// Arma las filas de la ficha tecnica de varios modelos.
///
/// Dart puro. Las filas salen en el orden en que aparece cada etiqueta por
/// primera vez, sin distinguir mayusculas ni espacios de los bordes, para que
/// "Motor" y "motor " cuenten como el mismo dato. Si un modelo repite una
/// etiqueta, se queda con la primera.
List<FilaComparativa> filasDeFicha(List<DetalleModelo> modelos) {
  String clave(String e) => e.trim().toLowerCase();

  final etiquetas = <String, String>{};
  for (final m in modelos) {
    for (final d in m.ficha) {
      etiquetas.putIfAbsent(clave(d.etiqueta), () => d.etiqueta.trim());
    }
  }

  return [
    for (final e in etiquetas.entries)
      FilaComparativa(
        etiqueta: e.value,
        valores: [
          for (final m in modelos)
            m.ficha
                .where((d) => clave(d.etiqueta) == e.key)
                .map((d) => d.valor)
                .firstOrNull,
        ],
      ),
  ];
}

/// Indice del modelo mas barato entre los que tienen precio, o `null` si no
/// hay precios o todos cuestan lo mismo. Sirve para resaltar el menor precio.
int? indiceMasBarato(List<DetalleModelo> modelos) {
  int? mejor;
  var empate = false;
  for (var i = 0; i < modelos.length; i++) {
    final p = modelos[i].modelo.precioDesde;
    if (p == null) continue;
    final actual = mejor == null ? null : modelos[mejor].modelo.precioDesde;
    if (actual == null || p < actual) {
      mejor = i;
      empate = false;
    } else if (p == actual) {
      empate = true;
    }
  }
  return empate ? null : mejor;
}

/// Lee los ids de `?ids=1,2,3`. Devuelve una lista vacia si algun id no es
/// numero, si hay repetidos o si la cantidad no esta entre el minimo y el maximo.
List<int> idsDeComparativa(String? crudo) {
  if (crudo == null || crudo.trim().isEmpty) return const [];
  final ids = <int>[];
  for (final parte in crudo.split(',')) {
    final id = int.tryParse(parte.trim());
    if (id == null || ids.contains(id)) return const [];
    ids.add(id);
  }
  if (ids.length < minimoComparables || ids.length > maximoComparables) {
    return const [];
  }
  return ids;
}
