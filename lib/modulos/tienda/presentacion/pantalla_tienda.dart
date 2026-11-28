import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/tienda.dart';
import 'formato_tienda.dart';
import 'piezas_tienda.dart';
import 'proveedores_tienda.dart';
import 'rutas_tienda.dart';

// Alto que ocupa un estado (error o vacío) debajo de los filtros.
const _altoEstado = 360.0;

/// Espera tras la última tecla antes de buscar.
const esperaBusquedaTienda = Duration(milliseconds: 400);

/// La tienda (V2-M14.01): los productos que le quedan al auto elegido, con su
/// existencia, categorías y búsqueda. Resuelve cargando, datos, vacío, error y
/// sin conexión; los filtros se quedan en pantalla en todos.
class PantallaTienda extends ConsumerStatefulWidget {
  const PantallaTienda({super.key, this.vehiculoId});

  /// Auto con el que se abre, por ejemplo desde un enlace.
  final int? vehiculoId;

  @override
  ConsumerState<PantallaTienda> createState() => _PantallaTiendaState();
}

class _PantallaTiendaState extends ConsumerState<PantallaTienda> {
  final _busqueda = TextEditingController();
  Timer? _espera;

  @override
  void initState() {
    super.initState();
    final inicial = widget.vehiculoId;
    if (inicial != null) {
      Future.microtask(() {
        if (mounted) {
          ref.read(eleccionDeAutoProvider.notifier).elegir(inicial);
        }
      });
    }
  }

  @override
  void dispose() {
    _espera?.cancel();
    _busqueda.dispose();
    super.dispose();
  }

  void _buscar(String texto) {
    _espera?.cancel();
    ref.read(filtroTiendaProvider.notifier).buscar(texto);
  }

  void _alEscribir(String texto) {
    _espera?.cancel();
    _espera = Timer(esperaBusquedaTienda, () {
      if (mounted) _buscar(texto);
    });
  }

  void _verTodo() {
    _espera?.cancel();
    _busqueda.clear();
    ref.read(filtroTiendaProvider.notifier).limpiar();
    ref.read(eleccionDeAutoProvider.notifier).elegir(null);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final carrito = ref.watch(carritoProvider);
    final productos = ref.watch(productosTiendaProvider);

    return MarcoPantalla(
      icono: LucideIcons300.store,
      titulo: t.tiendaTitulo,
      conRegreso: true,
      acciones: [
        BotonCircular(
          etiqueta: t.tiendaMisPedidos,
          icono: LucideIcons300.receiptText,
          colorIcono: c.texto,
          alPresionar: () => context.push(rutaMisPedidos),
        ),
      ],
      alRefrescar: () => ref.refresh(productosTiendaProvider.future),
      barraInferior: carrito.vacio
          ? null
          : BarraInferior(
              hijos: [
                Boton(
                  texto: t.tiendaVerCarrito(carrito.piezas),
                  icono: LucideIcons300.shoppingBag,
                  anchoCompleto: true,
                  alPresionar: () => context.push(rutaCarrito),
                ),
              ],
            ),
      slivers: [
        SliverToBoxAdapter(child: _filtros(context)),
        ...productos.when(
          skipLoadingOnReload: false,
          skipLoadingOnRefresh: true,
          loading: () => const [
            SliverToBoxAdapter(child: EsqueletoTienda(altos: [112, 112, 112])),
          ],
          error: (error, _) => [
            SliverToBoxAdapter(
              child: SizedBox(
                height: _altoEstado,
                child: ErrorTienda(
                  error: error,
                  alReintentar: () => ref
                    ..invalidate(garajeProvider)
                    ..invalidate(productosTiendaProvider),
                ),
              ),
            ),
          ],
          data: (lista) => lista.elementos.isEmpty
              ? [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: _altoEstado,
                      child: EstadoVacio(
                        titulo: t.tiendaVacioTitulo,
                        mensaje: t.tiendaVacioMensaje,
                        icono: LucideIcons300.searchX,
                        textoAccion: t.tiendaQuitarFiltros,
                        alAccion: _verTodo,
                      ),
                    ),
                  ),
                ]
              : [_lista(context, lista)],
        ),
      ],
    );
  }

  Widget _filtros(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final garaje = ref.watch(garajeProvider).value ?? const <VehiculoGaraje>[];
    final elegido = ref.watch(vehiculoTiendaProvider).value;
    final filtro = ref.watch(filtroTiendaProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Espaciado.e4,
        Espaciado.e2,
        Espaciado.e4,
        Espaciado.e2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (garaje.isNotEmpty) ...[
            Text(
              t.tiendaFiltroAuto,
              style: tokens.tipografia.etiqueta.copyWith(
                color: tokens.colores.textoSecundario,
              ),
            ),
            Wrap(
              spacing: Espaciado.e2,
              children: [
                for (final auto in garaje)
                  ChipPista(
                    texto: auto.titulo,
                    seleccionado: auto.id == elegido,
                    alCambiar: (_) => ref
                        .read(eleccionDeAutoProvider.notifier)
                        .elegir(auto.id),
                  ),
                ChipPista(
                  texto: t.tiendaTodosLosProductos,
                  seleccionado: elegido == null,
                  alCambiar: (_) =>
                      ref.read(eleccionDeAutoProvider.notifier).elegir(null),
                ),
              ],
            ),
            const SizedBox(height: Espaciado.e2),
          ],
          CampoTexto(
            etiqueta: t.tiendaBuscar,
            controlador: _busqueda,
            accionTeclado: TextInputAction.search,
            formatos: [LengthLimitingTextInputFormatter(80)],
            alCambiar: _alEscribir,
            alEnviar: _buscar,
          ),
          const SizedBox(height: Espaciado.e2),
          Wrap(
            spacing: Espaciado.e2,
            children: [
              for (final categoria in [null, ...CategoriaProducto.values])
                ChipPista(
                  texto: textoCategoria(t, categoria),
                  seleccionado: filtro.categoria == categoria,
                  alCambiar: (_) => ref
                      .read(filtroTiendaProvider.notifier)
                      .categoria(categoria),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lista(BuildContext context, ListaPaginada<Producto> lista) {
    final t = AppLocalizations.of(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
      sliver: SliverList.list(
        children: [
          const SizedBox(height: Espaciado.e2),
          for (final producto in lista.elementos) ...[
            TarjetaResumen(
              titulo: producto.nombre,
              subtitulo: pesosTienda(producto.precio),
              detalle: textoExistencia(t, producto),
              icono: iconoCategoria(producto.categoria),
              estado: producto.universal
                  ? t.tiendaUniversal
                  : (producto.compatible ?? false)
                  ? t.tiendaCompatible
                  : null,
              tonoEstado: producto.universal ? Tono.neutro : Tono.exito,
              alToque: () => context.push(rutaProducto(producto.id)),
            ),
            const SizedBox(height: Espaciado.e3),
          ],
          if (lista.errorAlCargarMas) ...[
            Aviso(mensaje: t.tiendaErrorMas, tono: Tono.peligro),
            const SizedBox(height: Espaciado.e3),
          ],
          if (lista.hayMas)
            BotonPildora(
              texto: t.tiendaVerMas,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              cargando: lista.cargandoMas,
              alPresionar: () =>
                  ref.read(productosTiendaProvider.notifier).cargarMas(),
            ),
        ],
      ),
    );
  }
}
