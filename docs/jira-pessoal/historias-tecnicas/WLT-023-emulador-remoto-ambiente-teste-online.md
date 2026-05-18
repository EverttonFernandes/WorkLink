# WLT-023 — Emulador remoto e ambiente de teste online na pipeline

## Objetivo

Habilitar execução automática dos testes de integração mobile em um emulador Android dentro da pipeline, sem depender de setup local com Flutter SDK ou device físico.

## Valor técnico

Hoje o projeto valida contrato HTTP mobile x backend em Docker, mas a suíte `integration_test/` ainda fica como `N/A` quando não existe device disponível. Isso deixa um gap entre o app Flutter e a validação real em runtime. Esta história fecha esse gap no CI.

## RNFs relacionados

- RNF03
- RNF13
- RNF14

## Escopo incluído

- Criar job dedicado na CI para testes mobile com Android Emulator.
- Subir backend e dependências de apoio durante a execução do job.
- Ajustar scripts mobile para executar `test/integration` e `integration_test/` contra emulador.
- Configurar o app para acessar o backend hospedado na máquina do runner via `10.0.2.2`.
- Registrar documentação mínima de operação e limitações.

## Fora do escopo

- Emulador iOS em runner macOS.
- Ambiente remoto persistente de QA.
- Appium, Selenium Grid ou device farm terceirizada.

## Critérios de aceite

- A pipeline executa testes de integração mobile com Android Emulator.
- O backend sobe no runner com Docker Compose e fica acessível ao emulador.
- A suíte `integration_test/` deixa de ficar `N/A` no CI.
- O fluxo continua sem exigir instalação direta de Flutter na máquina do usuário.
- A documentação da entrega reflete claramente o limite local versus o que roda no CI.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona uma capacidade nova de validação automática do produto na pipeline.
