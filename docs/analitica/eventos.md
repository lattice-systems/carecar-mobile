# Eventos de producto de CareCar

La analítica se habilita desde Ajustes. Empieza apagada y se guarda en este dispositivo. Los eventos se mandan a la API de Agencia360 cuando hay una cuenta autenticada y la opción sigue activa. Se descartan si falla el envío. No se guardan en una cola local ni se envían al volver a activar el interruptor.

| Evento | Momento | Propiedades | Objetivo |
| --- | --- | --- | --- |
| `DISPONIBILIDAD` | La agenda muestra los días disponibles, incluido el estado sin cupo | `intento`, UUID aleatorio por recorrido | O2 · Inicios del embudo |
| `FRANJA` | El cliente elige una franja en Agendar | `intento` | O2 · Selección de horario |
| `CONFIRMADA` | La API confirma la reserva | `intento`, `citaId` | O2 · Reservas confirmadas |
| `ATENDIDA` | Una cita confirmada del embudo llega a `ATENDIDA` o tiene una orden cerrada vinculada | Derivado por el backend a partir de la cita. Cuenta una vez por cita | O2 · Llegadas a taller |
| `ERROR_FLUTTER` | Flutter entrega un error a su manejador global | Ninguna | O8 · Frecuencia de errores de Flutter |
| `ERROR_ASINCRONO` | El aislado principal reporta un error asíncrono sin manejar | Ninguna | O8 · Frecuencia de errores asíncronos |
| `RENDIMIENTO` | Termina la muestra inicial de cuadros con la app visible | `arranqueMs`, `primeraPantallaMs`, `cuadrosMedidos`, `cuadrosPerdidos` | O8 · Arranque e interacción |

El intento relaciona los pasos de una sola reserva y se descarta al salir del flujo. La API valida que una cita confirmada pertenezca a la cuenta autenticada. El ID de cita sirve para consultar la asistencia del embudo dentro de Agencia360. El panel muestra agregados y no incluye IDs, correos, VIN, textos libres, ubicaciones, mensajes de error ni trazas. Apagar la analítica detiene los envíos del dispositivo y descarta el intento en curso. Las métricas ya registradas se conservan.

Los indicadores O1, O3–O7, O9 y O10 usan sus fuentes operativas o de revisión en el [tablero de objetivos](tablero.md). Registra futuros eventos aquí antes de instrumentarlos e indica qué decisión permite tomar cada propiedad.
