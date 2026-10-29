import 'package:flutter/material.dart';

import '../tema/tema_carecar.dart';
import 'menu_carecar.dart';

class PaginaCareCar extends StatelessWidget {
  const PaginaCareCar({
    required this.titulo,
    required this.contenido,
    required this.alCerrarSesion,
    this.regresar = true,
    this.expandir = false,
    super.key,
  });
  final String titulo;
  final Widget contenido;
  final VoidCallback alCerrarSesion;
  final bool regresar;
  final bool expandir;

  static const botonCerrarSesion = Key('inicio_cerrar_sesion');

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: TemaCareCar.fondo,
      foregroundColor: TemaCareCar.azulAgencia,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 142,
      leading: regresar
          ? TextButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Regresar'),
            )
          : null,
      actions: [
        IconButton(
          key: botonCerrarSesion,
          onPressed: alCerrarSesion,
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: SafeArea(
      top: false,
      child: expandir
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(TemaCareCar.espacioCampos),
                  child: Text(
                    titulo,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(child: contenido),
              ],
            )
          : SingleChildScrollView(
              key: PageStorageKey(titulo),
              padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: EstiloMenu.anchoMaximo,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            titulo,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: TemaCareCar.espacioSecciones),
                        contenido,
                      ],
                    ),
                  ),
                ),
              ),
            ),
    ),
  );
}
