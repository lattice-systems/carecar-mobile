import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'rutas_privacidad.dart';

/// Privacidad y mis datos (V2-M22.02 y V2-M22.03): reúne el aviso de privacidad
/// y los derechos sobre los datos (descargarlos y eliminar la cuenta). Se abre
/// desde el perfil.
class PantallaPrivacidad extends StatelessWidget {
  const PantallaPrivacidad({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    return MarcoPantalla(
      titulo: textos.privacidadHubTitulo,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          sliver: SliverList.list(
            children: [
              GrupoLista(
                filas: [
                  FilaGrupo(
                    titulo: textos.privacidadHubAviso,
                    subtitulo: textos.privacidadHubAvisoDetalle,
                    icono: Icons.privacy_tip_outlined,
                    colorIcono: c.acento,
                    alToque: () => context.push(rutaAvisoPrivacidad),
                  ),
                  FilaGrupo(
                    titulo: textos.privacidadHubDatos,
                    subtitulo: textos.privacidadHubDatosDetalle,
                    icono: Icons.download_outlined,
                    colorIcono: c.acento,
                    alToque: () => context.push(rutaMisDatos),
                  ),
                ],
              ),
              const SizedBox(height: Espaciado.e5),
              // Aparte y en rojo: es lo único que no se puede deshacer.
              GrupoLista(
                filas: [
                  FilaGrupo(
                    titulo: textos.privacidadHubEliminar,
                    subtitulo: textos.privacidadHubEliminarDetalle,
                    icono: Icons.delete_outline,
                    colorIcono: c.peligro,
                    alToque: () => context.push(rutaEliminarCuenta),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
