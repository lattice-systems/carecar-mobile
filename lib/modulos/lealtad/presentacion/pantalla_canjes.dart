import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/lealtad.dart';
import 'esqueleto_lealtad.dart';
import 'formato_lealtad.dart';
import 'proveedores_lealtad.dart';
import 'rutas_lealtad.dart';

/// Mis canjes (V2-M12.03): una tarjeta por canje, del mas nuevo, con la
/// recompensa, su codigo, su estado (vigente, usado o vencido) y la fecha que
/// importa; al tocarla abre el codigo con QR. Resuelve esqueleto, datos,
/// vacio, error y sin conexion; se recarga jalando hacia abajo.
class PantallaCanjes extends ConsumerWidget {
  const PantallaCanjes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.canjesTitulo;

    return ref
        .watch(canjesProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            icono: LucideIcons300.gift,
            titulo: titulo,
            conRegreso: true,
            estado: EsqueletoLealtad(
              altos: const [96, 96],
              etiqueta: textos.lealtadCargando,
            ),
          ),
          error: (error, _) => MarcoPantalla.estado(
            icono: LucideIcons300.gift,
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.lealtadReintentar,
              alReintentar: () => ref.invalidate(canjesProvider),
            ),
          ),
          data: (canjes) => canjes.isEmpty
              ? MarcoPantalla.estado(
                  icono: LucideIcons300.gift,
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: textos.canjesVaciaTitulo,
                    mensaje: textos.canjesVaciaMensaje,
                    icono: LucideIcons300.qrCode,
                    textoAccion: textos.canjesVerRecompensas,
                    alAccion: () => context.push(rutaRecompensas),
                  ),
                )
              : MarcoPantalla(
                  icono: LucideIcons300.gift,
                  titulo: titulo,
                  subtitulo: textos.lealtadCanjesResumen,
                  conRegreso: true,
                  alRefrescar: () => ref.refresh(canjesProvider.future),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Espaciado.e4,
                      ),
                      sliver: SliverList.list(
                        children: [
                          const SizedBox(height: Espaciado.e2),
                          for (final canje in canjes) ...[
                            TarjetaCanje(
                              canje: canje,
                              alToque: () => context.push(rutaCanje(canje.id)),
                            ),
                            const SizedBox(height: Espaciado.e3),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        );
  }
}

/// Un canje como tarjeta de resumen: recompensa, codigo, fecha y estado.
class TarjetaCanje extends StatelessWidget {
  const TarjetaCanje({required this.canje, super.key, this.alToque});

  final Canje canje;
  final VoidCallback? alToque;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tono = tonoEstadoCanje(canje.estado);
    return TarjetaResumen(
      titulo: canje.recompensa,
      subtitulo: textos.canjesCodigo(canje.codigo),
      detalle: textoFechaCanje(context, canje),
      icono: LucideIcons300.qrCode,
      tono: tono,
      estado: textoEstadoCanje(textos, canje.estado),
      tonoEstado: tono,
      alToque: alToque,
    );
  }
}
