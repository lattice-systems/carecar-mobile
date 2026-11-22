import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'tono.dart';

/// Mensaje en linea dentro de la pantalla, no flotante.
///
/// Anuncia su contenido al lector de pantalla cuando aparece. Con `alCerrar`
/// muestra un boton de cierre de 48 de zona tactil.
class Aviso extends StatelessWidget {
  const Aviso({
    required this.mensaje,
    super.key,
    this.titulo,
    this.tono = Tono.informacion,
    this.alCerrar,
  });

  final String mensaje;
  final String? titulo;
  final Tono tono;
  final VoidCallback? alCerrar;

  static const double _tamanoIcono = 20;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final colores = ColoresTono.de(tono, c);

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colores.fondo,
          borderRadius: Radios.bordeTarjeta,
          border: Border.all(color: colores.frente.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.e4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(colores.icono, size: _tamanoIcono, color: colores.frente),
              const SizedBox(width: Espaciado.e3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titulo != null)
                      Text(
                        titulo!,
                        style: t.cuerpoFuerte.copyWith(color: c.texto),
                      ),
                    Text(
                      mensaje,
                      style: t.cuerpoChico.copyWith(color: c.texto),
                    ),
                  ],
                ),
              ),
              if (alCerrar != null)
                IconButton(
                  onPressed: alCerrar,
                  tooltip: 'Cerrar aviso',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, size: _tamanoIcono, color: c.texto),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
