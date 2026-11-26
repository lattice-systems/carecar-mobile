import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/lealtad.dart';
import 'esqueleto_lealtad.dart';
import 'formato_lealtad.dart';
import 'proveedores_lealtad.dart';
import 'rutas_lealtad.dart';

/// Mis puntos (V2-M12.01): el saldo, el nivel con su barra hacia el
/// siguiente (en Oro dice que ya esta en el maximo) y los accesos a
/// recompensas, canjes, movimientos y referir. Un cliente nuevo ve 0 puntos en
/// Bronce. Se actualiza sola con el aviso `puntos.movidos` (V2-M12.02).
/// Resuelve esqueleto, datos, error y sin conexion; se recarga jalando hacia
/// abajo.
class PantallaLealtad extends ConsumerWidget {
  const PantallaLealtad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.lealtadTitulo;

    return ref
        .watch(resumenLealtadProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EsqueletoLealtad(
              altos: const [140, 240],
              etiqueta: textos.lealtadCargando,
            ),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.lealtadReintentar,
              alReintentar: () => ref.invalidate(resumenLealtadProvider),
            ),
          ),
          data: (resumen) => MarcoPantalla(
            titulo: titulo,
            subtitulo: textos.lealtadSubtitulo,
            conRegreso: true,
            alRefrescar: () => ref.refresh(resumenLealtadProvider.future),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
                sliver: SliverList.list(
                  children: [
                    const SizedBox(height: Espaciado.e2),
                    TarjetaPuntos(resumen: resumen),
                    const SizedBox(height: Espaciado.e6),
                    const _Accesos(),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}

/// El saldo y el nivel como tarjeta de resumen, con la barra de lo ganado en
/// 12 meses contra el siguiente nivel. El lector la oye como un solo nodo:
/// saldo, nivel, lo que falta y el avance.
class TarjetaPuntos extends StatelessWidget {
  const TarjetaPuntos({required this.resumen, super.key});

  final ResumenLealtad resumen;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final nivel = textoNivel(textos, resumen.nivel);
    final siguiente = resumen.siguienteNivel;
    return TarjetaResumen(
      titulo: textos.lealtadPuntos(puntosLealtad(context, resumen.saldo)),
      subtitulo: textos.lealtadNivel(nivel),
      detalle: siguiente == null
          ? textos.lealtadNivelMaximo
          : textos.lealtadFaltan(
              puntosLealtad(context, resumen.puntosParaSiguiente),
              textoNivel(textos, siguiente),
            ),
      icono: LucideIcons300.award,
      tono: tonoNivel(resumen.nivel),
      estado: nivel,
      tonoEstado: tonoNivel(resumen.nivel),
      progreso: resumen.avance,
      etiquetaProgreso: textos.lealtadGanados(
        puntosLealtad(context, resumen.ganados),
      ),
    );
  }
}

class _Accesos extends StatelessWidget {
  const _Accesos();

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    return GrupoLista(
      filas: [
        FilaGrupo(
          titulo: textos.lealtadRecompensas,
          subtitulo: textos.lealtadRecompensasResumen,
          icono: LucideIcons300.gift,
          colorIcono: c.marca,
          alToque: () => context.push(rutaRecompensas),
        ),
        FilaGrupo(
          titulo: textos.lealtadCanjes,
          subtitulo: textos.lealtadCanjesResumen,
          icono: LucideIcons300.qrCode,
          colorIcono: c.exito,
          alToque: () => context.push(rutaCanjes),
        ),
        FilaGrupo(
          titulo: textos.lealtadMovimientos,
          subtitulo: textos.lealtadMovimientosResumen,
          icono: LucideIcons300.receiptText,
          colorIcono: c.acento,
          alToque: () => context.push(rutaMovimientos),
        ),
        FilaGrupo(
          titulo: textos.lealtadReferir,
          subtitulo: textos.lealtadReferirResumen,
          icono: LucideIcons300.userPlus,
          colorIcono: c.advertencia,
          alToque: () => context.push(rutaReferir),
        ),
      ],
    );
  }
}
