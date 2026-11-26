import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../nucleo/diseno/componentes/avatar.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/menu.dart';
import '../../../nucleo/diseno/componentes/pestanas.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import 'seccion_galeria.dart';

/// Secciones de los componentes base (V2-T02.04), con sus estados.
List<SeccionGaleria> seccionesBase() => [
  SeccionGaleria(
    titulo: 'Boton',
    construir: (context) => Wrap(
      spacing: Espaciado.e2,
      runSpacing: Espaciado.e2,
      children: [
        for (final v in VarianteBoton.values)
          Boton(texto: v.name, variante: v, alPresionar: () {}),
        const Boton(texto: 'Deshabilitado', alPresionar: null),
        Boton(texto: 'Cargando', cargando: true, alPresionar: () {}),
        Boton(
          texto: 'Con icono',
          icono: LucideIcons300.calendar,
          alPresionar: () {},
        ),
        for (final t in TamanoBoton.values)
          Boton(texto: t.name, tamano: t, alPresionar: () {}),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Insignia, chip y avatar',
    construir: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Espaciado.e2,
          runSpacing: Espaciado.e2,
          children: [
            for (final tono in Tono.values)
              Insignia(texto: tono.name, tono: tono, conIcono: true),
          ],
        ),
        const SizedBox(height: Espaciado.e3),
        Con<bool>(
          inicial: true,
          construir: (valor, cambiar) => Wrap(
            spacing: Espaciado.e2,
            children: [
              ChipPista(
                texto: 'Seleccionable',
                seleccionado: valor,
                alCambiar: cambiar,
              ),
              const ChipPista(
                texto: 'Deshabilitado',
                seleccionado: false,
                alCambiar: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: Espaciado.e3),
        Wrap(
          spacing: Espaciado.e3,
          children: [
            for (final t in TamanoAvatar.values)
              Avatar(nombre: 'Ana Perez', tamano: t),
          ],
        ),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Aviso',
    construir: (context) => Column(
      children: [
        for (final tono in Tono.values)
          Padding(
            padding: const EdgeInsets.only(bottom: Espaciado.e2),
            child: Aviso(
              titulo: tono.name,
              mensaje: 'Mensaje de ejemplo para el tono ${tono.name}.',
              tono: tono,
              alCerrar: tono == Tono.informacion ? () {} : null,
            ),
          ),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Campos',
    construir: (context) => const Column(
      children: [
        CampoTexto(etiqueta: 'Nombre', sugerencia: 'Como te llamas'),
        SizedBox(height: Espaciado.e3),
        CampoTexto(etiqueta: 'Correo', ayuda: 'Te enviaremos un codigo'),
        SizedBox(height: Espaciado.e3),
        CampoTexto(etiqueta: 'Telefono', error: 'Escribe 10 digitos'),
        SizedBox(height: Espaciado.e3),
        CampoContrasena(etiqueta: 'Contrasena'),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Selector, casilla e interruptor',
    construir: (context) => Column(
      children: [
        Con<String?>(
          inicial: null,
          construir: (valor, cambiar) => Selector<String>(
            etiqueta: 'Motivo de la cita',
            sugerencia: 'Elige uno',
            opciones: const [
              OpcionSelector(valor: 'servicio', texto: 'Servicio'),
              OpcionSelector(valor: 'garantia', texto: 'Garantia'),
            ],
            valor: valor,
            alCambiar: cambiar,
          ),
        ),
        Con<bool>(
          inicial: true,
          construir: (valor, cambiar) => Casilla(
            etiqueta: 'Recordarme',
            descripcion: 'Un aviso un dia antes',
            valor: valor,
            alCambiar: cambiar,
          ),
        ),
        Con<bool>(
          inicial: false,
          construir: (valor, cambiar) => Interruptor(
            etiqueta: 'Notificaciones',
            valor: valor,
            alCambiar: cambiar,
          ),
        ),
        const Casilla(etiqueta: 'Deshabilitada', valor: true, alCambiar: null),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Dialogo, hoja inferior y menu',
    construir: (context) => Wrap(
      spacing: Espaciado.e2,
      runSpacing: Espaciado.e2,
      children: [
        Boton(
          texto: 'Abrir dialogo',
          variante: VarianteBoton.secundario,
          alPresionar: () => mostrarDialogo<void>(
            context,
            builder: (c) => Dialogo(
              titulo: 'Cancelar cita',
              mensaje: 'Esta accion no se puede deshacer.',
              textoPrincipal: 'Cancelar cita',
              alPrincipal: () => Navigator.of(c).pop(),
              textoSecundario: 'Volver',
              alSecundario: () => Navigator.of(c).pop(),
              peligro: true,
            ),
          ),
        ),
        Boton(
          texto: 'Abrir hoja inferior',
          variante: VarianteBoton.secundario,
          alPresionar: () => mostrarHojaInferior<void>(
            context,
            titulo: 'Filtros',
            builder: (c) => const Text('Contenido de la hoja.'),
          ),
        ),
        Menu<String>(
          etiqueta: 'Mas opciones',
          alSeleccionar: (_) {},
          items: const [
            ItemMenu(
              valor: 'editar',
              texto: 'Editar',
              icono: LucideIcons300.pencil,
            ),
            ItemMenu(valor: 'borrar', texto: 'Borrar', peligro: true),
          ],
        ),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Pestanas',
    construir: (context) => Con<int>(
      inicial: 0,
      construir: (valor, cambiar) => Pestanas(
        etiquetas: const ['Proximas', 'Pasadas', 'Canceladas'],
        indice: valor,
        alCambiar: cambiar,
      ),
    ),
  ),
];
