import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Calendario de un mes para elegir un dia, con dias sin cupo.
///
/// Es controlado: quien lo usa guarda `seleccionado` y `mes`. Los dias fuera
/// de `[primerDia, ultimoDia]` o para los que `habilitado` devuelve falso no se
/// pueden elegir y se tachan, ademas de bajar de tono, para no depender solo del
/// color. Cada dia mide 48 y se anuncia completo ("15 de noviembre, sin cupo").
/// La semana empieza en lunes.
class Calendario extends StatelessWidget {
  const Calendario({
    required this.mes,
    required this.seleccionado,
    required this.alSeleccionar,
    required this.alCambiarMes,
    required this.primerDia,
    required this.ultimoDia,
    super.key,
    this.habilitado,
    this.hoy,
    this.marcaDelDia,
  });

  /// Cualquier fecha del mes que se muestra.
  final DateTime mes;
  final DateTime? seleccionado;
  final ValueChanged<DateTime> alSeleccionar;
  final ValueChanged<DateTime> alCambiarMes;
  final DateTime primerDia;
  final DateTime ultimoDia;

  /// Devuelve falso para los dias sin cupo.
  final bool Function(DateTime dia)? habilitado;

  /// Dia que se marca como hoy. Se pasa para que las pruebas no dependan del
  /// reloj.
  final DateTime? hoy;

  /// Etiqueta accesible para los días que muestran un punto.
  final String? Function(DateTime dia)? marcaDelDia;

  static DateTime _solo(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _mismoDia(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;

  bool _puedeElegir(DateTime dia) {
    if (dia.isBefore(_solo(primerDia)) || dia.isAfter(_solo(ultimoDia))) {
      return false;
    }
    return habilitado?.call(dia) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    final primero = DateTime(mes.year, mes.month);
    final diasDelMes = DateTime(mes.year, mes.month + 1, 0).day;
    final relleno = primero.weekday - 1;
    final celdas = relleno + diasDelMes;
    final filas = (celdas / 7).ceil();

    final anterior = DateTime(mes.year, mes.month - 1);
    final siguiente = DateTime(mes.year, mes.month + 1);
    final inicioMes = DateTime(mes.year, mes.month);
    final hayAnterior = inicioMes.isAfter(
      DateTime(primerDia.year, primerDia.month),
    );
    final haySiguiente = !siguiente.isAfter(
      DateTime(ultimoDia.year, ultimoDia.month),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: AppLocalizations.of(context).calendarioDelMes(mes),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: hayAnterior ? () => alCambiarMes(anterior) : null,
                tooltip: AppLocalizations.of(context).calendarioMesAnterior,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(LucideIcons300.chevronLeft),
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    AppLocalizations.of(context).calendarioTituloMes(mes),
                    textAlign: TextAlign.center,
                    style: t.cuerpoFuerte.copyWith(color: c.texto),
                  ),
                ),
              ),
              IconButton(
                onPressed: haySiguiente ? () => alCambiarMes(siguiente) : null,
                tooltip: AppLocalizations.of(context).calendarioMesSiguiente,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(LucideIcons300.chevronRight),
              ),
            ],
          ),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final inicial in AppLocalizations.of(
                  context,
                ).calendarioInicialesDias.split(','))
                  Expanded(
                    child: Center(
                      child: Text(
                        inicial,
                        style: t.etiqueta.copyWith(color: c.textoSecundario),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Espaciado.e1),
          for (var fila = 0; fila < filas; fila++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _celda(context, fila * 7 + col - relleno + 1),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _celda(BuildContext context, int numero) {
    final diasDelMes = DateTime(mes.year, mes.month + 1, 0).day;
    if (numero < 1 || numero > diasDelMes) return const SizedBox(height: 48);

    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final dia = DateTime(mes.year, mes.month, numero);
    final elegible = _puedeElegir(dia);
    final elegido = _mismoDia(dia, seleccionado);
    final esHoy = _mismoDia(dia, hoy);
    final marca = marcaDelDia?.call(dia);

    final fondo = elegido ? c.acento : Colors.transparent;
    final colorTexto = elegido
        ? c.sobreAcento
        : (elegible ? c.texto : c.textoTerciario);

    final textos = AppLocalizations.of(context);
    final etiqueta = [
      textos.calendarioDia(dia),
      if (esHoy) textos.calendarioHoy,
      ?marca,
      if (elegido) textos.calendarioSeleccionado,
      if (!elegible) textos.calendarioSinCupo,
    ].join(', ');

    return Semantics(
      button: true,
      enabled: elegible,
      selected: elegido,
      label: etiqueta,
      onTap: elegible ? () => alSeleccionar(dia) : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: elegible ? () => alSeleccionar(dia) : null,
        borderRadius: Radios.bordePildora,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fondo,
                shape: BoxShape.circle,
                border: esHoy && !elegido
                    ? Border.all(color: c.acento, width: 2)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Text(
                      numero.toString(),
                      style: t.cuerpo.copyWith(
                        color: colorTexto,
                        decoration: elegible
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  if (marca != null)
                    Positioned(
                      bottom: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: elegido ? c.sobreAcento : c.acento,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox.square(dimension: 5),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
