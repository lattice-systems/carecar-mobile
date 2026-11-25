import 'package:flutter/material.dart';

import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estante.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tarjeta_auto.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/colores.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'seccion_galeria.dart';

/// Secciones de los componentes con los que se arma una pantalla: boton
/// pildora, tarjeta del auto con sus acciones, tarjeta de resumen, estante y
/// grupo de lista.
List<SeccionGaleria> seccionesPantalla() => [
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
    titulo: 'Tarjeta del auto',
    construir: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TarjetaAuto(
          marca: 'Nissan',
          titulo: 'Kicks 2023',
          placas: 'ABC-12-34',
          kilometraje: '24,300 km',
        ),
        const SizedBox(height: 16),
        FilaAcciones(
          principal: AccionPantalla(
            texto: 'Agendar cita',
            icono: Icons.event,
            alPresionar: () {},
          ),
          secundaria: AccionPantalla(texto: 'Ver detalle', alPresionar: () {}),
        ),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Tarjeta de resumen',
    construir: (context) => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TarjetaResumen(
          titulo: 'Servicio de 20,000 km',
          subtitulo: 'Te toca por kilometraje',
          icono: Icons.build_circle_outlined,
          progreso: 0.84,
          etiquetaProgreso: 'Faltan 1,550 km · hacia el sáb, 9 ene',
        ),
        SizedBox(height: 12),
        TarjetaResumen(
          titulo: 'Folio 1042',
          subtitulo: 'Jueves 3 de diciembre, 09:00',
          icono: Icons.event_available_outlined,
          tono: Tono.exito,
          estado: 'Confirmada',
          tonoEstado: Tono.exito,
        ),
      ],
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
