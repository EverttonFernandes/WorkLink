# ADR-0004 — Base para ranking futuro sem algoritmo sofisticado na V1

## Status

Aceita.

## Contexto

O WorkLink precisa medir descoberta, contato, responsividade, disponibilidade e reputação, mas um ranking opaco antes de
dados reais criaria complexidade e risco de injustiça.

## Decisão

A V1 registra sinais funcionais e expõe agregados administrativos, mantendo `rankingAlgorithmEnabled=false`.

## Consequências

- O produto coleta dados para aprendizado futuro.
- Nenhum profissional é privilegiado por score opaco na V1.
- Uma futura decisão de ranking deve virar nova ADR, com critérios explicáveis.
