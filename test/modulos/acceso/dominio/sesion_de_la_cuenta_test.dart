import 'package:carecar_mobile/modulos/acceso/dominio/sesion_de_la_cuenta.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M01.09 · la sesion tal como la lista la necesita.
///
/// El criterio pide «lista con dispositivo y ultimo uso», y ahi esta el filo:
/// **el ultimo uso puede no existir**. Una sesion que se acaba de abrir nunca
/// se ha refrescado, y una sesion anterior a esta historia no tiene ninguna de
/// las tres fechas. El tipo decide **que fecha** mostrar; el texto lo arma la
/// pantalla.
void main() {
  SesionDeLaCuenta sesion({DateTime? ultimoUso, DateTime? iniciadaEn}) =>
      SesionDeLaCuenta(
        id: 1,
        ultimoUso: ultimoUso,
        iniciadaEn: iniciadaEn,
        expiraEn: DateTime.utc(2026, 12, 24),
      );

  group('la fecha que la lista muestra', () {
    test('es el ultimo uso cuando lo hay', () {
      final s = sesion(
        ultimoUso: DateTime.utc(2026, 11, 24, 18),
        iniciadaEn: DateTime.utc(2026, 11, 1),
      );

      expect(s.ultimaSenal, DateTime.utc(2026, 11, 24, 18));
    });

    test('es el inicio si nunca se ha refrescado', () {
      // Pasa siempre en la sesion de este mismo celular recien abierta: decir
      // «sin actividad» de la sesion que el cliente esta usando se veria roto.
      final s = sesion(iniciadaEn: DateTime.utc(2026, 11, 1));

      expect(s.ultimaSenal, DateTime.utc(2026, 11, 1));
    });

    test('no hay fecha en las sesiones de antes de esta historia', () {
      // El backend no puede inventar cuando empezaron: esas filas no tenian
      // las columnas. La pantalla tiene que saber vivir sin fecha, no pintar
      // la epoca de Unix.
      expect(sesion().ultimaSenal, isNull);
    });
  });

  test('sin nombre de dispositivo no se inventa uno', () {
    // El nombre lo manda la app al entrar y puede faltar. Rellenarlo aqui con
    // «Dispositivo desconocido» mezclaria texto en el dominio y dejaria a la
    // pantalla sin saber si el nombre es real.
    expect(sesion().dispositivo, isNull);
  });
}
