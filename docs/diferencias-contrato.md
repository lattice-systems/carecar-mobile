# Diferencias entre el backend y el contrato

Comparación de `api/agencia360-api-app-v1.yaml` (v1.1) con lo que responde el
backend del worktree `backend-agencia360-wt-app` (rama `feat/app-servicios-citas`,
1573e69), probado con curl y con la app el 20/11/2026. El YAML **no se editó**.

| # | Endpoint | Contrato | Backend real | Impacto en la app |
|---|---|---|---|---|
| 1 | `POST /citas` (mismo vehículo, misma fecha y franja) | 409 con `codigo` del enum (`FRANJA_SIN_CUPO`) | 409 **sin `codigo`**, mensaje «Ese vehículo ya tiene una cita en ese horario» | La app muestra el `message`; no puede distinguir el caso por código. Proponer un código nuevo (p. ej. `CITA_DUPLICADA`) en el enum de `Problema` |
| 2 | `GET /vehiculos/{id}/servicios` | `estatus` libre (PO-5) | Siempre `TERMINADO` | Sin colores por estatus hasta que se cierre el conjunto |
| 3 | `Cita` | No trae nombre del vehículo | Tampoco (otro agente lo agrega en `wt-app2`) | La app lee `vehiculoNombre` (o `vehiculo.{modelo,anio}`) si llega; si no, pide `GET /vehiculos` |
| 4 | `POST /citas/{id}/cancelar` fuera de plazo | 409 `FUERA_DE_PLAZO` | Igual (24 h por propiedad, PO-4) | OK |
| 5 | Ruta inexistente | No documentado | 404 con `Problema` («No existe la ruta …») | OK |

Ya coinciden (no son diferencias): paginación `{contenido, pagina, tamano,
totalElementos, totalPaginas}` con `pagina`/`tamano`, `franjaId` en `Cita`,
`marca`/`version` en `Vehiculo` y `marca`/`titulo` en `Manual`, 400
`DATOS_INVALIDOS` cuando falta `desde`/`hasta` en la disponibilidad.
