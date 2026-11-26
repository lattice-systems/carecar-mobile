/// Los certificados que la app acepta del servidor (V2-M22.04).
///
/// En `pruebas` y `produccion` la app no confía en los ~150 certificados raíz
/// del teléfono sino solo en estos: las raíces de la jerarquía pública de TLS
/// de Azure, que es donde vive el backend. Así, un certificado emitido por
/// cualquier otra autoridad, o instalado en el teléfono por un tercero, no
/// sirve para espiar la conexión.
///
/// **Se fijan raíces y no el certificado del servidor ni sus intermedios**:
/// Azure renueva el certificado del servidor cada pocos meses y cambia de
/// intermedio sin avisar; las raíces duran hasta 2038-2042. Por eso hay varias:
/// si Microsoft cambia de jerarquía, la app ya confía en la nueva.
///
/// Cada ancla viene de la fuente oficial y se verificó contra la huella que
/// publica su autoridad (repositorio PKI de Microsoft y DigiCert). La huella
/// SHA-256 de aquí la comprueba una prueba. Cómo agregar, cambiar o quitar una,
/// y qué hacer si algo se rompe, está en `docs/seguridad/fijar-certificados.md`.
/// Una vigilancia semanal (`.github/workflows/pines-tls.yml`) comprueba que el
/// servidor real siga validando contra estas anclas.
library;

/// Una raíz de confianza que la app acepta.
class AnclaDeConfianza {
  const AnclaDeConfianza({
    required this.nombre,
    required this.sha256,
    required this.venceEn,
    required this.pem,
  });

  /// Nombre de la autoridad, como aparece en el certificado.
  final String nombre;

  /// Huella SHA-256 del certificado (DER), en hexadecimal y minúsculas.
  final String sha256;

  /// Cuándo vence (`AAAA-MM-DD`). Informativo: la vigilancia semanal avisa
  /// con tiempo.
  final String venceEn;

  /// El certificado en PEM.
  final String pem;
}

/// Las raíces de la jerarquía pública de TLS de Azure.
const anclasAzure = <AnclaDeConfianza>[
  // La raíz con la que hoy responde el backend (la jerarquía nueva de Azure). El servidor manda su versión con firma cruzada de DigiCert; la autofirmada de aquí también la valida.
  AnclaDeConfianza(
    nombre: 'Microsoft TLS RSA Root G2',
    sha256: '6a170583db584151e1c454eeca2a64cc5d8e484a5bd1156e720b4458654ee9e5',
    venceEn: '2040-04-10',
    pem: '''
-----BEGIN CERTIFICATE-----
MIIFgDCCA2igAwIBAgIQZIbjsmkYD79AQDkuLlNLmzANBgkqhkiG9w0BAQwFADBR
MQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSIw
IAYDVQQDExlNaWNyb3NvZnQgVExTIFJTQSBSb290IEcyMB4XDTI1MDQxMDE4MzYz
MFoXDTQwMDQxMDE4NDM1MVowUTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jv
c29mdCBDb3Jwb3JhdGlvbjEiMCAGA1UEAxMZTWljcm9zb2Z0IFRMUyBSU0EgUm9v
dCBHMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAN/qi59H4SgQca9B
1hnbklfea6vmLt6tOmCDtxOYrFu5Mgt7659yJ2tdQKu+GAaTsg3SEu24dPV/L+qo
F5T2MxZXit4gfCHdt9qs3k5ksFrNS3Xz7wJkTe1S2qOPBOiR+Nf7Pxn9TkU5Xugp
w9byZ6+zAJTBjeHwShiYOfrACYQzQQUDBav0deFTpSGSXERM5mBXpJACl8fV2JME
MkrthVHt1sW6oD82ii9vTDmoBGkihDt1FPfZPrSp0AdBOIF+Rkgd6BnmcLigqhjd
cr9+fbVsThlwEYQEE4HUYv2ca/Ec3f/sp+Dmx40xS7/yazPM0Yy2/rEbo0qoXw5/
MXY4PwdHbAGorKUU2oKwXx9svIkawBIqy3uXHyguMRaKU0x1Zvl9AdbCYKpljzGe
csvMmy3lRBmTV6tujsLZLmWwci3nocOhfkkdWWfWCdQYEm3AlUV4yfFgauT27gYk
O3NKWhHCPpdhwHju7xOnMOJKOC3uWBcTILc2Kt8LMrTCOLGR3RKwRbZ8wLEdYqGd
3XESFZYBnQoJ9bHds9ngOEI09mm2w68Wc/7UQ/hD5Fj5T7Pz7NY9lDpAOBWrDIbQ
ZM4aY+iElFUJWrYEttE+mhXHZBGA0BuCDk3/RZ6yZQclH9uayMbs1luFUASfHMtd
IIJnnnni3+jy6G/EIHIwhuWddSc1AgMBAAGjVDBSMA4GA1UdDwEB/wQEAwIBhjAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTekYZIt6ExWTHxS18HqdyIedqodjAQ
BgkrBgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQwFAAOCAgEAdDOaUHmugVYlz5tv
URHeVRKQk2wz4C4kDF5kYjRONhm1oBTztcZ406PtsDsKXpI+chsuCoPev5+o0zmo
DtgjNQcFj7bzxhrUQyQXk5obQPB53cnAD3MaBYeLCrrbJIi0hL3N6n8b7XalNAe6
bg7qczpIwu3xnX/3jgUT28vTfShczLK+oHkQKibrcuSmoZcedsQ8flaa8+Y9z+LV
BBlqPNc45eO7HgUP3UgrfDmd6U9Nd6i9SSif57koWzb0cyCCVhbVwVpNxO37B8xo
N67DdFOrlygAA0aE0do5nk8QSj+ZQis1qDmVt36BPmyv/byprsCSTMI0JTsXp5uL
QAoj8orWuAA/Ul5Wu3nri4n4JIngzeYO+s8ISGbNypagtcsvb0QT5sY4nvEEkPET
SLVIQij9/4FIYlFVlJ9nSV9sSP7H0e2RoLQbttBruxNgoKifkv0zVcyBTzPjmkej
xTOZnDVvfB+kS189DzljD/otUI6sGZT9v5fZjljMgGlAZzi2xhfrHKqvhFZSn2Al
MnuQZvLjlzEiIsG1Oj2JFOG0kGq1MmKwljhVBvuKryqDTHrqGa3E9JQattAXUoet
+QzlJ5xIPcay1LE+MA+TM6wC5aCgUmmg8sVILr9GwyZF5urX+Usp4ta44Em3upSv
eM+HJyMso/L+NgtC+eHXJLur5sg=
-----END CERTIFICATE-----
''',
  ),
  // La que firma de forma cruzada a la anterior y la que usaba la jerarquía previa de Azure. Respaldo y camino de compatibilidad.
  AnclaDeConfianza(
    nombre: 'DigiCert Global Root G2',
    sha256: 'cb3ccbb76031e5e0138f8dd39a23f9de47ffc35e43c1144cea27d46a5ab1cb5f',
    venceEn: '2038-01-15',
    pem: '''
-----BEGIN CERTIFICATE-----
MIIDjjCCAnagAwIBAgIQAzrx5qcRqaC7KGSxHQn65TANBgkqhkiG9w0BAQsFADBh
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBH
MjAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAwMDBaMGExCzAJBgNVBAYTAlVT
MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
b20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IEcyMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuzfNNNx7a8myaJCtSnX/RrohCgiN9RlUyfuI
2/Ou8jqJkTx65qsGGmvPrC3oXgkkRLpimn7Wo6h+4FR1IAWsULecYxpsMNzaHxmx
1x7e/dfgy5SDN67sH0NO3Xss0r0upS/kqbitOtSZpLYl6ZtrAGCSYP9PIUkY92eQ
q2EGnI/yuum06ZIya7XzV+hdG82MHauVBJVJ8zUtluNJbd134/tJS7SsVQepj5Wz
tCO7TG1F8PapspUwtP1MVYwnSlcUfIKdzXOS0xZKBgyMUNGPHgm+F6HmIcr9g+UQ
vIOlCsRnKPZzFBQ9RnbDhxSJITRNrw9FDKZJobq7nMWxM4MphQIDAQABo0IwQDAP
BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQUTiJUIBiV
5uNu5g/6+rkS7QYXjzkwDQYJKoZIhvcNAQELBQADggEBAGBnKJRvDkhj6zHd6mcY
1Yl9PMWLSn/pvtsrF9+wX3N3KjITOYFnQoQj8kVnNeyIv/iPsGEMNKSuIEyExtv4
NeF22d+mQrvHRAiGfzZ0JFrabA0UWTW98kndth/Jsw1HKj2ZL7tcu7XUIOGZX1NG
Fdtom/DzMNU+MeKNhJ7jitralj41E6Vf8PlwUHBHQRFXGU7Aj64GxJUTFy8bJZ91
8rGOmaFvE7FBcf6IKshPECBV1/MUReXgRPTqh5Uykw7+U0b6LJ3/iyK5S9kJRaTe
pLiaWN0bfVKfjllDiIGknibVb63dDcY3fe0Dkhvld1927jyNxF1WW6LZZm6zNTfl
MrY=
-----END CERTIFICATE-----
''',
  ),
  // Respaldo: la variante ECC de la jerarquía nueva, por si Azure emite certificados ECC.
  AnclaDeConfianza(
    nombre: 'Microsoft TLS ECC Root G2',
    sha256: '87755cfe88bdb0d1099dcded3eae114ba976e664b3248ee3dc649e357f17e8a7',
    venceEn: '2040-04-10',
    pem: '''
-----BEGIN CERTIFICATE-----
MIICMTCCAbegAwIBAgIQcuICK8WywbBNJQVuYuJ2eTAKBggqhkjOPQQDAzBRMQsw
CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSIwIAYD
VQQDExlNaWNyb3NvZnQgVExTIEVDQyBSb290IEcyMB4XDTI1MDQxMDIwNTIzNloX
DTQwMDQxMDIwNTg1OVowUTELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29m
dCBDb3Jwb3JhdGlvbjEiMCAGA1UEAxMZTWljcm9zb2Z0IFRMUyBFQ0MgUm9vdCBH
MjB2MBAGByqGSM49AgEGBSuBBAAiA2IABFHCOIT2ay617TcWSuXj100AhDtAVPwJ
5vTFp6ZrVkROrWCeFZiOA+7iss11PVhkwBYM31rcLJ1AW75LVCrOjzy/lbyOrInv
aT4XBvd9wbgCZSPL9R0a41Oh9Ad+CotdWaNUMFIwDgYDVR0PAQH/BAQDAgGGMA8G
A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFG+rftr/l0Ny7Dtnd96CYTWIR0KFMBAG
CSsGAQQBgjcVAQQDAgEAMAoGCCqGSM49BAMDA2gAMGUCMQDYM1rR4cySss0f8PKM
sT2ytNTKmNzaiQX0G1dx35RNInYFUElNkCmSLL8vN+W5deICMAGSaVidU7LIVWZb
uslQWiqBto7PEdDyfoTcfzbfwy3aTfgisNizizSfnTEcrA8RGQ==
-----END CERTIFICATE-----
''',
  ),
  // Respaldo: la raíz de la jerarquía anterior de Microsoft, que otros servicios de Azure siguen usando.
  AnclaDeConfianza(
    nombre: 'Microsoft RSA Root Certificate Authority 2017',
    sha256: 'c741f70f4b2a8d88bf2e71c14122ef53ef10eba0cfa5e64cfa20f418853073e0',
    venceEn: '2042-07-18',
    pem: '''
-----BEGIN CERTIFICATE-----
MIIFqDCCA5CgAwIBAgIQHtOXCV/YtLNHcB6qvn9FszANBgkqhkiG9w0BAQwFADBl
MQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTYw
NAYDVQQDEy1NaWNyb3NvZnQgUlNBIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
IDIwMTcwHhcNMTkxMjE4MjI1MTIyWhcNNDIwNzE4MjMwMDIzWjBlMQswCQYDVQQG
EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTYwNAYDVQQDEy1N
aWNyb3NvZnQgUlNBIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTcwggIi
MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDKW76UM4wplZEWCpW9R2LBifOZ
Nt9GkMml7Xhqb0eRaPgnZ1AzHaGm++DlQ6OEAlcBXZxIQIJTELy/xztokLaCLeX0
ZdDMbRnMlfl7rEqUrQ7eS0MdhweSE5CAg2Q1OQT85elss7YfUJQ4ZVBcF0a5toW1
HLUX6NZFndiyJrDKxHBKrmCk3bPZ7Pw71VdyvD/IybLeS2v4I2wDwAW9lcfNcztm
gGTjGqwu+UcF8ga2m3P1eDNbx6H7JyqhtJqRjJHTOoI+dkC0zVJhUXAoP8XFWvLJ
jEm7FFtNyP9nTUwSlq31/niol4fX/V4ggNyhSyL71Imtus5Hl0dVe49FyGcohJUc
aDDv70ngNXtk55iwlNpNhTs+VcQor1fznhPbRiefHqJeRIOkpcrVE7NLP8TjwuaG
YaRSMLl6IE9vDzhTyzMMEyuP1pq9KsgtsRx9S1HKR9FIJ3Jdh+vVReZIZZ2vUpC6
W6IYZVcSn2i51BVrlMRpIpj0M+Dt+VGOQVDJNE92kKz8OMHY4Xu54+OU4UZpyw4K
UGsTuqwPN1q3ErWQgR5WrlcihtnJ0tHXUeOrO8ZV/R4O03QK0dqq6mm4lyiPSMQH
+FJDOvTKVTUssKZqwJz58oHhEmrARdlns87/I6KJClTUFLkqqNfs+avNJVgyeY+Q
W5g5xAgGwax/Dj0ApQIDAQABo1QwUjAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/
BAUwAwEB/zAdBgNVHQ4EFgQUCctZf4aycI8awznjwNnpv7tNsiMwEAYJKwYBBAGC
NxUBBAMCAQAwDQYJKoZIhvcNAQEMBQADggIBAKyvPl3CEZaJjqPnktaXFbgToqZC
LgLNFgVZJ8og6Lq46BrsTaiXVq5lQ7GPAJtSzVXNUzltYkyLDVt8LkS/gxCP81OC
gMNPOsduET/m4xaRhPtthH80dK2Jp86519efhGSSvpWhrQlTM93uCupKUY5vVau6
tZRGrox/2KJQJWVggEbbMwSubLWYdFQl3JPk+ONVFT24bcMKpBLBaYVu32TxU5nh
SnUgnZUP5NbcA/FZGOhHibJXWpS2qdgXKxdJ5XbLwVaZOjex/2kskZGT4d9Mozd2
TaGf+G0eHdP67Pv0RR0Tbc/3WeUiJ3IrhvNXuzDtJE3cfVa7o7P4NHmJweDyAmH3
pvwPuxwXC65B2Xy9J6P9LjrRk5Sxcx0ki69bIImtt2dmefU6xqaWM/5TkshGsRGR
xpl/j8nWZjEgQRCHLQzWwa80mMpkg/sTV9HB8Dx6jKXB/ZUhoHHBk2dxEuqPiApp
GWSZI1b7rCoucL5mxAyE7+WL85MB+GqQk2dLsmijtWKP6T+MejteD+eMuMZ87zf9
dOLITzNy4ZQ5bb0Sr74MTnB8G2+NszKTc0QWbej09+CVgI+WXTik9KveCjCHk9hN
AHFiRSdLOkKEW39lt2c0Ui2cFmuqqNh7o0JMcccMyj6D5KbvtwEwXlGjefVwaaZB
RA+GsCyRxj3qrg+E
-----END CERTIFICATE-----
''',
  ),
  // Respaldo: la variante ECC de la jerarquía anterior de Microsoft.
  AnclaDeConfianza(
    nombre: 'Microsoft ECC Root Certificate Authority 2017',
    sha256: '358df39d764af9e1b766e9c972df352ee15cfac227af6ad1d70e8e4a6edcba02',
    venceEn: '2042-07-18',
    pem: '''
-----BEGIN CERTIFICATE-----
MIICWTCCAd+gAwIBAgIQZvI9r4fei7FK6gxXMQHC7DAKBggqhkjOPQQDAzBlMQsw
CQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTYwNAYD
VQQDEy1NaWNyb3NvZnQgRUNDIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
MTcwHhcNMTkxMjE4MjMwNjQ1WhcNNDIwNzE4MjMxNjA0WjBlMQswCQYDVQQGEwJV
UzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTYwNAYDVQQDEy1NaWNy
b3NvZnQgRUNDIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTcwdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAATUvD0CQnVBEyPNgASGAlEvaqiBYgtlzPbKnR5vSmZR
ogPZnZH6thaxjG7efM3beaYvzrvOcS/lpaso7GMEZpn4+vKTEAXhgShC48Zo9OYb
hGBKia/teQ87zvH2RPUBeMCjVDBSMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBTIy5lycFIM+Oa+sgRXKSrPQhDtNTAQBgkrBgEEAYI3
FQEEAwIBADAKBggqhkjOPQQDAwNoADBlAjBY8k3qDPlfXu5gKcs68tvWMoQZP3zV
L8KxzJOuULsJMsbG7X7JNpQS5GiFBqIb0C8CMQCZ6Ra0DvpWSNSkMBaReNtUjGUB
iudQZsIxtzm6uBoiB078a1QWIP8rtedMDE2mT3M=
-----END CERTIFICATE-----
''',
  ),
];

/// Los dominios cuyo certificado se valida contra [anclasAzure].
const _dominiosDeAzure = <String>['azurecontainerapps.io'];

/// Las anclas que valen para [host], o `null` si no hay ninguna fijada para él.
///
/// El host solo coincide si es el dominio mismo o un subdominio de verdad
/// (`x.azurecontainerapps.io`); un dominio que solo termina parecido
/// (`evilazurecontainerapps.io`) no.
List<AnclaDeConfianza>? anclasPara(String host) {
  final h = host.toLowerCase();
  for (final dominio in _dominiosDeAzure) {
    if (h == dominio || h.endsWith('.$dominio')) return anclasAzure;
  }
  return null;
}
