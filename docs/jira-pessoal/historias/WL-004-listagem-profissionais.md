# WL-004 — Listagem de profissionais com sinais mínimos

## Objetivo

Exibir profissionais compatíveis com critérios de busca usando cards com informações resumidas e sinais iniciais.

## Valor entregue

O usuário compara profissionais sem ver apenas uma lista de contatos.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF09, RF10, RF23, RF29, RF58, RF60
- RN07, RN08, RN15, RN16

## Escopo incluído

- Cards com foto quando houver, nome, categoria e cidade.
- Exibição de badge de perfil básico/completo/verificado quando disponível.
- Exibição de badge de disponibilidade quando disponível.
- Sinal de atividade recente quando disponível.
- Ação para abrir perfil.

## Fora do escopo

- Algoritmo sofisticado de ranking.
- Garantia de qualidade.
- Avaliações se ainda não existirem.

## Critérios de aceite

- Listagem deve exibir apenas profissionais compatíveis com a busca.
- Card deve conter informações resumidas suficientes para comparação inicial.
- Badges devem ser exibidos somente quando houver dados que os justifiquem.
- Profissional indisponível não deve receber destaque indevido.
- Card deve permitir abrir perfil detalhado.

## Protótipos de tela relacionados

- `docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png`
- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`

### Requisitos não funcionais por tela

- cards devem evitar promessa de qualidade, garantia ou ranking sofisticado;
- tela deve manter boa performance em listas maiores;
- testes mobile devem cobrir renderização dos cards, abertura do perfil e estado sem resultados.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona listagem comparável com sinais úteis.
