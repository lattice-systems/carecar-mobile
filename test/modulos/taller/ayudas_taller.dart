import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/proveedores_taller.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../ayudas/tema_pista.dart';

final Uint8List pngDePrueba = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// Videos que la pantalla pidio abrir.
final videosAbiertos = <Uri>[];

/// La pantalla del taller con su fake, el canal de eventos en memoria, el tema
/// Pista y sin movimiento, para que la etapa actual no respire y
/// `pumpAndSettle` termine.
Widget appTaller(
  Widget pantalla,
  RepositorioTallerFake repo, {
  Escenario escenario = Escenario.claro,
  double ancho = 360,
  bool abreVideo = true,
  Locale idioma = idiomaBase,
  EventosEnVivoFake? eventos,
}) => ProviderScope(
  overrides: [
    repositorioTallerProvider.overrideWithValue(repo),
    eventosEnVivoProvider.overrideWithValue(eventos ?? EventosEnVivoFake()),
    imagenEvidenciaProvider.overrideWithValue((_) => MemoryImage(pngDePrueba)),
    abrirVideoProvider.overrideWithValue((url) async {
      videosAbiertos.add(url);
      return abreVideo;
    }),
    exportarFirmaProvider.overrideWithValue((_, _) async => pngDePrueba),
  ],
  child: conTemaPista(
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: pantalla,
      ),
    ),
    escenario: escenario,
    ancho: ancho,
    idioma: idioma,
  ),
);

/// Pantalla alta para que todo quepa sin desplazar.
void pruebaTaller(
  String descripcion,
  Future<void> Function(WidgetTester) cuerpo,
) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    videosAbiertos.clear();
    await cuerpo(tester);
  });
}

/// Dia y hora como los muestra la app en espanol. Se llama despues de montar
/// la app, cuando ya se cargaron los datos del idioma.
String hora(DateTime momento) => DateFormat.MMMd('es').add_Hm().format(momento);

/// Solo la hora, como la linea de tiempo.
String horaCorta(DateTime momento) => DateFormat.Hm('es').format(momento);

/// El dia con su nombre, como el horario para recoger el auto.
String dia(DateTime fecha) => DateFormat.MMMEd('es').format(fecha);
