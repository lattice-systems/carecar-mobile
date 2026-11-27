import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_fake.dart';
import 'package:carecar_mobile/modulos/historial/historial.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_adicionales.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_inspeccion.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_orden.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/proveedores_taller.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';
import '../../modulos/taller/ayudas_taller.dart';

void main() {
  testWidgets('las pantallas de taller pasan la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioTallerProvider.overrideWithValue(RepositorioTallerFake()),
        repositorioHistorialProvider.overrideWithValue(
          RepositorioHistorialFake(),
        ),
        imagenEvidenciaProvider.overrideWithValue(
          (_) => MemoryImage(pngDePrueba),
        ),
      ],
    );
    await auditarRutas(tester, {
      rutaOrdenTaller(41): PantallaOrden,
      rutaInspeccionTaller(41): PantallaInspeccion,
      rutaAdicionalesTaller(41): PantallaAdicionales,
    });
  });
}
