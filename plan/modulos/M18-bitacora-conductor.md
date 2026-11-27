# M18 · Bitácora del conductor

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Juan Pablo |
| Revisa | Cristian |
| Ficha técnica | ✅ Sección 18. Bitácora del conductor |
| Estado | Listo para historias |

## Propósito

Que el cliente registre cargas de gasolina y gastos para conocer el rendimiento y el costo real de su auto; las lecturas alimentan la predicción de mantenimiento (M05). Mueve O4 y O6.

## Pantallas

- **Bitácora** — cargas y gastos por vehículo.
- **Nueva carga** — litros, precio, km, foto del ticket (lectura automática por OCR en el dispositivo).
- **Estadísticas** — km/l, costo por km, gasto mensual, comparación con el promedio del modelo.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `gasto_vehiculo` ➕ | id, vehiculo_cliente_id, tipo (gasolina/estacionamiento/casetas/lavado/otro), monto, litros, km, fecha, ticket_url | Cada km alimenta `lectura_km` (fuente cliente). |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET/POST | `/vehiculos/{id}/gastos` | Listar (paginado, por mes) y registrar gastos; una carga de gasolina también crea una `lectura_km` de fuente cliente. |
| PUT/DELETE | `/gastos/{id}` | Corregir o borrar un gasto propio. |

Las estadísticas (km/l, $/km, gasto por mes) se calculan en la app con los gastos.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M18.01 | Como cliente quiero registrar una carga de gasolina para llevar el control de lo que gasto | Litros y monto mayores a 0 · km entero no menor a la última lectura (`lectura_km`) · guarda el gasto y una lectura de km de fuente cliente · error claro por campo | ✅ | V2-M05.03 |
| V2-M18.02 | Como cliente quiero llenar la carga desde la foto del ticket para no teclear los datos | Lectura en el dispositivo (ML Kit), la foto no sale del teléfono · propone litros, monto y fecha y el cliente confirma o corrige · si no lee nada, el formulario queda vacío | | V2-M18.01 |
| V2-M18.03 | Como cliente quiero ver mi rendimiento y gasto para saber cuánto me cuesta mi auto | km/l entre cargas y $/km · gasto por mes en gráfica con tabla alternativa para lector de pantalla · con menos de 2 cargas explica por qué aún no hay datos | | V2-M18.01, V2-T02.10 |
| V2-M18.04 | Como cliente quiero registrar otros gastos para conocer el costo total de mi auto | Tipos estacionamiento, casetas, lavado y otro (con descripción) · monto mayor a 0 · aparecen en la bitácora junto a las cargas | ✅ | V2-M18.01 |
| V2-M18.05 | Como cliente quiero exportar mi bitácora para guardarla o compartirla | CSV y PDF por vehículo y rango de meses · se comparte con la hoja del sistema | | V2-M18.03 |

## Fuera de alcance / notas

- La comparación con el promedio del modelo necesita datos agregados de muchos clientes; queda fuera de esta versión.

## Avance de V2-M18.01 a V2-M18.05

Estado de la parte de app: **hecha, sin integrar con el backend real**. El código vive en `lib/modulos/bitacora/` (`dominio/`, `datos/`, `presentacion/`) y se abre desde el detalle del vehículo (`/vehiculos/:id/bitacora`, con sus subrutas de estadísticas, exportar y gasto).

- **V2-M18.01 (carga de gasolina):** `BorradorGasto` valida por campo (litros y monto mayores a 0, km entero no menor a la última lectura). `RepositorioBitacoraApi` usa los DTOs `Gasto` y `NuevoGasto` de `lib/api/modelos` y el cliente del núcleo; un 422 por km se distingue de un fallo de red (`KmInvalido`) y se muestra en el campo. La lectura de km de fuente cliente la crea el backend.
- **V2-M18.02 (ticket):** `LectorTicketMlKit` reconoce el texto en el dispositivo; la foto no se sube ni se guarda. `parser_ticket.dart` propone litros, monto y fecha; el cliente confirma o corrige, y si no lee nada el formulario queda vacío. Android incluye las dependencias nativas de los scripts opcionales de ML Kit requeridas por la compilación release con R8. Se agregó el permiso de cámara en `Info.plist` y `Info-desarrollo.plist`.
- **V2-M18.03 (rendimiento):** `estadisticas.dart` calcula km/l entre cargas (método del tanque lleno), $/km y gasto por mes en la app. Gráfica con tabla alternativa para lector de pantalla; con menos de 2 cargas explica por qué aún no hay datos.
- **V2-M18.04 (otros gastos):** estacionamiento, casetas, lavado y otro (con descripción), con monto mayor a 0; aparecen junto a las cargas, agrupados por mes. Se pueden editar y borrar.
- **V2-M18.05 (exportar):** CSV (con BOM) y PDF (fuente de la app) por vehículo y rango de meses, compartidos con la hoja del sistema.
- **Paginación:** la respuesta real trae además `tamano` y `totalElementos`; el cliente ignora lo que no usa.
- **Pruebas:** `test/modulos/bitacora/` cubre dominio, repositorio contra el contrato, las pantallas en sus cinco estados, la exportación y la ruta. El `mock_api` simula los gastos con la regla del km.
- **Pendiente:** la comparación con el promedio del modelo sigue fuera de alcance. Falta probar en celular con el backend real y capturas claro/oscuro; el tablero y `plan/cumplimiento-ficha.md` los actualiza quien integra.
