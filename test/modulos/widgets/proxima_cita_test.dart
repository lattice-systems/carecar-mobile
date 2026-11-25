import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/bitacora/bitacora.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/modulos/widgets/dominio/contenido_widgets.dart';
import 'package:carecar_mobile/modulos/widgets/dominio/proxima_cita_widget.dart';
import 'package:carecar_mobile/nucleo/navegacion/enlaces.dart';
import 'package:flutter_test/flutter_test.dart';

CitaCliente _cita(
  int id,
  DateTime fecha, {
  String hora = '09:00',
  EstadoDeCita estado = EstadoDeCita.confirmada,
}) => CitaCliente(
  id: id,
  vehiculoId: 1,
  fecha: fecha,
  horaInicio: hora,
  horaFin: '10:00',
  estado: estado,
  vehiculoNombre: 'Aveo 2021',
);

void main() {
  final ahora = DateTime(2026, 11, 22, 12);

  group('proximaCita', () {
    test('es la confirmada que empieza primero', () {
      final citas = [
        _cita(1, DateTime(2026, 12, 5)),
        _cita(2, DateTime(2026, 11, 25)),
        _cita(3, DateTime(2026, 11, 30)),
      ];
      expect(proximaCita(citas, ahora)?.id, 2);
    });

    test('ignora canceladas, atendidas y las que ya pasaron', () {
      final citas = [
        _cita(1, DateTime(2026, 11, 23), estado: EstadoDeCita.cancelada),
        _cita(2, DateTime(2026, 11, 24), estado: EstadoDeCita.atendida),
        _cita(3, DateTime(2026, 11, 22), hora: '08:00'),
        _cita(4, DateTime(2026, 12, 1)),
      ];
      expect(proximaCita(citas, ahora)?.id, 4);
    });

    test('sin citas por venir no hay proxima', () {
      expect(proximaCita(const [], ahora), isNull);
      expect(proximaCita([_cita(1, DateTime(2026, 11, 1))], ahora), isNull);
    });
  });

  group('enlaces del widget', () {
    test('abrir la cita lleva al comprobante por carecar://', () {
      final enlace = enlaceDeCitaWidget(7);
      expect(enlace, 'carecar://citas/7/comprobante');
      expect(
        EnlacesApp.aRutaInterna(Uri.parse(enlace))?.path,
        rutaComprobanteCita(7),
      );
    });

    test('sin cita el enlace lleva a agendar', () {
      expect(
        EnlacesApp.aRutaInterna(Uri.parse(enlaceAgendarWidget))?.path,
        rutaAgendarCita,
      );
    });
  });

  group('enlaces de los demas widgets', () {
    Uri? ruta(String enlace) => EnlacesApp.aRutaInterna(Uri.parse(enlace));

    test('cada enlace es una ruta que existe en su modulo', () {
      expect(ruta(enlaceDeRuta(rutaOrdenTaller(41)))?.path, '/taller/41');
      expect(
        ruta(enlaceDeRuta(rutaMantenimientoVehiculo(7)))?.path,
        rutaMantenimientoVehiculo(7),
      );
      expect(ruta(enlaceDeRuta('/bitacora/7'))?.path, rutaBitacoraVehiculo(7));
      expect(ruta(enlaceDeRuta(rutaGaraje))?.path, rutaGaraje);
      expect(ruta(enlaceDeRuta(rutaSos))?.path, rutaSos);
      expect(ruta(enlaceDeRuta(rutaMisCitas))?.path, rutaMisCitas);
    });
  });
}
