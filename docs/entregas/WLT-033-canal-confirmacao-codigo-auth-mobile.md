# Entrega WLT-033 — Canal de confirmação de código na autenticação mobile

## Resumo

A autenticação mobile deixou de tratar o envio de código como um fluxo ambíguo. A V1 agora explicita suporte a `SMS`, `WhatsApp` e `email`, mantendo telefone como identificador primário e sinalizando quando o envio de homologação é simulado.

## Escopo entregue

- Decisão de produto registrada para autenticação multicanal na V1.
- UI mobile com escolha de canal antes da solicitação do código.
- Campo de email exibido e validado apenas quando o canal `email` é selecionado.
- Tela de verificação exibindo o canal e o destino corretos.
- Contrato mobile/backend atualizado para transportar `deliveryChannel` e `emailAddress` opcional.
- Resposta de solicitação OTP com canais disponíveis e flag `simulatedDelivery`.
- Testes unitários, widget e backend cobrindo SMS, WhatsApp, email e homologação simulada.

## Segurança e privacidade

- A API mantém resposta genérica para evitar enumeração de contas.
- O código OTP não é retornado para o aplicativo.
- O email só é coletado quando o usuário escolhe esse canal.
- Homologação permanece transparente: o envio pode ser simulado até existir provedor real configurado.

## Evidências

- `flutter test` focado em autenticação mobile, gateway e serviço: PASS.
- `mvn -Dtest=AuthenticationControllerTest,AuthenticationUseCaseTest test`: PASS.
- `make mobile-static-analysis`: PASS.
- `make backend-static-analysis`: PASS, com warnings PMD preexistentes não bloqueantes.
- `make mobile-unit-test`: PASS, 159 testes e cobertura unitária mobile 95,23%.
- `make mobile-screen-test`: PASS, 75 testes de widget/evidência visual.
- `make backend-unit-test`: PASS, 313 testes e Jacoco aprovado.
- `make functional-test`: PASS, 5 suítes e 12 testes.
- Auditoria local de segurança: PASS, sem secrets, sem exposição de OTP e com resposta genérica preservada.

## Observações

- Esta entrega não contrata nem configura provedor externo de SMS, WhatsApp ou email.
- Antes de produção, será necessário integrar o provedor real e trocar `simulatedDelivery` para `false` quando o envio for confirmado pelo adaptador.
- `worklink-mobile/pubspec.lock` já estava modificado no workspace e não faz parte desta entrega.
