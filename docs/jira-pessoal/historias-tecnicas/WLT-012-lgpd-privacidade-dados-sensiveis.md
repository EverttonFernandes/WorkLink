# WLT-012 — LGPD, privacidade e minimização de dados

## Objetivo

Aplicar privacidade por padrão e desde a concepção nos dados pessoais tratados pela V1.

## Valor técnico

Reduz risco regulatório e protege usuários, profissionais e denunciantes.

## RNFs relacionados

- RNF04, RNF05

## Escopo incluído

- Minimização de dados.
- Finalidade clara.
- Anonimização pública de avaliações.
- Rastreabilidade interna controlada.
- Retenção definida.
- Exclusão de conta como requisito técnico.
- Dados que não devem ser coletados na V1.

## Fora do escopo

- Dados bancários.
- Cartão de crédito.
- Documentos com foto.
- Localização contínua em tempo real.
- Dados financeiros.

## Critérios de aceite

- O sistema não deve coletar dados fora do escopo da V1.
- Avaliações anônimas devem ocultar identidade publicamente.
- Dados pessoais devem ter finalidade clara.
- Acesso a dados sensíveis deve ser restrito.
- Exclusão de conta deve ser considerada no desenho técnico.
- Incidentes de privacidade devem ter fluxo mínimo documentado.

## Entrega versionável

- Tipo sugerido: `MINOR`
