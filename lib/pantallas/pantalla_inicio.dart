import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
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
                subtitulo: 'Tus autos, fichas y manuales',
                icono: IconoMenu.vehiculos.icono,
                colores: [TemaCareCar.azulAgencia, TemaCareCar.azulProfundo],
                indice: 0,
                alPulsar: () => abrirPantalla(
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
                alPulsar: () => abrirPantalla(
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
                alPulsar: () => abrirPantalla(
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
        ),
      ),
    ),
  );
}
