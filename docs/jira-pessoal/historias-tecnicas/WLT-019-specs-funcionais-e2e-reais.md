# WLT-019 — Specs funcionais E2E reais

## Objetivo

Implementar os cenários reais de teste funcional/E2E da API em `functional-tests/src/specs/`, cobrindo os fluxos críticos da plataforma como caixa-preta.

## Valor técnico

A infraestrutura de testes funcionais existe (Jest, axios, lifecycle, http client), mas não há nenhum spec real implementado. Sem specs, o `make functional-test` não valida nenhum fluxo de negócio e o gate de CI passa vazio.

## RNFs relacionados

- RNF06, RNF14

## Escopo incluído

- Spec de autenticação do cliente por telefone e OTP.
- Spec de cadastro e busca de profissional por cidade e categoria.
- Spec de intenção de contato via WhatsApp.
- Spec de pós-contato estruturado.
- Spec de avaliação anônima sem expor autoria publicamente.
- Spec de denúncia de profissional.
- Spec de profissional bloqueado não aparecer na busca.
- Spec de usuário não autenticado não iniciar contato.
- Spec de usuário não acessar dados privados de outro usuário.
- Spec de profissional não acessar dados administrativos.
- Fixtures e seeders necessários para preparar e limpar massa de dados.

## Fora do escopo

- Testes de UI/tela mobile.
- Testes de carga ou performance.
- Importação de código Java ou conhecimento interno do backend.

## Critérios de aceite

- `functional-tests/src/specs/` deve conter ao menos um spec por fluxo obrigatório listado acima.
- Cada spec deve preparar massa, chamar endpoints HTTP, validar resposta e limpar massa.
- `make functional-test` deve executar os specs e falhar quando algum fluxo não passar.
- Os specs não devem importar código Java nem depender de detalhes internos do backend.
- A suite deve rodar dentro do container `functional-tests` do compose sem instalação local.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: fecha o gap de validação E2E dos fluxos críticos da V1.
