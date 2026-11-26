import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/carecar_api.dart';
import '../../api/excepciones.dart';
import '../../api/modelos/modelos.dart';
import '../../manuales/servicio_manuales.dart';
import '../../tema/tema_carecar.dart';
import '../../widgets/aviso.dart';
import '../../widgets/carga_datos.dart';
import '../../widgets/formato.dart';
import '../../widgets/menu_carecar.dart';
import '../../widgets/movimiento.dart';
import '../../widgets/pagina_carecar.dart';
import '../../widgets/pantalla.dart';
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

  static const botonCargarMas = Key('historial_cargar_mas');

  @override
  Widget build(BuildContext context) {
    final recargador = Recargador();
    return PaginaCareCar(
      titulo: 'Historial de servicios',
      anchoMaximo: Pantalla.anchoLectura,
      alCerrarSesion: alCerrarSesion,
      alRefrescar: recargador.recargar,
      contenido: CargaDatos<Pagina<Servicio>>(
        recargador: recargador,
        cargar: () => api.paginaDeServicios(vehiculo.id),
        mensajeCarga: 'Cargando servicios…',
        mensajeError: 'No se pudo cargar el historial',
        construir: (primera) => primera.contenido.isEmpty
            ? const Aviso.informacion(
                titulo: 'Aún no hay servicios',
                detalle:
                    'Cuando el taller atienda tu vehículo, aparecerá aquí.',
              )
            : _Linea(
                key: ObjectKey(primera),
                primera: primera,
                siguiente: (n) => api.paginaDeServicios(vehiculo.id, pagina: n),
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
class _Linea extends StatefulWidget {
  const _Linea({
    required this.primera,
    required this.siguiente,
    required this.abrirTicket,
    super.key,
  });

  final Pagina<Servicio> primera;
  final Future<Pagina<Servicio>> Function(int pagina) siguiente;
  final void Function(Servicio) abrirTicket;

  @override
  State<_Linea> createState() => _LineaState();
}

class _LineaState extends State<_Linea> {
  late final List<Servicio> servicios = [...widget.primera.contenido];
  late Pagina<Servicio> _ultima = widget.primera;
  bool _cargando = false;
  String? _error;

  Future<void> _cargarMas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final nueva = await widget.siguiente(_ultima.pagina + 1);
      if (!mounted) return;
      setState(() {
        servicios.addAll(nueva.contenido);
        _ultima = nueva;
      });
    } on ExcepcionApi catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void abrirTicket(Servicio s) => widget.abrirTicket(s);

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
                      // Tramo de arriba: une con el punto anterior sin hueco.
                      SizedBox(
                        height: 22,
                        child: i > 0
                            ? const VerticalDivider(
                                width: 2,
                                thickness: 2,
                                color: TemaCareCar.borde,
                              )
                            : null,
                      ),
                      Container(
                        width: 14,
                        height: 14,
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
                                // Wrap: con letra grande la insignia baja de
                                // linea en vez de desbordarse.
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    Text(
                                      formatoFecha(s.fecha),
                                      style: temas.titleMedium,
                                    ),
                                    ShadBadge(child: Text(_estatus(s.estatus))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
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
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          LucideIcons300.receiptText,
                                          size: 18,
                                          color: TemaCareCar.textoSecundario,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Ver ticket',
                                            style: temas.labelLarge?.copyWith(
                                              color:
                                                  TemaCareCar.textoSecundario,
                                            ),
                                          ),
                                        ),
                                      ],
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
          ).animate(delay: (90 * (i % 20)).ms).fadeIn().slideX(begin: 0.1),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Aviso.error(
              titulo: 'No se pudieron cargar más servicios',
              detalle: _error!,
            ),
          ),
        if (_ultima.hayMas)
          OutlinedButton.icon(
            key: PantallaHistorial.botonCargarMas,
            onPressed: _cargando ? null : _cargarMas,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, TemaCareCar.altoMinimoToque),
            ),
            icon: _cargando
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons300.chevronDown),
            label: Text(_cargando ? 'Cargando…' : 'Cargar más'),
          ),
      ],
    );
  }

  /// «TERMINADO» → «Terminado». El contrato deja libres los valores (PO-5).
  String _estatus(String e) =>
      e.isEmpty ? e : e[0].toUpperCase() + e.substring(1).toLowerCase();
}
