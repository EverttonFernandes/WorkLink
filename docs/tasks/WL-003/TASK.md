# WL-003 — Descoberta por categoria, cidade e palavra-chave

## Fonte

- História: `docs/jira-pessoal/historias/WL-003-descoberta-busca-filtros.md`
- Ordem oficial: 12 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Negócio
- Versão sugerida: `MINOR`

## Objetivo

Permitir que usuários encontrem profissionais usando categoria, cidade selecionada e palavra-chave.

## Escopo incluído

- Busca por categoria.
- Busca por palavra-chave.
- Busca por cidade ou cidades selecionadas.
- Limpeza de filtros.
- Estado de nenhum profissional encontrado.
- Fluxo sem login.
- Tela mobile mínima vinculada ao protótipo `docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png`.

## Fora do escopo

- Ranking sofisticado.
- Recomendação por IA.
- Busca nacional.
- Perfil detalhado e cards ricos, que pertencem às próximas histórias.

## Critérios de aceite

- Usuário deve buscar profissionais por categoria sem login.
- Usuário deve buscar por palavra-chave sem login.
- Usuário deve buscar por cidade sem login.
- Filtros combinados devem retornar apenas profissionais compatíveis.
- Limpar filtros deve restaurar a busca para estado padrão.
- Quando não houver resultado, deve existir estado de nenhum profissional encontrado.
