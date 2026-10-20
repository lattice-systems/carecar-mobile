import 'package:flutter/material.dart';

/// Tema de CareCar, derivado de la guia de estilos de Agencia360.
///
/// La app comparte la identidad visual de Agencia360. La guia esta escrita para
/// React con Tailwind y shadcn/ui, asi que lo que se traslada son **los valores**
/// (paleta, escala tipografica, radios, espaciado), no las librerias.
///
/// **Pendiente:** las fuentes Inter y JetBrains Mono. La guia pide servirlas
/// desde la app y no desde Google Fonts, pero los archivos `.ttf` no vinieron
/// con la guia: es la peticion EQ-4. Mientras tanto se usa la fuente del
/// sistema; al llegar los archivos solo se agregan a `pubspec.yaml` y se nombran
/// aqui, sin tocar ninguna pantalla.
abstract final class TemaCareCar {
  // --- Paleta (guia de estilos, §2) ---

  /// Azul Agencia. Botones principales, encabezado, enlaces, foco.
  static const azulAgencia = Color(0xFF1D3557);

  /// Azul profundo. Hover del primario.
  static const azulProfundo = Color(0xFF142640);

  /// Azul suave. Seleccion y fondos suaves.
  static const azulSuave = Color(0xFFE8EDF4);

  /// Turquesa 360. Acento **solo sobre fondo oscuro**.
  ///
  /// Nunca es fondo de boton ni color de texto normal: la guia lo limita al
  /// 10 % de la interfaz.
  static const turquesa = Color(0xFF2EC4B6);

  /// Turquesa oscuro. Acento sobre fondo claro.
  ///
  /// Da 3.97:1 sobre blanco, asi que solo sirve para iconos, graficas o texto
  /// de 24 px o mas. No para texto normal.
  static const turquesaOscuro = Color(0xFF168F84);

  static const fondo = Color(0xFFF5F7FA);
  static const tarjeta = Color(0xFFFFFFFF);
  static const borde = Color(0xFFE2E7EE);
  static const bordeCampo = Color(0xFFCBD2DC);
  static const textoSecundario = Color(0xFF52606D);
  static const textoPrincipal = Color(0xFF1F2933);

  static const exito = Color(0xFF1B6E3A);
  static const exitoFondo = Color(0xFFEAF5EE);
  static const advertencia = Color(0xFF8A5A00);
  static const advertenciaFondo = Color(0xFFFDF6E3);
  static const peligro = Color(0xFFB42318);
  static const peligroFondo = Color(0xFFFDECEA);

  // --- Medidas (guia de estilos, §5 y §6) ---

  /// Separacion entre campos de un formulario.
  static const espacioCampos = 16.0;

  /// Separacion entre secciones.
  static const espacioSecciones = 24.0;

  /// Relleno de tarjeta en celular.
  static const rellenoTarjeta = 16.0;

  /// Radio de tarjetas y dialogos.
  static const radioTarjeta = 8.0;

  /// Radio de botones y campos.
  static const radioControl = 6.0;

  /// Alto minimo para tocar. La guia pide 40 px, y 44 donde se usa en
  /// movimiento: una app de cliente es justamente ese caso.
  static const altoMinimoToque = 44.0;

  /// Tamano de los campos de formulario.
  ///
  /// **Siempre 16.** Con menos, iOS hace zoom al enfocar el campo.
  static const tamanoCampo = 16.0;

  static ThemeData get claro {
    const esquema = ColorScheme.light(
      primary: azulAgencia,
      onPrimary: Colors.white,
      secondary: turquesaOscuro,
      onSecondary: Colors.white,
      surface: tarjeta,
      onSurface: textoPrincipal,
      error: peligro,
      onError: Colors.white,
      outline: bordeCampo,
      outlineVariant: borde,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,

      // Escala tipografica de la guia (§3). Pesos permitidos: 400, 500, 600, 700.
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          height: 36 / 30,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 32 / 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 28 / 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          height: 28 / 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tarjeta,
        border: _bordeCampo(bordeCampo),
        enabledBorder: _bordeCampo(bordeCampo),
        focusedBorder: _bordeCampo(azulAgencia, grosor: 2),
        errorBorder: _bordeCampo(peligro),
        focusedErrorBorder: _bordeCampo(peligro, grosor: 2),
        errorStyle: const TextStyle(color: peligro, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: azulAgencia,
          foregroundColor: Colors.white,
          disabledBackgroundColor: azulAgencia.withValues(alpha: 0.38),
          minimumSize: const Size.fromHeight(altoMinimoToque),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radioControl),
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: azulAgencia,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // La guia pide bordes y no sombras, salvo en tarjetas y dialogos.
      cardTheme: CardThemeData(
        color: tarjeta,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radioTarjeta),
          side: const BorderSide(color: borde),
        ),
      ),
    );
  }

  static OutlineInputBorder _bordeCampo(Color color, {double grosor = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radioControl),
        borderSide: BorderSide(color: color, width: grosor),
      );
}
