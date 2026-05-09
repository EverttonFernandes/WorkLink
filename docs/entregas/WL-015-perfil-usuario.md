# Entrega WL-015 — Perfil do usuário cliente

## Identificador

- História: `WL-015`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que o usuário cliente acesse uma área de perfil com seus dados básicos, cidades selecionadas, profissionais
salvos, avaliações enviadas, preferências simples, informações de privacidade e ação para sair da conta.

## Personas afetadas

- Usuário cliente: visualiza e ajusta informações básicas da sua experiência no app.
- Produto: ganha uma base visível para evoluir preferências, privacidade e histórico do cliente.
- Segurança/compliance: mantém dados pessoais atrás de autenticação local e com exposição mínima.

## Requisitos atendidos

- Usuário autenticado visualiza perfil.
- Usuário visualiza cidades selecionadas.
- Usuário visualiza profissionais salvos.
- Usuário visualiza avaliações enviadas.
- Usuário gerencia preferências básicas.
- Usuário consegue sair da conta.
- Dados pessoais são exibidos de forma mínima e apenas após autenticação.

## O que foi implementado

- Modelo mobile `CustomerProfileState` com dados básicos, cidade principal, cidades selecionadas, profissionais salvos,
  avaliações enviadas e preferências.
- Controller mobile `CustomerProfileController` para atualização de preferências e logout.
- Tela mobile `CustomerProfileScreen` com seções de perfil, cidades, salvos, avaliações, preferências e privacidade.
- Acesso ao perfil a partir da tela de descoberta.
- Gate de autenticação local antes de abrir o perfil do cliente.
- Testes BDD/TDD unitários, de widget e de fluxo do app.

## O que não foi implementado

- Integração HTTP real para persistir o perfil do cliente.
- Preferências avançadas.
- Histórico financeiro.
- Gestão administrativa de privacidade.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de descoberta.
- Tela mobile de autenticação do cliente.
- Tela mobile de perfil do cliente.
- Protótipo:
  - `docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png`

## Estratégia de testes

- Mobile unitário: alteração de preferências, logout e resumo derivado do perfil mínimo.
- Mobile tela: renderização de dados, cidades, profissionais salvos, avaliações, preferências e callback de logout.
- Mobile app: abertura do perfil exige autenticação quando usuário ainda não está autenticado e abre diretamente quando
  já existe sessão local.

## Evidências de validação

- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, 71 testes e cobertura 96,18%.
- `make mobile-screen-test`: PASS, 53 testes.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-unit-test`: PASS, 226 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v014`.
- `make backend-image-build`: PASS.

## Riscos ou limitações remanescentes

- O perfil ainda usa estado local e dados de demonstração porque a API persistente de perfil do cliente ainda não existe.
- Preferências são aplicadas na sessão local e precisarão de adapter HTTP quando a persistência de perfil for criada.
- Teste de integração mobile segue pendente de ambiente com Android Emulator, iOS Simulator ou Chrome.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/customer_profile`
- `worklink-mobile/lib/features/discovery/discovery_screen.dart`
- `worklink-mobile/lib/main.dart`
- `worklink-mobile/test/unit/features/customer_profile`
- `worklink-mobile/test/widget/features/customer_profile`
- `worklink-mobile/test/widget/worklink_app_widget_test.dart`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma nova capacidade funcional do cliente sem quebrar contratos existentes.
