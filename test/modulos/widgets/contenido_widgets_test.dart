import 'package:carecar_mobile/modulos/widgets/dominio/contenido_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TipoWidget', () {
    test('cada widget tiene su prefijo, su proveedor y su kind propios', () {
      final prefijos = TipoWidget.values.map((t) => t.prefijo).toSet();
      final proveedores = TipoWidget.values
          .map((t) => t.proveedorAndroid)
          .toSet();
      final kinds = TipoWidget.values.map((t) => t.tipoIos).toSet();
      expect(prefijos, hasLength(TipoWidget.values.length));
      expect(proveedores, hasLength(TipoWidget.values.length));
      expect(kinds, hasLength(TipoWidget.values.length));
    });

    test('las claves del almacen llevan el prefijo del widget', () {
      expect(TipoWidget.taller.clave('etapa'), 'taller_etapa');
      expect(TipoWidget.bitacora.clave('gasto'), 'bit_gasto');
    });
  });

  group('proxima cita', () {
    test(
      'con cita trae dia grande, horario, vehiculo y enlace al comprobante',
      () {
        final c = ContenidoWidget.proximaCita(
          titulo: 'Próxima cita',
          dia: '24',
          mes: 'NOV',
          semana: 'mar',
          horario: '09:00 a 10:00',
          vehiculo: 'Aveo 2021',
          descripcion: 'Próxima cita, martes 24 de noviembre',
          citaId: 7,
        );
        expect(c.tipo, TipoWidget.proximaCita);
        expect(c.hayDatos, isTrue);
        expect(c.enlace, 'carecar://citas/7/comprobante');
        expect(c.almacen['cita_dia'], '24');
        expect(c.almacen['cita_mes'], 'NOV');
        expect(c.almacen['cita_vehiculo'], 'Aveo 2021');
        expect(c.almacen['cita_hay'], isTrue);
      },
    );

    test('sin cita invita a agendar y no lleva datos de una cita', () {
      final c = ContenidoWidget.proximaCitaVacia(
        titulo: 'Próxima cita',
        mensaje: 'No tienes citas próximas',
        accion: 'Agendar',
      );
      expect(c.hayDatos, isFalse);
      expect(c.enlace, 'carecar://citas/agendar');
      expect(c.almacen['cita_hay'], isFalse);
      expect(c.almacen.containsKey('cita_dia'), isFalse);
      expect(c.almacen['cita_accion'], 'Agendar');
    });
  });

  group('taller', () {
    test('trae etapa, paso, total y enlace a la orden', () {
      final c = ContenidoWidget.taller(
        titulo: 'Taller en vivo',
        etapa: 'En reparación',
        paso: 4,
        total: 7,
        pasoTexto: 'Paso 4 de 7',
        entrega: 'Entrega estimada: 24 nov, 18:00',
        vehiculo: 'Nissan March 2026',
        descripcion: 'Taller en vivo, en reparación',
        ordenId: 41,
      );
      expect(c.enlace, 'carecar://taller/41');
      expect(c.almacen['taller_paso'], 4);
      expect(c.almacen['taller_total'], 7);
      expect(c.almacen['taller_entrega'], contains('18:00'));
    });

    test('sin entrega estimada no publica la clave', () {
      final c = ContenidoWidget.taller(
        titulo: 't',
        etapa: 'e',
        paso: 1,
        total: 7,
        pasoTexto: 'Paso 1 de 7',
        vehiculo: 'v',
        descripcion: 'd',
        ordenId: 1,
      );
      expect(c.almacen.containsKey('taller_entrega'), isFalse);
    });

    test('vacio abre agendar', () {
      final c = ContenidoWidget.tallerVacio(
        titulo: 't',
        mensaje: 'm',
        accion: 'Agendar',
      );
      expect(c.hayDatos, isFalse);
      expect(c.enlace, 'carecar://citas/agendar');
    });
  });

  group('mantenimiento', () {
    test('trae progreso, faltante y enlace al plan del vehiculo', () {
      final c = ContenidoWidget.mantenimiento(
        titulo: 'Mantenimiento',
        servicio: 'Servicio de 20,000 km',
        faltan: 'Faltan 2,300 km',
        fecha: 'Hacia el 15 ene',
        progreso: 77,
        urgente: false,
        vehiculo: 'Aveo 2021',
        descripcion: 'd',
        vehiculoId: 7,
      );
      expect(c.enlace, 'carecar://mantenimiento/7');
      expect(c.almacen['mant_progreso'], 77);
      expect(c.almacen['mant_urgente'], isFalse);
    });

    test('vacio abre el garaje para elegir un auto', () {
      final c = ContenidoWidget.mantenimientoVacio(
        titulo: 't',
        mensaje: 'm',
        accion: 'Ver plan',
      );
      expect(c.hayDatos, isFalse);
      expect(c.enlace, 'carecar://garaje');
    });
  });

  group('bitacora', () {
    test('trae rendimiento, gasto y enlace a la bitacora del vehiculo', () {
      final c = ContenidoWidget.bitacora(
        titulo: 'Bitácora',
        rendimiento: '12.4',
        unidad: 'km/l',
        etiquetaRendimiento: 'Rendimiento',
        gasto: r'$1,250',
        etiquetaGasto: 'Gasto de noviembre',
        vehiculo: 'Aveo 2021',
        descripcion: 'd',
        vehiculoId: 7,
      );
      expect(c.enlace, 'carecar://bitacora/7');
      expect(c.almacen['bit_rendimiento'], '12.4');
      expect(c.almacen['bit_gasto'], r'$1,250');
    });

    test('sin rendimiento calculado publica una raya', () {
      final c = ContenidoWidget.bitacora(
        titulo: 'Bitácora',
        unidad: 'km/l',
        etiquetaRendimiento: 'Rendimiento',
        gasto: r'$0',
        etiquetaGasto: 'Gasto',
        descripcion: 'd',
        vehiculoId: 7,
      );
      expect(c.almacen['bit_rendimiento'], '—');
    });

    test('vacio abre el garaje', () {
      final c = ContenidoWidget.bitacoraVacia(
        titulo: 't',
        mensaje: 'm',
        accion: 'Registrar',
      );
      expect(c.hayDatos, isFalse);
      expect(c.enlace, 'carecar://garaje');
    });
  });

  group('accesos', () {
    test('lleva los cuatro textos y los cuatro enlaces', () {
      final c = ContenidoWidget.accesos(
        titulo: 'Accesos rápidos',
        agendar: 'Agendar',
        miAuto: 'Mi auto',
        sos: 'SOS',
        comprobante: 'Comprobante',
        enlaceComprobante: 'carecar://citas/7/comprobante',
        enlaceSos: 'carecar://asistencia/pedir',
      );
      expect(c.almacen['acc_enlace_agendar'], 'carecar://citas/agendar');
      expect(c.almacen['acc_enlace_mi_auto'], 'carecar://garaje');
      expect(c.almacen['acc_enlace_sos'], 'carecar://asistencia/pedir');
      expect(
        c.almacen['acc_enlace_comprobante'],
        'carecar://citas/7/comprobante',
      );
      expect(c.almacen['acc_comprobante'], 'Comprobante');
    });
  });

  test('dos contenidos con los mismos datos son iguales', () {
    ContenidoWidget uno() => ContenidoWidget.proximaCitaVacia(
      titulo: 't',
      mensaje: 'm',
      accion: 'a',
    );
    expect(uno(), uno());
    expect(uno().hashCode, uno().hashCode);
  });

  test('ningun contenido lleva datos personales fuera de lo que se pinta', () {
    final c = ContenidoWidget.taller(
      titulo: 't',
      etapa: 'e',
      paso: 1,
      total: 7,
      pasoTexto: 'Paso 1 de 7',
      vehiculo: 'v',
      descripcion: 'd',
      ordenId: 1,
    );
    final claves = c.almacen.keys.join(',');
    for (final prohibida in ['asesor', 'monto', 'placas', 'vin', 'correo']) {
      expect(claves, isNot(contains(prohibida)));
    }
  });
}
