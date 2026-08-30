# Entrega WL-026 - Navegacao anonima com autenticacao antes do detalhe

## Resultado

Concluida tecnicamente. O app agora permite descoberta e busca anonimas, mas exige login ou cadastro antes de abrir o
detalhe completo do profissional, acessar contato, salvos ou perfil do cliente.

## Artefatos

- `docs/jira-pessoal/historias/WL-026-autenticacao-obrigatoria-antes-da-descoberta.md`
- `docs/tasks/WL-026/IMPLEMENTATION.md`
- `docs/tasks/WL-026/progress.txt`
- `functional-tests/src/specs/autorizacao-e-bloqueios.spec.js`
- `worklink-api/src/main/java/br/com/worklink/api/professional/ProfessionalController.java`
- `worklink-api/src/main/java/br/com/worklink/api/professional/ProfessionalSummaryHttpResponse.java`
- `worklink-api/src/main/java/br/com/worklink/api/professional/ProfessionalDetailHttpResponse.java`
- `worklink-api/src/main/java/br/com/worklink/application/professional/usecase/ListProfessionalsUseCase.java`
- `worklink-api/src/main/java/br/com/worklink/application/professional/usecase/LoadProfessionalDetailUseCase.java`
- `worklink-mobile/lib/app/worklink_application_gateway.dart`
- `worklink-mobile/lib/main.dart`
- `worklink-mobile/lib/services/authentication_session_store.dart`
- `worklink-mobile/test/widget/visual/wl_026_visual_evidence_test.dart`

## Validacao

- `WORKLINK_POSTGRES_PORT=55432 make backend-static-analysis`: PASS.
- `WORKLINK_POSTGRES_PORT=55432 make backend-unit-test`: PASS com 350 testes e JaCoCo aprovado.
- `WORKLINK_POSTGRES_PORT=55432 make backend-integration-test`: PASS.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS com 172 testes e cobertura 95.35%.
- `make mobile-screen-test`: PASS com 89 testes.
- `WORKLINK_POSTGRES_PORT=55432 make functional-test`: PASS com 21 cenarios E2E.
- `WORKLINK_POSTGRES_PORT=55432 make mobile-integration-test`: PASS no contrato Dart; `integration_test` em device ficou N/A por ausencia de Android/iOS/Chrome no container.

## Observacoes operacionais

- A listagem publica entrega apenas resumo de descoberta.
- O detalhe do profissional exige autenticacao no backend e no mobile.
- O refresh token do mobile fica em armazenamento seguro; access token nao e persistido.
- HTTP `401` invalida sessao local; HTTP `403` nao faz logout automatico.

## Pendencias fora desta historia

- Executar testes reais em device/emulador nos proximos gates de loja quando houver infraestrutura mobile disponivel.
- Prosseguir para `WLT-042`, operacao manual assistida da Play Console para testes internos e fechados.

## Proxima historia

WLT-042 - Operacao manual da Play Console para testes internos e fechados.
