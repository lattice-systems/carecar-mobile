import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../tema/tema_carecar.dart';

/// Tarjeta de presentacion de una pantalla (p. ej. «Nueva cita»).
///
/// Es **clara** a proposito: el encabezado de la pantalla es azul oscuro, y una
/// tarjeta del mismo color pegada debajo se veia como una sola mancha. Lleva
/// separacion arriba para no tocar el encabezado.
class TarjetaIntro extends StatelessWidget {
  const TarjetaIntro({
    required this.etiqueta,
    required this.titulo,
    required this.texto,
    required this.icono,
    required this.color,
    required this.fondo,
    super.key,
  });

  /// Rotulo pequeno en mayusculas, en el color de acento.
  final String etiqueta;
  final String titulo;
  final String texto;
  final IconData icono;

  /// Color de acento (ícono, rótulo y borde).
  final Color color;

  /// Fondo suave de la tarjeta.
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icono, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: temas.labelSmall?.copyWith(
                    color: color,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: temas.titleLarge?.copyWith(
                    color: TemaCareCar.azulAgencia,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  texto,
                  style: temas.bodyMedium?.copyWith(
                    color: TemaCareCar.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08);
  }
}
