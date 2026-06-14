# Operacao da autenticacao local por email e senha

## Configuracao padrao

- Autenticacao local habilitada.
- Google/Gmail, Microsoft/Outlook, Facebook, Apple, WhatsApp Business, SMS e OTP desabilitados.
- Senha entre 12 e 128 caracteres.
- Cinco falhas consecutivas bloqueiam temporariamente a credencial.
- Bloqueio padrao de 15 minutos.
- Token de recuperacao de uso unico com validade padrao de 30 minutos.
- Recuperacao por email so fica operacional quando `WORKLINK_PASSWORD_RECOVERY_DELIVERY_MODE=smtp` estiver
  configurado com remetente e URL de redefinicao.

Os valores reais devem ser fornecidos por variaveis de ambiente documentadas em `.env.example`. Secrets nunca devem ser
versionados.

## Recuperacao de senha

1. O usuario informa o email.
2. A API sempre responde com mensagem generica, exista conta ou nao.
3. Para conta valida, a API gera token aleatorio, persiste apenas sua protecao/hash e envia pelo adapter configurado.
4. O token expira, aceita um unico uso e nunca deve aparecer em logs.
5. A redefinicao revoga todas as sessoes anteriores da conta.

O ambiente local pode oferecer suporte de teste protegido por profile `local`. Esse suporte nao deve existir no profile de
producao.

## Compatibilidade com contas legadas

- O cadastro publico por email e senha nao pode anexar credencial a um telefone ja existente no legado OTP.
- A migracao segura de conta legada para login proprio exigira prova de posse do canal anterior em historia posterior.

## Resposta a incidente

- Suspeita de credential stuffing: reduzir temporariamente o limite, revisar eventos de bloqueio e revogar sessoes afetadas.
- Vazamento de refresh token: revogar as sessoes da conta e rotacionar os secrets de assinatura quando houver risco amplo.
- Vazamento de token de recuperacao: invalidar desafios ativos e revisar o canal transacional.
- Comprometimento da base: senhas permanecem protegidas por hash lento com salt; ainda assim, comunicar e forcar troca.

## Rollback

- Desabilitar somente a feature flag de autenticacao local impede novos cadastros/logins sem apagar credenciais.
- Nao remover migrations nem reverter hashes de senha.
- Preservar refresh/logout para permitir encerramento seguro das sessoes existentes.
- Canais externos, incluindo Google/Gmail, Microsoft/Outlook e WhatsApp, so podem ser habilitados por historia posterior
  com custo, privacidade, seguranca e operacao aprovados.
