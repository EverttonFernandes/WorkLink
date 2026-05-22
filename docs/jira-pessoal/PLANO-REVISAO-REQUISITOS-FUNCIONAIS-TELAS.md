# Plano De Revisão Dos Requisitos Funcionais Com Tela — WorkLink V1

Este plano define como revisar, em ordem cronológica, todos os requisitos funcionais da V1 que possuem impacto direto em telas mobile, protótipos, fluxos visuais ou homologação manual Android/iOS.

O objetivo é garantir que cada tela seja construída 100% aderente ao requisito funcional, regra de negócio, protótipo oficial, massa de dados de homologação e evidência visual real.

## Fontes obrigatórias

- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md`
- `docs/prototipos-de-tela/`
- `docs/debitos-tecnicos/DEBITOS-HOMOLOGACAO-MOBILE-2026-05-22.md`
- `.agents/skills/skills/ralph-loop/product-manager/SKILL.md`
- `.agents/skills/skills/ralph-loop/mobile-frontend-specialist-agent/SKILL.md`
- `.agents/skills/skills/ralph-loop/qa-agent/SKILL.md`
- `.agents/skills/skills/ralph-loop/final-reviewer-agent/SKILL.md`

## Decisão de governança

Antes de continuar novas etapas de publicação, TestFlight, Play Store, promoção de release ou rollback mobile, o projeto deve revisar e corrigir as telas funcionais já entregues que não representam os requisitos e protótipos oficiais.

CI verde, APK instalável e backend respondendo não bastam. Uma tela só é considerada pronta quando:

- o Product Manager confirmou o RF e a regra de negócio;
- o Mobile Front-end Specialist confirmou aderência visual ao protótipo;
- o QA confirmou teste, evidência visual e ausência de labels técnicas;
- o Final Reviewer confirmou `Product/Prototype Fit = OK`;
- existe screenshot real do APK/emulador para o estado principal da tela;
- a massa de homologação permite simular uso real;
- o APK gerado permite validação manual pelo dono do produto.

## Exit bar do plano

O plano só termina quando todos os itens abaixo estiverem completos:

- Todos os RFs com impacto em tela estão mapeados para história, protótipo, tela Flutter e evidência.
- Todas as lacunas de protótipo foram resolvidas por protótipo novo ou decisão explícita de produto.
- Todas as telas principais foram comparadas contra o APK real.
- Nenhuma tela expõe enums, chaves internas, mensagens técnicas ou copy incoerente.
- As cidades da região inicial aparecem onde forem necessárias: Charqueadas, São Jerônimo, Triunfo, Arroio dos Ratos, Eldorado do Sul, General Câmara e Butiá.
- O canal de verificação por código está decidido e refletido na UI: SMS, WhatsApp, email ou combinação aprovada.
- Um novo APK Android de homologação foi gerado e instalado com sucesso em device real.
- A estratégia equivalente para iOS foi definida antes de TestFlight.

## Ordem cronológica de revisão

| Ordem | História | Tela ou fluxo | RFs principais | Protótipo oficial | Decisão de revisão |
| ----- | -------- | ------------- | --------------- | ----------------- | ------------------ |
| 0 | WL-001 | Massa visual mínima para telas | RF01, RF03, RF09, RF10, RF12, RF19, RF29 | N/A | Validar dados base, cidades, categorias e profissionais fake antes de revisar UI. |
| 1 | WL-002 | Seleção de cidades e localização | RF03, RF04, RF05, RF06, RF07, RF54 | `tela-selecionar-cidades.png` | Revisar seleção múltipla, limpar filtros, localização atual e cidades da região. |
| 2 | WL-003 | Descoberta, busca e estado sem resultado | RF01, RF02, RF03, RF04, RF07, RF08, RF09 | `tela-nenhum-profissional-encontrado.png` | Revisar busca por categoria, palavra-chave, cidade e estado vazio. |
| 3 | WL-004 | Listagem de profissionais | RF09, RF10, RF11, RF23, RF29, RF30 | Lacuna: sem protótipo exclusivo de listagem | Criar ou aprovar referência visual própria para listagem antes de corrigir UI. |
| 4 | WL-005 | Perfil público do profissional | RF11, RF12, RF13, RF29, RF45, RF47 | `tela-perfil-do-profissional.png` | Revisar dados principais, serviços, cidades atendidas, avaliações, denúncia e contato. |
| 5 | WL-006 | Cadastro progressivo do profissional | RF18, RF19, RF20, RF21, RF22 | `tela-cadastro-do-profissional.png` | Revisar cadastro mínimo, perfil completo, edição, completude e campos sensíveis. |
| 6 | WL-007 | Badges de confiança e completude | RF21, RF23, RF24, RF25, RF26 | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png` | Remover labels técnicas e revisar labels de produto em listagem, perfil e cadastro. |
| 7 | WL-008 | Disponibilidade do profissional | RF27, RF28, RF29, RF30 | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png` | Revisar status visíveis e destaque reduzido para indisponíveis. |
| 8 | WL-009 | Autenticação simplificada do cliente | RF14, RF15, RF16, RF17 | `tela-verificao-usuario-cliente-profissional.png`, `tela-login-autenticacao.png` | Revisar navegação sem login, autenticação só em ação sensível e canal real do código. |
| 9 | WL-010 | Contato via WhatsApp e intenção | RF31, RF32, RF33, RF34, RF35 | `tela-falar-com-o-profissional.png` | Revisar aviso de redirecionamento, registro de intenção e limites de responsabilidade. |
| 10 | WL-011 | Pós-contato estruturado | RF35, RF36, RF37, RF38, RF39 | `tela-falar-com-o-profissional.png`, `tela-avaliacao-profissional.png` | Revisar ponte entre intenção de contato, feedback e habilitação de avaliação. |
| 11 | WL-012 | Avaliação anônima rastreável | RF40, RF41, RF42, RF43, RF44 | `tela-avaliacao-profissional.png`, `tela-avaliacao-concluida.png` | Revisar estrelas, comentário, anonimato público e rastreabilidade interna. |
| 12 | WL-013 | Exibição de avaliações no perfil | RF45, RF46 | `tela-perfil-do-profissional.png`, `tela-avaliacao-concluida.png` | Revisar avaliações no perfil e solicitação de análise pelo profissional. |
| 13 | WL-014 | Denúncia de profissional | RF47, RF48, RF49, RF50, RF51, RF52 | `tela-denunciar-profissional.png` | Revisar motivo, descrição, evidência opcional e orientação sobre autoridades. |
| 14 | WL-015 | Perfil do usuário cliente | RF53, RF54, RF55, RF56, RF57 | `tela-perfil-do-cliente-usuario.png` | Revisar cidades selecionadas, salvos, avaliações, preferências, privacidade e sair. |
| 15 | WL-018 | Verificação do telefone do profissional | RF24 | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png` | Revisar badge de telefone verificado sem prometer garantia de qualidade. |
| 16 | WL-019 | Portfólio e fotos do profissional | RF13, RF20 | `tela-perfil-do-profissional.png`, `tela-cadastro-do-profissional.png` | Revisar upload/exibição de fotos e estados sem portfólio. |
| 17 | WL-020 | Profissionais salvos e preferências | RF55, RF57 | `tela-perfil-do-cliente-usuario.png`, `tela-perfil-do-profissional.png` | Revisar salvar/remover profissional e persistência no perfil do cliente. |
| 18 | WL-021 | Solicitação ativa de feedback | RF35, RF36, RF37, RF38, RF39 | `tela-falar-com-o-profissional.png`, `tela-avaliacao-profissional.png` | Revisar gatilho de feedback pós-contato e comunicação honesta ao usuário. |
| 19 | WL-016/WL-023/WL-024 | Administração e moderação | RF62, RF63, RF64, RF65, RF66, RF67 | Lacuna: sem protótipo mobile/admin | Registrar como fluxo administrativo separado; não bloquear APK mobile cliente, mas exigir protótipo antes de construir UI admin. |

## Lacunas de protótipo a resolver

| Lacuna | RFs afetados | Motivo | Ação obrigatória |
| ------ | ------------ | ------ | ---------------- |
| Home | RF01, RF02, RF03, RF09, RF53 | O épico prevê Home com busca, categorias, destaques, confiança, disponibilidade e perfil do usuário. | Criar protótipo oficial ou registrar decisão de que a V1 começa direto pela descoberta/listagem. |
| Listagem de profissionais | RF09, RF10, RF11, RF23, RF29, RF30 | A listagem é tela central, mas hoje usa protótipos relacionados, não um protótipo próprio. | Criar protótipo oficial de card/listagem antes de aprovar correção visual. |
| Pós-contato estruturado | RF35, RF36, RF37, RF38, RF39 | O mapa usa telas relacionadas, mas o fluxo de feedback pode exigir estado próprio. | Decidir se será estado dentro da avaliação ou tela própria. |
| Admin/moderação | RF62 a RF67 | RFs existem, mas não há protótipo mobile/admin. | Tratar como console separado ou criar protótipos antes da implementação visual. |

## Ritual por requisito funcional

Cada RF revisado deve gerar uma entrada objetiva no `progress.txt` da história correspondente ou em uma futura história de correção visual.

Formato obrigatório:

```text
RF: RFxx
História: WL-xxx
Protótipo: docs/prototipos-de-tela/<arquivo>.png ou DECISAO_PRODUTO_NECESSARIA
Tela Flutter: <path>
Backend/API/Massa: <path ou endpoint>
Screenshot real: <path>
Status Produto: PASS | FAIL | DECISAO_PRODUTO_NECESSARIA
Status Mobile Front-end: PASS | FAIL
Status QA: PASS | FAIL
Débitos encontrados:
- ...
Correção necessária:
- ...
```

## Checklist visual obrigatório por tela

Para cada tela, validar:

- paleta e identidade visual verde do WorkLink;
- hierarquia de título, subtítulo, seções e ações;
- cards, botões, ícones, inputs e estados interativos;
- copy em português, sem enums ou labels técnicas;
- estados de carregamento, sucesso, erro e vazio quando aplicável;
- responsividade em Android físico e viewport equivalente iOS;
- acessibilidade mínima: contraste, toque, leitura e foco;
- navegação de ida e volta;
- integração com backend ou mock declarado;
- massa de homologação suficiente para testar o fluxo real.

## Plano de execução recomendado

1. Criar uma história técnica de retomada: `WLT-030 — Revisão funcional e visual das telas mobile da V1`.
2. Na WLT-030, executar uma auditoria sem correção de código para preencher a matriz RF/tela/protótipo/screenshot.
3. Criar sub-histórias de correção agrupadas por jornada, não por arquivo:
   - Descoberta e listagem;
   - Perfil e confiança do profissional;
   - Cadastro profissional e disponibilidade;
   - Autenticação e canal de código;
   - Contato, pós-contato e avaliação;
   - Denúncia;
   - Perfil do usuário.
4. Gerar APK Android de homologação após cada grupo corrigido.
5. Registrar evidências visuais no repositório apenas quando forem screenshots oficiais de validação, não prints temporários de investigação.
6. Antes de TestFlight, repetir a validação visual em iOS ou viewport iOS confiável.

## Bloqueios conhecidos

- O APK atual foi validado como instalável, mas não como produto aderente aos protótipos.
- A pasta `docs/prototipos-de-tela/print-das-telas-para-melhorar/` contém evidências de divergência visual capturadas manualmente.
- A UI atual precisa passar por revisão de produto antes de novas promessas de release.
- O canal de OTP/verificação ainda precisa de decisão explícita.
- A massa de cidades da região carbonífera precisa cobrir todos os municípios definidos para homologação manual.

## Resultado esperado

Ao final, o WorkLink deve ter uma trilha clara dizendo, para cada RF com tela:

- qual protótipo governa a implementação;
- qual tela Flutter entrega o requisito;
- qual teste protege o comportamento;
- qual screenshot prova a aderência visual;
- qual massa de dados permite o teste manual;
- qual APK foi validado pelo dono do produto.
