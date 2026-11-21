import '../widgets/foto_auto.dart';

/// Ficha tecnica de referencia de un modelo.
///
/// **Son datos del modelo, no de la unidad.** Lo que cambia segun el ano o la
/// version se escribe «Segun version»: nunca se inventa una cifra. La ficha de
/// cada unidad esta en su manual del propietario.
class FichaTecnica {
  const FichaTecnica({
    required this.carroceria,
    required this.pasajeros,
    required this.propulsion,
    required this.transmision,
    required this.traccion,
    required this.motor,
  });

  final String carroceria;
  final String pasajeros;
  final String propulsion;
  final String transmision;
  final String traccion;
  final String motor;
}

const _segun = 'Según versión';

/// Ficha tecnica de un modelo por su nombre, o `null` si no se tiene.
FichaTecnica? fichaDeModelo(String? modelo) => switch (claveDeModelo(modelo)) {
  'march' => const FichaTecnica(
    carroceria: 'Hatchback',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: 'Manual 5 vel. o CVT',
    traccion: 'Delantera',
    motor: '1.6 L, 4 cilindros',
  ),
  'versa' => const FichaTecnica(
    carroceria: 'Sedán',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: 'Manual 5 vel. o CVT',
    traccion: 'Delantera',
    motor: '1.6 L, 4 cilindros',
  ),
  'kicks' => const FichaTecnica(
    carroceria: 'SUV compacta',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: 'CVT',
    traccion: 'Delantera',
    motor: '1.6 L, 4 cilindros',
  ),
  'sentra' => const FichaTecnica(
    carroceria: 'Sedán',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: 'Manual 6 vel. o CVT',
    traccion: 'Delantera',
    motor: '2.0 L, 4 cilindros',
  ),
  'xtrail' => const FichaTecnica(
    carroceria: 'SUV mediana',
    pasajeros: '5 o 7 según versión',
    propulsion: 'Gasolina o e-Power',
    transmision: _segun,
    traccion: 'Delantera o 4x4',
    motor: _segun,
  ),
  'frontier' => const FichaTecnica(
    carroceria: 'Pick-up doble cabina',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: _segun,
    traccion: '4x2 o 4x4',
    motor: _segun,
  ),
  'leaf' => const FichaTecnica(
    carroceria: 'Hatchback',
    pasajeros: '5',
    propulsion: 'Eléctrico',
    transmision: 'Automática de una velocidad',
    traccion: 'Delantera',
    motor: 'Motor eléctrico, batería de iones de litio',
  ),
  'ariya' => const FichaTecnica(
    carroceria: 'SUV eléctrica',
    pasajeros: '5',
    propulsion: 'Eléctrico',
    transmision: 'Automática de una velocidad',
    traccion: 'Delantera o e-4ORCE (4x4)',
    motor: 'Motor eléctrico, batería de iones de litio',
  ),
  'z' => const FichaTecnica(
    carroceria: 'Coupé deportivo',
    pasajeros: '2',
    propulsion: 'Gasolina',
    transmision: 'Manual 6 vel. o automática 9 vel.',
    traccion: 'Trasera',
    motor: 'V6 3.0 L biturbo',
  ),
  'gtr' => const FichaTecnica(
    carroceria: 'Coupé deportivo',
    pasajeros: '4',
    propulsion: 'Gasolina',
    transmision: 'Automática 6 vel. de doble embrague',
    traccion: 'Integral',
    motor: 'V6 3.8 L biturbo',
  ),
  'altima' => const FichaTecnica(
    carroceria: 'Sedán',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: 'CVT',
    traccion: 'Delantera o integral',
    motor: _segun,
  ),
  'pathfinder' => const FichaTecnica(
    carroceria: 'SUV de tres filas',
    pasajeros: '7 u 8 según versión',
    propulsion: 'Gasolina',
    transmision: 'Automática',
    traccion: 'Delantera o 4x4',
    motor: _segun,
  ),
  'murano' => const FichaTecnica(
    carroceria: 'SUV mediana',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: _segun,
    traccion: 'Delantera o integral',
    motor: _segun,
  ),
  'armada' => const FichaTecnica(
    carroceria: 'SUV grande',
    pasajeros: '7 u 8 según versión',
    propulsion: 'Gasolina',
    transmision: 'Automática',
    traccion: '4x2 o 4x4',
    motor: _segun,
  ),
  'titan' => const FichaTecnica(
    carroceria: 'Pick-up grande',
    pasajeros: '5 o 6 según versión',
    propulsion: 'Gasolina',
    transmision: 'Automática',
    traccion: '4x2 o 4x4',
    motor: _segun,
  ),
  'urvan' => const FichaTecnica(
    carroceria: 'Van de pasajeros o carga',
    pasajeros: 'Según versión',
    propulsion: 'Gasolina',
    transmision: _segun,
    traccion: 'Trasera',
    motor: _segun,
  ),
  'maxima' => const FichaTecnica(
    carroceria: 'Sedán',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: 'CVT',
    traccion: 'Delantera',
    motor: 'V6 3.5 L',
  ),
  'juke' => const FichaTecnica(
    carroceria: 'SUV subcompacta',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: _segun,
    traccion: 'Delantera',
    motor: _segun,
  ),
  'qashqai' => const FichaTecnica(
    carroceria: 'Crossover compacto',
    pasajeros: '5',
    propulsion: 'Gasolina o e-Power',
    transmision: _segun,
    traccion: 'Delantera o integral',
    motor: _segun,
  ),
  'patrol' => const FichaTecnica(
    carroceria: 'SUV grande',
    pasajeros: '7 u 8 según versión',
    propulsion: 'Gasolina',
    transmision: 'Automática',
    traccion: '4x4',
    motor: _segun,
  ),
  'tiida' => const FichaTecnica(
    carroceria: 'Hatchback',
    pasajeros: '5',
    propulsion: 'Gasolina',
    transmision: 'Manual o CVT',
    traccion: 'Delantera',
    motor: _segun,
  ),
  'note' => const FichaTecnica(
    carroceria: 'Hatchback compacto',
    pasajeros: '5',
    propulsion: 'Híbrido e-Power',
    transmision: 'Automática de una velocidad',
    traccion: 'Delantera',
    motor: 'Motor eléctrico con generador de gasolina',
  ),
  _ => null,
};
