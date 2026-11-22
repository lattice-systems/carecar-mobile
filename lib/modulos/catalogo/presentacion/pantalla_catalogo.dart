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
import '../dominio/modelo_vigente.dart';
import 'proveedores_catalogo.dart';

/// Catalogo de modelos actuales de la agencia (V2-M03.01).
///
/// Resuelve los cinco estados: cargando con esqueleto, datos, vacio, error con
/// reintento y sin conexion. Se puede recargar jalando hacia abajo.
class PantallaCatalogo extends ConsumerWidget {
  const PantallaCatalogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelos = ref.watch(catalogoProvider);
    final textos = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(textos.catalogoTitulo)),
      body: modelos.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(catalogoProvider),
        ),
        data: (lista) => lista.isEmpty
            ? EstadoVacio(
                titulo: textos.catalogoVacioTitulo,
                mensaje: textos.catalogoVacioMensaje,
                icono: Icons.directions_car_outlined,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(catalogoProvider.future),
                child: _Lista(modelos: lista),
              ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.modelos});

  final List<ModeloVigente> modelos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Espaciado.e4),
      itemCount: modelos.length,
      separatorBuilder: (_, _) => const SizedBox(height: Espaciado.e3),
      itemBuilder: (context, i) {
        final m = modelos[i];
        return TarjetaVehiculo(
          nombre: m.titulo,
          detalle: _detalle(context, m),
          foto: m.imagenUrl == null ? null : NetworkImage(m.imagenUrl!),
          descripcionFoto: AppLocalizations.of(context).fotoDeModelo(m.titulo),
          heroTag: m.id == null ? null : 'modelo-${m.id}',
        );
      },
    );
  }
}

/// Los precios son en pesos mexicanos y se escriben igual en cualquier idioma:
/// `$450,000`. Por eso el formato no sigue al idioma de la app.
final _pesos = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

/// "Signature · Desde $450,000": la version y el precio, lo que haya.
String? _detalle(BuildContext context, ModeloVigente m) {
  final textos = AppLocalizations.of(context);
  final precio = m.precioDesde;
  final partes = [
    ?m.version,
    if (precio != null) textos.precioDesde(_pesos.format(precio)),
  ];
  return partes.isEmpty ? null : partes.join(' · ');
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).catalogoCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 240),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 240),
          ],
        ),
      ),
    );
  }
}
