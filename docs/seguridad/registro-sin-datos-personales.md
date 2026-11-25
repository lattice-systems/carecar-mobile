# Registro sin datos personales (V2-M22.07)

Historia [V2-M22.07](../../plan/modulos/M22-seguridad-y-privacidad.md). Control MASVS L1 relacionado: MSTG-STORAGE-3 (no se escriben datos sensibles en los registros de la app).

## Qué hace

| Criterio | Mecanismo | Código |
| --- | --- | --- |
| Lo que se registra sale sin correo, teléfono, VIN ni token | `Registro.depurar` pasa todo texto por `quitarDatosPersonales` antes de escribirlo | `lib/nucleo/registro/` |
| Prueba que falla si se registra uno de esos datos | Pruebas del redactor y del registro, más una guarda sobre todo `lib/` | `test/nucleo/registro/`, `test/arquitectura/registro_sin_datos_personales_test.dart` |

## Qué se tapa

| Dato | Forma que busca | Queda como |
| --- | --- | --- |
| Correo | `nombre@dominio.tld` | `[correo]` |
| Teléfono | de 10 a 15 dígitos, con espacios, puntos, guiones o paréntesis entre ellos, y `+` opcional | `[telefono]` |
| VIN | 17 caracteres sin I, O ni Q, con al menos una letra y un dígito | `[vin]` |
| Token | JWT (`eyJ…`), lo que sigue a `Bearer` y el valor de `token`, `access_token`, `refresh_token`, `id_token`, `api_key`, `contrasena`, `password`, `clave` o `secret` | `[token]` |

Prefiere tapar de más: un número largo que no era un teléfono se pierde en el registro; un teléfono nunca llega.

## Cómo se usa

```dart
Registro.depurar('No se pudo programar el aviso', error: e);
```

No se usa `print`, `debugPrint`, `developer.log` ni `stdout` fuera de `lib/nucleo/registro/`. La guarda lo rechaza con el archivo y la línea, y también rechaza interpolar un nombre que delate un dato personal (`$correo`, `${usuario.telefono}`, `$accessToken`, `${vehiculo.vin}`).

## Decisiones

- **Guarda como prueba, no como lint propio**: un lint propio (`custom_lint`) añade una dependencia que pasa por el check de dependencias, y el repo ya guarda sus reglas con pruebas (dependencias entre módulos, cadenas visibles, componentes del sistema). `flutter_lints` ya incluye `avoid_print`; la guarda cubre además `debugPrint`, `developer.log` y `stdout`/`stderr`.
- **Dos barreras**: la guarda impide *escribir* el dato a propósito; el redactor lo tapa cuando llega dentro del texto de una excepción de un tercero, que nadie escribió.
- **Acceso estático**: `Registro` es un punto de acceso global porque su primer usuario, `lib/notificaciones/`, es código v1 sin Riverpod. La salida se sustituye en pruebas con `Registro.salida`.

## Límites

- Solo tapa lo que tiene una forma reconocible. Un nombre, una dirección o una placa no se detectan: no se registran, y eso lo cuida quien escribe el código y quien revisa el PR.
- La guarda lee texto, no entiende el código: no ve `final m = 'x $correo'; Registro.depurar(m);`. En ese caso el redactor sigue tapando en ejecución.
- Lo que escribe el propio framework no pasa por `Registro`: un `FlutterError` no atrapado se vuelca a la consola por defecto. Cuando se integre V2-M23.01 (reportes de errores), su manejador debe pasar el texto por `quitarDatosPersonales`.
- Los plugins nativos pueden escribir en `logcat` por su cuenta; no se auditaron aquí. Queda para la revisión de V2-M22.08.
- El backend no entra en esta historia.
