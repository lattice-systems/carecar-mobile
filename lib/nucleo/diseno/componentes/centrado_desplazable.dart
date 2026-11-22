import 'package:flutter/widgets.dart';

/// Centra el contenido y, si no cabe (letra grande, pantalla chica), lo deja
/// desplazarse en vez de desbordar. Base de los estados de pantalla completa.
class CentradoDesplazable extends StatelessWidget {
  const CentradoDesplazable({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, caja) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: caja.hasBoundedHeight ? caja.maxHeight : 0,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
