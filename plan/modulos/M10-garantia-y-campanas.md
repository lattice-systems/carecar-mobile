# M10 · Garantía y campañas de seguridad

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Ricardo |
| Revisa | Haziel |
| Ficha técnica | ✅ Sección 10. Garantía y campañas de seguridad |
| Estado | En curso (V2-M10.01 a V2-M10.05) |

## Propósito

Mostrar la cobertura de garantía de cada auto y avisar de campañas de seguridad (recalls) por VIN para atenderlas en la agencia. Mueve O4 y O6.

## Pantallas

- **Garantía** — cobertura por componente con km/fecha límite y barra de consumo.
- **Campañas** — campañas abiertas para el VIN, gravedad, qué hacer, botón Agendar.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `garantia` ➕ | id, vehiculo_cliente_id, componente, descripcion, inicia_en, vence_en, km_limite, aviso_60_dias_en, aviso_15_dias_en, aviso_km_en | Los `aviso_*_en` guardan cuándo se mandó cada aviso de V2-M10.05 para no repetirlo. |
| `campana_seguridad` ➕ | id, codigo, titulo, descripcion, que_hacer, gravedad (BAJA/MEDIA/ALTA/CRITICA), modelo, anio_desde, anio_hasta, vin_desde, vin_hasta, publicada_en | El rango de VIN es opcional (los dos o ninguno). |
| `campana_vehiculo` ➕ | id, campana_seguridad_id, vehiculo_cliente_id, cita_id, estado (abierta/agendada/atendida), avisada_en | Una por campaña y vehículo; agendada exige `cita_id`. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/vehiculos/{id}/garantia` | Coberturas contra el km actual (V2-M10.01). |
| GET | `/vehiculos/{id}/campanas` | Campañas del vehículo con su estado (V2-M10.02). |
| POST | `/vehiculos/{id}/campanas/{campanaId}/cita` | Agenda la atención con motivo `campana` (V2-M10.03). |
| GET | `/eventos` | Avisos en vivo `campana.nueva` (V2-M10.04) y `garantia.por_vencer` (V2-M10.05). |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M10.01 | Como cliente quiero ver qué cubre mi garantía y hasta cuándo | Por componente con fecha y km límite contra km actual | ✅ | V2-M02.02 |
| V2-M10.02 | Como cliente quiero saber si mi auto tiene una campaña de seguridad | Cruce por modelo/año/rango de VIN · badge en Garaje | ✅ | V2-M02.01 |
| V2-M10.03 | Como cliente quiero agendar la atención de una campaña | Agendar con motivo "Campaña <código>" · estado pasa a agendada | ✅ | V2-M10.02, V2-M02.08 |
| V2-M10.04 | Como cliente quiero un aviso cuando salga una campaña para mi auto | Push con gravedad · no silenciable si es crítica | ✅ | V2-M06.02 |
| V2-M10.05 | Como cliente quiero saber que mi garantía está por vencer | Aviso 60 y 15 días antes / 1 000 km antes | ✅ | V2-M06.02 |

## Avance de V2-M10.01 a V2-M10.05

El módulo vive en `lib/modulos/garantia/` (`dominio/`, `datos/`, `presentacion/`) y su contrato público es `garantia.dart`. Es nuevo en v2: sus rutas se registran en `registro_de_rutas.dart` sin interruptor v1/v2. Las cuatro pantallas abren con `MarcoPantalla` (con `MarcoPantalla.estado` para cargando, vacío y error) y el cierre de agendar es un `ResultadoPantalla`. El diseño técnico del backend está en `agencia-360-backend/plan/historias-backend.md` (contrato 2.18.0).

- **Garantía (V2-M10.01):** `PantallaGarantia` en `/garantia/{vehiculoId}`, con el km actual como subtítulo. Cada cobertura es una `TarjetaResumen`: componente, «Vence el {fecha}» o «Vence el {fecha} o a los {km} km», descripción, insignia de estado (vigente, por vencer o vencida), barra de lo usado y lo que le queda por el límite que llega primero («Quedan N días» o «Quedan N km»); vencida dice si fue por fecha o por kilometraje. El lector la oye como un solo nodo con el porcentaje usado. El estado y el consumo los calcula el servidor (por vencer a 60 días o a 1 000 km del límite); la app no los recalcula. Abajo, el acceso a las campañas.
- **Campañas (V2-M10.02):** `PantallaCampanas` en `/garantia/{vehiculoId}/campanas`: una `TarjetaResumen` por campaña (título, código, gravedad y estado) que abre su detalle; una crítica pendiente se avisa arriba. `PantallaCampana` en `/garantia/{vehiculoId}/campanas/{campanaId}`: resumen, «Qué pasa», «Qué hacer» y la acción según el estado (agendar si está pendiente, ver las citas si ya tiene cita; atendida no tiene acción). El cruce por modelo, año y rango de VIN lo hace el backend. `InsigniaCampanas(vehiculoId)` es la insignia del garaje («Campaña de seguridad»); se monta en el garaje y el detalle del vehículo suma los accesos en un PR aparte del módulo `vehiculos`.
- **Agendar (V2-M10.03):** `PantallaAgendarCampana` en `/garantia/{vehiculoId}/campanas/{campanaId}/agendar`. Secciones «Día» (`Calendario` con los días con cupo) y «Horario» (`SelectorFranja`) con la disponibilidad del taller del módulo `citas` (`disponibilidadProvider`), y «Agendar» en la `BarraInferior`; la cita nace con motivo `campana` y la campaña queda agendada. Los 409 `CAMPANA_NO_AGENDABLE`, `FRANJA_SIN_CUPO` y `CITA_DUPLICADA` se explican sin perder lo elegido (`AgendaCampanaRechazada`); `CAMPANA_NO_AGENDABLE` se agregó a `CodigoProblema`. Al terminar, `ResultadoPantalla` con día y hora lleva al comprobante con QR de la cita. Una cita cancelada reabre la campaña.
- **En vivo (V2-M10.04 y V2-M10.05):** las campañas (lista y detalle) se vuelven a pedir con `campana.nueva` y la garantía con `garantia.por_vencer` del mismo vehículo (y al volver la conexión), sin pasar por carga; si la recarga falla se queda lo que se ve. El push con la app cerrada (no silenciable si `critica`) es de V2-M06.07.
- **Cinco estados:** cargando (esqueleto), datos, vacío, error con reintento y sin conexión, en las cuatro pantallas; el detalle dice también si la campaña ya no aparece.
- **Pruebas:** `test/modulos/garantia/` (repositorio API y fake, pantallas, en vivo, insignia y rutas) y `test/contrato/contrato_garantia_test.dart`. Cada pantalla se prueba en claro, oscuro y letra al 200 %.
- **Textos:** claves `garantia*` y `campanas*` en `app_es.arb` y `app_en.arb`.
- **Simulador:** `mock_api/modulos/garantia.js` con semillas en `semillas/garantia.json` y emisores `/__mock/campanas`, `/__mock/campanas/{id}/vehiculos/{id}/atendida` y `/__mock/garantias/{id}/aviso`.
