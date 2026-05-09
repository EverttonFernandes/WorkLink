# Política básica de segurança

## Secrets

Secrets reais não devem ser commitados. Use `.env.example` apenas com valores fictícios.

## Dados sensíveis

Dados pessoais, documentos, tokens, evidências e autoria interna devem ser minimizados em payloads e logs.

## Revisão obrigatória

Histórias que tocam autenticação, autorização, LGPD, auditoria, denúncias, avaliações, storage ou administração exigem
gate de segurança.

## Divulgação

Vulnerabilidades devem ser tratadas como incidentes P0/P1 conforme impacto e registradas com evidências suficientes para
correção rastreável.
