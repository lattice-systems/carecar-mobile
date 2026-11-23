import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../nucleo/diseno/tema_pista.dart';
import '../nucleo/idioma/selector_idioma.dart';
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
    contenido: Column(
      children: [
        // PROVISIONAL: el selector pasa a la pantalla de Ajustes v2 cuando
        // V2-T02.08 retire esta. La v1 aun no usa el tema Pista, asi que el
        // selector lo trae puesto.
        Theme(
          data: TemaPista.claro(),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SelectorIdioma(),
          ),
        ),
        Expanded(
          child: PantallaPerfil(
            api: api,
            alCerrarSesion: () async => alCerrarSesion(),
          ),
        ),
      ],
    ),
  );
}
