# Derechos ARCO: descargar mis datos y borrar mi cuenta (V2-M22.02 y V2-M22.03)

Historias [V2-M22.02](../../plan/modulos/M22-seguridad-y-privacidad.md) (acceso) y V2-M22.03 (cancelación). Backend: [`agencia-360-backend#97`](https://github.com/lattice-systems/agencia-360-backend/pull/97) (contrato 2.14.0) y [`agencia-360-backend#99`](https://github.com/lattice-systems/agencia-360-backend/pull/99) (contrato 2.15.0). Tabla de la ficha: `solicitud_arco`.

La LFPDPPP da a cada persona derecho de **A**cceso, **R**ectificación, **C**ancelación y **O**posición sobre sus datos. La app entrega el acceso (una copia de los datos personales que CareCar guarda de la cuenta, más abajo) y la cancelación (borrar la cuenta, al final); la rectificación y la oposición se atienden hoy en la agencia (el tipo ya existe en la tabla).

# Descargar mis datos (V2-M22.02)

## Qué hace

| Criterio | Mecanismo | Código |
| --- | --- | --- |
| La solicitud genera un archivo con todos mis datos | `POST /privacidad/arco/acceso` abre la solicitud (202); después de confirmarla, el backend arma un JSON con una sección por tabla de la cuenta. | `ArcoService`, `ExportadorDeDatosJdbc` (backend) |
| Aviso al estar listo | El backend publica el evento `arco.estado` por el canal de avisos en vivo; la app lo escucha y, por si el canal se cae, vuelve a preguntar cada 3 s mientras la solicitud está pendiente. | `accesoArcoProvider` |
| Descargarlo | «Descargar mi archivo» baja el JSON con la sesión y abre la hoja de compartir del sistema. | `pantalla_mis_datos.dart` |

## Qué trae el archivo

Una sección por tabla: `cliente`, `cuentaApp` (sin el hash de la contraseña), `vehiculos`, `citas`, `traslados` y sus checklists, `direcciones`, `servicios`, `estimacionesTomaCuenta`, `solicitudesEstreno`, `solicitudesAsistencia`, `consultasAsistente`, `lecturasKm`, `gastos`, `avisosAceptados` y `solicitudesArco`. Las secciones sin datos van vacías: el archivo dice qué no hay, no lo omite.

Y un `alcance` que dice **qué no incluye**: los datos fiscales y comerciales que la agencia conserva por obligación legal (ventas, pagos y facturas), las notas internas del personal y las fotos y archivos adjuntos. Se piden en la agencia. La pantalla lo avisa antes de pedir la copia.

## Decisiones

- **La copia no pasa por el módulo `archivos`.** Ese módulo solo admite imágenes, PDF y video y entrega por URL firmadas públicas de 15 minutos. Un archivo con datos personales solo sale por la API con la sesión de su cuenta, sin caché; vive en la tabla `archivo_arco` (el diseño completo está en el plan del backend).
- **El archivo no se guarda en el teléfono.** La app lo descarga a memoria y lo entrega a la hoja de compartir; ahí la persona decide dónde queda. La capa de caché de la API tampoco guarda nada de esto.
- **Vence a los 7 días** y una limpieza diaria lo borra. Pedir una copia nueva borra la anterior: por cuenta nunca hay más de un archivo.
- **Una sola solicitud pendiente por cuenta.** Dos toques seguidos, o dos teléfonos, devuelven la misma; lo garantiza un índice único parcial en la base, no una lectura previa.
- **JSON y no PDF**: es legible por máquinas y por personas, y se puede abrir en cualquier lado. Un PDF «bonito» queda como mejora si la agencia lo pide.

## Límites

- **Falta probarlo en un teléfono** contra el backend real; la ficha queda en 🟡. El simulador (`mock_api`) deja la solicitud lista a los 2 s (`RETRASO_ARCO_MS` lo cambia).
- **El aviso en vivo solo llega mientras la pantalla está abierta.** Si la persona sale antes de que termine, al volver ve el estado actual; no hay notificación push (V2-M06 pendiente).
- **Una columna que guarde datos de la persona en una tabla nueva** no entra sola: hay que agregar su sección en `ExportadorDeDatosJdbc`. La regla queda dicha en el plan del backend.
- La cancelación de la cuenta (V2-M22.03) reutiliza la tabla y la pantalla «Privacidad y mis datos»; va abajo.

# Borrar mi cuenta (V2-M22.03)

La persona puede pedir que se borre su cuenta desde «Privacidad y mis datos» → «Eliminar mi cuenta». **No se puede deshacer.** El detalle de lo que pasa con cada dato está en el plan del backend (`plan/historias-backend.md`, «Diseño de V2-M22.03»).

## Qué hace

| Criterio | Mecanismo | Código |
| --- | --- | --- |
| Flujo con confirmación | Tres pasos seguidos: leer qué se borra y qué se conserva, escribir la contraseña y deslizar el control hasta el final (con lector de pantalla, un botón que abre un diálogo). | `pantalla_eliminar_cuenta.dart`, `DeslizarParaConfirmar` |
| Se desactiva `cuenta_app` y se anonimizan los datos no obligatorios | `POST /privacidad/arco/cancelacion` `{contrasena}`: en una sola transacción borra o anonimiza lo que ninguna ley obliga a conservar y cancela la cuenta. | `CancelacionService`, `AnonimizadorDeCuentaJdbc` (backend) |
| Lo fiscal se conserva | No se tocan ventas, pagos, facturas ni prospectos (son de otros módulos); tampoco el historial de servicio de los vehículos ni la prueba del aviso aceptado. | tabla del plan del backend |
| La sesión termina | Al confirmar el servidor, la app cierra la sesión (tokens, caché de la API y recordatorios locales) y muestra «Tu cuenta se eliminó» sobre la pantalla de entrada. | `ControladorSesion.cerrarSesion` |

## Qué se borra y qué se conserva

- **Se borra o se vacía:** nombre, correo y teléfono; direcciones; preguntas al asistente; estimaciones de toma a cuenta y solicitudes de estreno; la bitácora de gastos y kilometraje con sus fotos y tickets; la ubicación y el comentario de las solicitudes de asistencia; las sesiones, los códigos de recuperación y la copia de datos que se hubiera pedido.
- **Se conserva:** el historial de servicio y garantía de los vehículos (citas, traslados, órdenes con sus firmas de aprobación), lo fiscal y comercial, y la constancia de que se aceptó el aviso. La pantalla lo dice con esas palabras y **no** promete que lo conservado «ya no lleva tu nombre»: las facturas son de otros módulos y no se tocan.

## Decisiones

- **La contraseña, no solo el deslizar.** Alguien con el teléfono desbloqueado podría deslizar; la contraseña confirma que es la persona.
- **Contraseña equivocada = 400, no 401.** La app lee un 401 como sesión vencida y cerraría la sesión sin explicar. El 400 se dice en el campo («La contraseña no es correcta») y se quita al escribir otra.
- **Cuenta como intento del login.** La contraseña equivocada suma al contador de la cuenta: a los cinco, 429 con `Retry-After` y la pantalla dice cuántos minutos esperar (sin inventar un tiempo si el servidor no lo dio). Sin esto, la pantalla sería una forma de adivinar contraseñas sin límite.
- **La sesión se cierra aunque la persona salga de la pantalla.** La cuenta se borra en el servidor sin importar dónde esté la persona; todo lo que hace falta después de esperar se toma antes del `await`, y una prueba cierra la pantalla a media petición.
- **Una respuesta perdida no deja la cuenta a medias.** Si la cancelación se hizo pero la respuesta no llegó y se reintenta, el token ya no sirve (403): la app lo trata como hecho (`CuentaYaCerrada`) y cierra la sesión, en vez de mostrar un error.
- **Sin reactivación.** El CRM no puede reactivar una cuenta cancelada por su titular (409); una desactivada a mano por el personal sí. Volver a usar la app requiere un cliente nuevo.
- **Aparte y en rojo.** La fila vive en un grupo propio en «Privacidad y mis datos», separada del aviso y de la descarga.

## Límites

- **Falta probarlo en un teléfono** contra el backend real; la ficha sigue en 🟡. El simulador (`mock_api`) lo deja en `db.json` y `npm run reset` devuelve la cuenta; su contador de fallos es solo de la cancelación (en el backend es el mismo del login).
- **Qué se conserva es criterio de la agencia y su revisión legal está pendiente** (incluidas las firmas de aprobación de trabajos adicionales). Si cambia, se cambia en `AnonimizadorDeCuentaJdbc` y en la tabla del plan.
- **No hay periodo de espera ni confirmación por correo** (llega con V2-M06): el borrado es inmediato. Es una decisión de producto que queda abierta.
- **En el teléfono, la app hace el cierre de sesión de siempre:** tokens, caché de la API y recordatorios locales. Un archivo que la persona ya guardó o compartió con la hoja del sistema (la copia de sus datos) queda fuera de la app y es suya. Si la app llega a guardar otros datos personales en el teléfono, deben limpiarse en el mismo cierre.
- **Los datos de otros módulos** (prospecto del CRM, ventas, facturas) no se tocan; si la agencia decide anonimizarlos, es historia de esos módulos.
