import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../tema/tema_carecar.dart';
import 'menu_carecar.dart';
import 'movimiento.dart';

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
    super.key,
  });
  final String titulo;
  final Widget contenido;
  final VoidCallback alCerrarSesion;
  final bool regresar;
  final bool expandir;

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
                ? contenido
                : _refrescable(
                    SingleChildScrollView(
                      key: PageStorageKey(titulo),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(
                        TemaCareCar.espacioSecciones,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: EstiloMenu.anchoMaximo,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: contenido,
                          ),
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
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.paddingOf(context).top + 4,
        8,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                if (regresar)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: blanco),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('Regresar'),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'CARECAR',
                      style: temas.labelSmall?.copyWith(
                        color: TemaCareCar.turquesa,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const Spacer(),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Semantics(
              header: true,
              child: Text(
                titulo,
                style: temas.headlineLarge?.copyWith(color: blanco),
              ),
            ),
          ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.04),
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
