# Épico — WorkLink V1

## Objetivo

Construir a primeira versão funcional do WorkLink para descoberta local de profissionais autônomos, com sinais de confiança, disponibilidade e responsividade, contato via WhatsApp e coleta de feedback pós-contato.

## Tese protegida

O WorkLink V1 não deve ser apenas uma lista de contatos. Cada entrega deve ajudar o usuário a encontrar profissionais locais com maior chance real de resposta e atendimento.

## Personas

- Usuário cliente: pessoa que precisa contratar serviços locais e quer mais confiança do que indicação informal.
- Profissional: autônomo ou prestador de serviço manual que quer visibilidade regional.
- Administrador: operador mínimo da plataforma responsável por moderação e acompanhamento.

## Região inicial

Charqueadas e região próxima: São Jerônimo, Triunfo, Arroio dos Ratos, Eldorado do Sul, General Câmara, Butiá e cidades próximas definidas no lançamento.

## Entregas de valor

1. Fundação de categorias, cidades e profissionais mínimos.
2. Seleção de cidades e localização.
3. Descoberta por categoria, cidade e palavra-chave.
4. Listagem com sinais mínimos.
5. Perfil público detalhado.
6. Cadastro progressivo do profissional.
7. Badges de confiança.
8. Disponibilidade explícita.
9. Autenticação simplificada do cliente.
10. Contato via WhatsApp e intenção de contato.
11. Pós-contato estruturado.
12. Avaliação anônima rastreável.
13. Exibição de avaliações.
14. Denúncia de profissional.
15. Perfil do usuário.
16. Administração mínima e moderação.
17. Métricas e base para ranking futuro.

## Regras centrais

- Usuário pode navegar e buscar sem login (`RN01`).
- Login só é exigido antes de contato ou ação sensível (`RN02`).
- O contato principal é WhatsApp (`RN03`).
- O WorkLink não intermedia pagamento (`RN04`).
- O WorkLink não garante execução do serviço (`RN05`).
- Avaliação pública pode ser anônima, mas deve manter autoria interna (`RN09`, `RN10`).
- Avaliação só ocorre após contato registrado e serviço realizado (`RN11`).
- Denúncias graves devem orientar busca de autoridades (`RN13`, `RN14`).
- Perfil completo/verificado não significa garantia de qualidade (`RN16`).

## Fora do escopo da V1

- pagamento dentro do app
- garantia do serviço
- contrato formal
- chat interno completo
- agenda avançada
- cálculo de preço
- orçamento automático
- ranking algorítmico sofisticado
- IA para recomendação
- mediação completa de conflito
- seguro de serviço
- verificação documental avançada
- expansão nacional imediata

## Versionamento

Cada história concluída deve gerar uma entrega documentada em `docs/entregas/` e sugerir incremento semântico:

- `MINOR`: nova capacidade funcional compatível.
- `PATCH`: correção ou ajuste sem novo contrato funcional relevante.
- `MAJOR`: quebra de contrato ou mudança incompatível.

Para o backlog inicial da V1, a previsão padrão é `MINOR` para cada entrega de valor.
