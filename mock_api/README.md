# API simulada de Agencia360 · TEC-5

Simula la API que Agencia360 expone a la app CareCar, para que la app avance sin
esperar al backend. Incluye operaciones del contrato v1 y módulos de v2.

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

Si ya existe `db.json`, `npm run reset` reúne las semillas **y elimina cambios
locales del mock**. Detén el servidor antes de restaurar los datos y vuelve a
iniciarlo después para que lea el archivo nuevo.

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
| `semillas/<modulo>.json` | Colecciones iniciales versionadas por módulo |
| `db.json` | Estado vivo. Lo modifican las peticiones `POST`. **Está ignorado por git** |

El servidor crea `db.json` reuniendo todas las semillas la primera vez. Los
arranques siguientes leen el estado persistido. Para volver al estado inicial:

```bash
npm run reset
```

### Agregar un módulo

1. Crea `modulos/<modulo>.js` con una función CommonJS que registre las rutas en
   `servidor`. Recibe `db` si necesita leer o escribir colecciones. Usa `BASE`,
   `problema` y `noEncontrado` de `comun/http.js` para las rutas y errores del
   contrato. Los módulos se registran después de la guardia de sesión.
2. Registra la función en `server.js` antes del manejo de rutas desconocidas.
   Pasa sólo las dependencias necesarias. Por ejemplo, Citas recibe de
   Recolección las operaciones que necesita para crear y cancelar traslados.
3. Si hay datos persistidos, crea `semillas/<modulo>.json` con un objeto cuyas
   claves sean nombres de colecciones y cuyos valores sean listas. Para sumar
   datos a una colección existente, edita la semilla del módulo dueño. El reset
   detecta nombres repetidos antes de escribir `db.json`.
4. Si agregas una colección, inicialízala con `db.defaults(...).write()` en el
   módulo para que funcione con los `db.json` creados en versiones previas.
   Revisa el arranque con y sin un estado persistido.

Las rutas sin datos persistidos, como Asistencia y Eventos, mantienen su estado
en memoria y no necesitan un archivo de semilla.

### Guarda estado

A diferencia de un mock sin estado, aquí las escrituras se quedan:

- Agendar una cita la hace aparecer en `GET /citas`.
- Agendar **descuenta** el cupo de la franja; cancelar lo devuelve y reprogramar ocupa la franja nueva y libera la anterior.
- Cambiar la contraseña cambia con qué contraseña entras después.

Por eso existe `npm run reset`.

## Qué cubre

Operaciones de la app y casos de error:

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
| GET | `/servicios/{id}` | Ticket con mano de obra, refacciones y totales (V2-M02.06) y `puntosGanados` de lealtad: la orden 2 dio 230 (V2-M12.02) · `pago` (con qué, referencia y fecha) y `pagable` (V2-M08.02): la 2 está pagada con la Visa 4242 |
| GET | `/servicios/{id}/ticket` | PDF real, generado al momento |
| GET | `/agenda/disponibilidad` | Solo franjas con cupo > 0 · 400 si falta `desde` o `hasta` |
| GET | `/citas` | Solo las del cliente · cada cita con recolección trae `recoleccion` (traslados con su estado vigente, V2-M17.03) |
| POST | `/citas` | 201 · 409 sin cupo o doble reserva · con `recoleccion: { direccionId }` crea los traslados de recoger y entregar y los devuelve en `recoleccion` · 404 si la dirección es ajena · 422 `FUERA_DE_COBERTURA` |
| POST | `/citas/{id}/cancelar` | 200 · 409 si ya no está confirmada |
| POST | `/citas/{id}/reprogramar` | 200 · 409 `FRANJA_SIN_CUPO`, `CITA_NO_REPROGRAMABLE` o `FUERA_DE_PLAZO` (propuesto en V2-M02.13; no está en el contrato v1) |
| GET | `/direcciones` | Las del cliente (V2-M17.01) |
| POST | `/direcciones` | 201 · 400 `DATOS_INVALIDOS` · 422 `FUERA_DE_COBERTURA` (15 km alrededor del centro de León, Guanajuato) |
| PUT | `/direcciones/{id}` | 200 · 400 · 404 si es ajena · 422 |
| DELETE | `/direcciones/{id}` | 204 · 404 · 409 `DIRECCION_EN_USO` si ya tiene traslados |
| GET | `/vehiculos/{id}/mantenimiento` | Plan de 8 servicios cada 5 000 km con su estado y el próximo servicio · 404 si el vehículo es ajeno · los de 2014 o anteriores no tienen plan (V2-M05.01) |
| POST | `/vehiculos/{id}/lecturas-km` | `{ km }` · 201 lectura del cliente · 400 `DATOS_INVALIDOS` · 404 · 422 `KM_INVALIDO` si es menor a la última lectura (V2-M05.03) |
| GET | `/recoleccion/cotizacion` | `direccionId` y `fecha` · costo por traslado (80 + 8 por km), total, y franjas 07:00-09:00 y 17:00-19:00 · 400 · 404 · 422 (V2-M17.02) |
| GET | `/catalogo` | Solo modelos activos |
| GET | `/catalogo/{id}` | Detalle con `imagenes`, `versiones` y `especificaciones` · 404 si no existe o está retirado |
| POST | `/toma-a-cuenta/estimaciones` | 201 con el rango y los supuestos, y la guarda · 400 si el auto no viene de una sola forma o km, año o estado no sirven · 404 si el vehículo es ajeno o el modelo está retirado · 422 `SIN_PARAMETROS_DE_VALUACION` si no hay parámetros para ese auto |
| GET | `/toma-a-cuenta/estimaciones` | Las del cliente, la más reciente primero, con `pagina` y `tamano` |
| POST | `/asistente/preguntas` | Sin IA (V2-M24.03): si la pregunta toca un tema del manual (aceite, llantas, testigos, frenos…) responde con una cita de ejemplo a la página 12; si no, `encontrado: false` sin fuentes · 400 sin pregunta · 404 vehículo ajeno |
| POST | `/asistente/preguntas/flujo` | V2-M24.09: SSE con la misma respuesta palabra por palabra (eventos `texto` cada 70 ms y `fin`) · 400 · 404 |
| POST | `/asistente/consultas/{id}/calificacion` | V2-M24.07: 204 con `{"util": true}` o `false` (no se guarda) · 400 sin `util` |
| POST | `/asistente/testigos` | V2-M24.05 (multipart `vehiculoId`, `imagen`): siempre «Presión de aceite», roja, con cita a la pág. 12 · 400 sin imagen · 404 vehículo ajeno |
| POST | `/estreno/cotizaciones/calculo` | V2-M16.02: mensualidad con 14.99 %, enganche mínimo 10 % y plazos 12–60 · 409 `ESTRENO_SIN_PRECIO` · 400 |
| POST | `/estreno/solicitudes` | V2-M16.01: prueba o cotización; el simulador asigna a «Vera Vendedora» al instante (`EN_ATENCION`) · 409 `ESTRENO_DUPLICADA` · 400 · 404 |
| GET | `/estreno/solicitudes` | V2-M16.04: paginado, solo en memoria (se pierde al reiniciar) |
| GET | `/privacidad/aviso` | V2-M22.01: el aviso vigente (la versión 2 nombra a los proveedores externos; la 1 es el texto que la app traía) con `aceptado` de tu cuenta |
| POST | `/privacidad/aceptaciones` | V2-M22.01: `{avisoId}` · idempotente · 404 · 409 `AVISO_NO_VIGENTE` si ya hay una versión más nueva · en memoria |
| GET | `/privacidad/arco` | V2-M22.02: mis solicitudes de derechos ARCO (las últimas 20) |
| POST | `/privacidad/arco/acceso` | V2-M22.02: 202 y la solicitud `PENDIENTE`; a los 2 s (`RETRASO_ARCO_MS`, 0 = al instante) queda `RESUELTA` y llega el evento `arco.estado`; si ya había una pendiente, 200 con esa · en memoria |
| GET | `/privacidad/arco/{id}/archivo` | V2-M22.02: el JSON como adjunto, sin caché · 404 si no es tuya o no está lista |
| POST | `/privacidad/arco/cancelacion` | V2-M22.03: `{contrasena}` borra tu cuenta · 200 con la solicitud `CANCELACION` `RESUELTA` · contraseña equivocada o ausente: 400 `DATOS_INVALIDOS` (no 401) · a los 5 fallos, 429 con `Retry-After` 15 min · después cualquier token suyo recibe 403 y el login con la contraseña vieja, 401 · se guarda en `db.json`: `npm run reset` la devuelve |
| POST | `/api/v1/avisos-privacidad` | Solo del simulador (en el backend es del Gerente de marketing): publica la versión siguiente con `{texto}` para probar que una versión nueva vuelve a pedir la aceptación |
| GET | `/ordenes/activas` | Órdenes en el taller sin entregar (V2-M04.01). `cliente1` tiene la orden 41 del March en reparación |
| GET | `/ordenes/{id}` | Etapas con su hora, entrega estimada, inspección con fotos y un video, dos trabajos adicionales y totales (V2-M04.02 y V2-M04.04) · 404 si es ajena |
| POST | `/ordenes/{id}/adicionales/{aid}/respuesta` | `{"aprobado": true, "firma": "<PNG en Base64>"}` · 200 con los totales recalculados · 400 si la firma no es PNG · 409 `ADICIONAL_YA_RESPONDIDO` u `ORDEN_CERRADA` (V2-M04.05) |
| GET | `/vehiculos/{id}/garantia` | Coberturas con días y km restantes, consumo y estado contra el km más alto conocido (el del taller o la última lectura del cliente) · por vencer a 60 días o 1 000 km · `cliente1` tiene tres del March (5); la batería está por vencer (V2-M10.01) · 404 si es ajeno |
| GET | `/vehiculos/{id}/campanas` | Campañas de seguridad del vehículo, pendientes primero y las más graves arriba; la fila se crea al consultarla y una cita cancelada la reabre · el March tiene la crítica RC-24-017 pendiente y la RC-23-002 atendida (V2-M10.02) |
| POST | `/vehiculos/{id}/campanas/{cid}/cita` | `{franjaId, fecha}` · 201 con la cita (`motivo: campana`) y la campaña queda agendada · 409 `CAMPANA_NO_AGENDABLE`, `FRANJA_SIN_CUPO` o `CITA_DUPLICADA` · 400 · 404 (V2-M10.03) |
| GET | `/lealtad` | Saldo (suma de movimientos), nivel por lo ganado en 12 meses (Plata desde 1 500, Oro desde 4 000), lo que falta y el código de referido · `cliente1` está en Plata con 1,330 puntos (V2-M12.01) · antes de responder vence los canjes pasados de fecha y devuelve sus puntos |
| GET | `/lealtad/movimientos` | Del más nuevo, paginado (`pagina`, `tamano`) con referencia a la orden, el canje o el referido (V2-M12.05) |
| GET | `/lealtad/recompensas` | Activas, de la más barata · el «Termo CareCar» está agotado (V2-M12.03) |
| POST | `/lealtad/canjes` | `{recompensaId}` · 201 con código de 8 caracteres vigente 30 días y movimiento `CANJE` · 409 `SALDO_INSUFICIENTE` o `RECOMPENSA_AGOTADA` · 404 |
| GET | `/lealtad/canjes` | Mis canjes con estado (V2-M12.03) |
| POST | `/lealtad/referidos` | `{nombre, telefono?, correo?, consentimiento}` · 201 en seguimiento · 400 sin contacto, sin consentimiento o teléfono que no tiene 10 dígitos · 409 `REFERIDO_DUPLICADO` (correo de una cuenta o contacto ya referido) o `LIMITE_REFERIDOS` (10 abiertos) (V2-M12.04) |
| GET | `/lealtad/referidos` | Mis referidos con su estado y los puntos que dio el que compró |
| GET | `/catalogos-fiscales` | Regímenes fiscales y usos de CFDI de CFDI 4.0, copia de `CatalogoFiscal.java` (`semillas/catalogos_fiscales.json`): a qué persona aplica cada clave y qué regímenes acepta cada uso (V2-M08.05) |
| GET · POST | `/perfiles-fiscales` | Mis perfiles, el predeterminado primero · `cliente1` trae GODE561231GR8 · el primero que se crea queda predeterminado y otro lo toma con `predeterminado: true` · 400 `DATOS_FISCALES_INVALIDOS` con `campos` (RFC con forma, fecha y dígito verificador; régimen y uso del catálogo para la persona; uso aceptado por el régimen; código postal; correo) (V2-M08.05) |
| GET · PUT · DELETE | `/perfiles-fiscales/{id}` | El mío o 404 · PUT con las mismas reglas · DELETE 204; si era el predeterminado, lo toma el más viejo. Los pagos y facturas de M08 son simulados ([ADR 0009](../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md)) |
| POST | `/ordenes/{id}/pagos` | Header `Idempotency-Key` · `{tarjeta: {token, mesVence, anioVence}}` o `{metodoPagoId}`, más `guardarTarjeta` y `perfilFiscalId` · 201, o 200 con la misma llave · decide por el token de prueba (`tok_sim_visa`, `tok_sim_mastercard`, `tok_sim_visa_debito`, `tok_sim_fondos_insuficientes`, `tok_sim_3ds`, `tok_sim_3ds_falla`) · 400 · 404 · 409 `ORDEN_NO_PAGABLE` o `PAGO_EN_CURSO` · al pagarse suma los puntos y emite `pago.confirmado` (V2-M08.02) |
| POST | `/pagos/{id}/autenticacion` | `{confirmada}` · responde el 3-D Secure simulado · 404 · 409 `PAGO_NO_PENDIENTE` |
| GET | `/pagos` y `/pagos/{id}` | Mis pagos del más nuevo, paginados (`pagina`, `tamano`) · `cliente1` trae uno pagado (orden 2) y uno fallido (orden 3) (V2-M08.07) |
| GET · PUT · DELETE | `/metodos-pago` · `/metodos-pago/{id}/predeterminado` · `/metodos-pago/{id}` | Tarjetas guardadas, la predeterminada primero · `cliente1` trae la Visa 4242 · borrar la predeterminada pasa la marca a otra · 404 ajena (V2-M08.04) |
| GET | `/api/v1/archivos/evidencias/{id}` | Fuera de la base y sin token: una foto PNG de prueba. El video de la orden apunta a un MP4 público, así que se ve con internet |
| POST | `/valuaciones` | `{estimacionTomaCuentaId}`. 201, o 200 con la abierta de ese vehículo. 400. 404 si la estimación es ajena. 422 `VALUACION_SIN_VEHICULO` si se capturó a mano (V2-M26.01) |
| GET | `/valuaciones` y `/valuaciones/{id}` | Paginadas, la más reciente primero, con el estado al día: oferta pasada es `VENCIDA` y una cita cancelada la regresa a `SOLICITADA`. La semilla trae el Jetta (6) con una oferta vigente y estimaciones del March (5) en varios meses, y agrega franjas futuras si las de citas ya pasaron |
| POST | `/valuaciones/{id}/fotos/{toma}` | Multipart `imagen` JPEG o PNG de hasta 8 MB, reemplaza la toma. 400 (también de 8 a 20 MB). 413 arriba de 20 MB. 404. 409 `VALUACION_CERRADA`. La imagen no se guarda: la URL entrega una de prueba (V2-M26.02) |
| POST | `/valuaciones/{id}/cita` | `{franjaId, fecha}`. 201 con la cita (`motivo: valuacion`). 400. 404. 409 `VALUACION_NO_AGENDABLE`, `FRANJA_SIN_CUPO` o `CITA_DUPLICADA` (V2-M26.03) |
| POST | `/valuaciones/{id}/respuesta` | `{aceptada, monto}`. Repetir lo mismo responde 200. 400. 404. 409 `OFERTA_VENCIDA` u `OFERTA_NO_DISPONIBLE` (V2-M26.04) |
| GET | `/vehiculos/{id}/valor-estimado` | `meses` de 1 a 36 (12 por omisión). Un punto por mes con la última estimación de ese mes. 400. 404 (V2-M26.05) |
| GET | `/api/v1/archivos/valuacion-fotos/{id}` | Fuera de la base y sin token: la imagen de prueba de una foto de valuación |
| GET | `/tienda/productos` | `vehiculoId`, `categoria` (`accesorio`, `refaccion`, `cuidado`), `q`, `pagina` y `tamano`. Por nombre. Con `vehiculoId` solo salen los universales y los de su modelo y año, con `compatible`. Los agotados sí se listan. 400. 404 si el vehículo es ajeno (V2-M14.01) |
| GET | `/tienda/productos/{id}` | Con `vehiculoId` dice `compatible`. 404 (V2-M14.01) |
| POST | `/tienda/pedidos` | `Idempotency-Key` obligatoria. 201, o 200 con el pedido de esa llave. 400. 404. 409 `SIN_EXISTENCIA`, `CITA_NO_DISPONIBLE` o `LIMITE_APARTADOS` (3 sin entregar). 422 `PRODUCTO_INCOMPATIBLE`. Vence en 48 horas o al final del día siguiente a la cita (V2-M14.02 y V2-M14.03) |
| GET | `/tienda/pedidos` y `/tienda/pedidos/{id}` | Del más reciente al más antiguo. Antes de responder vence lo pasado de hora y sigue a la cita ligada: cancelada regresa a mostrador y reprogramada mueve la vigencia (V2-M14.05) |
| POST | `/tienda/pedidos/{id}/cancelar` | Libera las piezas. Repetirlo responde 200. 409 `PEDIDO_NO_CANCELABLE` (V2-M14.02) |
| PUT | `/tienda/pedidos/{id}/instalacion` | `{citaId}`, o nulo para volver a mostrador. 409 `CITA_NO_DISPONIBLE` o `PEDIDO_NO_MODIFICABLE`. 422 `PRODUCTO_INCOMPATIBLE` (V2-M14.03) |

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

## Eventos en vivo y emisor de prueba

`GET /api/v1/app/eventos` es un canal Server-Sent Events (`event:` y `data:` JSON) con latido cada 25 s y cierre a los 30 min, como el backend. Solo llegan los eventos del cliente que escucha. Como no hay agencia ni chofer, el mock trae un emisor **fuera del contrato** (sin token) para provocar avances y verlos en la app:

```bash
# V2-M11.04 · la ayuda va en camino (id de la solicitud abierta)
curl -X POST localhost:3000/__mock/asistencia/1/estado -H 'content-type: application/json' -d '{"estado":"en_camino"}'
# V2-M17.03 · el chofer sale, se mueve y recoge el auto
curl -X POST localhost:3000/__mock/traslados/1/estado -H 'content-type: application/json' -d '{"estado":"en_camino"}'
curl -X POST localhost:3000/__mock/traslados/1/ubicacion -H 'content-type: application/json' -d '{"lat":19.43,"lng":-99.13}'
curl -X POST localhost:3000/__mock/traslados/1/estado -H 'content-type: application/json' -d '{"estado":"recogido"}'
# V2-M17.04 · checklist a mano (al pasar a recogido o entregado se crea uno)
curl -X POST localhost:3000/__mock/traslados/1/checklist -H 'content-type: application/json' -d '{"km":45200,"gasolina":"medio"}'
curl -X POST localhost:3000/__mock/ordenes/3/pagada-en-caja -H 'content-type: application/json' -d '{"referencia":"CAJA-0042"}'
# V2-M04.03, V2-M04.06 y V2-M04.07 · el taller pasa la orden 41 a lista y luego la entrega
curl -X POST localhost:3000/__mock/ordenes/41/etapa -H 'content-type: application/json' -d '{"etapa":"LISTO_PARA_ENTREGA"}'
curl -X POST localhost:3000/__mock/ordenes/41/etapa -H 'content-type: application/json' -d '{"etapa":"ENTREGADO"}'
# V2-M10.04 · se publica una campaña para el March (5) y llega `campana.nueva`
curl -X POST localhost:3000/__mock/campanas -H 'content-type: application/json' -d '{"codigo":"RC-26-001","titulo":"Freno de estacionamiento","gravedad":"ALTA","vehiculoIds":[5]}'
# V2-M10.03 · el taller marca atendida la campaña 1 del March
curl -X POST localhost:3000/__mock/campanas/1/vehiculos/5/atendida
# V2-M26.04: ventas captura o renueva la oferta de la valuación 1 (debe tener cita) y llega `valuacion.oferta`
curl -X POST localhost:3000/__mock/valuaciones/1/oferta -H 'content-type: application/json' -d '{"monto":125000,"nota":"Oferta de prueba"}'
# V2-M14.05: la agencia marca el pedido 1 como listo, entregado o cancelado y llega `pedido.estado`
curl -X POST localhost:3000/__mock/pedidos/1/estado -H 'content-type: application/json' -d '{"estado":"listo"}'
# V2-M10.05 · aviso de garantía por vencer de la batería (motivo opcional: dias_60, dias_15 o km_1000)
curl -X POST localhost:3000/__mock/garantias/1/aviso -H 'content-type: application/json' -d '{"motivo":"dias_60"}'
# V2-M12.02 · el cliente 1 gana 165 puntos por un servicio y llega `puntos.movidos`
curl -X POST localhost:3000/__mock/puntos -H 'content-type: application/json' -d '{"clienteId":1,"puntos":165,"ordenId":2}'
# V2-M12.03 · el personal marca usado un canje vigente (código de la app)
curl -X POST localhost:3000/__mock/canjes/K7XQ2MPA/usar
# V2-M12.04 · la venta del referido 2 se finaliza: el cliente gana 500 puntos una sola vez
curl -X POST localhost:3000/__mock/referidos/2/compro
```

Cada cambio de la orden (etapa nueva o respuesta a un adicional) llega como evento `orden` con `ordenId`, `vehiculoId`, `estatus`, `etapa` y `motivo`. Lista o entregada, la orden suma los adicionales aprobados, trae `horarioEntrega` de 09:00 a 17:00 y queda en el historial (`/servicios/{id}` con el mismo id). La etapa debe ir después de la actual (400) y una orden entregada ya no cambia (409 `ORDEN_CERRADA`).

Los traslados se crean agendando una cita con recolección desde la app. La ubicación del chofer solo se manda en `en_camino` y `de_regreso`; las fotos del checklist son de `picsum.photos` (hace falta internet) y su parámetro de firma cambia en cada petición.

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
