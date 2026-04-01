# Build local (sem arquivos externos)

Documentação de segurança:
- OAuth Twitch (checklist contínuo): `docs/security/OAUTH_TWITCH_CHECKLIST.md`

Este repositório possui build autônomo para AIR Desktop, sem depender de arquivos externos da FDT (como certificado em `docs/certificates` ou descriptor gerado manualmente).

## Pré-requisitos

- Java JDK 8 ou 11
- HARMAN AIR SDK instalado
  - Defina `AIR_HOME` (ou `AIR_SDK_HOME`) para a pasta do SDK
  - Alternativa: coloque o SDK em `tools/air-sdk`

## Windows (prioridade)

No PowerShell:

```powershell
$env:AIR_HOME = "C:\air-sdk"
.\scripts\build.ps1
```

Ou:

```cmd
set AIR_HOME=C:\air-sdk
scripts\build.cmd
```

Saídas:
- SWF: `bin/TwitchGiveawayTool.swf`
- Pacote: `installers/LachhhTools.exe`

## CI separada por plataforma

Workflows:
- `.github/workflows/build-windows.yml`
- `.github/workflows/build-macos.yml`

Características:
- Windows e macOS rodam em workflows independentes
- Build Windows via `scripts/build.ps1`
- Build macOS via `scripts/build.sh`
- Smoke test de integração automatizado por plataforma
  - Windows: `installers/LachhhTools.exe` + `bin/TwitchGiveawayTool.swf`
  - macOS: `installers/LachhhTools.app` + `bin/TwitchGiveawayTool.swf`

Versões fixas no CI:
- Windows: `APP_VERSION=1.0.4`
- macOS: `APP_VERSION=0.0.1`

## Release versionada (separada por plataforma)

Este projeto tem workflows de release por tag em:
- `.github/workflows/release-windows.yml`
- `.github/workflows/release-macos.yml`

Padrões de tag:
- Windows: `vX.Y.Z` (ex.: `v1.0.4`)
- macOS: `vX.Y.Z-mac` (ex.: `v0.0.1-mac`)

Eles publicam releases separadas:
- Windows: `LachhhTools.exe`
- macOS: `LachhhTools-macOS-vX.Y.Z.zip`

Como gerar as releases:

```bash
git tag -a v1.0.4 -m "Release Windows v1.0.4"
git push origin v1.0.4

git tag -a v0.0.1-mac -m "Release macOS v0.0.1"
git push origin v0.0.1-mac
```

Resultado:
- Windows:
  - A Action roda no `windows-latest`
  - Gera o executável via `scripts/build.ps1`
  - Cria release com asset `installers/LachhhTools.exe`
- macOS:
  - A Action roda no `macos-latest`
  - Gera o bundle via `scripts/build.sh` (`PACKAGE_TARGET=bundle`)
  - Compacta `.app` para `.zip`
  - Cria release com asset `installers/LachhhTools-macOS-vX.Y.Z.zip`

## macOS

```bash
export AIR_HOME="/Applications/AIRSDK"
./scripts/build.sh
```

Saídas:
- SWF: `bin/TwitchGiveawayTool.swf`
- Pacote: `installers/LachhhTools.app`

## O que o script resolve automaticamente

- Gera `bin/TwitchGiveawayTool-app.xml` a partir de template versionado no repo
- Copia `platform/xSplitWidget/release/lachhhWidget.swf` para `bin/lachhhtools_widget.swf`
- Copia ícones para `bin/icons`
- Gera certificado local em `build/certs/dev-certificate.p12` (se não existir)
- Compila e empacota com `amxmlc/mxmlc` + `adt`

## Variáveis opcionais

- `MAIN_CLASS` (default: `com.flashinit.ReleaseInit`)
- `PACKAGE_TARGET` (`auto`, `native`, `bundle`, `air`)
- `APP_VERSION` (default: `1.0.2`)
- `APP_ID`, `APP_NAME`, `APP_FILENAME`
- `CERT_PASS` (default: `changeit`)
- `AIR_NAMESPACE_VERSION` (default: `25.0`)

## VS Code (ActionScript & MXML)

O arquivo `asconfig.json` foi adicionado para build/IDE moderna sem FDT.
Ele usa somente dependências locais do repositório.
