import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../nucleo/diseno/componentes/barra_navegacion.dart';
import '../../../nucleo/diseno/componentes/burbuja_mensaje.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/campo_busqueda_liquido.dart';
import '../../../nucleo/diseno/componentes/campo_mensaje.dart';
import '../../../nucleo/diseno/componentes/comparacion_antes_despues.dart';
import '../../../nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/firma.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/grafica.dart';
import '../../../nucleo/diseno/componentes/linea_de_tiempo.dart';
import '../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../nucleo/diseno/componentes/semaforo.dart';
import '../../../nucleo/diseno/componentes/superficie_liquida.dart';
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
          icono: LucideIcons300.calendar,
          alToque: () {},
        ),
        const SizedBox(height: Espaciado.e2),
        TarjetaAccion(
          titulo: 'Pedir ayuda en el camino',
          icono: LucideIcons300.siren,
          tono: Tono.peligro,
          alToque: () {},
        ),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Semaforo',
    construir: (context) => Column(
      children: [
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
          DestinoNavegacion(etiqueta: 'Inicio', icono: LucideIcons300.house),
          DestinoNavegacion(etiqueta: 'Mi auto', icono: LucideIcons300.car),
          DestinoNavegacion(
            etiqueta: 'Servicio',
            icono: LucideIcons300.wrench,
            conteo: 3,
          ),
          DestinoNavegacion(
            etiqueta: 'Explorar',
            icono: LucideIcons300.compass,
          ),
          DestinoNavegacion(etiqueta: 'Cuenta', icono: LucideIcons300.user),
        ],
        indice: valor,
        alCambiar: cambiar,
      ),
    ),
  ),
  SeccionGaleria(
    titulo: 'Mensajes',
    construir: (context) => Column(
      children: [
        const BurbujaMensaje(
          texto: '¿Qué significa la luz naranja del motor?',
          autor: AutorMensaje.propio,
          nombreAutor: 'Tú',
          hora: '10:42',
          estado: EstadoEnvio.enviado,
        ),
        const SizedBox(height: Espaciado.e2),
        BurbujaMensaje(
          texto:
              'Es el testigo de revisión del motor. Conviene agendar una '
              'revisión pronto.',
          autor: AutorMensaje.ajeno,
          nombreAutor: 'CareCar',
          hora: '10:42',
          fuentes: [
            FuenteMensaje(
              texto: 'Manual, pág. 214',
              etiquetaLector: 'Manual, página 214, abrir',
              alTocar: () {},
            ),
          ],
        ),
        const SizedBox(height: Espaciado.e2),
        BurbujaMensaje(
          texto: '¿Y la presión de las llantas?',
          autor: AutorMensaje.propio,
          nombreAutor: 'Tú',
          estado: EstadoEnvio.fallido,
          alReintentar: () {},
        ),
        const SizedBox(height: Espaciado.e3),
        CampoMensaje(alEnviar: (_) {}, alAdjuntar: () {}),
      ],
    ),
  ),
  SeccionGaleria(
    titulo: 'Superficie liquida y busqueda',
    construir: (context) => Column(
      children: [
        const CampoBusquedaLiquido(
          sugerencia: 'Buscar modelo, servicio o refacción…',
        ),
        const SizedBox(height: Espaciado.e4),
        SuperficieLiquida(
          padding: const EdgeInsets.all(Espaciado.e4),
          child: Row(
            children: [
              const Icon(LucideIcons300.sparkles, color: Color(0xFF2457F5)),
              const SizedBox(width: Espaciado.e3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Efecto cristal líquido',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Desenfoque gaussiano dinámico con refracción y rebote elástico.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
];
