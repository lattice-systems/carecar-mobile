# Derechos ARCO: descargar mis datos (V2-M22.02)

Historia [V2-M22.02](../../plan/modulos/M22-seguridad-y-privacidad.md). Backend: [`agencia-360-backend#97`](https://github.com/lattice-systems/agencia-360-backend/pull/97), contrato 2.14.0. Tabla de la ficha: `solicitud_arco`.

La LFPDPPP da a cada persona derecho de **A**cceso, **R**ectificación, **C**ancelación y **O**posición sobre sus datos. Esta historia entrega el acceso: una copia de los datos personales que CareCar guarda de la cuenta. La cancelación es V2-M22.03; la rectificación y la oposición se atienden hoy en la agencia (el tipo ya existe en la tabla).

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
- La cancelación de la cuenta (V2-M22.03) reutiliza la tabla y la pantalla «Privacidad y mis datos».
