import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'la conexion solo vive mientras alguien escucha eventosProvider',
    () async {
      final canal = EventosEnVivoFake();
      final contenedor = ProviderContainer(
        overrides: [eventosEnVivoProvider.overrideWithValue(canal)],
      );
      addTearDown(contenedor.dispose);

      expect(canal.escuchas, 0);

      final recibidos = <String>[];
      final suscripcion = contenedor.listen(eventosProvider, (_, nuevo) {
        nuevo.whenData((e) => recibidos.add(e.nombre));
      });
      await Future<void>.delayed(Duration.zero);
      expect(canal.escuchas, 1);

      canal.emitir('asistencia.estado', {'solicitudId': 1});
      await Future<void>.delayed(Duration.zero);
      expect(recibidos, ['asistencia.estado']);

      suscripcion.close();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(canal.escuchas, 0);
    },
  );
}
