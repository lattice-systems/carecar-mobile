import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/privacidad/privacidad.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:carecar_mobile/nucleo/inicio/inicio_nuevo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

/// V2-M22.01 de punta a punta: sesión, verificador, guardia, puerta y regreso
/// a donde iba la persona. Solo se sustituye la API.
AvisoPrivacidad _aviso({required bool aceptado}) => AvisoPrivacidad(
  id: 3,
  version: 2,
  texto: 'Primer párrafo del aviso.\n\nSegundo párrafo del aviso.',
  vigenteDesde: DateTime.utc(2026, 11, 25, 18),
  aceptado: aceptado,
  aceptadoEn: aceptado ? DateTime.utc(2026, 11, 26) : null,
);

class _Escena {
  _Escena(this.api, this.sesion);
  final ApiFalsa api;
  final ControladorSesion sesion;
  final aceptados = <int>[];
}

Future<_Escena> _montar(
  WidgetTester tester, {
  required Future<AvisoPrivacidad> Function(_Escena escena) aviso,
  bool conSesion = false,
}) async {
  // El idioma del telefono: los textos de la puerta salen del idioma de la app.
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  final escena = _Escena(api, sesion);
  api.alPedirAvisoDePrivacidad = () => aviso(escena);
  api.alAceptarAvisoDePrivacidad = (id) async {
    escena.aceptados.add(id);
    return AceptacionAviso(
      avisoId: id,
      version: 2,
      aceptadoEn: DateTime.utc(2026, 11, 26),
    );
  };
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      envolver: (app) => VerificadorDeAviso(child: app),
    ),
  );
  await tester.pumpAndSettle();
  return escena;
}

String _ubicacion(WidgetTester tester) =>
    enrutadorDe(tester).routerDelegate.currentConfiguration.uri.toString();

void main() {
  group('la puerta del aviso de privacidad (V2-M22.01)', () {
    testWidgets('al iniciar sesion sin haberlo aceptado, la puerta va antes '
        'del inicio y al aceptar se llega al inicio', (tester) async {
      var aceptado = false;
      final escena = await _montar(
        tester,
        aviso: (e) async => _aviso(aceptado: aceptado),
      );
      expect(_ubicacion(tester), startsWith(Rutas.acceso));

      await escena.sesion.iniciarSesion(
        correo: 'a@b.mx',
        contrasena: 'CareCar2026',
      );
      await tester.pumpAndSettle();

      expect(_ubicacion(tester), Rutas.aceptarAviso);
      expect(find.text('Acepto el aviso de privacidad'), findsOneWidget);
      expect(find.byType(InicioNuevo), findsNothing);

      aceptado = true;
      await tester.tap(find.text('Acepto el aviso de privacidad'));
      await tester.pumpAndSettle();

      expect(escena.aceptados, [3]);
      expect(_ubicacion(tester), Rutas.inicio);
      expect(find.byType(InicioNuevo), findsOneWidget);
    });

    testWidgets('con una sesion restaurada tambien se pide, y se vuelve al '
        'enlace que se abrio', (tester) async {
      var aceptado = false;
      final escena = await _montar(
        tester,
        conSesion: true,
        aviso: (e) async => _aviso(aceptado: aceptado),
      );
      expect(_ubicacion(tester), Rutas.aceptarAviso);

      // Un enlace a otra pantalla no se salta la puerta y se recuerda.
      enrutadorDe(tester).go(rutaAvisoPrivacidad);
      await tester.pumpAndSettle();
      expect(
        _ubicacion(tester),
        '/privacidad/aceptar?desde=%2Fprivacidad%2Faviso',
      );

      aceptado = true;
      await tester.tap(find.text('Acepto el aviso de privacidad'));
      await tester.pumpAndSettle();

      expect(escena.aceptados, [3]);
      expect(_ubicacion(tester), rutaAvisoPrivacidad);
      expect(find.textContaining('Lo aceptaste el'), findsOneWidget);
    });

    testWidgets('con el aviso ya aceptado no hay puerta', (tester) async {
      await _montar(
        tester,
        conSesion: true,
        aviso: (e) async => _aviso(aceptado: true),
      );

      expect(_ubicacion(tester), Rutas.inicio);
      expect(find.byType(InicioNuevo), findsOneWidget);
    });

    testWidgets('sin conexion no deja a nadie fuera de la app', (tester) async {
      await _montar(
        tester,
        conSesion: true,
        aviso: (e) => Future.error(const SinConexion()),
      );

      expect(_ubicacion(tester), Rutas.inicio);
      expect(find.byType(InicioNuevo), findsOneWidget);
    });

    testWidgets('quien no acepta cierra la sesion y vuelve al acceso', (
      tester,
    ) async {
      final escena = await _montar(
        tester,
        conSesion: true,
        aviso: (e) async => _aviso(aceptado: false),
      );
      expect(_ubicacion(tester), Rutas.aceptarAviso);

      await tester.tap(find.text('No acepto, cerrar sesión'));
      await tester.pumpAndSettle();

      expect(escena.aceptados, isEmpty);
      expect(escena.sesion.estado, isA<SinSesion>());
      expect(_ubicacion(tester), startsWith(Rutas.acceso));
    });

    testWidgets(
      'una version nueva mientras se lee pide leerla antes de aceptar',
      (tester) async {
        var version = 2;
        final escena = await _montar(
          tester,
          conSesion: true,
          aviso: (e) async => AvisoPrivacidad(
            id: version + 1,
            version: version,
            texto: 'Texto de la versión $version.',
            vigenteDesde: DateTime.utc(2026, 11, 25, 18),
            aceptado: false,
          ),
        );
        expect(find.text('Texto de la versión 2.'), findsOneWidget);

        // La agencia publica la 3 y el servidor rechaza aceptar la 2.
        version = 3;
        escena.api.alAceptarAvisoDePrivacidad = (id) {
          escena.aceptados.add(id);
          return Future.error(
            Conflicto(
              'x',
              problema: Problema.fromJson({
                'timestamp': '2026-11-25T18:00:00Z',
                'status': 409,
                'error': 'Conflict',
                'message': 'x',
                'path': '/privacidad/aceptaciones',
                'codigo': 'AVISO_NO_VIGENTE',
              }),
            ),
          );
        };
        await tester.tap(find.text('Acepto el aviso de privacidad'));
        await tester.pumpAndSettle();

        expect(escena.aceptados, [3]);
        expect(find.text('Texto de la versión 3.'), findsOneWidget);
        expect(
          find.textContaining('El aviso cambió mientras lo leías'),
          findsOneWidget,
        );
        expect(_ubicacion(tester), Rutas.aceptarAviso);
      },
    );
  });
}
