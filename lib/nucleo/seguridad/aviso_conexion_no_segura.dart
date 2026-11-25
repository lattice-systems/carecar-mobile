import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/aviso.dart';
import '../diseno/componentes/tono.dart';
import '../diseno/tema_pista.dart';
import '../diseno/tokens/espaciado.dart';
import 'proveedores_seguridad.dart';

/// Aviso no bloqueante cuando el certificado del servidor no se puede verificar
/// (V2-M22.15).
///
/// Con los certificados fijados (V2-M22.04), una red con filtros o un servidor
/// que cambió de autoridad cortan la conexión; cada pantalla diría «sin
/// conexión» y la persona no sabría por qué. Este aviso va una sola vez, por
/// encima de la navegación (en el `builder` de la app), y se quita solo con la
/// siguiente respuesta del servidor.
class AvisoConexionNoSegura extends ConsumerWidget {
  const AvisoConexionNoSegura({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(estadoConexionSeguraProvider);
    // Con el aviso la columna tiene un hijo más al principio: Flutter empareja
    // los hijos también desde el final, así que lo de abajo conserva su estado
    // sin llave (lo comprueba la prueba del contador).
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final mostrar = estado.noSegura;
        return Column(
          children: [
            if (mostrar) _aviso(context),
            Expanded(
              // El aviso ya cubrió la zona de la barra de estado.
              child: MediaQuery.removePadding(
                context: context,
                removeTop: mostrar,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _aviso(BuildContext context) {
    final textos = AppLocalizations.of(context);
    // Mientras la app no tenga el tema v2 global (V2-T01.05) el aviso lleva su
    // propio tema Pista, en claro u oscuro según el sistema.
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
                // `Aviso` ya se anuncia al lector de pantalla al aparecer.
                child: Aviso(
                  tono: Tono.peligro,
                  titulo: textos.seguridadConexionNoSeguraTitulo,
                  mensaje: textos.seguridadConexionNoSeguraMensaje,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
