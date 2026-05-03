# Functional Tests

Pasta dedicada aos testes funcionais/E2E do WorkLink.

Esta estrutura sera evoluida quando a API e os fluxos de negocio estiverem disponiveis.

## Execucao

```bash
make functional-test
```

O alvo usa Docker. Quando a suite funcional for criada, ela deve expor `functional-tests/run.sh` como ponto de entrada.

## Diretrizes

- cenarios em portugues;
- padrao `GIVEN`, `WHEN`, `THEN`;
- massa deterministica;
- cleanup/rollback obrigatorio;
- sem dependencia de base compartilhada manual.
