import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../sesion/controlador_sesion.dart';
import '../tema/tema_carecar.dart';
import '../widgets/menu_carecar.dart';
import '../widgets/pagina_carecar.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_proximamente.dart';
import 'pantalla_vehiculos.dart';

/// Raiz de la navegacion autenticada. Al salir se descarta toda esta pila.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({
    required this.api,
    required this.controlador,
    required this.alCerrarSesion,
    super.key,
  });

  final CarecarApi api;
  final ControladorSesion controlador;
  final VoidCallback alCerrarSesion;
  static const botonCerrarSesion = PaginaCareCar.botonCerrarSesion;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final _navegador = GlobalKey<NavigatorState>();
  bool _cerrando = false;

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
          alCerrarSesion: _cerrarSesion,
          contenido: RejillaMenu(
            tarjetas: [
              TarjetaMenu(
                titulo: 'Mis vehículos',
                imagen: const DibujoMenu(IconoMenu.vehiculos),
                alPulsar: () => abrirPantalla(
                  context,
                  PantallaVehiculos(
                    api: widget.api,
                    alCerrarSesion: _cerrarSesion,
                  ),
                ),
              ),
              TarjetaMenu(
                titulo: 'Catálogo',
                imagen: const DibujoMenu(IconoMenu.catalogo),
                color: TemaCareCar.exitoFondo,
                alPulsar: () => abrirPantalla(
                  context,
                  PantallaProximamente(
                    titulo: 'Catálogo',
                    alCerrarSesion: _cerrarSesion,
                  ),
                ),
              ),
              TarjetaMenu(
                titulo: 'Ajustes',
                imagen: const DibujoMenu(IconoMenu.ajustes),
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
        ),
      ),
    ),
  );
}
