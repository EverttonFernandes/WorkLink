# Guia de infraestrutura mobile para homologacao e release

Este guia operacional complementa o SRE para Android e iOS. A decisao de arquitetura esta em
`docs/adrs/ADR-0005-estrategia-infra-mobile-homologacao-release.md`.

## Objetivo

Garantir que cada versao mobile possa ser validada antes de chegar ao publico, equilibrando:

- teste automatizado;
- teste manual pelo dono do produto;
- custo de infraestrutura;
- seguranca de assinatura;
- rastreabilidade por versao semantica.

## Agentes Responsaveis

- `sre-agent`: dono do gate operacional.
- `mobile-infra-specialist-agent`: parceiro obrigatorio do SRE para Android/iOS, lojas, assinatura, emuladores e custos.
- `qa-agent`: dono dos testes automatizados.
- `security-specialist-agent`: dono de secrets, assinatura e riscos de exposicao.

## Trilha Recomendada

### 1. Android barato e funcional

Use enquanto o produto ainda esta validando fluxo real.

- CI Linux no GitHub Actions.
- Testes unitarios, widget/integracao e emulator Android.
- APK manual para o dono do produto.
- Backend local ou temporario HTTPS para validar fluxo real.

Saida aceitavel:

- APK testavel manualmente.
- Evidencia de CI verde.
- Massa fake carregada.

Limite:

- APK debug ou local nao fecha homologacao estavel.

### 2. Android de homologacao controlada

Use para uma versao interna que pode virar referencia.

- APK release assinado com chave de homologacao.
- Backend HTTPS publico e allowlisted.
- Artifact `worklink-android-homologation-<commit>`.
- Promocao para GitHub Release.
- Metadados versionados em `artifacts/homologation/releases/<versao>/android`.

Saida aceitavel:

- Dono do produto instala o APK no Android fisico.
- Fluxos principais passam com backend e massa real de homologacao.

### 3. Android loja

Use perto da publicacao.

- AAB.
- Play App Signing.
- Play Console Internal Testing.
- Closed/Open Testing quando necessario.
- Observabilidade e plano de hotfix.

### 4. iOS

Use quando houver preparacao real para App Store.

- Apple Developer Program ativo.
- Certificados e provisioning profiles.
- Build em macOS runner ou maquina confiavel.
- TestFlight interno.
- Teste manual em iPhone real.

Limite:

- iOS simulator ajuda no desenvolvimento, mas nao substitui TestFlight nem teste em aparelho real.

## Politica De Automacao Versus Teste Manual

Automatize quando:

- o mesmo teste precisa rodar em todo commit;
- a falha seria cara ou dificil de perceber manualmente;
- a pipeline ja consegue executar dentro de tempo/custo aceitavel;
- a automacao reduz risco de publicar versao quebrada.

Prefira teste manual quando:

- a automacao exige conta paga, runner caro ou device farm antes da hora;
- a validacao depende de percepcao de produto;
- o objetivo e explorar a experiencia inicial;
- o custo operacional ainda nao se justifica.

## Custos E Trade-Offs

Valores de mercado mudam. Antes de ativar billing ou comprar conta de loja, valide nas paginas oficiais. Em
2026-05-22, as referencias usadas para planejamento sao:

- GitHub Actions Linux 2-core: USD 0.006 por minuto.
- GitHub Actions macOS 3/4-core: USD 0.062 por minuto.
- Google Play Console: USD 25 uma vez para registrar a conta.
- Apple Developer Program: USD 99 por ano.
- Google Play Internal Testing: ate 100 testers internos por app.
- TestFlight: ate 10.000 testers externos.

### Baixo custo

- GitHub Actions Linux para Android.
- APK manual baixado do artifact.
- Backend local ou temporario.

Risco:

- menos parecido com loja;
- exige disciplina manual.

### Custo medio

- Backend cloud de homologacao.
- Play Console Internal Testing.
- Releases semanticas com artifacts promovidos.

Risco:

- manutencao de ambiente;
- cuidado com dados fake e reset.

### Custo alto

- macOS runner frequente.
- device farm pago.
- infraestrutura dedicada sempre ligada.

Risco:

- custo antes de maturidade de produto;
- mais tempo em DevOps do que em aprendizado de negocio.

## Exit Bar Mobile Infra

Para considerar uma etapa mobile pronta, registre:

- CI verde.
- Artifact correto gerado.
- Tipo de assinatura claro.
- Backend usado identificado.
- Massa de dados conhecida.
- Caminho de instalacao manual documentado.
- Gate visual/produto aprovado quando houver UI ou teste humano de APK/IPA.
- Riscos e custos remanescentes registrados.

O gate visual oficial esta em `docs/qa/mobile-visual-homologation-gate.md` e deve ser validado com:

```bash
make mobile-visual-qa-gate TASK_KEY=<KEY>
```

## Aplicacao Na WLT-029

Estado atual esperado:

- Android CI verde.
- Keystore de homologacao local gerada.
- Falta URL HTTPS publica de backend de homologacao.

Proximo passo operacional:

```bash
WORKLINK_HOMOLOGATION_API_BASE_URL=https://sua-url-de-homologacao \
make configure-android-homologation-github-env
```

Depois disso, a CI deve gerar:

```text
worklink-android-homologation-<commit>
```

Esse sera o APK correto para teste manual full-stack no Android fisico.
