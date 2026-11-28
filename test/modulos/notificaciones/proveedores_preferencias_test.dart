import 'package:carecar_mobile/modulos/notificaciones/dominio/aviso_cliente.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/preferencias_de_avisos.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/proveedores_preferencias.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M06.05 · guardar las preferencias sin botón de guardar.
///
/// Se guarda al tocar cada interruptor. Lo que se prueba es lo que eso exige:
/// que se pinte al instante y que **se revierta si el servidor falla**, porque
/// un interruptor que se queda mintiendo es peor que uno lento.
void main() {
  late _RepoFalso repo;

  ProviderContainer contenedor() {
    repo = _RepoFalso();
    final c = ProviderContainer(
      overrides: [repositorioPreferenciasProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('carga las preferencias del servidor', () async {
    final c = contenedor();

    final p = await c.read(preferenciasDeAvisosProvider.future);

    expect(p.porCategoria[CategoriaDeAviso.promociones], isFalse);
  });

  test('prender una categoría se pinta y se guarda', () async {
    final c = contenedor();
    await c.read(preferenciasDeAvisosProvider.future);

    await c
        .read(preferenciasDeAvisosProvider.notifier)
        .cambiar(CategoriaDeAviso.promociones, true);

    final p = c.read(preferenciasDeAvisosProvider).requireValue;
    expect(p.porCategoria[CategoriaDeAviso.promociones], isTrue);
    expect(repo.guardados, 1);
  });

  test('si el servidor falla, el interruptor se revierte', () async {
    final c = contenedor();
    await c.read(preferenciasDeAvisosProvider.future);
    repo.falla = true;

    await c
        .read(preferenciasDeAvisosProvider.notifier)
        .cambiar(CategoriaDeAviso.taller, false);

    // Un interruptor que se queda mintiendo es peor que uno lento: la persona
    // creería que apagó algo que sigue encendido.
    final p = c.read(preferenciasDeAvisosProvider).requireValue;
    expect(p.porCategoria[CategoriaDeAviso.taller], isTrue);
    expect(c.read(preferenciasDeAvisosProvider.notifier).ultimoFallo, isTrue);
  });

  test('poner un horario lo guarda', () async {
    final c = contenedor();
    await c.read(preferenciasDeAvisosProvider.future);

    await c
        .read(preferenciasDeAvisosProvider.notifier)
        .ponerHorario(
          const HorarioSilencioso(
            desde: HoraDelDia(22, 0),
            hasta: HoraDelDia(7, 0),
          ),
        );

    final p = c.read(preferenciasDeAvisosProvider).requireValue;
    expect(p.silencio!.desde, const HoraDelDia(22, 0));
    expect(repo.guardados, 1);
  });

  test('quitar el horario lo guarda y deja las categorías', () async {
    final c = contenedor();
    await c.read(preferenciasDeAvisosProvider.future);
    await c
        .read(preferenciasDeAvisosProvider.notifier)
        .ponerHorario(
          const HorarioSilencioso(
            desde: HoraDelDia(22, 0),
            hasta: HoraDelDia(7, 0),
          ),
        );

    await c.read(preferenciasDeAvisosProvider.notifier).quitarHorario();

    final p = c.read(preferenciasDeAvisosProvider).requireValue;
    expect(p.silencio, isNull);
    expect(p.porCategoria[CategoriaDeAviso.taller], isTrue);
  });

  test('un fallo se olvida al siguiente cambio bueno', () async {
    final c = contenedor();
    await c.read(preferenciasDeAvisosProvider.future);
    repo.falla = true;
    await c
        .read(preferenciasDeAvisosProvider.notifier)
        .cambiar(CategoriaDeAviso.taller, false);
    expect(c.read(preferenciasDeAvisosProvider.notifier).ultimoFallo, isTrue);

    repo.falla = false;
    await c
        .read(preferenciasDeAvisosProvider.notifier)
        .cambiar(CategoriaDeAviso.taller, false);

    expect(c.read(preferenciasDeAvisosProvider.notifier).ultimoFallo, isFalse);
  });
}

class _RepoFalso implements RepositorioPreferenciasAvisos {
  bool falla = false;
  int guardados = 0;

  PreferenciasDeAvisos _actual = const PreferenciasDeAvisos(
    porCategoria: {
      CategoriaDeAviso.taller: true,
      CategoriaDeAviso.citas: true,
      CategoriaDeAviso.mantenimiento: true,
      CategoriaDeAviso.documentos: true,
      CategoriaDeAviso.promociones: false,
      CategoriaDeAviso.mensajes: true,
    },
    silencio: null,
  );

  @override
  Future<PreferenciasDeAvisos> preferencias() async => _actual;

  @override
  Future<PreferenciasDeAvisos> guardar(PreferenciasDeAvisos nuevas) async {
    if (falla) throw Exception('no se pudo guardar');
    guardados++;
    _actual = nuevas;
    return nuevas;
  }
}
