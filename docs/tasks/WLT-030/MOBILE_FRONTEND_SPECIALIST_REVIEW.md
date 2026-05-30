# WLT-030 — Parecer do Mobile Front-end Specialist

## Verdict

`APPROVED`

## Escopo avaliado

| Tela | Protótipo | Arquivo Flutter | Evidência oficial | Status |
| --- | --- | --- | --- | --- |
| Autenticação por telefone | `docs/prototipos-de-tela/tela-login-autenticacao.png` | `worklink-mobile/lib/features/customer_authentication/customer_authentication_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/auth-phone-entry.png`, `auth-verification.png` | `PASS` |
| Seleção de cidades | `docs/prototipos-de-tela/tela-selecionar-cidades.png` | `worklink-mobile/lib/features/city_selection/city_selection_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/city-selection.png` | `PASS` |
| Descoberta / estado vazio | `docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png` | `worklink-mobile/lib/features/discovery/discovery_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/discovery-results.png`, `discovery-empty-state.png` | `PASS` |
| Perfil do profissional | `docs/prototipos-de-tela/tela-perfil-do-profissional.png` | `worklink-mobile/lib/features/professional_profile/professional_profile_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/professional-profile.png` | `PASS` |
| Cadastro profissional | `docs/prototipos-de-tela/tela-cadastro-do-profissional.png` | `worklink-mobile/lib/features/professional_registration/professional_registration_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/professional-registration.png` | `PASS` |
| Perfil do cliente | `docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png` | `worklink-mobile/lib/features/customer_profile/customer_profile_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/customer-profile.png` | `PASS` |
| Contato com profissional | `docs/prototipos-de-tela/tela-falar-com-o-profissional.png` | `worklink-mobile/lib/features/professional_contact/professional_contact_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/professional-contact.png` | `PASS` |
| Pós-contato | ponte entre contato e avaliação | `worklink-mobile/lib/features/post_contact_feedback/post_contact_feedback_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/post-contact-feedback.png` | `PASS` |
| Avaliação | `docs/prototipos-de-tela/tela-avaliacao-profissional.png` | `worklink-mobile/lib/features/professional_review/professional_review_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/professional-review.png` | `PASS` |
| Avaliação concluída | `docs/prototipos-de-tela/tela-avaliacao-concluida.png` | `worklink-mobile/lib/features/professional_review/professional_review_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/professional-review-success.png` | `PASS` |
| Denúncia | `docs/prototipos-de-tela/tela-denunciar-profissional.png` | `worklink-mobile/lib/features/professional_report/professional_report_screen.dart` | `docs/tasks/WLT-030/evidence/web-static/professional-report.png` | `PASS` |

## Evidências usadas

- `docs/tasks/WLT-030/evidence/web-static/*.png`
- `docs/tasks/WLT-030/evidence/generated/*.png`
- `worklink-mobile/test/widget/visual/goldens/*.png`
- `docs/prototipos-de-tela/*.png`

## Decisão técnica

A WLT-030 fica aprovada para o objetivo desta história: recuperar aderência visual, tema, hierarquia e evidência
auditável das telas mobile principais. Os screenshots web-static foram capturados a partir da aplicação Flutter Web real,
com tipografia legível e componentes renderizados, substituindo os goldens como evidência de revisão humana.

Os goldens permanecem como regressão automatizada, enquanto os screenshots web-static são a evidência visual oficial da
história.

## Restrições encaminhadas

- `WLT-032` continua responsável pela massa regional completa da região carbonífera.
- `WLT-033` continua responsável pela decisão funcional de canais de confirmação (`SMS`, `WhatsApp` e `email`).
- `WLT-034` deve transformar essa prática em gate recorrente de QA visual antes de aprovar APK/IPA.
