# Capa de acceso a datos · TEC-5

Todo lo que la app sabe de Agencia360 vive aquí. Simula o consume el contrato
`api/agencia360-api-app-v1.yaml`.

## La regla

> **Las pantallas dependen de `CarecarApi` y de los modelos. De nada más.**

Ninguna pantalla importa `cliente_api.dart`, ni `http`, ni conoce la dirección del
servidor. Por eso cambiar de la API simulada a la real no obliga a rehacer
pantallas: se cambia la dirección o la implementación, no la interfaz.

```
      Pantallas
          │  solo ven esto
          ▼
   CarecarApi  ·········· interfaz con las 13 operaciones del contrato
          │
          ▼
   CarecarApiHttp  ······ traduce cada operación a una ruta
          │
          ▼
   ClienteApi  ·········· único que sabe que detrás hay HTTP:
          │               arma peticiones, lee JSON y traduce
          ▼               los códigos del contrato a excepciones
     ApiConfig  ········· la dirección, que viene de --dart-define
```

## Archivos

| Archivo | Qué hace |
| --- | --- |
| `carecar_api.dart` | **La interfaz.** Las 13 operaciones del contrato |
| `carecar_api_http.dart` | La implementación: cada operación a su ruta |
| `cliente_api.dart` | Transporte HTTP, lectura de JSON y mapeo de errores |
| `api_config.dart` | La dirección de la API, validada |
| `excepciones.dart` | Jerarquía de fallos, todos con mensaje mostrable |
| `modelos/` | Los esquemas del contrato |

## La dirección

Se pasa al compilar, nunca se escribe en el código:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1/app
```

**No hay valor por omisión a propósito.** Es preferible un error claro al arrancar
que una compilación de producción apuntando a `localhost`. Si falta, `ApiConfig`
lanza `ApiConfigInvalida` con el comando exacto que hay que usar.

Las direcciones según dónde corre la app (emulador, simulador, celular físico)
están en [`mock_api/README.md`](../../mock_api/README.md).

## Los errores

Todos los métodos lanzan una subclase de `ExcepcionApi`, y **el `mensaje` de
cualquiera se puede mostrar al usuario**: o viene del `message` del backend, que la
guía de estilos pide mostrar tal cual, o es un texto propio que dice qué pasó y qué
hacer.

| Excepción | Cuándo |
| --- | --- |
| `SinConexion` | Sin red, servidor apagado, DNS, timeout, TLS |
| `CredencialesInvalidas` | 401 |
| `CuentaDesactivada` | 403 |
| `NoEncontrado` | 404 · no existe **o no es del cliente** |
| `DatosInvalidos` | 400 |
| `Conflicto` | 409 · sin cupo, doble reserva, fuera de plazo |
| `ErrorDelServidor` | 5xx y cualquier código que el contrato no declara |
| `RespuestaInvalida` | Respondió con éxito pero el cuerpo no se pudo leer |

`SinConexion` existe separada porque **APP-2.1 pide distinguirla** de
«credenciales inválidas»: son dos mensajes distintos para el usuario. Un socket
caído nunca se reporta como error del servidor.

`RespuestaInvalida` también está aparte: «el servidor falló» y «el servidor
contestó algo que no entendemos» son problemas distintos, y el segundo suele ser
una desviación del contrato.

## Los nombres de los campos

Los modelos usan **los nombres del contrato, sin acentos ni eñes**:
`contrasena`, `anio`, `debeCambiarContrasena`. No se traducen ni se «corrigen»:
cualquier diferencia rompe la deserialización en silencio.

## La prueba de contrato

`test/contrato/contrato_test.dart` lee el YAML y lo compara contra lo que la app
cree que dice: esquemas, propiedades, campos obligatorios, el enum de estados, las
13 operaciones y cuáles van sin token.

**Si Ricardo cambia el contrato, esa prueba se pone roja y el CI avisa.** Es la
alarma que pedía RIC-22. Verificado: al agregar un campo a `Vehiculo` en el YAML,
la prueba falla diciendo exactamente qué cambió.

El último grupo, además, valida las respuestas reales de la API simulada. Solo
corre si está levantada; en CI se omite sin poner el build en rojo.

```bash
# Las 6 pruebas contra la simulada, de verdad
cd mock_api && npm start
flutter test test/contrato/contrato_test.dart
```

## Huecos del contrato que esta capa deja marcados

Donde el contrato no define algo, el código lo dice en el lugar donde importa:

| Hueco | Dónde está marcado | Pregunta |
| --- | --- | --- |
| No se sabe cuánto vive el `accessToken` ni hay refresh | `modelos/sesion.dart` | RIC-1, RIC-2 |
| Los valores de `Servicio.estatus` no están definidos | `modelos/servicio.dart` | PO-5 |
| Fechas y horas sin zona horaria | `modelos/comun.dart` | RIC-13 |
| `Cita` no devuelve `franjaId` | `modelos/cita.dart` | RIC-10 |
| No se sabe si la `url` del manual pide token | `modelos/manual.dart` | RIC-17 |
| No se sabe el plazo para cancelar una cita | `carecar_api.dart` | PO-4 |

## Lo que todavía no está aquí

- **Dónde se guarda el token.** `ClienteApi` lo recibe por una función
  (`obtenerToken`), así que la sesión puede cambiar sin reconstruir el cliente,
  pero quién la guarda y dónde es decisión de APP-2.1. El almacenamiento seguro
  del sistema operativo es lo razonable, pendiente de EQ-9.
- **Repositorios por funcionalidad.** Si al crecer conviene una capa de dominio
  encima, va aparte: esta capa ya aísla el transporte.
- **Caché y modo sin conexión.** Depende de EQ-8, que es la decisión más cara de
  revertir de todas las abiertas.
