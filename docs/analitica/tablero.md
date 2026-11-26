# Tablero de objetivos de CareCar

El plan [O1–O10](../../plan/proposito.md#objetivos-de-producto-sin-fechas) define los indicadores y su alcance.

El backend sirve el panel HTML en `GET /api/v1/analitica/objetivos`. Se consulta con un token del personal de administración o gerencia de marketing. El panel cubre los últimos 30 días y muestra como pendientes las fuentes aún ausentes.

```bash
curl --fail -H "Authorization: Bearer $TOKEN_PERSONAL" \
  "$BASE_BACKEND/api/v1/analitica/objetivos" -o objetivos-carecar.html
```

| Objetivo | Fuente de evidencia |
| --- | --- |
| O1 | Matriz de cumplimiento con prueba automática y verificación física |
| O2 | Embudo de citas de producto y total de citas por canal cuando se pueda identificar su origen |
| O3 | Órdenes abiertas con estado en vivo y llamadas sobre el estado del vehículo |
| O4 | Retorno al siguiente mantenimiento recomendado |
| O5 | Solicitudes de estreno, pagos y pedidos originados en CareCar |
| O6 | Expediente documental y preferencias de aviso |
| O7 | Encuestas y respuestas de la agencia |
| O8 | CI, cobertura, errores de Flutter y Dart, cierres por fallo de Android y métricas de arranque y cuadros |
| O9 | Auditoría de accesibilidad y comprobación de idiomas |
| O10 | PR integrados por hito y participantes |

El embudo cuenta intentos de reserva para la disponibilidad y la selección. Cuenta citas distintas para confirmación y asistencia. El indicador por canal queda pendiente porque la base actual no registra un total comparable de citas fuera de CareCar. El panel muestra los errores recibidos y las muestras de rendimiento por separado.
