import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import 'aviso.dart';

/// Aviso «Sin conexion» que se muestra solo mientras [sinConexion] sea `true`.
class AvisoSinConexion extends StatelessWidget {
  const AvisoSinConexion({required this.sinConexion, super.key});

  final ValueListenable<bool> sinConexion;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: sinConexion,
    builder: (context, activo, _) => activo
        ? const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Aviso.advertencia(
              titulo: 'Sin conexión · mostrando datos guardados',
              icono: LucideIcons300.cloudOff,
            ),
          )
        : const SizedBox.shrink(),
  );
}
