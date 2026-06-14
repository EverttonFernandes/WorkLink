# Autenticacao, mensageria e controle de custos

## Objetivo

Este documento consolida a decisao operacional da `WLT-038`: o aplicativo pode ser publicado usando autenticacao propria
por email e senha, mantendo canais externos opcionais preparados, mas desligados por padrao e protegidos contra custo
acidental.

## Estado oficial no lancamento

- Canal principal: login proprio por email e senha (`WL-025`).
- Recuperacao de senha: suportada por contrato proprio; entrega real por email continua opcional.
- OTP por SMS, WhatsApp Business ou email: desativado por padrao.
- Google, Microsoft e Facebook: desativados por padrao.
- WhatsApp deep link com profissional: permitido e sem custo para o WorkLink.

## Teto de custo da V1

- Teto mensal de mensageria paga no lancamento: **R$ 0,00**.
- Enquanto esse teto for zero, os modos pagos devem permanecer desligados por feature flag e por `delivery-mode`.
- Qualquer piloto futuro com custo recorrente deve nascer com aprovacao explicita de produto e novo teto mensal
  documentado.

## Matriz de canais

| Canal | Uso pretendido | Estado atual | Custo operacional no WorkLink | Gate para ativacao |
| ----- | -------------- | ------------ | ------------------------------ | ------------------ |
| Email e senha | login principal | ativo | baixo e previsivel | nenhum extra |
| Recuperacao por email | redefinicao de senha | `disabled` ou `smtp` | variavel por provedor de email | secrets SMTP + aprovacao operacional |
| OTP por SMS | autenticacao/verificacao forte | desligado | pago por envio | provider, secrets, rate limit e teto aprovado |
| OTP por WhatsApp Business | autenticacao/verificacao forte | desligado | pago por conversa/envio | provider, templates, secrets e teto aprovado |
| OTP por email | autenticacao/verificacao forte | desligado | baixo/variavel | sender confiavel + rate limit |
| Google | login social futuro | desligado | baixo, mas com setup e manutencao | credenciais OAuth e revisao de privacidade |
| Microsoft | login social futuro | desligado | baixo, mas com setup e manutencao | credenciais OAuth e revisao de privacidade |
| Facebook | login social futuro | desligado | baixo, mas com setup e manutencao | credenciais OAuth e revisao de privacidade |

## Controles tecnicos ativos

- `WORKLINK_FEATURE_LOCAL_AUTHENTICATION_ENABLED=true` mantem o login proprio.
- `WORKLINK_FEATURE_OTP_AUTHENTICATION_ENABLED=false` bloqueia a autenticacao por codigo na V1.
- `WORKLINK_AUTHENTICATION_OTP_DELIVERY_MODE=disabled` impede ativacao acidental de sandbox/provedor.
- `WORKLINK_OTP_REQUEST_COOLDOWN_SECONDS=45` protege reenvios muito frequentes por telefone.
- Flags por canal controlam exposicao do catalogo de entrega:
  - `WORKLINK_FEATURE_SMS_ENABLED`
  - `WORKLINK_FEATURE_EMAIL_OTP_ENABLED`
  - `WORKLINK_FEATURE_WHATSAPP_ENABLED`
- O backend nunca deve registrar OTP bruto, token bruto ou segredo em logs.

## Modo sandbox

Quando for necessario homologar a trilha OTP sem custo real:

- ligar `WORKLINK_FEATURE_OTP_AUTHENTICATION_ENABLED=true`;
- ligar apenas os canais desejados;
- definir `WORKLINK_AUTHENTICATION_OTP_DELIVERY_MODE=sandbox`;
- manter `WORKLINK_TEST_SUPPORT_FIXED_OTP` apenas em ambiente controlado.

O modo `sandbox` valida:

- selecao de canal disponivel;
- cooldown de reenvio;
- persistencia do hash do OTP;
- resposta HTTP esperada pelo mobile;
- ausencia de envio pago real.

## Acoes permitidas sem verificacao forte

Na V1 atual, seguem liberadas com login proprio e controles normais de sessao:

- criar conta local;
- autenticar com email e senha;
- recuperar/redefinir senha;
- navegar em cidades, categorias e perfis;
- salvar preferencias e profissionais;
- iniciar contato com profissional por link de WhatsApp;
- enviar feedback, avaliacao e denuncia dentro das regras ja protegidas por autenticacao, ownership e auditoria.

## Acoes que devem exigir verificacao forte no futuro

Ainda nao existem fluxos obrigatorios na V1, mas a regra daqui para frente e:

- mudanca de telefone primario usado para confianca;
- passwordless login por OTP real;
- vinculacao de login social com takeover sensivel;
- fluxos financeiros, repasses ou monetizacao;
- recuperacao de conta em cenarios de alto risco;
- qualquer operacao que aumente fraude, custo ou impacto juridico.

## Pendencias manuais antes de ativar um canal pago

1. escolher provedor;
2. cadastrar secrets fora do Git;
3. definir teto mensal e responsavel pelo acompanhamento;
4. revisar privacidade e textos da loja;
5. validar custos com volume real esperado;
6. criar monitoramento/alerta de consumo.
