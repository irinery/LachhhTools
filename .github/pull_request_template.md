## Resumo

- O que foi alterado:
- Por que foi alterado:

## Testes

- [ ] Testei localmente
- [ ] Fluxo principal validado

## Segurança OAuth Twitch (obrigatório quando aplicável)

Se este PR toca o fluxo OAuth Twitch (login/callback/token/socket/persistência), marque:

- [ ] `state` anti-CSRF foi mantido/adicionado e validado
- [ ] `state` é consumido uma única vez
- [ ] `code` OAuth é validado antes de uso
- [ ] token é validado antes de uso
- [ ] não há logs com token/code
- [ ] não há persistência local nova de segredo
- [ ] falhas limpam estado sensível intermediário
- [ ] executei o checklist em `docs/security/OAUTH_TWITCH_CHECKLIST.md`

