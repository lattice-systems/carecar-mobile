# Matriz de cumplimiento de la ficha técnica v2.1

Cada funcionalidad de la [ficha](../docs/ficha-tecnica/README.md) tiene una fila. Una fila pasa a ✅ solo con **prueba automática enlazada** (app y backend) y demostrada en celular. Toda historia que avance una funcionalidad actualiza esta tabla en su PR.

Leyenda: ✅ cumple con prueba · 🟡 existe en v1, falta v2 o prueba · ❌ brecha contra lo que pide la ficha · ⬜ aún no existe (planeada).

Estado levantado contra `main` de `carecar-mobile` (PR #12) y `agencia-360-backend` (PR #57).

## Funcionalidades

### 1. Acceso y perfil — plan [M01](modulos/M01-acceso-y-perfil.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Inicio de sesión (cuenta entregada por la agencia, sin registro público) | `cliente`, `cuenta_app`, `sesion_app` | 🟡 pantalla v2 con 42 pruebas (V2-M01.01) y la renovación de 30 días demostrada de punta a punta (V2-M01.11); **la ruta del módulo ya solo espera** a actualizar las trece pruebas ajenas, y falta demostrarla en celular | V2-M01.01, V2-M01.11 |
| Cambio obligatorio de la contraseña temporal | `cuenta_app` | 🟡 pantalla v2 con 15 pruebas y el apretón de manos con el guardia fijado (V2-M01.03); su ruta **no está encendida** hasta V2-M01.04, y falta demostrarla en celular | V2-M01.03 |
| Recuperación de contraseña por enlace de un solo uso | `cuenta_app`, `token_recuperacion` | 🟡 backend con `token_recuperacion` y enlace de un solo uso (`AccesoAppIntegrationTest`); las dos pantallas de la app con 26 pruebas (V2-M01.04), **la ruta del módulo no está encendida** y falta demostrarlo en celular con un correo real | V2-M01.04, V2-T05.04 |
| Desbloqueo con huella o rostro | `cuenta_app`, `sesion_app` | ⬜ | V2-M01.05 |
| Consulta del perfil | `cliente`, `cuenta_app`, `vehiculo_cliente` | 🟡 | V2-M01.06 |
| Edición de teléfono y correo con verificación | `cliente`, `cuenta_app`, `verificacion_contacto` | ❌ backend con `cuenta_app.usuario` que sigue al correo (V2-T05.03); falta `verificacion_contacto` y la pantalla | V2-M01.07, V2-T05.03 |
| Sesiones y dispositivos activos | `sesion_app` | ⬜ | V2-M01.09, V2-M01.10 |
| Aviso de cuenta desactivada | `cuenta_app` | 🟡 | V2-M01.08 |

### 2. Mis vehículos y postventa — plan [M02](modulos/M02-vehiculos-y-postventa.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Mis vehículos (garaje) | `cliente`, `vehiculo_cliente` | 🟡 | V2-M02.01 |
| Detalle del vehículo y kilometraje | `vehiculo_cliente`, `orden_servicio` | 🟡 | V2-M02.02 |
| Manuales por modelo y año | `manual`, `vehiculo_cliente` | 🟡 app v2 abre, descarga, comparte y **busca** en el manual (índice de texto offline, sin motor de PDF); backend con `manual.archivo_pdf`; falta índice estructurado y probar en celular | V2-M02.03, V2-T05.05 |
| Ficha técnica del vehículo | `ficha_tecnica_modelo`, `vehiculo_cliente` | 🟡 app v2 y backend (tabla y endpoint, rama `feat/v2-juan-pablo-citas-b`); la tabla aún sin datos, la app usa su respaldo | V2-M02.04 |
| Historial de servicios | `orden_servicio`, `vehiculo_cliente` | 🟡 app v2 con paginación infinita, filtro por año, fecha de cierre, estatus y total (`test/modulos/historial/`); backend con filtro y años (`ServiciosAppIntegrationTest`); falta demostrar en celular | V2-M02.05, V2-T05.06 |
| Ticket del servicio | `orden_servicio`, `orden_refaccion`, `refaccion` | 🟡 app v2 con mano de obra y refacciones (cantidad × precio) que suman el total y PDF para compartir (`test/modulos/historial/`); backend `GET /servicios/{id}` (`ServiciosAppIntegrationTest`); falta demostrar en celular | V2-M02.06, V2-T05.06 |
| Disponibilidad del taller | `franja_horario`, `cita` | 🟡 backend con la tabla `franja_horario` y `cita.franja_id` con FK (`AgendaAppIntegrationTest`); falta demostrar en celular | V2-M02.07, V2-T05.07 |
| Agendar cita | `cita`, `franja_horario`, `vehiculo_cliente` | 🟡 app y backend (`cita.motivo`, `CITA_DUPLICADA`) listos; falta demostrar en celular | V2-M02.08 |
| Mis citas (próximas y pasadas) | `cita`, `franja_horario`, `vehiculo_cliente` | 🟡 app v2 lista con estados y paginación; falta demostrar en celular | V2-M02.09 |
| Cancelar y reprogramar cita | `cita`, `franja_horario` | 🟡 app y backend de cancelar y reprogramar listos; falta demostrar en celular | V2-M02.10, V2-M02.13 |
| Comprobante de cita con código QR | `cita`, `vehiculo_cliente` | 🟡 QR firmado en app y backend; agregar al calendario como `.ics` hecho (V2-M02.12, falta la dirección de la sucursal de V2-M27.02 y probar en celular) | V2-M02.11, V2-M02.12 |

### 3. Catálogo y calculadora — plan [M03](modulos/M03-catalogo-y-calculadora.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Catálogo de modelos actuales | `modelo_catalogo`, `modelo_catalogo_imagen` | 🟡 app lista contra `mock_api`, falta construir las tablas en el backend | V2-M03.01, V2-M03.02 |
| Comparador de modelos | `modelo_catalogo` | ✅ hecho (reutiliza el detalle de V2-M03.02) | V2-M03.03 |
| Calculadora de toma a cuenta (estimación no vinculante) | `modelo_catalogo`, `vehiculo_cliente`, `parametro_toma_cuenta`, `estimacion_toma_cuenta` | 🟡 la calculadora (V2-M03.04) está lista contra `mock_api` y el diseño de las tablas y la fórmula está en el backend (backend#69), y el backend ya está construido (backend#84, V2-M03.06). M03.05, la diferencia a pagar, también está lista. M03.07, la lista de estimaciones guardadas, también. Faltan los valores reales de los parámetros, que entrega el PO | V2-M03.04 a V2-M03.07 |

### 4. Taller en vivo — plan [M04](modulos/M04-taller-en-vivo.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Estado de la orden en tiempo real | `orden_servicio`, `etapa_orden` | 🟡 backend con `etapa_orden` y `orden_servicio.cita_id`, `asesor_id` y `entrega_estimada` (`TallerAppIntegrationTest`); app con la tarjeta de Inicio y la línea de tiempo con la hora de cada etapa y la entrega estimada (`test/modulos/taller/`); se actualiza sola con el aviso `orden` del canal de eventos (`GET /eventos`, V2-M04.03); lista para entrega, la tarjeta cambia a «Listo» con el total y el horario de `franja_horario` (V2-M04.06), y la orden cerrada pasa sus adicionales aprobados a `orden_mano_de_obra` y `orden_refaccion` y abre su ticket del historial (V2-M04.07); falta el push con la app cerrada (V2-M06.07) y demostrar en celular | V2-M04.01, V2-M04.02, V2-M04.03, V2-M04.06, V2-M04.07 |
| Inspección multipunto con fotos | `orden_servicio`, `punto_inspeccion`, `evidencia_orden` | 🟡 backend con `punto_inspeccion` y `evidencia_orden` (fotos y videos en `archivos`, URL firmada) (`TallerAppIntegrationTest`); app con semáforo, fotos con zoom y video en el reproductor del teléfono (`test/modulos/taller/`); falta demostrar en celular | V2-M04.04 |
| Aprobación de trabajos adicionales | `orden_servicio`, `trabajo_adicional` | 🟡 backend con `trabajo_adicional` y su auditoría (quién, cuándo y firma) (`TallerAppIntegrationTest`); app aprueba o rechaza uno por uno con firma en pantalla y recalcula el total (`test/modulos/taller/`); la firma usa un lienzo provisional; falta demostrar en celular | V2-M04.05 |

### 5. Mantenimiento inteligente — plan [M05](modulos/M05-mantenimiento-inteligente.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Plan de mantenimiento y próximo servicio | `plan_mantenimiento`, `concepto_mantenimiento`, `orden_servicio`, `vehiculo_cliente` | 🟡 app y backend (plan cruzado con el historial, próximo por km y por tiempo, qué incluye y precio estimado); recordatorio por el canal en vivo hecho (V2-M05.05, falta el push de V2-M06.02) y falta demostrar en celular | Ver M05 |
| Registro de kilometraje del cliente | `lectura_km`, `vehiculo_cliente` | 🟡 app y backend, con foto opcional; falta demostrar en celular | Ver M05 |

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
| Pago del servicio | `pago_app`, `orden_servicio`, `metodo_pago` | ⬜ procesador propuesto en la [ADR 0009](../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md) (Stripe en modo de pruebas) | V2-M08.01, V2-M08.02, V2-M08.03, V2-M08.07 |
| Métodos de pago guardados | `metodo_pago` | ⬜ | V2-M08.04 |
| Datos fiscales y facturas | `perfil_fiscal`, `factura`, `pago_app` | ⬜ `factura` existe (ERP, sin timbrado); se le agregan columnas para facturas de servicio y el timbrado va con Facturama en sandbox ([ADR 0009](../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md)) | V2-M08.05, V2-M08.06 |

### 9. Documentos y vencimientos — plan [M09](modulos/M09-documentos-y-vencimientos.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Documentos del vehículo | `documento_vehiculo`, `vehiculo_cliente` | ⬜ | Ver M09 |
| Alertas de vencimiento | `documento_vehiculo`, `notificacion` | ⬜ | Ver M09 |

### 10. Garantía y campañas de seguridad — plan [M10](modulos/M10-garantia-y-campanas.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Cobertura de garantía | `garantia`, `vehiculo_cliente` | 🟡 backend con `garantia` y el estado por fecha y km contra el km actual (`GarantiaCampanasIntegrationTest`, `PoliticaGarantiaTest`) y aviso diario a 60 y 15 días y 1 000 km (`AvisosGarantiaServiceTest`); app con coberturas, consumo y recarga en vivo (`test/modulos/garantia/`); falta el push con la app cerrada (V2-M06.07) y demostrar en celular | V2-M10.01, V2-M10.05 |
| Campañas de seguridad (recalls) | `campana_seguridad`, `campana_vehiculo`, `vehiculo_cliente`, `cita` | 🟡 backend con cruce por modelo, año y rango de VIN, `campana_vehiculo` y cita con motivo `CAMPANA` (`GarantiaCampanasIntegrationTest`, `CampanasAppServiceTest`); app con campañas, agendar, recarga en vivo e insignia en el garaje (`test/modulos/garantia/`, `test/modulos/vehiculos/garaje_campanas_test.dart`); falta el push con la app cerrada (V2-M06.07) y demostrar en celular | V2-M10.02, V2-M10.03, V2-M10.04 |

### 11. Asistencia en camino — plan [M11](modulos/M11-asistencia-en-camino.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Solicitud de asistencia (SOS) | `solicitud_asistencia`, `vehiculo_cliente` | 🟡 guías, solicitud con ubicación y estado en vivo (SSE) en app y backend; llamadas rápidas al 911, la agencia y la aseguradora hechas (V2-M11.02, la aseguradora espera a V2-M09.01); falta el push con la app cerrada (V2-M06.02) y demostrar en celular | V2-M11.01, V2-M11.02, V2-M11.03, V2-M11.04 |

### 12. Lealtad y recompensas — plan [M12](modulos/M12-lealtad.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Puntos y niveles | `movimiento_puntos` | 🟡 backend con `movimiento_puntos`, saldo por suma, nivel por lo ganado en 12 meses y puntos al entregar la orden una sola vez (`LealtadIntegrationTest`, `ReglasLealtadTest`); app con Mis puntos, movimientos paginados, puntos en el ticket y recarga en vivo (`test/modulos/lealtad/`); reglas propuestas, pendientes del PO; falta sumar al confirmarse el pago (V2-M08.02) y demostrar en celular | V2-M12.01, V2-M12.02, V2-M12.05 |
| Canje de recompensas | `recompensa`, `canje`, `movimiento_puntos` | 🟡 backend con canje bajo bloqueo del saldo y de la recompensa, código de 8 caracteres, vencimiento a 30 días con `DEVOLUCION_CANJE` y uso por el personal (`LealtadIntegrationTest`, `LealtadAppServiceTest`); app con catálogo, confirmación, mis canjes y QR (`test/modulos/lealtad/`); falta demostrar en celular | V2-M12.03 |
| Referidos | `referido`, `prospecto` | 🟡 backend con `referido`, consentimiento, prospecto creado por evento en `ventascrm` y 500 puntos al finalizarse la venta una sola vez (`LealtadIntegrationTest`, `ReferidosAppServiceTest`); app con mi código para compartir, formulario y mis referidos (`test/modulos/lealtad/`); falta demostrar en celular | V2-M12.04 |

### 13. Promociones y novedades — plan [M13](modulos/M13-promociones.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Promociones personalizadas | `promocion`, `promocion_vista`, `cita` | ⬜ | Ver M13 |

### 14. Tienda de refacciones y accesorios — plan [M14](modulos/M14-tienda.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Catálogo compatible con mi vehículo | `refaccion`, `compatibilidad_refaccion` | 🟡 backend integrado (backend#107) y app lista con el contrato 2.21.0 y `mock_api`: filtro por vehículo, existencia visible, categorías y búsqueda (`test/modulos/tienda/pantalla_tienda_test.dart`, `pantalla_producto_test.dart` y `test/contrato/contrato_tienda_test.dart`). Falta probarla contra el backend real y demostrarla en celular | V2-M14.01 |
| Pedidos y apartados | `pedido_app`, `pedido_app_renglon`, `refaccion`, `movimiento_inventario`, `cita` | 🟡 backend integrado (backend#107) y app lista con `mock_api`: apartar con llave de idempotencia, vigencia, cancelar, instalar en una cita y mis pedidos en vivo (`pantalla_carrito_test.dart` y `pantalla_pedidos_test.dart`). Se paga en caja: el pago en la app (V2-M14.04) espera a V2-M08.02 y el push con la app cerrada a M06. Falta probarla contra el backend real y demostrarla en celular | V2-M14.02, V2-M14.03, V2-M14.05 |

### 15. Encuestas y NPS — plan [M15](modulos/M15-encuestas-nps.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Encuesta de satisfacción del servicio | `encuesta_servicio`, `orden_servicio` | ⬜ | Ver M15 |

### 16. Estreno — plan [M16](modulos/M16-estreno.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Prueba de manejo y cotización de auto nuevo | `solicitud_estreno`, `prospecto`, `modelo_catalogo`, `estimacion_toma_cuenta` | 🟡 backend con `solicitud_estreno` y prospecto de origen `APP` (`EstrenoIntegrationTest`, backend#93); app con las tres pantallas, el repositorio y el contrato 2.12.1 probados (`test/modulos/estreno/`, `test/api/estreno_*_test.dart`, `test/contrato/contrato_estreno_test.dart`); falta demostrarla en celular | V2-M16.01, V2-M16.02, V2-M16.03, V2-M16.04 |

### 17. Recolección y entrega a domicilio — plan [M17](modulos/M17-recoleccion-y-entrega.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Recolección y entrega del vehículo | `direccion_cliente`, `traslado`, `checklist_traslado`, `cita` | 🟡 direcciones, recolección al agendar, seguimiento del chofer en vivo y checklist con fotos en app y backend; cancelar o reprogramar mueve los traslados; faltan que estas pantallas pasen del mapa provisional al componente Mapa (ya existe, V2-T02.09), el push con la app cerrada (V2-M06.02) y demostrar en celular | V2-M17.01, V2-M17.02, V2-M17.03, V2-M17.04 |

### 18. Bitácora del conductor — plan [M18](modulos/M18-bitacora-conductor.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Registro de gastos y rendimiento | `gasto_vehiculo`, `lectura_km`, `vehiculo_cliente` | 🟡 app y backend: cargas desde la foto del ticket, otros gastos, rendimiento y exportación; falta demostrar en celular | V2-M18.01, V2-M18.02, V2-M18.03, V2-M18.04, V2-M18.05, V2-M05.03 |

### 19. Cuentas familiares — plan [M19](modulos/M19-cuentas-familiares.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Compartir vehículo con permisos | `acceso_compartido`, `vehiculo_cliente`, `cuenta_app` | ⬜ | Ver M19 |

### 20. Seguridad y privacidad — plan [M22](modulos/M22-seguridad-y-privacidad.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Aviso de privacidad | `aviso_privacidad`, `aceptacion_aviso`, `cuenta_app` | 🟡 backend con las dos tablas de la ficha (`V43`), aviso inmutable por disparador, aceptación idempotente y publicación de versiones (`PrivacidadIntegrationTest`, `PrivacidadServiceTest`, backend#96); app con la puerta, el verificador, la guardia y el perfil probados de punta a punta (`test/modulos/privacidad/`, `test/nucleo/navegacion/`); la versión 2 (`V45`, V2-M22.10, backend#100) nombra a Azure, Neon, OpenStreetMap, el geocodificador del teléfono y Gemini; falta demostrarlo en celular contra el backend real, la revisión legal y que la agencia publique su texto definitivo | V2-M22.01, V2-M22.10 |
| Derechos ARCO (descargar datos y borrar cuenta) | `solicitud_arco`, `cliente`, `cuenta_app` | 🟡 acceso (descargar mis datos): backend con `solicitud_arco` (`V44`), la copia armada fuera de la petición, entregada solo con sesión y vigente 7 días (`ArcoIntegrationTest`, `ArcoServiceTest`, backend#97); app con «Privacidad y mis datos» y «Mis datos», el seguimiento por aviso en vivo y la descarga probados (`test/modulos/privacidad/`). Cancelación (borrar mi cuenta): backend con la contraseña como confirmación, 5 intentos y 429, todo en una transacción que borra o anonimiza lo no obligatorio y desactiva la cuenta sin reactivación posible (`CancelacionIntegrationTest` con dos clientes sembrados, `CancelacionServiceTest`, backend#99); app con «Eliminar mi cuenta» (contraseña + deslizar, error de contraseña, bloqueo, sin red, cierre de sesión aunque se salga de la pantalla) en `test/modulos/privacidad/pantalla_eliminar_cuenta_test.dart`. Falta demostrarlo en celular y la revisión legal de lo que se conserva | V2-M22.02, V2-M22.03 |

### 21. Asistente CareCar (IA) — plan [M24](modulos/M24-asistente-carecar.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Preguntas sobre el manual del vehículo | `manual`, `fragmento_manual`, `consulta_asistente` | ✅ | V2-M24.02 y V2-M24.03: tablas en `V27`, pruebas `AsistenteIntegrationTest` (backend) y `test/modulos/asistente/` (app); demostrado en un Xiaomi contra Azure con Gemini |
| Identificación de testigos del tablero | `consulta_asistente`, `vehiculo_cliente` | ✅ | V2-M24.05: `POST /asistente/testigos` (backend#90) con foto sin EXIF que no se guarda, registro en `consulta_asistente`; pruebas `AsistenteIntegrationTest`, `LimpiadorImagenTest` (backend) y `test/modulos/asistente/` (app) |

### 22. Valuación formal — plan [M26](modulos/M26-valuacion.md)

| Funcionalidad | Tablas | Estado | Historias |
| --- | --- | --- | --- |
| Valuación y oferta de toma a cuenta | `valuacion`, `estimacion_toma_cuenta`, `cita` | 🟡 app lista contra `mock_api` con el contrato de la valuación: solicitud, fotos guiadas, inspección, oferta y valor en el tiempo (`test/modulos/valuacion/` y `test/contrato/contrato_valuacion_test.dart`). El backend se construye aparte: `valuacion` es nueva y la inspección reusa `cita` con motivo `VALUACION`. `estimacion_toma_cuenta` ya existe (`V34`). La oferta se captura con endpoints del personal porque el ERP y el CRM web están congelados. Falta integrar el backend y demostrarlo en celular | V2-M26.01 a V2-M26.05 |

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
| `cuenta_app.usuario` | Creada; el login la usa y sigue al correo del cliente | V2-T05.03 |
| `token_recuperacion` | Creada con enlace de un solo uso y código para la app v1; `codigo_recuperacion` retirada | V2-T05.04 |
| `manual.archivo_pdf` | Renombrada desde `manual.archivo` | V2-T05.05 |
| `orden_servicio`, `orden_refaccion` | Creadas con `mano_de_obra`, `estatus` y `fecha_cierre`; la mano de obra detallada va en `orden_mano_de_obra` | V2-T05.06 |
| `franja_horario` | Creada con sus campos; `cita.franja_id` apunta a ella | V2-T05.07 |

Tablas de la ficha que ya existen sin cambios: `cliente`, `vehiculo_cliente`, `cita`, `modelo_catalogo`, `sesion_app`, `refaccion`, `movimiento_inventario`, `factura`, `prospecto`. Todas las demás se crean con las historias de su módulo.
