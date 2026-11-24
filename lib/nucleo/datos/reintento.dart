import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fallo.dart';

/// Cuantas veces se insiste antes de rendirse.
///
/// Riverpod trae 10. Con la espera que dobla desde 200 ms, diez intentos
/// dejan al usuario mirando una pantalla de error mas de medio minuto antes de
/// que deje de intentarlo. Tres cubren el caso real —un tunel, un servidor que
/// se reinicia— en menos de dos segundos.
const maxIntentosDelNucleo = 3;

/// Politica de reintento de la app · V2-T01.08.
///
/// Se instala **una vez** en el `ProviderScope` de `main.dart`:
///
/// ```dart
/// ProviderScope(retry: reintentoDelNucleo, child: ...)
/// ```
///
/// ## Por que hace falta
///
/// Riverpod 3 reintenta solo cualquier proveedor que falle: hasta 10 veces,
/// con espera que dobla de 200 ms a 6.4 s. Su politica por omision
/// (`ProviderContainer.defaultRetry`) solo se salta los `Error`.
///
/// Y **todos** nuestros fallos son `Exception`, porque `ExcepcionApi`
/// implementa `Exception`. Sin esta politica, un 404 se pide once veces para
/// recibir once veces lo mismo, y un 429 —que justo significa «deja de
/// pedir»— se pide otras once, alargando el bloqueo.
///
/// Esta politica solo insiste cuando repetir puede dar otro resultado, que es
/// lo que responde [CaraDelFallo.esReintentable]: sin conexion y 5xx si; 400,
/// 401, 403, 404, 409 y 429 no.
///
/// ## Lo que NO resuelve
///
/// El boton «Reintentar» de [VistaAsincrona] sigue siendo necesario y es otra
/// cosa: esto es el reintento automatico de lo que puede arreglarse solo;
/// aquel es la decision del usuario cuando no se arreglo.
Duration? reintentoDelNucleo(int intento, Object error) {
  // Un bug no se arregla repitiendolo, y un error del contrato que ya dijo
  // «no» va a decir «no» otra vez. `falloDe` tipa lo que llegue sin tipar.
  if (!falloDe(error).esReintentable) return null;

  // La espera la calcula Riverpod: no hay motivo para tener dos curvas de
  // backoff distintas en la misma app. Lo unico que cambia es el tope.
  // (Un `Error` cae aqui solo si llego sin convertir, y `defaultRetry` lo
  // descarta por su cuenta.)
  return ProviderContainer.defaultRetry(
    intento,
    error,
    maxRetries: maxIntentosDelNucleo,
  );
}
