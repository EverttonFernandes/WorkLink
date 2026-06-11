# Checklist Google Play Console - Profissional Perto

## Conta

- [ ] Conta pessoal criada em `https://play.google.com/console/signup`.
- [ ] Titular maior de 18 anos.
- [ ] Taxa de cadastro paga.
- [ ] Verificacao de identidade concluida.
- [ ] 2FA ativo na conta Google.
- [ ] Email publico de suporte definido.

## Criacao do app

- [ ] Nome do app: `Profissional Perto`.
- [ ] Idioma padrao: Portugues Brasil.
- [ ] Tipo: aplicativo.
- [ ] Preco: gratuito inicialmente.
- [ ] Declaracao de politicas aceita.
- [ ] Play App Signing aceito.
- [ ] Pacote Android definitivo confirmado: `br.com.worklink.mobile`.

## Ficha da loja

- [ ] Nome com ate 30 caracteres.
- [ ] Descricao curta com ate 80 caracteres.
- [ ] Descricao completa revisada.
- [ ] Categoria definida.
- [ ] Tags definidas sem exagero de palavras-chave.
- [ ] Email de contato publico preenchido.
- [ ] Site ou pagina de suporte definida quando existir.
- [ ] Politica de privacidade em URL publica e ativa.

## Assets

- [ ] Icone de alta resolucao.
- [ ] Feature graphic.
- [ ] Screenshots Android phone.
- [ ] Screenshots tablet apenas se houver suporte real.
- [ ] Screenshots alinhados aos prototipos oficiais.
- [ ] Nenhuma tela tecnica, mock quebrado ou backend indisponivel aparece nas imagens.

## Conteudo e privacidade

- [ ] Data Safety preenchido conforme dados realmente coletados.
- [ ] Politica de privacidade menciona Profissional Perto e/ou o publicador.
- [ ] Politica descreve contato de privacidade.
- [ ] Politica descreve dados coletados, uso, compartilhamento, seguranca, retencao e exclusao.
- [ ] Classificacao indicativa preenchida.
- [ ] Publico-alvo e conteudo preenchidos.
- [ ] Declaracoes de anuncios preenchidas.
- [ ] Declaracoes de permissao sensivel preenchidas, se aplicavel.

## Teste interno

- [ ] Lista de testers criada.
- [ ] AAB release gerado pela CI.
- [ ] `versionCode` incrementado.
- [ ] API cloud HTTPS configurada.
- [ ] App instalado via Play Store Internal Testing.
- [ ] Smoke test manual aprovado pelo Everton.
- [ ] Evidencias registradas antes de ir para producao.

## Teste fechado obrigatorio para conta pessoal nova

- [ ] Pelo menos 12 testers com conta Google recrutados.
- [ ] Testers opt-in no Closed Testing.
- [ ] Testers permanecem opt-in por 14 dias continuos.
- [ ] Feedback coletado e resumido.
- [ ] Correcoes criticas aplicadas antes de solicitar producao.
- [ ] Solicitação de acesso a producao preenchida no dashboard da Play Console.

## Go/no-go

- [ ] Backend cloud esta estavel.
- [ ] Autenticacao real esta funcionando e com custo controlado.
- [ ] Fluxos principais funcionam em aparelho real.
- [ ] Politicas e Data Safety conferem com o app.
- [ ] Suporte e canal de contato estao prontos.
- [ ] Plano de rollback/hotfix esta documentado.
