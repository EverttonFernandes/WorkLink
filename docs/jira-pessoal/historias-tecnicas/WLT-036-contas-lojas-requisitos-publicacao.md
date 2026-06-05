# WLT-036 — Contas das lojas e requisitos de publicação

## Objetivo

Preparar as contas, cadastros e requisitos obrigatórios para publicar o WorkLink na Google Play Store e, em seguida, na Apple App Store.

## Valor técnico

A estratégia oficial passa a ser aplicativo nas lojas. Antes de gerar builds finais, o projeto precisa garantir que contas, dados legais, políticas e assets mínimos estejam prontos para evitar bloqueios de revisão.

## Decisão fechada

- Foco principal: publicar aplicativo mobile nas lojas.
- Play Store é a primeira loja-alvo por custo menor e maior simplicidade operacional.
- App Store entra na sequência, exigindo Apple Developer Program.
- Web/PWA deixa de ser objetivo principal e só poderá ser retomado como apoio futuro.
- Backend em nuvem continua obrigatório, pois as lojas distribuem o app, mas não hospedam API, banco ou autenticação.

## Responsável principal

- Everton, com apoio técnico de Produto, SRE, Segurança e Mobile Infra.

## Escopo incluído

- Criar ou validar conta Google Play Console.
- Levantar custo e requisitos do Apple Developer Program.
- Definir nome público do app, descrição curta e descrição completa.
- Definir categoria, público-alvo e classificação indicativa.
- Preparar política de privacidade inicial.
- Preparar contato de suporte.
- Mapear screenshots obrigatórios por loja.
- Mapear ícone, feature graphic e assets de loja.
- Registrar checklist de dados de segurança exigidos pela Play Store.
- Registrar checklist equivalente para App Store Connect.

## Fora do escopo

- Publicar build nas lojas.
- Comprar infraestrutura robusta definitiva.
- Automação de upload para lojas.
- Campanhas de marketing.

## Critérios de aceite

- Conta Google Play Console criada ou caminho manual documentado.
- Decisão sobre Apple Developer Program documentada.
- Checklist de publicação Android criado.
- Checklist de publicação iOS criado.
- Política de privacidade inicial planejada.
- Assets mínimos de loja listados.
- Pendências manuais do Everton registradas em `docs/operacao/`.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: abre oficialmente o caminho de publicação em lojas.
