import 'package:flutter/widgets.dart';

import 'tokens/movimiento.dart';

/// Conecta los tokens de movimiento con la preferencia de accesibilidad
/// "reducir movimiento" del sistema.
extension MovimientoEnContexto on BuildContext {
  /// Devuelve el token tal cual, o su version de fundido corto cuando el
  /// sistema pide reducir movimiento.
  TokenMovimiento movimiento(TokenMovimiento token) {
    return token.paraAccesibilidad(
      reducir: MediaQuery.disableAnimationsOf(this),
    );
  }
}
