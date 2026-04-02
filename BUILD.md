# Build local (sem arquivos externos)

Documentacao de seguranca:
- OAuth Twitch (checklist continuo): `docs/security/OAUTH_TWITCH_CHECKLIST.md`

Este repositorio possui build autonomo para AIR Desktop, sem depender de arquivos externos da FDT (como certificado em `docs/certificates` ou descriptor gerado manualmente).

## Pre-requisitos

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

Saidas:
- SWF: `bin/TwitchGiveawayTool.swf`
- Pacote: `installers/LachhhTools.exe`

## CI/CD por plataforma

Workflows:
- `.github/workflows/pr-validation.yml`
- `.github/workflows/build-windows.yml`
- `.github/workflows/build-macos.yml`
- `.github/workflows/release-on-merge.yml`

Sequencia oficial:
- `PR -> validacao -> merge -> testes de integracao -> build/release`

### 1. Validacao obrigatoria no PR

`pr-validation.yml` roda em PRs para `main/master` e valida:

- exatamente 1 label semver
- exatamente 1 label de plataforma
- YAML dos workflows e actions
- sintaxe dos scripts shell e PowerShell
- contrato da action `.github/actions/resolve-release-version/action.yml`
- consistencia documental minima da esteira

Labels aceitas:

- SemVer:
  - `semver:major`
  - `semver:minor`
  - `semver:patch`
- Plataforma:
  - `platform:windows`
  - `platform:macos`
  - `platform:both`

Para transformar isso em bloqueio real de merge, configure a branch `master` para exigir o check `PR Validation`.

### 2. Preview e fallback

- `build-windows.yml`
  - roda em `push` fora de `main/master`
  - tambem pode rodar manualmente
  - gera preview operacional do Windows, mas nao publica release oficial
- `build-macos.yml`
  - roda apenas via `workflow_dispatch`
  - serve como fallback operacional para macOS

### 3. Release oficial no merge

`release-on-merge.yml` roda em `pull_request.closed` quando o PR foi mergeado em `master/main`.

Fluxo:

- resolve `merge_commit_sha`
- resolve versao e plataforma a partir dos labels do PR
- roda integration gate so na plataforma liberada
- so depois roda o build da plataforma liberada
- publica tag e GitHub Release so da plataforma liberada

Regras de plataforma:

- `platform:windows`
  - cria apenas `vX.Y.Z`
  - publica apenas `LachhhTools-Windows-vX.Y.Z.exe`
- `platform:macos`
  - cria apenas `vX.Y.Z-mac`
  - publica apenas `LachhhTools-macOS-vX.Y.Z.zip`
- `platform:both`
  - usa a mesma `app_version` nas duas plataformas
  - publica Windows e macOS em trilhas separadas

Regras SemVer:

- `semver:major`
- `semver:minor`
- `semver:patch`

Rerun idempotente:

- se a tag da plataforma ja apontar para o mesmo merge, a versao e reutilizada
- se a release/asset ja existirem, o workflow publica apenas o que estiver faltando

Primeira entrega esperada:

- `semver:patch`
- `platform:windows`

## Release versionada

Padroes de tag:
- Windows: `vX.Y.Z`
- macOS: `vX.Y.Z-mac`

Artefatos oficiais:
- Windows: `LachhhTools-Windows-vX.Y.Z.exe`
- macOS: `LachhhTools-macOS-vX.Y.Z.zip`

## macOS

```bash
export AIR_HOME="/Applications/AIRSDK"
./scripts/build.sh
```

Saidas:
- SWF: `bin/TwitchGiveawayTool.swf`
- Pacote: `installers/LachhhTools.app`

## O que o script resolve automaticamente

- Gera `bin/TwitchGiveawayTool-app.xml` a partir de template versionado no repo
- Copia `platform/xSplitWidget/release/lachhhWidget.swf` para `bin/lachhhtools_widget.swf`
- Copia icones para `bin/icons`
- Gera certificado local em `build/certs/dev-certificate.p12` (se nao existir)
- Compila e empacota com `amxmlc/mxmlc` + `adt`

## Variaveis opcionais

- `MAIN_CLASS` (default: `com.flashinit.ReleaseInit`)
- `PACKAGE_TARGET` (`auto`, `native`, `bundle`, `air`)
- `APP_VERSION` (default: `1.0.2`)
- `APP_ID`, `APP_NAME`, `APP_FILENAME`
- `CERT_PASS` (default: `changeit`)
- `AIR_NAMESPACE_VERSION` (default: `25.0`)

## VS Code (ActionScript & MXML)

O arquivo `asconfig.json` foi adicionado para build/IDE moderna sem FDT.
Ele usa somente dependencias locais do repositorio.
