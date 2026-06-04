# WLT-029 — Matriz de QA visual mobile

Visual QA Verdict: PASS

Artifact class: functional-homologation

## Artifact avaliado

- Versao alvo: `v0.49.0`
- Source run: `26948049311`
- Source artifact: `worklink-android-homologation-6883e468d74c989f37fe62b76e84d2a2fe843490`
- Metadata: `artifacts/homologation/releases/v0.49.0/android/BUILD-METADATA.txt`
- Backend: `https://particular-deborah-vhs-emission.trycloudflare.com`

## Evidencia visual usada

As screenshots em `screenshots/` foram copiadas do baseline aprovado da WLT-030 em
`docs/tasks/WLT-030/evidence/web-static/`. A CI da WLT-029/WLT-035 validou build Android release, artifact de
homologacao, emulador Android e testes mobile no run `26948049311`.

Referencia normativa: `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md` e `docs/prototipos-de-tela/`.

| Tela/estado | Prototipo oficial | Evidencia | Status |
| ----------- | ----------------- | --------- | ------ |
| Login por telefone | docs/prototipos-de-tela/tela-login-autenticacao.png | screenshots/auth-phone-entry.png | PASS |
| Verificacao de codigo | docs/prototipos-de-tela/tela-login-autenticacao.png | screenshots/auth-verification.png | PASS |
| Selecao de cidades | docs/prototipos-de-tela/tela-selecionar-cidades.png | screenshots/city-selection.png | PASS |
| Descoberta/listagem | docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png | screenshots/discovery-results.png | PASS |
| Estado vazio | docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png | screenshots/discovery-empty-state.png | PASS |
| Perfil profissional | docs/prototipos-de-tela/tela-perfil-do-profissional.png | screenshots/professional-profile.png | PASS |
| Cadastro profissional | docs/prototipos-de-tela/tela-cadastro-do-profissional.png | screenshots/professional-registration.png | PASS |
| Perfil cliente | docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png | screenshots/customer-profile.png | PASS |
| Falar com profissional | docs/prototipos-de-tela/tela-falar-com-o-profissional.png | screenshots/professional-contact.png | PASS |
| Avaliacao profissional | docs/prototipos-de-tela/tela-avaliacao-profissional.png | screenshots/professional-review.png | PASS |
| Avaliacao concluida | docs/prototipos-de-tela/tela-avaliacao-concluida.png | screenshots/professional-review-success.png | PASS |
| Denuncia | docs/prototipos-de-tela/tela-denunciar-profissional.png | screenshots/professional-report.png | PASS |

## Limitacao conhecida

A evidencia visual automatizada nao substitui o teste manual do dono do produto em aparelho Android fisico. O pacote
`v0.49.0` fica apto para esse teste manual controlado, nao para publicacao em loja.
