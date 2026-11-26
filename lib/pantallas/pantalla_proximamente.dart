import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../api/modelos/vehiculo.dart';
import '../tema/tema_carecar.dart';
import '../widgets/pagina_carecar.dart';

/// Solo navegacion; no solicita catalogo, citas, servicios ni manuales.
class PantallaProximamente extends StatelessWidget {
  const PantallaProximamente({
    required this.titulo,
    required this.alCerrarSesion,
    this.vehiculo,
    super.key,
  });
  final String titulo;
  final Vehiculo? vehiculo;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: titulo,
    alCerrarSesion: alCerrarSesion,
    contenido: ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * .45,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons300.clockPlus,
              size: 56,
              color: TemaCareCar.textoSecundario,
            ),
            const SizedBox(height: TemaCareCar.espacioSecciones),
            Text(
              'PRÓXIMAMENTE',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (vehiculo != null) ...[
              const SizedBox(height: TemaCareCar.espacioCampos),
              Text(
                '${vehiculo!.modelo} ${vehiculo!.anio}',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
