# WL-003 — Descoberta por categoria, cidade e palavra-chave

## Objetivo

Permitir que usuários encontrem profissionais usando categoria, cidade selecionada e palavra-chave.

## Valor entregue

O usuário passa a descobrir profissionais locais por intenção real de busca.

## Personas

- Usuário cliente

## Requisitos relacionados

- RF01, RF02, RF03, RF04, RF07, RF08, RF09
- RN01

## Escopo incluído

- Busca por categoria.
- Busca por palavra-chave.
- Busca por cidade ou cidades selecionadas.
- Limpeza de filtros.
- Estado de nenhum profissional encontrado.

## Fora do escopo

- Ranking sofisticado.
- Recomendação por IA.
- Busca nacional.

## Critérios de aceite

- Usuário deve buscar profissionais por categoria sem login.
- Usuário deve buscar por palavra-chave sem login.
- Usuário deve buscar por cidade sem login.
- Filtros combinados devem retornar apenas profissionais compatíveis.
- Limpar filtros deve restaurar a busca para estado padrão.
- Quando não houver resultado, deve existir estado de nenhum profissional encontrado.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png`

### Requisitos não funcionais por tela

- estado vazio deve ser claro, acessível e sem exigir autenticação;
- busca e filtros não devem expor dados sensíveis ou registrar informação pessoal desnecessária;
- testes mobile devem cobrir busca com resultado, busca sem resultado, limpeza de filtros e estado vazio.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona descoberta funcional.
