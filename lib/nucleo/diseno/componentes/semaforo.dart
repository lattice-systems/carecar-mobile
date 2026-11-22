import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'tono.dart';

/// Resultado de revisar un punto de la inspeccion.
enum EstadoSemaforo {
  bien('Bien', Tono.exito, Icons.check_circle),
  atencion('Requiere atencion', Tono.advertencia, Icons.warning_amber_rounded),
  urgente('Urgente', Tono.peligro, Icons.error);

  const EstadoSemaforo(this.texto, this.tono, this.icono);

  final String texto;
  final Tono tono;
  final IconData icono;
}

/// Un punto revisado de la inspeccion multipunto: verde, amarillo o rojo.
///
/// El estado nunca depende solo del color: lleva su icono propio y su texto
/// ("Bien", "Requiere atencion", "Urgente"). El lector de pantalla recibe un
/// solo nodo ("Frenos: urgente. Balatas al 10 %"). Con `alToque` se vuelve
/// tocable, por ejemplo para abrir las fotos del punto, con zona de al menos 48.
class Semaforo extends StatelessWidget {
  const Semaforo({
    required this.punto,
    required this.estado,
    super.key,
    this.detalle,
    this.alToque,
  });

  /// Nombre del punto revisado, por ejemplo "Frenos".
  final String punto;
  final EstadoSemaforo estado;
  final String? detalle;
  final VoidCallback? alToque;

  static const double _tamanoIcono = 24;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final colores = ColoresTono.de(estado.tono, c);
    final tocable = alToque != null;

    final contenido = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e3),
        child: Row(
          children: [
            Icon(estado.icono, size: _tamanoIcono, color: colores.frente),
            const SizedBox(width: Espaciado.e3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(punto, style: t.cuerpoFuerte.copyWith(color: c.texto)),
                  Text(
                    estado.texto,
                    style: t.etiqueta.copyWith(color: colores.frente),
                  ),
                  if (detalle != null)
                    Text(
                      detalle!,
                      style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                    ),
                ],
              ),
            ),
            if (tocable)
              ExcludeSemantics(
                child: Icon(Icons.chevron_right, color: c.textoSecundario),
              ),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: tocable,
      label: ['$punto: ${estado.texto.toLowerCase()}', ?detalle].join('. '),
      onTap: alToque,
      excludeSemantics: true,
      child: Material(
        color: colores.fondo,
        borderRadius: Radios.bordeTarjeta,
        clipBehavior: Clip.antiAlias,
        child: tocable ? InkWell(onTap: alToque, child: contenido) : contenido,
      ),
    );
  }
}
