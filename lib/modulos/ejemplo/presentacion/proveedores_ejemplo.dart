import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/repositorio_avisos_fake.dart';
import '../dominio/aviso.dart';
import '../dominio/repositorio_avisos.dart';

/// Repositorio del modulo. En pruebas: `repositorioAvisosProvider.overrideWithValue(...)`.
final repositorioAvisosProvider = Provider<RepositorioAvisos>(
  (ref) => RepositorioAvisosFake(),
  name: 'repositorioAvisosProvider',
);

/// Avisos ordenados. El `AsyncValue` ya trae cargando, datos y error.
final avisosProvider = FutureProvider<List<Aviso>>(
  (ref) async =>
      Aviso.ordenar(await ref.watch(repositorioAvisosProvider).avisos()),
  // Riverpod 3 reintenta solo los errores; aqui el reintento es del usuario
  // (boton de EstadoError), asi que se apaga.
  retry: (_, _) => null,
  name: 'avisosProvider',
);
