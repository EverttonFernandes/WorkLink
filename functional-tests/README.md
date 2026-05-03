# Functional Tests

Pasta dedicada aos testes funcionais/E2E do WorkLink.

Esta estrutura sera evoluida quando a API e os fluxos de negocio estiverem disponiveis.

## Execucao

```bash
make functional-test
```

O alvo usa Docker e executa `functional-tests/run.sh` como ponto de entrada.

Enquanto nao houver cenarios reais em `functional-tests/src/**/*.spec.js`, o runner registra `N/A` e encerra com sucesso.
Quando houver cenarios, o runner executa `npm ci` e `npm test` dentro do container.

## Diretrizes

- cenarios em portugues;
- padrao `GIVEN`, `WHEN`, `THEN`;
- massa deterministica;
- cleanup/rollback obrigatorio;
- sem dependencia de base compartilhada manual.
