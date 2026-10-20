import 'package:flutter/material.dart';

import '../tema/tema_carecar.dart';

/// Los cuatro tonos de aviso de la guia de estilos.
enum TonoAviso { error, advertencia, exito, informacion }

/// Caja de aviso con icono, titulo y texto.
///
/// Es el patron que usan los mockups: un recuadro de color suave con icono a
/// la izquierda, un titulo en negritas y el detalle abajo.
///
/// **Siempre lleva icono y texto.** La guia de estilos es explicita: un estado
/// nunca se comunica solo con color, porque quien no distingue los colores no
/// recibe el mensaje.
class Aviso extends StatelessWidget {
  const Aviso({
    required this.titulo,
    required this.tono,
    super.key,
    this.detalle,
    this.icono,
  });

  const Aviso.error({required this.titulo, super.key, this.detalle, this.icono})
    : tono = TonoAviso.error;

  const Aviso.advertencia({
    required this.titulo,
    super.key,
    this.detalle,
    this.icono,
  }) : tono = TonoAviso.advertencia;

  const Aviso.exito({required this.titulo, super.key, this.detalle, this.icono})
    : tono = TonoAviso.exito;

  const Aviso.informacion({
    required this.titulo,
    super.key,
    this.detalle,
    this.icono,
  }) : tono = TonoAviso.informacion;

  final String titulo;
  final String? detalle;
  final TonoAviso tono;

  /// Cambia el icono por omision del tono, sin cambiar los colores.
  final IconData? icono;

  Color get _texto => switch (tono) {
    TonoAviso.error => TemaCareCar.peligro,
    TonoAviso.advertencia => TemaCareCar.advertencia,
    TonoAviso.exito => TemaCareCar.exito,
    TonoAviso.informacion => TemaCareCar.azulAgencia,
  };

  Color get _fondo => switch (tono) {
    TonoAviso.error => TemaCareCar.peligroFondo,
    TonoAviso.advertencia => TemaCareCar.advertenciaFondo,
    TonoAviso.exito => TemaCareCar.exitoFondo,
    TonoAviso.informacion => TemaCareCar.azulSuave,
  };

  IconData get _icono =>
      icono ??
      switch (tono) {
        TonoAviso.error => Icons.error_outline,
        TonoAviso.advertencia => Icons.warning_amber_outlined,
        TonoAviso.exito => Icons.check_circle_outline,
        TonoAviso.informacion => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(TemaCareCar.radioControl),
        border: Border.all(color: _texto.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icono, color: _texto, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: estilos.labelLarge?.copyWith(
                    color: _texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detalle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detalle!,
                    style: estilos.bodyMedium?.copyWith(color: _texto),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
