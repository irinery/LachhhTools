# Checklist Contínuo de Segurança OAuth (Twitch)

Este checklist define o padrão mínimo de segurança para qualquer alteração no fluxo OAuth da Twitch.

Escopo principal:
- `src/com/giveawaytool/io/twitch/TwitchConnection.as`
- `src/com/giveawaytool/components/LogicSendToWidget.as`
- `src/com/giveawaytool/io/playerio/PlayerIOConnectionPublic.as`
- `src/com/giveawaytool/io/playerio/PlayerIOGameRoomConnection.as`
- `src/com/giveawaytool/ui/ViewTwitchConnect.as`

## Quando aplicar

Aplicar este checklist sempre que houver mudança em:
- login Twitch
- callback OAuth (`code`, `state`, redirect)
- troca/uso de token
- persistência local ligada a autenticação Twitch
- logs e mensagens de erro desse fluxo

## Gates obrigatórios (PR não deve ser aprovado sem isso)

1. `state` anti-CSRF presente no URL de autorização e validado no callback.
2. `state` consumido uma única vez (não reutilizável).
3. `code` OAuth validado (formato e tamanho) antes de uso.
4. token recebido validado (formato e tamanho) antes de uso.
5. nenhum token/code aparece em logs (`trace`) ou mensagens de erro.
6. socket local de callback faz parse defensivo (limite de tamanho e tratamento seguro de query).
7. dados sensíveis não são persistidos em disco sem necessidade explícita.
8. falhas de validação limpam estado intermediário (`code`, `state`, token parcial).
9. erro para usuário é genérico; detalhes sensíveis não são expostos.
10. mudança não quebra o fluxo feliz de login/logout.

## Teste manual mínimo por release

### Fluxo feliz
1. Abrir login Twitch.
2. Autorizar com conta válida.
3. Confirmar que usuário conecta e nome da conta aparece corretamente.

### Fluxo de defesa
1. Repetir callback antigo (`code` antigo): deve falhar.
2. Callback com `state` ausente/inválido: deve falhar.
3. Callback com `code` inválido (curto ou caracteres inesperados): deve falhar.
4. Confirmar que nenhuma falha imprime token/code em log.

### Persistência
1. Fechar/reabrir app.
2. Validar que não há novo armazenamento local de segredo desnecessário.

## Checklist rápido para reviewer

- [ ] Li o diff inteiro dos arquivos de OAuth Twitch.
- [ ] Confirmei validação de `state` e consumo único.
- [ ] Confirmei validação de `code` e token.
- [ ] Confirmei ausência de log sensível.
- [ ] Confirmei limpeza de estado em falha.
- [ ] Confirmei teste manual mínimo.

## Itens recomendados (não bloqueantes)

- Preferir troca de `code` por token apenas no backend (já usado via PlayerIO).
- Evitar ampliar escopos OAuth sem necessidade funcional.
- Revisar permissões de escopo a cada release.

