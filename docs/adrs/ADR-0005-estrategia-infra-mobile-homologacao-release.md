# ADR-0005 — Estrategia de infraestrutura mobile para homologacao e release

## Status

Aceito.

## Contexto

O WorkLink precisa permitir validacao real antes de publicar versoes em lojas. A validacao deve cobrir:

- aplicativo Android e iOS;
- backend acessivel pelo aparelho;
- banco de dados;
- massa fake de profissionais da regiao carbonifera;
- testes automatizados em CI;
- testes manuais feitos pelo dono do produto;
- artifacts rastreaveis por versao semantica.

Ao mesmo tempo, o projeto ainda esta em validacao de produto. Infraestrutura dedicada demais pode consumir tempo e dinheiro
antes de existir necessidade real.

## Decisao

O WorkLink adotara uma estrategia progressiva de infraestrutura mobile:

1. **Validacao economica**
   - Android continua em GitHub Actions Linux com testes, build e emulator.
   - O dono do produto pode testar APK manual quando houver backend acessivel.
   - iOS fica documentado e preparado, mas sem obrigar macOS runner ate haver necessidade real.
   - Tuneis HTTPS temporarios podem ser usados para aprendizado, mas nao fecham uma versao estavel de homologacao.

2. **Homologacao controlada**
   - Android deve gerar APK release de homologacao assinado com chave propria de homologacao.
   - O APK de homologacao deve apontar para backend HTTPS publico e allowlisted.
   - O APK fica como asset de GitHub Release; o git guarda metadados, checksum e ponteiro.
   - Backend de homologacao deve ter massa fake reproduzivel e reset controlado.

3. **Pre-producao de loja**
   - Android passa para AAB, Play Console Internal Testing e depois Closed/Open Testing.
   - iOS passa para pipeline macOS minima e TestFlight.
   - Crash reporting, observabilidade e plano de rollback/hotfix passam a ser obrigatorios.

## Papel Do Mobile Infra Specialist Agent

O `sre-agent` deve consultar o `mobile-infra-specialist-agent` sempre que uma historia tocar:

- Android ou iOS;
- emuladores/simuladores;
- assinatura mobile;
- TestFlight;
- Play Console;
- artifacts mobile;
- release mobile;
- custo de CI/CD mobile;
- ambiente de homologacao acessivel por aparelho real.

O parecer deve registrar:

- recomendacao principal;
- alternativas avaliadas;
- custo relativo;
- riscos;
- o que automatizar agora;
- o que adiar;
- impacto no teste manual do dono do produto.

## Matriz De Trade-Offs

| Opcao | Custo | Tempo | Confianca | Quando usar |
| --- | --- | --- | --- | --- |
| APK debug local + backend local | baixo | baixo | baixa a media | exploracao rapida em Android |
| APK release homologacao + backend HTTPS temporario | baixo a medio | medio | media | validar fluxo real sem contratar infra fixa |
| Backend cloud dedicado de homologacao | medio | medio | alta | validacao recorrente e releases frequentes |
| Play Console Internal Testing | baixo depois da conta | medio | alta para Android | preparacao para Google Play |
| TestFlight | exige Apple Developer Program | medio | alta para iOS | preparacao para App Store |
| macOS runner em CI para iOS | maior que Linux | medio | alta | quando iOS virar gate real |
| device farm pago | alto | medio a alto | muito alta | quando bugs de aparelho real justificarem custo |

## Politica De Custo

- Nao contratar infraestrutura dedicada antes de existir necessidade recorrente.
- Priorizar GitHub Actions Linux para Android enquanto o tempo de pipeline for aceitavel.
- Usar macOS runner apenas para gates iOS necessarios, porque macOS tende a custar mais que Linux em CI hospedada.
- Preferir teste manual do dono do produto quando a alternativa automatizada exigir tempo ou custo desproporcional.
- Usar os valores abaixo apenas como referencia de planejamento; antes de contratar ou ativar billing, consultar as
  paginas oficiais porque precos e regras podem mudar.
- Referencias atuais consultadas em 2026-05-22:
  - GitHub Actions Linux 2-core: USD 0.006 por minuto.
  - GitHub Actions macOS 3/4-core: USD 0.062 por minuto.
  - Google Play Console: USD 25 uma vez para registrar a conta.
  - Apple Developer Program: USD 99 por ano.
  - Google Play Internal Testing: ate 100 testers internos por app.
  - TestFlight: ate 10.000 testers externos.
- Reavaliar a decisao quando houver:
  - mais de uma versao de homologacao por semana;
  - bugs recorrentes encontrados apenas em aparelho real;
  - necessidade de TestFlight;
  - necessidade de closed testing na Play Store;
  - custo mensal de CI maior que o beneficio percebido.

## Regras Para WLT-029

- WLT-029 pode usar backend HTTPS temporario para gerar um APK Android de homologacao testavel.
- WLT-029 so fecha como homologacao estavel se o APK for release, assinado com chave de homologacao, apontar para HTTPS
  publico/allowlisted e for validado manualmente em aparelho Android.
- APK debug, preview/offline ou local-fullstack nao fecha a historia.
- iOS deve ter paridade documentada, mas o fluxo TestFlight completo permanece na WLT-026.

## Consequencias

Positivas:

- reduz custo inicial;
- preserva seguranca de signing;
- permite aprendizado rapido;
- cria trilha clara para Android e iOS.

Negativas:

- iOS completo fica dependente de Apple Developer Program, macOS runner e TestFlight;
- backend temporario exige cuidado para nao ser confundido com homologacao estavel;
- teste manual ainda sera necessario antes de loja.

## Referencias Oficiais

- GitHub Actions runner pricing: https://docs.github.com/billing/reference/actions-minute-multipliers
- Apple Developer Program: https://developer.apple.com/programs/
- Apple membership comparison: https://developer.apple.com/support/compare-memberships/
- Google Play testing tracks: https://support.google.com/googleplay/android-developer/answer/9845334
- Google Play Console registration: https://support.google.com/googleplay/android-developer/answer/6112435
