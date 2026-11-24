# Tablero de CareCar v2

Fuente única del estado de cada historia. Se actualiza **en el mismo PR** que mueve la historia (R2). Detalle y criterios en `plan/modulos/`.

Estados: `Borrador` (falta refinar) → `Lista` (cumple la Definición de Listo) → `En curso` → `En revisión` (PR abierto) → `Hecha` (integrada). Al tomar una historia cambia su estado y anota el número de PR.

WIP: **una historia `En curso` por persona**; al abrir su PR pasa a `En revisión` y puedes tomar la siguiente mientras esperas CI o revisión. **B** = requiere backend (`agencia-360-backend`, plan espejo en su `plan/`; el diseño técnico lo escribe quien la toma en su primer commit).

Marcas en **Depende de** (no bloquean; ver [`trabajo-en-paralelo.md`](trabajo-en-paralelo.md)):

- `(simulable)`: es una historia de backend. La app avanza contra el contrato y `mock_api`.
- `(provisional)`: es un componente del sistema de diseño. La pantalla avanza con un provisional en su módulo y lo reemplaza cuando se integre.

Cómo se edita este archivo para no chocar: cada quien cambia **solo su fila** (estado y PR); nunca se regenera ni se reformatea la tabla; en un conflicto se conserva en cada fila el **estado más avanzado** (`Borrador` < `Lista` < `En curso` < `En revisión` < `Hecha`) y se juntan los PR de ambos lados. Filas nuevas, totales y marcas, solo en PR del planificador.

Total: **214 historias** + 4 de H0.

## H0 · Base de trabajo

| ID | Historia | Dueño | B | Depende de | Estado | PR |
| --- | --- | --- | --- | --- | --- | --- |
| V2-H0.01 | Reglas, agentes y plan maestro en carecar-mobile | Daniel | | — | Hecha | #13 |
| V2-H0.02 | Reglas, agentes y plan del backend | Daniel | B | — | Hecha | backend#58 |
| V2-H0.03 | Check `Autoría` requerido en `main` de ambos repos | Daniel | | V2-H0.01, V2-H0.02 | Hecha | |
| V2-H0.04 | Cada integrante activa `core.hooksPath .githooks` y lee AGENTS.md | Todos | | V2-H0.01 | Hecha | |

## H1 · Cimientos v2

| ID | Historia | Dueño | B | Depende de | Estado | PR |
| --- | --- | --- | --- | --- | --- | --- |
| V2-T01.01 | Aceptar o reemplazar las decisiones 0001–0005 | Daniel |  | — | Hecha | #17 |
| V2-T01.02 | El esqueleto `lib/nucleo` + `lib/modulos` | Daniel |  | V2-T01.01 | Hecha | #34 |
| V2-T01.03 | Navegación declarativa con deep links | Daniel |  | V2-T01.02 | Hecha | #39 |
| V2-T01.04 | Flavors `desarrollo`, `pruebas` y `produccion` | Daniel |  | V2-T01.02 | Hecha | #78 |
| V2-T01.05 | Migrar módulo por módulo sin romper v1 | Daniel |  | V2-T01.03 | Hecha | #75 |
| V2-T01.06 | Reglas de dependencia entre módulos verificadas | Daniel |  | V2-T01.02 | Hecha | #74 |
| V2-T01.07 | Retirar el código v1 al terminar H2 | Daniel |  | H2 | Lista | |
| V2-T01.08 | Un núcleo de datos común (errores, cinco estados, fakes) | Jael |  | V2-T01.02 | Lista | |
| V2-T02.01 | Los tokens v2 en código | Cristian |  | V2-T01.02 | Hecha | #16 |
| V2-T02.02 | La tipografía v2 empaquetada | Cristian |  | V2-T02.01 | Lista | |
| V2-T02.03 | Movimiento consistente | Cristian |  | V2-T02.01 | Hecha | #18 |
| V2-T02.04 | Los componentes base | Cristian |  | V2-T02.01 | Hecha | #19, #22, #23, #24 |
| V2-T02.05 | Los componentes compuestos | Cristian |  | V2-T02.04 | Hecha | #31, #33, #37, #41 |
| V2-T02.06 | Una galería del sistema dentro de la app | Cristian |  | V2-T02.05, V2-T02.13, V2-T02.14 | Hecha | #43 |
| V2-T02.07 | Íconos, logo, ícono de app y splash nuevos | Cristian |  | V2-T02.01 | Lista | |
| V2-T02.08 | Retirar `shadcn_ui` y la paleta v1 | Cristian |  | V2-T01.07 | Lista | |
| V2-T02.09 | Componente `Mapa` | Cristian |  | V2-T02.04 | Lista | |
| V2-T02.10 | Componente `Grafica` con tabla accesible | Cristian |  | V2-T02.04 | Hecha | #27 |
| V2-T02.11 | Componente `DeslizarParaConfirmar` | Cristian |  | V2-T02.04 | Hecha | #26 |
| V2-T02.12 | Componentes `GaleriaFotos` y `Firma` | Cristian |  | V2-T02.04 | Hecha | #28 |
| V2-T02.13 | Componente `LineaDeTiempo` | Cristian |  | V2-T02.04 | Hecha | #37, #42 |
| V2-T02.14 | Componentes `Calendario` y `SelectorFranja` | Cristian |  | V2-T02.04 | Hecha | #37 |
| V2-T02.15 | Componentes `BurbujaMensaje` y `CampoMensaje` | Daniel |  | V2-T02.04 | Hecha | #83 |
| V2-T02.16 | Estilo vidrio líquido y píldora en componentes y login | Daniel |  | V2-T02.04 | En revisión | #95 |
| V2-T03.01 | Reglas de análisis más estrictas | Haziel |  | — | Lista | |
| V2-T03.02 | Pruebas golden | Haziel |  | V2-T02.01 | Lista | |
| V2-T03.03 | `integration_test` del flujo principal | Haziel |  | V2-T01.03 | Lista | |
| V2-T03.04 | Cobertura visible | Haziel |  | — | Lista | |
| V2-T03.05 | Que cada criterio de aceptación tenga su prueba | Haziel |  | — | Lista | |
| V2-T03.06 | Que la API simulada siga al contrato v2 | Haziel |  | V2-T05.02 | Lista | |
| V2-T03.07 | Pruebas en celular físico por hito | Haziel |  | — | Lista | |
| V2-T03.08 | API simulada partida por módulo | Haziel |  | — | Lista | |
| V2-T04.01 | Versión automática | Daniel |  | — | Hecha | #40 |
| V2-T04.02 | Firmar builds en CI sin secretos en el repo | Daniel |  | V2-T04.01 | Lista | |
| V2-T04.03 | Un APK/IPA de prueba por cada merge a `main` | Daniel |  | V2-T04.02 | Lista | #72, #73 (avance: IPA sin firmar para sideload, [guía](../docs/guia-instalar-ios-sin-mac.md)) |
| V2-T04.04 | El check `Autoría` requerido | Daniel |  | — | Hecha | (V2-H0.03) |
| V2-T04.05 | Notas de versión automáticas | Daniel |  | V2-T04.01 | Lista | |
| V2-T04.06 | Publicar en pista interna de Google Play y App Store | Daniel |  | H6 | Lista | |
| V2-T05.01 | Módulos Modulith nuevos | Ricardo | B | — | Hecha | backend#83, #89 |
| V2-T05.02 | El contrato `agencia360-api-app-v2.yaml` | Ricardo | B | — | Hecha | backend#75, #79 |
| V2-T05.03 | `cuenta_app.usuario` como en la ficha | Ricardo | B | — | Hecha | backend#82, #88 |
| V2-T05.04 | `token_recuperacion` como en la ficha | Ricardo | B | — | Hecha | backend#82, #88 |
| V2-T05.05 | `manual.archivo_pdf` como en la ficha | Ricardo | B | — | Hecha | backend#82, #88 |
| V2-T05.06 | `orden_servicio` y `orden_refaccion` como en la ficha | Ricardo | B | — | Hecha | backend#81, #87 |
| V2-T05.07 | `franja_horario` como en la ficha | Ricardo | B | — | Hecha | backend#80, #85 |
| V2-T05.08 | Eventos en vivo | Ricardo | B | V2-T05.01 | Hecha | backend#83, #89 |
| V2-T05.09 | Almacenamiento de archivos | Ricardo | B | — | Hecha | backend#83, #89 |
| V2-T05.10 | Datos de ejemplo | Ricardo | B | — | Lista | |
| V2-T05.11 | Desplegar la API en Azure automáticamente en cada merge | Daniel | B | — | Hecha | backend#71 |

## H2 · Núcleo de la ficha (secciones 1–3)

| ID | Historia | Dueño | B | Depende de | Estado | PR |
| --- | --- | --- | --- | --- | --- | --- |
| V2-M01.01 | Iniciar sesión con la cuenta que me dio la agencia | Jael |  | V2-T01.02, V2-T02.04 | Lista | |
| V2-M01.02 | Ver una bienvenida la primera vez | Jael |  | V2-T02.04 | Lista | |
| V2-M01.03 | Cambiar obligatoriamente la contraseña temporal | Jael |  | V2-M01.01 | Lista | |
| V2-M01.04 | Recuperar mi contraseña con un enlace de un solo uso enviado a mi correo | Jael | B | V2-T05.04 (simulable), V2-T01.03 | Lista | |
| V2-M01.05 | Desbloquear con huella o rostro | Jael |  | V2-M01.01 | Lista | |
| V2-M01.06 | Ver mi perfil | Jael |  | V2-M01.01 | Lista | |
| V2-M01.07 | Editar mi teléfono y correo | Jael | B | V2-M01.06, V2-T05.03 (simulable) | Lista | |
| V2-M01.08 | Saber por qué no puedo entrar | Jael |  | V2-M01.01 | Lista | |
| V2-M01.09 | Ver y cerrar mis sesiones abiertas en otros celulares | Jael | B | V2-M01.01 | Lista | |
| V2-M01.10 | Cambiar mi contraseña desde Seguridad cuando yo quiera | Jael |  | V2-M01.03 | Lista | |
| V2-M01.11 | Que la sesión se renueve sola durante 30 días | Jael |  | V2-M01.01 | Lista | |
| V2-M01.12 | Que el primer inicio de sesión espere al servidor dormido | Daniel |  | V2-M01.01 | Hecha | #50 |
| V2-M02.01 | Ver mi garaje con todos mis vehículos | Juan Pablo |  | V2-T01.02, V2-T02.05 (provisional) | Hecha | #54 |
| V2-M02.02 | El detalle de un vehículo | Juan Pablo |  | V2-M02.01, V2-T05.06 (simulable) | Hecha | #57 |
| V2-M02.03 | Abrir el manual de mi modelo y año | Juan Pablo |  | V2-M02.02 | En revisión | #65 |
| V2-M02.04 | La ficha técnica de mi vehículo | Juan Pablo | B | V2-M02.02 | Hecha | #65, backend#70 |
| V2-M02.05 | El historial de servicios de mi auto | Ricardo | B | V2-T05.06 (simulable), V2-T02.13 (provisional) | Hecha | backend#85, #92 |
| V2-M02.06 | El ticket de cada servicio | Ricardo |  | V2-M02.05 | Hecha | backend#85, #92 |
| V2-M02.07 | Ver la disponibilidad del taller en un calendario | Juan Pablo |  | V2-T05.07 (simulable), V2-T02.14 (provisional) | Hecha | #55 |
| V2-M02.08 | Agendar una cita eligiendo vehículo, fecha, franja y motivo | Juan Pablo | B | V2-M02.07 | Hecha | #58, backend#70 |
| V2-M02.09 | Ver mis citas próximas y pasadas con su estado | Juan Pablo |  | V2-M02.08 | Hecha | #65 |
| V2-M02.10 | Cancelar una cita desde la app | Juan Pablo |  | V2-M02.09 | Hecha | #65 |
| V2-M02.11 | Un comprobante con QR de mi cita | Juan Pablo | B | V2-M02.08 | Hecha | #65, backend#70 |
| V2-M02.12 | Agregar la cita a mi calendario del teléfono | Juan Pablo |  | V2-M02.08, V2-M27.02 | Lista | |
| V2-M02.13 | Reprogramar una cita sin cancelarla | Juan Pablo | B | V2-M02.10 | Hecha | #65, backend#70 |
| V2-M03.01 | Ver el catálogo de modelos actuales | Cristian |  | V2-T02.05 (provisional) | Hecha | #45 |
| V2-M03.02 | El detalle de un modelo con galería y versiones | Cristian | B | V2-M03.01 | Hecha | #62, backend#68 |
| V2-M03.03 | Comparar dos o tres modelos lado a lado | Cristian |  | V2-M03.02 | Hecha | #63 |
| V2-M03.04 | Calcular cuánto me darían por mi auto a cuenta de uno nuevo | Cristian | B | V2-M03.01 | Hecha | #64, backend#69 |
| V2-M03.05 | Ver la diferencia a pagar contra el modelo que me gustó | Cristian |  | V2-M03.04 | Hecha | #66 |
| V2-M03.06 | Que la estimación salga de parámetros que puedo ajustar | Cristian | B | V2-M03.04 | Hecha | #91, backend#84 |
| V2-M03.07 | Guardar y volver a ver mis estimaciones | Cristian | B | V2-M03.04 | Hecha | #67, #90, backend#69 |
| V2-M20.01 | Textos fuera del código | Cristian |  | V2-T01.02 | Hecha | #49, #60 |
| V2-M20.02 | Entender cada pantalla | Cristian |  | V2-T02.05 | Lista | |
| V2-M20.03 | Que nada se corte | Cristian |  | V2-T02.05 | Lista | |
| V2-M20.04 | Animaciones reducidas | Cristian |  | V2-T02.03 | Hecha | #29 |
| V2-M20.05 | La app en inglés | Cristian |  | V2-M20.01 | Hecha | #61 |
| V2-M20.06 | Contraste AA garantizado | Cristian |  | V2-T02.01 | Hecha | #30 |
| V2-M20.07 | Una auditoría WCAG 2.2 AA | Cristian |  | H6 | Lista | |
| V2-M20.08 | Objetivos táctiles cómodos | Cristian |  | V2-T02.05 | Lista | |
| V2-M21.01 | Una base local | Jael |  | V2-T01.02 | Lista | |
| V2-M21.02 | Ver vehículos, historial, citas y documentos | Jael |  | V2-M21.01 | Lista | |
| V2-M21.03 | Que mis acciones se envíen al volver la conexión | Jael | B | V2-M21.01 | Lista | |
| V2-M21.04 | Saber si estoy sin conexión | Jael |  | V2-T02.05 (provisional) | Lista | |
| V2-M21.05 | Resolver conflictos de forma predecible | Jael | B | V2-M21.03 | Lista | |
| V2-M21.06 | Que la app sincronice en segundo plano | Jael |  | V2-M21.02 | Lista | |
| V2-M22.01 | Leer el aviso de privacidad real | Daniel | B | V2-M01.01 | Lista | |
| V2-M22.02 | Descargar mis datos (acceso ARCO) | Daniel | B | V2-M01.06 | Lista | |
| V2-M22.03 | Pedir que borren mi cuenta (cancelación ARCO) | Daniel | B | V2-M01.06 | Lista | |
| V2-M22.04 | Fijar certificados del servidor | Daniel |  | V2-T04.02 | Lista | |
| V2-M22.05 | Detectar equipos comprometidos | Daniel |  | — | Hecha | #76 |
| V2-M22.06 | Ocultar datos en el selector de apps | Daniel |  | — | Hecha | #77 |
| V2-M22.07 | Logs sin datos personales | Daniel |  | V2-T03.01 | Lista | |
| V2-M22.08 | Una revisión MASVS L1 | Daniel |  | H6 | Lista | |
| V2-M22.09 | HTTPS fuera de local | Daniel |  | V2-T04.01 | Lista | |
| V2-M23.01 | Reportes de crashes y errores | Haziel |  | V2-T04.02 | Lista | |
| V2-M23.02 | Un catálogo de eventos de producto | Haziel |  | — | Lista | |
| V2-M23.03 | Medir el embudo de citas | Haziel |  | V2-M23.02, V2-M02.08 | Lista | |
| V2-M23.04 | Decidir si comparto analítica | Haziel |  | V2-M23.02 | Lista | |
| V2-M23.05 | Medir rendimiento | Haziel |  | V2-M23.01 | Lista | |
| V2-M23.06 | Un tablero de objetivos | Haziel | B | V2-M23.03 | Lista | |

## H3 · Postventa viva

| ID | Historia | Dueño | B | Depende de | Estado | PR |
| --- | --- | --- | --- | --- | --- | --- |
| V2-M04.01 | Ver en Inicio que mi auto está en el taller | Ricardo | B | V2-M02.05 | Lista | |
| V2-M04.02 | La línea de tiempo de mi orden con la hora de cada etapa | Ricardo | B | V2-M04.01, V2-T02.13 (provisional) | Lista | |
| V2-M04.03 | Que la línea de tiempo se actualice sola | Ricardo | B | V2-M04.02, V2-M06.02 | Lista | |
| V2-M04.04 | Ver la inspección multipunto con fotos | Ricardo | B | V2-M04.02 | Lista | |
| V2-M04.05 | Aprobar o rechazar trabajos adicionales desde la app | Ricardo | B | V2-M04.02 | Lista | |
| V2-M04.06 | Saber cuándo mi auto está listo | Ricardo | B | V2-M04.03 | Lista | |
| V2-M04.07 | Que la orden cerrada pase a mi historial con su ticket | Ricardo | B | V2-M04.06 | Lista | |
| V2-M05.01 | Ver el plan de mantenimiento de mi modelo | Juan Pablo | B | V2-M02.05 | Lista | |
| V2-M05.02 | Saber cuándo toca mi próximo servicio | Juan Pablo | B | V2-M05.01 | Lista | |
| V2-M05.03 | Registrar mi kilometraje actual | Juan Pablo | B | V2-M05.02 | Lista | |
| V2-M05.04 | Agendar el servicio recomendado en un toque | Juan Pablo |  | V2-M05.02, V2-M02.08 | Lista | |
| V2-M05.05 | Un recordatorio cuando se acerque mi servicio | Juan Pablo | B | V2-M06.02 | Lista | |
| V2-M05.06 | Ver qué incluye cada servicio y su precio estimado | Juan Pablo | B | V2-M05.01 | Lista | |
| V2-M06.01 | Que se me explique por qué la app pide notificaciones | Jael |  | V2-T01.03 | Lista | |
| V2-M06.02 | Recibir push de la agencia en Android e iOS | Jael | B | V2-M06.01 | Lista | |
| V2-M06.03 | Que tocar una notificación me lleve a su pantalla | Jael |  | V2-M06.02 | Lista | |
| V2-M06.04 | Una bandeja con todos mis avisos | Jael | B | V2-M06.02 | Lista | |
| V2-M06.05 | Elegir qué avisos recibir y un horario silencioso | Jael | B | V2-M06.04 | Lista | |
| V2-M06.06 | Recordatorios de cita aunque no tenga red | Jael |  | V2-M02.08 | Lista | |
| V2-M06.07 | Un servicio único de envío en el backend | Jael | B | V2-T05.01 | Lista | |
| V2-M09.01 | Ver los documentos de mi auto con su estado | Haziel | B | V2-M02.02 | Lista | |
| V2-M09.02 | Fotografiar un documento y guardarlo | Haziel | B | V2-M09.01 | Lista | |
| V2-M09.03 | Ver los documentos que me dio la agencia | Haziel | B | V2-M09.01 | Lista | |
| V2-M09.04 | Alertas antes de que venza un documento | Haziel | B | V2-M06.02 | Lista | |
| V2-M09.05 | Ver mis documentos sin conexión | Haziel |  | V2-M21.01 | Lista | |
| V2-M09.06 | Un calendario con todos mis vencimientos | Haziel |  | V2-M09.01 | Lista | |
| V2-M10.01 | Ver qué cubre mi garantía y hasta cuándo | Ricardo | B | V2-M02.02 | Lista | |
| V2-M10.02 | Saber si mi auto tiene una campaña de seguridad | Ricardo | B | V2-M02.01 | Lista | |
| V2-M10.03 | Agendar la atención de una campaña | Ricardo | B | V2-M10.02, V2-M02.08 | Lista | |
| V2-M10.04 | Un aviso cuando salga una campaña | Ricardo | B | V2-M06.02 | Lista | |
| V2-M10.05 | Saber que mi garantía está por vencer | Ricardo | B | V2-M06.02 | Lista | |

## H4 · Cliente conectado

| ID | Historia | Dueño | B | Depende de | Estado | PR |
| --- | --- | --- | --- | --- | --- | --- |
| V2-M07.01 | Escribirle a mi asesor sobre mi orden | Jael | B | V2-M04.02 | Borrador | |
| V2-M07.02 | Recibir respuestas en tiempo real | Jael | B | V2-M07.01, V2-M06.02 | Borrador | |
| V2-M07.03 | Mandar fotos y audios | Jael | B | V2-M07.01 | Borrador | |
| V2-M07.04 | Saber si mi mensaje fue leído | Jael | B | V2-M07.02 | Borrador | |
| V2-M07.05 | Escribir sin conexión y que se envíe después | Jael |  | V2-M21.03 | Borrador | |
| V2-M12.01 | Ver mis puntos y nivel | Ricardo | B | — | Borrador | |
| V2-M12.02 | Ganar puntos al pagar un servicio | Ricardo | B | V2-M04.07 | Borrador | |
| V2-M12.03 | Canjear recompensas | Ricardo | B | V2-M12.01 | Borrador | |
| V2-M12.04 | Referir a un amigo | Ricardo | B | V2-M12.01 | Borrador | |
| V2-M12.05 | Ver mis movimientos de puntos | Ricardo | B | V2-M12.01 | Borrador | |
| V2-M13.01 | Ver promociones que apliquen a mi auto | Haziel | B | V2-M02.01 | Borrador | |
| V2-M13.02 | Usar una promoción al agendar | Haziel | B | V2-M13.01, V2-M02.08 | Borrador | |
| V2-M13.03 | Ver novedades de la agencia | Haziel | B | — | Borrador | |
| V2-M13.04 | Saber qué promociones funcionan | Haziel | B | V2-M13.01 | Borrador | |
| V2-M15.01 | Calificar mi servicio al recogerlo | Haziel | B | V2-M04.07 | Lista | |
| V2-M15.02 | Que me contacten | Haziel | B | V2-M15.01 | Lista | |
| V2-M15.03 | Ver la respuesta de la agencia | Haziel | B | V2-M06.04 | Lista | |
| V2-M15.04 | El NPS por periodo y asesor | Haziel | B | V2-M15.01 | Lista | |
| V2-M27.01 | Buscar en preguntas frecuentes | Haziel | B | — | Lista | |
| V2-M27.02 | Ver sucursales en un mapa con horarios | Haziel | B | — | Lista | |
| V2-M27.03 | Contactar a la agencia por el medio que prefiera | Haziel |  | V2-M27.02 | Lista | |
| V2-M27.04 | Reportar un problema de la app | Haziel | B | — | Lista | |
| V2-M27.05 | Ver la versión, licencias y términos | Haziel |  | — | Lista | |

## H5 · Comercio

| ID | Historia | Dueño | B | Depende de | Estado | PR |
| --- | --- | --- | --- | --- | --- | --- |
| V2-M08.01 | Elegir el procesador de pagos | Ricardo |  | — | Borrador | |
| V2-M08.02 | Pagar mi orden con tarjeta desde la app | Ricardo | B | V2-M08.01, V2-M04.06 | Borrador | |
| V2-M08.03 | Pagar con Apple Pay o Google Pay | Ricardo | B | V2-M08.02 | Borrador | |
| V2-M08.04 | Guardar mis tarjetas | Ricardo | B | V2-M08.02 | Borrador | |
| V2-M08.05 | Capturar mis datos fiscales | Ricardo | B | — | Borrador | |
| V2-M08.06 | Descargar mi factura PDF y XML | Ricardo | B | V2-M08.05 | Borrador | |
| V2-M08.07 | Ver todos mis pagos | Ricardo | B | V2-M08.02 | Borrador | |
| V2-M14.01 | Ver accesorios compatibles con mi auto | Cristian | B | V2-M02.01 | Borrador | |
| V2-M14.02 | Apartar productos | Cristian | B | V2-M14.01 | Borrador | |
| V2-M14.03 | Que me instalen lo comprado en mi cita | Cristian | B | V2-M14.02, V2-M02.08 | Borrador | |
| V2-M14.04 | Pagar mi pedido en la app | Cristian | B | V2-M08.02 | Borrador | |
| V2-M14.05 | Seguir mis pedidos | Cristian | B | V2-M06.02 | Borrador | |
| V2-M16.01 | Pedir una prueba de manejo | Daniel | B | V2-M03.02 | Borrador | |
| V2-M16.02 | Cotizar un auto nuevo con mensualidad estimada | Daniel | B | V2-M03.02 | Borrador | |
| V2-M16.03 | Adjuntar mi estimación de toma a cuenta | Daniel | B | V2-M03.07 | Borrador | |
| V2-M16.04 | Ver el estado de mis solicitudes | Daniel | B | V2-M16.01 | Borrador | |
| V2-M17.01 | Guardar mis direcciones | Juan Pablo | B | V2-T02.09 (provisional) | En revisión | #94, backend#86 |
| V2-M17.02 | Pedir recolección al agendar | Juan Pablo | B | V2-M02.08, V2-M17.01 | En revisión | #94, backend#86 |
| V2-M17.03 | Seguir al chofer | Juan Pablo | B | V2-M17.02, V2-M06.02, V2-T02.09 (provisional), V2-T02.13 (provisional) | Lista | |
| V2-M17.04 | El checklist con fotos del estado de mi auto | Juan Pablo | B | V2-M17.03, V2-T05.09 (simulable), V2-T02.12 | Lista | |
| V2-M26.01 | Pedir una valuación formal desde mi estimación | Cristian | B | V2-M03.07 | Borrador | |
| V2-M26.02 | Subir fotos guiadas de mi auto | Cristian | B | V2-M26.01 | Borrador | |
| V2-M26.03 | Agendar la inspección física | Cristian | B | V2-M26.01, V2-M02.08 | Borrador | |
| V2-M26.04 | Recibir la oferta y aceptarla o rechazarla | Cristian | B | V2-M26.03 | Borrador | |
| V2-M26.05 | Ver cómo cambia el valor de mi auto con el tiempo | Cristian | B | V2-M03.04 | Borrador | |

## H6 · Inteligencia y extras

| ID | Historia | Dueño | B | Depende de | Estado | PR |
| --- | --- | --- | --- | --- | --- | --- |
| V2-M11.01 | Pedir ayuda con mi ubicación | Juan Pablo | B | V2-M02.01, V2-T02.11 | En revisión | #94, backend#86 |
| V2-M11.02 | Llamar rápido a mi aseguradora o a la agencia | Juan Pablo |  | V2-M09.01, V2-M27.02 | Lista | |
| V2-M11.03 | Guías de emergencia sin conexión | Juan Pablo |  | — | Hecha | #65 |
| V2-M11.04 | Ver el estado de mi solicitud | Juan Pablo | B | V2-M11.01, V2-M06.02, V2-T02.13 (provisional) | Lista | |
| V2-M18.01 | Registrar una carga de gasolina | Juan Pablo | B | V2-M05.03 | Lista | |
| V2-M18.02 | Llenar la carga desde la foto del ticket | Juan Pablo |  | V2-M18.01 | Lista | |
| V2-M18.03 | Ver mi rendimiento y gasto | Juan Pablo |  | V2-M18.01, V2-T02.10 | Lista | |
| V2-M18.04 | Registrar otros gastos | Juan Pablo | B | V2-M18.01 | Lista | |
| V2-M18.05 | Exportar mi bitácora | Juan Pablo |  | V2-M18.03 | Lista | |
| V2-M19.01 | Invitar a alguien a ver mi vehículo | Jael | B | V2-M01.04 | Borrador | |
| V2-M19.02 | Aceptar y ver el vehículo compartido | Jael | B | V2-M19.01 | Borrador | |
| V2-M19.03 | Limitar lo que puede hacer el invitado | Jael | B | V2-M19.02 | Borrador | |
| V2-M19.04 | Revocar un acceso | Jael | B | V2-M19.02 | Borrador | |
| V2-M24.01 | Elegir el proveedor de modelo y la arquitectura RAG | Daniel |  | — | Hecha | #81 |
| V2-M24.02 | Indexar los manuales por página | Daniel | B | V2-M24.01, V2-T05.05 | Hecha | backend#79, #84 |
| V2-M24.03 | Preguntar algo de mi auto y recibir una respuesta citada | Daniel | B | V2-M24.02 (simulable), V2-T02.15 (provisional) | Hecha | backend#79, #84 |
| V2-M24.04 | Abrir el manual en la página citada | Daniel |  | V2-M24.03, V2-M02.03 | Lista | |
| V2-M24.05 | Fotografiar una luz del tablero y saber qué significa | Daniel | B | V2-M24.01, V2-T02.15 (provisional) | Lista | |
| V2-M24.06 | Agendar desde la respuesta | Daniel |  | V2-M24.03, V2-M02.08 | Hecha | #97 |
| V2-M24.07 | Medir la calidad de respuestas | Daniel | B | V2-M24.03 | Hecha | #100, backend#87 |
| V2-M24.08 | Ver preguntas sugeridas | Daniel |  | V2-M24.03 | Hecha | #96 |
| V2-M24.09 | Ver la respuesta mientras se escribe | Daniel | B | V2-M24.03 | Lista | |
| V2-M25.01 | Un widget con mi próxima cita | Juan Pablo |  | V2-M02.09, V2-T01.03 | Hecha | #68 |
| V2-M25.02 | Ver en el widget el estado de mi auto en el taller | Juan Pablo |  | V2-M04.02, V2-M25.01 | Lista | |
| V2-M25.03 | Guardar mi cita en Wallet | Juan Pablo | B | V2-M02.11 | Hecha | #71, backend#73 |
| V2-M25.04 | Accesos rápidos desde el ícono | Juan Pablo |  | V2-T01.03 | Hecha | #65 |
| V2-M25.05 | Ver el estado del taller en la pantalla bloqueada | Juan Pablo | B | V2-M04.03 | Lista | |

## H7 · Lista para tiendas

Se llena con las historias de endurecimiento que salgan de M20.07, M22.08, M23.06 y T04.06, más los hallazgos de las pruebas en celular de cada hito.
