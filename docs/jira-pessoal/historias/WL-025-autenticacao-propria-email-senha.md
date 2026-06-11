# WL-025 — Autenticacao propria por email e senha

## Historia

Como usuario cliente ou profissional, quero criar uma conta e entrar no Profissional Perto com email e senha, para acessar
os recursos autenticados sem depender inicialmente de Google, Facebook, WhatsApp Business ou SMS pago.

## Objetivo

Substituir o canal pago ou terceirizado como caminho principal de entrada por uma autenticacao propria, previsivel e de
baixo custo, preservando a experiencia visual e a navegacao ja definidas para o aplicativo.

## Valor entregue

- reduz o custo recorrente inicial de autenticacao;
- permite publicar e validar o produto sem depender de login social ou OTP pago;
- mantem nome completo e celular como dados do cadastro;
- preserva os contratos tecnicos para ativar outros canais posteriormente;
- mantem a exigencia de login apenas antes de contato ou acao sensivel.

## Personas

- Usuario cliente.
- Profissional.

## Decisao de produto

- O caminho principal da V1 passa a ser cadastro com nome completo, celular, email e senha.
- O login principal usa email e senha.
- O celular e coletado como dado de perfil e contato, mas nao deve ser apresentado como verificado sem confirmacao real.
- Google, Facebook, WhatsApp Business, SMS e OTP por email ficam em stand by.
- Os canais em stand by devem permanecer desacoplados e protegidos por feature flag, sem serem removidos de forma que
  dificulte uma ativacao futura.
- A navegacao publica continua disponivel sem login.
- Login social nao deve aparecer como ativo enquanto nao houver configuracao, politica de privacidade e custo aprovados.

## Requisitos relacionados

- RF14 — navegacao sem autenticacao inicial.
- RF15 — autenticacao apenas antes de contato ou acao sensivel.
- RF16 e RF17 — replanejados para o canal futuro de verificacao; nao sao removidos.
- RN01 — busca e navegacao sem login.
- RN02 — autenticacao antes de iniciar contato.
- RNF03 — seguranca.
- RNF04 — privacidade e LGPD.
- RNF05 — criptografia.
- RNF16 — autenticacao segura.
- RNF17 — autorizacao por perfil.
- RNF18 — autenticidade e rastreabilidade.

## Escopo incluido

### Cadastro

- Informar nome completo.
- Informar numero de celular.
- Informar email.
- Criar e confirmar senha.
- Aceitar termos de uso e politica de privacidade.
- Impedir duplicidade de email sem expor existencia da conta em respostas inseguras.
- Criar conta com celular inicialmente nao verificado.

### Login

- Entrar com email e senha.
- Manter sessao usando os contratos seguros de access token e refresh token existentes.
- Permitir sair da conta e revogar a sessao.
- Exibir mensagens genericas para credenciais invalidas.
- Bloquear abuso por tentativas repetidas.

### Recuperacao de acesso

- Disponibilizar fluxo "Esqueci minha senha".
- Gerar token de recuperacao curto, de uso unico e armazenado de forma segura.
- Permitir configurar o envio transacional por email sem acoplar o dominio a um provedor.
- Nao expor se determinado email possui conta.
- Revogar sessoes anteriores depois da alteracao de senha quando aplicavel.

### Canais futuros em stand by

- Manter Google, Facebook, WhatsApp Business, SMS e OTP desativados por padrao.
- Controlar cada canal por configuracao/feature flag.
- Nao exibir botoes de canal indisponivel na interface de producao.
- Preservar portas/adapters necessarios para evolucao posterior sem obrigar SDKs sociais nesta entrega.

## UX e UI obrigatorias

- Usar `docs/prototipos-de-tela/tela-login-autenticacao.png` como contrato visual principal.
- Preservar identidade verde, tipografia, espacamentos, hierarquia, cards, botoes, icones e navegacao existentes.
- Preservar o fluxo que abre autenticacao somente ao tentar contato ou acao sensivel.
- Adaptar apenas campos, labels e microcopy necessarios para email e senha.
- Oferecer alternancia clara entre `Entrar` e `Criar conta` sem criar uma experiencia visual paralela.
- Prever estados de carregamento, erro, senha visivel/oculta, recuperacao e sucesso.
- Manter responsividade Android/iOS e preview Web.
- Atualizar goldens e evidencias visuais sem aceitar regressao nao aprovada pelo especialista mobile e pelo QA.

## Requisitos de seguranca

- Senha nunca deve ser armazenada ou registrada em texto puro.
- Usar algoritmo de hash de senha adequado e configuravel, preferencialmente Argon2id ou bcrypt.
- Aplicar politica minima de 12 caracteres e permitir senhas longas e gerenciadores de senha.
- Aplicar rate limit por conta, IP e dispositivo quando tecnicamente possivel.
- Proteger contra brute force, credential stuffing e enumeracao de usuarios.
- Tokens de recuperacao devem expirar, ser de uso unico e permanecer protegidos em persistencia.
- Access token e refresh token nao devem aparecer em logs.
- Dados pessoais devem seguir minimizacao, finalidade e regras LGPD existentes.
- Acoes sensiveis devem continuar sujeitas a autorizacao e ownership.
- MFA nao faz parte desta entrega, mas a arquitetura nao deve impedir sua adicao futura.

## Tarefas

### Produto e UX

- [ ] Revisar a jornada atual de telefone/OTP e mapear os pontos substituidos.
- [ ] Definir microcopy de login, cadastro, erros e recuperacao.
- [ ] Produzir matriz de aderencia ao prototipo oficial.
- [ ] Validar telas e estados com Product Manager, especialista mobile e QA.

### Backend

- [ ] Modelar credencial local vinculada a identidade do usuario.
- [ ] Implementar cadastro com email normalizado, senha protegida, nome completo e celular.
- [ ] Implementar login por email e senha.
- [ ] Implementar limite de tentativas e respostas resistentes a enumeracao.
- [ ] Implementar recuperacao e redefinicao segura de senha.
- [ ] Integrar emissao, rotacao e revogacao de tokens existentes.
- [ ] Registrar eventos de auditoria sem dados sensiveis.
- [ ] Criar migrations e garantir compatibilidade com contas existentes.

### Mobile

- [ ] Adaptar controller/state da autenticacao para entrar, cadastrar e recuperar senha.
- [ ] Adaptar a tela existente sem alterar a identidade visual homologada.
- [ ] Implementar campos acessiveis, validacao local e alternancia de visibilidade da senha.
- [ ] Ocultar canais futuros desativados.
- [ ] Manter navegacao anonima e redirecionamento apos autenticacao.
- [ ] Atualizar preview, fixtures e goldens oficiais.

### Configuracao e operacao

- [ ] Criar feature flags independentes para login local e canais futuros.
- [ ] Garantir que producao inicie com login local habilitado e canais pagos desabilitados.
- [ ] Documentar secrets e parametros sem versionar valores reais.
- [ ] Documentar recuperacao operacional e revogacao de sessoes.

### Testes e gates

- [ ] Cobrir cadastro, login, logout, recuperacao e revogacao com testes unitarios.
- [ ] Cobrir email duplicado, senha invalida, tentativas excessivas e token expirado.
- [ ] Cobrir fluxo mobile com widget tests e testes de integracao.
- [ ] Cobrir navegacao sem login e bloqueio de contato sem autenticacao.
- [ ] Executar testes funcionais ponta a ponta.
- [ ] Executar gates de QA, seguranca, privacidade, SRE, arquitetura e Final Reviewer.

## Criterios de aceite

- Usuario consegue navegar e buscar profissionais sem login.
- Ao iniciar contato ou acao sensivel, usuario nao autenticado e direcionado ao login.
- Usuario novo consegue cadastrar nome completo, celular, email e senha.
- Usuario existente consegue entrar com email e senha validos.
- Email e armazenado normalizado e nao pode identificar duas contas ativas.
- Celular sem verificacao e exibido explicitamente como nao verificado.
- Senha e armazenada somente como hash seguro.
- Credenciais invalidas produzem mensagem generica sem enumerar usuarios.
- Tentativas repetidas sofrem rate limit ou bloqueio temporario auditavel.
- Usuario consegue solicitar e concluir recuperacao de senha com token curto e de uso unico.
- Logout revoga a sessao correspondente.
- Google, Facebook, WhatsApp Business, SMS e OTP permanecem desativados e ocultos por padrao.
- Feature flags permitem futura ativacao dos canais sem alterar o dominio central.
- A tela mantem identidade visual, estrutura e navegacao do prototipo oficial.
- Estados de login, cadastro, recuperacao, carregamento, erro e sucesso possuem testes de tela.
- Testes backend, mobile, integracao e funcionais aplicaveis passam.
- Cobertura unitaria permanece dentro do gate oficial do projeto.
- Logs, erros e eventos nao expõem senha, token, telefone completo ou dados pessoais desnecessarios.

## Fora do escopo

- Login ativo por Google.
- Login ativo por Facebook.
- Autenticacao por WhatsApp Business.
- Envio de OTP por SMS, WhatsApp ou email como caminho principal.
- MFA/2FA.
- Biometria.
- Passkeys.
- Verificacao documental/KYC.
- Exclusao definitiva dos contratos de OTP ja existentes.

## Dependencias

- WLT-009 — autenticacao segura, sessoes e tokens.
- WLT-010 — autorizacao por perfil e ownership.
- WLT-011 — auditoria de acoes sensiveis.
- WLT-012 — LGPD e minimizacao.
- WLT-013 — criptografia e protecao de dados.
- WLT-037 — backend cloud minimo para o app das lojas.

## Historias posteriores

- WLT-038 avalia custo, provedor e ativacao futura de Google, Facebook, SMS, WhatsApp Business ou OTP por email.
- WLT-039 usa o login local funcional no teste interno da Google Play.
- WLT-040 valida o mesmo fluxo no TestFlight/iOS.

## Entrega versionavel

- Tipo sugerido: `MINOR`.
- Motivo: altera o canal principal de autenticacao e entrega cadastro/login proprio completo.
