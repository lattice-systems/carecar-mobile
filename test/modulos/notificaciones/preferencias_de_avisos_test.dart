import 'package:carecar_mobile/modulos/notificaciones/dominio/aviso_cliente.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/preferencias_de_avisos.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M06.05 · elegir qué avisos recibir y un horario silencioso.
///
/// Lo que se decide aquí es la hora: el rango que **cruza la medianoche**
/// (22:00 a 07:00) es el caso normal, no un error, y es el que se equivoca
/// quien lo trata como un rango cualquiera.
void main() {
  group('la hora del día', () {
    test('se lee del contrato y se vuelve a escribir igual', () {
      final h = HoraDelDia.deTexto('22:00');
      expect(h, isNotNull);
      expect(h!.hora, 22);
      expect(h.minuto, 0);
      expect(h.aTexto(), '22:00');
    });

    test('siempre con dos dígitos, que es lo que el contrato exige', () {
      expect(const HoraDelDia(7, 5).aTexto(), '07:05');
      expect(const HoraDelDia(0, 0).aTexto(), '00:00');
    });

    test('lo que no es una hora es nulo, no una hora inventada', () {
      expect(HoraDelDia.deTexto('25:00'), isNull);
      expect(HoraDelDia.deTexto('22:60'), isNull);
      expect(HoraDelDia.deTexto('22'), isNull);
      expect(HoraDelDia.deTexto(''), isNull);
      expect(HoraDelDia.deTexto(null), isNull);
    });
  });

  group('el horario silencioso', () {
    test('un rango normal silencia lo de en medio', () {
      const silencio = HorarioSilencioso(
        desde: HoraDelDia(13, 0),
        hasta: HoraDelDia(15, 0),
      );

      expect(silencio.silencia(const HoraDelDia(14, 0)), isTrue);
      expect(silencio.silencia(const HoraDelDia(12, 59)), isFalse);
      expect(silencio.silencia(const HoraDelDia(15, 1)), isFalse);
    });

    test('un rango que cruza la medianoche es el caso normal', () {
      // 22:00 a 07:00 es lo que la gente de verdad configura. Tratarlo como un
      // rango cualquiera dejaría la noche entera SIN silencio.
      const noche = HorarioSilencioso(
        desde: HoraDelDia(22, 0),
        hasta: HoraDelDia(7, 0),
      );

      expect(noche.silencia(const HoraDelDia(23, 30)), isTrue);
      expect(noche.silencia(const HoraDelDia(3, 0)), isTrue);
      expect(noche.silencia(const HoraDelDia(6, 59)), isTrue);
      expect(noche.silencia(const HoraDelDia(7, 1)), isFalse);
      expect(noche.silencia(const HoraDelDia(12, 0)), isFalse);
    });

    test('los extremos cuentan como silencio', () {
      const noche = HorarioSilencioso(
        desde: HoraDelDia(22, 0),
        hasta: HoraDelDia(7, 0),
      );
      expect(noche.silencia(const HoraDelDia(22, 0)), isTrue);
      expect(noche.silencia(const HoraDelDia(7, 0)), isTrue);
    });

    test('desde igual a hasta no silencia nada', () {
      // Un rango de cero minutos. Lo contrario -silenciar el día entero- es
      // una sorpresa desagradable para quien eligió dos horas iguales.
      const nulo = HorarioSilencioso(
        desde: HoraDelDia(22, 0),
        hasta: HoraDelDia(22, 0),
      );
      expect(nulo.silencia(const HoraDelDia(22, 0)), isFalse);
      expect(nulo.silencia(const HoraDelDia(3, 0)), isFalse);
    });
  });

  group('las preferencias', () {
    test('sin horario, nada se silencia', () {
      const p = PreferenciasDeAvisos(porCategoria: {}, silencio: null);
      expect(p.haySilencio, isFalse);
    });

    test('cambiar una categoría no toca las demás', () {
      const p = PreferenciasDeAvisos(
        porCategoria: {
          CategoriaDeAviso.taller: true,
          CategoriaDeAviso.promociones: false,
        },
        silencio: null,
      );

      final nueva = p.con(CategoriaDeAviso.promociones, true);

      expect(nueva.porCategoria[CategoriaDeAviso.promociones], isTrue);
      expect(nueva.porCategoria[CategoriaDeAviso.taller], isTrue);
    });

    test('quitar el horario deja las categorías como estaban', () {
      const p = PreferenciasDeAvisos(
        porCategoria: {CategoriaDeAviso.citas: false},
        silencio: HorarioSilencioso(
          desde: HoraDelDia(22, 0),
          hasta: HoraDelDia(7, 0),
        ),
      );

      final sinSilencio = p.sinHorario();

      expect(sinSilencio.silencio, isNull);
      expect(sinSilencio.porCategoria[CategoriaDeAviso.citas], isFalse);
    });

    test('la categoría desconocida no se manda al servidor', () {
      // El contrato no la declara: existe solo para que una categoría nueva
      // del backend no tumbe la pantalla.
      const p = PreferenciasDeAvisos(
        porCategoria: {
          CategoriaDeAviso.taller: true,
          CategoriaDeAviso.desconocida: false,
        },
        silencio: null,
      );

      expect(p.paraGuardar().keys, [CategoriaDeAviso.taller]);
    });
  });
}
