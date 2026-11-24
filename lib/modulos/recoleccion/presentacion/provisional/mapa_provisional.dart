// PROVISIONAL: se reemplaza por Mapa de V2-T02.09
//
// Mapa mínimo para poner el pin de una dirección. Es el único archivo del
// módulo que importa `flutter_map` y `latlong2` (decisión 0006); el resto de la
// app habla en `Coordenada`. Cuando exista el componente `Mapa` del sistema de
// diseño, este archivo se borra y el formulario usa el componente.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../../nucleo/mapas/mapas.dart';

/// Mapa con un pin que se mueve tocando. Sigue el tema Pista: bordes de
/// tarjeta, marcador del color de acento y atribución legible.
class MapaProvisional extends ConsumerStatefulWidget {
  const MapaProvisional({
    required this.pin,
    required this.alElegir,
    super.key,
    this.alto = 260,
  });

  /// Dónde está el pin; nulo mientras no se ha puesto.
  final Coordenada? pin;
  final ValueChanged<Coordenada> alElegir;
  final double alto;

  /// Centro de la zona de cobertura de desarrollo: Ciudad de México.
  static const _centroInicial = LatLng(19.4326, -99.1332);

  @override
  ConsumerState<MapaProvisional> createState() => _EstadoMapaProvisional();
}

class _EstadoMapaProvisional extends ConsumerState<MapaProvisional> {
  final _controlador = MapController();

  @override
  void didUpdateWidget(MapaProvisional anterior) {
    super.didUpdateWidget(anterior);
    final nuevo = widget.pin;
    if (nuevo != null && nuevo != anterior.pin) {
      // Un pin puesto desde fuera (ubicación, búsqueda) se centra; uno puesto
      // con el toque ya está a la vista y no se mueve el mapa.
      final camara = _controlador.camera;
      final punto = LatLng(nuevo.latitud, nuevo.longitud);
      if (!camara.visibleBounds.contains(punto)) {
        _controlador.move(punto, camara.zoom);
      }
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final teselas = ref.watch(configuracionTeselasProvider);
    final pin = widget.pin;
    final punto = pin == null ? null : LatLng(pin.latitud, pin.longitud);

    return Semantics(
      container: true,
      label: pin == null
          ? textos.recoleccionFormMapaSinPin
          : textos.recoleccionFormMapaDescripcion(
              '${pin.latitud}',
              '${pin.longitud}',
            ),
      child: ClipRRect(
        borderRadius: Radios.bordeTarjeta,
        child: SizedBox(
          height: widget.alto,
          child: FlutterMap(
            mapController: _controlador,
            options: MapOptions(
              initialCenter: punto ?? MapaProvisional._centroInicial,
              initialZoom: punto == null ? 11 : 16,
              minZoom: 3,
              maxZoom: 18,
              backgroundColor: c.superficieElevada,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, p) =>
                  widget.alElegir(Coordenada(p.latitude, p.longitude)),
            ),
            children: [
              TileLayer(
                urlTemplate: teselas.urlPlantilla,
                userAgentPackageName: 'com.carecar.carecar_mobile',
              ),
              if (punto != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: punto,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: ExcludeSemantics(
                        child: Icon(
                          Icons.location_on,
                          size: 48,
                          color: c.acento,
                        ),
                      ),
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.superficie.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      teselas.atribucion,
                      style: tokens.tipografia.cuerpoChico.copyWith(
                        color: c.textoSecundario,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
