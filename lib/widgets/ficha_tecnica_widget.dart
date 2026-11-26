import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../config/ficha_tecnica.dart';
import '../tema/tema_carecar.dart';

/// Tarjeta «Ficha tecnica» con una celda por dato, en una o dos columnas.
class TarjetaFichaTecnica extends StatelessWidget {
  const TarjetaFichaTecnica({required this.ficha, super.key});

  final FichaTecnica ficha;

  static const clave = Key('ficha_tecnica');

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final datos = <(IconData, String, String)>[
      (LucideIcons300.car, 'Carrocería', ficha.carroceria),
      (LucideIcons300.armchair, 'Pasajeros', ficha.pasajeros),
      (LucideIcons300.fuel, 'Propulsión', ficha.propulsion),
      (LucideIcons300.settings, 'Motor', ficha.motor),
      (LucideIcons300.zap, 'Potencia', ficha.potencia),
      (LucideIcons300.slidersHorizontal, 'Transmisión', ficha.transmision),
      (LucideIcons300.route, 'Tracción', ficha.traccion),
    ];
    return Container(
      key: clave,
      width: double.infinity,
      padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
      decoration: BoxDecoration(
        color: TemaCareCar.tarjeta,
        border: Border.all(color: TemaCareCar.borde),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ficha técnica', style: temas.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Especificaciones del modelo según su año y versión. El detalle '
            'de tu unidad está en su manual del propietario.',
            style: temas.bodyMedium?.copyWith(
              color: TemaCareCar.textoSecundario,
            ),
          ),
          const SizedBox(height: TemaCareCar.espacioCampos),
          LayoutBuilder(
            builder: (context, c) {
              final dosColumnas = c.maxWidth >= 420;
              final ancho = dosColumnas ? (c.maxWidth - 12) / 2 : c.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final (i, d) in datos.indexed)
                    SizedBox(
                      width: ancho,
                      child: _Celda(icono: d.$1, etiqueta: d.$2, valor: d.$3)
                          .animate(delay: (60 * i).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.15, curve: Curves.easeOutCubic),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Celda extends StatelessWidget {
  const _Celda({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TemaCareCar.fondo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TemaCareCar.azulSuave,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, size: 20, color: TemaCareCar.azulAgencia),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: temas.labelSmall?.copyWith(
                    color: TemaCareCar.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: temas.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
