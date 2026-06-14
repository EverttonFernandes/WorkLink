# Entrega WLT-038 - Mensageria de autenticacao real e controle de custos

## Resultado

Concluida tecnicamente. A historia preparou a trilha de OTP/autenticacao opcional para evolucao futura sem mexer no
canal principal da V1, que continua sendo email e senha. O backend agora diferencia explicitamente modo `disabled` e
modo `sandbox` para OTP, respeita apenas canais habilitados por flag, aplica cooldown de reenvio por telefone e deixa o
custo mensal da mensageria paga travado em `R$ 0,00` no lancamento.

## Artefatos

- `docs/jira-pessoal/historias-tecnicas/WLT-038-mensageria-autenticacao-real-custos.md`
- `docs/operacao/autenticacao-mensageria-custos.md`
- `docs/tasks/WLT-038/TASK.md`
- `docs/tasks/WLT-038/IMPLEMENTATION.md`
- `docs/tasks/WLT-038/progress.txt`
- `.env.example`
- `worklink-api/src/main/resources/application.yml`
- `worklink-api/src/main/java/br/com/worklink/application/authentication/port/DeliverAuthenticationOtpPort.java`
- `worklink-api/src/main/java/br/com/worklink/application/authentication/port/AuthenticationOtpDeliveryRequest.java`
- `worklink-api/src/main/java/br/com/worklink/application/authentication/usecase/RequestAuthenticationOtpUseCase.java`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/authentication/DisabledAuthenticationOtpDeliveryAdapter.java`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/authentication/SandboxAuthenticationOtpDeliveryAdapter.java`

## Validacao

- `docker compose --env-file .env run --rm backend-tests mvn -q test -Dtest=AuthenticationUseCaseTest,AuthenticationControllerTest,AuthenticationOtpDeliveryAdapterTest,WorkLinkUseCaseConfigurationTest`: PASS.
- `docker compose --env-file .env run --rm backend-tests mvn -q -DskipITs test`: PASS.
- `make backend-static-analysis`: PASS.
- `git diff --check`: PASS.

## Decisoes fechadas

- Login proprio da `WL-025` segue como trilha principal e independente.
- OTP, WhatsApp Business, Google, Microsoft e Facebook continuam desligados por padrao.
- O canal OTP futuro so pode sair de `disabled` para `sandbox` ou real mediante feature flags, secrets externos e
  aprovacao explicita de produto.
- O teto mensal de mensageria paga no lancamento fica em `R$ 0,00`.

## Pendencias fora desta historia

- Escolha de provedor pago real continua manual e posterior.
- Ativacao real de SMS/WhatsApp/social depende de custo aprovado, secrets e monitoramento de consumo.
- `WLT-039` assume o proximo passo da fila para a trilha Android de loja.

## Proxima historia

WLT-039 - Android AAB e Play Store Internal Testing.
