import 'package:carecar_mobile/api/modelos/cita.dart';
import 'package:carecar_mobile/api/modelos/disponibilidad.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/auditoria_rutas.dart';

void main() {
  testWidgets('las pantallas de citas pasan la auditoría', (tester) async {
    final manana = DateTime.now().add(const Duration(days: 1));
    await montarParaAuditar(
      tester,
      api: ApiFalsa()
        ..alPedirCitas = () async {
          return [
            Cita(
              id: 1,
              vehiculoId: 1,
              franjaId: 1,
              fecha: manana,
              horaInicio: '09:00',
              horaFin: '10:00',
              estado: EstadoCita.confirmada,
            ),
          ];
        }
        ..alPedirDisponibilidad = (_, _) async => [
          Disponibilidad(
            fecha: manana,
            franjaId: 1,
            horaInicio: '09:00',
            horaFin: '10:00',
            cupoDisponible: 2,
          ),
        ],
    );
    await auditarRutas(tester, {
      rutaMisCitas: PantallaMisCitas,
      rutaComprobanteCita(1): PantallaComprobanteCita,
    });
    await auditarRutas(tester, {
      rutaDisponibilidad: PantallaDisponibilidad,
      rutaAgendarCita: PantallaAgendarCita,
      rutaReprogramarCita(1): PantallaReprogramarCita,
    }, conCalendario: true);
  });
}
