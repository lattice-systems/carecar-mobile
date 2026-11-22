import 'package:flutter/widgets.dart';

/// Una seccion de la galeria: un componente con sus estados.
class SeccionGaleria {
  const SeccionGaleria({required this.titulo, required this.construir});

  final String titulo;
  final WidgetBuilder construir;
}

/// Guarda un valor para las demos que necesitan estado. Evita una clase
/// `StatefulWidget` por cada componente de la galeria.
class Con<T> extends StatefulWidget {
  const Con({required this.inicial, required this.construir, super.key});

  final T inicial;
  final Widget Function(T valor, ValueChanged<T> cambiar) construir;

  @override
  State<Con<T>> createState() => _ConState<T>();
}

class _ConState<T> extends State<Con<T>> {
  late T _valor = widget.inicial;

  @override
  Widget build(BuildContext context) {
    return widget.construir(_valor, (nuevo) => setState(() => _valor = nuevo));
  }
}
