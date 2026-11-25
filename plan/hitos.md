# Hitos de CareCar v2

Sin fechas. Un hito se cierra cuando **todos** sus criterios de salida se cumplen y están demostrados en un celular físico contra el backend real. El hito activo se marca con ▶.

Los hitos ordenan prioridades, no bloquean a nadie: si una persona no tiene historias `Lista` en el hito activo, toma las del siguiente. **Nadie se queda sin trabajo.**

| Hito | Nombre | Módulos | Objetivos |
| --- | --- | --- | --- |
| H0 | Base de trabajo | Reglas, agentes, plan | O10 |
| ▶ H1 | Cimientos v2 | T01, T02, T03, T04, T05 | O8, O9 |
| H2 | Núcleo de la ficha (secciones 1–3) | M01, M02, M03 + base de M20, M21, M22, M23 | O1, O2 |
| H3 | Postventa viva | M04, M05, M06, M09, M10 | O3, O4, O6 |
| H4 | Cliente conectado | M07, M12, M13, M15, M27 | O4, O7 |
| H5 | Comercio | M08, M14, M16, M17, M26 | O5 |
| H6 | Inteligencia y extras | M11, M18, M19, M24, M25 | O4, O6 |
| H7 | Lista para entregar | Endurecimiento de todos + M20, M21, M22, M23 completos | O8, O9 |

---

## H0 · Base de trabajo

**Propósito:** que cualquiera (persona o agente) clone y sepa trabajar.

Criterios de salida:
- [x] `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` y `.claude/agents/` integrados en `carecar-mobile` y `agencia-360-backend`.
- [x] Ficha técnica versionada en `docs/ficha-tecnica/` y matriz de cumplimiento creada.
- [x] Plan maestro (`plan/`) con módulos, historias, reparto y tablero.
- [x] Workflow `Autoría` corriendo y agregado como check requerido de `main` en ambos repos.
- [ ] Las 6 personas corrieron `git config core.hooksPath .githooks`.

## H1 · Cimientos v2

**Propósito:** construir la base nueva sobre la que se rehace todo.

Criterios de salida:
- [x] Decisiones 0001–0005 en estado `Aceptada` (o reemplazadas con otra decisión aceptada).
- [ ] Estructura `lib/nucleo/` + `lib/modulos/` creada, con navegación declarativa y deep links funcionando.
- [ ] Sistema de diseño v2: tokens (claro/oscuro), tipografía, 100 % de los componentes base del catálogo con prueba golden y galería navegable en la app (modo desarrollo).
- [ ] `integration_test` del flujo login → inicio corriendo en CI.
- [ ] Distribución interna automática de cada `main` (APK firmado de prueba) para el equipo.
- [ ] Contrato `agencia360-api-app-v2.yaml` iniciado, compatible con v1, copiado en `api/`.

## H2 · Núcleo de la ficha (secciones 1–3)

**Propósito:** las secciones 1–3 de la ficha (acceso, vehículos y postventa, catálogo y calculadora) funcionan en la v2 con el diseño nuevo, mejor que v1. Las demás secciones se cierran en H3–H6.

Criterios de salida:
- [ ] Filas de las secciones 1–3 en `plan/cumplimiento-ficha.md` en ✅ con prueba enlazada.
- [ ] Calculadora de toma a cuenta (brecha de v1) funcionando.
- [ ] M01, M02, M03 reconstruidos en la estructura v2; pantallas v1 retiradas.
- [ ] Sin conexión: lectura de vehículos, historial y citas guardadas.
- [ ] Accesibilidad: lector de pantalla y letra al 200 % en todas las pantallas de la ficha.
- [ ] Crashes y errores reportados a la herramienta de observabilidad.

## H3 · Postventa viva

**Propósito:** el auto en el taller deja de ser una caja negra; la app avisa antes de que falle algo.

Criterios de salida:
- [ ] Orden de servicio con línea de tiempo en vivo y aprobación de trabajos adicionales desde la app.
- [ ] Plan de mantenimiento por modelo con próximo servicio estimado y recordatorio.
- [ ] Notificaciones push (FCM) con bandeja dentro de la app y preferencias.
- [ ] Documentos del vehículo con vencimientos y alertas.
- [ ] Campañas de seguridad (recalls) por VIN visibles y agendables.

## H4 · Cliente conectado

**Propósito:** conversación de dos vías entre cliente y agencia.

Criterios de salida:
- [ ] Chat con el asesor de servicio ligado a la orden.
- [ ] Encuesta NPS al cerrar cada servicio.
- [ ] Programa de lealtad con puntos y canje.
- [ ] Promociones segmentadas por modelo y kilometraje.
- [ ] Centro de ayuda con preguntas frecuentes, sucursales y contacto.

## H5 · Comercio

**Propósito:** la app genera ingreso.

Criterios de salida:
- [ ] Pago del servicio en la app y descarga de factura (PDF/XML).
- [ ] Tienda de refacciones y accesorios con apartado y recogida en el taller.
- [ ] Solicitud de prueba de manejo y cotización de auto nuevo (lead al backend).
- [ ] Recolección y entrega a domicilio solicitada al agendar.
- [ ] Valuación avanzada para toma a cuenta.

## H6 · Inteligencia y extras

**Propósito:** que la app se sienta del futuro.

Criterios de salida:
- [ ] Asistente CareCar responde preguntas con base en el manual del modelo del cliente, citando la página.
- [ ] Identificación de testigos del tablero por foto con recomendación y atajo a cita.
- [ ] Bitácora del conductor (gasolina, gastos, rendimiento).
- [ ] Cuentas familiares y conductores autorizados.
- [ ] Asistencia en camino (SOS) con ubicación.
- [ ] Widgets de inicio y pase de cita en Google Wallet / Apple Wallet.

## H7 · Lista para entregar

**Propósito:** entregar la app con calidad de producto comercial. **Decisión (Daniel):** no se publica en Google Play ni en App Store; Android se instala con el APK firmado de los Release y el iPhone con el IPA sin firmar y Sideloadly (firma de 7 días con Apple ID gratis).

Criterios de salida:
- [ ] `plan/cumplimiento-ficha.md` completa: las 58 funcionalidades de la ficha v2.1 en ✅ con prueba enlazada.
- [ ] Auditoría WCAG 2.2 AA sin hallazgos críticos; app en español e inglés.
- [ ] Revisión OWASP MASVS L1 aprobada; derechos ARCO funcionando (exportar y borrar cuenta).
- [ ] Métricas de producto (O1–O10) en un tablero de analítica.
- [ ] Presupuestos de rendimiento cumplidos (arranque, memoria, tamaño de instalación).
- [ ] APK firmado con la llave de producción en un Release `vX.Y.Z`, IPA sin firmar adjunto y guía de instalación vigente; política de privacidad dentro de la app.
