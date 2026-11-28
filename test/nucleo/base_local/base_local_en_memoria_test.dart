import 'package:carecar_mobile/nucleo/base_local/base_local_en_memoria.dart';
import 'package:flutter_test/flutter_test.dart';

import 'contrato_base_local.dart';

void main() {
  group('BaseLocalEnMemoria (V2-M21.01)', () {
    ejecutarContratoBaseLocal((reloj) => BaseLocalEnMemoria(reloj: reloj));
  });
}
