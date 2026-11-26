import '../../../api/modelos/comun.dart';
import '../dominio/lealtad.dart';

/// Lee lealtad del contrato (`ResumenLealtad`, `PaginaMovimientosPuntos`,
/// `Recompensa`, `Canje` y `Referido`). Lanza [FormatException] si falta algo
/// obligatorio.
class LecturaLealtad {
  const LecturaLealtad();

  ResumenLealtad resumen(Map<String, Object?> json) => ResumenLealtad(
    saldo: leerEntero(json['saldo'], 'saldo'),
    nivel: NivelLealtad.desde(json['nivel'] as String?),
    ganados: leerEntero(json['ganados'], 'ganados'),
    siguienteNivel: NivelLealtad.desdeOpcional(
      json['siguienteNivel'] as String?,
    ),
    puntosParaSiguiente: leerEntero(
      json['puntosParaSiguiente'],
      'puntosParaSiguiente',
    ),
    codigoReferido: leerTexto(json['codigoReferido'], 'codigoReferido'),
  );

  PaginaMovimientos pagina(Map<String, Object?> json) {
    final pagina = leerEntero(json['pagina'], 'pagina');
    final total = leerEntero(json['totalPaginas'], 'totalPaginas');
    final contenido = json['contenido'];
    if (contenido is! List) {
      throw const FormatException('El campo «contenido» no es una lista');
    }
    return PaginaMovimientos(
      movimientos: [
        for (final elemento in contenido)
          if (elemento is Map<String, Object?>)
            movimiento(elemento)
          else
            throw const FormatException('Un movimiento no es un objeto'),
      ],
      pagina: pagina,
      hayMas: pagina + 1 < total,
    );
  }

  MovimientoPuntos movimiento(Map<String, Object?> json) => MovimientoPuntos(
    id: leerEntero(json['id'], 'id'),
    puntos: leerEntero(json['puntos'], 'puntos'),
    motivo: MotivoPuntos.desde(json['motivo'] as String?),
    referenciaTipo: json['referenciaTipo'] as String?,
    referenciaId: leerEnteroOpcional(json['referenciaId'], 'referenciaId'),
    creadoEn: leerMomentoUtc(json['creadoEn'], 'creadoEn'),
  );

  Recompensa recompensa(Map<String, Object?> json) => Recompensa(
    id: leerEntero(json['id'], 'id'),
    nombre: leerTexto(json['nombre'], 'nombre'),
    descripcion: json['descripcion'] as String?,
    puntos: leerEntero(json['puntos'], 'puntos'),
    existencia: leerEnteroOpcional(json['existencia'], 'existencia'),
  );

  Canje canje(Map<String, Object?> json) => Canje(
    id: leerEntero(json['id'], 'id'),
    codigo: leerTexto(json['codigo'], 'codigo'),
    recompensa: leerTexto(json['recompensa'], 'recompensa'),
    puntos: leerEntero(json['puntos'], 'puntos'),
    estado: EstadoCanje.desde(json['estado'] as String?),
    venceEn: leerMomentoUtc(json['venceEn'], 'venceEn'),
    usadoEn: json['usadoEn'] == null
        ? null
        : leerMomentoUtc(json['usadoEn'], 'usadoEn'),
    creadoEn: leerMomentoUtc(json['creadoEn'], 'creadoEn'),
  );

  Referido referido(Map<String, Object?> json) => Referido(
    id: leerEntero(json['id'], 'id'),
    nombre: leerTexto(json['nombre'], 'nombre'),
    estado: EstadoReferido.desde(json['estado'] as String?),
    puntos: leerEntero(json['puntos'], 'puntos'),
    creadoEn: leerMomentoUtc(json['creadoEn'], 'creadoEn'),
  );
}
