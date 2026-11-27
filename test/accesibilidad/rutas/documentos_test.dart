import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_fake.dart';
import 'package:carecar_mobile/modulos/documentos/documentos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';
import '../../modulos/documentos/ayudas_documentos.dart';

void main() {
  testWidgets('la pantalla de documentos pasa la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioDocumentosProvider.overrideWithValue(
          RepositorioDocumentosFake(documentos: documentosDeEjemplo()),
        ),
      ],
    );
    await auditarRutas(tester, {
      rutaDocumentosVehiculo(5): PantallaDocumentos,
    });
  });
}
