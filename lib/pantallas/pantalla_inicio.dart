import 'package:flutter/material.dart';

import '../sesion/controlador_sesion.dart';
import '../tema/tema_carecar.dart';

/// Pantalla a la que se llega despues del login.
///
/// **Es un marcador de posicion.** APP-2.1 solo pide el acceso; «Mis
/// vehiculos» es APP-3.1 y entra en S2. Aqui solo se comprueba que la sesion
/// quedo iniciada y se puede cerrar.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({
    required this.controlador,
    required this.alCerrarSesion,
    super.key,
  });

  final ControladorSesion controlador;
  final VoidCallback alCerrarSesion;

  static const botonCerrarSesion = Key('inicio_cerrar_sesion');

  @override
  Widget build(BuildContext context) {
    final estado = controlador.estado;
    final debeCambiar = estado is Autenticada && estado.debeCambiarContrasena;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareCar'),
        actions: [
          IconButton(
            key: botonCerrarSesion,
            onPressed: () async {
              await controlador.cerrarSesion();
              alCerrarSesion();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 56,
              color: TemaCareCar.exito,
            ),
            const SizedBox(height: TemaCareCar.espacioCampos),
            Text(
              'Sesión iniciada',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí irá «Mis vehículos» (APP-3.1, sprint 2).',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: TemaCareCar.textoSecundario),
              textAlign: TextAlign.center,
            ),
            if (debeCambiar) ...[
              const SizedBox(height: TemaCareCar.espacioSecciones),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TemaCareCar.advertenciaFondo,
                  borderRadius: BorderRadius.circular(TemaCareCar.radioControl),
                  border: Border.all(
                    color: TemaCareCar.advertencia.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.key_outlined,
                      size: 20,
                      color: TemaCareCar.advertencia,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tu contraseña es temporal y hay que cambiarla. '
                        'La pantalla de cambio llega en APP-2.3.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: TemaCareCar.advertencia),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
