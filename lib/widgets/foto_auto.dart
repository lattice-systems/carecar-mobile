import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../nucleo/autos/foto_de_modelo.dart';
import '../tema/tema_carecar.dart';

export '../nucleo/autos/foto_de_modelo.dart';

/// Foto de un auto: la incluida en la app, si no la URL, si no un marcador.
class FotoAuto extends StatelessWidget {
  const FotoAuto({
    required this.modelo,
    required this.alto,
    this.url,
    this.radio = 16,
    super.key,
  });

  final String? modelo;
  final String? url;
  final double alto;
  final double radio;

  static const marcador = Key('foto_auto_marcador');

  @override
  Widget build(BuildContext context) {
    final vacio = Container(
      key: marcador,
      height: alto,
      width: double.infinity,
      color: TemaCareCar.azulSuave,
      child: const Icon(
        LucideIcons300.car,
        size: 56,
        color: TemaCareCar.azulAgencia,
      ),
    );
    final asset = fotoDeModelo(modelo);
    final Widget imagen = asset != null
        ? Image.asset(
            asset,
            height: alto,
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: 'Foto de $modelo',
            errorBuilder: (_, _, _) => vacio,
          )
        : url != null
        ? Image.network(
            url!,
            height: alto,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => vacio,
          )
        : vacio;
    return ClipRRect(borderRadius: BorderRadius.circular(radio), child: imagen);
  }
}
