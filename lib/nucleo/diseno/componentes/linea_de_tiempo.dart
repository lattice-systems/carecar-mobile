import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/tokens_pista.dart';

/// Estado de un paso de la [LineaDeTiempo].
enum EstadoPaso { hecho, actual, pendiente }

/// Un paso de la linea de tiempo. `hora` ya viene formateada, por ejemplo
/// "10:30". `nota` es un detalle opcional bajo el titulo, como una ETA.
class PasoLinea {
  const PasoLinea({
    required this.titulo,
    required this.estado,
    this.hora,
    this.nota,
  });

  final String titulo;
  final EstadoPaso estado;
  final String? hora;
  final String? nota;

  String get _estadoTexto => switch (estado) {
    EstadoPaso.hecho => 'completado',
    EstadoPaso.actual => 'en curso',
    EstadoPaso.pendiente => 'pendiente',
  };
}

/// Linea de tiempo vertical de pasos, por ejemplo las etapas de una orden de
/// servicio.
///
/// El paso actual "respira" con un halo suave; con "reducir movimiento" se
/// queda quieto. El estado no depende del color: cada paso lleva su icono y el
/// lector de pantalla lo dice ("Diagnostico, completado, 10:30").
class LineaDeTiempo extends StatelessWidget {
  const LineaDeTiempo({required this.pasos, super.key});

  final List<PasoLinea> pasos;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        children: [
          for (var i = 0; i < pasos.length; i++)
            _Paso(
              paso: pasos[i],
              esUltimo: i == pasos.length - 1,
              posicion: i + 1,
              total: pasos.length,
            ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({
    required this.paso,
    required this.esUltimo,
    required this.posicion,
    required this.total,
  });

  final PasoLinea paso;
  final bool esUltimo;
  final int posicion;
  final int total;

  static const double _punto = 28;
  static const double _anchoLinea = 2;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final hecho = paso.estado == EstadoPaso.hecho;
    final actual = paso.estado == EstadoPaso.actual;

    final colorTitulo = paso.estado == EstadoPaso.pendiente
        ? c.textoSecundario
        : c.texto;

    final partes = [
      paso.titulo,
      paso._estadoTexto,
      ?paso.hora,
      ?paso.nota,
      'paso $posicion de $total',
    ];

    return Semantics(
      container: true,
      label: partes.join(', '),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _punto + Espaciado.e2,
              child: Column(
                children: [
                  _Punto(estado: paso.estado),
                  if (!esUltimo)
                    Expanded(
                      child: Container(
                        width: _anchoLinea,
                        color: hecho ? c.acento : c.borde,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: esUltimo ? 0 : Espaciado.e4,
                  left: Espaciado.e2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            paso.titulo,
                            style: (actual ? t.cuerpoFuerte : t.cuerpo)
                                .copyWith(color: colorTitulo),
                          ),
                        ),
                        if (paso.hora != null) ...[
                          const SizedBox(width: Espaciado.e2),
                          Text(
                            paso.hora!,
                            style: t.etiqueta.copyWith(
                              color: c.textoSecundario,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (paso.nota != null)
                      Text(
                        paso.nota!,
                        style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Punto extends StatefulWidget {
  const _Punto({required this.estado});

  final EstadoPaso estado;

  @override
  State<_Punto> createState() => _PuntoState();
}

class _PuntoState extends State<_Punto> with SingleTickerProviderStateMixin {
  late final AnimationController _respiro = AnimationController(vsync: this);
  bool _corriendo = false;

  bool get _debeRespirar => widget.estado == EstadoPaso.actual;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sincronizar();
  }

  @override
  void didUpdateWidget(_Punto anterior) {
    super.didUpdateWidget(anterior);
    _sincronizar();
  }

  void _sincronizar() {
    _respiro.duration = context.movimiento(Movimiento.enfatico).duracion * 4;
    final reducir = MediaQuery.disableAnimationsOf(context);
    if (_debeRespirar && !reducir) {
      if (!_corriendo) {
        _corriendo = true;
        _respiro.repeat(reverse: true);
      }
    } else {
      _corriendo = false;
      _respiro
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _respiro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final curva = context.movimiento(Movimiento.base).curva;
    const diametro = _Paso._punto;

    final (fondo, borde, icono, colorIcono) = switch (widget.estado) {
      EstadoPaso.hecho => (c.acento, c.acento, Icons.check, c.sobreAcento),
      EstadoPaso.actual => (c.acentoSuave, c.acento, null, c.acento),
      EstadoPaso.pendiente => (
        c.superficie,
        c.contornoControl,
        null,
        c.textoTerciario,
      ),
    };

    return SizedBox(
      width: diametro,
      height: diametro,
      child: AnimatedBuilder(
        animation: _respiro,
        builder: (context, _) {
          final halo = curva.transform(_respiro.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.estado == EstadoPaso.actual)
                Container(
                  width: diametro + 8 * halo,
                  height: diametro + 8 * halo,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.acento.withValues(alpha: 0.18 * (1 - halo)),
                  ),
                ),
              Container(
                width: diametro,
                height: diametro,
                decoration: BoxDecoration(
                  color: fondo,
                  shape: BoxShape.circle,
                  border: Border.all(color: borde, width: 2),
                ),
                child: icono == null
                    ? (widget.estado == EstadoPaso.actual
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colorIcono,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null)
                    : Icon(icono, size: 16, color: colorIcono),
              ),
            ],
          );
        },
      ),
    );
  }
}
