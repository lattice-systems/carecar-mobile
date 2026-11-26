import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import 'proveedores_ejemplo.dart';

/// Pantalla de ejemplo: resuelve los cinco estados de la arquitectura
/// (cargando, datos, vacio, error con reintento, sin conexion) con
/// componentes de `nucleo/diseno`. Se copia como modelo; se borra en
/// V2-T01.07.
class PantallaAvisos extends ConsumerWidget {
  const PantallaAvisos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avisos = ref.watch(avisosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Avisos')),
      body: avisos.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(avisosProvider),
        ),
        data: (lista) => lista.isEmpty
            ? const EstadoVacio(
                titulo: 'Sin avisos',
                mensaje: 'Cuando haya algo para ti, aparecera aqui.',
              )
            : ListView(
                children: [
                  for (final a in lista)
                    FilaLista(
                      titulo: a.titulo,
                      subtitulo: a.detalle,
                      inicio: a.urgente
                          ? const Icon(LucideIcons300.circleAlert)
                          : null,
                      conChevron: false,
                    ),
                ],
              ),
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando',
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
