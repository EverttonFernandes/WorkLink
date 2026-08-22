# Checklist manual - Execucao Play Console

## Pre-condicoes

- [ ] `WLT-037` concluida com backend HTTPS estavel e persistente.
- [ ] `WLT-039` concluida com artifact `worklink-android-play-internal-<commit>`.
- [ ] Conta Google Play Console ativa.
- [ ] Metadados minimos e politica de privacidade preenchidos.

## Conferencia do artifact

- [ ] Run verde da CI identificado.
- [ ] Artifact `worklink-android-play-internal-<commit>` baixado.
- [ ] Arquivo `.aab` presente no zip.
- [ ] `BUILD-METADATA.txt` validado.
- [ ] `SHA256SUMS` validado.
- [ ] Backend em `api_base_url` confere com o backend cloud esperado.

## Internal testing

- [ ] App `Profissional Perto` selecionado na Play Console.
- [ ] Menu `Testing > Internal testing` acessado.
- [ ] Release interna criada ou atualizada.
- [ ] `.aab` enviado com sucesso.
- [ ] `versionCode` aceito sem conflito.
- [ ] Lista de testers internos configurada.
- [ ] Release publicada.
- [ ] Link/convite de teste interno gerado.

## Validacao em aparelho real

- [ ] App instalado via Play Store.
- [ ] Tela inicial abre.
- [ ] Dados reais carregam.
- [ ] Login principal funciona.
- [ ] Navegacao principal funciona sem erro bloqueante.
- [ ] Veredito do smoke test registrado.

## Closed testing, se exigido

- [ ] Regra da conta pessoal nova confirmada.
- [ ] Pelo menos 12 testers recrutados.
- [ ] Testers opt-in na trilha fechada.
- [ ] Janela de 14 dias continuos planejada/iniciada.
- [ ] Feedbacks coletados.
- [ ] Bloqueios e correcoes criticas registrados.

## Saida

- [ ] Pode seguir para WLT-041.
- [ ] Ou ficou bloqueado, com motivo documentado.
