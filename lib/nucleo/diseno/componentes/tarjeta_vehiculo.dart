import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'insignia.dart';
import 'rebote_tactil.dart';
import 'silueta_auto.dart';
import 'tono.dart';

/// Tarjeta de un vehículo: su foto, el nombre y un detalle.
///
/// Es una tarjeta como [TarjetaResumen] y [TarjetaAuto] con foto: misma
/// superficie, radio y sombra, con la foto dentro de un bloque redondeado y,
/// si se puede tocar, el chevron al final (V2-T02.27).
///
/// Sin `foto` muestra la silueta de un auto en `textoTerciario`; si la foto
/// falla (sin conexión), usa `fotoRespaldo` (una de la app) antes que la
/// silueta. Con `heroTag` la foto viaja a la pantalla de detalle.
/// `descripcionFoto` es lo que lee el lector de pantalla en lugar de la
/// imagen. Toda la tarjeta es un solo nodo.
class TarjetaVehiculo extends StatelessWidget {
  const TarjetaVehiculo({
    required this.nombre,
    super.key,
    this.detalle,
    this.foto,
    this.fotoRespaldo,
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

  /// Foto incluida en la app, para cuando `foto` falta o no carga.
  final ImageProvider? fotoRespaldo;
  final String? descripcionFoto;
  final Object? heroTag;

  /// Texto corto de estado, por ejemplo "Servicio en proceso".
  final String? estado;
  final Tono tonoEstado;
  final VoidCallback? alToque;

  /// Alto del bloque de la foto.
  final double alto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    // Sin foto (o si falla) va la misma silueta de auto que usa `TarjetaAuto`,
    // en tonos neutros.
    final silueta = Center(
      child: SizedBox(
        width: 140,
        child: SiluetaAuto(
          carroceria: c.textoTerciario.withValues(alpha: 0.55),
          cristal: c.superficieHundida,
          llanta: c.textoTerciario,
        ),
      ),
    );
    final respaldo = fotoRespaldo == null
        ? silueta
        : SizedBox.expand(
            child: Image(
              image: fotoRespaldo!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => silueta,
            ),
          );
    Widget imagen = foto == null
        ? respaldo
        : Center(
            child: Image(
              image: foto!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => respaldo,
            ),
          );
    if (heroTag != null) imagen = Hero(tag: heroTag!, child: imagen);

    final partes = [nombre, ?detalle, ?estado];

    final tarjeta = DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: Radios.bordeTarjeta,
        boxShadow: tokens.sombras,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (estado != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Insignia(
                  texto: estado!,
                  tono: tonoEstado,
                  conIcono: true,
                ),
              ),
              const SizedBox(height: Espaciado.e3),
            ],
            SizedBox(
              height: alto,
              child: ClipRRect(
                borderRadius: Radios.bordeControl,
                child: ColoredBox(color: c.superficieHundida, child: imagen),
              ),
            ),
            const SizedBox(height: Espaciado.e3),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          style: t.cuerpoChico.copyWith(
                            color: c.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ),
                if (alToque != null)
                  Padding(
                    padding: const EdgeInsets.only(left: Espaciado.e2),
                    child: Icon(
                      LucideIcons300.chevronRight,
                      color: c.textoTerciario,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: alToque != null,
      label: partes.join('. '),
      onTap: alToque,
      excludeSemantics: true,
      child: alToque == null
          ? tarjeta
          : ReboteTactil(alPulsar: alToque, child: tarjeta),
    );
  }
}
