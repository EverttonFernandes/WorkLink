---
name: code-style
description: Garante consistência de código usando compilação e análise estática (Java/Gradle).
required_env: []
---

# Adaptação para Este Projeto

Neste projeto, esta skill deve validar o código em coerência com:

- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Regra de Escopo

Você não valida apenas se o projeto compila.

Você também deve considerar:

- se a estrutura do código continua coerente com a arquitetura
- se há sinais de quebra óbvia de organização entre camadas
- se a mudança introduziu problemas estruturais que apareceriam já em compilação ou build
- se há nomes obviamente genéricos, abreviados ou pouco didáticos em código, testes, scripts ou configuração como código

## Regra de Uso pelo Ralph Loop

Quando invocada pelo `executor-agent` ou `qa-agent`, esta skill serve como apoio para:

- compilação
- validação de estilo
- validação de build
- confirmação de que a base técnica da história não foi quebrada

# Capacidade: Verificar e Corrigir (`enforce-style`)

Esta skill executa o ciclo de verificação e correção para projetos Java com Gradle.

## Instrução para o Agente

1. **Detecção de Build Tool**:
    - Verifique se existe `gradlew` na raiz do projeto.
    - Se não existir: Verifique se existe `mvnw` ou `pom.xml` (Maven).
    - Se nenhum encontrado: ⚠️ Avise "Sem build tool detectada" e encerre.

2. **Compilação (Fase 1)**:
    - **Gradle**: Execute `./gradlew compileJava` (compila sem rodar testes).
    - **Maven**: Execute `./mvnw compile -DskipTests`.
    - **Se passar (Exit 0)**: ✅ SUCESSO COMPILAÇÃO.

3. **Verificação de Lint (Fase 2)**:
   Verifique se o projeto tem ferramentas de análise estática configuradas:
    - **Checkstyle**: `grep -q 'checkstyle' build.gradle` → Se sim: `./gradlew checkstyleMain`.
    - **Spotless**: `grep -q 'spotless' build.gradle` → Se sim: `./gradlew spotlessCheck`.
    - **PMD**: `grep -q 'pmd' build.gradle` → Se sim: `./gradlew pmdMain`.
    - **Nenhum configurado**: ⚠️ Avise "Sem linter configurado — validando apenas compilação e build" e pule para Fase
      3.

4. **Build Completo (Fase 3)**:
    - **Gradle**: Execute `./gradlew build -x test` (build sem testes — testes são responsabilidade do `test-runner`).
    - **Maven**: Execute `./mvnw package -DskipTests`.
    - Inclui processamento de annotations (Lombok, MapStruct, etc.) e empacotamento.
    - **Se passar**: ✅ SUCESSO BUILD.

5. **Correção Manual (Fase 4 - Se Fase 1, 2 ou 3 falhar)**:
    - Analise o output do erro.
    - Identifique o arquivo e a linha.
    - **AÇÃO**: Edite o código para resolver o erro de compilação ou regra.
    - 🛑 **PROIBIDO**: Não use `@SuppressWarnings` a menos que seja a ÚNICA solução tecnicamente viável e justificada.
    - Repita a verificação do que falhou. Se falhar 3 vezes, aborte.

## Sinais de Atenção Neste Projeto

Mesmo que a compilação passe, considere isso um sinal de alerta para o agente chamador se encontrar:

- organização claramente incoerente com a arquitetura em camadas
- mistura acidental entre domínio e infraestrutura
- código excessivamente genérico ou confuso em nomes
- teste sem blocos `GIVEN`, `WHEN`, `THEN`
- classes, métodos, variáveis, fixtures, seeders, helpers ou workflows com nomes abreviados ou opacos

Esses pontos podem não quebrar o build, mas devem ser tratados nas etapas seguintes do fluxo.

## Notas sobre Projetos Multi-Módulo

- Em projetos Gradle multi-módulo (vários `subprojects` em `settings.gradle`):
    - `./gradlew compileJava` compila **todos** os módulos.
    - `./gradlew :modulo:compileJava` compila apenas um módulo específico.
    - Se o erro for em um módulo específico, compile apenas ele para feedback mais rápido.
