import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/lealtad.dart';
import 'esqueleto_lealtad.dart';
import 'formato_lealtad.dart';
import 'proveedores_lealtad.dart';

/// Un canje (V2-M12.03): si esta vigente, su QR y su codigo para mostrarlos
/// en caja o en servicio; si ya se uso o vencio, lo dice (los puntos de uno
/// vencido regresaron). Abajo, el costo y las fechas. Lee el canje de «Mis
/// canjes», asi que se actualiza con ellos.
class PantallaCanje extends ConsumerWidget {
  const PantallaCanje({required this.canjeId, super.key});

  final int canjeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.canjesTitulo;

    return ref
        .watch(canjesProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EsqueletoLealtad(
              altos: const [280, 120],
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
              alReintentar: () => ref.invalidate(canjesProvider),
            ),
          ),
          data: (canjes) {
            final canje = canjes.where((c) => c.id == canjeId).firstOrNull;
            if (canje == null) {
              return MarcoPantalla.estado(
                titulo: titulo,
                conRegreso: true,
                estado: EstadoVacio(
                  titulo: textos.canjeNoEncontradoTitulo,
                  mensaje: textos.canjeNoEncontradoMensaje,
                  icono: LucideIcons300.qrCode,
                ),
              );
            }
            return MarcoPantalla(
              titulo: canje.recompensa,
              subtitulo: textoFechaCanje(context, canje),
              conRegreso: true,
              alRefrescar: () => ref.refresh(canjesProvider.future),
              slivers: [SliverToBoxAdapter(child: _Canje(canje: canje))],
            );
          },
        );
  }
}

class _Canje extends StatelessWidget {
  const _Canje({required this.canje});

  final Canje canje;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final vigente = canje.estado == EstadoCanje.vigente;
    final usadoEn = canje.usadoEn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e2,
            Espaciado.e4,
            Espaciado.e5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vigente) ...[
                _TarjetaQr(codigo: canje.codigo),
                const SizedBox(height: Espaciado.e4),
                // Alto de objetivo táctil: se mantiene presionado para copiar.
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: Espaciado.objetivoTactilMinimo,
                  ),
                  child: SelectableText(
                    canje.codigo,
                    textAlign: TextAlign.center,
                    style: tokens.tipografia.titulo1.copyWith(
                      color: c.texto,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: Espaciado.e4),
                Aviso(mensaje: textos.canjeMuestralo, tono: Tono.informacion),
              ] else
                Aviso(
                  mensaje: canje.estado == EstadoCanje.usado
                      ? textos.canjeYaUsado
                      : textos.canjeYaVencio,
                  tono: tonoEstadoCanje(canje.estado),
                ),
            ],
          ),
        ),
        GrupoLista(
          encabezado: textos.canjeDetalles,
          filas: [
            FilaGrupo(
              titulo: textos.canjesCodigo(canje.codigo),
              subtitulo: textoEstadoCanje(textos, canje.estado),
              icono: LucideIcons300.qrCode,
              colorIcono: c.exito,
            ),
            FilaGrupo(
              titulo: textos.canjeCosto,
              subtitulo: textos.recompensasCosto(
                puntosLealtad(context, canje.puntos),
              ),
              icono: LucideIcons300.award,
              colorIcono: c.marca,
            ),
            FilaGrupo(
              titulo: textos.canjeCanjeado,
              subtitulo: fechaLealtad(context, canje.creadoEn),
              icono: LucideIcons300.calendar,
              colorIcono: c.acento,
            ),
            if (usadoEn != null)
              FilaGrupo(
                titulo: textos.canjeUsadoEl,
                subtitulo: fechaLealtad(context, usadoEn),
                icono: LucideIcons300.circleCheckBig,
                colorIcono: c.exito,
              )
            else
              FilaGrupo(
                titulo: textos.canjeVigencia,
                subtitulo: fechaLealtad(context, canje.venceEn),
                icono: LucideIcons300.clock,
                colorIcono: c.advertencia,
              ),
          ],
        ),
      ],
    );
  }
}

/// El QR del codigo sobre su tarjeta blanca, centrado. Negro sobre blanco en
/// cualquier tema porque asi lo lee el escaner. Para el lector de pantalla es
/// una imagen con su descripcion.
class _TarjetaQr extends StatelessWidget {
  const _TarjetaQr({required this.codigo});

  final String codigo;

  static const double _lado = 220;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Center(
      child: Semantics(
        image: true,
        label: AppLocalizations.of(context).canjeQr(codigo),
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Radios.hoja),
            boxShadow: tokens.sombras,
          ),
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e5),
            child: QrImageView(
              key: ValueKey('qr-canje:$codigo'),
              data: codigo,
              size: _lado,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
