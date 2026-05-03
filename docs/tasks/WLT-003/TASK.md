# WLT-003 — PostgreSQL e consistência transacional

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-003-banco-postgresql-consistencia.md`
- Ordem oficial: 03 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Estabelecer PostgreSQL como fonte da verdade para dados transacionais críticos.

## Valor técnico

Garante base de persistência consistente para usuários, profissionais, contatos, avaliações, denúncias, disponibilidade, auditoria e administração.

## RNFs relacionados

- RNF02
- RNF15

## Escopo incluído

- Configuração do PostgreSQL em Docker Compose.
- Estratégia de migrations executável localmente.
- Diretriz de consistência forte para dados críticos.
- Diretriz de consistência eventual apenas para métricas, cache, ranking e dados derivados.

## Fora do escopo

- Read replicas.
- Banco distribuído.
- Event Sourcing.
- OpenSearch obrigatório.
- Modelagem funcional completa.
- JPA repositories antes das histórias de domínio.

## Critérios de aceite

- PostgreSQL deve ser a fonte primária dos dados transacionais.
- Dados críticos devem ser modelados para consistência forte.
- Dados derivados devem ser explicitamente classificados quando aceitarem consistência eventual.
- Migrations devem ser executáveis localmente.
- Cache não deve ser fonte da verdade.
