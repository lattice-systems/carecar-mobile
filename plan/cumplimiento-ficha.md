# Matriz de cumplimiento de la ficha técnica v2.1

Cada funcionalidad de la [ficha](../docs/ficha-tecnica/README.md) tiene una fila. Una fila pasa a ✅ solo con **prueba automática enlazada** (app y backend) y demostrada en celular. Toda historia que avance una funcionalidad actualiza esta tabla en su PR.

Leyenda: ✅ cumple con prueba · 🟡 existe en v1, falta v2 o prueba · ❌ brecha contra lo que pide la ficha · ⬜ aún no existe (planeada).

Estado levantado contra `main` de `carecar-mobile` (PR #12) y `agencia-360-backend` (PR #57).

## Funcionalidades

### 1. Acceso y perfil — plan [M01](modulos/M01-acceso-y-perfil.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Inicio de sesión (cuenta entregada por la agencia, sin registro público) | `cliente`, `cuenta_app`, `sesion_app` | 🟡 | V2-M01.01, V2-M01.11 |
| Cambio obligatorio de la contraseña temporal | `cuenta_app` | 🟡 | V2-M01.03 |
| Recuperación de contraseña por enlace de un solo uso | `cuenta_app`, `token_recuperacion` | ❌ v1 usa código | V2-M01.04, V2-T05.04 |
| Desbloqueo con huella o rostro | `cuenta_app`, `sesion_app` | ⬜ | V2-M01.05 |
| Consulta del perfil | `cliente`, `cuenta_app`, `vehiculo_cliente` | 🟡 | V2-M01.06 |
| Edición de teléfono y correo con verificación | `cliente`, `cuenta_app`, `verificacion_contacto` | ❌ | V2-M01.07, V2-T05.03 |
| Sesiones y dispositivos activos | `sesion_app` | ⬜ | V2-M01.09, V2-M01.10 |
| Aviso de cuenta desactivada | `cuenta_app` | 🟡 | V2-M01.08 |

### 2. Mis vehículos y postventa — plan [M02](modulos/M02-vehiculos-y-postventa.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Mis vehículos (garaje) | `cliente`, `vehiculo_cliente` | 🟡 | V2-M02.01 |
| Detalle del vehículo y kilometraje | `vehiculo_cliente`, `orden_servicio` | 🟡 | V2-M02.02 |
| Manuales por modelo y año | `manual`, `vehiculo_cliente` | 🟡 app v2 abre, descarga y comparte; faltan búsqueda e índice en el PDF | V2-M02.03, V2-T05.05 |
| Ficha técnica del vehículo | `ficha_tecnica_modelo`, `vehiculo_cliente` | 🟡 app v2 y backend (tabla y endpoint, rama `feat/v2-juan-pablo-citas-b`); la tabla aún sin datos, la app usa su respaldo | V2-M02.04 |
| Historial de servicios | `orden_servicio`, `vehiculo_cliente` | 🟡 solo 1.ª página | V2-M02.05, V2-T05.06 |
| Ticket del servicio | `orden_servicio`, `orden_refaccion`, `refaccion` | 🟡 | V2-M02.06, V2-T05.06 |
| Disponibilidad del taller | `franja_horario`, `cita` | ❌ sin tabla (app lista contra la API v1) | V2-M02.07, V2-T05.07 |
| Agendar cita | `cita`, `franja_horario`, `vehiculo_cliente` | 🟡 app y backend (`cita.motivo`, `CITA_DUPLICADA`) listos; falta demostrar en celular | V2-M02.08 |
| Mis citas (próximas y pasadas) | `cita`, `franja_horario`, `vehiculo_cliente` | 🟡 app v2 lista con estados y paginación; falta demostrar en celular | V2-M02.09 |
| Cancelar y reprogramar cita | `cita`, `franja_horario` | 🟡 app y backend de cancelar y reprogramar listos; falta demostrar en celular | V2-M02.10, V2-M02.13 |
| Comprobante de cita con código QR | `cita`, `vehiculo_cliente` | 🟡 QR firmado en app y backend; falta agregar al calendario (V2-M02.12) | V2-M02.11, V2-M02.12 |

### 3. Catálogo y calculadora — plan [M03](modulos/M03-catalogo-y-calculadora.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Catálogo de modelos actuales | `modelo_catalogo`, `modelo_catalogo_imagen` | 🟡 app lista contra `mock_api`, falta construir las tablas en el backend | V2-M03.01, V2-M03.02 |
| Comparador de modelos | `modelo_catalogo` | ✅ hecho (reutiliza el detalle de V2-M03.02) | V2-M03.03 |
| Calculadora de toma a cuenta (estimación no vinculante) | `modelo_catalogo`, `vehiculo_cliente`, `parametro_toma_cuenta`, `estimacion_toma_cuenta` | 🟡 la calculadora (V2-M03.04) está lista contra `mock_api` y el diseño de las tablas y la fórmula está en el backend (backend#69), falta construirlo. Siguen M03.05 a M03.07 | V2-M03.04 a V2-M03.07 |

### 4. Taller en vivo — plan [M04](modulos/M04-taller-en-vivo.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Estado de la orden en tiempo real | `orden_servicio`, `etapa_orden` | ⬜ | Ver M04 |
| Inspección multipunto con fotos | `orden_servicio`, `punto_inspeccion`, `evidencia_orden` | ⬜ | Ver M04 |
| Aprobación de trabajos adicionales | `orden_servicio`, `trabajo_adicional` | ⬜ | Ver M04 |

### 5. Mantenimiento inteligente — plan [M05](modulos/M05-mantenimiento-inteligente.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Plan de mantenimiento y próximo servicio | `plan_mantenimiento`, `concepto_mantenimiento`, `orden_servicio`, `vehiculo_cliente` | ⬜ | Ver M05 |
| Registro de kilometraje del cliente | `lectura_km`, `vehiculo_cliente` | ⬜ | Ver M05 |

### 6. Notificaciones — plan [M06](modulos/M06-notificaciones.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Notificaciones push | `dispositivo_push`, `cuenta_app`, `notificacion` | ⬜ | Ver M06 |
| Bandeja de avisos | `notificacion` | ⬜ | Ver M06 |
| Preferencias de avisos | `preferencia_notificacion` | ⬜ | Ver M06 |

### 7. Mensajería con el asesor — plan [M07](modulos/M07-mensajeria-asesor.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Chat con el asesor | `conversacion`, `mensaje`, `orden_servicio`, `cita` | ⬜ | Ver M07 |

### 8. Pagos y facturas — plan [M08](modulos/M08-pagos-y-facturas.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Pago del servicio | `pago_app`, `orden_servicio`, `metodo_pago` | ⬜ | Ver M08 |
| Métodos de pago guardados | `metodo_pago` | ⬜ | Ver M08 |
| Datos fiscales y facturas | `perfil_fiscal`, `factura`, `pago_app` | ⬜ | Ver M08 |

### 9. Documentos y vencimientos — plan [M09](modulos/M09-documentos-y-vencimientos.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Documentos del vehículo | `documento_vehiculo`, `vehiculo_cliente` | ⬜ | Ver M09 |
| Alertas de vencimiento | `documento_vehiculo`, `notificacion` | ⬜ | Ver M09 |

### 10. Garantía y campañas de seguridad — plan [M10](modulos/M10-garantia-y-campanas.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Cobertura de garantía | `garantia`, `vehiculo_cliente` | ⬜ | Ver M10 |
| Campañas de seguridad (recalls) | `campana_seguridad`, `campana_vehiculo`, `vehiculo_cliente`, `cita` | ⬜ | Ver M10 |

### 11. Asistencia en camino — plan [M11](modulos/M11-asistencia-en-camino.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Solicitud de asistencia (SOS) | `solicitud_asistencia`, `vehiculo_cliente` | 🟡 solo guías sin conexión (V2-M11.03); falta la solicitud | V2-M11.01, V2-M11.02, V2-M11.03, V2-M11.04 |

### 12. Lealtad y recompensas — plan [M12](modulos/M12-lealtad.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Puntos y niveles | `movimiento_puntos` | ⬜ | Ver M12 |
| Canje de recompensas | `recompensa`, `canje`, `movimiento_puntos` | ⬜ | Ver M12 |
| Referidos | `referido`, `prospecto` | ⬜ | Ver M12 |

### 13. Promociones y novedades — plan [M13](modulos/M13-promociones.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Promociones personalizadas | `promocion`, `promocion_vista`, `cita` | ⬜ | Ver M13 |

### 14. Tienda de refacciones y accesorios — plan [M14](modulos/M14-tienda.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Catálogo compatible con mi vehículo | `refaccion`, `compatibilidad_refaccion` | ⬜ | Ver M14 |
| Pedidos y apartados | `pedido_app`, `pedido_app_renglon`, `refaccion`, `movimiento_inventario`, `cita` | ⬜ | Ver M14 |

### 15. Encuestas y NPS — plan [M15](modulos/M15-encuestas-nps.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Encuesta de satisfacción del servicio | `encuesta_servicio`, `orden_servicio` | ⬜ | Ver M15 |

### 16. Estreno — plan [M16](modulos/M16-estreno.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Prueba de manejo y cotización de auto nuevo | `solicitud_estreno`, `prospecto`, `modelo_catalogo`, `estimacion_toma_cuenta` | ⬜ | Ver M16 |

### 17. Recolección y entrega a domicilio — plan [M17](modulos/M17-recoleccion-y-entrega.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Recolección y entrega del vehículo | `direccion_cliente`, `traslado`, `checklist_traslado`, `cita` | ⬜ | V2-M17.01, V2-M17.02, V2-M17.03, V2-M17.04 |

### 18. Bitácora del conductor — plan [M18](modulos/M18-bitacora-conductor.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Registro de gastos y rendimiento | `gasto_vehiculo`, `lectura_km`, `vehiculo_cliente` | ⬜ | V2-M18.01, V2-M18.02, V2-M18.03, V2-M18.04, V2-M18.05, V2-M05.03 |

### 19. Cuentas familiares — plan [M19](modulos/M19-cuentas-familiares.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Compartir vehículo con permisos | `acceso_compartido`, `vehiculo_cliente`, `cuenta_app` | ⬜ | Ver M19 |

### 20. Seguridad y privacidad — plan [M22](modulos/M22-seguridad-y-privacidad.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Aviso de privacidad | `aviso_privacidad`, `aceptacion_aviso`, `cuenta_app` | ⬜ | Ver M22 |
| Derechos ARCO (descargar datos y borrar cuenta) | `solicitud_arco`, `cliente`, `cuenta_app` | ⬜ | Ver M22 |

### 21. Asistente CareCar (IA) — plan [M24](modulos/M24-asistente-carecar.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Preguntas sobre el manual del vehículo | `manual`, `fragmento_manual`, `consulta_asistente` | ⬜ | Ver M24 |
| Identificación de testigos del tablero | `consulta_asistente`, `vehiculo_cliente` | ⬜ | Ver M24 |

### 22. Valuación formal — plan [M26](modulos/M26-valuacion.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Valuación y oferta de toma a cuenta | `valuacion`, `estimacion_toma_cuenta`, `cita` | ⬜ | Ver M26 |

### 23. Ayuda y sucursales — plan [M27](modulos/M27-ayuda-y-sucursales.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Preguntas frecuentes | `pregunta_frecuente` | ⬜ | Ver M27 |
| Sucursales y horarios | `sucursal` | ⬜ | Ver M27 |
| Reporte de problemas de la app | `reporte_app` | ⬜ | Ver M27 |

Los módulos sin tablas propias (M20 Accesibilidad, M21 Sin conexión, M23 Analítica, M25 Widgets) no están en la ficha: son frentes transversales que se cumplen dentro de cada funcionalidad.

## Tablas que hoy existen con otro nombre o faltan (backend)

Prioridad máxima del backend: dejar estas tablas con los nombres y campos de la ficha mediante **migraciones nuevas**.

| Ficha | Hoy en el backend | Historia |
| --- | --- | --- |
| `cuenta_app.usuario` | No existe (se usa `cliente.correo`) | V2-T05.03 |
| `token_recuperacion` | `codigo_recuperacion` (código de 6 dígitos) | V2-T05.04 |
| `manual.archivo_pdf` | `manual.archivo` | V2-T05.05 |
| `orden_servicio`, `orden_refaccion` | `servicio`, `renglon_servicio` (sin `mano_de_obra`, `estatus`, `fecha_cierre`) | V2-T05.06 |
| `franja_horario` | No existe (`HorarioTaller` en código) | V2-T05.07 |

Tablas de la ficha que ya existen sin cambios: `cliente`, `vehiculo_cliente`, `cita`, `modelo_catalogo`, `sesion_app`, `refaccion`, `movimiento_inventario`, `factura`, `prospecto`. Todas las demás se crean con las historias de su módulo.
