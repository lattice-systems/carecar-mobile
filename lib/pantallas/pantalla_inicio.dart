import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../l10n/app_localizations.dart';
import '../api/modelos/perfil.dart';
import '../modulos/taller/taller.dart';
import '../nucleo/inicio/inicio_nuevo.dart';
import '../nucleo/migracion/interruptor_modulos.dart';
import '../notificaciones/servicio_notificaciones.dart';
import '../sesion/controlador_sesion.dart';
import '../widgets/menu_carecar.dart' show abrirPantalla;
import '../widgets/pagina_carecar.dart';
import 'citas/pantalla_mis_citas.dart';
import 'pantalla_ajustes.dart';
import 'catalogo/pantalla_catalogo.dart';
import 'pantalla_vehiculos.dart';

/// Raiz de la navegacion autenticada. Al salir se descarta toda esta pila.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    required this.api,
    required this.controlador,
    required this.alCerrarSesion,
    this.abrirEnV2 = const {},
    super.key,
  });

  final CarecarApi api;
  final ControladorSesion controlador;
  final VoidCallback alCerrarSesion;

  /// Tarjetas cuyo modulo ya esta en v2 (V2-T01.05): al tocarlas se llama a
  /// esta accion en vez de abrir la pantalla v1. Vacio = todo en v1.
  final Map<ModuloMigrable, VoidCallback> abrirEnV2;
  static const botonCerrarSesion = PaginaCareCar.botonCerrarSesion;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final _navegador = GlobalKey<NavigatorState>();
  bool _cerrando = false;
  late final Future<Perfil> _perfil = widget.api.miPerfil();

  @override
  void initState() {
    super.initState();
    final avisos = Notificaciones.actual;
    avisos.toques.addListener(_abrirCitas);
    // Si la app arranco desde un recordatorio, se abre «Mis citas».
    if (avisos.abrirCitasAlEntrar) {
      avisos.abrirCitasAlEntrar = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _abrirCitas());
    }
  }

  @override
  void dispose() {
    Notificaciones.actual.toques.removeListener(_abrirCitas);
    super.dispose();
  }

  /// Al tocar un recordatorio: vuelve al menu y abre «Mis citas».
  void _abrirCitas() {
    final navegador = _navegador.currentState;
    if (!mounted || navegador == null) return;
    navegador.popUntil((ruta) => ruta.isFirst);
    abrirPantalla(
      navegador.context,
      PantallaMisCitas(api: widget.api, alCerrarSesion: _cerrarSesion),
    );
  }

  Future<void> _cerrarSesion() async {
    if (_cerrando) return;
    _cerrando = true;
    try {
      await widget.controlador.cerrarSesion();
      if (mounted) widget.alCerrarSesion();
    } finally {
      _cerrando = false;
    }
  }

  @override
  Widget build(BuildContext context) => NavigatorPopHandler<Object?>(
    onPopWithResult: (resultado) => _navegador.currentState!.pop(resultado),
    child: Navigator(
      key: _navegador,
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (context) => FutureBuilder<Perfil>(
          future: _perfil,
          builder: (context, snap) {
            final alVehiculos =
                widget.abrirEnV2[ModuloMigrable.vehiculos] ??
                () => abrirPantalla(
                  context,
                  PantallaVehiculos(
                    api: widget.api,
                    alCerrarSesion: _cerrarSesion,
                  ),
                );
            final alCitas =
                widget.abrirEnV2[ModuloMigrable.citas] ??
                () => abrirPantalla(
                  context,
                  PantallaMisCitas(
                    api: widget.api,
                    alCerrarSesion: _cerrarSesion,
                  ),
                );
            final alCatalogo =
                widget.abrirEnV2[ModuloMigrable.catalogo] ??
                () => abrirPantalla(
                  context,
                  PantallaCatalogo(
                    api: widget.api,
                    alCerrarSesion: _cerrarSesion,
                  ),
                );
            final textos = AppLocalizations.of(context);
            return InicioNuevo(
              nombre: snap.data?.nombre,
              ordenEnCurso: const TarjetaOrdenEnCurso(),
              alAgendar: alCitas,
              alAbrirAjustes: () => abrirPantalla(
                context,
                PantallaAjustes(api: widget.api, alCerrarSesion: _cerrarSesion),
              ),
              accesos: [
                AccesoInicio(
                  titulo: textos.inicioAccesoVehiculosTitulo,
                  subtitulo: textos.inicioAccesoVehiculosSubtitulo,
                  icono: Icons.directions_car_outlined,
                  alPulsar: alVehiculos,
                ),
                AccesoInicio(
                  titulo: textos.inicioAccesoCitasTitulo,
                  subtitulo: textos.inicioAccesoCitasSubtitulo,
                  icono: Icons.calendar_month_outlined,
                  alPulsar: alCitas,
                ),
                AccesoInicio(
                  titulo: textos.inicioAccesoCatalogoTitulo,
                  subtitulo: textos.inicioAccesoCatalogoSubtitulo,
                  icono: Icons.grid_view_outlined,
                  alPulsar: alCatalogo,
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
