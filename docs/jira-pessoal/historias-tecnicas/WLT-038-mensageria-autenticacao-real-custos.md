# WLT-038 — Mensageria de autenticação real e controle de custos

## Objetivo

Definir e implementar a estratégia mínima de autenticação real para o aplicativo das lojas, com controle de custo e
prevenção de abuso.

## Valor técnico

Um app publicado precisa permitir autenticação funcional. SMS e WhatsApp API podem gerar custo por envio, então o projeto
precisa escolher canal, provedor, limites e feature flags antes de abrir para usuários reais.

## Decisão de produto

- Contato com profissional via WhatsApp deep link continua sendo gratuito para o WorkLink e deve ser preservado.
- WhatsApp deep link não é WhatsApp Business API.
- OTP real deve ser protegido por limite de reenvio, limite por telefone/IP/dispositivo e orçamento mensal.
- Se SMS/WhatsApp API estiver caro ou burocrático, email pode ser usado como canal inicial de menor custo, desde que aprovado pelo produto.
- Decisão preliminar do dono do produto: operar com custo mensal mínimo no lançamento.
- SMS e WhatsApp Business API não devem ser o caminho padrão inicial se criarem custo recorrente sem receita validada.
- A primeira estratégia de produção deve priorizar autenticação de baixo custo, como login Google e/ou cadastro simples com
  nome completo e número de celular.
- O número de celular pode ser coletado como dado de contato/cadastro, mas a verificação paga do telefone deve ficar
  protegida por feature flag e só ser ativada quando houver orçamento, necessidade de confiança ou monetização validada.
- Cadastro simples sem verificação forte não pode liberar ações sensíveis de alto risco sem controles adicionais.

## Hipótese de autenticação inicial

1. Cliente entra com login Google ou cadastro simples.
2. Sistema coleta nome completo e número de celular.
3. Fluxos de baixo risco funcionam sem disparar SMS/WhatsApp pago.
4. Fluxos sensíveis podem exigir verificação adicional quando a WLT-038 implementar o gate real.
5. SMS/WhatsApp/email OTP ficam como canais configuráveis, desligáveis e limitados por orçamento.

## Escopo incluído

- Comparar login Google, cadastro simples, SMS, WhatsApp Business API e email para autenticação/verificação.
- Escolher canal padrão de produção inicial.
- Escolher provedor inicial ou sandbox.
- Implementar adapter fake/sandbox para homologação.
- Implementar contrato de envio real por interface/porta.
- Implementar ou especificar autenticação Google/cadastro simples como alternativa de menor custo.
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

- Canal de autenticação inicial decidido.
- Provedor ou sandbox documentado.
- Estratégia de custo mínimo validada pelo produto.
- Login Google e/ou cadastro simples avaliados como alternativa inicial.
- OTP real ou sandbox funcional em ambiente controlado.
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
