import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../widgets/pagina_carecar.dart';
import '../widgets/pantalla.dart';
import 'perfil/pantalla_perfil.dart';

/// Ajustes: el perfil del cliente, su cuenta, ayuda y cerrar sesion.
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });
  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: 'Ajustes',
    anchoMaximo: Pantalla.anchoLectura,
    expandir: true,
    alCerrarSesion: alCerrarSesion,
    contenido: PantallaPerfil(
      api: api,
      alCerrarSesion: () async => alCerrarSesion(),
    ),
  );
}
