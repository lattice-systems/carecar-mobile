# Equipo y reparto del trabajo

**Todos programan.** El rol Scrum no exime de historias: el Scrum Master y el Product Owner tienen su frente como cualquiera. Cada persona es **dueña de punta a punta** de sus módulos: app **y** backend (las historias **B**), docs y pruebas. Cada módulo tiene además un revisor fijo para que ningún módulo dependa de una sola persona (O10).

## Integrantes

| Persona | Rol Scrum | GitHub | Frentes (dueño) | Historias |
| --- | --- | --- | --- | --- |
| Daniel Ojeda Luna | Scrum Master | `DevOjeda016` | T01 Arquitectura · T04 Entrega continua · M16 Estreno · M22 Seguridad y privacidad · M24 Asistente IA | 36 |
| Haziel Orlando Gutierrez Hernandez | Product Owner | `UncrownedRex` | T03 Calidad y aceptación · M09 Documentos · M13 Promociones · M15 Encuestas · M23 Analítica · M27 Ayuda | 32 |
| Cristian Veuliah Mares Cerda | Desarrollo | `CristianMares` | T02 Sistema de diseño · M03 Catálogo y calculadora · M14 Tienda · M20 Accesibilidad · M26 Valuación | 37 |
| Ricardo Garnica Mejia | Desarrollo | `RichiGM` | T05 Contrato API y backend · M02 historial y tickets · M04 Taller en vivo · M08 Pagos · M10 Garantía · M12 Lealtad | 36 |
| Juan Pablo Rea Cano | Desarrollo | `PabloDev24` | M02 garaje, manuales y citas · M05 Mantenimiento · M11 SOS · M17 Recolección · M18 Bitácora · M25 Widgets y Wallet | 35 |
| Jael Neftali Vargas Grijalva | Desarrollo | `Jael-Vargas` | M01 Acceso y perfil · M06 Notificaciones · M07 Mensajería · M19 Familia · M21 Sin conexión | 33 |

El conteo sale de [`tablero.md`](tablero.md); si cambia el reparto, se actualizan las dos tablas en el mismo PR.

## Revisión cruzada

Revisor fijo por módulo en [`modulos/README.md`](modulos/README.md). Por ahora GitHub **no exige aprobación** para integrar; la revisión cruzada sigue siendo la práctica del equipo:

- El revisor revisa los PR del módulo; si no está, cualquier otra persona.
- Evita integrar tu propio PR sin que nadie lo haya visto, salvo cambios triviales de docs.
- Cada persona revisa al menos un PR de otro frente por cada PR propio que integra.

## Qué toca a cada quien en cada hito

| Hito | Daniel | Haziel | Cristian | Ricardo | Juan Pablo | Jael |
| --- | --- | --- | --- | --- | --- | --- |
| H0 | Reglas, agentes, plan | Revisa ficha y matriz | Revisa diseño v2 | Revisa plan backend | Revisa M02 | Revisa M01 |
| H1 | T01 esqueleto, rutas, flavors · T04 builds | T03 golden, integration_test, convenciones de prueba | T02 tokens y componentes | T05 contrato v2 + migraciones a la ficha | T02 componentes compuestos (calendario, línea de tiempo) | T01 núcleo API/sesión · M21 base local |
| H2 | M22 base de seguridad | M23 errores · aceptación de la matriz | M03 catálogo + **calculadora** · M20 base | M02 historial y tickets | M02 garaje, manuales y citas | M01 completo |
| H3 | M22 aviso y ARCO | M09 Documentos | M20 idiomas | M04 Taller en vivo · M10 Garantía | M05 Mantenimiento | M06 Notificaciones |
| H4 | M23/M24 preparación (ADR IA) | M13, M15, M27 | M12 (apoyo de diseño) | M12 Lealtad | M25 widgets (base) | M07 Mensajería |
| H5 | M16 Estreno | M23 embudos | M14 Tienda · M26 Valuación | M08 Pagos | M17 Recolección | M21 cola de escritura |
| H6 | M24 Asistente IA | M23 tablero de objetivos | M20 auditoría | Endurecer backend | M11, M18, M25 | M19 Familia |
| H7 | T04 tiendas · M22 MASVS | Aceptación final | Accesibilidad AA | Rendimiento API | Pruebas en celulares | Sin conexión completo |

## Nunca sin trabajo

Si tus historias están bloqueadas: (1) revisa PR pendientes, (2) toma la siguiente historia `Lista` de tu frente en el siguiente hito, (3) toma una historia `Lista` sin bloquear de otro frente avisando a su dueño, (4) pide al planificador refinar `Borrador` de tus módulos.
