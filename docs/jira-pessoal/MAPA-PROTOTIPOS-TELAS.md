# Mapa de Protótipos de Tela — WorkLink V1

Este arquivo vincula os protótipos em `docs/prototipos-de-tela/` às histórias responsáveis pela construção real de cada tela ou estado visual.

Regra de uso pelos agentes:

- a história responsável deve usar o protótipo como referência visual principal;
- requisitos funcionais continuam sendo os RFs da história;
- requisitos não funcionais continuam sendo os RNFs da história e os padrões em `docs/spec-driven-development/`;
- quando uma tela tocar autenticação, autorização, LGPD, rastreabilidade, storage, observabilidade ou disponibilidade, os gates especializados devem ser executados;
- protótipo não substitui critério de aceite, teste, acessibilidade, responsividade, segurança ou regra de domínio.

## Mapa oficial

| Protótipo                                                            | História responsável                                            | Papel na entrega                                                  | Requisitos principais                                | Gates/subagentes esperados                                        |
| -------------------------------------------------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------- | ----------------------------------------------------------------- |
| `docs/prototipos-de-tela/tela-selecionar-cidades.png`                     | [WL-002](historias/WL-002-selecao-cidades-localizacao.md)       | Tela de seleção manual de cidades e localização atual             | RF03, RF04, RF05, RF06, RF07, RF54, RN01             | QA, mobile, privacidade quando localização for usada              |
| `docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png`         | [WL-003](historias/WL-003-descoberta-busca-filtros.md)          | Estado vazio da descoberta/listagem                               | RF01, RF02, RF03, RF04, RF07, RF08, RF09, RN01       | QA, mobile                                                        |
| `docs/prototipos-de-tela/tela-perfil-do-profissional.png`                 | [WL-005](historias/WL-005-perfil-publico-profissional.md)       | Perfil público detalhado do profissional                          | RF11, RF12, RF13, RF29, RF45, RF47, RN15, RN16       | QA, mobile, arquitetura                                           |
| `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`               | [WL-006](historias/WL-006-cadastro-progressivo-profissional.md) | Cadastro e edição progressiva do perfil profissional              | RF18, RF19, RF20, RF21, RF22, RN06, RN15, RN16       | QA, mobile, storage quando houver foto/portfólio                  |
| `docs/prototipos-de-tela/tela-verificao-usuario-cliente-profissional.png` | [WL-025](historias/WL-025-autenticacao-propria-email-senha.md)  | Referência histórica de verificação OTP; não representa escolha de perfil e não deve aparecer no fluxo local padrão | RF16, RF17 | QA, mobile, segurança, privacidade |
| `docs/prototipos-de-tela/tela-login-autenticacao.png`                     | [WL-025](historias/WL-025-autenticacao-propria-email-senha.md)  | Login/cadastro próprio preservando a composição visual existente  | RF14, RF15, RF16, RF17, RN01, RN02                   | QA, mobile, segurança, privacidade, SRE quando tocar configuração |
| `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`               | [WL-010](historias/WL-010-contato-whatsapp-intencao.md)         | Confirmação/aviso antes do redirecionamento ao WhatsApp           | RF31, RF32, RF33, RF34, RF35, RN02, RN03, RN04, RN05 | QA, mobile, segurança, auditoria                                  |
| `docs/prototipos-de-tela/tela-avaliacao-profissional.png`                 | [WL-012](historias/WL-012-avaliacao-anonima-rastreavel.md)      | Formulário de avaliação após serviço realizado                    | RF40, RF41, RF42, RF43, RF44, RN09, RN10, RN11, RN12 | QA, mobile, segurança, privacidade, auditoria                     |
| `docs/prototipos-de-tela/tela-avaliacao-concluida.png`                    | [WL-012](historias/WL-012-avaliacao-anonima-rastreavel.md)      | Confirmação de avaliação enviada                                  | RF40, RF41, RF42, RF43, RF44, RN09, RN10, RN11, RN12 | QA, mobile, segurança, privacidade, auditoria                     |
| `docs/prototipos-de-tela/tela-denunciar-profissional.png`                 | [WL-014](historias/WL-014-denuncia-profissional.md)             | Formulário de denúncia com motivo, descrição e evidência opcional | RF47, RF48, RF49, RF50, RF51, RF52, RN13, RN14, RN20 | QA, mobile, segurança, privacidade, storage, auditoria            |
| `docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png`              | [WL-015](historias/WL-015-perfil-usuario.md)                    | Perfil do cliente, preferências e informações básicas             | RF53, RF54, RF55, RF56, RF57, RN01, RN02             | QA, mobile, segurança, privacidade                                |

## Referências secundárias

| História                                                   | Protótipos relacionados                                                      | Motivo                                                               |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| [WL-004](historias/WL-004-listagem-profissionais.md)       | `tela-nenhum-profissional-encontrado.png`, `tela-perfil-do-profissional.png` | a listagem deve levar ao perfil e compartilhar estados da descoberta |
| [WL-007](historias/WL-007-badges-confianca-completude.md)  | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png`       | badges aparecem no cadastro, listagem e perfil                       |
| [WL-008](historias/WL-008-disponibilidade-profissional.md) | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png`       | disponibilidade aparece no cadastro e no perfil                      |
| [WL-011](historias/WL-011-pos-contato-estruturado.md)      | `tela-falar-com-o-profissional.png`, `tela-avaliacao-profissional.png`       | pós-contato habilita avaliação e sinais de responsividade            |
| [WL-013](historias/WL-013-exibicao-avaliacoes-perfil.md)   | `tela-perfil-do-profissional.png`, `tela-avaliacao-concluida.png`            | avaliações enviadas devem aparecer no perfil respeitando anonimato   |
| [WL-018](historias/WL-018-verificacao-telefone-profissional.md) | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png` | telefone verificado aparece como confiança progressiva               |
| [WL-019](historias/WL-019-portfolio-fotos-profissional.md)  | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png`       | portfólio/fotos completam cadastro e perfil público                  |
| [WL-020](historias/WL-020-profissionais-salvos-preferencias-persistentes.md) | `tela-perfil-do-cliente-usuario.png`, `tela-perfil-do-profissional.png` | perfil do cliente deve carregar salvos e preferências persistidas    |
| [WL-021](historias/WL-021-solicitacao-pos-contato.md)       | `tela-falar-com-o-profissional.png`, `tela-avaliacao-profissional.png`       | solicitação ativa de feedback nasce após intenção de contato         |
| [WL-009](historias/WL-009-autenticacao-cliente-telefone.md) | `tela-verificao-usuario-cliente-profissional.png`, `tela-login-autenticacao.png` | implementação histórica por telefone/OTP preservada como referência para canal futuro |

## Regras obrigatórias para implementação de telas

- Seguir `docs/spec-driven-development/codigo-limpo.md`.
- Seguir `docs/spec-driven-development/padroes-de-testes.md`.
- Seguir `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`.
- Manter regra de negócio fora de widgets, controllers de tela, adapters e SDKs.
- Cobrir lógica mobile com testes unitários e widget tests quando aplicável.
- Manter cobertura unitária mínima de 95% quando houver suíte unitária mobile.
- Validar estados de sucesso, erro, carregamento e vazio quando fizer sentido para a tela.
- Garantir que dados sensíveis não sejam expostos indevidamente na UI, logs ou eventos.
- Preservar anonimato público em avaliação anônima.
- Não transformar protótipo em regra absoluta quando houver conflito com segurança, LGPD, acessibilidade ou critério de aceite.
