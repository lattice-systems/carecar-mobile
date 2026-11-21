# T01 · Arquitectura v2 de la app

| Campo | Valor |
| --- | --- |
| Hito | H1 |
| Dueño | Daniel |
| Revisa | Jael |
| Estado | Listo para historias |

Descripción del objetivo: [`../arquitectura-v2.md`](../arquitectura-v2.md). Decisiones: `docs/decisiones/0001`–`0005`.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-T01.01 | Como equipo queremos aceptar o reemplazar las decisiones 0001–0005 | Cada ADR pasa a `Aceptada` o se reemplaza, con aprobación de SM y PO en el PR | | — |
| V2-T01.02 | Como equipo queremos el esqueleto `lib/nucleo` + `lib/modulos` | Carpetas, inyección de dependencias, `ApiCliente` del núcleo reutilizando el cliente v1, una pantalla de ejemplo con pruebas · la app v1 sigue funcionando | | V2-T01.01 |
| V2-T01.03 | Como equipo queremos navegación declarativa con deep links | Rutas tipadas · `carecar://` y enlaces universales https · redirección por sesión (login, cambio obligatorio) · prueba por ruta | | V2-T01.02 |
| V2-T01.04 | Como equipo queremos flavors `desarrollo`, `pruebas` y `produccion` | Nombre, ícono, `API_BASE_URL` y permisos de red por flavor | | V2-T01.02 |
| V2-T01.05 | Como equipo queremos migrar módulo por módulo sin romper v1 | Guía en `arquitectura-v2.md` · interruptor por módulo (v1/v2) hasta cerrar H2 | | V2-T01.03 |
| V2-T01.06 | Como equipo queremos reglas de dependencia entre módulos verificadas | Prueba/lint que falle si `modulos/a` importa internals de `modulos/b` | | V2-T01.02 |
| V2-T01.07 | Como equipo queremos retirar el código v1 al terminar H2 | `lib/pantallas`, `lib/widgets`, `lib/tema` eliminados · sin referencias | | H2 |
