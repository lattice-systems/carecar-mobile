# M21 · Sin conexión y sincronización

| Campo | Valor |
| --- | --- |
| Hito | H2 (lectura) → H7 (escritura en cola) |
| Dueño | Jael |
| Revisa | Juan Pablo |
| Ficha técnica | No (frente transversal; se cumple dentro de las funcionalidades de la ficha) |
| Estado | Listo para historias |

## Propósito

La app sirve en el sótano del taller: lee lo último guardado y encola lo que el cliente hace sin red. Mueve O3 y O8. (v1 ya tiene caché en disco; v2 lo formaliza.)

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M21.01 | Como equipo queremos una base local para los datos del cliente | Base local cifrada (decisión en ADR) · se borra al cerrar sesión · migraciones versionadas | | V2-T01.02 |
| V2-M21.02 | Como cliente sin red quiero ver vehículos, historial, citas y documentos | Lectura de la base local con sello "actualizado hace X" | | V2-M21.01 |
| V2-M21.03 | Como cliente sin red quiero que mis acciones se envíen al volver la conexión | Cola de operaciones idempotentes (clave de idempotencia) · reintentos con espera exponencial · estado visible | ✅ | V2-M21.01 |
| V2-M21.04 | Como cliente quiero saber si estoy sin conexión | Aviso discreto global · acciones no disponibles deshabilitadas con explicación | | V2-T02.05 |
| V2-M21.05 | Como equipo queremos resolver conflictos de forma predecible | Servidor gana en datos del taller; cliente gana en preferencias; documentado | ✅ | V2-M21.03 |
| V2-M21.06 | Como cliente quiero que la app sincronice en segundo plano | Actualización periódica respetando batería y datos | | V2-M21.02 |
