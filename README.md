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

Exemplo para gerar build local macOS da versão `v0.0.1`:

```bash
APP_VERSION=0.0.1 ./scripts/build.sh
```

Exemplo para gerar build local Windows da versão `v1.0.4`:

```powershell
$env:APP_VERSION="1.0.4"
.\scripts\build.ps1
```

## CI/CD em GitHub Actions

O projeto agora possui pipelines separadas por plataforma em:

- `.github/workflows/build-windows.yml`
- `.github/workflows/build-macos.yml`

Versões fixas por plataforma no CI:

- Windows: `v1.0.4`
- macOS: `v0.0.1`

Smoke test de integração automatizado em cada job:

- Valida build + empacotamento
- Falha se artefatos obrigatórios não forem gerados

## Release por plataforma (tags)

Windows (tag padrão `vX.Y.Z`, exemplo atual `v1.0.4`):

```bash
git tag -a v1.0.4 -m "Release Windows v1.0.4"
git push origin v1.0.4
```

macOS (tag padrão `vX.Y.Z-mac`, exemplo `v0.0.1-mac`):

```bash
git tag -a v0.0.1-mac -m "Release macOS v0.0.1"
git push origin v0.0.1-mac
```

Fluxos de release:

- `.github/workflows/release-windows.yml` (asset `LachhhTools.exe`)
- `.github/workflows/release-macos.yml` (asset `LachhhTools-macOS-vX.Y.Z.zip`)

Comandos legados por tag (exemplo):

```bash
git tag -a v1.0.4 -m "Release Windows v1.0.4"
git push origin v1.0.4
```

Consulte também:

- `BUILD.md`
- `docs/security/OAUTH_TWITCH_CHECKLIST.md`
