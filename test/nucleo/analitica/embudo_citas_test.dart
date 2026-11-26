import 'package:carecar_mobile/nucleo/analitica/analitica.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'V2-M23.03: el embudo deduplica pasos y respeta la revocación',
    () async {
      var activa = false;
      var revision = 0;
      final eventos = <Map<String, Object>>[];
      final analitica = Analitica(() => activa, (evento, puedeEnviar) async {
        if (puedeEnviar()) eventos.add(evento);
      }, revision: () => revision);
      final embudo = EmbudoCitas();

      await embudo.mostrarDisponibilidad(analitica);
      expect(eventos, isEmpty);
      activa = true;
      revision++;
      await embudo.mostrarDisponibilidad(analitica);
      await embudo.mostrarDisponibilidad(analitica);
      await embudo.elegirFranja(analitica);
      await embudo.elegirFranja(analitica);
      final primero = embudo.intento;
      activa = false;
      revision++;
      activa = true;
      revision++;
      await embudo.confirmar(analitica, 1, primero);
      expect(eventos.map((e) => e['tipo']), ['DISPONIBILIDAD', 'FRANJA']);

      await embudo.mostrarDisponibilidad(analitica);
      final segundo = embudo.intento;
      expect(segundo, isNot(primero));
      await embudo.elegirFranja(analitica);
      await embudo.confirmar(analitica, 2, segundo);
      await embudo.confirmar(analitica, 2, segundo);
      expect(eventos.last, {
        'tipo': 'CONFIRMADA',
        'intento': segundo,
        'citaId': 2,
      });
      expect(eventos.where((e) => e['tipo'] == 'CONFIRMADA'), hasLength(1));
    },
  );
}
