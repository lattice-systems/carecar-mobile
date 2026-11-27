import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/comparativa.dart';
import '../dominio/detalle_modelo.dart';
import 'proveedores_catalogo.dart';

/// Comparativa de dos o tres modelos lado a lado (V2-M03.03).
///
/// Una columna por modelo y una fila por dato: primero el precio y luego la
/// ficha tecnica de todos. Un dato que un modelo no tiene dice "Sin dato" en
/// vez de dejar el hueco. La tabla se desliza de lado cuando no cabe, por
/// ejemplo con la letra al 200 %. Con ids que no sirven (menos de dos, mas de
/// tres o repetidos) explica como llegar bien en vez de fallar.
class PantallaComparador extends ConsumerWidget {
  const PantallaComparador({required this.ids, super.key});

  /// Ids ya validados con `idsDeComparativa`. Vacia si el enlace no servia.
  final List<int> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);

    Widget estado(Widget hijo) => MarcoPantalla.estado(
      titulo: textos.catalogoComparadorTitulo,
      conRegreso: true,
      estado: hijo,
    );

    if (ids.isEmpty) {
      return estado(
        EstadoVacio(
          titulo: textos.catalogoComparadorIdsMalosTitulo,
          mensaje: textos.catalogoComparadorIdsMalosMensaje,
          icono: LucideIcons300.arrowRightLeft,
        ),
      );
    }

    final clave = ids.join(',');
    return ref
        .watch(comparativaProvider(clave))
        .when(
          skipLoadingOnReload: true,
          loading: () => estado(const _Cargando()),
          error: (error, _) => estado(
            error is NoEncontrado
                ? EstadoVacio(
                    titulo: textos.catalogoNoEncontradoTitulo,
                    mensaje: textos.catalogoNoEncontradoMensaje,
                    icono: LucideIcons300.car,
                  )
                : EstadoError(
                    causa: error is SinConexion
                        ? CausaError.sinConexion
                        : CausaError.generico,
                    alReintentar: () =>
                        ref.invalidate(comparativaProvider(clave)),
                  ),
          ),
          data: (modelos) => MarcoPantalla(
            titulo: textos.catalogoComparadorTitulo,
            conRegreso: true,
            alRefrescar: () => ref.refresh(comparativaProvider(clave).future),
            slivers: [SliverToBoxAdapter(child: _Tabla(modelos: modelos))],
          ),
        );
  }
}

final _pesos = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

/// Ancho de cada columna de modelo. Con tres modelos la tabla pasa de un
/// telefono chico y se desliza de lado.
const double _anchoColumna = 160;

class _Tabla extends StatelessWidget {
  const _Tabla({required this.modelos});

  final List<DetalleModelo> modelos;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final masBarato = indiceMasBarato(modelos);
    final sinDato = textos.catalogoComparadorSinDato;

    final filas = <FilaComparativa>[
      FilaComparativa(
        etiqueta: textos.catalogoComparadorPrecio,
        valores: [
          for (final m in modelos)
            m.modelo.precioDesde == null
                ? null
                : _pesos.format(m.modelo.precioDesde),
        ],
      ),
      ...filasDeFicha(modelos),
    ];

    // El scroll vertical es el del marco y el horizontal el de la tabla, asi
    // la pantalla alta y la ancha se resuelven sin recortar nada.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilaModelos(modelos: modelos),
            for (var f = 0; f < filas.length; f++)
              _FilaDato(
                fila: filas[f],
                modelos: modelos,
                sinDato: sinDato,
                // La fila 0 es el precio: ahi se marca el mas bajo.
                resaltar: f == 0 ? masBarato : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _FilaModelos extends StatelessWidget {
  const _FilaModelos({required this.modelos});

  final List<DetalleModelo> modelos;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in modelos)
          SizedBox(
            width: _anchoColumna,
            child: Padding(
              padding: const EdgeInsets.only(right: Espaciado.e2),
              child: Semantics(
                header: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: m.modelo.imagenUrl == null
                            ? Icon(
                                LucideIcons300.carFront,
                                size: 48,
                                color: c.textoTerciario,
                              )
                            : Image.network(
                                m.modelo.imagenUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  LucideIcons300.carFront,
                                  size: 48,
                                  color: c.textoTerciario,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: Espaciado.e2),
                    Text(
                      m.modelo.titulo,
                      style: t.cuerpoFuerte.copyWith(color: c.texto),
                    ),
                    if (m.modelo.version != null)
                      Text(
                        m.modelo.version!,
                        style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({
    required this.fila,
    required this.modelos,
    required this.sinDato,
    required this.resaltar,
  });

  final FilaComparativa fila;
  final List<DetalleModelo> modelos;
  final String sinDato;

  /// Indice de la columna a resaltar, si hay.
  final int? resaltar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Padding(
      padding: const EdgeInsets.only(top: Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fila.etiqueta,
            style: t.cuerpoChico.copyWith(color: c.textoSecundario),
          ),
          const SizedBox(height: Espaciado.e1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < modelos.length; i++)
                SizedBox(
                  width: _anchoColumna,
                  child: Padding(
                    padding: const EdgeInsets.only(right: Espaciado.e2),
                    child: _Celda(
                      valor: fila.valores[i],
                      sinDato: sinDato,
                      resaltado: resaltar == i,
                      etiquetaResaltado: textos.catalogoComparadorMasBajo,
                      semantica: textos.catalogoComparadorCelda(
                        fila.etiqueta,
                        modelos[i].modelo.titulo,
                        fila.valores[i] ?? sinDato,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Celda extends StatelessWidget {
  const _Celda({
    required this.valor,
    required this.sinDato,
    required this.resaltado,
    required this.etiquetaResaltado,
    required this.semantica,
  });

  final String? valor;
  final String sinDato;
  final bool resaltado;
  final String etiquetaResaltado;
  final String semantica;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final estilo = valor == null
        ? t.cuerpo.copyWith(color: c.textoTerciario)
        : t.cuerpoFuerte.copyWith(color: c.texto);

    return Semantics(
      label: resaltado ? '$semantica, $etiquetaResaltado' : semantica,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resaltado ? c.acento.withValues(alpha: 0.12) : null,
          border: Border(bottom: BorderSide(color: c.borde)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Espaciado.e2,
            horizontal: Espaciado.e1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valor ?? sinDato, style: estilo),
              if (resaltado)
                Text(
                  etiquetaResaltado,
                  style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                ),
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
      label: AppLocalizations.of(context).catalogoComparadorCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 120),
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
