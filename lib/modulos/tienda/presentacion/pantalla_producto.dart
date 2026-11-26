import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/tienda.dart';
import 'formato_tienda.dart';
import 'piezas_tienda.dart';
import 'proveedores_tienda.dart';
import 'rutas_tienda.dart';

/// Lo que se le dice a la persona debajo de las acciones.
class _Resultado {
  const _Resultado(
    this.mensaje, {
    this.tono = Tono.advertencia,
    this.accion,
    this.ruta,
  });

  final String mensaje;
  final Tono tono;
  final String? accion;
  final String? ruta;
}

/// Un producto (V2-M14.01): foto, precio, existencia y compatibilidad con el
/// auto elegido. Se agrega al carrito o se instala en la próxima cita
/// (V2-M14.03).
class PantallaProducto extends ConsumerStatefulWidget {
  const PantallaProducto({required this.productoId, super.key});

  final int productoId;

  @override
  ConsumerState<PantallaProducto> createState() => _PantallaProductoState();
}

class _PantallaProductoState extends ConsumerState<PantallaProducto> {
  int _cantidad = 1;
  bool _buscandoCita = false;
  _Resultado? _resultado;

  void _agregar(Producto producto) {
    final t = AppLocalizations.of(context);
    final sumo = ref
        .read(carritoProvider.notifier)
        .agregar(producto, _cantidad);
    final renglon = ref.read(carritoProvider).renglonDe(producto.id);
    final _Resultado resultado;
    if (renglon == null) {
      resultado = _Resultado(t.tiendaCarritoLleno(maximoRenglones));
    } else if (!sumo) {
      resultado = _Resultado(t.tiendaMaximoAlcanzado(renglon.cantidad));
    } else {
      resultado = _Resultado(
        t.tiendaAgregado(renglon.cantidad),
        tono: Tono.exito,
      );
    }
    setState(() => _resultado = resultado);
  }

  // La cita más próxima de un auto al que le quede el producto. La
  // compatibilidad la decide el servidor, auto por auto.
  Future<CitaCliente?> _citaCompatible(
    Producto producto,
    List<CitaCliente> citas,
  ) async {
    if (producto.universal) return citas.first;
    final repositorio = ref.read(repositorioTiendaProvider);
    final revisados = <int, bool>{};
    for (final cita in citas) {
      var leQueda = revisados[cita.vehiculoId];
      if (leQueda == null) {
        final consultado = await repositorio.producto(
          producto.id,
          vehiculoId: cita.vehiculoId,
        );
        leQueda = consultado.compatible ?? false;
        revisados[cita.vehiculoId] = leQueda;
      }
      if (leQueda) return cita;
    }
    return null;
  }

  Future<void> _instalarEnProximaCita(Producto producto) async {
    if (_buscandoCita) return;
    final t = AppLocalizations.of(context);
    setState(() {
      _buscandoCita = true;
      _resultado = null;
    });
    final sinCita = rutaAgendarCita;
    _Resultado? resultado;
    // Mantiene viva la consulta mientras se espera.
    final citas = ref.listenManual(citasParaInstalarProvider, (_, _) {});
    try {
      ref.invalidate(citasParaInstalarProvider);
      final proximas = await ref.read(citasParaInstalarProvider.future);
      if (!mounted) return;
      if (proximas.isEmpty) {
        resultado = _Resultado(
          t.tiendaSinCitas,
          accion: t.tiendaAgendarCita,
          ruta: sinCita,
        );
      } else {
        final cita = await _citaCompatible(producto, proximas);
        if (!mounted) return;
        if (cita == null) {
          resultado = _Resultado(t.tiendaSinCitaCompatible);
        } else {
          final carrito = ref.read(carritoProvider.notifier);
          if (ref.read(carritoProvider).renglonDe(producto.id) == null &&
              !carrito.agregar(producto, _cantidad)) {
            resultado = _Resultado(t.tiendaCarritoLleno(maximoRenglones));
          } else {
            carrito.instalarEnCita(cita.id);
          }
        }
      }
    } on SinConexion {
      resultado = _Resultado(t.tiendaAccionSinConexion);
    } on Object {
      resultado = _Resultado(t.tiendaErrorCitas);
    } finally {
      citas.close();
    }
    if (!mounted) return;
    setState(() {
      _buscandoCita = false;
      _resultado = resultado;
    });
    if (resultado == null) await context.push(rutaCarrito);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final titulo = t.tiendaProductoTitulo;
    final vehiculo = ref.watch(vehiculoTiendaProvider);
    if (!vehiculo.hasValue) {
      return MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: const EsqueletoTienda(altos: [220, 112, 96]),
      );
    }
    final clave = (productoId: widget.productoId, vehiculoId: vehiculo.value);

    return ref
        .watch(productoTiendaProvider(clave))
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoTienda(altos: [220, 112, 96]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: error is NoEncontrado
                ? EstadoVacio(
                    titulo: t.tiendaProductoNoEncontradoTitulo,
                    mensaje: t.tiendaProductoNoEncontradoMensaje,
                    icono: Icons.search_off_rounded,
                    textoAccion: t.tiendaIrALaTienda,
                    alAccion: () => context.go(rutaTienda),
                  )
                : ErrorTienda(
                    error: error,
                    alReintentar: () =>
                        ref.invalidate(productoTiendaProvider(clave)),
                  ),
          ),
          data: (producto) => MarcoPantalla(
            titulo: titulo,
            conRegreso: true,
            alRefrescar: () =>
                ref.refresh(productoTiendaProvider(clave).future),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
                sliver: SliverToBoxAdapter(
                  child: _contenido(context, producto, vehiculo.value),
                ),
              ),
            ],
          ),
        );
  }

  Widget _contenido(BuildContext context, Producto p, int? vehiculoId) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final carrito = ref.watch(carritoProvider);
    final garaje = ref.watch(garajeProvider).value ?? const <VehiculoGaraje>[];
    final auto = vehiculoId == null ? null : nombreDeAuto(garaje, vehiculoId);
    final foto = p.fotoUrl;
    final resultado = _resultado;
    final maximo = p.maximoPorRenglon;
    final cantidad = maximo == 0 ? 1 : _cantidad.clamp(1, maximo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Espaciado.e2),
        if (foto != null) ...[
          GaleriaFotos(
            fotos: [
              FotoGaleria(
                imagen: ref.watch(imagenTiendaProvider)(foto),
                descripcion: t.tiendaFotoDe(p.nombre),
              ),
            ],
          ),
          const SizedBox(height: Espaciado.e3),
        ],
        TarjetaResumen(
          titulo: p.nombre,
          subtitulo: pesosTienda(p.precio),
          detalle: p.codigo,
          icono: iconoCategoria(p.categoria),
          estado: textoExistencia(t, p),
          tonoEstado: p.agotado ? Tono.advertencia : Tono.exito,
        ),
        const SizedBox(height: Espaciado.e3),
        if (p.universal)
          Aviso(mensaje: t.tiendaUniversal, tono: Tono.exito)
        else if (auto != null && p.compatible != null)
          Aviso(
            mensaje: p.compatible!
                ? t.tiendaLeQueda(auto)
                : t.tiendaNoLeQueda(auto),
            tono: p.compatible! ? Tono.exito : Tono.advertencia,
          ),
        if (p.descripcion != null) ...[
          const SizedBox(height: Espaciado.e3),
          Text(
            p.descripcion!,
            style: tokens.tipografia.cuerpo.copyWith(
              color: tokens.colores.texto,
            ),
          ),
        ],
        const SizedBox(height: Espaciado.e4),
        if (!p.agotado) ...[
          Selector<int>(
            key: ValueKey(maximo),
            etiqueta: t.tiendaCantidad,
            opciones: [
              for (var i = 1; i <= maximo; i++)
                OpcionSelector(valor: i, texto: i.toString()),
            ],
            valor: cantidad,
            alCambiar: (valor) => setState(() => _cantidad = valor ?? 1),
          ),
          const SizedBox(height: Espaciado.e3),
        ],
        BotonPildora(
          texto: t.tiendaAgregar,
          icono: Icons.add_shopping_cart_rounded,
          expandido: true,
          alPresionar: p.agotado ? null : () => _agregar(p),
        ),
        const SizedBox(height: Espaciado.e2),
        BotonPildora(
          texto: t.tiendaInstalarProxima,
          icono: Icons.build_circle_outlined,
          variante: VarianteBotonPildora.tonal,
          expandido: true,
          cargando: _buscandoCita,
          alPresionar: p.agotado ? null : () => _instalarEnProximaCita(p),
        ),
        if (resultado != null) ...[
          const SizedBox(height: Espaciado.e3),
          Aviso(mensaje: resultado.mensaje, tono: resultado.tono),
          if (resultado.ruta != null) ...[
            const SizedBox(height: Espaciado.e2),
            BotonPildora(
              texto: resultado.accion!,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: () => context.push(resultado.ruta!),
            ),
          ],
        ],
        if (!carrito.vacio) ...[
          const SizedBox(height: Espaciado.e2),
          BotonPildora(
            texto: t.tiendaVerCarrito(carrito.piezas),
            icono: Icons.shopping_bag_outlined,
            variante: VarianteBotonPildora.vidrio,
            expandido: true,
            alPresionar: () => context.push(rutaCarrito),
          ),
        ],
        if (p.compatibilidad.isNotEmpty) ...[
          const SizedBox(height: Espaciado.e6),
          GrupoLista(
            encabezado: t.tiendaCompatibilidadTitulo,
            filas: [
              for (final c in p.compatibilidad)
                FilaGrupo(
                  titulo: c.modelo,
                  subtitulo: t.tiendaCompatibilidadAnios(
                    '${c.anioDesde}',
                    '${c.anioHasta}',
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
