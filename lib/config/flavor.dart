/// Ambientes en los que se compila la app (V2-T01.04).
///
/// El nombre de cada valor es **exactamente** el del flavor de Android
/// (`productFlavors` en `android/app/build.gradle.kts`) y el del scheme de iOS,
/// así `flutter run --flavor desarrollo -t lib/main_desarrollo.dart` apunta a
/// lo mismo en las tres capas.
///
/// | Flavor | Nombre | Dirección por omisión | HTTP en claro | Certificados fijados |
/// | --- | --- | --- | --- | --- |
/// | `desarrollo` | CareCar Dev | mock local (`mock_api`, :3000) | sí | no |
/// | `pruebas` | CareCar Pruebas | backend en Azure | no | sí |
/// | `produccion` | CareCar | backend en Azure | no | sí |
///
/// `--dart-define=API_BASE_URL=...` sigue sobrescribiendo la dirección.
library;

enum Flavor {
  desarrollo(
    nombreApp: 'CareCar Dev',
    permiteHttpEnClaro: true,
    fijaCertificados: false,
    urlAndroid: 'http://10.0.2.2:3000/api/v1/app',
    urlOtras: 'http://localhost:3000/api/v1/app',
  ),
  pruebas(
    nombreApp: 'CareCar Pruebas',
    permiteHttpEnClaro: false,
    fijaCertificados: true,
    urlAndroid: _backendAzure,
    urlOtras: _backendAzure,
  ),
  produccion(
    nombreApp: 'CareCar',
    permiteHttpEnClaro: false,
    fijaCertificados: true,
    urlAndroid: _backendAzure,
    urlOtras: _backendAzure,
  );

  const Flavor({
    required this.nombreApp,
    required this.permiteHttpEnClaro,
    required this.fijaCertificados,
    required this._urlAndroid,
    required this._urlOtras,
  });

  /// Nombre que se ve bajo el ícono (debe coincidir con el nativo).
  final String nombreApp;

  /// Si el flavor puede hablar `http://`. Es lo mismo que el permiso nativo
  /// (`usesCleartextTraffic` en Android, ATS en iOS): solo `desarrollo`.
  final bool permiteHttpEnClaro;

  /// Si la app solo confía en los certificados fijados del servidor (V2-M22.04,
  /// `lib/config/pines_tls.dart`) en vez de en los del teléfono. `desarrollo`
  /// habla `http` con el simulador, así que no hay nada que fijar.
  final bool fijaCertificados;

  final String _urlAndroid;
  final String _urlOtras;

  /// Dirección usada si no se pasa `--dart-define=API_BASE_URL`.
  ///
  /// El emulador de Android ve la PC en `10.0.2.2`; el simulador de iOS y el
  /// resto, en `localhost`.
  String urlPorOmision({required bool esAndroid}) =>
      esAndroid ? _urlAndroid : _urlOtras;

  /// Flavor en ejecución. Lo fija `arrancar` en `main.dart`; si nadie lo fija
  /// (pruebas, `lib/main.dart` suelto) vale `produccion`, el más restrictivo.
  static Flavor actual = Flavor.produccion;
}

/// Backend real en Azure. Aún no hay un ambiente de pruebas separado: `pruebas`
/// comparte esta dirección y se separará pasando `API_BASE_URL` al compilar
/// cuando exista.
const String _backendAzure =
    'https://ca-agencia360-api.calmcliff-d0e7fc3b.eastus2.azurecontainerapps.io/api/v1/app';
