import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'insignia.dart';
import 'tono.dart';

/// Tarjeta heroe de un vehiculo: su foto sobre el degradado del sistema, el
/// nombre y un detalle.
///
/// Sin `foto` muestra la silueta de un auto en `textoTerciario`. Con `heroTag`
/// la foto viaja a la pantalla de detalle. `descripcionFoto` es lo que lee el
/// lector de pantalla en lugar de la imagen. Toda la tarjeta es un solo nodo.
class TarjetaVehiculo extends StatelessWidget {
  const TarjetaVehiculo({
    required this.nombre,
    super.key,
    this.detalle,
    this.foto,
    this.descripcionFoto,
    this.heroTag,
    this.estado,
    this.tonoEstado = Tono.neutro,
    this.alToque,
    this.alto = 200,
  });

  final String nombre;
  final String? detalle;
  final ImageProvider? foto;
  final String? descripcionFoto;
  final Object? heroTag;

  /// Texto corto de estado, por ejemplo "Servicio en proceso".
  final String? estado;
  final Tono tonoEstado;
  final VoidCallback? alToque;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final oscuro = tokens.brillo == Brightness.dark;

    Widget imagen = foto == null
        ? Icon(
            Icons.directions_car_filled_outlined,
            size: 96,
            color: c.textoTerciario,
          )
        : Image(
            image: foto!,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.directions_car_filled_outlined,
              size: 96,
              color: c.textoTerciario,
            ),
          );
    if (heroTag != null) imagen = Hero(tag: heroTag!, child: imagen);

    final partes = [nombre, ?detalle, ?estado];

    return Semantics(
      container: true,
      button: alToque != null,
      label: partes.join('. '),
      onTap: alToque,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: Radios.bordeTarjeta,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: Radios.bordeTarjeta,
            border: Border.all(color: c.borde),
            gradient: oscuro
                ? RadialGradient(
                    center: const Alignment(0, -0.3),
                    radius: 1,
                    colors: [
                      Color.alphaBlend(
                        c.acento.withValues(alpha: 0.12),
                        c.superficieHundida,
                      ),
                      c.fondo,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.superficieHundida, c.fondo],
                  ),
          ),
          child: InkWell(
            onTap: alToque,
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (estado != null)
                    Insignia(texto: estado!, tono: tonoEstado, conIcono: true),
                  SizedBox(
                    height: alto,
                    child: Center(child: imagen),
                  ),
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.titulo3.copyWith(color: c.texto),
                  ),
                  if (detalle != null)
                    Text(
                      detalle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
