# WLT-038 - Mensageria de autenticacao real e controle de custos

## Historia

Como dono do produto, quero manter SMS, WhatsApp Business, email OTP e logins externos preparados, mas desligados e
controlados por custo, para que o aplicativo possa evoluir com seguranca sem comprometer o lancamento via login proprio.

## Fontes

- `docs/jira-pessoal/historias-tecnicas/WLT-038-mensageria-autenticacao-real-custos.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/tasks/WL-025/IMPLEMENTATION.md`
- `worklink-api/src/main/resources/application.yml`

## Aceite

- Login proprio da WL-025 permanece como caminho principal.
- Canais externos ficam desativados por padrao e documentados.
- Existe estrategia minima de sandbox/adapter fake para ambientes controlados.
- Limites anti-abuso e teto de custo ficam implementados ou formalmente especificados antes da loja.
- Logs e auditoria nao expõem OTP, token ou segredo.
- Pendencias manuais de provedor/secrets ficam separadas do que o codigo ja suporta.
