/// El cliente HTTP de la app con los certificados del servidor fijados
/// (V2-M22.04).
///
/// En `pruebas` y `produccion` la app solo confía en las raíces de Azure de
/// `lib/config/pines_tls.dart` y no en las del teléfono: un certificado de
/// cualquier otra autoridad, o instalado por un tercero, no sirve para espiar la
/// conexión. Cómo se eligieron, cómo se rotan y qué hacer si algo se rompe:
/// `docs/seguridad/fijar-certificados.md`.
///
/// Solo cubre lo que sale por el cliente `http` de la app (la API y la descarga
/// de manuales). Las imágenes que Flutter baja con `NetworkImage` y lo que hacen
/// los plugins por su cuenta usan la tienda del sistema; el documento lo dice.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/flavor.dart';
import '../config/pines_tls.dart';
import 'api_config.dart';

/// `--dart-define=FIJAR_CERTIFICADOS=false` quita los pines al depurar (por
/// ejemplo, para ver el tráfico con un proxy). **Solo fuera de release**: en
/// release se ignora y no hay forma de apagarlos.
const bool _pinesActivados = bool.fromEnvironment(
  'FIJAR_CERTIFICADOS',
  defaultValue: true,
);

/// No se pudo armar la confianza del servidor. La app no arranca antes que
/// conectarse sin fijar.
class ConfianzaTlsInvalida implements Exception {
  ConfianzaTlsInvalida(this.motivo);

  final String motivo;

  @override
  String toString() => 'Certificados del servidor: $motivo';
}

/// En quién confía la app al hablar con el servidor.
sealed class ConfianzaTls {
  const ConfianzaTls();
}

/// Los certificados raíz del teléfono. Es lo de siempre, y lo que usa
/// `desarrollo`.
class ConfianzaDelSistema extends ConfianzaTls {
  const ConfianzaDelSistema();
}

/// Solo estos certificados (PEM), sin los del teléfono. Basta con que la cadena
/// del servidor termine en uno de ellos.
class ConfianzaFijada extends ConfianzaTls {
  const ConfianzaFijada(this.pem);

  final List<String> pem;
}

/// Decide en quién confiar para hablar con [servidor] desde [flavor].
///
/// - Un flavor que no fija (`desarrollo`), o un servidor sin TLS, usa la tienda
///   del sistema.
/// - Un flavor que fija y un servidor https **sin anclas** lanza
///   [ConfianzaTlsInvalida]: es preferible no arrancar que conectarse sin fijar
///   sin que nadie lo note.
/// - [pinesActivados] en `false` los quita, pero solo si [esRelease] es `false`.
ConfianzaTls decidirConfianza({
  required Flavor flavor,
  required Uri servidor,
  bool esRelease = kReleaseMode,
  bool pinesActivados = _pinesActivados,
}) {
  if (!flavor.fijaCertificados || servidor.scheme != 'https') {
    return const ConfianzaDelSistema();
  }
  if (!esRelease && !pinesActivados) return const ConfianzaDelSistema();

  final anclas = anclasPara(servidor.host);
  if (anclas == null) {
    throw ConfianzaTlsInvalida(
      'no hay certificados fijados para «${servidor.host}». Agrega sus raíces '
      'en lib/config/pines_tls.dart (guía: docs/seguridad/fijar-certificados.md).',
    );
  }
  return ConfianzaFijada([for (final a in anclas) a.pem]);
}

/// Arma el cliente HTTP que confía en [confianza].
http.Client crearClienteHttp(ConfianzaTls confianza) => switch (confianza) {
  ConfianzaDelSistema() => http.Client(),
  ConfianzaFijada(:final pem) => IOClient(
    HttpClient(context: _contextoFijado(pem)),
  ),
};

/// El cliente de este ambiente: el flavor en ejecución contra la dirección
/// configurada.
http.Client clienteHttpDelAmbiente() => crearClienteHttp(
  decidirConfianza(
    flavor: Flavor.actual,
    servidor: ApiConfig.desdeEntorno().base,
  ),
);

/// Un contexto que **no** carga los certificados del sistema: solo [pem].
///
/// Sigue verificando que el certificado sea del servidor al que se conecta y que
/// no haya vencido; lo único que cambia es quién puede firmarlo.
SecurityContext _contextoFijado(List<String> pem) {
  if (pem.isEmpty) {
    throw ConfianzaTlsInvalida('no hay ningún certificado que fijar');
  }
  final contexto = SecurityContext(withTrustedRoots: false);
  try {
    contexto.setTrustedCertificatesBytes(utf8.encode(pem.join('\n')));
  } on TlsException catch (e) {
    throw ConfianzaTlsInvalida(
      'no se pudieron leer los fijados (${e.message})',
    );
  }
  return contexto;
}
