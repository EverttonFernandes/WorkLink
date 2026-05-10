# WL-022 — Métricas funcionais detalhadas da V1

## Objetivo

Completar as métricas funcionais previstas no épico, incluindo buscas por categoria/cidade, buscas sem resultado,
percentuais de responsividade e métricas de reputação.

## Valor entregue

Produto e administração conseguem avaliar se a V1 está validando a tese de descoberta local com chance real de resposta.

## Personas

- Administrador
- Product Manager

## Requisitos relacionados

- RF58, RF59, RF60, RF61, RF67
- RN17, RN18

## Escopo incluído

- Categorias mais buscadas.
- Cidades mais buscadas.
- Buscas sem resultado.
- Percentual de contatos respondidos.
- Percentual de profissionais que não responderam.
- Percentual de serviços realizados.
- Percentual de usuários que responderam pós-contato.
- Quantidade de avaliações anônimas.
- Denúncias recebidas e avaliações contestadas nos agregados.

## Fora do escopo

- Ranking algorítmico sofisticado.
- IA para recomendação.
- Dashboards avançados.

## Critérios de aceite

- Métricas de descoberta devem incluir categoria, cidade e buscas sem resultado.
- Métricas de responsividade devem incluir percentuais derivados do pós-contato.
- Métricas de reputação devem incluir avaliações, média, anônimas, denúncias e contestações.
- Métricas de profissional devem diferenciar ativos, completos, disponíveis, indisponíveis e com contato recebido.
- Resposta deve manter `rankingAlgorithmEnabled=false`.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: completa base analítica prevista no épico sem criar ranking opaco.
