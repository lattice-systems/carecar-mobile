import 'package:flutter/material.dart';

import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/estante.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/tokens/colores.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'seccion_galeria.dart';

/// Secciones de los componentes de estilo portada: boton pildora, cabecera de
/// portada, estante y grupo de lista.
List<SeccionGaleria> seccionesPortada() => [
  SeccionGaleria(
    titulo: 'Boton pildora',
    construir: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: BotonPildora(
                texto: 'Agendar',
                icono: Icons.event,
                expandido: true,
                alPresionar: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonPildora(
                texto: 'Detalle',
                variante: VarianteBotonPildora.vidrio,
                expandido: true,
                alPresionar: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const BotonPildora(texto: 'Deshabilitado', alPresionar: null),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Cabecera de portada',
    construir: (context) => CabeceraPortada(
      titulo: 'Mi Kicks',
      subtitulo: 'Nissan Kicks 2023 · 24,300 km',
      descripcion: 'Silueta de tu auto',
      portada: ColoredBox(
        color: TokensPista.de(context).colores.superficieHundida,
        child: Icon(
          Icons.directions_car_filled_outlined,
          size: 120,
          color: TokensPista.de(context).colores.textoTerciario,
        ),
      ),
      principal: AccionPortada(
        texto: 'Agendar cita',
        icono: Icons.event,
        alPresionar: () {},
      ),
      secundaria: AccionPortada(texto: 'Ver detalle', alPresionar: () {}),
    ),
  ),
  SeccionGaleria(
    titulo: 'Estante',
    construir: (context) {
      final c = TokensPista.de(context).colores;
      return Estante(
        titulo: 'Para ti',
        alVerTodo: () {},
        anchoTarjeta: 140,
        alto: 140,
        hijos: [
          for (final color in [c.acento, c.exito, c.advertencia, c.marca])
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: Radios.bordeTarjeta,
              ),
              child: Icon(Icons.local_offer_outlined, color: color, size: 40),
            ),
        ],
      );
    },
  ),
  SeccionGaleria(
    titulo: 'Grupo de lista',
    construir: (context) {
      final PaletaColores c = TokensPista.de(context).colores;
      return GrupoLista(
        encabezado: 'Cuenta',
        pie: 'Tus datos se guardan en este telefono.',
        filas: [
          FilaGrupo(
            titulo: 'Perfil',
            subtitulo: 'Nombre y telefono',
            icono: Icons.person,
            colorIcono: c.acento,
            alToque: () {},
          ),
          FilaGrupo(
            titulo: 'Seguridad',
            icono: Icons.lock,
            colorIcono: c.exito,
            alToque: () {},
          ),
          FilaGrupo(
            titulo: 'Notificaciones',
            icono: Icons.notifications,
            colorIcono: c.peligro,
            fin: const Text('Activadas'),
            alToque: () {},
          ),
        ],
      );
    },
  ),
];
