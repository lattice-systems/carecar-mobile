import 'pagos.dart';

/// Que responde el banco simulado con una tarjeta de prueba (ADR 0009).
enum EscenarioTarjeta {
  aprobada,
  fondosInsuficientes,
  pideConfirmar,
  confirmacionFalla,
}

/// Una de las tarjetas de prueba del procesador simulado. La app solo acepta
/// estas, para que nadie escriba una real por error, y al servidor solo le
/// manda su `token`.
class TarjetaDePrueba {
  const TarjetaDePrueba({
    required this.numero,
    required this.token,
    required this.marca,
    required this.tipo,
    required this.escenario,
  });

  final String numero;
  final String token;
  final String marca;
  final TipoTarjeta tipo;
  final EscenarioTarjeta escenario;

  String get ultimos4 => numero.substring(numero.length - 4);
}

/// Las mismas del backend (`TarjetaDePrueba.java`), con su numero.
const tarjetasDePrueba = <TarjetaDePrueba>[
  TarjetaDePrueba(
    numero: '4242424242424242',
    token: 'tok_sim_visa',
    marca: 'VISA',
    tipo: TipoTarjeta.credito,
    escenario: EscenarioTarjeta.aprobada,
  ),
  TarjetaDePrueba(
    numero: '5555555555554444',
    token: 'tok_sim_mastercard',
    marca: 'MASTERCARD',
    tipo: TipoTarjeta.credito,
    escenario: EscenarioTarjeta.aprobada,
  ),
  TarjetaDePrueba(
    numero: '4000056655665556',
    token: 'tok_sim_visa_debito',
    marca: 'VISA',
    tipo: TipoTarjeta.debito,
    escenario: EscenarioTarjeta.aprobada,
  ),
  TarjetaDePrueba(
    numero: '4000000000009995',
    token: 'tok_sim_fondos_insuficientes',
    marca: 'VISA',
    tipo: TipoTarjeta.credito,
    escenario: EscenarioTarjeta.fondosInsuficientes,
  ),
  TarjetaDePrueba(
    numero: '4000000000003220',
    token: 'tok_sim_3ds',
    marca: 'VISA',
    tipo: TipoTarjeta.credito,
    escenario: EscenarioTarjeta.pideConfirmar,
  ),
  TarjetaDePrueba(
    numero: '4000008400001629',
    token: 'tok_sim_3ds_falla',
    marca: 'VISA',
    tipo: TipoTarjeta.credito,
    escenario: EscenarioTarjeta.confirmacionFalla,
  ),
];

/// Reglas de una tarjeta que se revisan en el telefono antes de cobrar.
abstract final class ReglasTarjeta {
  static const largoNumero = 16;
  static const largoCvv = 3;
  static const aniosMaximos = 20;

  static String soloDigitos(String texto) =>
      texto.replaceAll(RegExp(r'[^0-9]'), '');

  /// Algoritmo de Luhn: el digito final cuadra con los demas.
  static bool luhn(String digitos) {
    if (digitos.isEmpty || digitos.contains(RegExp(r'[^0-9]'))) return false;
    var suma = 0;
    for (var i = 0; i < digitos.length; i++) {
      var digito = digitos.codeUnitAt(digitos.length - 1 - i) - 48;
      if (i.isOdd) {
        digito *= 2;
        if (digito > 9) digito -= 9;
      }
      suma += digito;
    }
    return suma % 10 == 0;
  }

  /// La tarjeta de prueba con ese numero, sin importar espacios.
  static TarjetaDePrueba? deNumero(String texto) {
    final digitos = soloDigitos(texto);
    for (final tarjeta in tarjetasDePrueba) {
      if (tarjeta.numero == digitos) return tarjeta;
    }
    return null;
  }

  /// `MM/AA` como mes y año de cuatro cifras; nulo si no tiene esa forma.
  static ({int mes, int anio})? vencimiento(String texto) {
    final forma = RegExp(r'^\s*(\d{2})\s*/\s*(\d{2})\s*$').firstMatch(texto);
    if (forma == null) return null;
    final mes = int.parse(forma.group(1)!);
    if (mes < 1 || mes > 12) return null;
    return (mes: mes, anio: 2000 + int.parse(forma.group(2)!));
  }

  /// Una tarjeta vence al terminar su mes.
  static bool vencida(int mes, int anio, DateTime hoy) =>
      anio < hoy.year || (anio == hoy.year && mes < hoy.month);

  /// Los digitos en grupos de cuatro, como vienen impresos.
  static String agrupar(String digitos) {
    final grupos = <String>[];
    for (var i = 0; i < digitos.length; i += 4) {
      grupos.add(
        digitos.substring(i, i + 4 > digitos.length ? digitos.length : i + 4),
      );
    }
    return grupos.join(' ');
  }
}

/// Que campo de la tarjeta no sirve.
enum CampoTarjeta { numero, vencimiento, cvv }

/// Por que no sirve.
enum MotivoTarjeta {
  numeroVacio,
  numeroIncompleto,
  numeroInvalido,
  noEsDePrueba,
  vencimientoVacio,
  vencimientoInvalido,
  vencida,
  cvvInvalido,
}

/// Lo que la persona va escribiendo de una tarjeta nueva. El numero y el CVV
/// solo viven en el telefono: al servidor va el token.
class BorradorTarjeta {
  const BorradorTarjeta({
    this.numero = '',
    this.vencimiento = '',
    this.cvv = '',
    this.guardar = false,
  });

  final String numero;
  final String vencimiento;
  final String cvv;
  final bool guardar;

  TarjetaDePrueba? get tarjeta => ReglasTarjeta.deNumero(numero);

  Map<CampoTarjeta, MotivoTarjeta> errores(DateTime hoy) {
    final errores = <CampoTarjeta, MotivoTarjeta>{};
    final digitos = ReglasTarjeta.soloDigitos(numero);
    if (digitos.isEmpty) {
      errores[CampoTarjeta.numero] = MotivoTarjeta.numeroVacio;
    } else if (digitos.length < ReglasTarjeta.largoNumero) {
      errores[CampoTarjeta.numero] = MotivoTarjeta.numeroIncompleto;
    } else if (!ReglasTarjeta.luhn(digitos)) {
      errores[CampoTarjeta.numero] = MotivoTarjeta.numeroInvalido;
    } else if (tarjeta == null) {
      errores[CampoTarjeta.numero] = MotivoTarjeta.noEsDePrueba;
    }
    final fecha = ReglasTarjeta.vencimiento(vencimiento);
    if (vencimiento.trim().isEmpty) {
      errores[CampoTarjeta.vencimiento] = MotivoTarjeta.vencimientoVacio;
    } else if (fecha == null ||
        fecha.anio > hoy.year + ReglasTarjeta.aniosMaximos) {
      errores[CampoTarjeta.vencimiento] = MotivoTarjeta.vencimientoInvalido;
    } else if (ReglasTarjeta.vencida(fecha.mes, fecha.anio, hoy)) {
      errores[CampoTarjeta.vencimiento] = MotivoTarjeta.vencida;
    }
    if (!RegExp(r'^\d{3}$').hasMatch(cvv.trim())) {
      errores[CampoTarjeta.cvv] = MotivoTarjeta.cvvInvalido;
    }
    return errores;
  }
}

/// La tarjeta no paso las reglas; nada salio del telefono.
class TarjetaInvalida implements Exception {
  const TarjetaInvalida(this.errores);

  final Map<CampoTarjeta, MotivoTarjeta> errores;

  @override
  String toString() => 'TarjetaInvalida($errores)';
}

/// Convierte una tarjeta escrita en lo que se manda al servidor. La simulada
/// es la unica; una real seria otra implementacion con su ADR (ADR 0009).
abstract interface class PasarelaPago {
  /// Lanza [TarjetaInvalida] si no pasa las reglas.
  TarjetaNueva tokenizar(BorradorTarjeta borrador, DateTime hoy);
}
