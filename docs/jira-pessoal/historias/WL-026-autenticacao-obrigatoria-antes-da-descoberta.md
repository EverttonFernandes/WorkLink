# WL-026 — Navegacao anonima com autenticacao obrigatoria antes do detalhe

## Historia

Como dono do produto, quero que o usuario possa continuar sem login para navegar e pesquisar profissionais, mas que seja
obrigado a criar conta ou entrar ao tentar abrir os detalhes de um profissional, para equilibrar baixa friccao na
descoberta com rastreabilidade antes de uma interacao mais profunda.

## Objetivo

Replanejar a jornada inicial do cliente para manter descoberta publica com opcao clara de criar conta agora, exigindo
autenticacao a partir do momento em que o usuario tenta ver o detalhe completo de um profissional.

## Valor entregue

- preserva descoberta e busca com baixa friccao;
- aumenta rastreabilidade antes do usuario aprofundar a jornada em um profissional;
- cria uma fronteira mais clara entre exploracao anonima e uso identificado;
- prepara melhor a publicacao em loja para uma experiencia controlada;
- preserva a autenticacao propria de baixo custo entregue pela `WL-025`.

## Personas

- Usuario cliente.
- Dono do produto.
- Time de operacao e suporte.

## Decisao de produto

- O app continua permitindo selecao de cidades, descoberta e listagem sem login.
- A interface deve oferecer opcao clara de `continuar sem login` e tambem de `criar conta agora` ou `entrar`.
- O usuario anonimo nao pode abrir o detalhe completo do profissional.
- Ao tentar ver detalhes do profissional, o usuario deve ser redirecionado para login/cadastro.
- A `WL-025` continua sendo o mecanismo principal de autenticacao.
- Esta historia substitui a decisao anterior de autenticar apenas antes do contato, elevando o gate para o detalhe do
  profissional, mas preservando navegacao publica.

## Requisitos relacionados

- RF14 e RF15 — reinterpretados por decisao de produto nesta historia.
- RF16 — login principal por email e senha.
- RF17 — criacao de conta com nome completo, celular, email e senha.
- RN01 e RN02 — reinterpretados por decisao de produto nesta historia.
- RNF03 — seguranca.
- RNF04 — privacidade e LGPD.
- RNF16 — autenticacao segura.
- RNF17 — autorizacao por perfil.
- RNF18 — autenticidade e rastreabilidade.

## Escopo incluido

### Jornada e navegacao

- Permitir acesso anonimo a selecao de cidades, descoberta e listagem.
- Oferecer CTA visivel para `continuar sem login`, `criar conta agora` e `entrar`.
- Bloquear acesso anonimo ao detalhe do profissional, contato, salvos e perfil do cliente.
- Redirecionar usuario autenticado para o detalhe do profissional solicitado apos login/cadastro bem-sucedido.
- Preservar logout e retorno controlado para uma jornada anonima ou autenticada conforme o contexto.

### UX e UI

- Reutilizar `docs/prototipos-de-tela/tela-login-autenticacao.png` como contrato visual do gate de autenticacao.
- Manter identidade visual, microcopy, espacamentos, icones e hierarquia ja aprovados na `WL-025`.
- Ajustar copy para deixar claro que a conta e opcional para explorar, mas obrigatoria para ver detalhes do profissional.
- Prever estados de carregamento, erro, sessao expirada, retorno apos login e tentativa bloqueada no detalhe.

### Backend e sessao

- Validar bootstrap de sessao ao abrir o app.
- Garantir que os dados usados em descoberta/listagem possam continuar publicos se essa for a decisao tecnica adotada.
- Garantir que detalhe do profissional, contato e recursos autenticados nao vazem dados protegidos para sessao ausente ou
  invalida.
- Preservar renovacao e revogacao de sessao existentes.

### Observabilidade e suporte

- Registrar evento de bloqueio/redirect de usuario nao autenticado ao tentar ver detalhe do profissional.
- Tornar claro no suporte e nas mensagens de erro quando o problema for sessao ausente, expirada ou invalida.

## Fora do escopo

- Login social ativo.
- MFA/2FA.
- Biometria.
- Mudanca do mecanismo principal de autenticacao da `WL-025`.
- Bloqueio da descoberta publica.
- Revisao completa da tese de negocio da V1 alem do novo gate no detalhe.

## Tarefas

### Produto e requisitos

- [x] Revisar a jornada oficial do cliente para refletir navegacao anonima com gate no detalhe do profissional.
- [x] Revisar impacto em `RF14`, `RF15`, `RN01` e `RN02`, registrando a nova interpretacao da decisao anterior.
- [x] Revisar `MAPA-PROTOTIPOS-TELAS.md`, historias relacionadas e documentacao operacional afetada.
- [x] Validar com Product Manager, QA e especialista mobile que o gate no detalhe do profissional equilibra descoberta e
  rastreabilidade.

### Mobile

- [x] Ajustar bootstrap do app para suportar jornada anonima inicial e autenticada sem regressao.
- [x] Criar guardas de navegacao para impedir acesso anonimo ao detalhe do profissional e demais telas protegidas.
- [x] Redirecionar usuario autenticado para o detalhe originalmente solicitado apos login/cadastro.
- [x] Ajustar logout, sessao expirada e deep links internos para nao furarem a regra do gate no detalhe.
- [x] Atualizar preview web, fixtures, goldens e evidencias visuais.

### Backend e seguranca

- [x] Confirmar que as rotas e contratos usados pelo mobile respeitam acesso anonimo em descoberta/listagem e sessao
  obrigatoria no detalhe.
- [x] Revisar erros e respostas para sessao ausente/expirada sem vazar dados sensiveis.
- [x] Garantir que nenhuma massa de preview/backdoor permita acesso visual indevido sem conta fora do contexto de teste.

### Testes e qualidade

- [x] Cobrir bootstrap sem sessao, com sessao valida e com sessao expirada em testes unitarios.
- [x] Cobrir guardas de navegacao e redirecionamentos no clique do detalhe em testes de widget/tela.
- [x] Cobrir login, cadastro, logout e retorno para o detalhe solicitado em testes de integracao mobile.
- [x] Cobrir em testes funcionais/E2E que usuario anonimo acessa descoberta/listagem, mas nao acessa detalhe nem contato.
- [x] Cobrir em testes funcionais/E2E que usuario autenticado acessa descoberta, detalhe, perfil e contato conforme as regras.
- [x] Manter ou elevar a cobertura unitaria dentro do gate oficial do projeto.

## Criterios de aceite

- Ao abrir o app sem sessao valida, o usuario pode navegar anonimamente pela descoberta e listagem.
- A interface oferece `continuar sem login`, `criar conta agora` e `entrar` de forma clara.
- Usuario anonimo nao consegue abrir o detalhe completo do profissional, iniciar contato, acessar salvos ou perfil do cliente.
- Ao tocar em um profissional na listagem, usuario anonimo e redirecionado para login/cadastro.
- Usuario autenticado consegue concluir login/cadastro e seguir para o detalhe originalmente solicitado.
- Usuario com sessao valida nao precisa autenticar novamente ao reabrir o app.
- Usuario com sessao expirada e redirecionado para autenticacao ao tentar abrir detalhe ou recurso protegido.
- Logout remove acesso imediato as telas protegidas e retorna o usuario para uma jornada anonima controlada.
- Copy e identidade visual do gate de autenticacao permanecem aderentes ao prototipo oficial.
- Preview web e build mobile exibem descoberta/listagem anonimas, mas bloqueiam detalhe para usuario sem conta autenticada.
- Testes unitarios cobrem bootstrap de sessao, estados do controller e guardas de navegacao.
- Testes mobile cobrem CTA de continuar sem login, redirecionamento no detalhe, sessao expirada e logout.
- Testes funcionais/E2E comprovam liberacao da descoberta anonima e bloqueio do detalhe para usuario nao autenticado.
- Cobertura unitaria e testes aplicaveis passam nos gates oficiais do projeto.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-login-autenticacao.png`

### Requisitos nao funcionais por tela

- a jornada anonima inicial deve ser resiliente a sessao ausente, invalida ou expirada;
- mensagens de erro nao devem expor existencia de contas ou detalhes sensiveis;
- guardas de navegacao nao devem permitir bypass por rota interna, refresh ou bootstrap incompleto no detalhe do profissional;
- testes mobile e funcionais devem comprovar a regra de autenticacao obrigatoria no detalhe de ponta a ponta;
- a cobertura unitaria da entrega deve permanecer alta e dentro do gate oficial do projeto.

## Dependencias

- WL-025 — autenticacao propria por email e senha.
- WLT-009 — autenticacao segura, sessoes e tokens.
- WLT-010 — autorizacao por perfil e ownership.
- WLT-011 — auditoria de acoes sensiveis.
- WLT-012 — LGPD e minimizacao.
- WLT-013 — criptografia e protecao de dados.
- WLT-019 — specs funcionais E2E reais.

## Historias impactadas

- WL-009 — continua desatualizada como jornada oficial, porque ainda empurra o gate apenas para o contato.
- WL-025 — continua valida no mecanismo de login, mas com jornada de entrada revisada.
- WL-003 e WL-004 — permanecem anonimas.
- WL-005 — passa a exigir autenticacao antes de abrir o detalhe completo do profissional.
- WL-015 e WL-020 — permanecem autenticadas.
- WLT-042 e etapas de loja devem esperar esta decisao ser refletida no produto antes da subida final.

## Entrega versionavel

- Tipo sugerido: `MINOR`.
- Motivo: altera uma decisao central de produto da V1 sobre o ponto exato em que a autenticacao passa a ser obrigatoria.
