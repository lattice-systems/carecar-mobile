# 0008 · Reintento automático decidido por tipo de error

**Estado:** Propuesta

## Contexto

Riverpod 3 reintenta solo cualquier proveedor que falle. Su política por omisión (`ProviderContainer.defaultRetry`) hace hasta **10 intentos** con espera que dobla de 200 ms a 6.4 s, y solo se salta los `Error`.

Todos los fallos de la app son `Exception`: `ExcepcionApi` implementa `Exception`. Así que sin política propia, **un 404 se pide once veces** para recibir once veces lo mismo, y un **429 —que significa literalmente «deja de pedir»— se pide otras once**, alargando el bloqueo de 15 minutos del login.

El equipo ya detectó el comportamiento y lo documentó en `lib/modulos/README.md`: poner `retry: (_, _) => null` en cada proveedor cuya pantalla ofrezca botón de reintento. Al levantar el árbol para V2-T01.08, de los proveedores existentes **`vehiculoProvider` de `vehiculos` es el único sin esa línea**, que es el problema de una regla que hay que recordar en cada proveedor.

## Opciones

1. **Dejar la política de Riverpod y seguir con `retry: (_, _) => null` por proveedor.** Cero código nuevo. Pero es todo o nada: desactiva también los reintentos útiles, hay que acordarse cada vez y ya se olvidó una vez.
2. **Desactivar el reintento en todo el `ProviderScope`** (`retry: (_, _) => null` global). Simple y predecible, pero pierde el caso que de verdad sirve: un túnel o un servidor reiniciándose se recuperan solos sin que el usuario toque nada.
3. **Una política de la app que decida por tipo de error.** Un archivo del núcleo, instalado una vez. Requiere que los fallos respondan si vale la pena insistir, que es lo que ya hace `Fallo.esReintentable` (V2-T01.08).

## Decisión

La **3**. `reintentoDelNucleo` (`lib/nucleo/datos/reintento.dart`) se instala en el `ProviderScope` de `main.dart` y consulta `Fallo.esReintentable`:

| Fallo | ¿Se reintenta? | Por qué |
| --- | --- | --- |
| Sin conexión | **Sí** | El túnel se acaba |
| 5xx | **Sí** | Suele ser pasajero |
| 400, 404, 409 | No | La respuesta sería idéntica |
| 401, 403 | No | La salida es volver a entrar, no insistir |
| 429 | No | Insistir alarga el bloqueo |
| `Error` (bug nuestro) | No | Repetir un `TypeError` da el mismo `TypeError` |

Tope de **3 intentos** en vez de 10: con la espera que dobla, diez dejan al usuario mirando un error más de medio minuto antes de que la app se rinda. La curva de espera se delega a `ProviderContainer.defaultRetry` para no tener dos *backoff* distintos en la misma app.

## Consecuencias

- **Los módulos quedan cubiertos sin tocar sus carpetas.** Incluye `vehiculoProvider`, que hoy reintenta un 404 once veces.
- **Ya no hace falta `retry: (_, _) => null` por proveedor.** Los que existen siguen funcionando, porque el del proveedor manda sobre el del contenedor (`origin.retry ?? container.retry ?? defaultRetry`); solo quedan redundantes y además renuncian a los reintentos útiles. Los quita el dueño de cada módulo cuando toque el archivo. La guía de `lib/modulos/README.md` se actualizó.
- **Un fallo pasajero se cura solo** y el usuario puede no llegar a ver el error. Es deseable, pero **cambia cómo se escriben las pruebas**: una prueba que quiera ver un error reintentable tiene que montar el `ProviderScope` sin la política. Está anotado en la guía y fijado en `test/nucleo/datos/nucleo_de_datos_test.dart`.
- El botón «Reintentar» de `VistaAsincrona` sigue siendo necesario: la política es lo que se arregla solo, el botón es la decisión del usuario cuando no se arregló.
- Si más adelante se quiere afinar por pantalla, el `retry` del proveedor sigue teniendo precedencia, así que esta decisión no cierra puertas.
