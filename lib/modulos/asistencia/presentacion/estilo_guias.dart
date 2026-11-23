import 'package:flutter/material.dart';

import '../../../nucleo/diseno/tokens/colores.dart';
import '../dominio/guia_emergencia.dart';

/// Ícono y color del sistema de cada guía, compartidos por la lista y la
/// pantalla de pasos para que una guía se reconozca de un vistazo.
extension EstiloDeGuia on TipoGuia {
  IconData get icono => switch (this) {
    TipoGuia.llanta => Icons.tire_repair_outlined,
    TipoGuia.corriente => Icons.battery_charging_full_outlined,
    TipoGuia.choque => Icons.car_crash_outlined,
  };

  /// Color de la guía tomado de la paleta, nunca un valor suelto.
  Color color(PaletaColores c) => switch (this) {
    TipoGuia.llanta => c.acento,
    TipoGuia.corriente => c.advertencia,
    TipoGuia.choque => c.peligro,
  };
}
