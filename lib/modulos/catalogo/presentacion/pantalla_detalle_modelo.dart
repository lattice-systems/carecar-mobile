import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/tarjeta_vehiculo.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../estreno/estreno.dart';
import '../dominio/detalle_modelo.dart';
import 'proveedores_catalogo.dart';
import 'rutas_catalogo.dart';

/// Detalle de un modelo del catalogo (V2-M03.02): galeria deslizable con zoom,
/// versiones con su precio y ficha resumida.
///
/// Resuelve los cinco estados. Un modelo que ya no esta vigente se explica en
/// vez de fallar. Las tres listas pueden venir vacias: cada seccion sin datos
/// simplemente no se muestra.
class PantallaDetalleModelo extends ConsumerWidget {
  const PantallaDetalleModelo({required this.modeloId, super.key});

  final int modeloId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalle = ref.watch(detalleModeloProvider(modeloId));
    final textos = AppLocalizations.of(context);

    final titulo = textos.catalogoDetalleTitulo;

    return detalle.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: error is NoEncontrado
            ? EstadoVacio(
                titulo: textos.catalogoNoEncontradoTitulo,
                mensaje: textos.catalogoNoEncontradoMensaje,
                icono: Icons.directions_car_outlined,
              )
            : EstadoError(
                causa: error is SinConexion
                    ? CausaError.sinConexion
                    : CausaError.generico,
                alReintentar: () =>
                    ref.invalidate(detalleModeloProvider(modeloId)),
              ),
      ),
      data: (d) => MarcoPantalla(
        titulo: titulo,
        conRegreso: true,
        alRefrescar: () => ref.refresh(detalleModeloProvider(modeloId).future),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: _Detalle(detalle: d, modeloId: modeloId),
            ),
          ),
        ],
      ),
    );
  }
}

/// Los precios son en pesos mexicanos y se escriben igual en cualquier idioma.
final _pesos = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

class _Detalle extends StatelessWidget {
  const _Detalle({required this.detalle, required this.modeloId});

  final DetalleModelo detalle;
  final int modeloId;

  /// Las fotos de la galeria. Sin galeria, la portada es la unica foto.
  List<FotoGaleria> _fotos(AppLocalizations textos) {
    final m = detalle.modelo;
    final origen = detalle.fotos.isNotEmpty
        ? detalle.fotos
        : [if (m.imagenUrl != null) FotoModelo(url: m.imagenUrl!)];
    return [
      for (var i = 0; i < origen.length; i++)
        FotoGaleria(
          imagen: NetworkImage(origen[i].url),
          descripcion:
              origen[i].descripcion ??
              (origen[i].color == null
                  ? textos.catalogoFotoDe(m.titulo, i + 1)
                  : textos.catalogoFotoDeColor(
                      m.titulo,
                      origen[i].color!,
                      i + 1,
                    )),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final m = detalle.modelo;
    final precio = m.precioDesde;
    final fotos = _fotos(textos);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TarjetaVehiculo(
          nombre: m.titulo,
          detalle: [
            ?m.version,
            if (precio != null) textos.precioDesde(_pesos.format(precio)),
          ].join(' · '),
          foto: m.imagenUrl == null ? null : NetworkImage(m.imagenUrl!),
          descripcionFoto: textos.fotoDeModelo(m.titulo),
          heroTag: 'modelo-$modeloId',
        ),
        if (m.descripcion != null) ...[
          const SizedBox(height: Espaciado.e3),
          Text(
            m.descripcion!,
            style: t.cuerpo.copyWith(color: c.textoSecundario),
          ),
        ],
        const SizedBox(height: Espaciado.e4),
        // V2-M16: del interes a una solicitud que llega al CRM.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BotonPildora(
                texto: textos.estrenoQuieroProbarlo,
                icono: Icons.directions_car_outlined,
                expandido: true,
                alPresionar: () => context.push(rutaPruebaManejo(modeloId)),
              ),
            ),
            const SizedBox(width: Espaciado.e2),
            Expanded(
              child: BotonPildora(
                texto: textos.estrenoCotizar,
                icono: Icons.request_quote_outlined,
                variante: VarianteBotonPildora.vidrio,
                expandido: true,
                alPresionar: () => context.push(rutaCotizarEstreno(modeloId)),
              ),
            ),
          ],
        ),
        const SizedBox(height: Espaciado.e2),
        Boton(
          texto: textos.catalogoCalcularTomaACuenta,
          variante: VarianteBoton.secundario,
          anchoCompleto: true,
          alPresionar: () => context.push(rutaCalculadoraDe(modeloId)),
        ),
        if (fotos.length > 1 || detalle.fotos.isNotEmpty) ...[
          _Encabezado(textos.catalogoGaleria),
          GaleriaFotos(fotos: fotos),
        ],
        if (detalle.versiones.isNotEmpty) ...[
          _Encabezado(textos.catalogoVersiones),
          for (final v in detalle.versiones)
            FilaLista(
              titulo: v.nombre,
              subtitulo: v.id == modeloId
                  ? textos.catalogoVersionActual
                  : (v.precioDesde == null
                        ? textos.catalogoSinPrecio
                        : textos.precioDesde(_pesos.format(v.precioDesde))),
              alToque: v.id == modeloId
                  ? null
                  : () => context.push(rutaDetalleModelo(v.id)),
            ),
        ],
        if (detalle.ficha.isNotEmpty) ...[
          _Encabezado(textos.catalogoFicha),
          for (final d in detalle.ficha) _Dato(dato: d),
        ],
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Padding(
      padding: const EdgeInsets.only(top: Espaciado.e5, bottom: Espaciado.e2),
      child: Semantics(
        header: true,
        child: Text(
          texto,
          style: tokens.tipografia.titulo2.copyWith(
            color: tokens.colores.texto,
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.dato});

  final DatoFicha dato;

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
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dato.etiqueta,
                style: t.cuerpoChico.copyWith(color: c.textoSecundario),
              ),
              Text(dato.valor, style: t.cuerpoFuerte.copyWith(color: c.texto)),
            ],
          ),
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
      label: AppLocalizations.of(context).catalogoDetalleCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
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
