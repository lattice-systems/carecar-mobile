import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_fake.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/pantalla_cambiar_contrasena.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/proveedores_acceso.dart';
import 'package:carecar_mobile/nucleo/navegacion/guardia_sesion.dart';
import 'package:carecar_mobile/nucleo/navegacion/proveedores_navegacion.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/tema_pista.dart';

/// V2-M01.03 · «no puedo navegar a otra pantalla hasta cambiarla».
///
/// La regla la aplica `redirigirPorSesion`, y sus casos ya estan probados en
/// `test/nucleo/navegacion/guardia_sesion_test.dart`. Aqui no se repiten: lo
/// que falta comprobar es **el apreton de manos**, que la pantalla ponga
/// exactamente la bandera que el guardia lee. Si cada lado funciona y no se
/// entienden, el cliente queda encerrado en el cambio para siempre.
void main() {
  const temporal = Autenticada(debeCambiarContrasena: true);

  group('el apreton de manos con el guardia', () {
    testWidgets('antes de cambiarla, el guardia trae de vuelta aqui', (
      tester,
    ) async {
      // Sin la bandera, cualquier destino cae en el cambio obligatorio.
      expect(
        redirigirPorSesion(
          destino: Uri.parse(Rutas.inicio),
          estado: temporal,
          contrasenaCambiada: false,
        ),
        Rutas.cambiarContrasena,
      );
    });

    testWidgets('la pantalla pone la bandera que el guardia lee', (
      tester,
    ) async {
      final repositorio = RepositorioAccesoFake();
      late ProviderContainer contenedor;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            controladorSesionProvider.overrideWithValue(
              ControladorSesion(ApiFalsa(), AlmacenEnMemoria()),
            ),
            repositorioAccesoProvider.overrideWithValue(repositorio),
          ],
          child: conTemaPista(
            Consumer(
              builder: (context, ref, _) {
                contenedor = ProviderScope.containerOf(context);
                return const PantallaCambiarContrasena();
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoActual),
        'Temporal123',
      );
      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoNueva),
        'carecar2026',
      );
      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoConfirmar),
        'carecar2026',
      );
      final boton = find.byKey(PantallaCambiarContrasena.botonGuardar);
      await tester.ensureVisible(boton);
      await tester.pump();
      await tester.tap(boton);
      await tester.pumpAndSettle();

      final bandera = contenedor.read(contrasenaCambiadaProvider);
      expect(bandera, isTrue);

      // Y con esa bandera el guardia por fin deja salir. Es la vuelta
      // completa: pantalla → bandera → guardia.
      expect(
        redirigirPorSesion(
          destino: Uri.parse(Rutas.cambiarContrasena),
          estado: temporal,
          contrasenaCambiada: bandera,
        ),
        Rutas.inicio,
      );
    });
  });

  group('la bandera no sobrevive a cerrar sesion', () {
    test('al cerrar sesion vuelve a apagarse', () async {
      // Importa de verdad: si se quedara encendida, el siguiente cliente que
      // entre en este telefono con una contrasena temporal **se saltaria el
      // cambio obligatorio**. El comentario del nucleo dice que se apaga
      // sola; esto lo comprueba, porque no tenia ninguna prueba.
      final sesion = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
      final contenedor = ProviderContainer(
        overrides: [controladorSesionProvider.overrideWithValue(sesion)],
      );
      addTearDown(contenedor.dispose);

      // Hay que estar escuchando para que el notificador reaccione.
      contenedor.listen(contrasenaCambiadaProvider, (_, _) {});
      await sesion.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );
      contenedor.read(contrasenaCambiadaProvider.notifier).marcarCambiada();
      expect(contenedor.read(contrasenaCambiadaProvider), isTrue);

      await sesion.cerrarSesion();

      expect(contenedor.read(contrasenaCambiadaProvider), isFalse);
    });
  });
}
