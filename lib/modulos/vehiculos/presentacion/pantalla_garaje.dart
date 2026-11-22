import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/tarjeta_vehiculo.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/vehiculo_garaje.dart';
import 'proveedores_vehiculos.dart';

/// Garaje del cliente: una tarjeta por vehiculo (V2-M02.01).
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

    return Scaffold(
      appBar: AppBar(title: Text(textos.vehiculosTitulo)),
      body: vehiculos.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(garajeProvider),
        ),
        data: (lista) => lista.isEmpty
            ? EstadoVacio(
                titulo: textos.vehiculosVacioTitulo,
                mensaje: textos.vehiculosVacioMensaje,
                icono: Icons.directions_car_outlined,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(garajeProvider.future),
                child: _Lista(vehiculos: lista),
              ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.vehiculos});

  final List<VehiculoGaraje> vehiculos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Espaciado.e4),
      itemCount: vehiculos.length,
      separatorBuilder: (_, _) => const SizedBox(height: Espaciado.e3),
      itemBuilder: (context, i) {
        final v = vehiculos[i];
        return TarjetaVehiculo(
          nombre: v.titulo,
          detalle: _detalle(context, v),
          heroTag: 'vehiculo-${v.id}',
        );
      },
    );
  }
}

/// "Placas ABC-123 · 12,500 km": lo que haya. Sin placas lo dice.
String _detalle(BuildContext context, VehiculoGaraje v) {
  final textos = AppLocalizations.of(context);
  final km = v.kilometraje;
  final placas = v.placas;
  return [
    placas == null || placas.isEmpty
        ? textos.vehiculosSinPlacas
        : textos.vehiculosPlacas(placas),
    if (km != null)
      textos.vehiculosKilometros(
        NumberFormat.decimalPattern(
          Localizations.localeOf(context).toString(),
        ).format(km),
      ),
  ].join(' · ');
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).vehiculosCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 200),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 200),
          ],
        ),
      ),
    );
  }
}
