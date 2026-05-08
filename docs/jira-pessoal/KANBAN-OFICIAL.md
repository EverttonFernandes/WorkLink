# Kanban Oficial Unificado — WorkLink V1

Fonte oficial de execução cronológica do projeto.

Este arquivo combina histórias de negócio (`WL-*`) e histórias técnicas (`WLT-*`) em uma única fila. Os agentes devem seguir esta ordem, independentemente de a história ser funcional ou não funcional.

Regra: a próxima entrega oficial é sempre a primeira história ainda não concluída neste kanban.

Para histórias que constroem telas, consulte também [MAPA-PROTOTIPOS-TELAS.md](MAPA-PROTOTIPOS-TELAS.md). O mapa vincula cada protótipo em `docs/prototipos-de-tela/` à história responsável, requisitos relacionados e gates esperados.

## Critério de `Done`

Uma história só pode ir para `Done` quando:

- critérios de aceite foram atendidos
- testes aplicáveis passaram
- gates de QA, SRE, Segurança, Arquitetura e Final Reviewer foram tratados quando aplicáveis
- documentação da entrega foi criada em `docs/entregas/`
- commit de fechamento foi criado
- tag semântica aponta para o mesmo hash do commit

## To Do

| Ordem | História | Tipo | Título | Relação com outras histórias | Execução | Versão |
|-------|----------|------|--------|-------------------------------|----------|--------|
| 14 | [WL-005](historias/WL-005-perfil-publico-profissional.md) | Negócio | Perfil público detalhado do profissional | Depende de listagem | Separada | MINOR |
| 15 | [WLT-014](historias-tecnicas/WLT-014-storage-seguro-arquivos.md) | Técnica | Storage seguro de arquivos | Pré-requisito para foto, portfólio e evidências | Separada | MINOR |
| 16 | [WL-006](historias/WL-006-cadastro-progressivo-profissional.md) | Negócio | Cadastro progressivo do profissional | Usa storage para foto/portfólio quando aplicável | Junto de validações de storage | MINOR |
| 17 | [WL-007](historias/WL-007-badges-confianca-completude.md) | Negócio | Badges de confiança e completude | Depende de cadastro progressivo | Separada | MINOR |
| 18 | [WL-008](historias/WL-008-disponibilidade-profissional.md) | Negócio | Disponibilidade do profissional | Depende de perfil profissional | Separada | MINOR |
| 19 | [WLT-013](historias-tecnicas/WLT-013-criptografia-protecao-dados.md) | Técnica | Criptografia e proteção de dados | Pré-requisito para auth, documentos, denúncias e tokens | Separada | MINOR |
| 20 | [WLT-009](historias-tecnicas/WLT-009-autenticacao-sessoes-tokens.md) | Técnica | Autenticação segura, sessões e tokens | Pré-requisito técnico para autenticação do cliente | Separada | MINOR |
| 21 | [WLT-010](historias-tecnicas/WLT-010-autorizacao-perfis-ownership.md) | Técnica | Autorização por perfil e ownership | Pré-requisito para ações sensíveis | Separada | MINOR |
| 22 | [WLT-011](historias-tecnicas/WLT-011-rastreabilidade-auditoria-acoes-sensiveis.md) | Técnica | Autenticidade, rastreabilidade e auditoria | Pré-requisito para contato, avaliação, denúncia e admin | Separada | MINOR |
| 23 | [WLT-012](historias-tecnicas/WLT-012-lgpd-privacidade-dados-sensiveis.md) | Técnica | LGPD, privacidade e minimização | Pré-requisito para dados pessoais e anonimato | Separada | MINOR |
| 24 | [WLT-015](historias-tecnicas/WLT-015-observabilidade-logs-metricas.md) | Técnica | Observabilidade, logs e métricas | Pré-requisito para rastrear fluxos críticos | Separada | MINOR |
| 25 | [WL-009](historias/WL-009-autenticacao-cliente-telefone.md) | Negócio | Autenticação simplificada do cliente por telefone | Depende de auth segura, privacidade e auditoria | Junto dos gates de segurança | MINOR |
| 26 | [WL-010](historias/WL-010-contato-whatsapp-intencao.md) | Negócio | Contato via WhatsApp e intenção de contato | Depende de autenticação, autorização e auditoria | Junto dos gates de segurança | MINOR |
| 27 | [WL-011](historias/WL-011-pos-contato-estruturado.md) | Negócio | Pós-contato estruturado | Depende de intenção de contato rastreável | Separada | MINOR |
| 28 | [WL-012](historias/WL-012-avaliacao-anonima-rastreavel.md) | Negócio | Avaliação anônima com rastreabilidade interna | Depende de pós-contato, LGPD e auditoria | Junto dos gates de segurança | MINOR |
| 29 | [WL-013](historias/WL-013-exibicao-avaliacoes-perfil.md) | Negócio | Exibição de avaliações no perfil | Depende de avaliação anônima | Separada | MINOR |
| 30 | [WL-014](historias/WL-014-denuncia-profissional.md) | Negócio | Denúncia de profissional | Depende de storage, auditoria, LGPD e autorização | Junto dos gates de segurança | MINOR |
| 31 | [WL-015](historias/WL-015-perfil-usuario.md) | Negócio | Perfil do usuário cliente | Depende de autenticação e autorização | Junto dos gates de privacidade | MINOR |
| 32 | [WLT-016](historias-tecnicas/WLT-016-disponibilidade-escalabilidade-stateless.md) | Técnica | Disponibilidade e escalabilidade stateless | Endurece operação antes de admin/métricas | Separada | MINOR |
| 33 | [WL-016](historias/WL-016-admin-minimo-moderacao.md) | Negócio | Administração mínima e moderação | Depende de autorização, auditoria e observabilidade | Junto dos gates de segurança/SRE | MINOR |
| 34 | [WL-017](historias/WL-017-metricas-ranking-futuro.md) | Negócio | Métricas funcionais e base para ranking futuro | Depende dos eventos principais e observabilidade | Separada | MINOR |
| 35 | [WLT-018](historias-tecnicas/WLT-018-documentacao-adrs-release-mobile.md) | Técnica | Documentação técnica, ADRs e release mobile | Fechamento técnico/documental da V1 | Separada | MINOR |

## Doing

_Vazio._

## Review

_Vazio._

## Done

| Ordem | História | Tipo | Título | Relação com outras histórias | Execução | Versão | Entrega |
|-------|----------|------|--------|-------------------------------|----------|--------|---------|
| 01 | [WLT-001](historias-tecnicas/WLT-001-monorepo-stack-base.md) | Técnica | Monorepo e stack base | Pré-requisito geral | Separada | MINOR | [Entrega WLT-001](../entregas/WLT-001-monorepo-stack-base.md) |
| 02 | [WLT-002](historias-tecnicas/WLT-002-arquitetura-modular-hexagonal.md) | Técnica | Arquitetura modular hexagonal | Pré-requisito geral | Separada | MINOR | [Entrega WLT-002](../entregas/WLT-002-arquitetura-modular-hexagonal.md) |
| 03 | [WLT-003](historias-tecnicas/WLT-003-banco-postgresql-consistencia.md) | Técnica | PostgreSQL e consistência transacional | Pré-requisito para dados funcionais | Separada | MINOR | [Entrega WLT-003](../entregas/WLT-003-postgresql-consistencia-transacional.md) |
| 04 | [WLT-004](historias-tecnicas/WLT-004-ambiente-local-docker-makefile.md) | Técnica | Ambiente local reproduzível | Pré-requisito para execução local e testes | Separada | MINOR | [Entrega WLT-004](../entregas/WLT-004-ambiente-local-docker-makefile.md) |
| 05 | [WLT-005](historias-tecnicas/WLT-005-configuracao-segura-env-secrets.md) | Técnica | Configuração segura e secrets | Pré-requisito para backend, storage, auth e CI | Separada | MINOR | [Entrega WLT-005](../entregas/WLT-005-configuracao-segura-env-secrets.md) |
| 06 | [WLT-006](historias-tecnicas/WLT-006-qualidade-estatica-backend-mobile.md) | Técnica | Qualidade estática e clean code | Pré-requisito para gates de qualidade | Separada | MINOR | [Entrega WLT-006](../entregas/WLT-006-qualidade-estatica-clean-code.md) |
| 07 | [WLT-007](historias-tecnicas/WLT-007-testabilidade-backend.md) | Técnica | Testabilidade backend | Pré-requisito para histórias backend e cobertura unitária mínima de 95% | Separada | MINOR | [Entrega WLT-007](../entregas/WLT-007-testabilidade-backend.md) |
| 08 | [WLT-008](historias-tecnicas/WLT-008-testabilidade-mobile.md) | Técnica | Testabilidade mobile | Pré-requisito para telas, fluxos mobile e cobertura unitária mínima de 95% | Separada | MINOR | [Entrega WLT-008](../entregas/WLT-008-testabilidade-mobile.md) |
| 09 | [WLT-017](historias-tecnicas/WLT-017-cicd-builds-scans.md) | Técnica | CI/CD, builds e scans | Sustenta validação contínua e bloqueia cobertura unitária abaixo de 95% | Separada | MINOR | [Entrega WLT-017](../entregas/WLT-017-cicd-builds-scans.md) |
| 10 | [WL-001](historias/WL-001-fundacao-categorias-cidades-profissionais.md) | Negócio | Fundação de categorias, cidades e profissionais mínimos | Usa base técnica inicial | Separada | MINOR | [Entrega WL-001](../entregas/WL-001-fundacao-categorias-cidades-profissionais.md) |
| 11 | [WL-002](historias/WL-002-selecao-cidades-localizacao.md) | Negócio | Seleção de cidades e localização atual | Depende de fundação de cidades | Separada | MINOR | [Entrega WL-002](../entregas/WL-002-selecao-cidades-localizacao.md) |
| 12 | [WL-003](historias/WL-003-descoberta-busca-filtros.md) | Negócio | Descoberta por categoria, cidade e palavra-chave | Depende de cidades, categorias e profissionais | Separada | MINOR | [Entrega WL-003](../entregas/WL-003-descoberta-busca-filtros.md) |
| 13 | [WL-004](historias/WL-004-listagem-profissionais.md) | Negócio | Listagem de profissionais com sinais mínimos | Depende de descoberta | Separada | MINOR | [Entrega WL-004](../entregas/WL-004-listagem-profissionais.md) |

## Histórias técnicas que podem ser executadas separadamente

- WLT-001, WLT-002, WLT-003, WLT-004, WLT-005, WLT-006, WLT-007, WLT-008, WLT-013, WLT-014, WLT-015, WLT-016, WLT-017, WLT-018.

## Histórias técnicas que devem estar prontas antes de histórias de negócio específicas

| Técnica | Deve anteceder | Motivo |
|---------|----------------|--------|
| WLT-003 | WL-001, WL-002, WL-003 | persistência e consistência dos dados base |
| WLT-007 | WL-001 em diante | testes backend, funcionais e cobertura unitária mínima de 95% |
| WLT-008 | histórias com tela mobile | testes mobile e cobertura unitária mínima de 95% |
| WLT-014 | WL-006, WL-014 | foto, portfólio, anexos e evidências |
| WLT-013 | WL-009, WL-012, WL-014, WL-015 | proteção de dados sensíveis |
| WLT-009 | WL-009 | autenticação segura |
| WLT-010 | WL-010, WL-012, WL-014, WL-015, WL-016 | ownership e perfis |
| WLT-011 | WL-010, WL-011, WL-012, WL-014, WL-016 | autoria rastreável |
| WLT-012 | WL-012, WL-014, WL-015 | LGPD e anonimato |
| WLT-015 | WL-009 em diante | rastreabilidade operacional de fluxos críticos |
| WLT-016 | WL-016, WL-017 | prontidão operacional antes de admin/métricas |

## Observações de execução

- As histórias técnicas de base devem ser pequenas e entregáveis; não devem virar uma fase infinita de fundação.
- Uma história de negócio pode carregar ajustes técnicos pequenos se eles forem estritamente necessários para a entrega, mas não deve absorver uma história técnica inteira sem rastreabilidade.
- Se uma história funcional tocar segurança, SRE ou privacidade, os gates especializados devem ser executados mesmo que a história técnica correspondente já esteja `Done`.
- Se uma história funcional construir ou alterar tela, os protótipos vinculados em `MAPA-PROTOTIPOS-TELAS.md` devem ser considerados insumo obrigatório junto dos critérios de aceite, RNFs e padrões de código/teste.
