# WorkLink API

Backend do WorkLink.

## Stack

- Java 21
- Spring Boot
- Maven

## Comandos esperados

```bash
make backend-static-analysis
make backend-unit-test
make backend-integration-test
make backend-test
make backend-image-build
```

## Observacao

O projeto exige JDK 21. As validacoes devem rodar em Docker pelo `compose.yml`, sem exigir JDK 21 ou Maven instalados
diretamente na maquina.

## Documentação

- OpenAPI: `../docs/api/openapi.yaml`
- Arquitetura modular: `../docs/arquitetura/backend-modular-hexagonal.md`
- C4 Model: `../docs/arquitetura/c4-model.md`
- Segurança: `../docs/seguranca/`
- Variáveis de ambiente: `../docs/operacao/guia-variaveis-ambiente.md`
