# M05 · Mantenimiento inteligente

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Juan Pablo |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 5. Mantenimiento inteligente |
| Estado | Listo para historias |

## Propósito

Decirle al cliente **qué** servicio toca, **cuándo** y **cuánto** cuesta antes de que lo pregunte, y llevarlo a agendar en un toque. Mueve O2 y O4.

## Pantallas

- **Plan de mantenimiento** — servicios por km/tiempo del modelo (5 000, 10 000…), hechos vs. pendientes.
- **Próximo servicio** (tarjeta en Garaje e Inicio) — km/fecha estimados, precio estimado, botón Agendar.
- **Actualizar kilometraje** — el cliente registra su km actual (foto del odómetro opcional).
- **Paquetes de servicio** — qué incluye cada servicio y su precio.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `plan_mantenimiento` ➕ | id, modelo, anio_desde, anio_hasta, km, meses, nombre, precio_estimado | Por modelo. |
| `concepto_mantenimiento` ➕ | id, plan_mantenimiento_id, concepto | Qué incluye. |
| `lectura_km` ➕ | id, vehiculo_cliente_id, km, fuente (taller/cliente), foto_url, registrada_en | El taller sigue siendo la fuente oficial (ficha). |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/vehiculos/{id}/mantenimiento` | Plan con estado y próximo. |
| POST | `/vehiculos/{id}/lecturas-km` | Lectura del cliente. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M05.01 | Como cliente quiero ver el plan de mantenimiento de mi modelo | Lista por km/meses con hechos (cruzados con historial) y pendientes | ✅ | V2-M02.05 |
| V2-M05.02 | Como cliente quiero saber cuándo toca mi próximo servicio | Estimación por km promedio diario (lecturas) y por tiempo; gana lo que llegue primero | ✅ | V2-M05.01 |
| V2-M05.03 | Como cliente quiero registrar mi kilometraje actual | Validación: no menor a la última lectura oficial · foto opcional · el km oficial (taller) no se sobrescribe | ✅ | V2-M05.02 |
| V2-M05.04 | Como cliente quiero agendar el servicio recomendado en un toque | Abre Agendar cita con vehículo y motivo precargados | | V2-M05.02, V2-M02.08 |
| V2-M05.05 | Como cliente quiero un recordatorio cuando se acerque mi servicio | Push a 1 000 km o 2 semanas antes (configurable) | ✅ | V2-M06.02 |
| V2-M05.06 | Como cliente quiero ver qué incluye cada servicio y su precio estimado | Conceptos y precio con leyenda de estimado | ✅ | V2-M05.01 |

## Avance de V2-M05.01

El módulo vive en `lib/modulos/mantenimiento/` (`dominio/`, `datos/`, `presentacion/`) y su contrato público es `mantenimiento.dart`. El plan se abre en `/mantenimiento/{vehiculoId}` (exige sesión) y se alcanza desde la fila «Mantenimiento» del grupo «Tu auto» del detalle del vehículo (`lib/modulos/vehiculos`). Es un módulo nuevo en v2: sus rutas se registran en `registro_de_rutas.dart` sin interruptor v1/v2, como `asistente` y `recoleccion`.

- **Contrato:** `GET /vehiculos/{vehiculoId}/mantenimiento` devuelve `PlanMantenimiento` (`kmActual`, `kmActualizadoEn`, `kmFuente`, `promedioKmDiario`, `servicios[]`, `proximo`). Cada servicio trae `estado` (`hecho` cruzado con el historial, `pendiente`, `proximo`, `vencido`), `hechoEn`, `precioEstimado` y `conceptos`. Sin plan para el modelo y año responde 200 con `servicios` vacío y `proximo` nulo. Los DTO están en `lib/api/modelos/mantenimiento.dart`; el repositorio los traduce a dominio (`RepositorioMantenimientoApi`) y existe un fake con un plan de ejemplo (`RepositorioMantenimientoFake`). La copia del contrato en `api/` y `test/contrato` se integra aparte desde el backend.
- **Pantalla:** `PantallaPlanMantenimiento` en «Estilo portada»: `CabeceraPortada` con el próximo servicio como héroe, grupo «Tu kilometraje» (km vigente, quién lo registró y promedio diario) y grupo «Plan de servicios» con una fila por servicio. El estado va en el subtítulo de la fila («Hecho el…», «Próximo · 10,000 km · 12 meses») además del ícono y su color, porque `GrupoLista` lee cada fila como un solo nodo y deja fuera el adorno final. `BarraPortada` opaca al desplazar: nada atraviesa el título.
- **Cinco estados:** cargando (esqueleto anunciado), datos, vacío (el modelo no tiene plan), error con reintento y sin conexión.
- **Pruebas:** `test/modulos/mantenimiento/` (dominio, repositorio API y fake, pantallas, rutas y títulos al desplazar), `test/api/mantenimiento_modelos_test.dart` y la fila en `test/modulos/vehiculos/pantalla_detalle_test.dart`. Cada pantalla se prueba en claro, oscuro y letra al 200 % y pasa la auditoría de accesibilidad.
- **Textos:** claves `mantenimiento*` en `app_es.arb` y `app_en.arb`.

## Avance de V2-M05.02

El próximo servicio es el héroe del plan: título con el nombre del servicio, una línea con el motivo («Te toca por kilometraje» o «Te toca por tiempo transcurrido», según lo que haya llegado primero) y otra con «Faltan N km · hacia el {fecha}». Cuando ya se pasó (no falta km o no faltan días) dice «Ya te toca · pasó de los N km» sin cifras negativas. La estimación la calcula el servidor (promedio diario de las lecturas y meses del plan; gana lo que llegue primero); la app solo la muestra y no inventa una fecha: sin km conocido el héroe invita a registrar el kilometraje.

## Avance de V2-M05.03

`PantallaRegistrarKm` (`/mantenimiento/{vehiculoId}/kilometraje`): `CampoTexto` numérico con la ayuda «Tu último registro: N km» y la nota de que el km del taller es el oficial y no se reemplaza.

- **Validación local:** vacío, cero y menor a la última lectura que se conoce se rechazan antes de llamar al servidor. El mismo km que el último es válido.
- **Servidor:** `POST /vehiculos/{vehiculoId}/lecturas-km` con `{ km }` devuelve 201 `LecturaKm` (fuente siempre `cliente`). El 422 `KM_INVALIDO` se traduce a `KmInvalido` y se explica; `KM_INVALIDO` se agregó a `CodigoProblema` y a `test/api/errores_v11_test.dart`. Un 422 con otro código no se confunde con él. Sin conexión se conserva lo escrito y se puede reintentar; mientras guarda se anuncia y no deja guardar dos veces.
- **Éxito:** cierra con `true`; el plan se recarga y muestra «Kilometraje guardado. Actualizamos tu próximo servicio.».
- **Pendiente:** la foto opcional del odómetro (`foto_url` de `lectura_km`) no está en el contrato acordado de `POST /lecturas-km` (solo `km`); se agrega cuando el contrato la incorpore y exista un componente de captura de foto.

## Avance de V2-M05.04

«Agendar este servicio» (héroe del plan y barra inferior del detalle de un servicio sin hacer) abre `/citas/agendar?vehiculoId={id}&motivo=mantenimiento`. Cambio mínimo en `lib/modulos/citas`: `PantallaAgendarCita` gana `vehiculoIdInicial` y `motivoInicial` opcionales, la ruta los lee de la consulta y `localizacionAgendarCita({vehiculoId, motivo})` (exportada en `citas.dart`) arma el enlace. La persona puede cambiar ambos; un vehículo que ya no está en el garaje o un parámetro desconocido se ignoran y se agenda a mano. Pruebas: `test/modulos/citas/agendar_prellenado_test.dart` y `test/modulos/mantenimiento/ruta_mantenimiento_test.dart`.

## Avance de V2-M05.06

`PantallaServicioMantenimiento` (`/mantenimiento/{vehiculoId}/servicio/{servicioId}`): insignia de estado, km y meses del servicio, grupo «Qué incluye» con los conceptos y una tarjeta con «Precio estimado» y la leyenda «Estimación no vinculante», leídas juntas como una sola frase por el lector de pantalla (el monto nunca se anuncia sin decir que es estimado). Un servicio hecho dice cuándo se hizo y no ofrece agendar; uno que ya no está en el plan lo explica. Sale del mismo `GET /mantenimiento`: no hay endpoint aparte.

## Avance de V2-M05.05

Recordatorio del próximo servicio. Backend (parte B) en `agencia-360-backend` (ver su `plan/historias-backend.md`, «Diseño técnico — V2-M05.05») y un aviso en la app.

- **Backend:** un job diario avisa a 1 000 km o 14 días del próximo servicio (umbrales por entorno), una sola vez por vehículo y servicio (`recordatorio_mantenimiento`, migración `V46`), y publica el evento en vivo `mantenimiento.recordatorio` (contrato 2.14.0 del backend; a `api/` solo se copió este evento, porque el resto trae `AVISO_NO_VIGENTE` de V2-M22 que la app aún no mapea).
- **App:** `PantallaPlanMantenimiento` escucha el canal en vivo; si llega el recordatorio de **ese** vehículo muestra «Tu próximo servicio ya se acerca…» (aviso cerrable) y vuelve a pedir el plan. Pruebas: `test/modulos/mantenimiento/recordatorio_en_vivo_test.dart` (este vehículo, otro vehículo y otro tipo de evento).

**Decisiones sobre trabajo de otras personas**

- **Push (V2-M06.02 y V2-M06.07, Jael):** el criterio dice «push», pero el servicio de envío no existe. El backend publica el evento de dominio y hoy solo llega por el canal en vivo (app abierta). Cuando Jael integre M06.07 y escuche `AvisoAlCliente`, el push sale sin tocar este código; el texto del push y la preferencia del cliente (V2-M06.05) los define ella.
- **Tocar el aviso lleva a su pantalla** es V2-M06.03 (Jael): aquí el aviso está dentro del plan y no navega.

**Pendiente:** el push real con la app cerrada (depende de M06) y un umbral por cliente (depende de V2-M06.05). La historia queda `En revisión`, no `Hecha`.

## Mock

`mock_api/modulos/mantenimiento.js` simula ambos endpoints: plan de 8 servicios cada 5 000 km cuyo estado sale del km vigente, promedio diario de las lecturas (35 km/día por omisión), 404 para vehículo ajeno, 400 `DATOS_INVALIDOS` y 422 `KM_INVALIDO` en las lecturas. Los vehículos de 2014 o anteriores no tienen plan.

## Rediseño: encabezados ligeros (V2-T02.21)

`PantallaPlanMantenimiento` ya no lleva portada: `MarcoPantalla` con una `TarjetaResumen` del próximo servicio (qué toca, por qué y cuánto falta). Cuando toca por kilometraje la tarjeta trae una barra con el avance desde el último servicio hecho; el criterio de aceptación no cambia. «Agendar este servicio» y «Registrar km» van en `FilaAcciones`. La bitácora de combustible (V2-M18) sigue el mismo patrón.
