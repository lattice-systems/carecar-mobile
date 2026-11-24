import '../../../api/modelos/comun.dart';
import '../dominio/etapa_taller.dart';
import '../dominio/orden_taller.dart';

/// Lee las ordenes del contrato (`OrdenEnCurso` y `OrdenEnVivo`). Las URL de
/// las evidencias llegan relativas al servidor y se resuelven con [base]. Lanza
/// [FormatException] si falta algo obligatorio.
class LecturaTaller {
  const LecturaTaller(this.base);

  final Uri base;

  OrdenEnCurso enCurso(Map<String, Object?> json) => OrdenEnCurso(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    vehiculo: leerTexto(json['vehiculo'], 'vehiculo'),
    etapa: _etapa(json['etapa']),
    avance: leerEntero(json['avance'], 'avance').clamp(0, 100),
    adicionalesPendientes: leerEntero(
      json['adicionalesPendientes'],
      'adicionalesPendientes',
    ),
    entregaEstimada: leerFechaHoraOpcional(
      json['entregaEstimada'],
      'entregaEstimada',
    ),
    asesor: _textoOpcional(json['asesor']),
  );

  OrdenEnVivo orden(Map<String, Object?> json) => OrdenEnVivo(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    vehiculo: leerTexto(json['vehiculo'], 'vehiculo'),
    etapa: _etapa(json['etapa']),
    avance: leerEntero(json['avance'], 'avance').clamp(0, 100),
    entregaEstimada: leerFechaHoraOpcional(
      json['entregaEstimada'],
      'entregaEstimada',
    ),
    asesor: _textoOpcional(json['asesor']),
    etapas: [
      for (final paso in _lista(json['etapas'], 'etapas'))
        if (EtapaTaller.desde(paso['etapa'] as String?) != null)
          PasoEtapa(
            etapa: _etapa(paso['etapa']),
            inicio: _fechaHora(paso['inicio'], 'inicio'),
            fin: leerFechaHoraOpcional(paso['fin'], 'fin'),
            nota: _textoOpcional(paso['nota']),
          ),
    ],
    inspeccion: [
      for (final punto in _lista(json['inspeccion'], 'inspeccion'))
        if (ResultadoInspeccion.desde(punto['resultado'] as String?)
            case final resultado?)
          PuntoRevisado(
            id: leerEntero(punto['id'], 'id'),
            punto: leerTexto(punto['punto'], 'punto'),
            resultado: resultado,
            comentario: _textoOpcional(punto['comentario']),
            evidencias: _evidencias(punto['evidencias']),
          ),
    ],
    evidencias: _evidencias(json['evidencias']),
    adicionales: [
      for (final adicional in _lista(json['adicionales'], 'adicionales'))
        if (EstadoAdicional.desde(adicional['estado'] as String?)
            case final estado?)
          TrabajoAdicional(
            id: leerEntero(adicional['id'], 'id'),
            concepto: leerTexto(adicional['concepto'], 'concepto'),
            manoDeObra: leerDecimal(adicional['manoDeObra'], 'manoDeObra'),
            refacciones: leerDecimal(adicional['refacciones'], 'refacciones'),
            total: leerDecimal(adicional['total'], 'total'),
            estado: estado,
            respondidoEn: leerFechaHoraOpcional(
              adicional['respondidoEn'],
              'respondidoEn',
            ),
          ),
    ],
    totalOrden: leerDecimal(json['totalOrden'], 'totalOrden'),
    totalAdicionalesAprobados: leerDecimal(
      json['totalAdicionalesAprobados'],
      'totalAdicionalesAprobados',
    ),
    totalAdicionalesPendientes: leerDecimal(
      json['totalAdicionalesPendientes'],
      'totalAdicionalesPendientes',
    ),
    totalEstimado: leerDecimal(json['totalEstimado'], 'totalEstimado'),
  );

  List<Evidencia> _evidencias(Object? valor) => [
    for (final evidencia in _lista(valor, 'evidencias'))
      if (TipoEvidencia.desde(evidencia['tipo'] as String?) case final tipo?)
        Evidencia(
          id: leerEntero(evidencia['id'], 'id'),
          tipo: tipo,
          url: base.resolve(leerTexto(evidencia['url'], 'url')),
        ),
  ];

  static EtapaTaller _etapa(Object? valor) {
    final etapa = EtapaTaller.desde(valor as String?);
    if (etapa == null) {
      throw FormatException('La etapa «$valor» no es del contrato.');
    }
    return etapa;
  }

  static DateTime _fechaHora(Object? valor, String campo) {
    final fecha = leerFechaHoraOpcional(valor, campo);
    if (fecha == null) throw FormatException('Falta el campo «$campo».');
    return fecha;
  }

  static List<Map<String, Object?>> _lista(Object? valor, String campo) {
    if (valor == null) return const [];
    if (valor is! List) {
      throw FormatException('El campo «$campo» no es una lista: $valor');
    }
    return [for (final e in valor) e as Map<String, Object?>];
  }

  static String? _textoOpcional(Object? valor) {
    final texto = (valor as String?)?.trim();
    return texto == null || texto.isEmpty ? null : texto;
  }
}
