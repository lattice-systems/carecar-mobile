import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// V2-T04.05: las notas de cada Release salen de los commits convencionales.
void main() {
  final script = File('scripts/notas-de-version.sh').absolute.path;

  late Directory repo;

  ProcessResult git(List<String> args) {
    final r = Process.runSync('git', args, workingDirectory: repo.path);
    expect(r.exitCode, 0, reason: '${r.stderr}');
    return r;
  }

  void commit(String asunto) {
    File('${repo.path}/a.txt').writeAsStringSync(asunto, mode: FileMode.append);
    git(['add', '.']);
    git(['commit', '-q', '-m', asunto]);
  }

  setUp(() {
    repo = Directory.systemTemp.createTempSync('notas_');
    git(['init', '-q']);
    git(['config', 'user.email', 'prueba@ejemplo.mx']);
    git(['config', 'user.name', 'Prueba']);
    git(['config', 'commit.gpgsign', 'false']);
    git(['config', 'core.hooksPath', '/dev/null']);
    commit('feat(citas): agendar una cita');
    git(['tag', 'v1.0.0']);
    commit('feat(asistente): ver la respuesta mientras se escribe');
    commit('fix(api): leer bien los errores del flujo');
    commit('docs(tablero): tomar V2-T04.05');
    commit('ci: firmar el Release');
    commit('un commit sin formato');
    git(['tag', 'v1.1.0']);
  });

  tearDown(() => repo.deleteSync(recursive: true));

  String notas(String etiqueta) {
    final r = Process.runSync('bash', [
      script,
      etiqueta,
    ], workingDirectory: repo.path);
    expect(r.exitCode, 0, reason: '${r.stderr}');
    return r.stdout as String;
  }

  test('agrupa novedades y correcciones desde la etiqueta anterior', () {
    final texto = notas('v1.1.0');
    expect(texto, contains('## CareCar v1.1.0'));
    expect(texto, contains('Cambios desde v1.0.0.'));
    expect(
      texto,
      contains(
        '### Novedades\n\n- Ver la respuesta mientras se escribe (asistente)',
      ),
    );
    expect(
      texto,
      contains('### Correcciones\n\n- Leer bien los errores del flujo (api)'),
    );
    expect(texto, isNot(contains('agendar una cita')));
    expect(texto, contains('Además, 3 cambios de mantenimiento'));
  });

  test('la primera version toma todo el historial', () {
    final texto = notas('v1.0.0');
    expect(texto, contains('Primera versión.'));
    expect(texto, contains('- Agendar una cita (citas)'));
  });

  test('release.yml usa estas notas', () {
    final flujo = File('.github/workflows/release.yml').readAsStringSync();
    expect(flujo, contains('scripts/notas-de-version.sh'));
  });
}
