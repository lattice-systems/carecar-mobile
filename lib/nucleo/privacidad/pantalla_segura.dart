import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'proteccion_de_captura.dart';

/// Envoltorio declarativo: mientras este widget esta en el arbol, la pantalla
/// no se puede capturar ni grabar (Android) y no aparece en el selector de apps.
///
/// Uso: `PantallaSegura(child: PantallaPago())`, normalmente en el `builder`
/// de la ruta. Solo para pagos (M08) y documentos (M09); el resto de la app
/// se deja capturar a proposito.
class PantallaSegura extends ConsumerStatefulWidget {
  const PantallaSegura({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PantallaSegura> createState() => _PantallaSeguraState();
}

class _PantallaSeguraState extends ConsumerState<PantallaSegura> {
  late final ProteccionDeCaptura _proteccion;

  @override
  void initState() {
    super.initState();
    _proteccion = ref.read(proteccionDeCapturaProvider);
    _proteccion.bloquear();
  }

  @override
  void dispose() {
    _proteccion.permitir();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
