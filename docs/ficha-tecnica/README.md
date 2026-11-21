# Ficha técnica CareCar v1.1 — contrato obligatorio

> **Regla de oro:** todo lo que está en esta ficha se cumple **sí o sí**. La versión 2 de la app se construye **nueva** encima de ella: puede agregar módulos, tablas, campos y pantallas, pero **nunca** quitar, renombrar ni contradecir lo que la ficha define.

- Original: [`ficha-tecnica-carecar-v1.1.docx`](ficha-tecnica-carecar-v1.1.docx) (fuente de verdad; este archivo es su transcripción fiel).
- Cualquier cambio a la ficha lo aprueba el Product Owner y sube la versión del `.docx` y de esta transcripción en el mismo PR.
- La matriz de cumplimiento está en [`../../plan/cumplimiento-ficha.md`](../../plan/cumplimiento-ficha.md).

---

## Descripción

CareCar es la aplicación móvil de servicio postventa de la agencia automotriz, disponible para Android e iOS. Está dirigida a los clientes que ya recibieron su vehículo y les permite consultar sus unidades, manuales e historial de servicios, agendar citas en el taller y conocer el catálogo de modelos actuales. El acceso es exclusivo: la agencia crea la cuenta del cliente al entregar la unidad, y la app obtiene toda su información de los servicios de Agencia360.

## Integrantes

| Nombre | Rol |
| --- | --- |
| Daniel Ojeda Luna | Scrum Master |
| Haziel Orlando Gutierrez Hernandez | Product Owner |
| Cristian Veuliah Mares Cerda | Equipo de desarrollo |
| Ricardo Garnica Mejia | Equipo de desarrollo |
| Juan Pablo Rea Cano | Equipo de desarrollo |
| Jael Neftali Vargas Grijalva | Equipo de desarrollo |

## Tablas por módulo

Las tablas viven en la base de datos de Agencia360; la app las consulta a través de su API. Los campos corresponden al modelo de datos v1.

### Módulo 1 - Acceso y perfil

| Tabla | Campos | Descripción |
| --- | --- | --- |
| `cliente` | id, prospecto_id, nombre, telefono, correo | Datos del cliente. Se crea cuando recibe su vehículo; el cliente edita su teléfono y correo desde la app. |
| `cuenta_app` | id, cliente_id, usuario, contrasena_hash, debe_cambiar_contrasena, activa | Cuenta de acceso que crea la agencia; el usuario es el correo del cliente. Puede desactivarse. |
| `token_recuperacion` | id, cuenta_app_id, token_hash, expira, usado | Enlace de un solo uso para recuperar la contraseña; se guarda el hash del token y expira. |

### Módulo 2 - Mis vehículos y postventa

| Tabla | Campos | Descripción |
| --- | --- | --- |
| `vehiculo_cliente` | id, cliente_id, vehiculo_id, vin, modelo, anio, placas, kilometraje | Vehículos de cada cliente. Las unidades vendidas por la agencia se registran al entregarse. El kilometraje lo actualiza el taller al cerrar un servicio. |
| `manual` | id, modelo, anio, archivo_pdf | Manuales y fichas técnicas por modelo y año; se asocian al vehículo por modelo y año. |
| `orden_servicio` | id, vehiculo_cliente_id, mano_de_obra, total, estatus, fecha_cierre | Servicios realizados al vehículo. El total (mano de obra más refacciones) se guarda al cerrar la orden, y esta genera el ticket que ve el cliente. |
| `orden_refaccion` | id, orden_servicio_id, refaccion_id, cantidad, precio | Refacciones usadas en cada orden de servicio. La refacción pertenece al inventario de Agencia360. |
| `franja_horario` | id, dia_semana, hora_inicio, hora_fin, capacidad | Horarios semanales del taller (por día de la semana) y cuántas citas caben en cada uno. El cupo se calcula por franja y fecha. |
| `cita` | id, vehiculo_cliente_id, franja_id, fecha, estado | Citas agendadas: confirmada, atendida, no asistió o cancelada. El cliente se obtiene a través del vehículo y puede cancelar su cita desde la app. |

### Módulo 3 - Catálogo y calculadora

| Tabla | Campos | Descripción |
| --- | --- | --- |
| `modelo_catalogo` | id, modelo, activo | Modelos actuales que se muestran en el catálogo. Es una lista aparte del inventario. |

## Módulos

| Módulo | Funcionalidades | Historias |
| --- | --- | --- |
| 1. Acceso y perfil | Inicio de sesión con la cuenta que entrega la agencia (sin registro público), cambio obligatorio de la contraseña temporal, recuperación de contraseña por correo y gestión del perfil personal. | APP-2.1, APP-2.2, APP-2.3 |
| 2. Mis vehículos y postventa | Consulta de los vehículos del cliente con sus manuales y fichas técnicas, historial digital de servicios con su ticket y agendamiento y cancelación de citas en los horarios disponibles del taller. | APP-3.1, APP-3.2, APP-3.3 |
| 3. Catálogo y calculadora | Catálogo de los modelos actuales de la agencia y mini calculadora de toma a cuenta, que muestra una estimación no vinculante. | APP-4.1 |

## Control de versiones

| Versión | Modificaciones | Elaborado por | Aprobado por |
| --- | --- | --- | --- |
| v1.0 | Diseño inicial del documento. | Scrum Team | Scrum Master |
| v1.1 | Tablas por módulo movidas antes de Módulos; ajustes a las tablas de los módulos 1 y 2. | Scrum Team | Product Owner |
