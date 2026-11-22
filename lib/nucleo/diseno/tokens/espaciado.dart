/// Escala de espaciado del sistema de diseno v2, con base de 4.
abstract final class Espaciado {
  static const double e1 = 4;
  static const double e2 = 8;
  static const double e3 = 12;
  static const double e4 = 16;
  static const double e5 = 20;
  static const double e6 = 24;
  static const double e8 = 32;
  static const double e10 = 40;
  static const double e14 = 56;
  static const double e18 = 72;

  static const List<double> escala = [e1, e2, e3, e4, e5, e6, e8, e10, e14, e18];

  static const double margenTelefono = 16;
  static const double margenTableta = 24;
  static const double anchoMaximoContenido = 640;
  static const double objetivoTactilMinimo = 48;
}
