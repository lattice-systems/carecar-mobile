import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

/// Los botones que Material dibuja solo (regresar, cerrar, abrir menú) usan el
/// mismo set de íconos que el resto de la app (V2-T02.07).
final iconosDeAccion = ActionIconThemeData(
  backButtonIconBuilder: (_) => const Icon(LucideIcons300.chevronLeft),
  closeButtonIconBuilder: (_) => const Icon(LucideIcons300.x),
  drawerButtonIconBuilder: (_) => const Icon(LucideIcons300.menu),
  endDrawerButtonIconBuilder: (_) => const Icon(LucideIcons300.menu),
);
