import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../mapas/cliente_teselas.dart';
import '../../mapas/mapas.dart';
import '../movimiento_contexto.dart';
import '../tokens/colores.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'aviso.dart';
import 'boton_circular.dart';
import 'boton_pildora.dart';
import 'tono.dart';

/// Algo que cambia de lugar cada pocos segundos, como el chofer de un traslado.
@immutable
class MarcadorEnMovimiento {
  const MarcadorEnMovimiento({
    required this.posicion,
    required this.etiqueta,
    this.icono = LucideIcons300.truck,
  });

  /// La última posición conocida.
  final Coordenada posicion;

  /// Qué es, para el lector de pantalla.
  final String etiqueta;
  final IconData icono;
}

/// Hacia dónde mueve el pin cada botón, en puntos de pantalla.
enum _Rumbo {
  norte(Offset(0, -1), LucideIcons300.arrowUp),
  sur(Offset(0, 1), LucideIcons300.arrowDown),
  oeste(Offset(-1, 0), LucideIcons300.arrowLeft),
  este(Offset(1, 0), LucideIcons300.arrowRight);

  const _Rumbo(this.direccion, this.icono);

  final Offset direccion;
  final IconData icono;

  String boton(AppLocalizations textos) => switch (this) {
    norte => textos.mapaMoverNorte,
    sur => textos.mapaMoverSur,
    oeste => textos.mapaMoverOeste,
    este => textos.mapaMoverEste,
  };

  String anuncio(AppLocalizations textos) => switch (this) {
    norte => textos.mapaPinMovidoNorte,
    sur => textos.mapaPinMovidoSur,
    oeste => textos.mapaPinMovidoOeste,
    este => textos.mapaPinMovidoEste,
  };
}

/// Mapa del sistema de diseño v2 (V2-T02.09, decisión 0006): pin que se
/// arrastra, ubicación propia y un marcador en movimiento.
///
/// El pin lo guarda la pantalla: con `alMoverPin` el mapa se puede editar y
/// entrega la coordenada al tocar, al soltar el arrastre o al usar los
/// botones, que son la forma de moverlo sin arrastrar. Sin `alMoverPin` es de
/// solo lectura.
///
/// Es el único archivo que importa `flutter_map` y `latlong2`. Quien lo usa
/// habla en `Coordenada` y le pasa `configuracionTeselasProvider`.
class Mapa extends StatefulWidget {
  const Mapa({
    required this.teselas,
    super.key,
    this.fuenteTeselas,
    this.pin,
    this.alMoverPin,
    this.miUbicacion,
    this.proveedorUbicacion,
    this.enMovimiento,
    this.descripcion,
    this.centroInicial = centroPorOmision,
    this.alto = 260,
  });

  /// Servidor de teselas y crédito obligatorio.
  final ConfiguracionTeselas teselas;

  /// Reemplaza la descarga de la red en pruebas, golden y galería.
  final FuenteTeselas? fuenteTeselas;

  /// Dónde está el pin; nulo mientras no se ha puesto.
  final Coordenada? pin;

  /// Nulo hace el mapa de solo lectura.
  final ValueChanged<Coordenada>? alMoverPin;

  /// La ubicación del teléfono, si la pantalla ya la tiene.
  final Coordenada? miUbicacion;

  /// Con él aparece «Ver mi ubicación». La posición se lee una sola vez y solo
  /// cuando la persona toca el botón.
  final ProveedorUbicacion? proveedorUbicacion;

  final MarcadorEnMovimiento? enMovimiento;

  /// Nombre del mapa para el lector de pantalla; por omisión dice si hay pin.
  final String? descripcion;

  /// Qué se ve cuando no hay ningún punto que mostrar.
  final Coordenada centroInicial;
  final double alto;

  /// Centro de la zona de cobertura, igual al del backend: León, Guanajuato.
  static const centroPorOmision = Coordenada(21.1250, -101.6860);

  /// Va en el `User-Agent` de cada descarga: la política de teselas de
  /// OpenStreetMap exige que identifique a la app.
  static const _identificadorApp = 'com.carecar.carecar_mobile';

  @override
  State<Mapa> createState() => _EstadoMapa();
}

class _EstadoMapa extends State<Mapa> with SingleTickerProviderStateMixin {
  static const double _tamanoMarcador = Espaciado.objetivoTactilMinimo;
  static const double _tamanoPunto = Espaciado.e6;

  /// El dibujo de `location_on` termina 2 de sus 24 puntos antes de la orilla.
  static const double _huecoBajoElPin = _tamanoMarcador / 12;

  /// Cuánto mueve el pin cada botón: cuanto más cerca, más fino.
  static const double _pasoDelPin = Espaciado.e6;
  static const double _alfaVeloOscuro = 0.4;
  static const double _alfaCredito = 0.85;

  final _controlador = MapController();
  late final _recorrido = AnimationController(vsync: this, value: 1);

  /// Tramo que está recorriendo el marcador en movimiento.
  LatLng? _desde;
  LatLng? _hasta;
  Curve _curva = Curves.linear;

  /// Posición del pin mientras el dedo lo arrastra.
  LatLng? _arrastre;

  Coordenada? _miUbicacionLeida;
  bool _ubicando = false;
  ErrorUbicacion? _errorUbicacion;

  bool _sinTeselas = false;
  int _intento = 0;
  http.Client? _cliente;

  Coordenada? get _miUbicacion => _miUbicacionLeida ?? widget.miUbicacion;

  static LatLng _punto(Coordenada c) => LatLng(c.latitud, c.longitud);

  static Coordenada _coordenada(LatLng p) =>
      Coordenada(p.latitude, p.longitude);

  @override
  void initState() {
    super.initState();
    final movil = widget.enMovimiento;
    if (movil != null) _desde = _hasta = _punto(movil.posicion);
  }

  @override
  void didUpdateWidget(Mapa anterior) {
    super.didUpdateWidget(anterior);
    if (widget.miUbicacion != anterior.miUbicacion) _miUbicacionLeida = null;
    final pin = widget.pin;
    if (pin != null && pin != anterior.pin) _dejarALaVista(_punto(pin));
    final movil = widget.enMovimiento;
    if (movil == null) {
      _desde = _hasta = null;
    } else if (movil.posicion != anterior.enMovimiento?.posicion) {
      _avanzarHasta(_punto(movil.posicion));
    }
  }

  @override
  void dispose() {
    _recorrido.dispose();
    _controlador.dispose();
    _cliente?.close();
    super.dispose();
  }

  /// Lo que llega desde fuera se centra solo si no se estaba viendo.
  void _dejarALaVista(LatLng punto) {
    final camara = _controlador.camera;
    if (!camara.visibleBounds.contains(punto)) {
      _controlador.move(punto, camara.zoom);
    }
  }

  /// Desliza el marcador desde donde va hasta `destino`. Con «reducir
  /// movimiento» salta.
  void _avanzarHasta(LatLng destino) {
    final actual = _posicionDelMovil;
    _desde = actual ?? destino;
    _hasta = destino;
    if (actual == null || MediaQuery.disableAnimationsOf(context)) {
      _recorrido.value = 1;
    } else {
      final movimiento = context.movimiento(Movimiento.base);
      _curva = movimiento.curva;
      _recorrido
        ..duration = movimiento.duracion
        ..forward(from: 0);
    }
    _dejarALaVista(destino);
  }

  LatLng? get _posicionDelMovil {
    final desde = _desde;
    final hasta = _hasta;
    if (desde == null || hasta == null) return null;
    final t = _curva.transform(_recorrido.value);
    return LatLng(
      desde.latitude + (hasta.latitude - desde.latitude) * t,
      desde.longitude + (hasta.longitude - desde.longitude) * t,
    );
  }

  Drag _empezarArrastre(LatLng pin) {
    var enPantalla = _controlador.camera.latLngToScreenOffset(pin);
    return _ArrastreDelPin(
      alMover: (delta) {
        final camara = _controlador.camera;
        final limite = camara.nonRotatedSize;
        enPantalla += delta;
        // Fuera del recuadro ya no se podría ver dónde queda.
        final visible = Offset(
          enPantalla.dx.clamp(0, limite.width),
          enPantalla.dy.clamp(0, limite.height),
        );
        setState(() => _arrastre = camara.screenOffsetToLatLng(visible));
      },
      alSoltar: () {
        final destino = _arrastre;
        if (destino == null) return;
        setState(() => _arrastre = null);
        widget.alMoverPin?.call(_coordenada(destino));
      },
      alCancelar: () {
        if (mounted) setState(() => _arrastre = null);
      },
    );
  }

  void _empujar(_Rumbo rumbo, Coordenada pin) {
    final camara = _controlador.camera;
    final destino = camara.screenOffsetToLatLng(
      camara.latLngToScreenOffset(_punto(pin)) + rumbo.direccion * _pasoDelPin,
    );
    widget.alMoverPin?.call(_coordenada(destino));
    SemanticsService.sendAnnouncement(
      View.of(context),
      rumbo.anuncio(AppLocalizations.of(context)),
      Directionality.of(context),
    );
  }

  Future<void> _verMiUbicacion(ProveedorUbicacion proveedor) async {
    setState(() {
      _ubicando = true;
      _errorUbicacion = null;
    });
    try {
      final posicion = await proveedor.posicionActual();
      if (!mounted) return;
      setState(() => _miUbicacionLeida = posicion);
      _controlador.move(_punto(posicion), _controlador.camera.zoom);
    } on ErrorUbicacion catch (error) {
      if (!mounted) return;
      setState(() => _errorUbicacion = error);
    } finally {
      if (mounted) setState(() => _ubicando = false);
    }
  }

  /// El aviso puede llegar mientras se está dibujando; por eso espera.
  void _fallaronLasTeselas() {
    Future.microtask(() {
      if (mounted && !_sinTeselas) setState(() => _sinTeselas = true);
    });
  }

  TileProvider _proveedorDeTeselas() {
    final fuente = widget.fuenteTeselas;
    if (fuente != null) return _TeselasDeFuente(fuente);
    return NetworkTileProvider(
      httpClient: _cliente ??= ClienteTeselas(RetryClient(http.Client())),
    );
  }

  String _nombre(AppLocalizations textos) => [
    widget.descripcion ??
        (widget.pin != null
            ? textos.mapaConPin
            : widget.enMovimiento == null
            ? textos.mapaSinPin
            : textos.mapaSeguimiento),
    ?widget.enMovimiento?.etiqueta,
    if (_miUbicacion != null) textos.mapaConUbicacion,
  ].join(' ');

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final error = _errorUbicacion;
    final proveedor = widget.proveedorUbicacion;
    const separacion = SizedBox(height: Espaciado.e3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _lienzo(context, textos, tokens),
        if (_sinTeselas) ...[
          separacion,
          Aviso(mensaje: textos.mapaSinTeselas, tono: Tono.advertencia),
          const SizedBox(height: Espaciado.e2),
          BotonPildora(
            texto: textos.mapaReintentar,
            icono: LucideIcons300.refreshCw,
            variante: VarianteBotonPildora.tonal,
            expandido: true,
            alPresionar: () => setState(() {
              _sinTeselas = false;
              _intento++;
            }),
          ),
        ],
        if (proveedor != null) ...[
          separacion,
          BotonPildora(
            texto: textos.mapaMiUbicacion,
            icono: LucideIcons300.locateFixed,
            variante: VarianteBotonPildora.vidrio,
            expandido: true,
            cargando: _ubicando,
            alPresionar: () => _verMiUbicacion(proveedor),
          ),
        ],
        if (error != null) ...[
          separacion,
          Aviso(
            mensaje: switch (error) {
              UbicacionPermisoDenegado() => textos.mapaUbicacionDenegada,
              UbicacionPermisoDenegadoParaSiempre() =>
                textos.mapaUbicacionBloqueada,
              UbicacionServicioApagado() => textos.mapaUbicacionApagada,
              UbicacionTiempoAgotado() => textos.mapaUbicacionTiempo,
            },
            tono: Tono.advertencia,
          ),
        ],
        if (widget.alMoverPin != null) ..._controlesDelPin(textos, tokens),
      ],
    );
  }

  /// La forma de poner y mover el pin sin arrastrar ni apuntar.
  List<Widget> _controlesDelPin(AppLocalizations textos, TokensPista tokens) {
    final pin = widget.pin;
    return [
      const SizedBox(height: Espaciado.e3),
      Text(
        textos.mapaAyudaPin,
        style: tokens.tipografia.cuerpoChico.copyWith(
          color: tokens.colores.textoSecundario,
        ),
      ),
      const SizedBox(height: Espaciado.e2),
      if (pin == null)
        BotonPildora(
          texto: textos.mapaPinAlCentro,
          icono: LucideIcons300.mapPinPlus,
          variante: VarianteBotonPildora.vidrio,
          expandido: true,
          alPresionar: () =>
              widget.alMoverPin?.call(_coordenada(_controlador.camera.center)),
        )
      else
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Espaciado.e2,
          runSpacing: Espaciado.e2,
          children: [
            for (final rumbo in _Rumbo.values)
              BotonCircular(
                icono: rumbo.icono,
                etiqueta: rumbo.boton(textos),
                alPresionar: () => _empujar(rumbo, pin),
              ),
          ],
        ),
    ];
  }

  Widget _lienzo(
    BuildContext context,
    AppLocalizations textos,
    TokensPista tokens,
  ) {
    final c = tokens.colores;
    final pin = widget.pin;
    final yo = _miUbicacion;
    final movil = widget.enMovimiento;
    final puntoDelPin = _arrastre ?? (pin == null ? null : _punto(pin));
    final primero = pin ?? movil?.posicion ?? yo;
    final alMover = widget.alMoverPin;

    return ClipRRect(
      key: const ValueKey('mapa-lienzo'),
      borderRadius: Radios.bordeTarjeta,
      child: SizedBox(
        height: widget.alto,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              container: true,
              label: _nombre(textos),
              child: ExcludeSemantics(
                child: FlutterMap(
                  mapController: _controlador,
                  options: MapOptions(
                    initialCenter: _punto(primero ?? widget.centroInicial),
                    initialZoom: primero == null ? 11 : 16,
                    minZoom: 3,
                    maxZoom: 18,
                    backgroundColor: c.superficieHundida,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: alMover == null
                        ? null
                        : (_, p) => alMover(_coordenada(p)),
                  ),
                  children: [
                    TileLayer(
                      key: ValueKey(_intento),
                      urlTemplate: widget.teselas.urlPlantilla,
                      userAgentPackageName: Mapa._identificadorApp,
                      tileProvider: _proveedorDeTeselas(),
                      // Solo lo que se ve: nada de descargar por adelantado.
                      panBuffer: 0,
                      evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                      errorTileCallback: (_, _, _) => _fallaronLasTeselas(),
                    ),
                    // Las teselas son claras: en oscuro se atenúan.
                    if (Theme.of(context).brightness == Brightness.dark)
                      IgnorePointer(
                        child: ColoredBox(
                          color: c.fondo.withValues(alpha: _alfaVeloOscuro),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    if (yo != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _punto(yo),
                            width: _tamanoPunto,
                            height: _tamanoPunto,
                            child: const _PuntoPropio(
                              key: ValueKey('mapa-mi-ubicacion'),
                            ),
                          ),
                        ],
                      ),
                    if (movil != null)
                      AnimatedBuilder(
                        animation: _recorrido,
                        builder: (context, _) => MarkerLayer(
                          markers: [
                            Marker(
                              point: _posicionDelMovil!,
                              width: _tamanoMarcador,
                              height: _tamanoMarcador,
                              child: _FichaEnMovimiento(
                                key: const ValueKey('mapa-en-movimiento'),
                                icono: movil.icono,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (puntoDelPin != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: puntoDelPin,
                            width: _tamanoMarcador,
                            height: _tamanoMarcador,
                            alignment: Alignment.topCenter,
                            child: _marcadorDelPin(c, pin),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.superficie.withValues(alpha: _alfaCredito),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Radios.control),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Espaciado.e2,
                    vertical: Espaciado.e1,
                  ),
                  child: Semantics(
                    container: true,
                    child: Text(
                      widget.teselas.atribucion,
                      style: tokens.tipografia.etiqueta.copyWith(
                        color: c.textoSecundario,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marcadorDelPin(PaletaColores c, Coordenada? pin) {
    // El aro lo separa de cualquier tesela, en claro y en oscuro.
    final aro = Shadow(color: c.superficie, blurRadius: Espaciado.e1);
    final dibujo = Transform.translate(
      offset: const Offset(0, _huecoBajoElPin),
      child: Icon(
        LucideIcons300.mapPin,
        size: _tamanoMarcador,
        color: c.acento,
        shadows: [aro, aro, aro],
      ),
    );
    if (widget.alMoverPin == null || pin == null) {
      return SizedBox(key: const ValueKey('mapa-pin'), child: dibujo);
    }
    return RawGestureDetector(
      key: const ValueKey('mapa-pin'),
      behavior: HitTestBehavior.opaque,
      gestures: {
        // Gana al desplazamiento del mapa y al de la página, que lo contiene.
        ImmediateMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              ImmediateMultiDragGestureRecognizer
            >(
              ImmediateMultiDragGestureRecognizer.new,
              (reconocedor) =>
                  reconocedor.onStart = (_) => _empezarArrastre(_punto(pin)),
            ),
        // Un toque sobre el propio pin no lo mueve.
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (reconocedor) => reconocedor.onTap = () {},
            ),
      },
      child: dibujo,
    );
  }
}

class _ArrastreDelPin extends Drag {
  _ArrastreDelPin({
    required this.alMover,
    required this.alSoltar,
    required this.alCancelar,
  });

  final ValueChanged<Offset> alMover;
  final VoidCallback alSoltar;
  final VoidCallback alCancelar;

  @override
  void update(DragUpdateDetails details) => alMover(details.delta);

  @override
  void end(DragEndDetails details) => alSoltar();

  @override
  void cancel() => alCancelar();
}

class _TeselasDeFuente extends TileProvider {
  _TeselasDeFuente(this.fuente);

  final FuenteTeselas fuente;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      fuente.tesela(x: coordinates.x, y: coordinates.y, zoom: coordinates.z);
}

/// La ubicación del teléfono: un punto con aro, distinto del pin.
class _PuntoPropio extends StatelessWidget {
  const _PuntoPropio({super.key});

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.acento,
        border: Border.all(color: c.superficie, width: Espaciado.e1),
        boxShadow: [BoxShadow(color: c.velo, blurRadius: Espaciado.e1)],
      ),
    );
  }
}

class _FichaEnMovimiento extends StatelessWidget {
  const _FichaEnMovimiento({required this.icono, super.key});

  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.superficieElevada,
        border: Border.all(color: c.acento, width: 2),
        boxShadow: [BoxShadow(color: c.velo, blurRadius: Espaciado.e1)],
      ),
      child: Icon(icono, size: Espaciado.e6, color: c.acento),
    );
  }
}
