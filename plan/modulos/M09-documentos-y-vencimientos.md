# M09 · Documentos y vencimientos

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Haziel |
| Revisa | Jael |
| Ficha técnica | ✅ Sección 9. Documentos y vencimientos |
| Estado | Listo para historias |

## Propósito

La guantera digital: póliza de seguro, tarjeta de circulación, verificación, tenencia/refrendo, garantía, factura de compra; con alertas antes de que venzan. Mueve O6.

## Pantallas

- **Documentos del vehículo** — tarjetas por tipo con estado (vigente / por vencer / vencido / falta).
- **Agregar documento** — cámara con recorte automático, galería o PDF; fecha de vencimiento.
- **Visor** — imagen/PDF a pantalla completa, compartir.
- **Calendario de vencimientos** — todos los autos.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `documento_vehiculo` ➕ | id, vehiculo_cliente_id, tipo, archivo_url, vence_en, origen (cliente/agencia), creado_en | Almacenamiento cifrado. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET/POST | `/vehiculos/{id}/documentos` | |
| GET/PUT/DELETE | `/documentos/{id}` | |
| GET | `/documentos/{id}/archivo` | URL firmada de corta vida. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M09.01 | Como cliente quiero ver los documentos de mi auto con su estado | Tipos fijos + "otro" · estado calculado por fecha | ✅ | V2-M02.02 |
| V2-M09.02 | Como cliente quiero fotografiar un documento y guardarlo | Recorte de bordes · compresión · máx. tamaño · progreso | ✅ | V2-M09.01 |
| V2-M09.03 | Como cliente quiero ver los documentos que me dio la agencia | Factura de compra y póliza de garantía cargadas por la agencia aparecen solas | ✅ | V2-M09.01 |
| V2-M09.04 | Como cliente quiero alertas antes de que venza un documento | Push 30, 7 y 1 día antes · configurable | ✅ | V2-M06.02 |
| V2-M09.05 | Como cliente quiero ver mis documentos sin conexión | Copia local cifrada de los marcados como "disponible sin red" | | V2-M21.01 |
| V2-M09.06 | Como cliente quiero un calendario con todos mis vencimientos | Vista mensual y lista | | V2-M09.01 |
