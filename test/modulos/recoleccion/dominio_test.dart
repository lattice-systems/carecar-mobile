import 'package:carecar_mobile/modulos/recoleccion/dominio/cotizacion_recoleccion.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/direccion_guardada.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/recoleccion_agendada.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter_test/flutter_test.dart';

BorradorDireccion _borrador({
  String alias = 'Casa',
  String calle = 'Av. Reforma 100',
  String colonia = 'Juárez',
  String cp = '06600',
  String ciudad = 'Ciudad de México',
  Coordenada? ubicacion = const Coordenada(19.4326, -99.1332),
}) => BorradorDireccion(
  alias: alias,
  calle: calle,
  colonia: colonia,
  cp: cp,
  ciudad: ciudad,
  ubicacion: ubicacion,
);

final _fecha = DateTime(2026, 11, 26);

void main() {
  group('BorradorDireccion.camposInvalidos', () {
    test('un borrador completo no tiene campos inválidos', () {
      expect(_borrador().camposInvalidos, isEmpty);
    });

    test('marca los campos vacíos tras recortar espacios', () {
      final malos = _borrador(
        alias: '  ',
        calle: '',
        colonia: ' ',
        ciudad: '',
      ).camposInvalidos;
      expect(
        malos,
        containsAll([
          CampoDireccion.alias,
          CampoDireccion.calle,
          CampoDireccion.colonia,
          CampoDireccion.ciudad,
        ]),
      );
    });

    test('el código postal son exactamente cinco dígitos', () {
      expect(_borrador(cp: '0660').camposInvalidos, [CampoDireccion.cp]);
      expect(_borrador(cp: '066001').camposInvalidos, [CampoDireccion.cp]);
      expect(_borrador(cp: '0660a').camposInvalidos, [CampoDireccion.cp]);
    });

    test('respeta los largos máximos del contrato', () {
      expect(_borrador(alias: 'a' * 41).camposInvalidos, [
        CampoDireccion.alias,
      ]);
      expect(_borrador(calle: 'a' * 121).camposInvalidos, [
        CampoDireccion.calle,
      ]);
      expect(_borrador(colonia: 'a' * 81).camposInvalidos, [
        CampoDireccion.colonia,
      ]);
      expect(_borrador(ciudad: 'a' * 81).camposInvalidos, [
        CampoDireccion.ciudad,
      ]);
      expect(_borrador(alias: 'a' * 40).camposInvalidos, isEmpty);
    });

    test('sin pin en el mapa la ubicación es obligatoria', () {
      expect(_borrador(ubicacion: null).camposInvalidos, [
        CampoDireccion.ubicacion,
      ]);
    });
  });

  group('DireccionGuardada', () {
    test('el resumen junta calle, colonia, código postal y ciudad', () {
      const d = DireccionGuardada(
        id: 1,
        alias: 'Casa',
        calle: 'Av. Reforma 100',
        colonia: 'Juárez',
        cp: '06600',
        ciudad: 'CDMX',
        ubicacion: Coordenada(19.4, -99.1),
      );
      expect(d.resumen, 'Av. Reforma 100, Juárez, 06600 CDMX');
    });
  });

  group('CotizacionRecoleccion', () {
    test('guarda costos y ventanas tal como llegan', () {
      final c = CotizacionRecoleccion(
        direccionId: 3,
        fecha: _fecha,
        costoPorTraslado: 150,
        costoTotal: 300,
        recoleccion: const VentanaHoraria(inicio: '07:00', fin: '09:00'),
        entrega: const VentanaHoraria(inicio: '17:00', fin: '19:00'),
      );
      expect(c.costoTotal, 2 * c.costoPorTraslado);
      expect(c.recoleccion.fin, '09:00');
    });
  });

  group('RecoleccionAgendada', () {
    test('ubica el traslado de recoger y el de entregar', () {
      final r = RecoleccionAgendada(
        direccionId: 3,
        costoTotal: 300,
        traslados: [
          TrasladoAgendado(
            id: 1,
            tipo: TipoTraslado.recoger,
            costo: 150,
            fecha: _fecha,
            ventanaInicio: '07:00',
            ventanaFin: '09:00',
          ),
          TrasladoAgendado(
            id: 2,
            tipo: TipoTraslado.entregar,
            costo: 150,
            fecha: _fecha,
            ventanaInicio: '17:00',
            ventanaFin: '19:00',
          ),
        ],
      );
      expect(r.recoger!.ventanaInicio, '07:00');
      expect(r.entregar!.ventanaFin, '19:00');
    });
  });
}
