# LachhhTools

Ferramenta desktop (Adobe AIR) para sorteios e automacoes de stream, com integracao de chat e alertas.

## Novidades da versao `v1.0.2`

- Botao de configuracao OAuth2 do YouTube adicionado ao lado do login atual na area de conexao.
- Fluxo de autorizacao YouTube integrado ao callback local (`http://localhost:9233`) ja usado no app.
- Persistencia local dos dados de conexao YouTube (token e nome do canal).
- Coleta de usuarios do chat agora permite escolher entre chats abertos/conhecidos no momento do sorteio.
- A tela de `Add Viewers` aceita selecao por indice ou por nome do canal.

## Documentacao oficial utilizada

- OAuth 2.0 para apps instalados (Google Identity):  
  [https://developers.google.com/identity/protocols/oauth2/native-app](https://developers.google.com/identity/protocols/oauth2/native-app)
- OAuth 2.0 endpoint de autorizacao Google:
  [https://developers.google.com/identity/protocols/oauth2](https://developers.google.com/identity/protocols/oauth2)
- YouTube Live Streaming API - `liveBroadcasts.list`:  
  [https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/list](https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/list)
- YouTube Live Streaming API - `liveChatMessages.list`:  
  [https://developers.google.com/youtube/v3/live/docs/liveChatMessages/list](https://developers.google.com/youtube/v3/live/docs/liveChatMessages/list)

## Configuracao do OAuth2 YouTube

No arquivo privado:

- `src/com/lachhh/lachhhengine/VersionInfoDONTSTREAMTHIS.as`

Preencha:

- `YOUTUBE_CLIENT_ID`
- `YOUTUBE_CLIENT_SECRET`
- `YOUTUBE_REDIRECT_URI` (padrao: `http://localhost:9233`)

## Build

<<<<<<< HEAD
Exemplo para gerar build local macOS da versão `vX.Y.Z`:
=======
Exemplo para gerar build local macOS da versao `vX.Y.Z`:
>>>>>>> 0b0e4a5 (melhorando workflow)

```bash
APP_VERSION=X.Y.Z ./scripts/build.sh
```

<<<<<<< HEAD
Exemplo para gerar build local Windows da versão `vX.Y.Z`:
=======
Exemplo para gerar build local Windows da versao `vX.Y.Z`:
>>>>>>> 0b0e4a5 (melhorando workflow)

```powershell
$env:APP_VERSION="X.Y.Z"
.\scripts\build.ps1
```

## CI/CD em GitHub Actions

<<<<<<< HEAD
O projeto possui workflows separados para preview de CI e release oficial:
=======
O projeto possui uma esteira em nuvem separada por plataforma:
>>>>>>> 0b0e4a5 (melhorando workflow)

- `.github/workflows/pr-validation.yml`
- `.github/workflows/build-windows.yml`
- `.github/workflows/build-macos.yml`
- `.github/workflows/release-on-merge.yml`

<<<<<<< HEAD
Comportamento atual:

- `build-windows.yml` roda em PRs e em push fora de `main/master`
- o preview de Windows resolve a próxima versão esperada via labels `semver:*`
- o artifact de preview sobe com contexto do PR/commit, por exemplo `LachhhTools-Windows-pr-4-v1.0.6-preview`
- `build-macos.yml` fica manual (`workflow_dispatch`) como fallback operacional
- `release-on-merge.yml` roda no merge de PR para `master` e publica os artefatos oficiais
=======
Sequencia oficial:

- `PR -> validacao -> merge -> testes de integracao -> build/release`

### PR Validation
>>>>>>> 0b0e4a5 (melhorando workflow)

O workflow `PR Validation` roda em PRs para `main/master` e faz o papel de gate obrigatorio antes do merge.

Ele valida:

<<<<<<< HEAD
## Release por plataforma (automática no merge)

O versionamento/release é orquestrado automaticamente em merge de PR para `master`:

- `.github/workflows/release-on-merge.yml`

Regras SemVer por label no PR:

- `semver:major`
- `semver:minor`
- `semver:patch`

Resolução de conflito de labels:

- maior impacto vence: `major > minor > patch`
- sem label: default `patch`

Tags geradas automaticamente:

- Windows: `vX.Y.Z`
- macOS: `vX.Y.Z-mac`

Artefatos oficiais:

- Windows: `LachhhTools-Windows-vX.Y.Z.exe`
- macOS: `LachhhTools-macOS-vX.Y.Z.zip`

Comportamento em rerun (idempotente):

- se tags do `merge_commit_sha` já existirem, a mesma versão é reutilizada
- se uma release/asset já existir, o workflow publica apenas o que estiver faltando
=======
- presenca e unicidade de 1 label semver
- presenca e unicidade de 1 label de plataforma
- sintaxe dos workflows YAML
- sintaxe dos scripts shell e PowerShell
- contrato da action de resolucao de versao/plataforma
- consistencia basica da documentacao e dos workflows versionados

Labels obrigatorias por PR:

- semver: `semver:major`, `semver:minor`, `semver:patch`
- plataforma: `platform:windows`, `platform:macos`, `platform:both`

Para bloquear merge indevido, configure a branch `master` para exigir o status check `PR Validation`.

### Preview e fallback

- `build-windows.yml` roda em `push` fora de `main/master` e em `workflow_dispatch`
- o preview de Windows nao e a fonte oficial de release; ele serve apenas como artefato operacional de apoio
- `build-macos.yml` fica manual (`workflow_dispatch`) como fallback operacional

### Release oficial no merge

O workflow `.github/workflows/release-on-merge.yml` roda no merge de PR para `master/main` e resolve tudo na nuvem:

- le os labels do PR
- calcula a proxima versao SemVer
- decide a plataforma alvo
- roda testes de integracao so da plataforma liberada
- faz build so depois dos testes de integracao verdes
- cria tag e GitHub Release so da plataforma liberada
>>>>>>> 0b0e4a5 (melhorando workflow)

Regras de plataforma:

- `platform:windows`: release apenas Windows
- `platform:macos`: release apenas macOS
- `platform:both`: release Windows e macOS com a mesma `app_version`

Regras SemVer:

- `semver:major`
- `semver:minor`
- `semver:patch`

## Release por plataforma

Tags oficiais:

- Windows: `vX.Y.Z`
- macOS: `vX.Y.Z-mac`

Artefatos oficiais:

- Windows: `LachhhTools-Windows-vX.Y.Z.exe`
- macOS: `LachhhTools-macOS-vX.Y.Z.zip`

Comportamento em rerun:

- se a tag da plataforma ja apontar para o mesmo `merge_commit_sha`, a mesma versao e reutilizada
- se a release ou o asset ja existirem, o workflow publica apenas o que estiver faltando

Primeiro caso previsto nesta esteira:

- `semver:patch` + `platform:windows`

Consulte tambem:

- `BUILD.md`
- `docs/security/OAUTH_TWITCH_CHECKLIST.md`
