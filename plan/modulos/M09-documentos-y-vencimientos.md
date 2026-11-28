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

## Privacidad de pantalla

Las pantallas con documentos y su visor se envuelven con `PantallaSegura` (`lib/nucleo/privacidad/`, V2-M22.06) para bloquear capturas en Android; ver [`docs/seguridad/ocultar-en-selector.md`](../../docs/seguridad/ocultar-en-selector.md). Su prueba usa `ProteccionDeCapturaFake`.

## Avance de V2-M09.01

> **Le tocaba a Haziel, la hizo Juan Pablo (R6, ayuda).** La tomó porque V2-M11.02 (llamar a la aseguradora) dependía de ella. Haziel sigue siendo dueño del módulo y de V2-M09.02 a V2-M09.06.

Ver los documentos de cada auto con su estado de vencimiento. Backend y app.

**Backend** (`agencia-360-backend`, diseño en `plan/historias-backend.md`, «Diseño técnico — V2-M09.01»)

- Migración `V61__crear_documento_vehiculo.sql`: tabla `documento_vehiculo` con los campos de la ficha (`id`, `vehiculo_cliente_id`, `tipo`, `archivo_url`, `vence_en`, `origen`, `creado_en`) más `titulo`, `numero`, `emitido_en`, `aseguradora` y `telefono_aseguradora` (R1 permite agregar). `archivo_url` es opcional hasta V2-M09.02.
- `GET /api/v1/app/vehiculos/{id}/documentos`: el estado (`VIGENTE`, `POR_VENCER` de 0 a 30 días, `VENCIDO`, `SIN_FECHA`) y `diasRestantes` se calculan con la fecha de la agencia (`America/Mexico_City`), no la del teléfono; orden por vencimiento con los que no tienen fecha al final; 404 para un auto ajeno igual que uno que no existe; 401 sin sesión. No expone la dirección del archivo (`tieneArchivo` solo dice si hay).
- Contrato v2 (etiqueta `Documentos`, esquema `Documento`), script de sembrado para una base ya cargada y datos de ejemplo de Diego en `docs/datos-de-ejemplo.md`.

**App** (`lib/modulos/documentos/`)

- Dominio `DocumentoVehiculo` con `TipoDocumento` y `EstadoDocumento`; `polizaParaLlamar(...)` elige la póliza no vencida con aseguradora y teléfono: prefiere una vigente a una por vencer y, entre iguales, la que vence más tarde.
- `RepositorioDocumentosApi` con `ApiCliente` y `RepositorioDocumentosFake`; `documentosProvider(vehiculoId)`.
- Pantalla `PantallaDocumentos` en `/documentos/:vehiculoId` (exige sesión y va dentro de `PantallaSegura`, sin capturas en Android): portada con el resumen de lo que necesita atención, grupos por estado de lo más urgente a lo menos, insignia de estado, fecha y días, número y aseguradora de la póliza; cinco estados (cargando, datos, vacío, error con reintento y sin conexión). Solo componentes y tokens de `lib/nucleo/diseno/`.
- Acceso «Documentos» en el grupo «Tu auto» del detalle del vehículo.
- `mock_api/modulos/documentos.js` con la misma regla de estado y orden; la semilla usa `venceEnDias` para que siempre haya un documento de cada estado.

**Pruebas:** `dominio_documentos_test.dart`, `repositorio_documentos_test.dart`, `ruta_documentos_test.dart` (ruta, sesión y bloqueo de capturas), `pantalla_documentos_test.dart` (estados, orden, claro y oscuro, letra al 200 % en 320×568 sin desbordes también con textos largos, pantalla ancha, nada atraviesa el título al desplazar, un nodo por documento para el lector de pantalla, inglés) y `test/accesibilidad/rutas/documentos_test.dart`. En el backend, `DocumentosAppIntegrationTest`, `DocumentosAppServiceTest` y `DocumentoVehiculoTest` (estado por fecha).

**Decisiones**

- El estado lo calcula el servidor y la app no lo recalcula: así el teléfono con la hora mal puesta no cambia lo que se ve.
- La aseguradora de V2-M11.02 sale de la póliza (no de una tabla aparte), porque la ficha no define otra y la póliza ya trae la aseguradora.

**No probado:** en el celular. Subir o fotografiar un documento es V2-M09.02.

### V2-M09.06 · Calendario de todos los vehículos

Desde Documentos se puede abrir el calendario de todo el garaje. Cada marca anuncia cuántos vencimientos hay y la lista permite abrir los documentos del vehículo. Usa el listado existente de V2-M09.01 y conserva la protección de pantalla.

La [prueba de calendario](../../test/modulos/documentos/calendario_documentos_test.dart) verifica dos vehículos, cambio de mes, filtro por día y recuperación ante errores.
