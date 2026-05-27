# WLT-030 — Parecer do Mobile Front-end Specialist

## Verdict

`REJECTED`

## Escopo avaliado

| Tela | Protótipo | Arquivo Flutter | Evidência atual | Status |
| --- | --- | --- | --- | --- |
| Autenticação por telefone | `docs/prototipos-de-tela/tela-login-autenticacao.png` | `worklink-mobile/lib/features/customer_authentication/customer_authentication_screen.dart` | `docs/tasks/WLT-030/evidence/generated/01-auth-phone-entry.png`, `02-auth-verification.png` | `FAIL` |
| Seleção de cidades | `docs/prototipos-de-tela/tela-selecionar-cidades.png` | `worklink-mobile/lib/features/city_selection/city_selection_screen.dart` | `docs/tasks/WLT-030/evidence/generated/03-city-selection.png` | `DECISAO_PRODUTO_NECESSARIA` |
| Descoberta / estado vazio | `docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png` | `worklink-mobile/lib/features/discovery/discovery_screen.dart` | `docs/tasks/WLT-030/evidence/generated/04-discovery-results.png`, `05-discovery-empty-state.png` | `FAIL` |
| Perfil do profissional | `docs/prototipos-de-tela/tela-perfil-do-profissional.png` | `worklink-mobile/lib/features/professional_profile/professional_profile_screen.dart` | `docs/tasks/WLT-030/evidence/generated/06-professional-profile.png` | `FAIL` |
| Cadastro profissional | `docs/prototipos-de-tela/tela-cadastro-do-profissional.png` | `worklink-mobile/lib/features/professional_registration/professional_registration_screen.dart` | `docs/tasks/WLT-030/evidence/generated/07-professional-registration.png` | `FAIL` |
| Perfil do cliente | `docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png` | `worklink-mobile/lib/features/customer_profile/customer_profile_screen.dart` | `docs/tasks/WLT-030/evidence/generated/08-customer-profile.png` | `FAIL` |
| Contato com profissional | `docs/prototipos-de-tela/tela-falar-com-o-profissional.png` | `worklink-mobile/lib/features/professional_contact/professional_contact_screen.dart` | `docs/tasks/WLT-030/evidence/generated/09-professional-contact.png` | `FAIL` |
| Pós-contato | relação secundária com `tela-falar-com-o-profissional.png` e `tela-avaliacao-profissional.png` | `worklink-mobile/lib/features/post_contact_feedback/post_contact_feedback_screen.dart` | `docs/tasks/WLT-030/evidence/generated/10-post-contact-feedback.png` | `DECISAO_PRODUTO_NECESSARIA` |
| Avaliação | `docs/prototipos-de-tela/tela-avaliacao-profissional.png` | `worklink-mobile/lib/features/professional_review/professional_review_screen.dart` | `docs/tasks/WLT-030/evidence/generated/11-professional-review.png` | `FAIL` |
| Avaliação concluída | `docs/prototipos-de-tela/tela-avaliacao-concluida.png` | `worklink-mobile/lib/features/professional_review/professional_review_screen.dart` | `docs/tasks/WLT-030/evidence/generated/12-professional-review-success.png` | `FAIL` |
| Denúncia | `docs/prototipos-de-tela/tela-denunciar-profissional.png` | `worklink-mobile/lib/features/professional_report/professional_report_screen.dart` | `docs/tasks/WLT-030/evidence/generated/13-professional-report.png` | `FAIL` |

## Evidências usadas

- `docs/tasks/WLT-030/evidence/generated/*.png`
- `worklink-mobile/test/widget/visual/goldens/*.png`
- `docs/prototipos-de-tela/*.png`
- feedback manual já registrado pelo dono do produto em `docs/debitos-tecnicos/DEBITOS-HOMOLOGACAO-MOBILE-2026-05-22.md`

## Findings principais

### 1. Bloqueio crítico: evidência atual não prova aderência visual real

Os screenshots gerados via golden test estão bons para regressão automatizada de layout, mas **não são adequados como
evidência final de produto** neste ambiente porque a tipografia aparece rasterizada em glifos quadrados/retângulos em
vez de texto legível. Isso impede validar:

- hierarquia tipográfica;
- microcopy;
- peso visual de botões e cards;
- acabamento real da interface;
- coerência com o protótipo aprovado.

### 2. Screenshots oficiais de APK/emulador continuam ausentes

O especialista mobile não pode aprovar a `WLT-030` sem screenshots reais do APK/emulador ou preview web funcional com
renderização fiel da tipografia e dos componentes.

### 3. Fluxo de autenticação ainda depende de decisão funcional irmã

A copy e a jornada de envio de código continuam semanticamente incompletas por depender da `WLT-033`, especialmente em
relação a:

- SMS;
- WhatsApp;
- e-mail.

Mesmo que a estrutura visual tenha evoluído, o especialista não aprova a tela final enquanto o canal real continuar
ambíguo.

### 4. Recorte regional ainda não está completamente homologado

Para homologação manual da descoberta regional, o especialista espera massa suficiente para validar o recorte inicial
da V1 com:

- Charqueadas
- São Jerônimo
- Triunfo
- Arroio dos Ratos
- Eldorado do Sul
- General Câmara
- Butiá

Esta lacuna conversa diretamente com a `WLT-032`.

## Action items para o Executor / próximos gates

1. Restaurar evidência oficial por um destes caminhos:
   - preview web dockerizado funcional com tipografia correta; ou
   - screenshots de APK/emulador; ou
   - screenshots do navegador com a app Flutter Web real, não DevTools.
2. Registrar uma matriz final tela → protótipo → screenshot oficial → veredito.
3. Retomar o recorte de massa/região com a `WLT-032` antes de chamar homologação manual completa.
4. Fechar a decisão de canal de autenticação na `WLT-033` antes da aprovação final da autenticação.

## Apoio para QA

QA deve tratar os goldens como:

- `PASS` para regressão visual automatizada;
- `FAIL` como evidência final de aderência de produto.

Checklist mínimo antes de aprovar:

- texto legível nas evidências oficiais;
- cores e hierarquia equivalentes ao protótipo;
- estados de sucesso, vazio e formulário visíveis em screenshots reais;
- ausência de labels técnicas na UI.

## Apoio para Product Manager

Decisões pendentes de produto:

1. confirmar se pós-contato seguirá protótipo próprio novo ou permanecerá como ponte entre contato e avaliação;
2. consolidar regra final do canal de autenticação (`WLT-033`);
3. decidir se a história `WLT-030` pode ser fechada apenas após screenshots oficiais ou se aceita uma etapa intermediária
   chamada "pré-aprovação visual técnica".
