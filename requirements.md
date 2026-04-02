# Documento de Levantamento de Requisitos

## Sistema de Sorteio para Live

### Documento orientado para desenvolvimento por LLM (Codex)

---

# 1. Objetivo do documento

Este documento define os requisitos funcionais, de interface e de usabilidade da funcionalidade core de uma ferramenta de sorteio para live.

Este documento será utilizado como **fonte de verdade (source of truth)** para desenvolvimento automatizado por LLM, servindo como **guard rails** para impedir:

* funcionalidades fora do escopo
* mudanças de comportamento
* decisões arbitrárias da LLM
* over-engineering
* alterações de fluxo sem especificação
* inconsistências de interface

Todas as implementações devem seguir estritamente este documento.

---

# 2. Escopo do sistema

O sistema deve permitir realizar sorteios de participantes provenientes de chats de lives ou listas de usuários, com foco em:

* operação rápida
* interface clara
* baixo risco operacional
* execução durante transmissão ao vivo
* visualização clara do vencedor

O sistema **não faz parte deste escopo**:

* sistema de login complexo
* sistema de pagamentos
* CRM
* analytics avançado
* automações externas complexas
* integração com redes sociais além do chat
* sistema web completo
* banco de dados distribuído
* microserviços
* notificações push
* sistema multiusuário

A LLM **não deve implementar funcionalidades fora deste escopo**.

---

# 3. Definições e termos

| Termo             | Definição                                        |
| ----------------- | ------------------------------------------------ |
| Sorteio           | Processo de escolha aleatória de um participante |
| Participante      | Usuário elegível ao sorteio                      |
| Chat              | Fonte de participantes                           |
| Lista             | Conjunto de participantes                        |
| Elegível          | Participante válido para sorteio                 |
| Operador          | Usuário que executa o sorteio                    |
| Sorteio ativo     | Sorteio que ainda não foi executado              |
| Sorteio concluído | Sorteio já executado                             |
| Fonte             | Origem dos participantes                         |

---

# 4. Fluxo principal do sistema

Este é o fluxo principal e **não deve ser alterado pela LLM**.

## Fluxo padrão

1. Selecionar fonte de participantes
2. Selecionar chat/canal/live
3. Coletar participantes
4. Visualizar lista
5. Editar lista (opcional)
6. Executar sorteio
7. Exibir vencedor
8. Sortear novamente ou reiniciar

Qualquer implementação deve respeitar este fluxo.

---

# 5. Requisitos Funcionais (RF)

## RF-01 — Selecionar fonte de participantes

O sistema deve permitir selecionar a origem dos participantes.

Fontes possíveis:

* chat atual
* chat selecionado
* lista manual
* lista importada

A interface deve mostrar claramente a fonte selecionada.

---

## RF-02 — Selecionar chat ou live

O sistema deve permitir selecionar o chat ou live que será usado como base de participantes.

A interface deve mostrar:

* nome do canal
* status do chat
* indicador de seleção

---

## RF-03 — Coletar participantes

O sistema deve permitir coletar participantes do chat selecionado.

Após a coleta, o sistema deve:

* remover duplicados automaticamente
* ignorar nomes vazios
* exibir quantidade total de participantes
* atualizar a lista visível

---

## RF-04 — Exibir lista de participantes

O sistema deve exibir a lista de participantes com:

* nome
* status (elegível / removido)
* busca
* remoção manual
* contagem total

---

## RF-05 — Editar lista manualmente

O operador deve poder:

* adicionar participante
* remover participante
* limpar lista
* remover duplicados
* restaurar lista anterior

---

## RF-06 — Executar sorteio

O sistema deve executar o sorteio apenas se:

* existir ao menos 1 participante elegível

O sistema deve:

* escolher aleatoriamente
* registrar o vencedor atual
* impedir sorteios múltiplos simultâneos

---

## RF-07 — Exibir vencedor

O sistema deve:

* mostrar nome do vencedor
* destacar visualmente
* permitir copiar o nome
* permitir novo sorteio
* permitir reiniciar sorteio

---

## RF-08 — Sortear novamente

O sistema deve permitir sortear novamente usando a mesma lista.

---

## RF-09 — Reiniciar sorteio

O sistema deve permitir limpar tudo e começar novamente.

---

# 6. Requisitos de Interface (RI)

## RI-01 — Estrutura da tela principal

A tela deve conter 4 áreas principais:

1. Conexão / Fonte
2. Seleção de chat
3. Lista de participantes
4. Área de sorteio e resultado

---

## RI-02 — Hierarquia visual

Prioridade visual:

1. Resultado do sorteio
2. Botão sortear
3. Lista de participantes
4. Seleção de chat
5. Conexão

---

## RI-03 — Botões principais

Botões obrigatórios:

* Conectar
* Selecionar chat
* Coletar participantes
* Sortear
* Sortear novamente
* Reiniciar
* Adicionar participante
* Remover participante
* Limpar lista

A LLM não deve criar botões extras sem requisito.

---

# 7. Requisitos de Usabilidade (RU)

## RU-01 — Fluxo rápido

O operador deve conseguir executar um sorteio em menos de 30 segundos após abrir o sistema.

## RU-02 — Clareza de estado

O sistema deve sempre mostrar o estado atual:

* desconectado
* conectado
* chat selecionado
* participantes coletados
* pronto para sortear
* sorteio concluído

## RU-03 — Prevenção de erro

O sistema não deve permitir:

* sortear sem participantes
* sortear sem chat selecionado
* limpar lista sem confirmação
* trocar chat sem aviso

## RU-04 — Legibilidade

A interface deve:

* ter contraste adequado
* permitir leitura rápida de nomes
* destacar vencedor claramente
* funcionar em resolução mínima 1280x720

---

# 8. Requisitos Não Funcionais (RNF)

## RNF-01 — Desempenho

* Coleta de participantes deve ocorrer em até 5 segundos
* Sorteio deve ocorrer instantaneamente
* Interface deve responder em menos de 200ms

## RNF-02 — Confiabilidade

O sistema não pode:

* duplicar participantes
* perder lista sem ação do usuário
* alterar vencedor após sorteio
* sortear participante removido

## RNF-03 — Persistência

O sistema pode salvar:

* última fonte usada
* último chat selecionado
* última lista de participantes

---

# 9. Guard Rails para desenvolvimento por LLM (Codex)

## GR-01 — Não inventar funcionalidades

A LLM não deve implementar funcionalidades não descritas neste documento.

## GR-02 — Não alterar o fluxo principal

Fluxo obrigatório:
Selecionar fonte → Selecionar chat → Coletar → Revisar lista → Sortear → Mostrar vencedor

## GR-03 — Não adicionar complexidade arquitetural

A LLM não deve:

* criar microserviços
* criar arquitetura distribuída
* criar autenticação complexa
* criar sistema de permissões
* criar banco de dados se não for necessário
* criar APIs externas sem requisito

## GR-04 — Interface deve ser simples

A LLM deve priorizar:

* uma tela principal
* poucos botões
* fluxo linear
* feedback visual claro

## GR-05 — Estados do sistema são obrigatórios

Estados obrigatórios:

* DISCONNECTED
* CONNECTED
* CHAT_SELECTED
* PARTICIPANTS_LOADED
* READY_TO_DRAW
* DRAW_COMPLETED

## GR-06 — Regras do sorteio

* sorteio deve usar apenas participantes elegíveis
* sorteio deve ser aleatório
* sorteio não pode repetir automaticamente
* sorteio não pode ocorrer com lista vazia

## GR-07 — Lista de participantes

A lista deve sempre:

* remover duplicados
* ignorar vazios
* permitir remoção manual
* permitir adição manual

## GR-08 — Botão Sortear

O botão sortear:

* deve ficar desabilitado sem participantes
* deve ficar destacado quando pronto
* deve mudar estado após sorteio

## GR-09 — Resultado

O resultado deve:

* ser visível
* ser único
* permanecer visível até novo sorteio
* poder ser copiado

---

# 10. Critérios de aceitação

O sistema será considerado correto se:

1. O operador conseguir coletar participantes
2. O operador conseguir ver a lista
3. O operador conseguir remover nomes
4. O operador conseguir executar sorteio
5. O vencedor for exibido corretamente
6. O operador conseguir sortear novamente
7. O operador conseguir reiniciar
8. Não for possível sortear sem participantes
9. A interface for clara
10. O fluxo seguir o documento

---

# 11. Fluxo de interface (modelo mental)

```
------------------------------------------------
| Conexão | Chat | Participantes | Sorteio     |
------------------------------------------------
| Fonte                                       |
| Chat selecionado                            |
------------------------------------------------
| Lista de participantes                      |
|                                             |
|                                             |
------------------------------------------------
| [Sortear]                                   |
| Vencedor: XXXXX                             |
------------------------------------------------
```

---

# 12. Diretriz para desenvolvimento por LLM

Adicionar no repositório:

```
THIS PROJECT IS SPEC-DRIVEN.
ALL IMPLEMENTATION MUST FOLLOW requirements.md
DO NOT ADD FEATURES NOT IN THE SPEC.
DO NOT CHANGE UI FLOW.
DO NOT CHANGE STATES.
```

---

# 13. Conclusão

Este documento define:

* funcionalidades core
* interface
* usabilidade
* fluxo operacional
* restrições de implementação
* guard rails para LLM
* critérios de aceitação

Este documento deve ser utilizado como base para desenvolvimento assistido por LLM, garantindo que a implementação siga o comportamento esperado e evitando decisões arbitrárias durante a geração de código.
