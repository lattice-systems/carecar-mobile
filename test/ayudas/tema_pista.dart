import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';

/// Los tres escenarios en los que todo componente del sistema v2 debe verse
/// bien: claro, oscuro y letra al 200 %.
enum Escenario { claro, oscuro, letraGrande }

/// Envuelve un widget con el tema Pista en el escenario pedido.
Widget conTemaPista(
  Widget hijo, {
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) {
  final oscuro = escenario == Escenario.oscuro;
  final escala = escenario == Escenario.letraGrande ? 2.0 : 1.0;
  return MaterialApp(
    theme: oscuro ? TemaPista.oscuro() : TemaPista.claro(),
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(ancho, 800),
        textScaler: TextScaler.linear(escala),
      ),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: ancho, child: hijo),
        ),
      ),
    ),
  );
}
