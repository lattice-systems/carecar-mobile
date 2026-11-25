# Aviso de privacidad versionado (V2-M22.01)

Historia [V2-M22.01](../../plan/modulos/M22-seguridad-y-privacidad.md). Backend: [`agencia-360-backend#96`](https://github.com/lattice-systems/agencia-360-backend/pull/96), contrato 2.13.0. Tablas de la ficha: `aviso_privacidad` y `aceptacion_aviso`.

## Qué hace

| Criterio | Mecanismo | Código |
| --- | --- | --- |
| Texto versionado del backend | `GET /privacidad/aviso` devuelve la versión vigente (la mayor cuyo `vigente_desde` ya llegó) con `aceptado` y `aceptadoEn` de esta cuenta. Un aviso publicado no se edita: una versión nueva es otro aviso. | `lib/modulos/privacidad/` |
| Aceptación en el primer ingreso | Con cada sesión nueva, `VerificadorDeAviso` pregunta al servidor y avisa a la guardia del enrutador; si falta aceptar, la persona ve la puerta antes que el inicio. | `verificador_aviso.dart`, `lib/nucleo/privacidad/estado_aviso.dart` |
| Aceptación al cambiar de versión | Una versión nueva tiene otro `id` y nadie la ha aceptado: la puerta vuelve a aparecer. Aceptar la vieja responde 409 `AVISO_NO_VIGENTE` y la puerta enseña la nueva. | `pantalla_aceptar_aviso.dart` |
| Leerlo cuando se quiera | «Aviso de privacidad» del perfil abre el aviso del servidor con su versión y la fecha en que se aceptó. | `pantalla_aviso_privacidad.dart` |

## Cómo está armado

```
sesión nueva ─► VerificadorDeAviso ─► estadoAvisoProvider (núcleo) ─► guardia del enrutador
                  GET /privacidad/aviso   verificando / pendiente / aceptado     │ por aceptar
                                                                                 ▼
                                                      /privacidad/aceptar (puerta) ─► POST /privacidad/aceptaciones
                                                                                 │ aceptado
                                                                                 ▼
                                                                    vuelve a donde iba (`desde`)
```

- **La guardia vive en el núcleo y no puede importar módulos** (regla R2 de dependencias). Por eso lee `EstadoAviso`, un estado simple que escribe el módulo, que sí habla con el servidor.
- **Va después del cambio de contraseña temporal** y guarda el destino (`desde`) igual que aquel: un enlace profundo no se salta la puerta y se recupera al aceptar.
- **Mientras pregunta, la guardia retiene** a la persona en la puerta (`verificando`), para que no vea el inicio un instante antes de que le pidan aceptar.
- **Quien no acepta no queda atrapada**: «No acepto, cerrar sesión».

## Decisiones

- **Sin conexión no se bloquea a nadie** (`noRequerido`). El aviso se pide después de autenticarse, así que en el primer ingreso la red ya funcionó; en un ingreso posterior, dejar a una persona fuera de su auto por falta de datos es peor que preguntar de nuevo la próxima vez. La puerta vuelve en cuanto se pueda leer el aviso (también al abrirlo desde el perfil).
- **Sin copia en caché**: «aceptado» tiene que ser lo que el servidor sabe ahora; una copia vieja dejaría pasar una versión nueva sin aceptar. Se limpia con la sesión, nunca se reutiliza la lectura de la cuenta anterior.
- **El servidor no bloquea el resto de la API** por no haber aceptado: la app v1 instalada no conoce el aviso. La puerta es de la app v2; lo que queda registrado, con fecha, es lo que cuenta ante una reclamación.
- **El texto vive en el backend**: la versión 1 es el texto que la app traía incluido (`Agencia.avisoPrivacidad`). El texto definitivo es de la agencia: lo publica el Gerente de marketing como versión 2 con `POST /api/v1/avisos-privacidad`, sin publicar una versión nueva de la app. Para probarlo con el simulador (`mock_api`), el mismo `POST` publica una versión nueva.

## Límites

- **Una sesión larga no se entera de una versión nueva** hasta la siguiente sesión o hasta abrir el aviso desde el perfil. Es una app de un auto, no de un banco; si hiciera falta, bastaría volver a verificar al volver a primer plano.
- **El perfil v1 sin enrutador** (la v1 suelta, en pruebas) sigue mostrando el texto que la app trae. Desaparece con V2-T01.07.
- **Falta probarlo en un teléfono** contra el backend real: la ficha queda en 🟡 hasta entonces.
- La puerta no valida **quién** hace clic: la aceptación es de la cuenta autenticada (`cuenta_app`), no de la persona física.
