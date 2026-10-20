# API simulada de Agencia360 · TEC-5

Simula la API que Agencia360 expone a la app CareCar, para que la app avance sin
esperar al backend. Simula el contrato `api/agencia360-api-app-v1.yaml`.

**No es parte de la app.** Es una herramienta de desarrollo: no se compila, no se
publica y no viaja en el APK.

## Levantarla

Hace falta Node 20 o superior.

```bash
cd mock_api
npm install          # solo la primera vez
npm start
```

Queda escuchando en `http://localhost:3000/api/v1/app`.

Para usar otro puerto:

```bash
PORT=4000 npm start
```

## Conectar la app

La dirección de la API se pasa al compilar, sin tocar código:

```bash
# Contra la API simulada
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1/app

# Contra la API real, cuando exista
flutter run --dart-define=API_BASE_URL=https://<servidor>/api/v1/app
```

> **En emulador o dispositivo físico, `localhost` no es tu computadora.**
>
> | Dónde corre la app | Dirección que debes usar |
> | --- | --- |
> | Emulador de Android | `http://10.0.2.2:3000/api/v1/app` |
> | Simulador de iOS | `http://localhost:3000/api/v1/app` |
> | Celular físico en la misma red | `http://<ip-de-tu-computadora>:3000/api/v1/app` |
>
> En Android, el tráfico sin cifrar está bloqueado por omisión. Para apuntar a
> esta API simulada desde un dispositivo hay que permitir texto claro solo en la
> configuración de depuración.

## Cuentas de prueba

| Usuario | Contraseña | Para probar |
| --- | --- | --- |
| `cliente1` | `CareCar2026` | Caso normal. Tiene **2 vehículos**, historial de servicios y citas |
| `cliente2` | `Temporal123` | Devuelve `debeCambiarContrasena: true`, para el primer ingreso de APP-2.3 |
| `cliente3` | `CareCar2026` | Cuenta desactivada: el login responde **403** (CRM-1.3) |

Tokens de recuperación para APP-2.3:

| Token | Resultado |
| --- | --- |
| `token-valido-de-prueba` | 204, y queda usado |
| `token-ya-usado` | 400 |
| `token-expirado` | 400 |

## Los datos

| Archivo | Qué es |
| --- | --- |
| `db.seed.json` | Estado inicial. **Está versionado**: es el que se edita para agregar datos de ejemplo |
| `db.json` | Estado vivo. Lo modifican las peticiones `POST`. **Está ignorado por git** |

El servidor crea `db.json` desde la semilla la primera vez. Para volver al estado
inicial:

```bash
npm run reset
```

### Guarda estado

A diferencia de un mock sin estado, aquí las escrituras se quedan:

- Agendar una cita la hace aparecer en `GET /citas`.
- Agendar **descuenta** el cupo de la franja, y cancelar lo devuelve.
- Cambiar la contraseña cambia con qué contraseña entras después.

Por eso existe `npm run reset`.

## Qué cubre

Los 13 endpoints del contrato, con sus casos de error:

| Método | Ruta | Notas |
| --- | --- | --- |
| POST | `/auth/login` | 401 contraseña mala · 403 cuenta desactivada |
| POST | `/auth/cambiar-contrasena` | 204 · 400 si la actual no coincide o la nueva es corta |
| POST | `/auth/recuperar-contrasena` | **202 siempre**, exista o no el correo |
| POST | `/auth/restablecer-contrasena` | 204 · 400 si el token es inválido, usado o expiró |
| GET | `/vehiculos` | Solo los del cliente de la sesión |
| GET | `/vehiculos/{id}/manuales` | Por modelo y año, no por vehículo |
| GET | `/vehiculos/{id}/servicios` | Orden cronológico, el más reciente primero |
| GET | `/servicios/{id}/ticket` | PDF real, generado al momento |
| GET | `/agenda/disponibilidad` | Solo franjas con cupo > 0 · 400 si falta `desde` o `hasta` |
| GET | `/citas` | Solo las del cliente |
| POST | `/citas` | 201 · 409 sin cupo o doble reserva |
| POST | `/citas/{id}/cancelar` | 200 · 409 si ya no está confirmada |
| GET | `/catalogo` | Solo modelos activos |

Además, respeta tres reglas del contrato que son fáciles de pasar por alto:

- **Un recurso ajeno responde 404, no 403.** La app no puede distinguir «no
  existe» de «no es tuyo».
- **Recuperar contraseña responde 202 siempre**, para no revelar qué cuentas hay.
- **Todos los errores salen con el formato `Problema`** (`timestamp`, `status`,
  `error`, `message`, `path`).

### El token

Se firma un JWT real (HS256, con un secreto de desarrollo) aunque el mock no lo
necesite, por dos razones: tiene la misma forma que el del backend real, y la app
puede leer el claim `exp` mientras **RIC-1** siga abierta (el contrato no dice
cuánto vive el `accessToken`). Dura una hora.

## Decisiones que el mock tuvo que tomar

El contrato tiene huecos. Donde no había respuesta, el mock eligió algo razonable
y lo dejó marcado, para cambiarlo en un solo lugar cuando el equipo responda.

| Hueco | Qué hace el mock | Pregunta |
| --- | --- | --- |
| No se define qué responden las rutas protegidas si la cuenta se desactiva y el cliente ya tenía token | Responde **403** | RIC-3 |
| No se sabe con cuántas horas de anticipación se puede cancelar una cita | Solo valida que la cita no haya pasado | PO-4 |
| Los valores de `Servicio.estatus` no están definidos | Usa `Terminado` y `En proceso` como provisionales | PO-5 |
| No hay reglas de contraseña | Exige 8 caracteres como mínimo | RIC-9 |
| No se define la zona horaria de fechas y horas | Trata todo como fecha y hora local, sin zona | RIC-13 |

## Rutas de inspección

Además del contrato, json-server expone las colecciones en crudo, **sin el
prefijo** `/api/v1/app` y sin token. Sirven para ver y manipular el estado durante
el desarrollo, y **no forman parte del contrato**:

```bash
curl http://localhost:3000/cuentas
curl http://localhost:3000/franjas

# Desactivar una cuenta para probar el 403 con un token ya emitido
curl -X PATCH http://localhost:3000/cuentas/1 \
  -H 'Content-Type: application/json' -d '{"activa":false}'
```

## Por qué json-server y no otra cosa

Se eligió json-server porque el equipo ya lo usa y guarda estado, que es lo que la
app necesita para las citas.

Su límite es que deriva las rutas de la forma del JSON, no del contrato, y solo
entiende operaciones tipo CRUD. De los 13 endpoints, **5 salen gratis**
(`/vehiculos`, `/citas` en GET y POST, `/catalogo`) y los otros 8 están escritos a
mano en `server.js`: todo el bloque `/auth/*`, la cancelación, el ticket en PDF, la
disponibilidad por rango y los manuales por modelo y año.

Se fijó la versión **0.17.4**, la última estable, en lugar de la que npm instala por
omisión (`1.0.0-beta.15`): el 1.x lleva mucho tiempo en beta y quitó justo el
soporte de rutas y middleware propios, que es lo que necesitamos para esos 8
endpoints.

**La contrapartida:** las respuestas se mantienen a mano, así que pueden desviarse
del contrato cuando Ricardo lo cambie. Eso lo cubre la prueba de validación contra
el contrato (tarea 4 de TEC-5).
