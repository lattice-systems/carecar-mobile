import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../tema/tema_carecar.dart';
import 'menu_carecar.dart';
import 'movimiento.dart';
import 'pantalla.dart';

/// Marco de todas las pantallas autenticadas: encabezado con el degradado de
/// marca, regresar, cerrar sesion y el contenido debajo.
class PaginaCareCar extends StatelessWidget {
  const PaginaCareCar({
    required this.titulo,
    required this.contenido,
    required this.alCerrarSesion,
    this.regresar = true,
    this.expandir = false,
    this.alRefrescar,
    this.anchoMaximo = EstiloMenu.anchoMaximo,
    super.key,
  });
  final String titulo;
  final Widget contenido;
  final VoidCallback alCerrarSesion;
  final bool regresar;
  final bool expandir;

  /// Ancho maximo del contenido; en pantallas amplias queda centrado.
  final double anchoMaximo;

  /// Si no es nulo, el contenido admite deslizar hacia abajo para recargar.
  final Future<void> Function()? alRefrescar;

  static const botonCerrarSesion = Key('inicio_cerrar_sesion');

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Encabezado(
          titulo: titulo,
          regresar: regresar,
          alCerrarSesion: alCerrarSesion,
        ),
        Expanded(
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
      ],
    ),
  );

  Widget _refrescable(Widget hijo) {
    final refrescar = alRefrescar;
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
    required this.alCerrarSesion,
  });

  final String titulo;
  final bool regresar;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    const blanco = Colors.white;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: TemaCareCar.degradadoMarca,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
          _contenido(context, temas, blanco),
        ],
      ),
    );
  }

  Widget _contenido(BuildContext context, TextTheme temas, Color blanco) {
    final relleno = MediaQuery.paddingOf(context);
    // En horizontal (ventana baja) el titulo va en la misma fila que los
    // botones para no comerse la pantalla.
    final baja = Pantalla.esBaja(context);
    final estiloTitulo =
        (baja || Pantalla.de(context) == Pantalla.compacto
                ? temas.headlineMedium
                : temas.headlineLarge)
            ?.copyWith(color: blanco);
    final tituloAnimado = Semantics(
      header: true,
      child: Text(
        titulo,
        maxLines: baja ? 1 : 2,
        overflow: TextOverflow.ellipsis,
        style: baja ? temas.titleLarge?.copyWith(color: blanco) : estiloTitulo,
      ),
    ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.04);

    return Container(
      padding: EdgeInsets.fromLTRB(
        8 + relleno.left,
        relleno.top + 4,
        8 + relleno.right,
        baja ? 8 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
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
                    child: Text(
                      'CARECAR',
                      style: temas.labelSmall?.copyWith(
                        color: TemaCareCar.turquesa,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: tituloAnimado,
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
