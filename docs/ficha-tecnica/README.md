# Ficha técnica CareCar v2.0 — contrato obligatorio

> **Regla de oro:** todo lo que está en esta ficha se cumple **sí o sí**. Cada funcionalidad existe en la app y cada tabla listada existe en la base de datos de Agencia360. Se pueden agregar campos; nunca quitar, renombrar ni contradecir lo que la ficha define.

- Original: [`ficha-tecnica-carecar-v2.0.docx`](ficha-tecnica-carecar-v2.0.docx) (fuente de verdad; este archivo es su transcripción fiel). Reemplaza a la v1.1, que queda descartada (consultable en el historial de git).
- Cualquier cambio a la ficha lo aprueba el Product Owner y sube la versión del `.docx` y de esta transcripción en el mismo PR.
- Matriz de cumplimiento: [`../../plan/cumplimiento-ficha.md`](../../plan/cumplimiento-ficha.md).

## Portada

| Dato | Valor |
| --- | --- |
| Proyecto | CareCar (ecosistema Agencia360) |
| Producto | Aplicación móvil de servicio postventa para clientes de la agencia automotriz |
| Versión del documento | 2.0 (reemplaza a la v1.1) |
| Fecha | 21 de noviembre de 2026 |
| Plataformas | Android e iOS |
| Tecnología de la app | Flutter (Dart) |
| Backend | API REST de Agencia360: Java 25, Spring Boot 3.5, Spring Modulith, PostgreSQL, Redis |
| Acceso | Exclusivo: la agencia crea la cuenta del cliente al entregar la unidad; no hay registro público |
| Metodología | Scrumban + XP |
| Repositorios | lattice-systems/carecar-mobile · lattice-systems/agencia-360-backend |

## Descripción

CareCar es la aplicación móvil de servicio postventa de la agencia automotriz. Está dirigida a los clientes que ya recibieron su vehículo: consultan sus unidades, manuales e historial de servicios, agendan citas en el taller, siguen su servicio en vivo, pagan, guardan sus documentos y conocen el catálogo de modelos actuales. La app obtiene toda su información de los servicios de Agencia360; las tablas viven en su base de datos y se consultan a través de su API.

## Integrantes

| Nombre | Rol |
| --- | --- |
| Daniel Ojeda Luna | Scrum Master |
| Haziel Orlando Gutierrez Hernandez | Product Owner |
| Cristian Veuliah Mares Cerda | Equipo de desarrollo |
| Ricardo Garnica Mejia | Equipo de desarrollo |
| Juan Pablo Rea Cano | Equipo de desarrollo |
| Jael Neftali Vargas Grijalva | Equipo de desarrollo |

## Funcionalidades y tablas

Cada funcionalidad de la app y las tablas de la base de datos de Agencia360 que participan en ella.

### 1. Acceso y perfil

| Funcionalidad | Tablas que participan |
| --- | --- |
| Inicio de sesión (cuenta entregada por la agencia, sin registro público) | `cliente`, `cuenta_app`, `sesion_app` |
| Cambio obligatorio de la contraseña temporal | `cuenta_app` |
| Recuperación de contraseña por enlace de un solo uso | `cuenta_app`, `token_recuperacion` |
| Desbloqueo con huella o rostro | `cuenta_app`, `sesion_app` |
| Consulta del perfil | `cliente`, `cuenta_app`, `vehiculo_cliente` |
| Edición de teléfono y correo con verificación | `cliente`, `cuenta_app`, `verificacion_contacto` |
| Sesiones y dispositivos activos | `sesion_app` |
| Aviso de cuenta desactivada | `cuenta_app` |

### 2. Mis vehículos y postventa

| Funcionalidad | Tablas que participan |
| --- | --- |
| Mis vehículos (garaje) | `cliente`, `vehiculo_cliente` |
| Detalle del vehículo y kilometraje | `vehiculo_cliente`, `orden_servicio` |
| Manuales por modelo y año | `manual`, `vehiculo_cliente` |
| Ficha técnica del vehículo | `ficha_tecnica_modelo`, `vehiculo_cliente` |
| Historial de servicios | `orden_servicio`, `vehiculo_cliente` |
| Ticket del servicio | `orden_servicio`, `orden_refaccion`, `refaccion` |
| Disponibilidad del taller | `franja_horario`, `cita` |
| Agendar cita | `cita`, `franja_horario`, `vehiculo_cliente` |
| Mis citas (próximas y pasadas) | `cita`, `franja_horario`, `vehiculo_cliente` |
| Cancelar y reprogramar cita | `cita`, `franja_horario` |
| Comprobante de cita con código QR | `cita`, `vehiculo_cliente` |

### 3. Catálogo y calculadora

| Funcionalidad | Tablas que participan |
| --- | --- |
| Catálogo de modelos actuales | `modelo_catalogo`, `modelo_catalogo_imagen` |
| Comparador de modelos | `modelo_catalogo` |
| Calculadora de toma a cuenta (estimación no vinculante) | `modelo_catalogo`, `vehiculo_cliente`, `parametro_toma_cuenta`, `estimacion_toma_cuenta` |

### 4. Taller en vivo

| Funcionalidad | Tablas que participan |
| --- | --- |
| Estado de la orden en tiempo real | `orden_servicio`, `etapa_orden` |
| Inspección multipunto con fotos | `orden_servicio`, `punto_inspeccion`, `evidencia_orden` |
| Aprobación de trabajos adicionales | `orden_servicio`, `trabajo_adicional` |

### 5. Mantenimiento inteligente

| Funcionalidad | Tablas que participan |
| --- | --- |
| Plan de mantenimiento y próximo servicio | `plan_mantenimiento`, `concepto_mantenimiento`, `orden_servicio`, `vehiculo_cliente` |
| Registro de kilometraje del cliente | `lectura_km`, `vehiculo_cliente` |

### 6. Notificaciones

| Funcionalidad | Tablas que participan |
| --- | --- |
| Notificaciones push | `dispositivo_push`, `cuenta_app`, `notificacion` |
| Bandeja de avisos | `notificacion` |
| Preferencias de avisos | `preferencia_notificacion` |

### 7. Mensajería con el asesor

| Funcionalidad | Tablas que participan |
| --- | --- |
| Chat con el asesor | `conversacion`, `mensaje`, `orden_servicio`, `cita` |

### 8. Pagos y facturas

| Funcionalidad | Tablas que participan |
| --- | --- |
| Pago del servicio | `pago_app`, `orden_servicio`, `metodo_pago` |
| Métodos de pago guardados | `metodo_pago` |
| Datos fiscales y facturas | `perfil_fiscal`, `factura`, `pago_app` |

### 9. Documentos y vencimientos

| Funcionalidad | Tablas que participan |
| --- | --- |
| Documentos del vehículo | `documento_vehiculo`, `vehiculo_cliente` |
| Alertas de vencimiento | `documento_vehiculo`, `notificacion` |

### 10. Garantía y campañas de seguridad

| Funcionalidad | Tablas que participan |
| --- | --- |
| Cobertura de garantía | `garantia`, `vehiculo_cliente` |
| Campañas de seguridad (recalls) | `campana_seguridad`, `campana_vehiculo`, `vehiculo_cliente`, `cita` |

### 11. Asistencia en camino

| Funcionalidad | Tablas que participan |
| --- | --- |
| Solicitud de asistencia (SOS) | `solicitud_asistencia`, `vehiculo_cliente` |

### 12. Lealtad y recompensas

| Funcionalidad | Tablas que participan |
| --- | --- |
| Puntos y niveles | `movimiento_puntos` |
| Canje de recompensas | `recompensa`, `canje`, `movimiento_puntos` |
| Referidos | `referido`, `prospecto` |

### 13. Promociones y novedades

| Funcionalidad | Tablas que participan |
| --- | --- |
| Promociones personalizadas | `promocion`, `promocion_vista`, `cita` |

### 14. Tienda de refacciones y accesorios

| Funcionalidad | Tablas que participan |
| --- | --- |
| Catálogo compatible con mi vehículo | `refaccion`, `compatibilidad_refaccion` |
| Pedidos y apartados | `pedido_app`, `pedido_app_renglon`, `refaccion`, `movimiento_inventario`, `cita` |

### 15. Encuestas y NPS

| Funcionalidad | Tablas que participan |
| --- | --- |
| Encuesta de satisfacción del servicio | `encuesta_servicio`, `orden_servicio` |

### 16. Estreno

| Funcionalidad | Tablas que participan |
| --- | --- |
| Prueba de manejo y cotización de auto nuevo | `solicitud_estreno`, `prospecto`, `modelo_catalogo`, `estimacion_toma_cuenta` |

### 17. Recolección y entrega a domicilio

| Funcionalidad | Tablas que participan |
| --- | --- |
| Recolección y entrega del vehículo | `direccion_cliente`, `traslado`, `checklist_traslado`, `cita` |

### 18. Bitácora del conductor

| Funcionalidad | Tablas que participan |
| --- | --- |
| Registro de gastos y rendimiento | `gasto_vehiculo`, `lectura_km`, `vehiculo_cliente` |

### 19. Cuentas familiares

| Funcionalidad | Tablas que participan |
| --- | --- |
| Compartir vehículo con permisos | `acceso_compartido`, `vehiculo_cliente`, `cuenta_app` |

### 20. Seguridad y privacidad

| Funcionalidad | Tablas que participan |
| --- | --- |
| Aviso de privacidad | `aviso_privacidad`, `aceptacion_aviso`, `cuenta_app` |
| Derechos ARCO (descargar datos y borrar cuenta) | `solicitud_arco`, `cliente`, `cuenta_app` |

### 21. Asistente CareCar (IA)

| Funcionalidad | Tablas que participan |
| --- | --- |
| Preguntas sobre el manual del vehículo | `manual`, `fragmento_manual`, `consulta_asistente` |
| Identificación de testigos del tablero | `consulta_asistente`, `vehiculo_cliente` |

### 22. Valuación formal

| Funcionalidad | Tablas que participan |
| --- | --- |
| Valuación y oferta de toma a cuenta | `valuacion`, `estimacion_toma_cuenta`, `cita` |

### 23. Ayuda y sucursales

| Funcionalidad | Tablas que participan |
| --- | --- |
| Preguntas frecuentes | `pregunta_frecuente` |
| Sucursales y horarios | `sucursal` |
| Reporte de problemas de la app | `reporte_app` |
