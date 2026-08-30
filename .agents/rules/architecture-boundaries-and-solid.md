---
name: architecture-boundaries-and-solid
description: Proteger fronteiras de arquitetura, SOLID pragmático e ports/adapters nas mudanças do WorkLink.
applies_when:
  - criar regra de negócio
  - integrar serviço externo
  - alterar domínio ou aplicação
  - revisar arquitetura
source_docs:
  - docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md
complements:
  - .agents/rules/clean-code-readable-names.md
  - .agents/rules/refactor-after-functional-green.md
  - .agents/rules/test-evidence-quality.md
priority: high
---

# Regra: Fronteiras E SOLID

Toda mudança deve preservar domínio e aplicação livres de detalhes de framework, banco, cache, HTTP, storage ou SDK externo.

## Complementos

- Use junto de `clean-code-readable-names.md` para garantir nomes alinhados ao domínio.
- Use junto de `refactor-after-functional-green.md` na limpeza final.
- Use junto de `test-evidence-quality.md` para provar regra crítica sem framework.

## Princípios

- SRP: cada classe, função ou widget deve ter uma responsabilidade clara.
- OCP: extensões previsíveis devem evitar alteração em cadeia.
- LSP: contratos precisam ser substituíveis sem surpresa.
- ISP: interfaces devem ser pequenas e específicas.
- DIP: domínio e aplicação dependem de abstrações, não de infraestrutura.

## Ports And Adapters

Use portas quando a regra de negócio atravessar uma fronteira real:

- banco de dados;
- API externa;
- mensageria;
- autenticação externa;
- storage;
- cache;
- envio de email, SMS ou WhatsApp.

Adapters devem conter detalhes técnicos. Use cases devem conter intenção de negócio.

## Camadas

Controllers, handlers, jobs, repositories, providers e clients são borda.

Eles podem converter contratos, validar entrada técnica, chamar use cases e mapear resposta.

Eles não devem conter regra de negócio, decidir fluxo de produto, acessar domínio por atalhos ou expor enum técnico ao usuário final.

## Pragmatismo

Não crie abstração sem fronteira relevante.

Evite `Service` genérico, domínio anêmico, SDK externo em use case, pattern por estética e microarquitetura prematura.

## Gate De Revisão

Antes de concluir:

- confirme que regra crítica é testável sem framework;
- confirme que dependências externas passam por porta/adaptador;
- confirme que nomes revelam intenção de negócio;
- registre qualquer dívida arquitetural remanescente.
