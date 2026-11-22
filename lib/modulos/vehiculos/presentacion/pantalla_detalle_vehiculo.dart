import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/tarjeta_vehiculo.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/vehiculo_garaje.dart';
import 'proveedores_vehiculos.dart';

/// Detalle de un vehiculo del garaje (V2-M02.02): VIN copiable, datos del auto,
/// kilometraje con la fecha en que el taller lo actualizo y accesos a historial,
/// manuales y ficha tecnica.
///
/// Los accesos todavia no tienen pantalla (V2-M02.03, V2-M02.04, V2-M02.05):
/// se ven deshabilitados y dicen "Disponible pronto" en vez de fallar. Resuelve
/// los cinco estados; si el id ya no esta en el garaje lo explica.
class PantallaDetalleVehiculo extends ConsumerWidget {
  const PantallaDetalleVehiculo({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculo = ref.watch(vehiculoProvider(vehiculoId));
    final textos = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(textos.vehiculosDetalleTitulo)),
      body: vehiculo.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(garajeProvider),
        ),
        data: (v) => v == null
            ? EstadoVacio(
                titulo: textos.vehiculosNoEncontradoTitulo,
                mensaje: textos.vehiculosNoEncontradoMensaje,
                icono: Icons.directions_car_outlined,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(garajeProvider.future),
                child: _Detalle(vehiculo: v),
              ),
      ),
    );
  }
}

class _Detalle extends StatefulWidget {
  const _Detalle({required this.vehiculo});

  final VehiculoGaraje vehiculo;

  @override
  State<_Detalle> createState() => _DetalleState();
}

class _DetalleState extends State<_Detalle> {
  bool _vinCopiado = false;

  Future<void> _copiarVin(String vin) async {
    await Clipboard.setData(ClipboardData(text: vin));
    if (mounted) setState(() => _vinCopiado = true);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehiculo;
    final textos = AppLocalizations.of(context);
    final vin = v.vin;
    final placas = v.placas;

    return ListView(
      padding: const EdgeInsets.all(Espaciado.e4),
      children: [
        TarjetaVehiculo(nombre: v.titulo, heroTag: 'vehiculo-${v.id}'),
        const SizedBox(height: Espaciado.e4),
        if (vin != null && vin.isNotEmpty) ...[
          _Dato(
            etiqueta: textos.vehiculosVin,
            valor: vin,
            cifras: true,
            fin: IconButton(
              tooltip: textos.vehiculosCopiarVin,
              onPressed: () => _copiarVin(vin),
              icon: const Icon(Icons.copy_outlined),
            ),
          ),
          if (_vinCopiado)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Espaciado.e2),
              child: Aviso(
                mensaje: textos.vehiculosVinCopiado,
                tono: Tono.exito,
                alCerrar: () => setState(() => _vinCopiado = false),
              ),
            ),
        ],
        _Dato(
          etiqueta: textos.vehiculosPlacasEtiqueta,
          valor: placas == null || placas.isEmpty
              ? textos.vehiculosSinPlacas
              : placas,
        ),
        _Dato(etiqueta: textos.vehiculosAnio, valor: '${v.anio}'),
        if (v.color != null)
          _Dato(etiqueta: textos.vehiculosColor, valor: v.color!),
        if (v.version != null)
          _Dato(etiqueta: textos.vehiculosVersion, valor: v.version!),
        _Kilometraje(vehiculo: v),
        const SizedBox(height: Espaciado.e4),
        FilaLista(
          titulo: textos.vehiculosAccesoHistorial,
          subtitulo: textos.vehiculosAccesoPronto,
          inicio: const Icon(Icons.history),
        ),
        FilaLista(
          titulo: textos.vehiculosAccesoManuales,
          subtitulo: textos.vehiculosAccesoPronto,
          inicio: const Icon(Icons.menu_book_outlined),
        ),
        FilaLista(
          titulo: textos.vehiculosAccesoFicha,
          subtitulo: textos.vehiculosAccesoPronto,
          inicio: const Icon(Icons.fact_check_outlined),
        ),
      ],
    );
  }
}

/// Kilometraje y, debajo, cuando lo actualizo el taller. Sin fecha de cierre
/// lo dice; nunca la inventa.
class _Kilometraje extends StatelessWidget {
  const _Kilometraje({required this.vehiculo});

  final VehiculoGaraje vehiculo;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final km = vehiculo.kilometraje;
    if (km == null) {
      return _Dato(
        etiqueta: textos.vehiculosKilometraje,
        valor: textos.vehiculosKmSinDato,
      );
    }
    final idioma = Localizations.localeOf(context).languageCode;
    final cierre = vehiculo.kilometrajeActualizadoEn;
    return _Dato(
      etiqueta: textos.vehiculosKilometraje,
      valor: textos.vehiculosKilometros(
        NumberFormat.decimalPattern(idioma == 'es' ? 'es_MX' : idioma)
            .format(km),
      ),
      nota: cierre == null
          ? textos.vehiculosKmSinActualizar
          : textos.vehiculosKmActualizado(
              MaterialLocalizations.of(context).formatFullDate(cierre),
            ),
    );
  }
}

/// Una fila de dato: etiqueta, valor (en cifras si es un codigo), una nota
/// opcional y un adorno al final. El lector de pantalla recibe etiqueta, valor
/// y nota juntos.
class _Dato extends StatelessWidget {
  const _Dato({
    required this.etiqueta,
    required this.valor,
    this.nota,
    this.cifras = false,
    this.fin,
  });

  final String etiqueta;
  final String valor;
  final String? nota;
  final bool cifras;
  final Widget? fin;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borde)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Espaciado.e2),
        child: Row(
          children: [
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etiqueta,
                      style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                    ),
                    Text(
                      valor,
                      style: (cifras ? t.cifra : t.cuerpoFuerte).copyWith(
                        color: c.texto,
                      ),
                    ),
                    if (nota != null)
                      Text(
                        nota!,
                        style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                      ),
                  ],
                ),
              ),
            ),
            ?fin,
          ],
        ),
      ),
    );
  }
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
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
