# M21 · Sin conexión y sincronización

| Campo | Valor |
| --- | --- |
| Hito | H2 (lectura) → H7 (escritura en cola) |
| Dueño | Jael |
| Revisa | Juan Pablo |
| Ficha técnica | No (frente transversal; se cumple dentro de las funcionalidades de la ficha) |
| Estado | Listo para historias |

## Propósito

La app sirve en el sótano del taller: lee lo último guardado y encola lo que el cliente hace sin red. Mueve O3 y O8. (v1 ya tiene caché en disco; v2 lo formaliza.)

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M21.01 | Como equipo queremos una base local para los datos del cliente | Base local cifrada (decisión en ADR) · se borra al cerrar sesión · migraciones versionadas | | V2-T01.02 |
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

