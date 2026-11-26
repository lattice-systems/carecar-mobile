/// Tipo de contribuyente que dice el largo del RFC: 13 caracteres es persona
/// fisica y 12 es persona moral (V2-M08.05).
enum TipoPersona {
  fisica,
  moral;

  /// Lo que diga el largo del RFC ya normalizado; nulo si no es 12 ni 13.
  static TipoPersona? delRfc(String rfc) => switch (rfc.length) {
    12 => moral,
    13 => fisica,
    _ => null,
  };

  static TipoPersona desde(String? valor) => valor == 'MORAL' ? moral : fisica;
}

/// Una clave de `c_RegimenFiscal` de CFDI 4.0.
class RegimenFiscal {
  const RegimenFiscal({
    required this.clave,
    required this.descripcion,
    required this.fisica,
    required this.moral,
  });

  final String clave;
  final String descripcion;
  final bool fisica;
  final bool moral;

  bool aplicaA(TipoPersona persona) =>
      persona == TipoPersona.fisica ? fisica : moral;
}

/// Una clave de `c_UsoCFDI` con los regimenes del receptor que la aceptan.
class UsoCfdi {
  const UsoCfdi({
    required this.clave,
    required this.descripcion,
    required this.fisica,
    required this.moral,
    required this.regimenes,
  });

  final String clave;
  final String descripcion;
  final bool fisica;
  final bool moral;
  final Set<String> regimenes;

  bool aplicaA(TipoPersona persona) =>
      persona == TipoPersona.fisica ? fisica : moral;

  bool aceptaRegimen(String regimen) => regimenes.contains(regimen);
}

/// Los catalogos del SAT que da el servidor (`GET /catalogos-fiscales`): la
/// app ofrece solo las combinaciones que el servidor acepta.
class CatalogoFiscal {
  const CatalogoFiscal({required this.regimenes, required this.usosCfdi});

  final List<RegimenFiscal> regimenes;
  final List<UsoCfdi> usosCfdi;

  RegimenFiscal? regimen(String? clave) =>
      regimenes.where((r) => r.clave == clave).firstOrNull;

  UsoCfdi? uso(String? clave) =>
      usosCfdi.where((u) => u.clave == clave).firstOrNull;

  /// Los regimenes de esa persona; todos si todavia no se sabe.
  List<RegimenFiscal> regimenesPara(TipoPersona? persona) => persona == null
      ? regimenes
      : regimenes.where((r) => r.aplicaA(persona)).toList();

  /// Los usos de esa persona que acepta ese regimen; sin regimen, los de la
  /// persona.
  List<UsoCfdi> usosPara(TipoPersona? persona, String? regimen) => usosCfdi
      .where((u) => persona == null || u.aplicaA(persona))
      .where((u) => regimen == null || u.aceptaRegimen(regimen))
      .toList();
}

/// Datos fiscales guardados del cliente (tabla `perfil_fiscal`).
class PerfilFiscal {
  const PerfilFiscal({
    required this.id,
    required this.rfc,
    required this.tipoPersona,
    required this.razonSocial,
    required this.regimenFiscal,
    required this.codigoPostal,
    required this.usoCfdi,
    required this.predeterminado,
    required this.creadoEn,
    this.correo,
  });

  final int id;
  final String rfc;
  final TipoPersona tipoPersona;
  final String razonSocial;
  final String regimenFiscal;
  final String codigoPostal;
  final String usoCfdi;
  final String? correo;
  final bool predeterminado;
  final DateTime creadoEn;
}

/// Los campos de un perfil fiscal, con su nombre en la API.
enum CampoFiscal {
  rfc('rfc'),
  razonSocial('razonSocial'),
  codigoPostal('codigoPostal'),
  regimenFiscal('regimenFiscal'),
  usoCfdi('usoCfdi'),
  correo('correo');

  const CampoFiscal(this.enLaApi);

  final String enLaApi;

  static CampoFiscal? desde(String nombre) =>
      values.where((c) => c.enLaApi == nombre).firstOrNull;
}

/// Por que un campo no sirve; la presentacion lo vuelve texto.
enum MotivoFiscal {
  rfcVacio,
  rfcLargo,
  rfcForma,
  rfcGenerico,
  rfcFecha,
  rfcDigito,
  razonSocialVacia,
  razonSocialLarga,
  codigoPostal,
  regimenFalta,
  regimenNoAplica,
  usoFalta,
  usoNoAplica,
  usoNoAceptaRegimen,
  correo,
}

/// Reglas del RFC del SAT, las mismas que aplica el servidor: largo, forma,
/// fecha real y digito verificador (modulo 11). Los genericos no sirven para
/// un perfil propio.
abstract final class ReglasRfc {
  static final _forma = RegExp(
    r'^([A-ZÑ&]{3,4})([0-9]{2})([0-9]{2})([0-9]{2})([A-Z0-9]{2})([0-9A])$',
  );
  static const _valores = '0123456789ABCDEFGHIJKLMN&OPQRSTUVWXYZ Ñ';
  static const _diasDelMes = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Sin espacios alrededor y en mayusculas.
  static String normalizar(String rfc) => rfc.trim().toUpperCase();

  /// Por que el RFC (ya normalizado) no sirve; nulo si sirve.
  static MotivoFiscal? problema(String rfc) {
    if (rfc.isEmpty) return MotivoFiscal.rfcVacio;
    if (rfc.length != 12 && rfc.length != 13) return MotivoFiscal.rfcLargo;
    final partes = _forma.firstMatch(rfc);
    if (partes == null || partes.group(1)!.length != rfc.length - 9) {
      return MotivoFiscal.rfcForma;
    }
    if (rfc == 'XAXX010101000' || rfc == 'XEXX010101000') {
      return MotivoFiscal.rfcGenerico;
    }
    final anio = int.parse(partes.group(2)!);
    final mes = int.parse(partes.group(3)!);
    final dia = int.parse(partes.group(4)!);
    if (!_fechaValida(anio, mes, dia)) return MotivoFiscal.rfcFecha;
    if (digitoVerificador(rfc) != rfc[rfc.length - 1]) {
      return MotivoFiscal.rfcDigito;
    }
    return null;
  }

  /// Cada uno de los primeros 12 caracteres (con un espacio al inicio si es
  /// persona moral) por su peso del 13 al 2, modulo 11.
  static String digitoVerificador(String rfc) {
    final completo = rfc.length == 12 ? ' $rfc' : rfc;
    var suma = 0;
    for (var i = 0; i < 12; i++) {
      suma += _valores.indexOf(completo[i]) * (13 - i);
    }
    final residuo = suma % 11;
    if (residuo == 0) return '0';
    final digito = 11 - residuo;
    return digito == 10 ? 'A' : '$digito';
  }

  static bool _fechaValida(int anio, int mes, int dia) {
    if (mes < 1 || mes > 12 || dia < 1 || dia > _diasDelMes[mes - 1]) {
      return false;
    }
    return mes != 2 || dia != 29 || anio % 4 == 0;
  }
}

/// Lo que se captura en el formulario, antes de enviarlo. [errores] aplica las
/// mismas reglas que el servidor para marcar los campos sin esperar la red.
class BorradorPerfilFiscal {
  const BorradorPerfilFiscal({
    required this.rfc,
    required this.razonSocial,
    required this.codigoPostal,
    this.regimenFiscal,
    this.usoCfdi,
    this.correo = '',
    this.predeterminado = false,
  });

  static const maxRazonSocial = 254;
  static const maxCorreo = 254;
  static final _codigoPostal = RegExp(r'^[0-9]{5}$');
  static final _correo = RegExp(r'^[^@\s]+@[^@\s.]+(\.[^@\s.]+)+$');

  final String rfc;
  final String razonSocial;
  final String codigoPostal;
  final String? regimenFiscal;
  final String? usoCfdi;
  final String correo;
  final bool predeterminado;

  String get rfcNormalizado => ReglasRfc.normalizar(rfc);

  /// La persona que dice el RFC, aunque todavia no sea valido; nula si el
  /// largo no alcanza.
  TipoPersona? get tipoPersona => TipoPersona.delRfc(rfcNormalizado);

  Map<CampoFiscal, MotivoFiscal> errores(CatalogoFiscal catalogo) {
    final errores = <CampoFiscal, MotivoFiscal>{};
    final rfc = rfcNormalizado;
    final delRfc = ReglasRfc.problema(rfc);
    if (delRfc != null) errores[CampoFiscal.rfc] = delRfc;
    final persona = delRfc == null ? TipoPersona.delRfc(rfc) : null;

    final razon = razonSocial.trim();
    if (razon.isEmpty) {
      errores[CampoFiscal.razonSocial] = MotivoFiscal.razonSocialVacia;
    } else if (razon.length > maxRazonSocial) {
      errores[CampoFiscal.razonSocial] = MotivoFiscal.razonSocialLarga;
    }

    if (!_codigoPostal.hasMatch(codigoPostal.trim())) {
      errores[CampoFiscal.codigoPostal] = MotivoFiscal.codigoPostal;
    }

    final regimen = catalogo.regimen(regimenFiscal);
    if (regimen == null) {
      errores[CampoFiscal.regimenFiscal] = MotivoFiscal.regimenFalta;
    } else if (persona != null && !regimen.aplicaA(persona)) {
      errores[CampoFiscal.regimenFiscal] = MotivoFiscal.regimenNoAplica;
    }

    final uso = catalogo.uso(usoCfdi);
    if (uso == null) {
      errores[CampoFiscal.usoCfdi] = MotivoFiscal.usoFalta;
    } else if (persona != null && !uso.aplicaA(persona)) {
      errores[CampoFiscal.usoCfdi] = MotivoFiscal.usoNoAplica;
    } else if (regimen != null && !uso.aceptaRegimen(regimen.clave)) {
      errores[CampoFiscal.usoCfdi] = MotivoFiscal.usoNoAceptaRegimen;
    }

    final mail = correo.trim();
    if (mail.isNotEmpty &&
        (mail.length > maxCorreo || !_correo.hasMatch(mail))) {
      errores[CampoFiscal.correo] = MotivoFiscal.correo;
    }
    return errores;
  }
}
