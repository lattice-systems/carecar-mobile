import 'package:flutter/widgets.dart';

import 'analitica.dart';

/// Comparte el mismo envío con las pantallas v1 que aún no leen Riverpod.
class AmbitoAnalitica extends InheritedWidget {
  const AmbitoAnalitica({
    required this.analitica,
    required super.child,
    super.key,
  });

  final Analitica analitica;

  static Analitica? de(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AmbitoAnalitica>()?.analitica;

  @override
  bool updateShouldNotify(AmbitoAnalitica oldWidget) =>
      analitica != oldWidget.analitica;
}
