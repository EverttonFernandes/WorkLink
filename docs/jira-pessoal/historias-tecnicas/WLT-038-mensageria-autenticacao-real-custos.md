# WLT-038 — Mensageria de autenticação real e controle de custos

## Objetivo

Avaliar e preparar canais opcionais de autenticacao/verificacao para ativacao futura, com controle de custo e prevencao de
abuso, sem substituir o login proprio entregue pela WL-025.

## Valor técnico

SMS, WhatsApp Business API e alguns provedores externos podem gerar custo por envio ou operacao. O projeto precisa manter
esses canais desligados enquanto nao houver necessidade, orcamento e retorno validado.

## Decisão de produto

- A WL-025 define email e senha como caminho principal de cadastro e login da V1.
- Google, Facebook, SMS, WhatsApp Business e OTP por email ficam em stand by e desativados por padrao.
- Esta historia nao deve substituir o login proprio nem bloquear a publicacao enquanto os canais opcionais estiverem
  corretamente desligados.
- Contato com profissional via WhatsApp deep link continua sendo gratuito para o WorkLink e deve ser preservado.
- WhatsApp deep link não é WhatsApp Business API.
- OTP real deve ser protegido por limite de reenvio, limite por telefone/IP/dispositivo e orçamento mensal.
- Decisão preliminar do dono do produto: operar com custo mensal mínimo no lançamento.
- SMS e WhatsApp Business API não devem ser o caminho padrão inicial se criarem custo recorrente sem receita validada.
- O número de celular pode ser coletado como dado de contato/cadastro, mas a verificação paga do telefone deve ficar
  protegida por feature flag e só ser ativada quando houver orçamento, necessidade de confiança ou monetização validada.
- Cadastro simples sem verificação forte não pode liberar ações sensíveis de alto risco sem controles adicionais.

## Hipótese de ativação futura

1. Cliente entra inicialmente pelo login proprio entregue na WL-025.
2. Sistema mantem nome completo, email e numero de celular.
3. Fluxos comuns funcionam sem disparar SMS/WhatsApp pago.
4. Fluxos de maior risco podem exigir verificacao adicional quando houver necessidade e orcamento aprovados.
5. Google, Facebook, SMS, WhatsApp Business e OTP por email permanecem configuraveis, desligaveis e limitados por
   orcamento.

## Escopo incluído

- Comparar Google, Facebook, SMS, WhatsApp Business API e OTP por email para autenticacao/verificacao futura.
- Definir criterios de ativacao, custo maximo e risco aceito para cada canal.
- Escolher provedor ou sandbox apenas para o canal priorizado para experimentacao.
- Implementar adapter fake/sandbox para homologação.
- Implementar contrato de envio real por interface/porta.
- Avaliar Google e Facebook apenas como canais opcionais futuros.
- Integrar-se ao login proprio da WL-025 sem duplicar identidade, sessao ou autorizacao.
- Configurar feature flags por canal.
- Configurar secrets sem versionar valores.
- Implementar limites anti-abuso.
- Registrar eventos de envio sem expor OTP em logs.
- Documentar custo estimado por envio e teto mensal.
- Documentar quais ações podem ser usadas sem telefone verificado e quais exigem verificação forte.

## Fora do escopo

- Campanhas de marketing por WhatsApp.
- Chat interno.
- Automação comercial.
- Implementar todos os provedores de uma vez.
- Envio em massa.
- Monetização completa do marketplace.
- Verificação documental/KYC de profissionais.

## Critérios de aceite

- Login proprio da WL-025 confirmado como canal inicial.
- Provedor ou sandbox documentado.
- Estratégia de custo mínimo validada pelo produto.
- Login proprio da WL-025 permanece como alternativa inicial funcional e independente.
- Canais externos permanecem desativados ate decisao explicita de produto.
- Canal opcional priorizado possui sandbox funcional em ambiente controlado antes de qualquer ativacao real.
- Limites anti-abuso implementados ou especificados para bloqueio antes da loja.
- Custos estimados documentados.
- Teto mensal de custo definido antes de ativar SMS/WhatsApp pago.
- Feature flag permite desligar envio pago.
- Ações permitidas sem telefone verificado são explicitamente documentadas.
- Logs não expõem OTP.
- Testes cobrem sucesso, falha, limite e reenvio.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: torna a autenticação compatível com uso real nas lojas sem surpresa de custo.
