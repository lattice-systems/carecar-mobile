import 'config/flavor.dart';
import 'main.dart';

/// Entrada del flavor `produccion` (V2-T01.04):
/// `flutter run --flavor produccion -t lib/main_produccion.dart`.
Future<void> main() => arrancar(Flavor.produccion);
