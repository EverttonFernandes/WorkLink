# Guia de incidentes

## Classificação inicial

- P0: vazamento de dados sensíveis, indisponibilidade total ou comprometimento de autenticação.
- P1: falha crítica em contato, denúncia, avaliação ou moderação.
- P2: degradação parcial sem perda de dados.

## Ações mínimas

1. Registrar horário, versão, commit e ambiente.
2. Preservar logs com `correlation_id`.
3. Interromper rollout quando houver risco ativo.
4. Abrir correção com história/tarefa rastreável.
5. Publicar pós-incidente com causa, impacto e prevenção.

## Evidências úteis

- Logs estruturados da API.
- Histórico de auditoria sensível.
- Versão semântica e tag implantada.
- Resultado dos gates de CI/CD.
