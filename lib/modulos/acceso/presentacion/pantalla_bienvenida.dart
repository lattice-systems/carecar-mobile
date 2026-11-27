import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/bienvenida/estado_bienvenida.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';

/// Bienvenida del primer arranque · V2-M01.02.
///
/// Aparece **una vez**, antes del login: explica que puede hacer la app a
/// quien todavia no tiene cuenta abierta. Quien la vio o la salto no la vuelve
/// a ver, y eso lo recuerda [bienvenidaPendienteProvider] en las preferencias
/// del dispositivo; quien decide mostrarla es la guardia de rutas.
///
/// ## Accesibilidad
///
/// Cada lamina es un `Semantics` con encabezado, asi que el lector de pantalla
/// anuncia el titulo como tal y luego el texto. Los puntos de abajo quedan
/// **fuera** del arbol de semantica: son decorativos y repetir «paso 2 de 3»
/// en tres nodos solo estorba. «Saltar» esta en la barra y es alcanzable en el
/// primer gesto, no al final del recorrido.
class PantallaBienvenida extends ConsumerStatefulWidget {
  const PantallaBienvenida({super.key});

  static const botonSaltar = Key('bienvenida_saltar');
  static const botonSiguiente = Key('bienvenida_siguiente');

  @override
  ConsumerState<PantallaBienvenida> createState() =>
      _EstadoPantallaBienvenida();
}

class _EstadoPantallaBienvenida extends ConsumerState<PantallaBienvenida> {
  final _paginas = PageController();
  int _actual = 0;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  Future<void> _terminar() async {
    final router = GoRouter.of(context);
    await ref.read(bienvenidaPendienteProvider.notifier).marcarVista();
    // La guardia deja de mandar aqui en cuanto el estado cambia; el destino es
    // el inicio y ella decide si toca pedir sesion.
    router.go(Rutas.inicio);
  }

  void _siguiente(int total) {
    if (_actual >= total - 1) {
      _terminar();
      return;
    }
    _paginas.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

    final laminas = <_Lamina>[
      _Lamina(
        icono: LucideIcons300.car,
        titulo: textos.bienvenidaUnoTitulo,
        texto: textos.bienvenidaUnoTexto,
      ),
      _Lamina(
        icono: LucideIcons300.calendarCheck,
        titulo: textos.bienvenidaDosTitulo,
        texto: textos.bienvenidaDosTexto,
      ),
      _Lamina(
        icono: LucideIcons300.bellRing,
        titulo: textos.bienvenidaTresTitulo,
        texto: textos.bienvenidaTresTexto,
      ),
    ];
    final ultima = _actual >= laminas.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(Espaciado.e3),
                child: Boton(
                  key: PantallaBienvenida.botonSaltar,
                  texto: textos.bienvenidaSaltar,
                  variante: VarianteBoton.terciario,
                  alPresionar: _terminar,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _paginas,
                onPageChanged: (i) => setState(() => _actual = i),
                children: laminas,
              ),
            ),
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < laminas.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Espaciado.e1,
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _actual
                              ? tokens.colores.acento
                              : tokens.colores.borde,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Espaciado.e5),
              child: Boton(
                key: PantallaBienvenida.botonSiguiente,
                texto: ultima
                    ? textos.bienvenidaEmpezar
                    : textos.bienvenidaSiguiente,
                alPresionar: () => _siguiente(laminas.length),
                anchoCompleto: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lamina extends StatelessWidget {
  const _Lamina({
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  final IconData icono;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);

    return CentradoDesplazable(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, size: 48, color: tokens.colores.acento),
              const SizedBox(height: Espaciado.e5),
              Semantics(
                header: true,
                child: Text(titulo, style: tokens.tipografia.titulo1),
              ),
              const SizedBox(height: Espaciado.e3),
              Text(
                texto,
                style: tokens.tipografia.cuerpo.copyWith(
                  color: tokens.colores.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
