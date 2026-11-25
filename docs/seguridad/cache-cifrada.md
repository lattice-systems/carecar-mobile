# Caché de la API cifrada

V2-M22.13 (PR #138). La app guarda la última respuesta buena de algunas lecturas (perfil, vehículos, servicios, citas, catálogo) para mostrarlas sin conexión: `lib/cache/carecar_api_con_cache.dart`. Esa copia lleva correo, nombre, VIN y placas, así que **se guarda cifrada**. Antes quedaba en texto plano en `SharedPreferences`, legible con root o desde una copia de seguridad (hallazgo F5 de la [revisión MASVS](revision-masvs-l1.md)).

## Cómo funciona

| Pieza | Qué hace |
| --- | --- |
| `CifradorAesGcm` (`lib/cache/cifrador_de_cache.dart`) | AES-256-GCM con un nonce aleatorio de 12 bytes por copia y una etiqueta de 16. Lo guardado es `c1.` + base64url(nonce + datos + etiqueta). |
| La llave | 32 bytes aleatorios, creados la primera vez que hacen falta y guardados en el Keystore (Android) o el Keychain (iOS) con la clave `carecar.cache.clave.v1`, por el mismo puerto que la sesión (`AlmacenamientoCifrado`). |
| El contexto | La clave de la copia (`vehiculos`, `perfil`…) viaja como dato asociado: una copia pasada a otra clave no se descifra. |
| La clave en disco | `cache_carecar_v2_<clave>` en `SharedPreferences`. |

## Qué pasa cuando algo falla

| Caso | Resultado |
| --- | --- |
| El almacenamiento seguro no responde al guardar | No se guarda copia y la lectura buena se entrega igual. **Nunca se guarda en claro.** |
| …o al leer sin conexión | No hay copia: se propaga «sin conexión». |
| Copia alterada, de otra llave, ilegible o con otra forma que la de ahora | Se descarta (se borra) y se trata como si no hubiera copia. |
| Se cierra o se inicia una sesión | Se borran todas las copias, de cualquier versión, y se olvida la llave: lo que quedara en disco ya no se puede leer. Si el almacenamiento seguro falla al olvidarla, la sesión se cierra igual. |
| Equipo con root o jailbreak (M22.05) | No se guarda ni se lee nada y se borra lo que hubiera, como antes. |
| Copias en claro de versiones anteriores (`cache_carecar_*`) | Se borran al arrancar. |

## Límites

- Protege contra leer el archivo de `SharedPreferences` (root, copia de seguridad). No protege contra el teléfono desbloqueado con la app abierta ni contra uno comprometido en ejecución: ahí la llave está en memoria.
- En iOS la llave queda en el Keychain con la accesibilidad por omisión, que entra en las copias de seguridad cifradas (hallazgo F2 de la revisión): una copia restaurada en otro iPhone podría descifrar la caché. Es lo mismo que la app volvería a pedir al servidor.
- No cifra el resto de `SharedPreferences` (idioma y preferencias locales, sin datos personales).
- AES-GCM en Dart puro (`cryptography`), sin aceleración nativa. Para los tamaños de la caché (unos KB) no se nota.
- Cuando V2-M21.01 cambie la copia a una base local, esa base necesitará su propia protección: esta llave y este cifrador se pueden reutilizar.

## Pruebas

- `test/cache/cifrador_de_cache_test.dart`: ida y vuelta, que lo guardado no deje ver el texto ni en base64, nonce distinto en cada copia, llave reutilizada y creada una sola vez aunque lleguen peticiones a la vez, copia alterada, movida a otra clave o en claro, olvidar la llave y fallo del almacenamiento (que se recupera después).
- `test/cache/carecar_api_con_cache_test.dart`: ninguna copia deja ver correo, nombre, VIN ni placas; lectura sin conexión tras reiniciar; copias ilegibles o con otra forma se descartan; purga de las copias en claro; cierre de sesión que olvida la llave aunque el almacenamiento falle; y la política de equipo comprometido de M22.05.
