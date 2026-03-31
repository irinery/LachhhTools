# Build local (sem arquivos externos)

Documentação de segurança:
- OAuth Twitch (checklist contínuo): `docs/security/OAUTH_TWITCH_CHECKLIST.md`

Este repositório agora possui build autônomo para AIR Desktop, sem depender de arquivos externos da FDT (como certificado em `docs/certificates` ou descriptor gerado manualmente).

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

## Release versionada (WINDOWS APENAS)

Este projeto tem workflow de release por tag em:
- `.github/workflows/release-windows.yml`

Ele publica release **somente para Windows** com download de:
- `LachhhTools.exe`

Como gerar uma release:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

Resultado:
- A Action roda no `windows-latest`
- Gera o executável via `scripts/build.ps1`
- Cria a GitHub Release com o asset `installers/LachhhTools.exe`

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
- `APP_VERSION` (default: `1.0.0`)
- `APP_ID`, `APP_NAME`, `APP_FILENAME`
- `CERT_PASS` (default: `changeit`)
- `AIR_NAMESPACE_VERSION` (default: `25.0`)

## VS Code (ActionScript & MXML)

O arquivo `asconfig.json` foi adicionado para build/IDE moderna sem FDT.
Ele usa somente dependências locais do repositório.
