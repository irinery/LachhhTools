## Resumo

- O que foi alterado:
- Por que foi alterado:

## Labels obrigatorias

- [ ] Adicionei exatamente 1 label semver: `semver:major`, `semver:minor` ou `semver:patch`
- [ ] Adicionei exatamente 1 label de plataforma: `platform:windows`, `platform:macos` ou `platform:both`
- [ ] Para a primeira entrega desta esteira, o alvo esperado e `semver:patch` + `platform:windows`

## Testes

- [ ] O check `PR Validation` passou
- [ ] Testei localmente (quando aplicavel)
- [ ] Fluxo principal validado

## Seguranca OAuth Twitch (obrigatorio quando aplicavel)

Se este PR toca o fluxo OAuth Twitch (login/callback/token/socket/persistencia), marque:

- [ ] `state` anti-CSRF foi mantido/adicionado e validado
- [ ] `state` e consumido uma unica vez
- [ ] `code` OAuth e validado antes de uso
- [ ] token e validado antes de uso
- [ ] nao ha logs com token/code
- [ ] nao ha persistencia local nova de segredo
- [ ] falhas limpam estado sensivel intermediario
- [ ] executei o checklist em `docs/security/OAUTH_TWITCH_CHECKLIST.md`
