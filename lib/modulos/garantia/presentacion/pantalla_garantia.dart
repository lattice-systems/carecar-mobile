import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/garantia_vehiculo.dart';
import 'esqueleto_garantia.dart';
import 'formato_garantia.dart';
import 'proveedores_garantia.dart';
import 'rutas_garantia.dart';

/// La garantia del vehiculo (V2-M10.01): una tarjeta de resumen por cobertura
/// con su estado, hasta cuando cubre por fecha y km, una barra de lo usado y
/// lo que le queda contra el km actual. Al final, el acceso a las campanas de
/// seguridad. Se actualiza sola con el aviso de garantia por vencer
/// (V2-M10.05). Resuelve esqueleto, datos, vacio, error y sin conexion; se
/// recarga jalando hacia abajo.
class PantallaGarantia extends ConsumerWidget {
  const PantallaGarantia({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.garantiaTitulo;

    return ref
        .watch(garantiaProvider(vehiculoId))
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoGarantia(altos: [140, 140, 140]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.garantiaReintentar,
              alReintentar: () => ref.invalidate(garantiaProvider(vehiculoId)),
            ),
          ),
          data: (garantia) => garantia.coberturas.isEmpty
              ? MarcoPantalla.estado(
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: textos.garantiaVaciaTitulo,
                    mensaje: textos.garantiaVaciaMensaje,
                    icono: Icons.verified_user_outlined,
                  ),
                )
              : _Garantia(
                  garantia: garantia,
                  alRefrescar: () =>
                      ref.refresh(garantiaProvider(vehiculoId).future),
                ),
        );
  }
}

class _Garantia extends StatelessWidget {
  const _Garantia({required this.garantia, required this.alRefrescar});

  final GarantiaVehiculo garantia;
  final Future<void> Function() alRefrescar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final km = garantia.kmActual;

    return MarcoPantalla(
      titulo: textos.garantiaTitulo,
      subtitulo: km == null
          ? null
          : textos.garantiaKmActual(kmGarantia(context, km)),
      conRegreso: true,
      alRefrescar: alRefrescar,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: Espaciado.e2),
              for (final cobertura in garantia.coberturas) ...[
                TarjetaCobertura(cobertura: cobertura),
                const SizedBox(height: Espaciado.e3),
              ],
              const SizedBox(height: Espaciado.e3),
              GrupoLista(
                filas: [
                  FilaGrupo(
                    titulo: textos.campanasAcceso,
                    subtitulo: textos.campanasAccesoResumen,
                    icono: Icons.campaign_outlined,
                    colorIcono: c.advertencia,
                    alToque: () =>
                        context.push(rutaCampanasVehiculo(garantia.vehiculoId)),
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

/// Una cobertura como tarjeta de resumen: componente, limite, descripcion,
/// estado y la barra de lo usado con lo que le queda. El lector de pantalla
/// la oye como un solo nodo con el porcentaje usado.
class TarjetaCobertura extends StatelessWidget {
  const TarjetaCobertura({required this.cobertura, super.key});

  final CoberturaGarantia cobertura;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tono = tonoCobertura(cobertura.estado);
    return TarjetaResumen(
      titulo: cobertura.componente,
      subtitulo: textoLimiteCobertura(context, cobertura),
      detalle: cobertura.descripcion,
      icono: switch (cobertura.estado) {
        EstadoCobertura.vigente => Icons.verified_user_outlined,
        EstadoCobertura.porVencer => Icons.schedule_outlined,
        EstadoCobertura.vencida => Icons.gpp_bad_outlined,
      },
      tono: tono,
      estado: textoEstadoCobertura(textos, cobertura.estado),
      tonoEstado: tono,
      progreso: cobertura.consumo / 100,
      etiquetaProgreso: textoRestante(context, cobertura),
    );
  }
}
