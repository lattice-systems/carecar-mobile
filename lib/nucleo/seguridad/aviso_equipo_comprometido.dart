import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/aviso.dart';
import '../diseno/componentes/tono.dart';
import '../diseno/tema_pista.dart';
import '../diseno/tokens/espaciado.dart';
import 'proveedores_seguridad.dart';

/// Aviso no bloqueante de equipo con root o jailbreak (V2-M22.05).
///
/// Va una sola vez, por encima de la navegacion (en el `builder` de la app).
/// Si el equipo esta comprometido muestra un [Aviso] de advertencia arriba y la
/// app sigue funcionando debajo; la persona puede cerrarlo y vuelve a verlo la
/// proxima vez que abra la app. Si no, [child] ocupa todo el espacio.
class AvisoEquipoComprometido extends ConsumerStatefulWidget {
  const AvisoEquipoComprometido({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AvisoEquipoComprometido> createState() =>
      _AvisoEquipoComprometidoState();
}

class _AvisoEquipoComprometidoState
    extends ConsumerState<AvisoEquipoComprometido> {
  final _cerrado = ValueNotifier<bool>(false);

  /// Mantiene el estado de la navegacion al aparecer o cerrarse el aviso: sin
  /// la llave, cambiar la cantidad de hijos de la columna la reconstruiria.
  final _llaveDelHijo = GlobalKey();

  @override
  void dispose() {
    _cerrado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final politica = ref.watch(politicaDatosLocalesProvider);
    // El `builder` de la app queda por encima del `Navigator`, asi que aqui no
    // hay `Overlay`; el aviso lo necesita para el tooltip de su boton.
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => ListenableBuilder(
            listenable: Listenable.merge([politica, _cerrado]),
            builder: (context, _) {
              final mostrar = politica.equipoComprometido && !_cerrado.value;
              return Column(
                children: [
                  if (mostrar) _aviso(context),
                  Expanded(
                    // El aviso ya cubrio la zona de la barra de estado.
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: mostrar,
                      child: KeyedSubtree(
                        key: _llaveDelHijo,
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _aviso(BuildContext context) {
    final textos = AppLocalizations.of(context);
    // Mientras la app no tenga el tema v2 global (V2-T01.05) el aviso lleva su
    // propio tema Pista, en claro u oscuro segun el sistema.
    final tema = MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro();
    return Theme(
      data: tema,
      child: Material(
        color: tema.scaffoldBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e3),
            // Con letra grande el aviso crece: nunca pasa de la mitad de la
            // pantalla y, si hace falta, se desplaza.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height / 2,
              ),
              child: SingleChildScrollView(
                child: Aviso(
                  tono: Tono.advertencia,
                  titulo: textos.seguridadEquipoComprometidoTitulo,
                  mensaje: textos.seguridadEquipoComprometidoMensaje,
                  alCerrar: () => _cerrado.value = true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
