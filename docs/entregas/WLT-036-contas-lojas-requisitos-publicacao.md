# Entrega WLT-036 - Contas das lojas e requisitos de publicacao

## Resultado

Concluida. A historia abriu oficialmente a estrategia loja-first do WorkLink e criou a base documental para Everton
concluir a conta da Play Console, preparar metadados publicos e evitar publicacao prematura sem backend, autenticacao e
privacidade prontos.

## Artefatos

- `docs/operacao/publicacao-lojas-mobile.md`
- `docs/operacao/checklist-google-play-console.md`
- `docs/operacao/checklist-app-store-connect.md`
- `docs/operacao/metadados-lojas-worklink.md`
- `docs/operacao/politica-privacidade-worklink-rascunho.md`
- `docs/tasks/WLT-036/IMPLEMENTATION.md`
- `docs/tasks/WLT-036/TASK.md`
- `docs/tasks/WLT-036/progress.txt`

## Validacao

- `git diff --check`: PASS.
- `make mobile-signing-governance`: PASS.

## Pendencias manuais fora desta historia

- Everton finalizar a conta pessoal da Google Play Console.
- Everton definir email publico de suporte.
- Everton confirmar se a conta Apple Developer sera criada agora ou depois da trilha Android.

## Bloqueio de producao

O app ainda nao deve ir para producao publica na loja. Antes disso, o backlog precisa concluir:

- WLT-037: backend cloud minimo para app nas lojas.
- WLT-038: autenticacao real, custo minimo e anti-abuso.
- WLT-039: AAB, assinatura e Play Store Internal/Closed Testing.
- WLT-041: publicacao controlada, suporte, monitoramento e rollback.

## Proxima historia

WLT-037 - Backend cloud minimo para aplicativo nas lojas.
