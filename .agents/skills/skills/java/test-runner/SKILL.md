---
name: test-runner
description: Gerencia a execução de testes unitários e de integração para projetos Java (Gradle/Maven).
required_env: []
---

# Adaptação para Este Projeto

Neste projeto, esta skill deve operar em coerência com:

- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/tasks/`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`

## Regra de Escopo

Você não valida apenas se testes passaram.

Você deve considerar que, neste projeto:

- testes unitários seguem padrão obrigatório
- testes unitários devem manter cobertura mínima de 95%
- testes funcionais precisam comprovar comportamento real
- uma história só pode sustentar a próxima se os testes relevantes estiverem aprovados

## Regra de Continuidade

Quando esta skill for usada pelo `qa-agent`:

- os resultados dela ajudam a decidir se a história está pronta para a próxima
- passar em parte dos testes não é suficiente para liberar continuidade

# Capacidade: Executar Testes Unitários (`run-unit`)

1. **Detecção de Build Tool**:
    - Verifique se existe `gradlew` na raiz do projeto → **Gradle**.
    - Se não, verifique se existe `mvnw` ou `pom.xml` → **Maven**.
    - Se nenhum encontrado: ⚠️ Avise "Sem build tool detectada" e encerre.

2. **Execução**:
    - **Gradle**: `./gradlew test`
    - **Maven**: `./mvnw test`
    - Isso executa os testes do source set `src/test/java` (JUnit).

3. **Análise do Resultado**:
    - **Se passar (Exit 0)**: ✅ SUCESSO.
    - **Se falhar**: Analise o output. Os relatórios detalhados ficam em:
        - **Gradle**: `build/reports/tests/test/index.html`
        - **Maven**: `target/surefire-reports/`

### Regra adicional deste projeto

Quando possível, o agente chamador deve cruzar o resultado dos testes com o que a história atual exige em
`docs/tasks/<KEY>/IMPLEMENTATION.md`.

# Capacidade: Executar Testes Funcionais / Integração (`run-functional`)

1. **Detecção**:
   Verifique se o projeto tem um source set de integração configurado:
    - **Gradle**: Procure no `build.gradle` por `integrationTest` ou `functionalTest` (task customizada).
    - **Maven**: Procure por `maven-failsafe-plugin` no `pom.xml`.
    - **Makefile**: Verifique se há um target como `functional-test` ou `integration-test`.

2. **Execução** (em ordem de prioridade):
    - **Gradle task**: `./gradlew integrationTest` (ou o nome da task encontrada).
    - **Maven Failsafe**: `./mvnw verify -DskipUnitTests`.
    - **Makefile**: `make functional-test` ou `make integration-test`.
    - Se nenhum encontrado: ⚠️ Avise "Nenhuma task de teste funcional/integração detectada" e ignore.

3. **Análise do Resultado**:
    - **Se passar (Exit 0)**: ✅ SUCESSO.
    - **Se falhar**: Relatórios em:
        - **Gradle**: `build/reports/tests/integrationTest/index.html`
        - **Maven**: `target/failsafe-reports/`

### Regra adicional deste projeto

Nos cenários funcionais deste projeto, a leitura do resultado deve considerar:

- validação end-to-end
- confirmação por `GET` quando aplicável
- mensagens `key` e `value` nos cenários de falha
- aptidão da história para sustentar a próxima

# Capacidade: Executar Testes com Coverage (`run-coverage`)

1. **Detecção**:
    - **Gradle**: Verifique se o `build.gradle` inclui o plugin `jacoco`.
    - **Maven**: Verifique se o `pom.xml` inclui `jacoco-maven-plugin`.
    - Se não encontrar: ⚠️ Avise "Sem plugin de coverage configurado" e ignore.

2. **Execução**:
    - **Gradle**: `./gradlew test jacocoTestReport`
    - **Maven**: `./mvnw test jacoco:report`

3. **Validação**:
    - Verifique se o relatório foi gerado:
        - **Gradle**: `build/reports/jacoco/test/html/index.html`
        - **Maven**: `target/site/jacoco/index.html`
    - O threshold mínimo oficial do projeto é 95% para cobertura unitária.
    - Se existir `jacocoTestCoverageVerification`, execute `./gradlew jacocoTestCoverageVerification`.
    - Se o projeto ainda não tiver verificação configurada, reporte a lacuna como bloqueio para CI/CD e valide manualmente o percentual no relatório gerado.
    - Se a cobertura unitária observada for menor que 95%, o resultado é `FAIL`.

### Regra adicional deste projeto

Coverage não substitui aderência ao `padroes-de-testes.md`.

O agente chamador deve tratar coverage como gate obrigatório e também como evidência complementar de qualidade. Passar 95% não libera testes ruins, frágeis ou desalinhados com o padrão oficial.

# Capacidade: Executar Tudo (`run-all`)

1. Execute `run-unit`.
2. Execute `run-functional`.
    - Se qualquer um falhar, o processo deve falhar.

## Notas sobre Projetos Multi-Módulo

- Em projetos Gradle multi-módulo:
    - `./gradlew test` executa testes de **todos** os módulos.
    - `./gradlew :modulo:test` executa apenas os testes de um módulo.
    - Se o erro for em um módulo específico, rode apenas ele para feedback mais rápido.
