# Fijar los certificados del servidor (V2-M22.04)

Historia [V2-M22.04](../../plan/modulos/M22-seguridad-y-privacidad.md). Controles MASVS relacionados: MSTG-NETWORK-3 (L1: verificar el certificado del servidor) y, como refuerzo, MSTG-NETWORK-4 (L2: fijarlo). Código: [`lib/config/pines_tls.dart`](../../lib/config/pines_tls.dart), [`lib/api/cliente_http_fijado.dart`](../../lib/api/cliente_http_fijado.dart).

## Qué protege

En `pruebas` y `produccion` la app **no confía en los ~150 certificados raíz del teléfono**: solo en cinco, las raíces de la jerarquía pública de TLS de Azure, que es donde vive el backend. Un certificado emitido por cualquier otra autoridad, o instalado en el teléfono por un tercero (un proxy de empresa, un programa malicioso), no sirve para espiar ni modificar lo que la app habla con el servidor: la conexión simplemente no se establece.

Sigue verificando todo lo demás: que el certificado sea del servidor al que se conecta y que no haya vencido. Lo único que cambia es quién puede firmarlo.

## Cómo funciona

| Flavor | ¿Fija? | Por qué |
| --- | --- | --- |
| `desarrollo` | no | Habla `http` con el simulador (`mock_api`): no hay TLS que fijar. |
| `pruebas` | sí | Es **el canario de los pines**: el APK `prueba-main` sale en cada merge a `main`, así que un pin roto se nota ahí antes de que llegue a `produccion`. |
| `produccion` | sí | — |

- **Mecanismo.** Un `SecurityContext(withTrustedRoots: false)` con solo las anclas. El cliente HTTP de la API y el de la descarga de manuales usan ese contexto (`clienteHttpDelAmbiente`, y `ClienteApi` sin cliente propio). `decidirConfianza` toma la decisión: flavor, esquema y host.
- **Falla cerrado.** Un flavor que fija con una dirección `https` **sin anclas** no arranca: la app muestra el error de arranque (`ConfianzaTlsInvalida`) en vez de conectarse sin fijar sin que nadie lo note. Un PEM roto o una lista vacía hacen lo mismo.
- **Depurar con un proxy.** `--dart-define=FIJAR_CERTIFICADOS=false` quita los pines **solo fuera de release**; en release se ignora, y una prueba lo comprueba. No hay forma de apagarlos en una app publicada.
- **Un fallo de pines se ve como «sin conexión».** El apretón de manos TLS falla con `HandshakeException` y `ClienteApi` lo traduce a `SinConexion`, con esa causa dentro. Para diagnosticar: la consola de una compilación de depuración y, sobre todo, la vigilancia semanal (abajo).

## Qué se fija, y por qué raíces

| Ancla | Papel | SHA-256 | Vence |
| --- | --- | --- | --- |
| Microsoft TLS RSA Root G2 | **La de hoy.** El servidor la manda con firma cruzada de DigiCert; la autofirmada también valida. | `6a170583…e9e5` | 2040-04-10 |
| DigiCert Global Root G2 | La que firma de forma cruzada a la anterior y la que usaba la jerarquía previa de Azure. | `cb3ccbb7…cb5f` | 2038-01-15 |
| Microsoft TLS ECC Root G2 | Respaldo: variante ECC de la jerarquía nueva. | `87755cfe…e8a7` | 2040-04-10 |
| Microsoft RSA Root Certificate Authority 2017 | Respaldo: la jerarquía anterior de Microsoft. | `c741f70f…73e0` | 2042-07-18 |
| Microsoft ECC Root Certificate Authority 2017 | Respaldo: su variante ECC. | `358df39d…ba02` | 2042-07-18 |

Las huellas completas están en `pines_tls.dart` y una prueba comprueba que son las de los certificados incluidos.

**Por qué raíces y no el certificado del servidor ni su intermedio.** Azure renueva el certificado del servidor cada pocos meses y cambia de intermedio sin avisar. La cadena de hoy es:

```text
calmcliff-d0e7fc3b.eastus2.azurecontainerapps.io        (el servidor, se renueva)
  └─ Microsoft TLS G2 RSA CA OCSP 16                     (intermedio, hay varios y rotan)
       └─ Microsoft TLS RSA Root G2                      (raíz, hasta 2040)
            └─ DigiCert Global Root G2                   (firma cruzada, hasta 2038)
```

Fijar el servidor o el intermedio rompería la app en cada renovación. Las raíces duran hasta 2038–2042. Por eso hay varias: si Microsoft cambia de jerarquía, la app ya confía en la nueva y no hace falta publicar una versión de urgencia.

**Lo que se concede.** Fijar raíces es más amplio que fijar un certificado: sirve cualquier certificado que una de esas cinco autoridades emita **para el nombre del servidor**. Es lo que se acepta a cambio de no romperse con cada renovación; la validación por nombre impide usar con nuestro servidor un certificado que la misma autoridad emitió para otro.

## Evidencia: cómo se verificó

- **Las raíces de Microsoft** se bajaron de `microsoft.com/pkiops/certs/` (los enlaces de su [repositorio PKI](https://www.microsoft.com/pkiops/docs/repository.htm)) y su huella SHA-1 coincide con la que publica esa página: `21734d95…`, `f82bb951…`, `999a64c3…`, `73a5e64a…`. Son autofirmadas.
- **DigiCert Global Root G2** se bajó de `cacerts.digicert.com` y es idéntica, byte a byte, a la del almacén de raíces de Mozilla que trae Linux. (La página de DigiCert no se pudo leer de forma automática, así que esa huella no se cotejó contra su texto.)
- **Contra el servidor real**, con `openssl s_client -CAfile <solo las anclas> -no-CApath`: valida con las cinco juntas, con solo `Microsoft TLS RSA Root G2` y con solo `DigiCert Global Root G2`, y **falla** con solo las de 2017 o solo las ECC. Es decir, el pin es selectivo y no acepta cualquier cosa.
- **Con el mismo código de la app**: una petición sin sesión al backend real (debe dar 401) con cada ancla sola y con las cinco. Mismo resultado que `openssl`; con las cinco, `HTTP 401` en ~200 ms, igual que con la tienda del sistema.
- **Pruebas** (`test/api/cliente_http_fijado_test.dart`): con una autoridad de prueba creada con `openssl`, conecta si el servidor es de la autoridad fijada y **no** si es de otra, ni con la tienda del sistema, ni a un nombre que el certificado no cubre; y fijar deja fuera los certificados del teléfono (un servidor público no valida). Mutaciones: 19 al código nuevo, todas atrapadas (tres sobrevivían y se reforzaron las pruebas).
- **Nota para quien pruebe:** el backend escala a cero; la primera petición tras un rato puede tardar más de 20 s (arranque en frío). No es un problema de los pines.

## Vigilancia

[`scripts/verificar-pines-tls.sh`](../../scripts/verificar-pines-tls.sh) comprueba, sin credenciales (solo abre una conexión TLS pública):

1. que los certificados de `pines_tls.dart` se lean y que cada huella declarada sea la del certificado;
2. que ninguno venza pronto: **aviso a 18 meses, fallo a 6**;
3. que el servidor real valide **solo** contra esas anclas, como lo hace la app.

Corre **cada semana** y a mano ([`pines-tls.yml`](../../.github/workflows/pines-tls.yml)), y en cada PR que toque los pines o el host: así no se integran pines que el servidor real no valida. Si falla, Actions lo marca en rojo y avisa por correo a quien tocó por última vez el horario del flujo. Local: `./scripts/verificar-pines-tls.sh [host]`.

## Plan de rotación

Regla de fondo: **siempre al menos dos anclas de jerarquías distintas, y nunca una versión cuyos pines no validen al servidor real** (lo garantiza la vigilancia en el PR).

| Situación | Qué se hace |
| --- | --- |
| **Microsoft anuncia una raíz nueva** (lo avisa con meses: «Azure TLS certificate changes») | 1. Bajar el `.crt` del repositorio PKI de Microsoft y comprobar su huella con la que publican. 2. Agregarlo a `anclasAzure` con su nombre, SHA-256, vencimiento y una línea de por qué. 3. `./scripts/verificar-pines-tls.sh`. 4. PR y versión nueva. 5. Esperar a que la versión esté instalada antes de la fecha en que Azure cambia. |
| **Una ancla se acerca a su vencimiento** (el aviso de 18 meses) | Agregar su reemplazo como arriba; quitar la vieja en una versión posterior, cuando ya ninguna cadena la use. |
| **Se retira una ancla** | Solo después de dos versiones desde que ninguna cadena del servidor la usa; nunca en la misma versión en que se agrega su reemplazo. |
| **Cambia el dominio o el hosting** (dominio propio, otro proveedor) | Agregar el grupo de anclas y el dominio en `anclasPara` **antes** de cambiar el DNS, y publicar esa versión primero. Sin anclas para el host, la app no arranca (a propósito). |

## Si algo se rompe

Síntoma: la app dice que no hay conexión y la vigilancia semanal está en rojo (o los pines no validan al servidor).

1. **Confirmar**: `./scripts/verificar-pines-tls.sh`. Muestra la cadena que presenta el servidor hoy y por qué no valida.
2. **Si el servidor cambió de jerarquía**: agregar la raíz nueva (fila 1 del plan de rotación) y publicar. El APK de `pruebas` sale en el merge; las versiones de `produccion`, con una etiqueta.
3. **Mientras llega la versión**: los usuarios con la versión rota no se conectan hasta actualizar (hoy se instala a mano: GitHub Releases y Sideloadly en iOS). Si hay una forma de que el servidor presente una cadena que la versión vieja valide (otro certificado de la jerarquía anterior), se hace.
4. **No hay interruptor remoto** a propósito: un interruptor que apague los pines tendría que bajarse por la misma conexión que se pretende proteger.

## Límites

- **Solo cubre el cliente `http` de la app**: la API y la descarga de manuales. Las imágenes que Flutter baja con `NetworkImage` (catálogo, evidencias del taller), Firebase y los plugins nativos usan la tienda del sistema. Fijarlas es otra historia (un proveedor de imágenes que use el cliente fijado).
- **No frena a quien controla el teléfono.** En un equipo con root o con jailbreak un atacante puede saltarse los pines con herramientas de instrumentación; eso lo atiende V2-M22.05 (avisar de equipos comprometidos), no esta historia.
- **No probado todavía en un teléfono.** Las pruebas y la conexión real se hicieron desde Linux con el mismo código y la misma biblioteca TLS (BoringSSL) que usa Dart en Android e iOS, pero **falta instalar el APK de `pruebas` y entrar**. Por eso la historia queda en 🟡 hasta esa demostración. Es el paso que hay que dar antes de etiquetar una versión de `produccion`.
- **La vigilancia no prueba la app**, prueba el servidor contra las anclas. Si alguien cambia el código del cliente, lo cubren las pruebas.
- **Un fallo de pines no tiene mensaje propio**: se ve como «sin conexión». Un mensaje que distinga «no pude verificar que la conexión sea segura» queda como mejora.
