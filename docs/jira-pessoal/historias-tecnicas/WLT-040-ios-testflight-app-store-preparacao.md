# WLT-040 — iOS TestFlight e preparação App Store

## Objetivo

Preparar o WorkLink para distribuição iOS via TestFlight e posterior publicação na Apple App Store.

## Valor técnico

Depois da Play Store, o iOS precisa de conta Apple Developer, certificados, provisioning, App Store Connect e fluxo de TestFlight. Esta história organiza a etapa sem misturar com Android.

## Decisão fechada

- Apple Store é etapa posterior à Play Store, mas deve ser preparada desde já para não acumular dívida.
- TestFlight é obrigatório antes de App Store pública.
- O app iOS deve usar a mesma API cloud estável do Android.

## Escopo incluído

- Confirmar Apple Developer Program e custo anual.
- Definir Bundle ID definitivo.
- Configurar certificados/provisioning ou automação equivalente.
- Configurar App Store Connect API key.
- Criar workflow manual macOS para build iOS assinável.
- Preparar upload TestFlight.
- Documentar screenshots, política, privacidade e revisão Apple.
- Validar instalação TestFlight em iPhone real quando conta/secrets existirem.

## Ações manuais esperadas

- Everton contratar/ativar Apple Developer Program.
- Everton criar ou confirmar o app no App Store Connect.
- Everton cadastrar secrets/certificados reais fora do repositório.
- Everton executar ou acompanhar smoke test em iPhone real via TestFlight.

## Fora do escopo

- Publicação pública imediata na App Store.
- Compra de conta Apple pelo Codex.
- Suporte avançado a múltiplos flavors iOS.
- Web/PWA.

## Critérios de aceite

- Requisitos Apple Developer documentados.
- Secrets iOS inventariados sem valores reais.
- Workflow iOS manual preparado para TestFlight.
- Build iOS aponta para API cloud estável.
- Checklist App Store Connect criado.
- Bloqueios manuais do Everton claramente listados.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: prepara a segunda loja sem travar o caminho Android.
