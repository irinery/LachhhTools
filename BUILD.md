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
- `.github/workflows/release-on-merge.yml`

Características:
- Build Windows de preview via `scripts/build.ps1`
- Build macOS manual de fallback via `scripts/build.sh`
- Release oficial no merge faz build e publicacao no mesmo workflow
- Smoke test de integração automatizado por plataforma
  - Windows: `installers/LachhhTools.exe` + `bin/TwitchGiveawayTool.swf`
  - macOS: `installers/LachhhTools.app` + `bin/TwitchGiveawayTool.swf`

Versao no CI:
- resolvida dinamicamente a partir da ultima tag estavel e das labels `semver:*`
- preview de Windows usa contexto do PR/commit no nome do artifact
- release oficial usa exatamente a mesma versao calculada no merge

## Release versionada (separada por plataforma)

Este projeto publica releases separadas por plataforma a partir de:
- `.github/workflows/release-on-merge.yml`

Padrões de tag:
- Windows: `vX.Y.Z`
- macOS: `vX.Y.Z-mac`

Eles publicam releases separadas:
- Windows: `LachhhTools-Windows-vX.Y.Z.exe`
- macOS: `LachhhTools-macOS-vX.Y.Z.zip`

Como funciona no merge de PR para `master`:

- `release-on-merge.yml` roda em `pull_request.closed` com PR merged em `master`
- resolve a versao oficial com base na ultima tag estavel e nas labels do PR
- calcula a próxima versão usando labels do PR:
  - `semver:major`
  - `semver:minor`
  - `semver:patch`
- conflito de labels: maior impacto vence (`major > minor > patch`)
- sem label: bump `patch`
- faz checkout do `merge_commit_sha` e builda os artefatos oficiais antes de publicar
- cria as tags no `merge_commit_sha`:
  - `vX.Y.Z` (Windows)
  - `vX.Y.Z-mac` (macOS)
- rerun idempotente:
  - se as tags ja existirem para aquele merge, a mesma versao eh reutilizada
  - se uma release/asset ja existir, publica apenas o que estiver faltando

Preview e fallback:
- Windows preview: `build-windows.yml`
- macOS manual: `build-macos.yml` via `workflow_dispatch`

Resultado:
- Windows:
  - O preview de CI sobe artifact nomeado com PR/commit e versao prevista
  - A release oficial publica `LachhhTools-Windows-vX.Y.Z.exe`
- macOS:
  - O fallback manual gera preview quando necessario
  - A release oficial gera o bundle, compacta `.app` para `.zip`
  - Publica `LachhhTools-macOS-vX.Y.Z.zip`

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
