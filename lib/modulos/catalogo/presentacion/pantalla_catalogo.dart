import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tarjeta_vehiculo.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../tienda/tienda.dart';
import '../dominio/comparativa.dart';
import '../dominio/modelo_vigente.dart';
import '../../../nucleo/diseno/componentes/boton_accion_flotante.dart';
import 'foto_incluida.dart';
import 'proveedores_catalogo.dart';
import 'rutas_catalogo.dart';

/// Catalogo de modelos actuales de la agencia (V2-M03.01).
///
/// Resuelve los cinco estados: cargando con esqueleto, datos, vacio, error con
/// reintento y sin conexion. Se puede recargar jalando hacia abajo.
///
/// El boton de la barra activa el modo comparar (V2-M03.03): cada modelo con id
/// muestra una casilla, se eligen de dos a tres y el boton de abajo abre la
/// comparativa.
class PantallaCatalogo extends ConsumerStatefulWidget {
  const PantallaCatalogo({super.key});

  @override
  ConsumerState<PantallaCatalogo> createState() => _EstadoPantallaCatalogo();
}

class _EstadoPantallaCatalogo extends ConsumerState<PantallaCatalogo> {
  bool _comparando = false;
  final List<int> _elegidos = [];

  void _alternarModo() => setState(() {
    _comparando = !_comparando;
    _elegidos.clear();
  });

  void _elegir(int id, bool elegido) => setState(() {
    if (elegido) {
      if (_elegidos.length < maximoComparables && !_elegidos.contains(id)) {
        _elegidos.add(id);
      }
    } else {
      _elegidos.remove(id);
    }
  });

  @override
  Widget build(BuildContext context) {
    final modelos = ref.watch(catalogoProvider);
    final textos = AppLocalizations.of(context);
    // Comparar solo tiene sentido con al menos dos modelos que se puedan abrir.
    final comparables =
        modelos.asData?.value.where((m) => m.id != null).length ?? 0;

    final titulo = textos.catalogoTitulo;
    return modelos.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        subtitulo: textos.catalogoSubtitulo,
        icono: LucideIcons300.layoutGrid,
        acciones: const [],
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        subtitulo: textos.catalogoSubtitulo,
        icono: LucideIcons300.layoutGrid,
        acciones: const [],
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(catalogoProvider),
        ),
      ),
      data: (lista) => lista.isEmpty
          ? MarcoPantalla.estado(
              titulo: titulo,
              subtitulo: textos.catalogoSubtitulo,
              icono: LucideIcons300.layoutGrid,
              acciones: const [],
              estado: EstadoVacio(
                titulo: textos.catalogoVacioTitulo,
                mensaje: textos.catalogoVacioMensaje,
                icono: LucideIcons300.car,
                textoAccion: textos.tiendaTitulo,
                alAccion: () => context.push(rutaTienda),
              ),
            )
          : MarcoPantalla(
              titulo: titulo,
              subtitulo: textos.catalogoSubtitulo,
              icono: LucideIcons300.layoutGrid,
              acciones: const [],
              botonFlotante: comparables >= minimoComparables
                  ? BotonAccionFlotante(
                      texto: _comparando
                          ? textos.catalogoSalirDeComparar
                          : textos.catalogoComparar,
                      icono: _comparando
                          ? LucideIcons300.x
                          : LucideIcons300.arrowRightLeft,
                      alPresionar: _alternarModo,
                    )
                  : null,
              alRefrescar: () => ref.refresh(catalogoProvider.future),
              barraInferior: _comparando
                  ? BarraInferior(
                      hijos: [
                        Boton(
                          texto: textos.catalogoCompararElegidos(
                            _elegidos.length,
                          ),
                          anchoCompleto: true,
                          alPresionar: _elegidos.length >= minimoComparables
                              ? () => context.push(rutaComparadorDe(_elegidos))
                              : null,
                        ),
                      ],
                    )
                  : null,
              slivers: [
                // La tienda (V2-M14) vive en Explorar, junto al catálogo.
                if (!_comparando)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Espaciado.e4,
                      Espaciado.e4,
                      Espaciado.e4,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: TarjetaResumen(
                        titulo: textos.tiendaTitulo,
                        subtitulo: textos.tiendaEntradaDetalle,
                        icono: LucideIcons300.shoppingBag,
                        alToque: () => context.push(rutaTienda),
                      ),
                    ),
                  ),
                _Lista(
                  modelos: lista,
                  comparando: _comparando,
                  elegidos: _elegidos,
                  alElegir: _elegir,
                ),
              ],
            ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.modelos,
    required this.comparando,
    required this.elegidos,
    required this.alElegir,
  });

  final List<ModeloVigente> modelos;
  final bool comparando;
  final List<int> elegidos;
  final void Function(int id, bool elegido) alElegir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return SliverPadding(
      padding: const EdgeInsets.all(Espaciado.e4),
      sliver: SliverList.separated(
        itemCount: modelos.length,
        separatorBuilder: (_, _) => const SizedBox(height: Espaciado.e3),
        itemBuilder: (context, i) {
          final m = modelos[i];
          final tarjeta = TarjetaVehiculo(
            nombre: m.titulo,
            detalle: _detalle(context, m),
            foto: m.imagenUrl == null ? null : NetworkImage(m.imagenUrl!),
            fotoRespaldo: fotoIncluidaDeModelo(m.titulo),
            descripcionFoto: textos.fotoDeModelo(m.titulo),
            heroTag: m.id == null ? null : 'modelo-${m.id}',
            alToque: m.id == null
                ? null
                : () => context.push(rutaDetalleModelo(m.id!)),
          );
          final id = m.id;
          if (!comparando || id == null) return tarjeta;
          final elegido = elegidos.contains(id);
          final lleno = elegidos.length >= maximoComparables && !elegido;
          return Column(
            children: [
              tarjeta,
              Casilla(
                etiqueta: textos.catalogoCompararModelo(m.titulo),
                valor: elegido,
                alCambiar: lleno ? null : (v) => alElegir(id, v),
              ),
            ],
          );
        },
      ),
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
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
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
