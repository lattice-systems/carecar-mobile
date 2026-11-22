import 'package:flutter/material.dart';

import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'seccion_galeria.dart';
import 'secciones_base.dart';
import 'secciones_compuestos.dart';

/// Galeria del sistema de diseno v2 (V2-T02.06): todos los componentes con sus
/// estados, y tres interruptores para verlos en oscuro y con letra al 150 % y
/// al 200 %. Solo se registra en desarrollo.
class PantallaGaleria extends StatefulWidget {
  const PantallaGaleria({super.key});

  @override
  State<PantallaGaleria> createState() => _PantallaGaleriaState();
}

class _PantallaGaleriaState extends State<PantallaGaleria> {
  bool _oscuro = false;
  double _escala = 1;

  final List<SeccionGaleria> _secciones = [
    ...seccionesBase(),
    ...seccionesCompuestos(),
  ];

  @override
  Widget build(BuildContext context) {
    final tema = _oscuro ? TemaPista.oscuro() : TemaPista.claro();
    return Theme(
      data: tema,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_escala)),
        child: Builder(
          builder: (context) {
            final tokens = TokensPista.de(context);
            final c = tokens.colores;
            final t = tokens.tipografia;
            return Scaffold(
              backgroundColor: c.fondo,
              appBar: AppBar(
                backgroundColor: c.fondo,
                foregroundColor: c.texto,
                title: Text(
                  'Galeria del sistema',
                  style: t.titulo3.copyWith(color: c.texto),
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Espaciado.e4,
                    ),
                    child: Wrap(
                      spacing: Espaciado.e2,
                      children: [
                        ChipPista(
                          texto: 'Oscuro',
                          seleccionado: _oscuro,
                          alCambiar: (v) => setState(() => _oscuro = v),
                        ),
                        ChipPista(
                          texto: 'Letra 150 %',
                          seleccionado: _escala == 1.5,
                          alCambiar: (v) =>
                              setState(() => _escala = v ? 1.5 : 1),
                        ),
                        ChipPista(
                          texto: 'Letra 200 %',
                          seleccionado: _escala == 2,
                          alCambiar: (v) => setState(() => _escala = v ? 2 : 1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(Espaciado.e4),
                      itemCount: _secciones.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: Espaciado.e6),
                      itemBuilder: (context, i) {
                        final seccion = _secciones[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                seccion.titulo,
                                style: t.titulo3.copyWith(color: c.texto),
                              ),
                            ),
                            const SizedBox(height: Espaciado.e3),
                            seccion.construir(context),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
