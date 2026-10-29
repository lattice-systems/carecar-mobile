import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../api/modelos/perfil.dart';
import '../tema/tema_carecar.dart';
import '../widgets/carga_datos.dart';
import '../widgets/dato_lectura.dart';
import '../widgets/pagina_carecar.dart';

class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });
  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: 'Ajustes',
    alCerrarSesion: alCerrarSesion,
    contenido: CargaDatos<Perfil>(
      cargar: api.miPerfil,
      mensajeCarga: 'Cargando perfil…',
      mensajeError: 'No se pudo cargar tu perfil',
      construir: (perfil) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información del perfil',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: TemaCareCar.espacioCampos),
                DatoLectura('Nombre', perfil.nombre),
                DatoLectura('Correo', perfil.correo),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
