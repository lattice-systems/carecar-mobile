# API simulada de Agencia360 · TEC-5

Simula la API que Agencia360 expone a la app CareCar, para que la app avance sin
esperar al backend. Simula el contrato `api/agencia360-api-app-v1.yaml`.

**No es parte de la app.** Es una herramienta de desarrollo: no se compila, no se
publica y no viaja en el APK.

## Levantarla

### Menús, vehículos y perfil

La app consulta `GET /api/v1/app/vehiculos` y `GET /api/v1/app/perfil` con
el Bearer de la sesión. Perfil devuelve `id`, `nombre` y `correo` del cliente
autenticado. Los menús de catálogo, citas, historial y manuales son placeholders.

`cliente1@example.com` tiene cuatro vehículos en la semilla: Versa, Kicks,
Nissan March Sense 2020 (id 5) y Volkswagen Jetta Comfortline 2018 (id 6).
Los dos nuevos pertenecen a `clienteId: 1` y tienen VIN de 17 caracteres.
Los colores Blanco/Gris son metadatos internos de la semilla: el contrato v1.1
solo expone `id`, `vin`, `modelo`, `anio`, `placas` y `kilometraje`; la app muestra
«No disponible» para marca, tipo, versión y color por separado.

Si ya existe `db.json`, `npm run reset` copia la semilla **y elimina cambios
locales del mock**. Reiniciar el servidor después de hacerlo; mantiene datos en
memoria. Si los datos ya están incorporados, basta con reiniciar el servidor.

Para probar en otro puerto desde PowerShell:

```powershell
# Terminal del mock, dentro de mock_api/
$env:PORT = '3001'
npm start

# Otra terminal, desde la raíz del proyecto
flutter test --dart-define=MOCK_API_URL=http://localhost:3001/api/v1/app
```

Las secciones históricas de abajo conservan referencias a `usuario`, tokens de
recuperación y 13 operaciones. Para el flujo actual se usa correo, recuperación
por código y el contrato `api/agencia360-api-app-v1.yaml` v1.1.0.

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
# Contra la API simulada: el flavor desarrollo ya apunta a :3000
# (10.0.2.2 en emulador Android, localhost en simulador iOS)
flutter run --flavor desarrollo -t lib/main_desarrollo.dart

# Otra dirección (PC en la red local, servidor propio)
flutter run --flavor desarrollo -t lib/main_desarrollo.dart --dart-define=API_BASE_URL=http://IP-DE-LA-PC:3000/api/v1/app
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
- Agendar **descuenta** el cupo de la franja; cancelar lo devuelve y reprogramar ocupa la franja nueva y libera la anterior.
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
| GET | `/vehiculos/{id}/ficha-tecnica` | Por modelo y año (V2-M02.04) · 404 si no hay ficha de ese modelo y año |
| GET | `/vehiculos/{id}/servicios` | Orden cronológico, el más reciente primero; `anio` filtra por año y cada orden trae `fechaCierre` (V2-M02.05) |
| GET | `/vehiculos/{id}/servicios/anios` | Años con servicios, del más reciente al más antiguo (V2-M02.05) |
| GET | `/servicios/{id}` | Ticket con mano de obra, refacciones y totales (V2-M02.06) |
| GET | `/servicios/{id}/ticket` | PDF real, generado al momento |
| GET | `/agenda/disponibilidad` | Solo franjas con cupo > 0 · 400 si falta `desde` o `hasta` |
| GET | `/citas` | Solo las del cliente |
| POST | `/citas` | 201 · 409 sin cupo o doble reserva · con `recoleccion: { direccionId }` crea los traslados de recoger y entregar y los devuelve en `recoleccion` · 404 si la dirección es ajena · 422 `FUERA_DE_COBERTURA` |
| POST | `/citas/{id}/cancelar` | 200 · 409 si ya no está confirmada |
| POST | `/citas/{id}/reprogramar` | 200 · 409 `FRANJA_SIN_CUPO`, `CITA_NO_REPROGRAMABLE` o `FUERA_DE_PLAZO` (propuesto en V2-M02.13; no está en el contrato v1) |
| GET | `/direcciones` | Las del cliente (V2-M17.01) |
| POST | `/direcciones` | 201 · 400 `DATOS_INVALIDOS` · 422 `FUERA_DE_COBERTURA` (círculo de 40 km alrededor de la Ciudad de México) |
| PUT | `/direcciones/{id}` | 200 · 400 · 404 si es ajena · 422 |
| DELETE | `/direcciones/{id}` | 204 · 404 · 409 `DIRECCION_EN_USO` si ya tiene traslados |
| GET | `/recoleccion/cotizacion` | `direccionId` y `fecha` · costo por traslado (80 + 12 por km), total, y franjas 07:00-09:00 y 17:00-19:00 · 400 · 404 · 422 (V2-M17.02) |
| GET | `/catalogo` | Solo modelos activos |
| GET | `/catalogo/{id}` | Detalle con `imagenes`, `versiones` y `especificaciones` · 404 si no existe o está retirado |
| POST | `/toma-a-cuenta/estimaciones` | 201 con el rango y los supuestos, y la guarda · 400 si el auto no viene de una sola forma o km, año o estado no sirven · 404 si el vehículo es ajeno o el modelo está retirado · 422 `SIN_PARAMETROS_DE_VALUACION` si no hay parámetros para ese auto |
| GET | `/toma-a-cuenta/estimaciones` | Las del cliente, la más reciente primero, con `pagina` y `tamano` |
| POST | `/asistente/preguntas` | Sin IA (V2-M24.03): si la pregunta toca un tema del manual (aceite, llantas, testigos, frenos…) responde con una cita de ejemplo a la página 12; si no, `encontrado: false` sin fuentes · 400 sin pregunta · 404 vehículo ajeno |
| POST | `/asistente/consultas/{id}/calificacion` | V2-M24.07: 204 con `{"util": true}` o `false` (no se guarda) · 400 sin `util` |
| GET | `/ordenes/activas` | Órdenes en el taller sin entregar (V2-M04.01). `cliente1` tiene la orden 41 del March en reparación |
| GET | `/ordenes/{id}` | Etapas con su hora, entrega estimada, inspección con fotos y un video, dos trabajos adicionales y totales (V2-M04.02 y V2-M04.04) · 404 si es ajena |
| POST | `/ordenes/{id}/adicionales/{aid}/respuesta` | `{"aprobado": true, "firma": "<PNG en Base64>"}` · 200 con los totales recalculados · 400 si la firma no es PNG · 409 `ADICIONAL_YA_RESPONDIDO` u `ORDEN_CERRADA` (V2-M04.05) |
| GET | `/api/v1/archivos/evidencias/{id}` | Fuera de la base y sin token: una foto PNG de prueba. El video de la orden apunta a un MP4 público, así que se ve con internet |

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

Como json-server queda fijo, sus dependencias (Express, `body-parser`, `qs`…) se
parchean **en `package-lock.json`** sin cambiar `package.json`: si Dependabot avisa
de una vulnerabilidad en una de ellas, `npm update <paquete>` la sube dentro del
rango que ya acepta su padre y `npm audit` confirma que quedó limpio. Así se
cerraron los avisos de `body-parser` (1.20.8 → 1.20.9) y `qs` (6.16.0 → 6.16.2).

**La contrapartida:** las respuestas se mantienen a mano, así que pueden desviarse
del contrato cuando Ricardo lo cambie. Eso lo cubre la prueba de validación contra
el contrato (tarea 4 de TEC-5).
