# WLT-002 — Arquitetura modular hexagonal

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-002-arquitetura-modular-hexagonal.md`
- Ordem oficial: 02 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Definir e aplicar a arquitetura de monólito modular com DDD tático e Ports and Adapters no backend.

## Valor técnico

Cria uma fronteira explícita entre API, aplicação, domínio e infraestrutura, reduzindo acoplamento e impedindo que framework, banco ou integrações externas contaminem regras de negócio.

## RNFs relacionados

- RNF02
- RNF15

## Escopo incluído

- Definir bounded contexts iniciais do backend.
- Documentar camadas internas por contexto.
- Definir regras de dependência entre `api`, `application`, `domain` e `infrastructure`.
- Criar teste automatizado de arquitetura para impedir violações futuras.

## Fora do escopo

- Implementar regras funcionais do produto.
- Criar entidades, casos de uso ou repositórios sem demanda real.
- Criar microserviços.
- Criar CQRS completo.
- Criar Event Sourcing.
- Extrair serviços.

## Critérios de aceite

- Cada módulo deve ter responsabilidade clara.
- Domínio não deve depender de infraestrutura.
- Dependências externas devem ser acessadas por portas/adaptadores.
- Estrutura deve suportar os bounded contexts do épico técnico.
- Não deve haver abstração distribuída prematura.
