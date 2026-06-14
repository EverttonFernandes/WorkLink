# Matriz de aderencia UX/UI — WL-025

Contrato visual principal:
`docs/prototipos-de-tela/tela-login-autenticacao.png`.

O prototipo `tela-verificao-usuario-cliente-profissional.png` permanece como referencia historica do fluxo OTP e nao
autoriza exibir verificacao por codigo ou escolha de perfil no fluxo local padrao.

| Estado | Elementos obrigatorios | Elementos proibidos | Evidencia esperada |
| --- | --- | --- | --- |
| Entrar | marca Profissional Perto, alternancia Entrar/Criar conta, email, senha, visibilidade, CTA verde, recuperar senha, bloco de seguranca | telefone como credencial, OTP, Google, Apple, Facebook, SMS ou WhatsApp | widget test e golden |
| Criar conta | nome completo, celular, email, senha, confirmacao, aceite legal, CTA verde, celular nao verificado | badge de telefone verificado, canal social ou mensageria | widget test e golden |
| Recuperar acesso | voltar, email, CTA de envio, resposta neutra | indicar se o email existe | widget test e golden |
| Redefinir senha | token, nova senha, confirmacao, CTA, sucesso | exibir token recuperado automaticamente em producao | widget test |
| Carregando | CTA bloqueado e indicador sem alterar a hierarquia | duplo envio | widget test |
| Erro | mensagem curta, acessivel e sem detalhes tecnicos | stack trace, enum de backend ou identificacao de conta | widget test |
| Sucesso | retorno para a acao sensivel originalmente solicitada | marcar celular como verificado | widget/app test |

## Regras responsivas

- Todo formulario deve usar rolagem e respeitar teclado/`viewInsets`.
- O cadastro nao pode esconder CTA ou aceite legal em telas pequenas.
- Textos, labels e botoes nao podem extrapolar a largura em Android, iOS ou preview Web.
- O card, espacamentos, tipografia e identidade verde devem seguir o prototipo principal.
- O callback autenticado deve representar a sessao/identidade, nao um telefone supostamente verificado.

## Gates

- Especialista mobile: compara composicao, microcopy, responsividade e ausencia dos canais desativados.
- QA: valida estados e regressao dos fluxos anonimo e autenticado.
- Product Manager: valida que celular continua como dado de contato nao verificado.
- Seguranca: valida mensagens genericas, segredo de senha e ausencia de tokens na interface/logs.
