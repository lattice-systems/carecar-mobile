import 'config/flavor.dart';
import 'main.dart';

/// Entrada del flavor `desarrollo` (V2-T01.04):
/// `flutter run --flavor desarrollo -t lib/main_desarrollo.dart`.
Future<void> main() => arrancar(Flavor.desarrollo);
