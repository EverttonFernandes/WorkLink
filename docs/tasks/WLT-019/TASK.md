# WLT-019 — Specs funcionais E2E reais

## História

Como guardião da qualidade técnica, quero specs funcionais HTTP reais cobrindo os fluxos críticos da V1 para que `make functional-test` deixe de passar vazio e passe a validar comportamento de negócio como caixa-preta.

## Valor

Fecha o gap atual da pipeline funcional, validando autenticação, descoberta, contato, pós-contato, avaliação, denúncia e regras de autorização usando apenas chamadas HTTP e massa determinística.

## Critérios de aceite

- `functional-tests/src/specs/` deve conter ao menos um spec por fluxo obrigatório.
- Cada spec deve preparar massa, chamar endpoints HTTP, validar resposta e limpar massa.
- `make functional-test` deve subir dependências necessárias e falhar quando algum cenário não passar.
- Os specs não devem importar código Java nem depender de detalhes internos do backend.
- A suite deve rodar dentro do container `functional-tests` do compose sem instalação local.
