import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/bitacora/bitacora.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/modulos/widgets/dominio/contenido_widgets.dart';
import 'package:carecar_mobile/modulos/widgets/presentacion/constructores_de_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CitaCliente _cita({int id = 7, String? vehiculo = 'Aveo 2021'}) => CitaCliente(
  id: id,
  vehiculoId: 1,
  fecha: DateTime(2026, 11, 24),
  horaInicio: '09:00',
  horaFin: '10:00',
  estado: EstadoDeCita.confirmada,
  vehiculoNombre: vehiculo,
);

OrdenEnCurso _orden({
  EtapaTaller etapa = EtapaTaller.enReparacion,
  DateTime? entrega,
}) => OrdenEnCurso(
  id: 41,
  vehiculoId: 1,
  vehiculo: 'Nissan March 2026',
  etapa: etapa,
  avance: 50,
  adicionalesPendientes: 0,
  entregaEstimada: entrega,
  asesor: 'Laura Méndez',
);

const _auto = VehiculoGaraje(
  id: 1,
  modelo: 'Aveo',
  anio: 2021,
  marca: 'Chevrolet',
);

ServicioMantenimiento _servicio(int id, int km) => ServicioMantenimiento(
  id: id,
  nombre: 'Servicio de $km km',
  km: km,
  meses: 6,
  precioEstimado: 1000,
  conceptos: const [],
  estado: EstadoServicio.pendiente,
);

PlanMantenimiento _plan({int faltanKm = 2500, int faltanDias = 90}) =>
    PlanMantenimiento(
      vehiculoId: 1,
      kmActual: 17500,
      servicios: [
        _servicio(1, 10000),
        _servicio(2, 20000),
        _servicio(3, 30000),
      ],
      proximo: ProximoServicio(
        servicioId: 2,
        nombre: 'Servicio de 20000 km',
        kmObjetivo: 20000,
        fechaEstimada: DateTime(2027, 1, 15),
        faltanKm: faltanKm,
        faltanDias: faltanDias,
        motivo: MotivoProximo.km,
      ),
    );

Gasto _carga(int id, DateTime fecha, int km, double litros, double monto) =>
    Gasto(
      id: id,
      vehiculoId: 1,
      tipo: TipoGasto.gasolina,
      monto: monto,
      fecha: fecha,
      litros: litros,
      km: km,
    );

void main() {
  late AppLocalizations es;
  late AppLocalizations en;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    es = await AppLocalizations.delegate.load(const Locale('es'));
    en = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('proxima cita', () {
    test('muestra dia grande, mes, horario y vehiculo', () {
      final c = contenidoDeCita(es, _cita());
      expect(c.hayDatos, isTrue);
      expect(c.datos['dia'], '24');
      expect(c.datos['mes'], 'NOV');
      expect(c.datos['horario'], '09:00 a 10:00');
      expect(c.datos['vehiculo'], 'Aveo 2021');
      expect(c.enlace, 'carecar://citas/7/comprobante');
      expect(c.datos['descripcion'], contains('Próxima cita'));
    });

    test('sin nombre de vehiculo no publica la clave', () {
      final c = contenidoDeCita(es, _cita(vehiculo: null));
      expect(c.datos.containsKey('vehiculo'), isFalse);
    });

    test('en ingles usa el idioma de la app', () {
      final c = contenidoDeCita(en, _cita());
      expect(c.datos['titulo'], 'Next appointment');
      expect(c.datos['horario'], '09:00 to 10:00');
    });

    test('sin cita invita a agendar', () {
      final c = contenidoDeCita(es, null);
      expect(c.hayDatos, isFalse);
      expect(c.datos['mensaje'], 'No tienes citas próximas');
      expect(c.datos['accion'], 'Agendar');
    });
  });

  group('taller', () {
    test('en reparacion es el paso 4 de 7 con entrega estimada', () {
      final c = contenidoDeTaller(
        es,
        _orden(entrega: DateTime(2026, 11, 24, 18)),
      );
      expect(c.datos['etapa'], 'En reparación');
      expect(c.datos['paso'], 4);
      expect(c.datos['total'], 7);
      expect(c.datos['paso_texto'], 'Paso 4 de 7');
      expect(c.datos['entrega'], contains('18:00'));
      expect(c.datos['vehiculo'], 'Nissan March 2026');
      expect(c.enlace, 'carecar://taller/41');
    });

    test('sin hora estimada no hay entrega', () {
      final c = contenidoDeTaller(es, _orden());
      expect(c.datos.containsKey('entrega'), isFalse);
    });

    test('listo para entrega llena la barra y entregado no pasa del total', () {
      expect(
        contenidoDeTaller(
          es,
          _orden(etapa: EtapaTaller.listoParaEntrega),
        ).datos['paso'],
        7,
      );
      expect(
        contenidoDeTaller(
          es,
          _orden(etapa: EtapaTaller.entregado),
        ).datos['paso'],
        7,
      );
    });

    test('no lleva al asesor', () {
      final c = contenidoDeTaller(es, _orden());
      expect(c.datos.values.join('|'), isNot(contains('Laura')));
    });

    test('sin orden muestra un estado vacio con Agendar', () {
      final c = contenidoDeTaller(es, null);
      expect(c.hayDatos, isFalse);
      expect(c.datos['accion'], 'Agendar');
      expect(c.enlace, 'carecar://citas/agendar');
    });
  });

  group('mantenimiento', () {
    test(
      'muestra servicio, km faltantes, fecha y progreso entre servicios',
      () {
        final c = contenidoDeMantenimiento(es, _plan(), _auto);
        expect(c.datos['servicio'], 'Servicio de 20000 km');
        expect(c.datos['faltan'], 'Faltan 2,500 km');
        expect(c.datos['fecha'], 'Hacia el 15 ene');
        // De 10,000 a 20,000: faltan 2,500, va en 75 %.
        expect(c.datos['progreso'], 75);
        expect(c.datos['urgente'], isFalse);
        expect(c.enlace, 'carecar://mantenimiento/1');
      },
    );

    test('cuando ya toca queda lleno y urgente', () {
      final c = contenidoDeMantenimiento(
        es,
        _plan(faltanKm: -100, faltanDias: 10),
        _auto,
      );
      expect(c.datos['faltan'], 'Ya toca');
      expect(c.datos['progreso'], 100);
      expect(c.datos['urgente'], isTrue);
    });

    test('sin plan, sin proximo o sin vehiculo es estado vacio', () {
      expect(contenidoDeMantenimiento(es, null, _auto).hayDatos, isFalse);
      expect(contenidoDeMantenimiento(es, _plan(), null).hayDatos, isFalse);
      const sinProximo = PlanMantenimiento(vehiculoId: 1, servicios: []);
      expect(contenidoDeMantenimiento(es, sinProximo, _auto).hayDatos, isFalse);
    });
  });

  group('bitacora', () {
    final ahora = DateTime(2026, 11, 24);
    final gastos = [
      _carga(1, DateTime(2026, 11, 2), 1000, 30, 700),
      _carga(2, DateTime(2026, 11, 20), 1360, 30, 750),
    ];

    test('muestra km/l y el gasto del mes en cifras', () {
      final c = contenidoDeBitacora(es, gastos, _auto, ahora);
      // 360 km con 30 litros: 12.0 km/l.
      expect(c.datos['rendimiento'], '12.0');
      expect(c.datos['unidad'], 'km/l');
      expect(c.datos['gasto'], r'$1,450');
      expect(c.datos['etiqueta_gasto'], 'Gasto de noviembre');
      expect(c.enlace, 'carecar://bitacora/1');
    });

    test('con una sola carga el rendimiento es una raya', () {
      final c = contenidoDeBitacora(es, [gastos.first], _auto, ahora);
      expect(c.datos['rendimiento'], '—');
    });

    test('sin gastos o sin vehiculo es estado vacio', () {
      expect(contenidoDeBitacora(es, const [], _auto, ahora).hayDatos, isFalse);
      expect(contenidoDeBitacora(es, null, _auto, ahora).hayDatos, isFalse);
      expect(contenidoDeBitacora(es, gastos, null, ahora).hayDatos, isFalse);
    });
  });

  group('accesos', () {
    test('el comprobante abre el de la proxima cita', () {
      final c = contenidoDeAccesos(es, _cita());
      expect(c.datos['comprobante'], 'Comprobante');
      expect(c.datos['enlace_comprobante'], 'carecar://citas/7/comprobante');
      expect(c.datos['enlace_agendar'], 'carecar://citas/agendar');
    });

    test('sin cita el comprobante abre la lista de citas', () {
      final c = contenidoDeAccesos(es, null);
      expect(c.datos['enlace_comprobante'], 'carecar://citas');
      expect(c.tipo, TipoWidget.accesos);
    });
  });
}
