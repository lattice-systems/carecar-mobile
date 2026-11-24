import 'package:carecar_mobile/modulos/acceso/dominio/reglas_contrasena.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M01.03 · «reglas en vivo» y «no acepta la temporal como nueva».
///
/// Dart puro: el dominio no importa Flutter.
///
/// Las reglas son las que **de verdad corre el backend**
/// (`ReglasContrasena.java` de `agencia-360-backend`): de 8 a 72 caracteres,
/// al menos una letra y un numero. **No pide mayuscula**, aunque el criterio
/// de la historia la mencionaba: no esta en la ficha v2.1, no esta en ninguno
/// de los dos contratos y no esta en el backend. Confirmado con el equipo.
///
/// Devuelve **una respuesta por regla** y no un booleano suelto, porque la
/// pantalla tiene que irlas marcando mientras la persona escribe: con un solo
/// «no cumple» no se sabria cual falta.
void main() {
  const actual = 'Temporal123';

  group('el largo', () {
    test('menos de 8 no alcanza', () {
      final r = ReglasContrasena.revisar('Care123', actual: actual);
      expect(r.largoSuficiente, isFalse);
      expect(r.cumpleTodo, isFalse);
    });

    test('exactamente 8 alcanza', () {
      final r = ReglasContrasena.revisar('Care1234', actual: actual);
      expect(r.largoSuficiente, isTrue);
      expect(r.cumpleTodo, isTrue);
    });

    test('mas de 72 no pasa: es el limite de BCrypt en el servidor', () {
      final larga = 'a1${'x' * 71}';
      expect(larga.length, 73);
      final r = ReglasContrasena.revisar(larga, actual: actual);
      expect(r.largoSuficiente, isFalse);
    });

    test('exactamente 72 pasa', () {
      final r = ReglasContrasena.revisar('a1${'x' * 70}', actual: actual);
      expect(r.largoSuficiente, isTrue);
      expect(r.cumpleTodo, isTrue);
    });
  });

  group('la composicion', () {
    test('sin letra no cumple', () {
      final r = ReglasContrasena.revisar('12345678', actual: actual);
      expect(r.tieneLetra, isFalse);
      expect(r.tieneNumero, isTrue);
      expect(r.cumpleTodo, isFalse);
    });

    test('sin numero no cumple', () {
      final r = ReglasContrasena.revisar('carecarcar', actual: actual);
      expect(r.tieneLetra, isTrue);
      expect(r.tieneNumero, isFalse);
      expect(r.cumpleTodo, isFalse);
    });

    test('minusculas con numero bastan: no se pide mayuscula', () {
      // Es la regla que corre en el backend. Pedir mayuscula aqui rechazaria
      // una contrasena que el servidor acepta.
      final r = ReglasContrasena.revisar('carecar2026', actual: actual);
      expect(r.cumpleTodo, isTrue);
    });

    test('acentos y enes cuentan como letra', () {
      final r = ReglasContrasena.revisar('mañana2026', actual: actual);
      expect(r.tieneLetra, isTrue);
      expect(r.cumpleTodo, isTrue);
    });

    test('un simbolo no sustituye a la letra', () {
      final r = ReglasContrasena.revisar('1234567!', actual: actual);
      expect(r.tieneLetra, isFalse);
      expect(r.cumpleTodo, isFalse);
    });
  });

  group('distinta de la actual', () {
    test('la misma temporal no se acepta', () {
      final r = ReglasContrasena.revisar(actual, actual: actual);
      // Cumple largo y composicion, y aun asi no sirve.
      expect(r.largoSuficiente, isTrue);
      expect(r.tieneLetra, isTrue);
      expect(r.tieneNumero, isTrue);
      expect(r.esDistintaDeLaActual, isFalse);
      expect(r.cumpleTodo, isFalse);
    });

    test('se compara tal cual, sin ignorar mayusculas', () {
      // «temporal123» y «Temporal123» son contrasenas distintas para el
      // servidor, asi que aqui tambien.
      final r = ReglasContrasena.revisar('temporal123', actual: actual);
      expect(r.esDistintaDeLaActual, isTrue);
      expect(r.cumpleTodo, isTrue);
    });

    test('sin saber la actual, la regla no estorba', () {
      // En la recuperacion por enlace no se conoce la contrasena anterior.
      final r = ReglasContrasena.revisar('carecar2026');
      expect(r.esDistintaDeLaActual, isTrue);
      expect(r.cumpleTodo, isTrue);
    });
  });

  group('en vivo', () {
    test('vacia: ninguna regla cumplida, y no es un error todavia', () {
      final r = ReglasContrasena.revisar('', actual: actual);
      expect(r.largoSuficiente, isFalse);
      expect(r.tieneLetra, isFalse);
      expect(r.tieneNumero, isFalse);
      expect(r.cumpleTodo, isFalse);
      // Al abrir la pantalla no se le reclama nada a quien no ha escrito.
      expect(r.estaVacia, isTrue);
    });

    test('las reglas se cumplen de una en una mientras se escribe', () {
      final paso1 = ReglasContrasena.revisar('c', actual: actual);
      expect(paso1.tieneLetra, isTrue);
      expect(paso1.tieneNumero, isFalse);
      expect(paso1.largoSuficiente, isFalse);

      final paso2 = ReglasContrasena.revisar('carecar2', actual: actual);
      expect(paso2.tieneLetra, isTrue);
      expect(paso2.tieneNumero, isTrue);
      expect(paso2.largoSuficiente, isTrue);
      expect(paso2.cumpleTodo, isTrue);
    });
  });
}
