import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../vehiculos/vehiculos.dart' show garajeProvider;
import '../dominio/solicitud_asistencia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'formulario_pedir_ayuda.dart';
import 'proveedores_asistencia.dart';
import 'vista_solicitud.dart';

/// «Pedir ayuda» (V2-M11.01): el cliente varado manda su solicitud con
/// vehiculo, tipo de problema y, si quiere, su ubicacion.
///
/// Si ya tiene una solicitud abierta (al entrar o porque el servidor contesto
/// 409) muestra esa y no deja crear otra. Resuelve los cinco estados:
/// cargando, error con reintento, garaje vacio, formulario y solicitud
/// enviada; la falta de conexion al enviar se avisa dentro del formulario.
class PantallaPedirAyuda extends ConsumerStatefulWidget {
  const PantallaPedirAyuda({super.key});

  @override
  ConsumerState<PantallaPedirAyuda> createState() => _PantallaPedirAyudaState();
}

class _PantallaPedirAyudaState extends ConsumerState<PantallaPedirAyuda> {
  SolicitudAsistencia? _enviada;
  bool _yaAbierta = false;

  void _alEnviar(SolicitudAsistencia solicitud, {required bool yaAbierta}) {
    setState(() {
      _enviada = solicitud;
      _yaAbierta = yaAbierta;
    });
  }

  @override
  Widget build(BuildContext context) {
    final enviada = _enviada;
    if (enviada != null) {
      return VistaSolicitud(solicitud: enviada, yaAbierta: _yaAbierta);
    }

    final textos = AppLocalizations.of(context);
    final activa = ref.watch(solicitudActivaProvider);

    return activa.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        icono: LucideIcons300.lifeBuoy,
        titulo: textos.asistenciaPedirTitulo,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        icono: LucideIcons300.lifeBuoy,
        titulo: textos.asistenciaPedirTitulo,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(solicitudActivaProvider),
        ),
      ),
      data: (abierta) => abierta != null
          ? VistaSolicitud(solicitud: abierta, yaAbierta: true)
          : _ConGaraje(alEnviar: _alEnviar),
    );
  }
}

class _ConGaraje extends ConsumerWidget {
  const _ConGaraje({required this.alEnviar});

  final AlEnviarSolicitud alEnviar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final garaje = ref.watch(garajeProvider);

    return garaje.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        icono: LucideIcons300.lifeBuoy,
        titulo: textos.asistenciaPedirTitulo,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        icono: LucideIcons300.lifeBuoy,
        titulo: textos.asistenciaPedirTitulo,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(garajeProvider),
        ),
      ),
      data: (vehiculos) => vehiculos.isEmpty
          ? MarcoPantalla.estado(
              icono: LucideIcons300.lifeBuoy,
              titulo: textos.asistenciaPedirTitulo,
              estado: EstadoVacio(
                titulo: textos.asistenciaGarajeVacioTitulo,
                mensaje: textos.asistenciaGarajeVacioMensaje,
                icono: LucideIcons300.car,
              ),
            )
          : MarcoPantalla(
              icono: LucideIcons300.lifeBuoy,
              titulo: textos.asistenciaPedirTitulo,
              slivers: [
                SliverToBoxAdapter(
                  child: FormularioPedirAyuda(
                    vehiculos: vehiculos,
                    alEnviar: alEnviar,
                  ),
                ),
              ],
            ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).asistenciaPedirCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 120, radio: 28),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
            ],
          ),
        ),
      ),
    );
  }
}
