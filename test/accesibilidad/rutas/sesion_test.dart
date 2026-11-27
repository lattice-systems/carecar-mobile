import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';

void main() {
  testWidgets('mi perfil y mis sesiones pasan la auditoría', (tester) async {
    await montarParaAuditar(tester);
    await auditarRutas(tester, {
      rutaMiPerfil: PantallaMiPerfil,
      rutaSesiones: PantallaSesiones,
    });
  });
}
