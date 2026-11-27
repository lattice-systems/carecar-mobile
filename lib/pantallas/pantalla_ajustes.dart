import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../nucleo/diseno/tema_pista.dart';
import 'perfil/pantalla_perfil.dart';

/// Ajustes: el idioma, el perfil del cliente, su cuenta, ayuda y cerrar sesion.
///
/// Esta en el lenguaje del sistema de diseno v2 (V2-T02.24): el marco, las
/// listas y el selector de idioma son los de las demas pantallas. Lleva su
/// propio tema Pista (claro u oscuro segun el sistema) porque la v1 aun no
/// esta bajo el tema v2 global (V2-T01.05).
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });
  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) => Theme(
    data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro(),
    child: PantallaPerfil(
      api: api,
      alCerrarSesion: () async => alCerrarSesion(),
    ),
  );
}
