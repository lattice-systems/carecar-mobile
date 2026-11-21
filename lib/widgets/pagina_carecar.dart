import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../tema/tema_carecar.dart';
import 'menu_carecar.dart';

/// Marco de todas las pantallas autenticadas: encabezado con el degradado de
/// marca, regresar, cerrar sesion y el contenido debajo.
class PaginaCareCar extends StatelessWidget {
  const PaginaCareCar({
    required this.titulo,
    required this.contenido,
    required this.alCerrarSesion,
    this.regresar = true,
    this.expandir = false,
    super.key,
  });
  final String titulo;
  final Widget contenido;
  final VoidCallback alCerrarSesion;
  final bool regresar;
  final bool expandir;

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
                : SingleChildScrollView(
                    key: PageStorageKey(titulo),
                    padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
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
      ],
    ),
  );
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
      decoration: const BoxDecoration(
        gradient: TemaCareCar.degradadoMarca,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
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
