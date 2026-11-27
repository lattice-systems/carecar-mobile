# Pruebas en celular físico por hito

Usa una compilación identificable de CareCar y un backend real con cuenta y vehículos de prueba. Anota el commit de la app, el ambiente del backend, el modelo del celular y la versión del sistema en el [registro de evidencia](evidencia.md). Ejecuta los casos del hito y repite el flujo base de H1 para detectar regresiones.

Instala el APK o IPA siguiendo la [guía de distribución](../publicacion.md). Usa Wi-Fi o datos móviles según el caso y confirma que el teléfono llega al backend antes de empezar. En Android de desarrollo con el backend en la PC puedes usar `adb reverse tcp:8080 tcp:8080` y `--dart-define=API_BASE_URL=http://localhost:8080/api/v1/app`. Para iOS usa una dirección HTTPS alcanzable desde el teléfono.

Marca `Pasa`, `Falla` o `Bloqueado` por caso. Anota resultado, motivo o enlace al reporte y adjunta evidencia sin credenciales, datos personales o tokens. Si una prueba crea una cita, un pedido o una solicitud usa datos de prueba y devuelve el registro a un estado reutilizable al terminar. Los criterios de cierre completos están en el [plan de hitos](../../plan/hitos.md).

## H0 · Base de trabajo

- **H0.1** Instala la compilación interna en un teléfono y ábrela. Comprueba que se identifica como CareCar, muestra el acceso y que el equipo puede repetir la instalación con la guía. Registra el artefacto instalado.

## H1 · Cimientos v2

- **H1.1** Abre `carecar://garaje` sin sesión en una compilación con `MODULOS_V2=vehiculos,citas`. Comprueba que pide acceso y que al entrar se reanuda el destino protegido. Regresa a Inicio y abre `carecar://ruta-inexistente`. La app debe llevar a una pantalla utilizable. En Android se puede abrir cada enlace con `adb shell am start -a android.intent.action.VIEW -d <enlace>`.
- **H1.2** En una compilación debug de desarrollo abre la galería con `carecar://galeria`. Revisa componentes representativos en claro, oscuro y texto al 200 %. Navega y desplaza el contenido en pantalla chica. Registra el resultado junto con el CI de golden.
- **H1.3** Abre Mis vehículos, confirma un vehículo de la cuenta, agenda una cita en una franja de prueba futura y cancélala desde Mis citas. Sal de la lista y vuelve a abrirla. Debe mostrarse cancelada y su franja debe volver a tener cupo. Si el backend aplica un plazo mínimo, elige una franja fuera del plazo de bloqueo.

## H2 · Núcleo de la ficha

- **H2.1** Ingresa con cuenta normal y luego con contraseña temporal. Comprueba el cambio obligatorio, recuperación y perfil con una cuenta que admita esos flujos.
- **H2.2** Recorre garaje, detalle, manual, historial, PDF y citas. Abre un manual del modelo correcto y confirma que historial y ticket corresponden al vehículo.
- **H2.3** Abre catálogo, compara modelos y genera una estimación. Repite lecturas guardadas de vehículos, historial y citas en modo avión. Comprueba navegación con lector de pantalla y texto al 200 %.

## H3 · Postventa viva

- **H3.1** Avanza una orden de prueba desde la agencia y comprueba el cambio de etapa en el teléfono. Abre inspección y evidencia, responde un adicional y comprueba el total actualizado.
- **H3.2** Valida próximo mantenimiento, recordatorio, permiso de notificaciones, bandeja y preferencias. Prueba las notificaciones con la app abierta y en segundo plano.
- **H3.3** Consulta documentos vigentes y vencidos, verifica un aviso de vencimiento y abre una campaña aplicable al VIN de prueba. Comprueba que la campaña conduce a la agenda.

## H4 · Cliente conectado

- **H4.1** Envía un mensaje desde una orden al asesor y recibe su respuesta. Cierra una orden de prueba, recibe la invitación NPS y confirma que una segunda apertura no duplica la encuesta.
- **H4.2** Consulta puntos y canje, compara promociones para vehículos elegibles y sin elegibilidad, y busca una respuesta en Ayuda. Abre ficha de una sucursal y su enlace externo de cómo llegar.

## H5 · Comercio

- **H5.1** Completa un pago en el ambiente de prueba y comprueba saldo, recibo y descarga de factura PDF/XML. Reserva un artículo y verifica la forma de recogida.
- **H5.2** Envía una prueba de manejo y una solicitud de cotización. Confirma que la agencia recibe el prospecto. Agenda recolección con domicilio de prueba, sigue su estado y comprueba el checklist. Abre una valuación formal y comprueba su estado.

## H6 · Inteligencia y extras

- **H6.1** Pregunta algo que esté en el manual y abre la página citada. Fotografía un testigo de muestra, revisa su recomendación y entra al atajo de agenda.
- **H6.2** Registra un gasto y revisa el rendimiento. Invita a una segunda cuenta con permisos limitados y verifica el acceso. Prueba SOS con datos de prueba y comprueba el estado en vivo.
- **H6.3** Agrega el widget de citas a Inicio y comprueba que se actualiza. Abre el pase de la cita en la Wallet disponible para el sistema.

## H7 · Lista para entregar

- **H7.1** Instala en Android e iOS con sus canales de entrega. Repite H1.1 y H1.3 con una compilación que habilite esos módulos y revisa español, inglés, lector de pantalla y texto al 200 %. Adjunta la ejecución de H1.2 en una compilación de desarrollo.
- **H7.2** Comprueba aviso de privacidad, exportación y solicitud ARCO con una cuenta de prueba. Adjunta corridas de accesibilidad, seguridad y rendimiento. Cruza la evidencia acumulada con la [matriz de la ficha](../../plan/cumplimiento-ficha.md).
