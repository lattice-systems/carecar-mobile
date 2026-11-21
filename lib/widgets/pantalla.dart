import 'package:flutter/material.dart';

import '../tema/tema_carecar.dart';

/// Tamano de la ventana segun su ancho. Unico lugar con los cortes de
/// diseno: las pantallas preguntan aqui en vez de comparar numeros sueltos.
enum Pantalla {
  /// Telefono en vertical (menos de 600 px).
  compacto,

  /// Tablet vertical, plegable abierto o telefono en horizontal (600–1000).
  medio,

  /// Tablet horizontal o escritorio (1000 px o mas).
  amplio;

  static const corteMedio = 600.0;
  static const corteAmplio = 1000.0;

  /// Por debajo de esta altura (telefono en horizontal) el encabezado se
  /// reduce a una sola linea para no comerse la pantalla.
  static const altoBajo = 500.0;

  /// Ancho maximo del contenido de lectura (formularios, listas de una columna).
  static const anchoLectura = 720.0;

  static Pantalla deAncho(double ancho) => ancho < corteMedio
      ? compacto
      : ancho < corteAmplio
      ? medio
      : amplio;

  static Pantalla de(BuildContext context) =>
      deAncho(MediaQuery.sizeOf(context).width);

  /// Ventana baja, tipicamente un telefono en horizontal.
  static bool esBaja(BuildContext context) =>
      MediaQuery.sizeOf(context).height < altoBajo;

  /// Columnas para tarjetas cuando hay espacio para ellas.
  int get columnas => switch (this) {
    compacto => 1,
    medio => 2,
    amplio => 3,
  };
}

/// Centra el contenido y limita su ancho en pantallas amplias.
class AnchoLimitado extends StatelessWidget {
  const AnchoLimitado({
    required this.child,
    this.anchoMaximo = Pantalla.anchoLectura,
    super.key,
  });

  final Widget child;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: anchoMaximo),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

/// Reparte tarjetas en columnas del mismo ancho segun [Pantalla.deAncho] del
/// espacio disponible. Usa Wrap para que cada tarjeta crezca con texto grande
/// sin recortarse.
class RejillaAdaptable extends StatelessWidget {
  const RejillaAdaptable({
    required this.hijos,
    this.maxColumnas = 3,
    this.espacio = TemaCareCar.espacioCampos,
    super.key,
  });

  final List<Widget> hijos;
  final int maxColumnas;
  final double espacio;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, limites) {
      final columnas = Pantalla.deAncho(limites.maxWidth).columnas
          .clamp(1, maxColumnas);
      final ancho = (limites.maxWidth - espacio * (columnas - 1)) / columnas;
      return Wrap(
        spacing: espacio,
        runSpacing: espacio,
        children: [
          for (final hijo in hijos) SizedBox(width: ancho, child: hijo),
        ],
      );
    },
  );
}
