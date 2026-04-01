# LachhhTools

Ferramenta desktop (Adobe AIR) para sorteios e automações de stream, com integração de chat e alertas.

## Novidades da versão `v1.0.2`

- Botão de configuração OAuth2 do YouTube adicionado ao lado do login atual na área de conexão.
- Fluxo de autorização YouTube integrado ao callback local (`http://localhost:9233`) já usado no app.
- Persistência local dos dados de conexão YouTube (token e nome do canal).
- Coleta de usuários do chat agora permite escolher entre chats abertos/conhecidos no momento do sorteio.
- A tela de `Add Viewers` aceita seleção por índice ou por nome do canal.

## Documentação oficial utilizada

- OAuth 2.0 para apps instalados (Google Identity):  
  [https://developers.google.com/identity/protocols/oauth2/native-app](https://developers.google.com/identity/protocols/oauth2/native-app)
- OAuth 2.0 endpoint de autorização Google:  
  [https://developers.google.com/identity/protocols/oauth2](https://developers.google.com/identity/protocols/oauth2)
- YouTube Live Streaming API - `liveBroadcasts.list`:  
  [https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/list](https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/list)
- YouTube Live Streaming API - `liveChatMessages.list`:  
  [https://developers.google.com/youtube/v3/live/docs/liveChatMessages/list](https://developers.google.com/youtube/v3/live/docs/liveChatMessages/list)

## Configuração do OAuth2 YouTube

No arquivo privado:

- `src/com/lachhh/lachhhengine/VersionInfoDONTSTREAMTHIS.as`

Preencha:

- `YOUTUBE_CLIENT_ID`
- `YOUTUBE_CLIENT_SECRET`
- `YOUTUBE_REDIRECT_URI` (padrão: `http://localhost:9233`)

## Build

Exemplo para gerar build local macOS da versão `vX.Y.Z`:

```bash
APP_VERSION=X.Y.Z ./scripts/build.sh
```

Exemplo para gerar build local Windows da versão `vX.Y.Z`:

```powershell
$env:APP_VERSION="X.Y.Z"
.\scripts\build.ps1
```

## CI/CD em GitHub Actions

O projeto possui workflows separados para preview de CI e release oficial:

- `.github/workflows/build-windows.yml`
- `.github/workflows/build-macos.yml`
- `.github/workflows/release-on-merge.yml`

Comportamento atual:

- `build-windows.yml` roda em PRs e em push fora de `main/master`
- o preview de Windows resolve a próxima versão esperada via labels `semver:*`
- o artifact de preview sobe com contexto do PR/commit, por exemplo `LachhhTools-Windows-pr-4-v1.0.6-preview`
- `build-macos.yml` fica manual (`workflow_dispatch`) como fallback operacional
- `release-on-merge.yml` roda no merge de PR para `master` e publica os artefatos oficiais

Smoke test de integração automatizado em cada job:

- Valida build + empacotamento
- Falha se artefatos obrigatórios não forem gerados

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

Consulte também:

- `BUILD.md`
- `docs/security/OAUTH_TWITCH_CHECKLIST.md`
