import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../nucleo/diseno/componentes/barra_navegacion.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/comparacion_antes_despues.dart';
import '../../../nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/firma.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/grafica.dart';
import '../../../nucleo/diseno/componentes/linea_de_tiempo.dart';
import '../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../nucleo/diseno/componentes/semaforo.dart';
import '../../../nucleo/diseno/componentes/tarjeta_accion.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tarjeta_vehiculo.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import 'seccion_galeria.dart';

/// Una imagen de un pixel: la galeria no empaqueta fotos, solo muestra los
/// componentes con su forma y sus estados.
final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// Secciones de los componentes compuestos y especiales (V2-T02.05, T02.10 a
/// T02.14), con sus estados.
List<SeccionGaleria> seccionesCompuestos() => [
  SeccionGaleria(
    titulo: 'Estado vacio, error y esqueleto',
    construir: (context) => Column(
      children: [
        EstadoVacio(
          titulo: 'Aun no tienes citas',
          mensaje: 'Agenda tu primera cita de servicio.',
          textoAccion: 'Agendar cita',
          alAccion: () {},
        ),
        EstadoError(alReintentar: () {}),
        EstadoError(causa: CausaError.sinConexion, alReintentar: () {}),
        const SizedBox(height: Espaciado.e3),
        const Esqueleto(alto: 96),
        const SizedBox(height: Espaciado.e2),
        const Esqueleto.linea(),
        const SizedBox(height: Espaciado.e2),
        const Esqueleto.circulo(diametro: 40),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Tarjetas',
    construir: (context) => Column(
      children: [
        TarjetaVehiculo(
          nombre: 'Mazda CX-5 2024',
          detalle: 'Placa ABC-123',
          estado: 'Servicio en proceso',
          tonoEstado: Tono.advertencia,
          alToque: () {},
        ),
        const SizedBox(height: Espaciado.e3),
        const Row(
          children: [
            Expanded(
              child: TarjetaMetrica(
                cifra: '12 400 km',
                etiqueta: 'Recorrido del mes',
                detalle: 'vs. mes anterior',
              ),
            ),
            SizedBox(width: Espaciado.e3),
            Expanded(
              child: TarjetaMetrica(
                cifra: '3',
                etiqueta: 'Alertas',
                tono: Tono.advertencia,
              ),
            ),
          ],
        ),
        const SizedBox(height: Espaciado.e3),
        TarjetaAccion(
          titulo: 'Agendar cita',
          descripcion: 'Elige fecha y hora',
          icono: Icons.event,
          alToque: () {},
        ),
        const SizedBox(height: Espaciado.e2),
        TarjetaAccion(
          titulo: 'Pedir ayuda en el camino',
          icono: Icons.sos,
          tono: Tono.peligro,
          alToque: () {},
        ),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Fila de lista y semaforo',
    construir: (context) => Column(
      children: [
        FilaLista(
          titulo: 'Mazda CX-5 2024',
          subtitulo: 'Proximo servicio en 1 200 km',
          inicio: const Icon(Icons.directions_car),
          alToque: () {},
        ),
        const FilaLista(titulo: 'Sin toque', subtitulo: 'No es tocable'),
        const SizedBox(height: Espaciado.e3),
        for (final estado in EstadoSemaforo.values)
          Padding(
            padding: const EdgeInsets.only(bottom: Espaciado.e2),
            child: Semaforo(
              punto: 'Frenos',
              estado: estado,
              detalle: 'Detalle de la revision',
              alToque: () {},
            ),
          ),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Linea de tiempo',
    construir: (context) => const LineaDeTiempo(
      pasos: [
        PasoLinea(titulo: 'Recibido', estado: EstadoPaso.hecho, hora: '09:00'),
        PasoLinea(
          titulo: 'Diagnostico',
          estado: EstadoPaso.hecho,
          hora: '10:30',
        ),
        PasoLinea(
          titulo: 'En reparacion',
          estado: EstadoPaso.actual,
          nota: 'Listo hacia las 16:00',
        ),
        PasoLinea(titulo: 'Entregado', estado: EstadoPaso.pendiente),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Calendario y franjas',
    construir: (context) => Con<DateTime?>(
      inicial: null,
      construir: (dia, cambiarDia) => Con<DateTime>(
        inicial: DateTime(2026, 11),
        construir: (mes, cambiarMes) => Column(
          children: [
            Calendario(
              mes: mes,
              seleccionado: dia,
              alSeleccionar: cambiarDia,
              alCambiarMes: cambiarMes,
              primerDia: DateTime(2026, 11, 3),
              ultimoDia: DateTime(2027, 1, 31),
              habilitado: (d) => d.weekday != DateTime.sunday && d.day != 20,
              hoy: DateTime(2026, 11, 10),
            ),
            const SizedBox(height: Espaciado.e3),
            Con<int?>(
              inicial: null,
              construir: (franja, cambiar) => SelectorFranja(
                franjas: const [
                  FranjaHoraria(etiqueta: '09:00', cupo: 3),
                  FranjaHoraria(etiqueta: '10:00', cupo: 1),
                  FranjaHoraria(etiqueta: '11:00', cupo: 0),
                ],
                seleccionada: franja,
                alSeleccionar: cambiar,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
  SeccionGaleria(
    titulo: 'Grafica',
    construir: (context) => const Column(
      children: [
        Grafica(
          titulo: 'Gasto por mes',
          puntos: [
            PuntoGrafica(etiqueta: 'Ene', valor: 1200),
            PuntoGrafica(etiqueta: 'Feb', valor: 800),
            PuntoGrafica(etiqueta: 'Mar', valor: 1500),
          ],
        ),
        SizedBox(height: Espaciado.e4),
        Grafica(
          titulo: 'Valor estimado',
          tipo: TipoGrafica.lineas,
          puntos: [
            PuntoGrafica(etiqueta: 'Ene', valor: 320),
            PuntoGrafica(etiqueta: 'Feb', valor: 310),
            PuntoGrafica(etiqueta: 'Mar', valor: 300),
          ],
        ),
        SizedBox(height: Espaciado.e4),
        Grafica(titulo: 'Sin datos', puntos: []),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Deslizar para confirmar',
    construir: (context) => Column(
      children: [
        DeslizarParaConfirmar(
          texto: 'Desliza para cancelar la cita',
          peligro: true,
          alConfirmar: () {},
        ),
        const SizedBox(height: Espaciado.e2),
        const DeslizarParaConfirmar(texto: 'Deshabilitado', alConfirmar: null),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Fotos, comparacion y firma',
    construir: (context) {
      final foto = FotoGaleria(
        imagen: MemoryImage(_pixel),
        descripcion: 'Foto de ejemplo',
      );
      return Column(
        children: [
          GaleriaFotos(fotos: [foto, foto, foto]),
          const SizedBox(height: Espaciado.e3),
          ComparacionAntesDespues(antes: foto, despues: foto),
          const SizedBox(height: Espaciado.e3),
          const Firma(firmante: 'Ana Perez', imagen: null),
        ],
      );
    },
  ),
  SeccionGaleria(
    titulo: 'Visor de PDF (estado de error)',
    construir: (context) => SizedBox(
      height: 320,
      child: VisorPdf(
        descripcion: 'Documento de ejemplo',
        cargar: () async => throw Exception('Documento de ejemplo'),
      ),
    ),
  ),
  SeccionGaleria(
    titulo: 'Barra de navegacion',
    construir: (context) => Con<int>(
      inicial: 0,
      construir: (valor, cambiar) => BarraNavegacion(
        destinos: const [
          DestinoNavegacion(etiqueta: 'Inicio', icono: Icons.home_outlined),
          DestinoNavegacion(
            etiqueta: 'Mi auto',
            icono: Icons.directions_car_outlined,
          ),
          DestinoNavegacion(
            etiqueta: 'Servicio',
            icono: Icons.build_outlined,
            conteo: 3,
          ),
          DestinoNavegacion(
            etiqueta: 'Explorar',
            icono: Icons.explore_outlined,
          ),
          DestinoNavegacion(etiqueta: 'Cuenta', icono: Icons.person_outline),
        ],
        indice: valor,
        alCambiar: cambiar,
      ),
    ),
  ),
];
