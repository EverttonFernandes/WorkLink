# Guia de testes

## Matriz oficial

```bash
make backend-static-analysis
make backend-unit-test
make backend-integration-test
make backend-image-build
make mobile-static-analysis
make mobile-unit-test
make mobile-screen-test
make mobile-integration-test
make functional-test
make test
```

## Regras

- Testes devem usar Given/When/Then.
- Backend e mobile exigem cobertura unitária mínima de 95%.
- Integração backend roda contra PostgreSQL em container.
- Testes funcionais só executam cenários reais quando existirem arquivos de spec.
- Testes mobile de integração dependem de device suportado no ambiente.
