import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_auto.dart';
import '../../../nucleo/diseno/componentes/tinte_auto.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../garantia/garantia.dart';
import '../dominio/vehiculo_garaje.dart';
import 'proveedores_vehiculos.dart';
import 'rutas_vehiculos.dart';

/// Garaje del cliente (V2-M02.01): una tarjeta por auto con su modelo, placas
/// y kilometraje; tocarla abre el detalle.
///
/// Resuelve los cinco estados: cargando con esqueleto, datos, vacio, error con
/// reintento y sin conexion. Sin conexion la API del nucleo entrega la ultima
/// copia guardada, asi que solo se ve el error si nunca hubo datos. Se puede
/// recargar jalando hacia abajo.
class PantallaGaraje extends ConsumerWidget {
  const PantallaGaraje({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculos = ref.watch(garajeProvider);
    final textos = AppLocalizations.of(context);
    final titulo = textos.vehiculosTitulo;

    return vehiculos.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(garajeProvider),
        ),
      ),
      data: (lista) => lista.isEmpty
          ? MarcoPantalla.estado(
              titulo: titulo,
              conRegreso: true,
              estado: EstadoVacio(
                titulo: textos.vehiculosVacioTitulo,
                mensaje: textos.vehiculosVacioMensaje,
                icono: Icons.directions_car_outlined,
              ),
            )
          : MarcoPantalla(
              titulo: titulo,
              conRegreso: true,
              alRefrescar: () => ref.refresh(garajeProvider.future),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
                  sliver: SliverList.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Espaciado.e4),
                    itemBuilder: (context, i) =>
                        _TarjetaDelAuto(auto: lista[i]),
                  ),
                ),
              ],
            ),
    );
  }
}

/// La tarjeta de un auto del garaje; abre su detalle. Si el auto tiene una
/// campana de seguridad pendiente, su insignia va debajo (V2-M10.02).
class _TarjetaDelAuto extends ConsumerWidget {
  const _TarjetaDelAuto({required this.auto});

  final VehiculoGaraje auto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final km = auto.kilometraje;
    final tarjeta = TarjetaAuto(
      marca: auto.marcaAparte,
      titulo: auto.modeloYAnio,
      placas: auto.placas,
      kilometraje: km == null
          ? null
          : textos.vehiculosKilometros(
              NumberFormat.decimalPattern(_localeNumeros(context)).format(km),
            ),
      tinte: tinteDeColorAuto(c, auto.color),
      alToque: () => context.push(rutaDetalleVehiculo(auto.id)),
    );
    if (!ref.watch(hayCampanaAbiertaProvider(auto.id))) return tarjeta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tarjeta,
        const SizedBox(height: Espaciado.e2),
        InsigniaCampanas(vehiculoId: auto.id),
      ],
    );
  }
}

/// Los numeros se escriben a la mexicana (`12,500`) tambien en espanol.
String _localeNumeros(BuildContext context) {
  final idioma = Localizations.localeOf(context).languageCode;
  return idioma == 'es' ? 'es_MX' : idioma;
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).vehiculosCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: TarjetaAuto.altoBase, radio: 28),
            SizedBox(height: Espaciado.e4),
            Esqueleto(alto: TarjetaAuto.altoBase, radio: 28),
          ],
        ),
      ),
    );
  }
}
