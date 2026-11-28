import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/aviso.dart';
import '../diseno/componentes/tono.dart';
import '../diseno/tema_pista.dart';
import '../diseno/tokens/espaciado.dart';
import 'senal_de_conexion.dart';

/// Aviso discreto cuando la agencia no contesta · V2-M21.04.
///
/// Va **por encima de la navegacion**, una sola vez, en el `builder` de la
/// app: sin esto cada pantalla diria «sin conexion» por su cuenta y la persona
/// veria el mismo mensaje cinco veces sin entender que es uno solo.
///
/// Es **advertencia y no peligro**: sin red la app sigue sirviendo para leer lo
/// que ya tiene guardado. El tono rojo esta reservado para lo que si es grave,
/// como un certificado que no se puede verificar (V2-M22.15).
///
/// Se quita solo con la siguiente respuesta buena del servidor; no hay boton de
/// cerrar porque no hay nada que la persona pueda hacer aqui, y uno invitaria a
/// taparlo en vez de a esperar.
class AvisoSinConexion extends ConsumerWidget {
  const AvisoSinConexion({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senal = ref.watch(senalDeConexionProvider);
    // Con el aviso la columna tiene un hijo mas al principio: Flutter empareja
    // los hijos tambien desde el final, asi que lo de abajo conserva su estado
    // sin llave.
    return ListenableBuilder(
      listenable: senal,
      builder: (context, _) {
        final mostrar = senal.sinConexion;
        return Column(
          children: [
            if (mostrar) _aviso(context),
            Expanded(
              // El aviso ya cubrio la zona de la barra de estado.
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
                  key: const Key('aviso_sin_conexion'),
                  tono: Tono.advertencia,
                  titulo: textos.conexionSinRedTitulo,
                  mensaje: textos.conexionSinRedMensaje,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
