# Checklist de Implementação — Sistema de Sorteio para Live

Este checklist consolida **todos os requisitos citados** em `requirements.md` para execução e validação durante desenvolvimento.

Fonte oficial: `requirements.md`.

---

## 1) Fluxo principal (obrigatório)

- [ ] Selecionar fonte de participantes
- [ ] Selecionar chat/canal/live
- [ ] Coletar participantes
- [ ] Visualizar lista
- [ ] Editar lista (opcional)
- [ ] Executar sorteio
- [ ] Exibir vencedor
- [ ] Sortear novamente ou reiniciar

---

## 2) Requisitos Funcionais (RF)

### RF-01 — Selecionar fonte de participantes
- [ ] Permitir seleção de origem dos participantes
- [ ] Suportar: chat atual
- [ ] Suportar: chat selecionado
- [ ] Suportar: lista manual
- [ ] Suportar: lista importada
- [ ] Exibir claramente a fonte selecionada

### RF-02 — Selecionar chat ou live
- [ ] Permitir selecionar chat/live base
- [ ] Exibir nome do canal
- [ ] Exibir status do chat
- [ ] Exibir indicador de seleção

### RF-03 — Coletar participantes
- [ ] Coletar participantes do chat selecionado
- [ ] Remover duplicados automaticamente
- [ ] Ignorar nomes vazios
- [ ] Exibir quantidade total de participantes
- [ ] Atualizar lista visível após coleta

### RF-04 — Exibir lista de participantes
- [ ] Exibir nome
- [ ] Exibir status (elegível/removido)
- [ ] Disponibilizar busca
- [ ] Permitir remoção manual
- [ ] Exibir contagem total

### RF-05 — Editar lista manualmente
- [ ] Permitir adicionar participante
- [ ] Permitir remover participante
- [ ] Permitir limpar lista
- [ ] Permitir remover duplicados
- [ ] Permitir restaurar lista anterior

### RF-06 — Executar sorteio
- [ ] Só permitir sorteio com ao menos 1 elegível
- [ ] Escolher aleatoriamente
- [ ] Registrar vencedor atual
- [ ] Impedir sorteios múltiplos simultâneos

### RF-07 — Exibir vencedor
- [ ] Mostrar nome do vencedor
- [ ] Destacar visualmente
- [ ] Permitir copiar nome
- [ ] Permitir novo sorteio
- [ ] Permitir reiniciar sorteio

### RF-08 — Sortear novamente
- [ ] Permitir novo sorteio com a mesma lista

### RF-09 — Reiniciar sorteio
- [ ] Limpar tudo e começar novamente

---

## 3) Requisitos de Interface (RI)

### RI-01 — Estrutura da tela principal
- [ ] Área 1: Conexão/Fonte
- [ ] Área 2: Seleção de chat
- [ ] Área 3: Lista de participantes
- [ ] Área 4: Sorteio e resultado

### RI-02 — Hierarquia visual
- [ ] Prioridade 1: resultado do sorteio
- [ ] Prioridade 2: botão sortear
- [ ] Prioridade 3: lista de participantes
- [ ] Prioridade 4: seleção de chat
- [ ] Prioridade 5: conexão

### RI-03 — Botões principais obrigatórios
- [ ] Conectar
- [ ] Selecionar chat
- [ ] Coletar participantes
- [ ] Sortear
- [ ] Sortear novamente
- [ ] Reiniciar
- [ ] Adicionar participante
- [ ] Remover participante
- [ ] Limpar lista
- [ ] Não criar botões extras sem requisito

---

## 4) Requisitos de Usabilidade (RU)

### RU-01 — Fluxo rápido
- [ ] Operador executa sorteio em < 30s após abrir sistema

### RU-02 — Clareza de estado
- [ ] Exibir estado desconectado
- [ ] Exibir estado conectado
- [ ] Exibir estado chat selecionado
- [ ] Exibir estado participantes coletados
- [ ] Exibir estado pronto para sortear
- [ ] Exibir estado sorteio concluído

### RU-03 — Prevenção de erro
- [ ] Bloquear sorteio sem participantes
- [ ] Bloquear sorteio sem chat selecionado
- [ ] Exigir confirmação para limpar lista
- [ ] Avisar ao trocar chat

### RU-04 — Legibilidade
- [ ] Contraste adequado
- [ ] Leitura rápida de nomes
- [ ] Vencedor claramente destacado
- [ ] Funcionar em 1280x720 (mínimo)

---

## 5) Requisitos Não Funcionais (RNF)

### RNF-01 — Desempenho
- [ ] Coleta em até 5s
- [ ] Sorteio instantâneo
- [ ] Resposta da interface < 200ms

### RNF-02 — Confiabilidade
- [ ] Não duplicar participantes
- [ ] Não perder lista sem ação do usuário
- [ ] Não alterar vencedor após sorteio
- [ ] Não sortear participante removido

### RNF-03 — Persistência
- [ ] Salvar última fonte usada (opcional)
- [ ] Salvar último chat selecionado (opcional)
- [ ] Salvar última lista de participantes (opcional)

---

## 6) Guard Rails (GR)

### GR-01 — Não inventar funcionalidades
- [ ] Não implementar fora do documento

### GR-02 — Não alterar fluxo principal
- [ ] Manter: Selecionar fonte → Selecionar chat → Coletar → Revisar lista → Sortear → Mostrar vencedor

### GR-03 — Não adicionar complexidade arquitetural
- [ ] Não criar microserviços
- [ ] Não criar arquitetura distribuída
- [ ] Não criar autenticação complexa
- [ ] Não criar permissões complexas
- [ ] Não criar banco de dados sem necessidade
- [ ] Não criar APIs externas sem requisito

### GR-04 — Interface simples
- [ ] Uma tela principal
- [ ] Poucos botões
- [ ] Fluxo linear
- [ ] Feedback visual claro

### GR-05 — Estados obrigatórios
- [ ] DISCONNECTED
- [ ] CONNECTED
- [ ] CHAT_SELECTED
- [ ] PARTICIPANTS_LOADED
- [ ] READY_TO_DRAW
- [ ] DRAW_COMPLETED

### GR-06 — Regras do sorteio
- [ ] Usar apenas elegíveis
- [ ] Ser aleatório
- [ ] Não repetir automaticamente
- [ ] Não sortear com lista vazia

### GR-07 — Lista de participantes
- [ ] Remover duplicados
- [ ] Ignorar vazios
- [ ] Permitir remoção manual
- [ ] Permitir adição manual

### GR-08 — Botão Sortear
- [ ] Desabilitado sem participantes
- [ ] Destacado quando pronto
- [ ] Mudar estado após sorteio

### GR-09 — Resultado
- [ ] Visível
- [ ] Único
- [ ] Persistente até novo sorteio
- [ ] Copiável

---

## 7) Critérios de aceitação (CA)

- [ ] CA-01: operador coleta participantes
- [ ] CA-02: operador visualiza lista
- [ ] CA-03: operador remove nomes
- [ ] CA-04: operador executa sorteio
- [ ] CA-05: vencedor exibido corretamente
- [ ] CA-06: operador sorteia novamente
- [ ] CA-07: operador reinicia
- [ ] CA-08: não é possível sortear sem participantes
- [ ] CA-09: interface clara
- [ ] CA-10: fluxo segue documento
