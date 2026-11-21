import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/carecar_api.dart';
import '../../api/modelos/modelos.dart';
import '../../manuales/servicio_manuales.dart';
import '../../tema/tema_carecar.dart';
import '../../widgets/aviso.dart';
import '../../widgets/carga_datos.dart';
import '../../widgets/formato.dart';
import '../../widgets/menu_carecar.dart';
import '../../widgets/movimiento.dart';
import '../../widgets/pagina_carecar.dart';
import '../pantalla_manual.dart';

/// APP-3.2 · Historial de servicios de un vehiculo, con su ticket en PDF.
class PantallaHistorial extends StatelessWidget {
  const PantallaHistorial({
    required this.api,
    required this.vehiculo,
    required this.alCerrarSesion,
    super.key,
  });

  final CarecarApi api;
  final Vehiculo vehiculo;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: 'Historial de servicios',
    alCerrarSesion: alCerrarSesion,
    contenido: CargaDatos<List<Servicio>>(
      cargar: () => api.serviciosDe(vehiculo.id),
      mensajeCarga: 'Cargando servicios…',
      mensajeError: 'No se pudo cargar el historial',
      construir: (servicios) => servicios.isEmpty
          ? const Aviso.informacion(
              titulo: 'Aún no hay servicios',
              detalle: 'Cuando el taller atienda tu vehículo, aparecerá aquí.',
            )
          : _Linea(
              servicios: servicios,
              abrirTicket: (s) => abrirPantalla(
                context,
                PantallaManual(
                  vehiculo: vehiculo,
                  alCerrarSesion: alCerrarSesion,
                  etiqueta: 'Ticket',
                  servicio: _Tickets(api, s),
                ),
              ),
            ),
    ),
  );
}

/// Baja el ticket del servicio con la API y lo pasa al visor de PDF.
class _Tickets implements ServicioManuales {
  _Tickets(this._api, this._servicio);

  final CarecarApi _api;
  final Servicio _servicio;

  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async {
    final Uint8List bytes = await _api.ticketDe(_servicio.id);
    return DocumentoManual(
      titulo: 'Servicio del ${formatoFecha(_servicio.fecha)}',
      identificador: 'ticket:${_servicio.id}',
      bytes: bytes,
    );
  }
}

/// Linea de tiempo vertical: un punto por servicio y su tarjeta al lado.
class _Linea extends StatelessWidget {
  const _Linea({required this.servicios, required this.abrirTicket});

  final List<Servicio> servicios;
  final void Function(Servicio) abrirTicket;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final (i, s) in servicios.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(top: 22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TemaCareCar.turquesaOscuro,
                          border: Border.all(
                            color: TemaCareCar.azulSuave,
                            width: 3,
                          ),
                        ),
                      ),
                      if (i < servicios.length - 1)
                        const Expanded(
                          child: VerticalDivider(
                            width: 2,
                            thickness: 2,
                            color: TemaCareCar.borde,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Rebote(
                      child: Material(
                        color: TemaCareCar.tarjeta,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: TemaCareCar.borde),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => abrirTicket(s),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        formatoFecha(s.fecha),
                                        style: temas.titleMedium,
                                      ),
                                    ),
                                    ShadBadge(child: Text(_estatus(s.estatus))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    NumeroAnimado(
                                      valor: s.total.round(),
                                      construir: (n) => Text(
                                        '\$${conMiles(n)}',
                                        style: temas.headlineMedium?.copyWith(
                                          color: TemaCareCar.azulAgencia,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 18,
                                      color: TemaCareCar.textoSecundario,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ver ticket',
                                      style: temas.labelLarge?.copyWith(
                                        color: TemaCareCar.textoSecundario,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: (90 * i).ms).fadeIn().slideX(begin: 0.1),
      ],
    );
  }

  /// «TERMINADO» → «Terminado». El contrato deja libres los valores (PO-5).
  String _estatus(String e) =>
      e.isEmpty ? e : e[0].toUpperCase() + e.substring(1).toLowerCase();
}
