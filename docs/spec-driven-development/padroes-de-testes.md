# Padrões de Testes

## Objetivo

Definir o padrão oficial de testes do projeto, cobrindo:

- testes unitários
- testes de integração
- testes funcionais
- testes mobile
- cobertura mínima obrigatória
- estratégia de massa de dados
- setup e teardown
- organização por sucesso e falha
- anti-reward hacking

Este documento adota como referência o padrão observado em `projeto-referencia-backend`, especialmente na pasta `__functional_tests__`, com adaptação para este projeto.

## Regra Geral

Todo teste deve ser:

- legível
- determinístico
- isolado
- didático
- sem dependência de estado residual de execuções anteriores

Toda funcionalidade deve ser desenvolvida com TDD sempre que houver comportamento testável: primeiro o teste, depois a implementação e por fim a refatoração.

Todo teste criado ou alterado deve seguir `GIVEN`, `WHEN`, `THEN`.

Os exemplos deste documento são conceituais. Nas histórias reais do WorkLink, os cenários devem usar o domínio do produto: usuários, profissionais, cidades, categorias, contato, pós-contato, avaliações, denúncias, moderação, autenticação, autorização e auditoria.

## Testes Unitários

### Regras obrigatórias

Todos os testes unitários:

- devem usar `@DisplayName` com descrição em português
- devem seguir o padrão `GIVEN`, `WHEN`, `THEN`
- devem usar `BDDMockito.given(...)` para preparação de mocks
- devem usar `Assertions.assertTrue`, `Assertions.assertFalse`, `Assertions.assertEquals`, `Assertions.assertThrows` e equivalentes
- devem manter uma asserção por linha
- não devem quebrar linha sem necessidade
- não devem esconder regra de negócio dentro do teste
- devem contribuir para cobertura unitária mínima obrigatória de 95%

### Cobertura mínima obrigatória

Toda suíte de testes unitários deve manter cobertura mínima de 95%.

Esta regra vale para backend e mobile quando a suíte unitária existir. A pipeline de GitHub Actions deve falhar quando a cobertura unitária calculada ficar abaixo de 95%.

Coverage não substitui qualidade dos testes. Um teste só conta como válido quando também comprova comportamento real, regra de domínio ou caso de uso de forma clara, determinística e aderente a este documento.

Não é permitido reduzir threshold, excluir arquivos relevantes da medição ou criar testes artificiais apenas para aumentar percentual.

### Estrutura obrigatória

Cada teste unitário deve respeitar esta estrutura:

```java
@Test
@DisplayName("Deve transferir saldo entre contas quando houver saldo suficiente")
void shouldTransferBalanceWhenSourceAccountHasEnoughFunds() {
    // GIVEN
    ...

    // WHEN
    ...

    // THEN
    ...
}
```

### Convenções para unitários

- o nome do método pode ficar em inglês técnico
- o `@DisplayName` obrigatoriamente deve ficar em português
- o `GIVEN` prepara o cenário, entradas, mocks e estado inicial
- o `WHEN` executa uma única ação principal
- o `THEN` verifica o resultado com assertions diretas

### Padrão de mocks

Obrigatório usar BDD:

```java
given(accountRepository.findById(sourceAccountId)).willReturn(Optional.of(sourceAccount));
given(accountRepository.findById(targetAccountId)).willReturn(Optional.of(targetAccount));
```

Não usar como padrão:

- `when(...).thenReturn(...)`

### Padrão de assertions

Obrigatório preferir:

```java
Assertions.assertEquals(expectedBalance, sourceAccount.getBalance());
Assertions.assertEquals(expectedTargetBalance, targetAccount.getBalance());
Assertions.assertTrue(notificationSent);
Assertions.assertFalse(account.isInactive());
```

Evitar:

- asserts agrupadas em expressões longas demais
- múltiplas verificações complexas na mesma linha
- asserções implícitas difíceis de ler

### Organização recomendada dos unitários

Separar testes por responsabilidade:

- converters
- domain models
- specifications
- services

Exemplos:

- `TransferRequestConverterTest`
- `TransferServiceTest`
- `ShouldHaveSufficientBalanceTest`
- `AccountTest`

### O que testar em unitários

#### Converter

Deve cobrir:

- mapeamento de DTO para domínio
- validação de campos obrigatórios
- rejeição de payload inválido
- normalização de valores de entrada

#### Specification

Deve cobrir:

- regra satisfeita
- regra não satisfeita
- mensagens de erro corretas

#### Domain

Deve cobrir:

- débito
- crédito
- criação de movimentação
- transições válidas de estado
- bloqueio de operações inválidas

#### Service

Deve cobrir:

- orquestração da transferência
- persistência das entidades esperadas
- disparo de notificação após sucesso
- interrupção do fluxo quando houver falha de regra

No WorkLink, casos de uso/application services devem ser testados isolando ports e adapters. O teste unitário não deve depender de banco, cache, storage, HTTP real ou framework.

## Exemplo de padrão unitário

```java
@Test
@DisplayName("Deve rejeitar transferência quando a conta de origem não possuir saldo suficiente")
void shouldRejectTransferWhenSourceAccountHasInsufficientBalance() {
    // GIVEN
    var sourceAccount = new Account(1L, "João", new BigDecimal("100.00"));
    var targetAccount = new Account(2L, "Maria", new BigDecimal("50.00"));
    var transfer = new Transfer(sourceAccount, targetAccount, new BigDecimal("150.00"));

    // WHEN
    var result = specification.isSatisfiedBy(transfer);

    // THEN
    Assertions.assertFalse(result.isSatisfied());
    Assertions.assertEquals("insufficient_balance", result.getMessages().get(0));
}
```

## Testes de Integração

Testes de integração validam a conexão real entre a aplicação e dependências controladas.

### Tecnologias esperadas

- Spring Boot Test
- PostgreSQL container
- Testcontainers quando a suíte executar com acesso seguro ao Docker daemon
- Redis container quando aplicável
- MinIO/S3-compatible quando a história tocar storage

### Regras obrigatórias

- devem seguir `GIVEN`, `WHEN`, `THEN`
- devem validar migrations, repositories, constraints, transações e persistência crítica
- devem usar massa determinística e cleanup explícito
- não devem depender de banco compartilhado manual
- devem executar contra dependência containerizada e reproduzível
- não substituem testes unitários nem testes funcionais

### O que validar em integração

- repository persistindo e consultando corretamente
- constraint impedindo estado inválido
- migration compatível com o modelo esperado
- transação fazendo rollback quando houver falha
- adapter de infraestrutura respeitando o contrato do port
- integração com Redis ou storage apenas quando a história exigir

## Testes Funcionais

### Regras obrigatórias

Todos os testes funcionais:

- devem ter `describe` em `pt-BR`
- devem ter `it` em `pt-BR`
- devem seguir o padrão `GIVEN`, `WHEN`, `THEN`
- devem descrever com precisão didática o comportamento sob teste
- devem usar massa de dados baseada em `seeders + fixtures`
- devem ter cleanup automático ao final da execução da pipeline
- devem respeitar a heurística VADER
- devem separar cenários de sucesso e cenários de falha em arquivos distintos

### Organização dos arquivos

Cada endpoint deve ter arquivos separados para:

- sucesso
- falha

Exemplo:

```text
__functional_tests__/src/endpoints/transfer/POST/transferPostSuccess.spec.js
__functional_tests__/src/endpoints/transfer/POST/transferPostFailure.spec.js
```

Se o time preferir manter o sufixo usado no `projeto-referencia-backend`, o equivalente aceitável é:

```text
transferPostSuccess.spec.js
transferPostValidations.spec.js
```

Para este projeto, o padrão preferencial será:

- `Success.spec.js` para sucesso
- `Failure.spec.js` para falha

### Padrão de descrição

Exemplo esperado:

```javascript
describe("POST /transfers deve processar transferências entre contas válidas e retornar o resultado esperado", () => {
  it("deve transferir saldo com sucesso quando a conta de origem possuir saldo suficiente", async () => {
    ...
  })
})
```

### Estrutura recomendada dos funcionais

Cada teste funcional deve deixar explícito:

- arranjo da massa
- chamada HTTP
- validação da resposta
- validação do efeito colateral no banco

### Estrutura obrigatória dos funcionais

Todos os testes funcionais devem seguir o padrão `GIVEN`, `WHEN`, `THEN`.

Neste contexto:

- `GIVEN` representa a massa pronta necessária para o cenário, preferencialmente vinda de `fixtures + seeders`
- `WHEN` representa a chamada ao endpoint que está sendo testado
- `THEN` representa a validação end-to-end completa

### Regra obrigatória de validação end-to-end

No teste funcional, o `THEN` não pode validar apenas:

- status code
- payload de resposta

Ele deve validar também o efeito real persistido no banco de dados.

Ou seja:

- se criou, deve confirmar que foi criado na base
- se alterou, deve confirmar que foi alterado na base
- se removeu, deve confirmar que foi removido da base
- se falhou, deve confirmar que nada indevido foi persistido

Essa é uma regra obrigatória para todos os testes end-to-end.

### Forma preferencial de validar o end-to-end

Para validar o `THEN` end-to-end, é permitido e recomendado chamar endpoints `GET` da própria API para confirmar o estado final do sistema.

Isso significa que, após um `POST`, `PUT`, `PATCH` ou `DELETE`, o teste pode:

- chamar um `GET` de consulta
- buscar o recurso criado, alterado ou removido
- fazer os `expect` no Jest com base na resposta da API

Essa abordagem é válida porque também comprova o fluxo completo da aplicação.

### Regra prática para validação do THEN

O `THEN` dos testes funcionais deve seguir esta ordem de preferência:

1. validar o `status code` e o payload da operação principal
2. chamar um endpoint `GET` para confirmar o estado final
3. quando necessário, complementar com validação direta no banco

Sempre que o `GET` da API for suficiente para provar o comportamento, ele deve ser usado como mecanismo principal de confirmação end-to-end.

### Exemplo conceitual do padrão funcional

```javascript
describe("POST /transfers deve processar transferências válidas de forma consistente", () => {
  it("deve transferir saldo com sucesso e persistir as movimentações na base", async () => {
    // GIVEN
    const sourceAccount = fixtures.sourceAccount
    const targetAccount = fixtures.targetAccount
    const payload = fixtures.validTransferPayload

    // WHEN
    const response = await createPOST("/transfers", payload).expect(201)

    // THEN
    expect(response.status).toBe(201)
    const sourceAccountResponse = await createGET(`/accounts/${sourceAccount.id}`).expect(200)
    const targetAccountResponse = await createGET(`/accounts/${targetAccount.id}`).expect(200)
    const statementResponse = await createGET(`/accounts/${sourceAccount.id}/transactions`).expect(200)

    expect(sourceAccountResponse.body.balance).toBe(900.00)
    expect(targetAccountResponse.body.balance).toBe(350.00)
    expect(statementResponse.body.length).toBeGreaterThan(0)
  })
})
```

### O que validar em funcionais

#### Cenários de sucesso

- criação de conta
- consulta de conta
- transferência com sucesso
- geração de movimentação para débito
- geração de movimentação para crédito
- envio de notificação após sucesso
- consulta de extrato
- persistência correta dos dados na base

#### Cenários de falha

- conta origem inexistente
- conta destino inexistente
- saldo insuficiente
- transferência para mesma conta
- valor zerado
- valor negativo
- payload inválido
- concorrência gerando conflito
- ausência de persistência indevida na base

### Validação obrigatória das mensagens de negócio

Em testes funcionais de falha ligados a validação de regra de negócio, não basta verificar apenas:

- status code
- ausência de persistência

Também é obrigatório validar a mensagem retornada pela API para garantir que o erro ocorrido é exatamente o erro esperado.

Exemplos:

- saldo insuficiente deve retornar a mensagem correspondente a saldo insuficiente
- transferência para a mesma conta deve retornar a mensagem correspondente a transferência inválida
- conta inexistente deve retornar a mensagem correspondente a recurso não encontrado

### Padrão obrigatório das mensagens da API

Todas as mensagens de retorno da API devem seguir um glosário com:

- `key`
- `value`

O `key` representa o identificador semântico da regra ou erro.

O `value` representa a mensagem legível para quem consome a API.

O `value` pode ser em `pt-BR`.

Exemplo de estrutura:

```json
{
  "code": 400,
  "operationMessages": [
    {
      "key": "transfer.insufficient_balance",
      "value": "Saldo insuficiente para realizar a transferência."
    }
  ]
}
```

### Regra de teste para mensagens da API

Todo teste funcional de validação deve conferir:

- o `status code`
- a `key` correta
- o `value` correto
- a ausência de efeito indevido no estado final

### Exemplo de validação de falha

```javascript
describe("POST /transfers deve rejeitar transferências inválidas conforme as regras de negócio", () => {
  it("deve retornar saldo insuficiente quando a conta de origem não possuir saldo bastante", async () => {
    // GIVEN
    const payload = fixtures.transferWithInsufficientBalance

    // WHEN
    const response = await createPOST("/transfers", payload).expect(400)

    // THEN
    expect(response.body.code).toBe(400)
    expect(response.body.operationMessages[0].key).toBe("transfer.insufficient_balance")
    expect(response.body.operationMessages[0].value).toBe("Saldo insuficiente para realizar a transferência.")

    const sourceAccountResponse = await createGET(`/accounts/${payload.sourceAccountId}`).expect(200)
    const targetAccountResponse = await createGET(`/accounts/${payload.targetAccountId}`).expect(200)

    expect(sourceAccountResponse.body.balance).toBe(50.00)
    expect(targetAccountResponse.body.balance).toBe(100.00)
  })
})
```

## Massa de Dados Funcional

### Regra obrigatória

Toda massa funcional deve vir de:

- `fixtures`
- `seeders`

Não é permitido:

- depender de dados pré-existentes do banco
- depender de IDs mágicos criados manualmente no teste
- criar massa ad hoc sem fixture versionada

### Referência adotada

O padrão vem do `projeto-referencia-backend`, que usa:

- `__functional_tests__/src/fixtures/newFixtures`
- `__functional_tests__/src/seeders`
- `seed.js`
- `rollback.js`

### Estrutura sugerida

```text
__functional_tests__/
  src/
    fixtures/
      newFixtures/
        account.fixture.js
        transfer.fixture.js
        transaction.fixture.js
    seeders/
      account/account.seeder.js
      transfer/transfer.seeder.js
      transaction/transaction.seeder.js
    endpoints/
      transfer/
        POST/
          transferPostSuccess.spec.js
          transferPostFailure.spec.js
    setup/
      setup.js
      databaseSetup.js
  seed.js
  rollback.js
```

### Padrão de fixture

Fixture deve:

- ter dados determinísticos
- ser versionada
- ter identificadores estáveis
- servir como fonte única da massa usada nos testes

Exemplo:

```javascript
export default {
  sourceAccount: {
    id: 1001,
    name: "Conta Origem",
    balance: 1000.00,
    active: true,
  },
  targetAccount: {
    id: 1002,
    name: "Conta Destino",
    balance: 250.00,
    active: true,
  },
}
```

### Padrão de seeder

Cada seeder deve exportar:

- uma função de seed
- uma função de rollback

Exemplo:

```javascript
export async function seedAccount(fixtures, transaction) {
  ...
}

export async function rollbackAccount(fixtures, transaction) {
  ...
}
```

### Rollback obrigatório

Ao final da execução dos testes funcionais, toda a massa criada deve ser destruída automaticamente.

Isto deve acontecer:

- via `rollback.js`
- ou via cleanup por suíte quando necessário

O banco deve terminar pronto para nova execução, sem lixo residual.

## Heurística VADER

Este projeto adotará a heurística VADER como padrão para testes funcionais, seguindo a mesma linha documentada no `projeto-referencia-backend`.

Na prática, isso significa:

- massa determinística
- isolamento entre suítes
- rollback limpo
- execução previsível
- ausência de dependência de base compartilhada
- ausência de dependência de `fixtures` globais instáveis

### Regras derivadas da VADER

- cada domínio deve ter fixtures próprias e explícitas
- cada domínio deve ter seed e rollback próprios
- os IDs usados nos testes devem ser fixos, controlados e documentados
- os testes devem ser reexecutáveis sem intervenção manual
- a pipeline deve conseguir preparar e destruir a massa automaticamente
- a suíte não deve poluir o banco

## Setup da Suíte Funcional

Inspirado no `projeto-referencia-backend`, o setup funcional deve conter:

- configuração global de timeout
- retry controlado apenas quando fizer sentido
- cleanup automático antes ou depois da suíte
- conexão explícita com banco de testes

### Exemplo de setup global

```javascript
jest.setTimeout(60000)
jest.retryTimes(3)
```

### Exemplo de cleanup automático

```javascript
cleanupQuery(fixtures.clientId).finally(() => {
  connection.close()
})
```

## Testes Mobile

Quando houver app Flutter, a suíte mobile deve cobrir lógica, widgets e fluxos críticos.

### Testes unitários Flutter

- devem usar `flutter_test` e mocks/fakes claros quando necessário
- devem seguir `GIVEN`, `WHEN`, `THEN`
- devem manter cobertura unitária mínima de 95% quando houver suíte unitária mobile
- devem validar regras de apresentação, formatação, estados e controllers/providers sem depender de UI real

### Testes de widget

- devem validar renderização e comportamento de componentes/telas
- devem usar nomes de cenários em português
- devem cobrir estados de sucesso, vazio, carregamento e erro quando aplicável
- não devem depender de estado residual entre execuções

### Testes de integração mobile

- devem validar fluxos críticos quando configurados com `integration_test`
- devem ser executáveis em Android Emulator e, quando disponível, iOS Simulator
- não substituem testes unitários nem testes de widget

## Convenções de Nomenclatura

### Unitários

- `...Test.java`
- `@DisplayName` sempre em português

### Funcionais

- `...Success.spec.js`
- `...Failure.spec.js`
- `describe` em português
- `it` em português

### Integração

- `...IntegrationTest.java`
- `...IT.java` apenas quando já for o padrão local
- `@DisplayName` em português

### Mobile

- nomes de arquivos e cenários devem descrever tela, componente, estado ou fluxo validado
- descrições de testes devem ser didáticas e em português quando o framework permitir

## Anti-padrões proibidos

Não será aceito:

- teste criado depois da implementação quando o comportamento permitia TDD
- teste sem `@DisplayName` em português
- teste unitário sem `GIVEN`, `WHEN`, `THEN`
- teste unitário usando `when(...).thenReturn(...)` como padrão
- teste unitário que não contribui para comportamento real apenas para inflar coverage
- cobertura unitária abaixo de 95%
- exclusão de arquivos relevantes do coverage para passar no gate
- teste de integração dependente de banco compartilhado manual
- teste de integração sem cleanup
- teste funcional com descrição em inglês
- teste funcional sem blocos `GIVEN`, `WHEN`, `THEN`
- teste funcional dependente de base compartilhada manual
- teste funcional que valide apenas status code sem validar persistência no banco
- teste funcional que ignore a possibilidade de validar por `GET` quando a própria API já expõe esse estado
- teste funcional de validação que não confira `key` e `value` da mensagem retornada
- resposta de erro da API sem glosário padronizado de `key` e `value`
- massa criada diretamente no corpo do teste sem fixture/seeder
- ausência de rollback
- misturar sucesso e falha no mesmo spec sem necessidade
- `@Disabled`, `@Ignore`, `.skip`, `xit` ou `xdescribe`
- remoção ou enfraquecimento de assertions para fazer a suíte passar
- validação de erro removida sem substituição equivalente
- validação de persistência removida sem substituição equivalente

## Checklist de Aceite

- todo unitário possui `@DisplayName` em português
- todo unitário possui blocos `GIVEN`, `WHEN`, `THEN`
- todo unitário usa `BDDMockito.given`
- todo unitário usa `Assertions.*`
- toda suíte unitária aplicável mantém cobertura mínima de 95%
- todo teste de integração possui blocos `GIVEN`, `WHEN`, `THEN`
- todo teste de integração valida dependência real controlada e possui cleanup
- todo funcional possui `describe` e `it` em `pt-BR`
- todo funcional possui blocos `GIVEN`, `WHEN`, `THEN`
- todo funcional valida o efeito real na base de dados
- todo funcional usa `GET` para confirmar estado final quando isso for suficiente
- todo funcional de falha valida a mensagem retornada pela API
- toda resposta de erro usa glosário com `key` e `value`
- toda massa funcional vem de `fixtures + seeders`
- existe `seed` e `rollback`
- a pipeline remove a massa ao final
- sucesso e falha ficam em arquivos separados
- a suíte respeita a heurística VADER
- testes mobile rodam com `flutter test` quando houver app Flutter
- testes mobile unitários mantêm 95% de cobertura quando houver suíte unitária mobile
- não há teste desabilitado, removido ou enfraquecido para passar pipeline

## Resumo

O padrão oficial deste projeto será:

- unitário com `DisplayName` em português, `GIVEN/WHEN/THEN`, `BDDMockito.given` e `Assertions.*`
- cobertura unitária mínima de 95%
- integração com dependências reais controladas e cleanup obrigatório
- funcional com `describe` e `it` em português e padrão `GIVEN/WHEN/THEN`
- validação end-to-end com conferência real no banco
- massa de dados controlada por `fixtures + seeders`
- uso preferencial de `GET` para comprovar o estado final via API
- validação de mensagens de erro com glosário `key` e `value`
- rollback automático ao fim da pipeline
- organização de sucesso e falha em arquivos separados
- execução determinística seguindo a heurística VADER
- mobile com unitários, widget tests e integração quando aplicável
- reprovação de reward hacking em qualquer suíte
