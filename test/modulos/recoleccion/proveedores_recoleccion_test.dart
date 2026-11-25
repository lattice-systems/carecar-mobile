import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/direccion_guardada.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/fallos_recoleccion.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/proveedores_recoleccion.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _borrador = BorradorDireccion(
  alias: 'Casa',
  calle: 'Av. Reforma 100',
  colonia: 'Juárez',
  cp: '06600',
  ciudad: 'CDMX',
  ubicacion: Coordenada(19.4326, -99.1332),
);

ProviderContainer _contenedor(RepositorioRecoleccionFake repo) {
  final c = ProviderContainer(
    overrides: [repositorioRecoleccionProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('direccionesProvider carga las direcciones del repositorio', () async {
    final c = _contenedor(RepositorioRecoleccionFake());
    expect(await c.read(direccionesProvider.future), isEmpty);
  });

  test('guardar suma la dirección a la lista ya cargada', () async {
    final c = _contenedor(RepositorioRecoleccionFake());
    await c.read(direccionesProvider.future);

    final creada = await c
        .read(direccionesProvider.notifier)
        .guardar(_borrador);

    expect(c.read(direccionesProvider).requireValue.map((d) => d.id), [
      creada.id,
    ]);
  });

  test('editar reemplaza la dirección en la lista', () async {
    final c = _contenedor(RepositorioRecoleccionFake());
    final notifier = c.read(direccionesProvider.notifier);
    await c.read(direccionesProvider.future);
    final creada = await notifier.guardar(_borrador);

    await notifier.editar(
      creada.id,
      const BorradorDireccion(
        alias: 'Oficina',
        calle: 'Insurgentes 1',
        colonia: 'Roma',
        cp: '06700',
        ciudad: 'CDMX',
        ubicacion: Coordenada(19.42, -99.16),
      ),
    );

    expect(c.read(direccionesProvider).requireValue.single.alias, 'Oficina');
  });

  test('borrar quita la dirección; en uso la conserva y relanza', () async {
    final c = _contenedor(RepositorioRecoleccionFake(idsEnUso: const {1}));
    final notifier = c.read(direccionesProvider.notifier);
    await c.read(direccionesProvider.future);
    await notifier.guardar(_borrador);
    final otra = await notifier.guardar(_borrador);

    await expectLater(notifier.borrar(1), throwsA(isA<DireccionEnUso>()));
    expect(c.read(direccionesProvider).requireValue, hasLength(2));

    await notifier.borrar(otra.id);
    expect(c.read(direccionesProvider).requireValue.map((d) => d.id), [1]);
  });

  test('la cotización se pide por dirección y día', () async {
    final repo = RepositorioRecoleccionFake(costoPorTraslado: 90);
    final c = _contenedor(repo);
    final d = await repo.guardar(_borrador);

    final cot = await c.read(
      cotizacionRecoleccionProvider((
        direccionId: d.id,
        fecha: DateTime(2026, 11, 26),
      )).future,
    );

    expect(cot.costoTotal, 180);
  });

  test(
    'el checklist no se guarda: se pide de nuevo al volver a abrir',
    () async {
      final repo = RepositorioRecoleccionFake(
        checklists: {
          5: ChecklistTraslado(
            trasladoId: 5,
            km: 100,
            gasolina: NivelGasolina.lleno,
            registradoEn: DateTime.utc(2026, 12),
          ),
        },
      );
      final c = _contenedor(repo);

      final sub = c.listen(checklistTrasladoProvider(5), (_, _) {});
      expect((await c.read(checklistTrasladoProvider(5).future))?.km, 100);
      sub.close();
      await Future<void>.delayed(Duration.zero);
      await c.read(checklistTrasladoProvider(5).future);

      expect(repo.consultasChecklist, 2);
    },
  );
}
