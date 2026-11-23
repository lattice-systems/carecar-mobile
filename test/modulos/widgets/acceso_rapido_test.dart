import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/modulos/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el icono ofrece Agendar, Mi auto y SOS, en ese orden', () {
    expect(AccesoRapido.values, [
      AccesoRapido.agendar,
      AccesoRapido.miAuto,
      AccesoRapido.sos,
    ]);
  });

  test('el id del atajo viaja por el sistema y vuelve igual', () {
    for (final acceso in AccesoRapido.values) {
      expect(AccesoRapido.desdeId(acceso.id), acceso);
    }
    expect(AccesoRapido.desdeId('otro'), isNull);
    expect(AccesoRapido.desdeId(null), isNull);
  });

  test('los ids son unicos', () {
    final ids = AccesoRapido.values.map((a) => a.id).toSet();
    expect(ids, hasLength(AccesoRapido.values.length));
  });

  test('cada acceso abre su pantalla', () {
    expect(rutaDeAcceso(AccesoRapido.agendar), rutaAgendarCita);
    expect(rutaDeAcceso(AccesoRapido.miAuto), rutaGaraje);
    expect(rutaDeAcceso(AccesoRapido.sos), rutaSos);
  });

  test('las rutas son las que pide la historia', () {
    expect(rutaDeAcceso(AccesoRapido.agendar), '/citas/agendar');
    expect(rutaDeAcceso(AccesoRapido.miAuto), '/garaje');
  });
}
