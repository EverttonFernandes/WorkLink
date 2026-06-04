# Gate de QA visual para homologacao mobile

## Objetivo

Impedir que APK, IPA ou artifact mobile seja aprovado para homologacao manual de produto apenas porque compilou,
instalou ou passou testes automatizados.

## Quando este gate e obrigatorio

Execute este gate sempre que uma historia:

- criar ou alterar tela Flutter;
- gerar APK, IPA ou artifact mobile para teste humano;
- alterar tema, navegacao, microcopy, massa visual ou fluxo principal;
- promover artifact de teste, homologacao ou release candidate.

## Classes oficiais de artifact

| Classe | Uso permitido | Pode ser homologacao de produto? |
| ------ | ------------- | -------------------------------- |
| `technical-build` | provar compilacao, assinatura, instalacao ou CI | Nao |
| `preview` | explorar UI com dados locais/mockados | Nao, apenas revisao rapida |
| `functional-homologation` | testar fluxo real com backend e massa de homologacao | Sim, se este gate passar |
| `release-candidate` | candidato a loja/TestFlight/Play testing | Sim, se este gate, CI, SRE e seguranca passarem |

## Evidencias obrigatorias

Para aprovar `mobile_tests = PASS`, registre em `docs/tasks/<KEY>/visual-qa/`:

- `MOBILE_VISUAL_QA_MATRIX.md`;
- `MOBILE_FRONTEND_SPECIALIST_REVIEW.md`;
- `screenshots/` com imagens reais do APK, emulador, iOS simulator ou device fisico.

Quando a historia tiver prototipo mapeado, a matriz deve citar o prototipo correspondente em
`docs/prototipos-de-tela/` ou `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md`.

## Matriz minima

`MOBILE_VISUAL_QA_MATRIX.md` deve conter:

- `Visual QA Verdict: PASS`;
- classe do artifact;
- historia responsavel;
- tela/estado validado;
- prototipo oficial comparado;
- arquivo Flutter relacionado;
- screenshot usado como evidencia;
- status por tela: `PASS`, `FAIL` ou `DECISAO_PRODUTO_NECESSARIA`;
- divergencias encontradas e decisao tomada.

Qualquer `FAIL` ou `DECISAO_PRODUTO_NECESSARIA` sem decisao de produto registrada bloqueia homologacao.

## Veredito do especialista mobile

`MOBILE_FRONTEND_SPECIALIST_REVIEW.md` deve conter:

- `Verdict: APPROVED`;
- lista de telas avaliadas;
- evidencias visuais usadas;
- divergencias aceitas ou inexistentes;
- riscos remanescentes.

Veredito ausente, incompleto ou `REJECTED` mantem `mobile_tests = FAIL`.

## Comando oficial

```bash
make mobile-visual-qa-gate TASK_KEY=WLT-000
```

O comando valida a estrutura minima da evidencia. Ele nao substitui a revisao humana do Product Manager, QA ou Final
Reviewer.

## Regra de aprovacao

CI verde, emulador verde e APK baixavel significam apenas que o artifact e tecnicamente valido.

Para ser homologavel como produto, o artifact tambem precisa passar por:

- comparacao visual com prototipos;
- massa de dados coerente com a regiao inicial;
- ausencia de labels tecnicas;
- microcopy em portugues;
- declaracao clara da classe do artifact;
- evidencias registradas na pasta da historia.
