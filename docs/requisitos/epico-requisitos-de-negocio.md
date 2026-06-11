# Épico — WorkLink V1

## Nome do épico
WorkLink V1 — Descoberta local, confiança, disponibilidade e responsividade de profissionais

## Objetivo do épico

Construir a primeira versão funcional do WorkLink, permitindo que usuários encontrem profissionais autônomos locais com maior confiança, visualizem sinais de disponibilidade e responsividade, entrem em contato via WhatsApp e registrem feedback pós-contato para alimentar a reputação da plataforma.

A V1 deve evitar que o WorkLink seja apenas uma lista de contatos. O objetivo é criar uma base funcional para transformar o boca a boca local em reputação organizada, mensurável e evolutiva.

## Visão da V1

O WorkLink deve ser uma plataforma regional que ajuda pessoas a encontrar profissionais próximos, confiáveis, disponíveis e com maior chance real de atendimento.

## Problema que a V1 resolve

Hoje muitas pessoas dependem de indicação informal para encontrar profissionais locais. Esse processo é lento, inseguro, desorganizado e nem sempre garante que o profissional indicado esteja disponível ou responda ao contato.

A V1 do WorkLink deve reduzir essa dor permitindo que o usuário encontre profissionais por categoria e região, visualize sinais mínimos de confiança, disponibilidade e atividade, entre em contato de forma simples e contribua com feedback após o contato.

## Tese central do produto

O WorkLink não deve competir apenas como um catálogo de profissionais.

O diferencial da plataforma deve ser:

**ajudar o usuário a encontrar profissionais locais com chance real de resposta e atendimento.**

## Público-alvo da V1

### Usuário cliente
- famílias
- pessoas sem rede forte de contatos
- pessoas que precisam contratar serviços manuais
- moradores de cidades pequenas, médias ou próximas a regiões metropolitanas

### Profissional
- autônomos
- prestadores de serviços manuais
- profissionais com familiaridade mínima com WhatsApp e aplicativos
- profissionais que desejam mais visibilidade local

## Região inicial da V1

A V1 será inicialmente pensada para Charqueadas e região próxima, podendo incluir:

- Charqueadas
- São Jerônimo
- Triunfo
- Arroio dos Ratos
- Eldorado do Sul
- General Câmara
- Butiá
- demais cidades próximas definidas para o lançamento inicial

---

# Escopo funcional da V1

A V1 deverá contemplar os seguintes blocos funcionais:

1. Descoberta de profissionais locais
2. Busca por categoria e cidade
3. Seleção de uma ou mais cidades
4. Uso opcional da localização atual
5. Listagem de profissionais
6. Perfil detalhado do profissional
7. Cadastro e autenticação simplificada do usuário cliente
8. Cadastro progressivo do profissional
9. Contato via WhatsApp
10. Registro de intenção de contato
11. Pós-contato estruturado
12. Avaliação do profissional
13. Avaliação anônima
14. Denúncia de profissional
15. Badges de confiança
16. Badges de disponibilidade
17. Sinais de responsividade
18. Perfil do usuário
19. Estado sem profissionais encontrados
20. Confirmação pós-avaliação
21. Base funcional para ranking futuro
22. Administração mínima da plataforma

---

# Princípios funcionais da V1

## 1. O app não pode ser apenas uma lista de contatos

A V1 deve exibir profissionais, mas também deve coletar e apresentar sinais que ajudem o usuário a entender:

- se o profissional é confiável
- se está disponível
- se costuma responder
- se o perfil está completo
- se existem avaliações
- se há chance real de atendimento

## 2. A confiança deve ser progressiva

O profissional poderá iniciar com um perfil simples, mas deverá ganhar mais destaque conforme completa informações e demonstra comportamento confiável.

## 3. A disponibilidade deve ser explícita

O profissional deverá informar se está aceitando novos clientes, disponível hoje, disponível na semana, atendendo emergências ou temporariamente indisponível.

## 4. A responsividade deve ser medida

A plataforma deverá coletar dados após o contato para identificar se o profissional respondeu, se demorou, se o serviço foi realizado e se o usuário ficou satisfeito.

## 5. A avaliação pode ser anônima publicamente

O usuário poderá avaliar de forma anônima para o público, especialmente considerando o contexto de cidades pequenas. Porém, a plataforma deverá manter rastreabilidade interna da avaliação.

## 6. O WorkLink deve facilitar descoberta e contato, mas não garantir a execução do serviço

A V1 não deverá assumir responsabilidade direta pela execução do serviço, pagamento, garantia ou contrato entre as partes.

---

# Fluxos principais da V1

## Fluxo 1 — Descobrir profissional

1. Usuário acessa o app
2. Visualiza a home
3. Escolhe uma categoria
4. Usa localização atual ou seleciona uma ou mais cidades
5. Visualiza profissionais disponíveis
6. Aplica filtros se necessário
7. Acessa o perfil do profissional
8. Decide entrar em contato

## Fluxo 2 — Autenticação do cliente

1. Usuário pode navegar sem login
2. Ao tentar entrar em contato com um profissional, o sistema solicita autenticação
3. Usuário existente informa email e senha
4. Usuário novo informa nome completo, celular, email e senha
5. Sistema autentica a conta existente ou cria a nova conta
6. Número de celular permanece não verificado até existir confirmação real
7. Google, Facebook, SMS, WhatsApp Business e OTP por email permanecem desativados por padrão para ativação futura

## Fluxo 3 — Cadastro progressivo do profissional

1. Profissional inicia cadastro com informações mínimas
2. Profissional informa nome, WhatsApp, cidade e categoria
3. Profissional pode completar o perfil com foto, descrição, CPF/CNPJ, links, cidades atendidas, portfólio e disponibilidade
4. Quanto mais completo o perfil, maior o nível de confiança exibido
5. Perfis completos e ativos podem ganhar mais destaque

## Fluxo 4 — Contato com profissional

1. Usuário acessa perfil do profissional
2. Clica em chamar no WhatsApp
3. Sistema registra intenção de contato
4. Usuário é redirecionado para o WhatsApp
5. O app informa que o contato ocorrerá diretamente entre usuário e profissional

## Fluxo 5 — Pós-contato estruturado

1. Após determinado período, o app solicita feedback do contato
2. Usuário informa se conseguiu falar com o profissional
3. Usuário informa se o profissional respondeu rápido, demorou ou não respondeu
4. Usuário informa se o serviço foi realizado
5. Caso o serviço tenha sido realizado, o usuário pode avaliar o profissional
6. Usuário pode deixar comentário opcional
7. Usuário pode publicar avaliação de forma anônima
8. Sistema registra dados para reputação e ranking futuro

## Fluxo 6 — Denúncia de profissional

1. Usuário acessa opção de denúncia
2. Seleciona motivo
3. Descreve o ocorrido
4. Opcionalmente adiciona evidências
5. Envia denúncia
6. Sistema registra a denúncia para análise
7. Em casos graves, o app orienta o usuário a procurar autoridades competentes

---

# Telas previstas na V1

## 1. Home

A home deve permitir que o usuário entenda rapidamente o propósito do app.

Deve exibir:

- localização atual ou cidade selecionada
- campo de busca
- categorias principais
- profissionais em destaque
- sinais visuais de confiança
- sinais visuais de disponibilidade
- acesso ao perfil do usuário

## 2. Listagem de profissionais

A listagem deve exibir profissionais conforme categoria e cidade selecionada.

Cada card deve conter:

- foto
- nome
- categoria
- cidade
- nota média, quando houver
- quantidade de avaliações, quando houver
- badge de perfil verificado ou completo
- badge de disponibilidade
- sinal de atividade recente, quando disponível
- botão ou ação para abrir perfil

## 3. Perfil do profissional

O perfil do profissional é uma das telas mais importantes do app.

Deve exibir:

- foto
- nome
- categoria
- cidade base
- cidades atendidas
- descrição
- serviços prestados
- portfólio ou fotos de trabalhos
- links úteis
- WhatsApp
- status de disponibilidade
- badges de confiança
- avaliações
- comentários
- opção de denunciar
- botão principal de contato

## 4. Cadastro/acesso do cliente

Deve permitir:

- entrada por email e senha;
- criação de conta com nome completo, celular, email e senha;
- recuperação de senha;
- login simplificado;
- autenticação apenas quando necessária para contato;
- canais externos ocultos enquanto estiverem desativados.

## 5. Verificação por código — canal futuro

Deve permitir:

- digitar código recebido
- reenviar código
- alterar telefone informado
- concluir autenticação

Esta tela permanece como referência para verificação futura e não deve ser o caminho principal enquanto SMS, WhatsApp
Business e OTP estiverem desativados.

## 6. Cadastro do profissional

Deve ser simples e progressivo.

### Campos mínimos
- nome
- WhatsApp
- cidade
- categoria principal
- descrição curta

### Campos para perfil completo
- foto
- CPF ou CNPJ
- cidades atendidas
- links úteis
- portfólio
- serviços prestados
- disponibilidade
- atendimento emergencial

## 7. Tela de contato via WhatsApp

Deve informar:

- que o usuário será redirecionado ao WhatsApp
- que o contato será direto com o profissional
- que o app poderá solicitar feedback posteriormente
- que o WorkLink facilita o contato, mas não garante a execução do serviço

## 8. Avaliação pós-contato

Deve permitir:

- informar se conseguiu falar com o profissional
- informar se o profissional respondeu
- informar se o serviço foi realizado
- atribuir nota
- escrever comentário opcional
- marcar avaliação como anônima

## 9. Sucesso pós-avaliação

Deve confirmar:

- avaliação enviada
- contribuição para a comunidade
- anonimato, se ativado
- possibilidade de voltar à home ou continuar buscando

## 10. Perfil do usuário

Deve exibir:

- nome
- telefone
- cidade principal
- cidades selecionadas
- profissionais salvos
- avaliações enviadas
- preferências
- privacidade
- sair da conta

## 11. Seleção de cidade/cidades

Deve permitir:

- usar localização atual como padrão
- buscar cidade manualmente
- selecionar uma ou mais cidades
- exibir cidades próximas quando a localização atual estiver ativa
- limpar seleção
- aplicar filtros

## 12. Denúncia de profissional

Deve permitir denunciar:

- golpe ou fraude
- assédio
- ameaça
- comportamento inadequado
- perfil falso
- serviço não realizado após combinado
- cobrança suspeita
- outro motivo

A tela deve permitir:

- escolher motivo
- detalhar ocorrido
- anexar evidência opcional
- enviar denúncia
- orientar sobre autoridades em casos graves

## 13. Nenhum profissional encontrado

Deve exibir mensagem amigável quando não houver resultado.

Deve sugerir:

- ampliar para cidades próximas
- alterar filtros
- buscar outra categoria
- limpar critérios de busca

---

# Requisitos funcionais da V1

## Descoberta e busca

### RF01
O sistema deve permitir que o usuário visualize profissionais por categoria.

### RF02
O sistema deve permitir busca por palavra-chave.

### RF03
O sistema deve permitir busca por cidade.

### RF04
O sistema deve permitir que o usuário selecione uma ou mais cidades para buscar profissionais.

### RF05
O sistema deve permitir uso da localização atual como base de busca.

### RF06
O sistema deve sugerir cidades próximas quando a localização atual estiver ativa.

### RF07
O sistema deve permitir limpar filtros de busca.

### RF08
O sistema deve exibir uma tela de nenhum resultado quando não houver profissionais compatíveis.

---

## Listagem e perfil profissional

### RF09
O sistema deve exibir uma listagem de profissionais compatíveis com os critérios de busca.

### RF10
O sistema deve exibir cards de profissionais com informações resumidas.

### RF11
O sistema deve permitir abrir o perfil detalhado do profissional.

### RF12
O sistema deve exibir no perfil do profissional suas informações principais, serviços, cidades atendidas, links, avaliações e disponibilidade.

### RF13
O sistema deve permitir que o profissional adicione portfólio ou fotos de trabalhos realizados.

---

## Cadastro e autenticação do cliente

### RF14
O sistema deve permitir navegação sem autenticação inicial.

### RF15
O sistema deve exigir autenticação somente quando o usuário tentar entrar em contato com um profissional ou realizar ações sensíveis.

### RF16
O sistema deve autenticar o usuário inicialmente por email e senha, mantendo verificacao por codigo como canal futuro
configuravel e desativado por padrao.

### RF17
O sistema deve permitir criar conta com nome completo, numero de celular, email e senha, sem apresentar o celular como
verificado antes de uma confirmacao real.

---

## Cadastro progressivo do profissional

### RF18
O sistema deve permitir o cadastro de profissionais.

### RF19
O sistema deve permitir cadastro mínimo do profissional com nome, WhatsApp, cidade, categoria e descrição curta.

### RF20
O sistema deve permitir que o profissional complete seu perfil com foto, CPF/CNPJ, cidades atendidas, links úteis, portfólio, serviços prestados e disponibilidade.

### RF21
O sistema deve indicar visualmente o nível de completude do perfil profissional.

### RF22
O sistema deve permitir que o profissional edite suas informações posteriormente.

---

## Confiança progressiva

### RF23
O sistema deve exibir badge de perfil básico, completo ou verificado conforme dados informados.

### RF24
O sistema deve exibir telefone verificado quando o número do profissional for validado.

### RF25
O sistema deve exibir documento informado quando o profissional cadastrar CPF ou CNPJ.

### RF26
O sistema deve exibir perfil completo quando critérios mínimos adicionais forem atendidos.

---

## Disponibilidade

### RF27
O sistema deve permitir que o profissional informe seu status de disponibilidade.

### RF28
O sistema deve permitir status como:
- disponível hoje
- disponível esta semana
- aceitando novos clientes
- atendimento emergencial
- indisponível temporariamente

### RF29
O sistema deve exibir badges de disponibilidade na listagem e no perfil.

### RF30
O sistema deve reduzir destaque de profissionais marcados como indisponíveis.

---

## Contato via WhatsApp

### RF31
O sistema deve permitir contato direto com o profissional via WhatsApp.

### RF32
O sistema deve registrar a intenção de contato quando o usuário clicar para chamar o profissional.

### RF33
O sistema deve informar que o contato e a negociação ocorrerão fora do app.

### RF34
O sistema deve informar que o WorkLink facilita a descoberta e o contato, mas não garante a execução do serviço.

---

## Pós-contato estruturado

### RF35
O sistema deve solicitar feedback ao usuário após contato iniciado.

### RF36
O sistema deve permitir que o usuário informe se conseguiu falar com o profissional.

### RF37
O sistema deve permitir que o usuário informe se o profissional respondeu rápido, demorou ou não respondeu.

### RF38
O sistema deve permitir que o usuário informe se o serviço foi realizado.

### RF39
O sistema deve armazenar respostas de pós-contato para compor indicadores futuros de responsividade.

---

## Avaliações

### RF40
O sistema deve permitir avaliação do profissional após o usuário informar que o serviço foi realizado.

### RF41
O sistema deve permitir nota em estrelas.

### RF42
O sistema deve permitir comentário opcional.

### RF43
O sistema deve permitir avaliação anônima publicamente.

### RF44
O sistema deve manter rastreabilidade interna da avaliação, mesmo quando publicada anonimamente.

### RF45
O sistema deve exibir avaliações e comentários no perfil do profissional.

### RF46
O sistema deve permitir que o profissional solicite análise de uma avaliação considerada indevida.

---

## Denúncias

### RF47
O sistema deve permitir denúncia de profissional.

### RF48
O sistema deve permitir selecionar motivo da denúncia.

### RF49
O sistema deve permitir descrição detalhada da denúncia.

### RF50
O sistema deve permitir anexar evidência opcional.

### RF51
O sistema deve registrar denúncias para análise posterior.

### RF52
O sistema deve orientar o usuário a procurar autoridades competentes em casos de crime, assédio, ameaça, violência ou situações graves.

---

## Perfil do usuário

### RF53
O sistema deve permitir que o usuário visualize seu perfil.

### RF54
O sistema deve permitir que o usuário visualize suas cidades selecionadas.

### RF55
O sistema deve permitir que o usuário visualize profissionais salvos.

### RF56
O sistema deve permitir que o usuário visualize avaliações enviadas.

### RF57
O sistema deve permitir que o usuário gerencie preferências básicas de conta.

---

## Base para ranking futuro

### RF58
O sistema deve registrar sinais de atividade do profissional.

### RF59
O sistema deve registrar sinais de responsividade com base no pós-contato.

### RF60
O sistema deve registrar sinais de disponibilidade.

### RF61
O sistema deve preparar dados para ranking futuro considerando avaliação, disponibilidade, perfil completo, responsividade e atividade recente.

---

## Administração mínima

### RF62
O sistema deve permitir que administradores visualizem profissionais cadastrados.

### RF63
O sistema deve permitir que administradores bloqueiem ou desbloqueiem profissionais.

### RF64
O sistema deve permitir que administradores visualizem denúncias recebidas.

### RF65
O sistema deve permitir que administradores revisem avaliações denunciadas ou contestadas.

### RF66
O sistema deve permitir que administradores gerenciem categorias de serviço.

### RF67
O sistema deve permitir que administradores acompanhem métricas básicas de uso.

---

# Regras de negócio da V1

## RN01
Usuários podem navegar e buscar profissionais sem login.

## RN02
Usuários precisam autenticar conta antes de iniciar contato com profissional.

## RN03
Contato principal da V1 será realizado via WhatsApp.

## RN04
O WorkLink não intermediará pagamento na V1.

## RN05
O WorkLink não garantirá a execução do serviço na V1.

## RN06
O profissional é responsável por manter sua disponibilidade atualizada.

## RN07
Profissionais disponíveis e ativos podem ganhar mais destaque.

## RN08
Profissionais indisponíveis ou inativos podem perder destaque.

## RN09
Avaliações públicas podem ser anônimas.

## RN10
A plataforma deve manter registro interno do autor da avaliação, mesmo quando ela for anônima publicamente.

## RN11
Avaliações só devem ser permitidas após contato registrado e confirmação de serviço realizado.

## RN12
Comentários em avaliações serão opcionais.

## RN13
Denúncias graves devem receber tratamento prioritário.

## RN14
O usuário deve ser orientado a procurar autoridades competentes em casos envolvendo crime, assédio, ameaça ou violência.

## RN15
Perfis com mais informações verificáveis devem transmitir maior nível de confiança.

## RN16
Perfil completo não significa garantia de qualidade, apenas maior completude de informações.

## RN17
A posição futura dos profissionais na busca deverá considerar mais do que nota média.

## RN18
Sinais de responsividade devem ser usados para melhorar a relevância futura dos profissionais.

## RN19
O profissional poderá contestar avaliações consideradas indevidas.

## RN20
A plataforma poderá ocultar ou revisar avaliações suspeitas, ofensivas ou abusivas.

---

# Níveis de confiança do profissional

## Perfil básico
Profissional com dados mínimos preenchidos.

Critérios:
- nome
- WhatsApp
- cidade
- categoria
- descrição curta

## Perfil completo
Profissional com informações adicionais preenchidas.

Critérios possíveis:
- foto
- descrição detalhada
- cidades atendidas
- links úteis
- serviços prestados
- disponibilidade informada

## Perfil verificado
Profissional com dados de confiança informados ou validados.

Critérios possíveis:
- telefone verificado
- CPF/CNPJ informado
- aceite dos termos
- perfil completo

## Perfil destaque
Profissional com bons sinais de reputação e atividade.

Critérios possíveis:
- boas avaliações
- resposta positiva no pós-contato
- disponibilidade atualizada
- atividade recente
- baixo índice de denúncias

---

# Sinais de disponibilidade

A V1 deverá permitir exibir sinais como:

- disponível hoje
- disponível esta semana
- aceitando novos clientes
- atendimento emergencial
- indisponível temporariamente

---

# Sinais de responsividade

A V1 deverá começar a coletar sinais como:

- usuário conseguiu falar com o profissional
- profissional respondeu rápido
- profissional demorou para responder
- profissional não respondeu
- serviço foi realizado
- usuário avaliou positivamente após serviço realizado

---

# Métricas funcionais da V1

## Métricas de descoberta
- quantidade de buscas realizadas
- categorias mais buscadas
- cidades mais buscadas
- buscas sem resultado

## Métricas de contato
- cliques em WhatsApp
- contatos iniciados por profissional
- contatos iniciados por categoria
- contatos iniciados por cidade

## Métricas de responsividade
- percentual de contatos respondidos
- percentual de profissionais que não responderam
- percentual de serviços realizados
- percentual de usuários que responderam pós-contato

## Métricas de reputação
- quantidade de avaliações
- média de avaliações
- quantidade de avaliações anônimas
- denúncias recebidas
- avaliações contestadas

## Métricas de profissional
- profissionais cadastrados
- profissionais ativos
- profissionais com perfil completo
- profissionais disponíveis
- profissionais indisponíveis
- profissionais com contato recebido

---

# Critérios de sucesso da V1

A V1 será considerada bem-sucedida se:

- usuários conseguirem encontrar profissionais locais com facilidade
- profissionais conseguirem criar perfis simples
- usuários iniciarem contatos pelo WhatsApp
- o pós-contato gerar dados úteis
- houver avaliações reais
- houver sinais de disponibilidade
- usuários perceberem mais valor do que no boca a boca informal
- profissionais perceberem aumento de visibilidade
- o app demonstrar potencial para replicação em outras regiões

---

# Fora do escopo da V1

A V1 não contempla:

- pagamento dentro do app
- garantia do serviço
- contrato formal entre usuário e profissional
- chat interno completo
- agenda avançada
- cálculo de preço
- orçamento automático
- ranking algorítmico sofisticado
- inteligência artificial para recomendação
- mediação completa de conflito
- seguro de serviço
- verificação documental avançada
- expansão nacional imediata
- operação manual complexa

---

# Resumo executivo

A V1 do WorkLink deve validar se existe demanda regional para uma plataforma que organiza o boca a boca local, permitindo que pessoas encontrem profissionais próximos, confiáveis, disponíveis e responsivos.

O principal diferencial da V1 não é apenas listar profissionais, mas começar a medir a chance real de atendimento por meio de disponibilidade, atividade e feedback pós-contato.

A plataforma deve nascer simples, mas com fundação evolutiva para ranking, reputação, moderação, expansão regional e futura monetização.
