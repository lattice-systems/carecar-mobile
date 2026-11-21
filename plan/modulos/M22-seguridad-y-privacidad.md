# M22 · Seguridad y privacidad

| Campo | Valor |
| --- | --- |
| Hito | H2 (base) → H7 (MASVS) |
| Dueño | Daniel |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 20. Seguridad y privacidad |
| Estado | Listo para historias |

## Propósito

Datos del cliente protegidos y bajo su control, conforme a la LFPDPPP (derechos ARCO) y OWASP MASVS L1. Mueve O8.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `aviso_privacidad` ➕ | id, version, texto, vigente_desde | Versionado; nunca se edita uno publicado. |
| `aceptacion_aviso` ➕ | id, cuenta_app_id, aviso_privacidad_id, aceptado_en | Una por versión aceptada. |
| `solicitud_arco` ➕ | id, cliente_id, tipo (acceso/rectificacion/cancelacion/oposicion), estado, archivo_url, creada_en, resuelta_en | |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M22.01 | Como cliente quiero leer el aviso de privacidad real | Texto versionado del backend · aceptación registrada en primer ingreso y al cambiar de versión | ✅ | V2-M01.01 |
| V2-M22.02 | Como cliente quiero descargar mis datos (acceso ARCO) | Solicitud genera archivo con todos mis datos · aviso al estar listo | ✅ | V2-M01.06 |
| V2-M22.03 | Como cliente quiero pedir que borren mi cuenta (cancelación ARCO) | Flujo con confirmación · se desactiva `cuenta_app` y se anonimizan datos no obligatorios por ley; lo fiscal se conserva | ✅ | V2-M01.06 |
| V2-M22.04 | Como equipo queremos fijar certificados del servidor | Certificate pinning en release con plan de rotación | | V2-T04.02 |
| V2-M22.05 | Como equipo queremos detectar equipos comprometidos | Aviso (no bloqueo) en root/jailbreak; sin datos en caché si se detecta | | — |
| V2-M22.06 | Como equipo queremos ocultar datos en el selector de apps | Pantalla cubierta en segundo plano; capturas bloqueadas en pantallas de pago y documentos | | — |
| V2-M22.07 | Como equipo queremos logs sin datos personales | Lint/regla y prueba que falle si se registra correo, teléfono, VIN o token | | V2-T03.01 |
| V2-M22.08 | Como equipo queremos una revisión MASVS L1 | Checklist en `docs/seguridad/` con evidencia por control | | H6 |
| V2-M22.09 | Como equipo queremos HTTPS fuera de local | `API_BASE_URL` http solo en flavor de desarrollo | | V2-T04.01 |
