# WL-017 — Métricas funcionais e base para ranking futuro

## Objetivo

Registrar sinais funcionais de descoberta, contato, responsividade, reputação, disponibilidade e atividade para permitir evolução futura de ranking.

## Valor entregue

A V1 encerra com base mensurável para decidir evolução do produto sem criar algoritmo sofisticado antes da hora.

## Personas

- Administrador
- Usuário cliente
- Profissional

## Requisitos relacionados

- RF58, RF59, RF60, RF61, RF67
- RN07, RN08, RN17, RN18

## Escopo incluído

- Métricas de descoberta.
- Métricas de contato.
- Métricas de responsividade.
- Métricas de reputação.
- Métricas de profissional.
- Dados preparados para ranking futuro.

## Fora do escopo

- Ranking algorítmico sofisticado.
- IA para recomendação.
- OpenSearch obrigatório.
- Otimização nacional.

## Critérios de aceite

- Sistema deve registrar buscas realizadas.
- Sistema deve registrar contatos iniciados por profissional, categoria e cidade.
- Sistema deve registrar sinais de responsividade.
- Sistema deve registrar sinais de disponibilidade.
- Sistema deve manter dados suficientes para ranking futuro.
- A V1 não deve implementar algoritmo sofisticado de ranking.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona base analítica e evolutiva para ranking futuro.
