# Instalar CareCar en un iPhone sin Mac (Windows + Sideloadly)

Guía para probar la app en un iPhone real **sin Mac y sin cuenta de Apple Developer**, solo con una PC con Windows y un Apple ID gratis.

**Por qué así.** En el equipo hay un solo iPhone y nadie tiene Mac ni la membresía de pago de Apple (99 USD al año), así que TestFlight (el camino de V2-T04.03) no está disponible por ahora. GitHub Actions compila un IPA **sin firmar** en un runner de macOS, y Sideloadly lo firma en tu PC con tu Apple ID y lo instala por cable. Es para pruebas internas; no sirve para distribuir a clientes.

| Paso | Dónde | Una sola vez |
| --- | --- | --- |
| 1. Generar y descargar el IPA | GitHub, en el navegador | No: cada vez que quieras una versión nueva |
| 2. Preparar Windows (iTunes, iCloud, Sideloadly) | PC | Sí |
| 3. Firmar e instalar con tu Apple ID | PC + iPhone por cable | No: cada instalación o refirma |
| 4. Modo desarrollador y confiar en el perfil | iPhone | Sí (el perfil, otra vez si cambias de Apple ID) |
| 5. Refirmar antes de 7 días | PC + iPhone | No: cada semana |

---

## 1. Generar el IPA y descargarlo

El workflow **IPA sin firma** ([`.github/workflows/ipa-sin-firma.yml`](../.github/workflows/ipa-sin-firma.yml)) no corre solo: los minutos de macOS son caros, así que se lanza a mano.

1. Abre el repositorio en GitHub con tu cuenta (debe tener acceso a `lattice-systems/carecar-mobile`).
2. Pestaña **Actions** → en la lista de la izquierda, **IPA sin firma**.
3. Botón **Run workflow** → deja la rama **main** → **Run workflow**.
4. Espera a que la corrida termine en verde (unos 5 minutos). El IPA es del flavor `produccion` (CareCar, bundle id `com.carecar.carecarMobile`).
5. Entra a la corrida y baja hasta **Artifacts**. Haz clic en `carecar-vX.Y.Z-build<n>.ipa`: se descarga el `.ipa` directo (unos 30 MB), sin zip alrededor.

El artefacto dura **30 días**. Cada versión etiquetada (`vX.Y.Z`) también trae su IPA en **Releases** (`carecar-vX.Y.Z.ipa`), junto al APK, unos minutos después de publicarse. Eso último solo pasa con los runners de macOS activos (hoy están en pausa, ver [`pausa-de-macos.md`](pausa-de-macos.md)); el lanzamiento a mano de arriba funciona siempre.

La app apunta al backend en Azure por HTTPS (dirección por omisión del flavor `produccion`; si existe la variable de repositorio `API_BASE_URL`, la sobrescribe y debe ser `https`). No hay que configurar nada en el teléfono.

Desde la terminal, si tienes `gh`:

```bash
gh workflow run ipa-sin-firma.yml --ref main -R lattice-systems/carecar-mobile
gh run watch -R lattice-systems/carecar-mobile          # elige la corrida
# Id y nombre del artefacto de esa corrida:
gh api repos/lattice-systems/carecar-mobile/actions/runs/<id-de-la-corrida>/artifacts \
  --jq '.artifacts[] | "\(.id) \(.name)"'
# Descarga el .ipa tal cual:
gh api repos/lattice-systems/carecar-mobile/actions/artifacts/<id-del-artefacto>/zip > carecar.ipa
```

No uses `gh run download`: trata el artefacto como zip y lo descomprime en una carpeta con el nombre del IPA, así que no obtienes el `.ipa`.

## 2. Preparar Windows (una sola vez)

Sideloadly necesita los controladores de Apple que traen iTunes e iCloud. Según la [página oficial de Sideloadly](https://sideloadly.io/), deben ser **las versiones web de Apple**, no las de Microsoft Store: _"Sideloadly requires the web version of iTunes & iCloud on Windows. If you have the Microsoft Store versions, uninstall them first."_

1. Si tienes iTunes o iCloud de **Microsoft Store**, desinstálalos (Configuración → Aplicaciones).
2. Instala **iTunes** desde Apple: [64 bits](https://www.apple.com/itunes/download/win64) (o [32 bits](https://www.apple.com/itunes/download/win32) si tu Windows es de 32).
3. Instala **iCloud** desde el enlace "Web iCloud" de [sideloadly.io](https://sideloadly.io/) (es el instalador de Apple, no el de la tienda).
4. Instala **Sideloadly** desde [sideloadly.io](https://sideloadly.io/). Funciona en Windows 7 SP1, 8, 10 y 11; recomiendan Windows 10 o más nuevo.
5. Reinicia la PC.

Sobre el Apple ID: el tuyo sirve, no hace falta pagar nada. Si prefieres no usar tu cuenta principal, puedes crear un Apple ID aparte solo para firmar; el iPhone no necesita tener esa cuenta iniciada.

## 3. Firmar e instalar con tu Apple ID

1. Conecta el iPhone a la PC **por cable** y desbloquéalo. Si pregunta **¿Confiar en esta computadora?**, toca **Confiar** y escribe tu código.
2. Abre iTunes una vez y comprueba que ve el iPhone (el icono del teléfono arriba a la izquierda). Si no lo ve, revisa el paso 2.
3. Abre **Sideloadly**. Arriba debe aparecer tu iPhone en **iDevice**.
4. Arrastra el `.ipa` a la ventana (o toca el icono de IPA y elígelo).
5. En **Apple account** escribe tu Apple ID y toca **Start**.
6. Escribe la contraseña de tu Apple ID. Si te llega un **código de verificación** (doble factor) a tus dispositivos, escríbelo cuando Sideloadly lo pida.
7. Espera a que el registro diga **Done**. El icono de CareCar aparece en el iPhone, pero todavía no abre: falta el paso 4.

**Si dice que el bundle id no está disponible** (otra cuenta ya registró `com.carecar.carecarMobile`): en Sideloadly abre **Advanced options**, activa **Change Bundle ID**, deja el que propone (o uno como `com.tunombre.carecar`) y repite. Anótalo: para actualizar o refirmar sin perder los datos hay que usar **siempre el mismo Apple ID y el mismo bundle id**.

## 4. Modo desarrollador y confiar en el perfil (iPhone)

Desde iOS 16 Apple pide el **Modo desarrollador** para abrir apps firmadas así. El interruptor aparece después de instalar la primera app con Sideloadly.

1. **Ajustes → Privacidad y seguridad → Modo de desarrollador** (está hasta abajo). Actívalo.
2. El iPhone pide **reiniciar**. Acepta.
3. Al encender, confirma **Activar** y escribe tu código.
4. **Ajustes → General → VPN y gestión de dispositivos**. En **App de desarrollador** toca tu Apple ID (el correo con el que firmaste) → **Confiar en "tu correo"** → **Confiar**.
5. Abre CareCar.

El paso 4 se repite solo si firmas con otro Apple ID.

## 5. Límites del Apple ID gratis

| Límite | Qué pasa | Qué hacer |
| --- | --- | --- |
| **7 días** | La firma vence y la app deja de abrir (se cierra al tocarla). | Refirmar antes de que venza (abajo). |
| **3 apps** | Con un Apple ID gratis puedes tener hasta 3 apps instaladas así a la vez. | Borra otra app instalada por sideload si llegas al tope. |
| **10 App IDs cada 7 días** | Cada bundle id distinto que firmas cuenta. Si cambias el bundle id muchas veces, Apple responde "You may create up to 10 App IDs every 7 days". | Usa siempre el mismo bundle id. |
| **Sin compras dentro de la app** | Las compras in-app no funcionan en apps instaladas por sideload. | La app no las usa. |

**Refirmar (cada semana) o instalar una versión nueva.** Conecta el iPhone, abre Sideloadly, carga el IPA (el mismo o uno nuevo) y toca **Start** con el **mismo Apple ID** y el **mismo bundle id**. Se instala encima y conserva los datos (la sesión iniciada incluida). Si cambias de Apple ID o de bundle id, iOS la trata como otra app: tendrás que iniciar sesión otra vez.

**Refirmar solo.** Sideloadly trae un servicio (Sideloadly Daemon) que intenta refirmar las apps cerca de vencer cuando ve el iPhone por cable o por Wi-Fi, con la PC encendida. Para Wi-Fi: conecta una vez por cable, en iTunes → el iPhone → **Resumen → Opciones** activa **Sincronizar con este iPhone por Wi-Fi**; Windows puede pedir el servicio Bonjour de Apple. Si la app ya venció, refirma a mano como arriba.

## 6. Qué funciona y qué no con un Apple ID gratis

Revisado contra el proyecto iOS actual (`ios/Runner`): **no hay archivo de entitlements** ni capacidades de pago activadas, así que el IPA se instala completo. No se cambió la configuración de iOS para esto.

| Capacidad | En la app hoy | Con Apple ID gratis |
| --- | --- | --- |
| Notificaciones **locales** (recordatorios de citas, `flutter_local_notifications`) | Sí | Funcionan. Acepta el permiso al abrir la app. |
| Enlaces `carecar://…` (restablecer contraseña) | Sí (esquema propio en `Info.plist`) | Funcionan. |
| Pase de Apple Wallet de la cita | Sí, por la hoja de compartir (`.pkpass`) | Funciona: no usa capacidades de la app; depende de que el servidor firme el pase. |
| Accesos rápidos, compartir, abrir enlaces | Sí | Funcionan. |
| Sesión guardada en el llavero (`flutter_secure_storage`) | Sí | Funciona; se pierde si refirmas con otro Apple ID o bundle id. |
| **Notificaciones push** remotas (APNs) | No las usa todavía | **No funcionarían**: una cuenta gratis no puede firmar con `aps-environment`. |
| **Widget de la próxima cita** (WidgetKit, V2-M25.01) | No viene en el IPA: la extensión aún no está en el proyecto Xcode | Cuando se agregue necesitará **App Groups** y una extensión (otro App ID); con cuenta gratis Sideloadly suele quitar la capacidad o fallar, y el widget podría no mostrar datos. |
| **Enlaces universales** (`https://…` que abren la app; Associated Domains) | No configurados | **No funcionarían** con cuenta gratis. |
| **Iniciar sesión con Apple**, iCloud, Apple Pay | No los usa | **No funcionarían** con cuenta gratis. |

Si una historia futura agrega alguna de las capacidades de la mitad de abajo, esta guía y la prueba en iPhone deben revisarse.

## 7. Problemas comunes

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| Sideloadly no ve el iPhone | iTunes/iCloud de Microsoft Store, o el iPhone no confía en la PC | Instala las versiones web (paso 2), reinicia, desbloquea el iPhone y toca **Confiar**. |
| Errores `np_client_new` o `afc_file_close` | iTunes de Microsoft Store | Desinstálalo e instala el de Apple (paso 2). |
| "Your session has expired. Please log in." | La sesión del Apple ID en Sideloadly venció | Vuelve a escribir el Apple ID y la contraseña. |
| "You may create up to 10 App IDs every 7 days" | Cambiaste muchas veces el bundle id | Espera a que pase la semana y usa siempre el mismo. |
| "Untrusted Developer" / "Desarrollador no confiable" al abrir | Falta confiar en el perfil | Paso 4.4. |
| La app no abre y no pide nada | Falta el Modo desarrollador o la firma venció | Paso 4.1 o refirma (sección 5). |
| La app abre pero dice que no hay conexión con el servidor | El IPA se compiló con otra `API_BASE_URL` (variable de repositorio) o el servidor está caído | Revisa la variable del repositorio y genera otro IPA. |

Más ayuda: [preguntas frecuentes de Sideloadly](https://sideloadly.io/faq).
