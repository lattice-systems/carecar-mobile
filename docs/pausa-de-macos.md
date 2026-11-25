# Pausa de los runners de macOS

Desde el **2026-11-25** (decisión de Daniel) los jobs que usan runners de macOS **no corren solos**. Se activan cuando el equipo los necesite, previsiblemente al terminar la app. Esta página dice qué se salta, cómo activarlo y qué hay que cuidar mientras tanto.

**Por qué.** Los minutos de macOS cuestan diez veces los de Linux y a veces GitHub no tiene runners disponibles: el job `Build iOS (sin firma)` salía `cancelled` con «job was not acquired by Runner… capacity constraints» o se quedaba pendiente en cada PR. No es un check requerido de `main`, pero ensuciaba todos los PR y gastaba minutos para validar algo que hoy casi nadie prueba (en el equipo solo hay un iPhone).

## Qué hace el interruptor

La variable de repositorio **`MACOS_ACTIVO`** (Settings → Secrets and variables → Actions → Variables) decide. Hoy vale `false`. Con cualquier valor distinto de `true`, o sin la variable, se salta todo lo de macOS:

| Workflow · job | Pausado (`MACOS_ACTIVO` distinta de `true`, hoy) | Activo (`true`) |
| --- | --- | --- |
| `CI` · `Build iOS (sin firma)` | Se salta en cada PR y en cada push a `main` (aparece «skipped») | Compila iOS sin firmar, flavors `desarrollo` y `produccion` |
| `Release` · `IPA sin firma` y `Adjuntar el IPA al Release` | Se saltan: el Release sale solo con el APK y sus notas dicen que no trae IPA | Adjunta `carecar-vX.Y.Z.ipa` al Release |
| `IPA sin firma` (`ipa-sin-firma.yml`) lanzado a mano | **Sigue disponible**: solo corre si alguien lo lanza ([guía](guia-instalar-ios-sin-mac.md)) | Igual |

Los demás checks (Formato, Análisis estático, Pruebas, Build Android, CodeQL, Revisión de dependencias, Autoría) no usan macOS y no cambian. El de iOS nunca fue requerido en `main`, así que saltarlo no bloquea ningún merge.

## Activar y volver a pausar

```bash
gh variable set MACOS_ACTIVO --body true  -R lattice-systems/carecar-mobile   # activar
gh variable set MACOS_ACTIVO --body false -R lattice-systems/carecar-mobile   # pausar otra vez
gh variable list -R lattice-systems/carecar-mobile                            # ver el estado
```

Surte efecto en la siguiente corrida: no hay que cambiar código ni abrir un PR. Hace falta permiso de administración sobre el repositorio.

## Qué se pierde mientras está pausado

- **Nadie compila iOS en los PR.** Un cambio que lo rompa (`ios/`, `Podfile`, `Info.plist`, un plugin con código nativo nuevo, código Swift) se descubre hasta activar. Los cambios solo de Dart casi nunca lo rompen.
- **Los Release no traen IPA**, y sus notas lo dicen.

## Al activarlo

1. Activa la variable (comando de arriba).
2. Corre el CI en `main` para ver si iOS compila: `gh workflow run ci.yml --ref main -R lattice-systems/carecar-mobile`. Arregla lo que falle **antes** de etiquetar.
3. Etiqueta el Release como siempre ([`plan/modulos/T04-entrega-continua.md`](../plan/modulos/T04-entrega-continua.md)): con la variable activa trae el IPA.
4. Si ya no hace falta, vuelve a pausar.

El criterio de salida de H7 pide un Release con APK firmado **e IPA** ([`plan/hitos.md`](../plan/hitos.md)): ese Release no sale completo sin este paso.
