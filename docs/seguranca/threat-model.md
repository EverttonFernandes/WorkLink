# Threat model — WorkLink V1

## Ativos

- Dados de clientes e profissionais.
- Telefone/WhatsApp.
- Documento do profissional.
- Evidências de denúncia.
- Tokens e sessões.
- Auditoria de ações sensíveis.

## Ameaças principais

- Acesso administrativo indevido.
- Exposição de autoria interna de avaliações anônimas.
- Vazamento de documentos, telefones, evidências ou tokens.
- Manipulação de denúncias, avaliações e bloqueios.
- Logs com dados sensíveis.
- Abuso de busca/contato para scraping.

## Controles existentes

- Autorização por perfil e ownership.
- Auditoria de ações sensíveis.
- Proteção criptográfica de dados sensíveis.
- Minimização de payloads administrativos.
- Sanitização de logs.
- Containers e configuração por ambiente.

## Pendências explícitas

- Rate limiting real em borda/API.
- Gestão produtiva de secrets fora do repositório.
- Monitoramento centralizado e alertas produtivos.
