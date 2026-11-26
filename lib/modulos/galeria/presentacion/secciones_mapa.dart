import 'package:flutter/material.dart';

import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/mapa.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/mapas/mapas.dart';
import 'seccion_galeria.dart';

/// El crédito dice que son de ejemplo: la galería no descarga teselas.
const _teselas = ConfiguracionTeselas(
  urlPlantilla: 'https://teselas.invalid/{z}/{x}/{y}.png',
  atribucion: 'Teselas de ejemplo',
);

const _casa = Coordenada(21.1250, -101.6860);

/// Por dónde pasa el chofer de ejemplo.
const _recorrido = [
  Coordenada(21.1262, -101.6874),
  Coordenada(21.1258, -101.6862),
  Coordenada(21.1246, -101.6850),
];

/// Sección del componente `Mapa` (V2-T02.09): con pin que se edita, con el
/// chofer en movimiento y sin conexión.
List<SeccionGaleria> seccionesMapa() => [
  SeccionGaleria(
    titulo: 'Mapa',
    construir: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Con<Coordenada?>(
          inicial: null,
          construir: (pin, cambiar) => Mapa(
            teselas: _teselas,
            fuenteTeselas: TeselasLisas(),
            pin: pin,
            alMoverPin: cambiar,
            proveedorUbicacion: UbicacionFalsa(
              posicion: const Coordenada(21.1244, -101.6868),
            ),
            alto: 200,
          ),
        ),
        const SizedBox(height: Espaciado.e5),
        Con<int>(
          inicial: 0,
          construir: (paso, cambiar) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Mapa(
                teselas: _teselas,
                fuenteTeselas: TeselasLisas(),
                pin: _casa,
                enMovimiento: MarcadorEnMovimiento(
                  posicion: _recorrido[paso],
                  etiqueta: 'Chofer de ejemplo',
                ),
                alto: 200,
              ),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: 'Avanzar chofer',
                variante: VarianteBotonPildora.tonal,
                alPresionar: () => cambiar((paso + 1) % _recorrido.length),
              ),
            ],
          ),
        ),
        const SizedBox(height: Espaciado.e5),
        Mapa(
          teselas: _teselas,
          fuenteTeselas: TeselasSinConexion(),
          descripcion: 'Mapa sin conexión de ejemplo.',
          alto: 160,
        ),
      ],
    ),
  ),
];
