import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';

import '../api/carecar_api.dart';
import '../api/modelos/perfil.dart';
import '../modulos/taller/taller.dart';
import '../nucleo/migracion/interruptor_modulos.dart';
import '../notificaciones/servicio_notificaciones.dart';
import '../sesion/controlador_sesion.dart';
import '../tema/tema_carecar.dart';
import '../widgets/menu_carecar.dart';
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
        builder: (context) => PaginaCareCar(
          titulo: 'Menú',
          regresar: false,
          cabecera: FutureBuilder<Perfil>(
            future: _perfil,
            builder: (context, snap) {
              final nombre = snap.data?.nombre.trim() ?? '';
              if (nombre.isEmpty) return const SizedBox.shrink();
              return _Saludo(nombre: nombre);
            },
          ),
          alCerrarSesion: _cerrarSesion,
          contenido: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TarjetaOrdenEnCurso(),
              RejillaMenu(
                tarjetas: [
                  TarjetaMenu(
                    titulo: 'Mis vehículos',
                    subtitulo: 'Tus autos, fichas y manuales',
                    icono: IconoMenu.vehiculos.icono,
                    colores: [
                      TemaCareCar.azulAgencia,
                      TemaCareCar.azulProfundo,
                    ],
                    indice: 0,
                    alPulsar:
                        widget.abrirEnV2[ModuloMigrable.vehiculos] ??
                        () => abrirPantalla(
                          context,
                          PantallaVehiculos(
                            api: widget.api,
                            alCerrarSesion: _cerrarSesion,
                          ),
                        ),
                  ),
                  TarjetaMenu(
                    titulo: 'Citas',
                    subtitulo: 'Agenda y revisa tus citas',
                    icono: IconoMenu.cita.icono,
                    colores: [TemaCareCar.turquesaOscuro, Color(0xFF0E6B63)],
                    indice: 1,
                    alPulsar:
                        widget.abrirEnV2[ModuloMigrable.citas] ??
                        () => abrirPantalla(
                          context,
                          PantallaMisCitas(
                            api: widget.api,
                            alCerrarSesion: _cerrarSesion,
                          ),
                        ),
                  ),
                  TarjetaMenu(
                    titulo: 'Catálogo',
                    subtitulo: 'Conoce los modelos Nissan',
                    icono: IconoMenu.catalogo.icono,
                    colores: [Color(0xFF3D5A9E), Color(0xFF283C7A)],
                    indice: 2,
                    alPulsar:
                        widget.abrirEnV2[ModuloMigrable.catalogo] ??
                        () => abrirPantalla(
                          context,
                          PantallaCatalogo(
                            api: widget.api,
                            alCerrarSesion: _cerrarSesion,
                          ),
                        ),
                  ),
                  TarjetaMenu(
                    titulo: 'Ajustes',
                    subtitulo: 'Perfil, contraseña y ayuda',
                    icono: IconoMenu.ajustes.icono,
                    colores: [Color(0xFF52606D), Color(0xFF334155)],
                    indice: 3,
                    alPulsar: () => abrirPantalla(
                      context,
                      PantallaAjustes(
                        api: widget.api,
                        alCerrarSesion: _cerrarSesion,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _iniciales(String nombre) {
  final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return partes.take(2).map((p) => p[0].toUpperCase()).join();
}

/// Saludo con pastilla de iniciales y nombre completo.
class _Saludo extends StatelessWidget {
  const _Saludo({required this.nombre});
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final primero = nombre.split(RegExp(r'\s+')).first;
    // A la derecha del encabezado: textos alineados al borde derecho y la
    // pastilla de iniciales al final.
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Hola, $primero',
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                nombre,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Text(
            _iniciales(nombre),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }
}
