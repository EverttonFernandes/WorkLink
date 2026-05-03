# Código Limpo

## Objetivo

Definir o padrão obrigatório de escrita de código deste projeto com foco em:

- legibilidade
- intenção explícita
- nomenclatura didática
- baixo acoplamento
- alta coesão

Neste projeto, `Clean Code` deve ser aplicado com rigor.

## Escopo obrigatório

Estas regras valem para todo código do projeto, sem exceção:

- backend
- frontend web, se existir
- mobile Flutter
- testes unitários
- testes de integração
- testes funcionais/E2E
- testes de widget
- testes mobile
- scripts de automação
- pipeline e configuração como código
- seeders, fixtures, builders, factories e helpers de teste

Não existe área "menos importante" para legibilidade. Código de teste, código de infraestrutura e código de apoio devem
ser tão claros quanto código de produção.

## Regra Principal

Nomes de:

- variáveis
- classes
- atributos
- métodos
- parâmetros
- constantes
- pacotes
- arquivos
- cenários de testes unitários
- cenários de testes de integração
- cenários de testes funcionais
- cenários de testes mobile
- componentes
- widgets
- hooks
- stores
- providers
- scripts
- workflows

não devem ser simplificados.

Os nomes devem ser:

- totalmente didáticos
- fáceis de entender
- explícitos quanto à intenção
- legíveis por qualquer pessoa do time
- longos o suficiente para remover ambiguidade

## Abreviações são proibidas

Não queremos abreviações em nomes de código.

Não usar:

- nomes curtos demais
- siglas opacas
- palavras truncadas
- encurtamentos desnecessários

Exemplos proibidos:

- `acc`
- `usr`
- `msg`
- `dtoConv`
- `bal`
- `srcAcc`
- `dstAcc`
- `amt`
- `resp`
- `req`
- `svc`
- `repo`
- `val`
- `cfg`
- `obj`

Exemplos aceitáveis:

- `sourceAccount`
- `targetAccount`
- `transferAmount`
- `notificationMessage`
- `transferRequest`
- `transferResponse`
- `accountRepository`
- `businessValidationResult`
- `transferRequestConverter`

## Nomes devem explicar a intenção

Cada nome deve responder sozinho, sem depender de contexto implícito:

- o que representa
- qual sua responsabilidade
- em qual contexto ele existe

### Exemplos

Ruim:

```java
BigDecimal value;
Account acc;
void execute();
```

Bom:

```java
BigDecimal transferAmount;
Account sourceAccount;
void executeTransferBetweenAccounts();
```

## Classes

Classes devem ter nomes que reflitam claramente seu papel.

Exemplos:

- `TransferController`
- `TransferRequestConverter`
- `TransferService`
- `AccountRepository`
- `ShouldHaveSufficientBalance`
- `BusinessValidationException`

Evitar nomes vagos:

- `Processor`
- `Helper`
- `Manager`
- `Util`
- `BaseService`
- `CommonService`

Se uma classe só faz sentido com nome genérico, isso normalmente indica design ruim.

## Métodos

Métodos devem ter nomes verbais e explícitos.

Devem indicar claramente:

- a ação executada
- o contexto da ação
- a condição relevante quando necessário

Exemplos bons:

- `transferAmountBetweenAccounts`
- `validateIfSourceAccountHasEnoughBalance`
- `sendNotificationAfterSuccessfulTransfer`
- `loadAccountByIdentifier`
- `createTransactionForDebit`

Exemplos ruins:

- `process`
- `handle`
- `doTransfer`
- `validate`
- `run`
- `execute`

## Variáveis e atributos

Variáveis e atributos devem ser autoexplicativos.

Exemplos bons:

- `sourceAccountBalanceBeforeTransfer`
- `targetAccountBalanceAfterTransfer`
- `businessValidationMessages`
- `transferCreatedAt`
- `accountTransactionList`

Exemplos ruins:

- `data`
- `info`
- `result`
- `temp`
- `obj`
- `list`
- `item`

Nomes genéricos só são aceitáveis quando o escopo é mínimo e o significado é óbvio.

## Parâmetros

Parâmetros devem ser tão claros quanto os atributos.

Exemplos:

```java
public void transferAmountBetweenAccounts(Account sourceAccount, Account targetAccount, BigDecimal transferAmount)
```

Evitar:

```java
public void transfer(Account a1, Account a2, BigDecimal value)
```

## Constantes

Constantes devem ter nomes longos o suficiente para expressar significado real.

Exemplos:

- `DEFAULT_INITIAL_ACCOUNT_BALANCE`
- `MAXIMUM_TRANSFER_AMOUNT_PER_OPERATION`
- `INSUFFICIENT_BALANCE_MESSAGE_KEY`

Evitar:

- `MAX_VALUE`
- `DEFAULT_VALUE`
- `MSG_1`

## Testes unitários

Os cenários de testes unitários devem ser totalmente didáticos.

### Regras obrigatórias

- o nome do método de teste deve ser claro
- o `@DisplayName` deve explicar exatamente o comportamento testado
- o corpo do teste deve seguir o padrão `GIVEN`, `WHEN`, `THEN`
- não usar nomes resumidos
- não usar descrições genéricas
- não economizar nome em variáveis de massa, mocks, respostas ou resultados esperados

Exemplo bom:

```java
@Test
@DisplayName("Deve impedir a transferência quando a conta de origem não possuir saldo suficiente")
void shouldPreventTransferWhenSourceAccountDoesNotHaveEnoughBalance() {
    // GIVEN
    ...

    // WHEN
    ...

    // THEN
    ...
}
```

Exemplo ruim:

```java
@Test
@DisplayName("Deve validar transferência")
void shouldValidateTransfer() {
}
```

## Testes de integração

Testes de integração também devem ser escritos para leitura humana.

### Regras obrigatórias

- nomes de classes devem explicar a integração validada
- nomes de métodos devem explicar cenário, ação e resultado
- o corpo do teste deve seguir `GIVEN`, `WHEN`, `THEN`
- massa de dados, containers, repositories e fixtures devem ter nomes completos
- não usar nomes genéricos como `repositoryTest`, `data`, `entity`, `saved`, `response`

Exemplo bom:

```java
@Test
@DisplayName("Deve persistir denúncia com autoria rastreável quando o usuário autenticado denuncia um profissional")
void shouldPersistReportWithTraceableAuthorWhenAuthenticatedUserReportsProfessional() {
    // GIVEN
    ...

    // WHEN
    ...

    // THEN
    ...
}
```

## Testes funcionais

Os cenários de testes funcionais também devem ser totalmente didáticos.

### Regras obrigatórias

- `describe` deve ser explícito
- `it` deve ser explícito
- o corpo do teste deve seguir `GIVEN`, `WHEN`, `THEN`
- o texto deve deixar claro o contexto, a ação e o resultado esperado
- não usar descrições vagas
- não usar descrições resumidas
- fixtures, seeders, payloads e responses devem ter nomes completos

Exemplo bom:

```javascript
describe("POST /transfers deve validar as regras de negócio relacionadas à transferência entre contas", () => {
  it("deve retornar saldo insuficiente quando a conta de origem não possuir saldo suficiente para concluir a transferência", async () => {
    // GIVEN
    ...

    // WHEN
    ...

    // THEN
    ...
  })
})
```

Exemplo ruim:

```javascript
describe("Transfer validations", () => {
  it("should fail", async () => {
  })
})
```

## Frontend e mobile

Código de interface deve seguir o mesmo nível de clareza.

### Componentes, widgets e telas

Nomes devem explicar o papel visual e funcional.

Exemplos bons:

- `ProfessionalPublicProfileScreen`
- `ProfessionalAvailabilityBadge`
- `AnonymousReviewSummaryCard`
- `CitySelectionAutocomplete`
- `ContactProfessionalByWhatsAppButton`

Exemplos ruins:

- `CardItem`
- `MainWidget`
- `ProfileBox`
- `ActionButton`
- `ScreenData`

### Estados, controllers, hooks e providers

Nomes devem deixar claro qual fluxo ou dado controlam.

Exemplos bons:

- `professionalSearchFiltersController`
- `selectedServiceCategoryNotifier`
- `anonymousReviewSubmissionState`
- `contactIntentCreationResult`
- `currentUserProfileFormController`

Exemplos ruins:

- `state`
- `ctrl`
- `provider`
- `data`
- `res`

## Scripts, pipelines e configuração como código

Scripts e workflows também precisam ser limpos.

### Regras obrigatórias

- jobs, steps e scripts devem ter nomes que expliquem o objetivo real
- variáveis de ambiente locais no script devem ser explícitas
- targets de Makefile devem ser claros
- comandos críticos devem estar separados por responsabilidade
- não usar nomes opacos para steps de CI/CD

Exemplos bons:

- `run-backend-unit-tests-with-coverage`
- `validate-flutter-unit-test-coverage`
- `build-android-release-artifact`
- `publish-sonar-quality-gate-report`

Exemplos ruins:

- `test`
- `check`
- `job1`
- `run`
- `misc`

## Métodos e classes pequenas

Além da nomenclatura, Clean Code exige:

- métodos pequenos
- classes com responsabilidade clara
- baixo número de parâmetros
- separação explícita entre camadas
- ausência de duplicação desnecessária
- ausência de código morto
- ausência de condicionais confusas que escondem regra de negócio

Se o nome está ficando confuso ou genérico, normalmente o problema não é só o nome, mas o design.

## Responsabilidade única

Cada unidade deve fazer uma coisa bem definida.

Exemplos:

- converter converte e valida entrada
- specification valida regra de negócio
- service orquestra caso de uso
- repository persiste e consulta dados

Quando uma classe ou método acumula responsabilidades, o nome normalmente vira genérico ou artificial. Isso é um sinal
para refatorar.

## Comentários

Comentários não devem compensar nomes ruins.

Primeiro, corrigir:

- nome da classe
- nome do método
- nome da variável
- estrutura do código

Só depois disso, se ainda necessário, comentar.

Regra prática:

- prefira código autoexplicativo
- use comentário apenas quando o porquê não estiver evidente

## Proibições

Não será aceito:

- abreviação sem necessidade real
- nome genérico sem contexto
- nome ambíguo
- nome curto demais para algo relevante
- método com nome vago
- classe com nome genérico como `Helper`, `Util`, `Manager` ou `Processor`
- testes com cenários resumidos ou pouco didáticos
- testes sem `GIVEN`, `WHEN`, `THEN`
- código frontend/mobile com componentes ou estados genéricos
- scripts e steps de pipeline com nomes opacos
- variáveis como `data`, `result`, `response`, `item` ou `value` quando o contexto exigir significado real
- comentários usados para compensar nomes ruins

## Checklist

- nomes de variáveis são explícitos
- nomes de métodos são verbais e claros
- nomes de classes descrevem responsabilidade
- atributos não usam abreviações
- parâmetros são autoexplicativos
- testes unitários têm nomes didáticos
- testes unitários seguem `GIVEN`, `WHEN`, `THEN`
- testes de integração têm nomes didáticos
- testes de integração seguem `GIVEN`, `WHEN`, `THEN`
- testes funcionais têm cenários didáticos
- testes funcionais seguem `GIVEN`, `WHEN`, `THEN`
- frontend e mobile usam componentes, widgets e estados com nomes explícitos
- scripts, workflows e targets têm nomes claros
- não existem abreviações desnecessárias
- o código se explica sozinho na maior parte do tempo

## Resumo

Neste projeto, Clean Code será aplicado à risca.

Isso significa:

- sem abreviações
- sem simplificação de nomes
- sem nomenclatura genérica
- sem descrições vagas em testes
- tudo deve ser escrito para ser lido com facilidade e sem ambiguidade

O nome certo faz parte da solução, não é detalhe estético.
