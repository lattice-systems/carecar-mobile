import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../modulos/catalogo/catalogo.dart';
import '../../modulos/ejemplo/ejemplo.dart';
import '../../modulos/galeria/galeria.dart';
import 'rutas_del_nucleo.dart';

/// UNICO lugar donde se juntan las rutas de todos los modulos (V2-T01.03).
///
/// Es un archivo caliente a proposito pequeno: cada modulo publica su lista de
/// `RouteBase` en su `<modulo>.dart` y aqui solo se agrega UNA linea por
/// modulo. Las rutas de los modulos exigen sesion por defecto (ver
/// `Rutas.publicas`). Guia: `lib/modulos/README.md`.
///
/// Es el unico archivo de `nucleo/` que importa modulos, y solo su contrato
/// publico (`<modulo>.dart`).
List<RouteBase> rutasDeLaApp() => [
  ...rutasDelNucleo(),
  // --- Un renglon por modulo, en orden alfabetico ---
  ...rutasCatalogo,
  // El ejemplo es solo para desarrollo; se elimina en V2-T01.07.
  if (kDebugMode) ...rutasEjemplo,
  // La galeria del sistema de diseno es solo para desarrollo (V2-T02.06).
  // Cuando exista el flavor `desarrollo` (V2-T01.04) se condiciona a el.
  if (kDebugMode) ...rutasGaleria,
];
