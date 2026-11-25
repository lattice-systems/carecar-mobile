import 'package:carecar_mobile/modulos/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el enlace de la orden es la ruta /taller/:id en carecar://', () {
    expect(enlaceDeOrdenWidget(41), 'carecar://taller/41');
  });

  test('con el auto en el taller lleva solo auto, etapa y entrega', () {
    final c = ContenidoWidgetCita.enTaller(
      titulo: 'Tu auto en el taller',
      etapa: 'En reparación',
      entrega: 'Entrega estimada: 24 nov 18:00',
      vehiculo: 'Nissan March 2026',
      ordenId: 41,
    );
    expect(c.hayCita, isTrue);
    expect(c.fecha, 'En reparación');
    expect(c.horario, 'Entrega estimada: 24 nov 18:00');
    expect(c.vehiculo, 'Nissan March 2026');
    expect(c.enlace, 'carecar://taller/41');
    expect(c.mensaje, isNull);
  });

  test('sin hora estimada no hay linea de entrega', () {
    final c = ContenidoWidgetCita.enTaller(
      titulo: 't',
      etapa: 'Recibido',
      vehiculo: 'Aveo',
      ordenId: 1,
    );
    expect(c.horario, isNull);
  });
}
