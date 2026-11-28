# M21 · Sin conexión y sincronización

| Campo | Valor |
| --- | --- |
| Hito | H2 (lectura) → H7 (escritura en cola) |
| Dueño | Jael |
| Revisa | Juan Pablo |
| Ficha técnica | No (frente transversal; se cumple dentro de las funcionalidades de la ficha) |
| Estado | En curso (V2-M21.01 en revisión) |

## Propósito

La app sirve en el sótano del taller: lee lo último guardado y encola lo que el cliente hace sin red. Mueve O3 y O8. (v1 ya tiene caché en disco; v2 lo formaliza.)

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M21.01 | Como equipo queremos una base local para los datos del cliente | Base local cifrada (decisión en ADR) · se borra al cerrar sesión · migraciones versionadas | | V2-T01.02 · **En revisión** |
| V2-M21.02 | Como cliente sin red quiero ver vehículos, historial, citas y documentos | Lectura de la base local con sello "actualizado hace X" | | V2-M21.01 |
| V2-M21.03 | Como cliente sin red quiero que mis acciones se envíen al volver la conexión | Cola de operaciones idempotentes (clave de idempotencia) · reintentos con espera exponencial · estado visible | ✅ | V2-M21.01 |
| V2-M21.04 | Como cliente quiero saber si estoy sin conexión | Aviso discreto global · acciones no disponibles deshabilitadas con explicación | | V2-T02.05 |
| V2-M21.05 | Como equipo queremos resolver conflictos de forma predecible | Servidor gana en datos del taller; cliente gana en preferencias; documentado | ✅ | V2-M21.03 |
| V2-M21.06 | Como cliente quiero que la app sincronice en segundo plano | Actualización periódica respetando batería y datos | | V2-M21.02 |

## Cómo se sabe que no hay conexión (V2-M21.04)

**La señal no pregunta si hay wifi: pregunta si la agencia contesta.** Es la
diferencia que esta historia existe para resolver: en el sótano del taller el
teléfono se ve conectado al wifi de la agencia y no llega nada. Un aviso que
dijera «tienes internet» ahí sería peor que ninguno.

Así que **no se agregó ninguna dependencia**. La señal se deduce de lo que ya
pasa: toda llamada de repositorio pasa por `RepositorioBase.pedir`, y ahí se
sabe si hubo respuesta. Eso da tres cosas gratis: cero dependencias, cero
sondeos periódicos y cero gasto de batería.

| Qué pasó | Qué hace la señal |
| --- | --- |
| Respuesta buena | En línea |
| `SinConexion` | Sin conexión |
| Error del servidor (500) | **Nada**: el servidor contestó, así que hay red. Decir «sin conexión» mandaría a la persona a revisar su wifi por un problema que no es suyo |
| Un `Error` nuestro | **Nada**: un bug no dice nada de la red |

**Lo que esto no alcanza:** si la app está quieta, la señal no se entera de que
la red volvió. Es aceptable porque el aviso se apaga con la primera respuesta
buena, y cualquier cosa que la persona intente produce una.

El aviso es **advertencia y no peligro**: sin red la app sigue sirviendo para
leer lo guardado. El rojo está reservado para lo que sí es grave, como un
certificado que no se puede verificar (V2-M22.15). No lleva botón de cerrar
porque no hay nada que la persona pueda hacer, y uno invitaría a taparlo.

### Para deshabilitar una acción

Se usa `sinConexionProvider`, que **sí repinta**. `senalDeConexionProvider`
entrega el objeto y `Provider` no escucha sus avisos, así que
`ref.watch(senalDeConexionProvider).sinConexion` se queda con el primer valor
para siempre. Lo destapó la prueba del botón deshabilitado, no la lectura del
código.

Deshabilitar no basta: hay que decir por qué, con
`textos.conexionAccionSinRed`. Un botón apagado sin explicación se lee como un
error de la app. Hecho ya en «Cambiar mi contraseña»; **cada módulo lo aplica a
sus propias acciones**, porque desde el núcleo no hay forma de saber cuál
necesita servidor.

## La base local (V2-M21.01)

`lib/nucleo/base_local/`. La decisión es la [ADR 0005](../../docs/decisiones/0005-base-local-drift.md): `drift` sobre SQLCipher.

| Pieza | Qué es |
| --- | --- |
| `BaseLocal` | La interfaz de dominio. **Los módulos dependen de esta y nunca de `drift`.** `guardar`, `leer`, `listar`, `borrarTodo`, `cerrar`. El contenido es texto (JSON): la base no conoce los datos de ningún módulo. |
| `BaseLocalDrift` | La real. Archivo `base_local/carecar.db` en la carpeta privada de la app (`getApplicationSupportDirectory`). |
| `BaseLocalEnMemoria` | El doble para pruebas. Cumple el mismo contrato (`test/nucleo/base_local/contrato_base_local.dart` corre contra los dos). |
| `BaseLocalConPolitica` | Aplica la política de root/jailbreak (V2-M22.05): no guarda ni entrega y borra lo que hubiera. |
| `baseLocalProvider` | Cómo la lee un módulo. Lo inyecta `main.dart`. |

**Cifrado.** SQLCipher cifra el archivo entero. La llave son 32 bytes aleatorios creados la primera vez y guardados en el Keystore o el Keychain (`carecar.base_local.clave.v1`), por el mismo puerto que la sesión. Si el motor cargado no es SQLCipher, la base no se abre: no hay modo de guardar en claro. Si el almacenamiento seguro no da la llave, `BaseLocalNoDisponible` y **no se crea archivo**; quien guarda lo trata como «sin copia local».

**Se borra al cerrar sesión.** `ControladorSesion.registrarAlTerminarSesion` corre las tareas registradas en `_terminar`, que es por donde pasan los tres finales de sesión: cierre voluntario, refresh vencido (401) y cuenta desactivada (403). Corre **antes** de borrar los tokens: si la app muere entre una cosa y otra, queda la sesión con la base vacía (se vuelve a descargar) y no una persona sin sesión con datos suyos. `borrarTodo` cierra la base, borra el archivo y sus `-wal`/`-shm`/`-journal` y **olvida la llave**: la siguiente base usa una nueva.

**Migraciones.** `schemaVersion` en `BaseDeDatosLocal`; cada cambio suma un paso en `onUpgrade` y una prueba que abre una base de la versión anterior. Versión 1: `copias_locales(coleccion, clave, contenido)`. Versión 2: agrega `actualizado_en` (el sello «actualizado hace X» de V2-M21.02); lo de la versión 1 queda con `1970-01-01`, que significa «no se sabe». **La versión 1 nunca salió en una app**: existe como punto de partida para que la ruta de migración tenga una prueba real desde el primer día. Es una copia, así que ante una base de un esquema **más nuevo** que la app, con llave perdida o ilegible, se **descarta y se recrea** vacía en vez de dar datos a medias.

**Qué no hace todavía.**

- **No migra la caché en archivos** (`lib/cache/`, `CarecarApiConCache`): sigue siendo la que sirve sin conexión. Moverla a esta base es V2-M21.02. (El hallazgo F5 de la revisión MASVS, que decía que esa caché guardaba datos personales sin cifrar, **ya se cerró con V2-M22.13**: está cifrada con AES-256-GCM. M21.02 la reemplaza por la base, no corrige una brecha abierta.)
- **No hay tablas tipadas.** Una sola tabla genérica por colección; cuando M21.02 necesite consultar por campos se agregan con una migración.
- **iOS no está probado** (no hay runner de macOS) ni la apertura en un teléfono real; la prueba corre SQLCipher en la computadora. En iOS la carpeta de Application Support entra en las copias de seguridad del dispositivo y la llave está en el Keychain con la accesibilidad por omisión (hallazgo F2): una copia restaurada en otro iPhone podría abrir la base.
- **Borrado en un login ajeno:** no se borra al iniciar sesión, solo al terminarla. Si la app muriera justo después de borrar los tokens de una sesión que no pasó por `_terminar`, quedaría una base; el orden descrito arriba lo evita en los tres caminos conocidos.
