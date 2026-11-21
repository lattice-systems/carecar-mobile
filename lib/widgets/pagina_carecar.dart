import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../tema/tema_carecar.dart';
import 'logo_carecar.dart';
import 'menu_carecar.dart';
import 'movimiento.dart';
import 'pantalla.dart';

/// Marco de todas las pantallas autenticadas: encabezado con el degradado de
/// marca, regresar, cerrar sesion y el contenido debajo.
class PaginaCareCar extends StatefulWidget {
  const PaginaCareCar({
    required this.titulo,
    required this.contenido,
    required this.alCerrarSesion,
    this.regresar = true,
    this.cabecera,
    this.expandir = false,
    this.alRefrescar,
    this.anchoMaximo = EstiloMenu.anchoMaximo,
    super.key,
  });
  final String titulo;
  final Widget contenido;
  final VoidCallback alCerrarSesion;
  final bool regresar;

  /// Saludo opcional bajo el titulo (p. ej. nombre de la persona).
  final Widget? cabecera;
  final bool expandir;

  /// Ancho maximo del contenido; en pantallas amplias queda centrado.
  final double anchoMaximo;

  /// Si no es nulo, el contenido admite deslizar hacia abajo para recargar.
  final Future<void> Function()? alRefrescar;

  static const botonCerrarSesion = Key('inicio_cerrar_sesion');

  @override
  State<PaginaCareCar> createState() => _PaginaCareCarState();
}

class _PaginaCareCarState extends State<PaginaCareCar> {
  /// Que tanto se contrajo el encabezado: 0 = completo, 1 = compacto.
  final _colapso = ValueNotifier<double>(0);

  /// Pixeles de scroll que tarda el encabezado en contraerse del todo.
  static const _recorrido = 90.0;

  String get titulo => widget.titulo;
  Widget get contenido => widget.contenido;
  bool get expandir => widget.expandir;
  double get anchoMaximo => widget.anchoMaximo;

  @override
  void dispose() {
    _colapso.dispose();
    super.dispose();
  }

  bool _alDesplazar(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final valor = (n.metrics.pixels / _recorrido).clamp(0.0, 1.0);
    if ((valor - _colapso.value).abs() > 0.01) _colapso.value = valor;
    return false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Encabezado(
          titulo: titulo,
          regresar: widget.regresar,
          cabecera: widget.cabecera,
          alCerrarSesion: widget.alCerrarSesion,
          colapso: _colapso,
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _alDesplazar,
            child: SafeArea(
              top: false,
              child: expandir
                  ? AnchoLimitado(anchoMaximo: anchoMaximo, child: contenido)
                  : _refrescable(
                      SingleChildScrollView(
                        key: PageStorageKey(titulo),
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(
                          TemaCareCar.espacioSecciones,
                        ),
                        child: AnchoLimitado(
                          anchoMaximo: anchoMaximo,
                          child: contenido,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _refrescable(Widget hijo) {
    final refrescar = widget.alRefrescar;
    if (refrescar == null) return hijo;
    return RefreshIndicator(
      onRefresh: refrescar,
      color: TemaCareCar.azulAgencia,
      child: hijo,
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.titulo,
    required this.regresar,
    required this.cabecera,
    required this.alCerrarSesion,
    required this.colapso,
  });

  final String titulo;
  final bool regresar;
  final Widget? cabecera;
  final VoidCallback alCerrarSesion;
  final ValueListenable<double> colapso;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    const blanco = Colors.white;
    final relleno = MediaQuery.paddingOf(context);
    // Tarjeta flotante: empieza DEBAJO de la barra de notificaciones (nunca
    // pasa por detras de ella) y deja un margen a los lados.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12 + relleno.left,
        relleno.top + 8,
        12 + relleno.right,
        0,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: TemaCareCar.degradadoMarca,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: Stack(
          children: [
            // Destellos que flotan despacio detras del titulo.
            Positioned(
              right: -40,
              top: -30,
              child: const _Destello(tamano: 170, opacidad: 0.22).siempre(
                context,
                (w) => w
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .move(
                      begin: Offset.zero,
                      end: const Offset(-24, 18),
                      duration: 4200.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -50,
              child: const _Destello(tamano: 130, opacidad: 0.12).siempre(
                context,
                (w) => w
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .move(
                      begin: Offset.zero,
                      end: const Offset(30, -14),
                      duration: 5200.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: colapso,
              builder: (context, c, _) => _contenido(context, temas, blanco, c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(
    BuildContext context,
    TextTheme temas,
    Color blanco,
    double c,
  ) {
    // En horizontal (ventana baja) el titulo va en la misma fila que los
    // botones para no comerse la pantalla.
    final baja = Pantalla.esBaja(context);
    // Titulo adaptable: los largos arrancan mas chicos y todos se contraen al
    // hacer scroll hasta una sola linea de 20 px.
    final largo = titulo.length > 26;
    final tamanoInicio =
        baja || largo || Pantalla.de(context) == Pantalla.compacto
        ? (largo ? 20.0 : 22.0)
        : 26.0;
    final tamano = baja ? 20.0 : lerpDouble(tamanoInicio, 20, c)!;
    final estiloTitulo = temas.headlineLarge?.copyWith(
      color: blanco,
      fontSize: tamano,
      height: 1.2,
    );
    final tituloAnimado = Semantics(
      header: true,
      child: Text(
        titulo,
        maxLines: (baja || c > 0.5) ? 1 : 2,
        overflow: TextOverflow.ellipsis,
        style: estiloTitulo,
      ),
    ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.04);

    return Container(
      padding: EdgeInsets.fromLTRB(8, 4, 8, baja ? 8 : lerpDouble(14, 8, c)!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                if (regresar)
                  Flexible(
                    flex: baja ? 0 : 1,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: blanco,
                        minimumSize: const Size(
                          TemaCareCar.altoMinimoToque,
                          TemaCareCar.altoMinimoToque,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      // En horizontal basta la flecha: el espacio es del titulo.
                      label: baja
                          ? const SizedBox.shrink()
                          : const Text(
                              'Regresar',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: const LogoCareCar(tamano: 32),
                  ),
                if (baja) Expanded(child: tituloAnimado) else const Spacer(),
                IconButton(
                  key: PaginaCareCar.botonCerrarSesion,
                  onPressed: alCerrarSesion,
                  color: blanco,
                  icon: const Icon(Icons.logout),
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),
          ),
          if (!baja)
            Padding(
              padding: EdgeInsets.fromLTRB(16, lerpDouble(4, 0, c)!, 16, 0),
              child: tituloAnimado,
            ),
          if (!baja && cabecera != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: cabecera,
            ),
        ],
      ),
    );
  }
}

class _Destello extends StatelessWidget {
  const _Destello({required this.tamano, required this.opacidad});

  final double tamano;
  final double opacidad;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            TemaCareCar.turquesa.withValues(alpha: opacidad),
            TemaCareCar.turquesa.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}
