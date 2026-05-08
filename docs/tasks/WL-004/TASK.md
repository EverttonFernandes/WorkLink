# WL-004 — Listagem de profissionais com sinais mínimos

## História

Como usuário cliente, quero visualizar profissionais compatíveis com minha busca em cards comparáveis, para decidir qual perfil abrir sem depender apenas de uma lista de contatos.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-004-listagem-profissionais.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md`

## Critérios de aceite

- [x] Listagem deve exibir apenas profissionais compatíveis com a busca.
- [x] Card deve conter informações resumidas suficientes para comparação inicial.
- [x] Badges devem ser exibidos somente quando houver dados que os justifiquem.
- [x] Profissional indisponível não deve receber destaque indevido.
- [x] Card deve permitir abrir perfil detalhado.

## Escopo técnico

- Evoluir a listagem mobile existente da descoberta para cards comparáveis.
- Exibir sinais mínimos opcionais sem prometer ranking, avaliação ou garantia de qualidade.
- Expor ação de abertura de perfil detalhado por callback, preparando a história `WL-005`.
- Manter filtros existentes de categoria, cidade e palavra-chave.
- Cobrir lógica e tela com testes BDD/TDD.

## Fora do escopo

- Perfil público detalhado.
- Ranking sofisticado.
- Avaliações.
- Garantia de qualidade.
- Integração HTTP real do app mobile.
