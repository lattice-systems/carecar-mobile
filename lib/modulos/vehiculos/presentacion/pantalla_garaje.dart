import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/estante.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/vehiculo_garaje.dart';
import 'portada_vehiculo.dart';
import 'proveedores_vehiculos.dart';
import 'rutas_vehiculos.dart';

/// Garaje del cliente en estilo portada (V2-M02.01).
///
/// Titulo grande translucido; con un solo auto es la portada protagonista y
/// con varios un estante de portadas tipo album con un grupo de datos rapidos
/// debajo. Resuelve los cinco estados: cargando con esqueleto, datos, vacio,
/// error con reintento y sin conexion. Sin conexion la API del nucleo entrega
/// la ultima copia guardada, asi que solo se ve el error si nunca hubo datos.
/// Se puede recargar jalando hacia abajo.
class PantallaGaraje extends ConsumerWidget {
  const PantallaGaraje({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculos = ref.watch(garajeProvider);
    final textos = AppLocalizations.of(context);
    final fondo = TokensPista.de(context).colores.fondo;

    Widget estado(Widget hijo) =>
        SliverFillRemaining(hasScrollBody: true, child: hijo);

    final contenido = vehiculos.when(
      skipLoadingOnReload: true,
      loading: () => estado(const _Cargando()),
      error: (error, _) => estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(garajeProvider),
        ),
      ),
      data: (lista) => lista.isEmpty
          ? estado(
              EstadoVacio(
                titulo: textos.vehiculosVacioTitulo,
                mensaje: textos.vehiculosVacioMensaje,
                icono: Icons.directions_car_outlined,
              ),
            )
          : SliverToBoxAdapter(child: _Contenido(vehiculos: lista)),
    );

    return Scaffold(
      backgroundColor: fondo,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(garajeProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            EncabezadoGrande(titulo: textos.vehiculosTitulo, translucido: true),
            contenido,
            const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
          ],
        ),
      ),
    );
  }
}

/// Un auto: portada protagonista. Varios: estante de portadas y datos rapidos.
class _Contenido extends StatelessWidget {
  const _Contenido({required this.vehiculos});

  final List<VehiculoGaraje> vehiculos;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

    if (vehiculos.length == 1) {
      final v = vehiculos.single;
      return CabeceraPortada(
        titulo: v.titulo,
        subtitulo: _detalle(context, v),
        descripcion: textos.fotoDeModelo(v.titulo),
        tinte: tinteDeColor(tokens, v.color),
        portada: PortadaVehiculo(tinte: tinteDeColor(tokens, v.color)),
        principal: AccionPortada(
          texto: textos.vehiculosVerDetalle,
          icono: Icons.directions_car_outlined,
          alPresionar: () => context.push(rutaDetalleVehiculo(v.id)),
        ),
      );
    }

    const lado = 180.0;
    final escala = MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Estante(
          titulo: textos.vehiculosEncabezadoTuAuto,
          anchoTarjeta: lado,
          alto: lado + Espaciado.e3 + escala * 48,
          hijos: [for (final v in vehiculos) _Album(vehiculo: v, lado: lado)],
        ),
        const SizedBox(height: Espaciado.e4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: GrupoLista(
            encabezado: textos.vehiculosEncabezadoRapidos,
            filas: [
              for (final v in vehiculos)
                FilaGrupo(
                  titulo: _detalle(context, v),
                  subtitulo: v.modelo,
                  icono: Icons.directions_car_filled_outlined,
                  colorIcono: tinteDeColor(tokens, v.color),
                  alToque: () => context.push(rutaDetalleVehiculo(v.id)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Portada de album de un auto: arte cuadrado con su tinte y el nombre debajo.
class _Album extends StatelessWidget {
  const _Album({required this.vehiculo, required this.lado});

  final VehiculoGaraje vehiculo;
  final double lado;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    return Semantics(
      button: true,
      label: vehiculo.titulo,
      excludeSemantics: true,
      onTap: () => context.push(rutaDetalleVehiculo(vehiculo.id)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radios.hoja),
        onTap: () => context.push(rutaDetalleVehiculo(vehiculo.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortadaVehiculo(
              tinte: tinteDeColor(tokens, vehiculo.color),
              lado: lado,
            ),
            const SizedBox(height: Espaciado.e2),
            Text(
              vehiculo.titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.cuerpoFuerte.copyWith(color: c.texto),
            ),
          ],
        ),
      ),
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
        NumberFormat.decimalPattern(_localeNumeros(context)).format(km),
      ),
  ].join(' · ');
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
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 240),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
