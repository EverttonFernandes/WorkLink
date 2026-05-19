# WLT-026 — Preparação iOS para CI e TestFlight

## Objetivo

Preparar a estratégia técnica para build iOS em runner macOS e distribuição futura via TestFlight, sem bloquear o desenvolvimento Android.

## Valor técnico

Como o WorkLink é multiplataforma, a esteira precisa reconhecer as exigências específicas da Apple: runner macOS, certificados, provisioning profiles, bundle identifier e conta Apple Developer.

## RNFs relacionados

- RNF01
- RNF06
- RNF13
- RNF14

## Escopo incluído

- Documentar a estratégia oficial de CI iOS.
- Validar estrutura mínima do projeto `ios/`.
- Definir requisitos de Apple Developer Account, certificados e provisioning.
- Criar desenho do workflow `ios-build` para runner macOS.
- Definir secrets necessários para TestFlight sem expor credenciais.
- Registrar limitações enquanto não houver credenciais reais.

## Fora do escopo

- Publicação efetiva no TestFlight.
- Upload automático para App Store Connect.
- Criação de certificados reais dentro do repositório.
- Testes em device físico iOS.

## Critérios de aceite

- Existe guia claro para habilitar build iOS na CI.
- Os secrets e variáveis esperados estão documentados.
- O projeto explicita o que pode ser validado sem conta Apple e o que depende dela.
- A futura automação de TestFlight fica mapeada como próximo incremento.
- Nenhum certificado, chave privada ou profile sensível é versionado.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: prepara a plataforma para distribuição iOS sem introduzir risco de secrets.
