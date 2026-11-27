import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';

void main() {
  testWidgets('las pantallas de recolección pasan la auditoría', (
    tester,
  ) async {
    await montarParaAuditar(
      tester,
      overrides: [
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
        repositorioRecoleccionProvider.overrideWithValue(
          RepositorioRecoleccionFake(
            traslados: [
              TrasladoDetalle(
                id: 5,
                citaId: 9,
                tipo: 'recoger',
                estado: EstadoTraslado.recogido,
                costo: 150,
                fecha: DateTime(2026, 12),
                ventanaInicio: '07:00',
                ventanaFin: '09:00',
              ),
            ],
          ),
        ),
      ],
    );
    await auditarRutas(tester, {
      rutaMisDirecciones: PantallaMisDirecciones,
      rutaSeguimientoTraslado(5): PantallaSeguimientoTraslado,
      rutaChecklistTraslado(5): PantallaChecklistTraslado,
    });
  });
}
