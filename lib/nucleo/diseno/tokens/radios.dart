import 'package:flutter/painting.dart';

/// Radios de esquina del sistema de diseno v2.
abstract final class Radios {
  static const double control = 10;
  static const double tarjeta = 16;
  static const double hoja = 28;
  static const double pildora = 999;

  /// Campo de chat (V2-T02.16): la mitad de su alto de una linea, asi se ve
  /// pildora y al crecer a varias lineas queda como capsula sin cortar el
  /// texto en las esquinas.
  static const double campoChat = 24;

  static const BorderRadius bordeControl = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius bordeTarjeta = BorderRadius.all(
    Radius.circular(tarjeta),
  );
  static const BorderRadius bordeHoja = BorderRadius.vertical(
    top: Radius.circular(hoja),
  );
  static const BorderRadius bordePildora = BorderRadius.all(
    Radius.circular(pildora),
  );
  static const BorderRadius bordeCampoChat = BorderRadius.all(
    Radius.circular(campoChat),
  );
}
