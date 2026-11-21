import '../widgets/foto_auto.dart';

/// Ficha tecnica de un modelo, segun su generacion y su version.
///
/// Son los datos de la configuracion principal de ese modelo en ese ano; la
/// ficha exacta de cada unidad esta en su manual del propietario.
class FichaTecnica {
  const FichaTecnica({
    required this.carroceria,
    required this.pasajeros,
    required this.propulsion,
    required this.motor,
    required this.potencia,
    required this.transmision,
    required this.traccion,
  });

  final String carroceria;
  final String pasajeros;
  final String propulsion;
  final String motor;
  final String potencia;
  final String transmision;
  final String traccion;
}

const _cvt = 'CVT Xtronic';
const _delantera = 'Delantera';

/// Ficha tecnica de un modelo por su nombre, ano y version.
///
/// El ano y la version deciden la generacion y la caja cuando cambian (p. ej.
/// el Versa 2020 estrena motor y la PRO-4X usa V6). Devuelve `null` solo si el
/// modelo no es uno de los del catalogo.
FichaTecnica? fichaDeModelo(String? modelo, {int? anio, String? version}) {
  final a = anio ?? 2026;
  final ver = (version ?? '').toLowerCase();
  final manual = ver.contains('sense');

  return switch (claveDeModelo(modelo)) {
    'march' => FichaTecnica(
      carroceria: 'Hatchback',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: '1.6 L, 4 cilindros',
      potencia: '106 hp a 6,000 rpm',
      transmision: manual ? 'Manual de 5 velocidades' : _cvt,
      traccion: _delantera,
    ),
    'versa' => FichaTecnica(
      carroceria: 'Sedán',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: '1.6 L, 4 cilindros',
      potencia: a >= 2020 ? '118 hp a 6,300 rpm' : '106 hp a 5,600 rpm',
      transmision: manual ? 'Manual de 5 velocidades' : _cvt,
      traccion: _delantera,
    ),
    'kicks' => const FichaTecnica(
      carroceria: 'SUV compacta',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: '1.6 L, 4 cilindros',
      potencia: '118 hp a 6,300 rpm',
      transmision: _cvt,
      traccion: _delantera,
    ),
    'sentra' => FichaTecnica(
      carroceria: 'Sedán',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: a >= 2020 ? '2.0 L, 4 cilindros' : '1.8 L, 4 cilindros',
      potencia: a >= 2020 ? '149 hp a 6,400 rpm' : '130 hp a 6,300 rpm',
      transmision: manual ? 'Manual de 6 velocidades' : _cvt,
      traccion: _delantera,
    ),
    'xtrail' when a >= 2023 => const FichaTecnica(
      carroceria: 'SUV mediana',
      pasajeros: '5',
      propulsion: 'Híbrido e-Power',
      motor: '1.5 L turbo (generador) y motor eléctrico',
      potencia: '204 hp',
      transmision: 'Automática de una velocidad',
      traccion: _delantera,
    ),
    'xtrail' => FichaTecnica(
      carroceria: 'SUV mediana',
      pasajeros: manual ? '5' : '7',
      propulsion: 'Gasolina',
      motor: '2.5 L, 4 cilindros',
      potencia: '170 hp a 6,000 rpm',
      transmision: _cvt,
      traccion: ver.contains('exclusive') ? 'Integral (AWD)' : _delantera,
    ),
    'frontier' when a >= 2022 && ver.contains('pro-4x') => const FichaTecnica(
      carroceria: 'Pick-up doble cabina',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: 'V6 3.8 L',
      potencia: '310 hp a 6,400 rpm',
      transmision: 'Automática de 9 velocidades',
      traccion: '4x4',
    ),
    'frontier' => const FichaTecnica(
      carroceria: 'Pick-up doble cabina',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: '2.5 L, 4 cilindros',
      potencia: '164 hp a 6,000 rpm',
      transmision: 'Manual de 6 velocidades',
      traccion: '4x2',
    ),
    'leaf' => FichaTecnica(
      carroceria: 'Hatchback',
      pasajeros: '5',
      propulsion: 'Eléctrico',
      motor: ver.contains('e+')
          ? 'Motor eléctrico, batería de 62 kWh'
          : 'Motor eléctrico, batería de 40 kWh',
      potencia: ver.contains('e+') ? '214 hp' : '147 hp',
      transmision: 'Automática de una velocidad',
      traccion: _delantera,
    ),
    'ariya' => const FichaTecnica(
      carroceria: 'SUV eléctrica',
      pasajeros: '5',
      propulsion: 'Eléctrico',
      motor: 'Motor eléctrico, batería de 87 kWh',
      potencia: '238 hp',
      transmision: 'Automática de una velocidad',
      traccion: _delantera,
    ),
    'z' => const FichaTecnica(
      carroceria: 'Coupé deportivo',
      pasajeros: '2',
      propulsion: 'Gasolina',
      motor: 'V6 3.0 L biturbo',
      potencia: '400 hp a 6,400 rpm',
      transmision: 'Manual de 6 velocidades',
      traccion: 'Trasera',
    ),
    'gtr' => const FichaTecnica(
      carroceria: 'Coupé deportivo',
      pasajeros: '4',
      propulsion: 'Gasolina',
      motor: 'V6 3.8 L biturbo',
      potencia: '565 hp a 6,800 rpm',
      transmision: 'Automática de 6 velocidades, doble embrague',
      traccion: 'Integral (ATTESA E-TS)',
    ),
    'altima' => const FichaTecnica(
      carroceria: 'Sedán',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: '2.5 L, 4 cilindros',
      potencia: '188 hp a 6,000 rpm',
      transmision: _cvt,
      traccion: _delantera,
    ),
    'pathfinder' => const FichaTecnica(
      carroceria: 'SUV de tres filas',
      pasajeros: '7',
      propulsion: 'Gasolina',
      motor: 'V6 3.5 L',
      potencia: '284 hp a 6,400 rpm',
      transmision: 'Automática de 9 velocidades',
      traccion: '4x4',
    ),
    'murano' => const FichaTecnica(
      carroceria: 'SUV mediana',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: 'V6 3.5 L',
      potencia: '260 hp a 6,000 rpm',
      transmision: _cvt,
      traccion: 'Integral (AWD)',
    ),
    'armada' => const FichaTecnica(
      carroceria: 'SUV grande',
      pasajeros: '7',
      propulsion: 'Gasolina',
      motor: 'V6 3.5 L biturbo',
      potencia: '425 hp',
      transmision: 'Automática de 9 velocidades',
      traccion: '4x4',
    ),
    'titan' => const FichaTecnica(
      carroceria: 'Pick-up grande',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: 'V8 5.6 L',
      potencia: '400 hp a 5,800 rpm',
      transmision: 'Automática de 9 velocidades',
      traccion: '4x4',
    ),
    'urvan' => const FichaTecnica(
      carroceria: 'Van de carga (Panel)',
      pasajeros: '3',
      propulsion: 'Gasolina',
      motor: '2.5 L, 4 cilindros',
      potencia: '126 hp a 5,600 rpm',
      transmision: 'Manual de 5 velocidades',
      traccion: 'Trasera',
    ),
    'maxima' => const FichaTecnica(
      carroceria: 'Sedán',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: 'V6 3.5 L',
      potencia: '300 hp a 6,400 rpm',
      transmision: _cvt,
      traccion: _delantera,
    ),
    'juke' => const FichaTecnica(
      carroceria: 'SUV subcompacta',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: '1.0 L turbo, 3 cilindros',
      potencia: '117 hp a 5,250 rpm',
      transmision: 'Automática de 7 velocidades, doble embrague',
      traccion: _delantera,
    ),
    'qashqai' => const FichaTecnica(
      carroceria: 'Crossover compacto',
      pasajeros: '5',
      propulsion: 'Gasolina (híbrido ligero)',
      motor: '1.3 L turbo, 4 cilindros',
      potencia: '158 hp',
      transmision: _cvt,
      traccion: _delantera,
    ),
    'patrol' when a >= 2025 => const FichaTecnica(
      carroceria: 'SUV grande',
      pasajeros: '7',
      propulsion: 'Gasolina',
      motor: 'V6 3.5 L biturbo',
      potencia: '425 hp',
      transmision: 'Automática de 9 velocidades',
      traccion: '4x4',
    ),
    'patrol' => const FichaTecnica(
      carroceria: 'SUV grande',
      pasajeros: '8',
      propulsion: 'Gasolina',
      motor: 'V8 5.6 L',
      potencia: '400 hp a 5,800 rpm',
      transmision: 'Automática de 7 velocidades',
      traccion: '4x4',
    ),
    'tiida' => FichaTecnica(
      carroceria: 'Hatchback',
      pasajeros: '5',
      propulsion: 'Gasolina',
      motor: '1.8 L, 4 cilindros',
      potencia: '126 hp a 6,000 rpm',
      transmision: manual ? 'Manual de 6 velocidades' : _cvt,
      traccion: _delantera,
    ),
    'note' => const FichaTecnica(
      carroceria: 'Hatchback compacto',
      pasajeros: '5',
      propulsion: 'Híbrido e-Power',
      motor: '1.2 L, 3 cilindros (generador) y motor eléctrico',
      potencia: '116 hp',
      transmision: 'Automática de una velocidad',
      traccion: _delantera,
    ),
    _ => null,
  };
}
