import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'boton.dart';
import 'centrado_desplazable.dart';

/// Causa de un [EstadoError]. Cambia el icono y el texto por defecto.
enum CausaError { generico, sinConexion }

/// Algo fallo al cargar. Explica que paso y ofrece reintentar.
///
/// Se anuncia solo al lector de pantalla cuando aparece. `sinConexion` usa
/// textos distintos para que la persona sepa que el problema no es suyo ni del
/// servidor. Los textos por omision salen del idioma de la app (con tilde y
/// traducidos); una pantalla solo los pasa si tiene algo mas que decir.
class EstadoError extends StatelessWidget {
  const EstadoError({
    required this.alReintentar,
    super.key,
    this.causa = CausaError.generico,
    this.titulo,
    this.mensaje,
    this.textoReintentar,
  });

  final VoidCallback? alReintentar;
  final CausaError causa;
  final String? titulo;
  final String? mensaje;
  final String? textoReintentar;

  static const double _tamanoIcono = 48;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final textos = AppLocalizations.of(context);
    final sinConexion = causa == CausaError.sinConexion;

    final tituloFinal =
        titulo ??
        (sinConexion
            ? textos.estadoErrorSinConexionTitulo
            : textos.estadoErrorTitulo);
    final mensajeFinal =
        mensaje ??
        (sinConexion
            ? textos.estadoErrorSinConexionMensaje
            : textos.estadoErrorMensaje);

    return Semantics(
      container: true,
      liveRegion: true,
      child: CentradoDesplazable(
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.e6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  sinConexion
                      ? LucideIcons300.wifiOff
                      : LucideIcons300.circleAlert,
                  size: _tamanoIcono,
                  color: sinConexion ? c.textoSecundario : c.peligro,
                ),
              ),
              const SizedBox(height: Espaciado.e4),
              Text(
                tituloFinal,
                textAlign: TextAlign.center,
                style: t.titulo3.copyWith(color: c.texto),
              ),
              const SizedBox(height: Espaciado.e2),
              Text(
                mensajeFinal,
                textAlign: TextAlign.center,
                style: t.cuerpo.copyWith(color: c.textoSecundario),
              ),
              const SizedBox(height: Espaciado.e5),
              Boton(
                texto: textoReintentar ?? textos.estadoErrorReintentar,
                icono: LucideIcons300.refreshCw,
                alPresionar: alReintentar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
