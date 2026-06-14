# Entrega WL-025 - Autenticacao propria por email e senha

## Resultado

Concluida tecnicamente. A historia substituiu o caminho principal de autenticacao por cadastro e login com email e senha,
preservando a navegacao anonima, mantendo os canais pagos ou terceiros em stand by e entregando recuperacao segura de
senha sem depender de OTP como fluxo principal.

## Artefatos

- `docs/jira-pessoal/historias/WL-025-autenticacao-propria-email-senha.md`
- `docs/operacao/autenticacao-local-email-senha.md`
- `docs/tasks/WL-025/IMPLEMENTATION.md`
- `docs/tasks/WL-025/MATRIZ-ADERENCIA-UX.md`
- `docs/tasks/WL-025/progress.txt`
- `docs/api/openapi.yaml`
- `worklink-api/src/main/resources/db/migration/V022__create_local_authentication_credentials.sql`
- `worklink-api/src/main/java/br/com/worklink/api/authentication/AuthenticationController.java`
- `worklink-api/src/main/java/br/com/worklink/application/authentication/usecase/RegisterLocalAuthenticationUseCase.java`
- `worklink-api/src/main/java/br/com/worklink/application/authentication/usecase/LoginLocalAuthenticationUseCase.java`
- `worklink-api/src/main/java/br/com/worklink/application/authentication/usecase/RequestPasswordRecoveryUseCase.java`
- `worklink-api/src/main/java/br/com/worklink/application/authentication/usecase/ResetPasswordUseCase.java`
- `worklink-mobile/lib/features/customer_authentication/customer_authentication_screen.dart`
- `worklink-mobile/lib/features/customer_authentication/customer_authentication_controller.dart`
- `worklink-mobile/test/widget/features/customer_authentication/customer_authentication_screen_test.dart`

## Validacao

- `mvn -q test`: PASS.
- `mvn -q verify`: PASS.
- `JaCoCo`: 95.18% instrucoes e 95.93% linhas.
- `jest --runInBand`: PASS com 17 cenarios funcionais.
- `flutter analyze`: PASS.
- `flutter test test/widget/visual/wlt_030_visual_evidence_test.dart --update-goldens`: PASS.
- `flutter test test/unit`: PASS.
- `flutter test test/widget`: PASS.

## Observacoes operacionais

- O `Makefile` foi endurecido para forcar rebuild do `worklink-api` nos alvos full-stack que dependem do backend atual,
  evitando falso verde contra imagem stale.
- O suporte de token de recuperacao ficou restrito a `local/test`, com `default false` fora desses perfis.
- O provedor real de email transacional continua como decisao posterior de producao.

## Pendencias fora desta historia

- Revisar a ativacao futura de Google, Microsoft, Facebook, SMS, WhatsApp Business e OTP por email em `WLT-038`.
- Escolher e configurar o provedor de email transacional antes de subir este fluxo em ambiente publico.
- Retomar `WLT-037` quando chegar a etapa de backend cloud minimo para lojas.

## Proxima historia

WLT-038 - Mensageria de autenticacao real e controle de custos.
