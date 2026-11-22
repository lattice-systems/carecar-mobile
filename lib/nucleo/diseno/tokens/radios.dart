import 'package:flutter/painting.dart';

/// Radios de esquina del sistema de diseno v2.
abstract final class Radios {
  static const double control = 10;
  static const double tarjeta = 16;
  static const double hoja = 28;
  static const double pildora = 999;

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
}
