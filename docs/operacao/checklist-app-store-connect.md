# Checklist App Store Connect - WorkLink

## Conta

- [ ] Apple Account com 2FA ativo.
- [ ] Apple Developer Program avaliado.
- [ ] Cadastro individual ou organizacao decidido.
- [ ] Pagamento anual planejado.
- [ ] Nome legal validado, ciente de que conta individual exibe o nome do vendedor.

## Identidade do app

- [ ] Bundle identifier definitivo definido.
- [ ] Team ID registrado.
- [ ] Certificado de distribuicao definido.
- [ ] Provisioning profile para distribuicao/TestFlight definido.
- [ ] App Store Connect API Key planejada para automacao futura.

## App Store Connect

- [ ] App criado no App Store Connect.
- [ ] Nome publico definido.
- [ ] Categoria definida.
- [ ] Descricao e subtitulo revisados.
- [ ] URL de suporte definida.
- [ ] URL de politica de privacidade definida.
- [ ] Informacoes de contato para revisao Apple definidas.

## Privacidade Apple

- [ ] App Privacy/Nutrition Label preenchido com dados reais.
- [ ] Coleta de telefone, email, localizacao e identificadores revisada.
- [ ] Retencao e exclusao coerentes com a politica de privacidade.
- [ ] Compartilhamento com provedores de SMS/WhatsApp/email declarado quando aplicavel.

## TestFlight

- [ ] Build iOS gerado em runner macOS.
- [ ] Assinatura iOS configurada sem versionar secrets.
- [ ] Grupo interno de testers criado.
- [ ] App instalado via TestFlight em iPhone real.
- [ ] Smoke test manual aprovado antes de App Review.

## Go/no-go

- [ ] Android ja passou por teste interno ou existe decisao explicita para seguir em paralelo.
- [ ] Backend cloud e autenticacao real estao estaveis.
- [ ] Screenshots iOS respeitam os prototipos mobile.
- [ ] Nenhum fluxo principal depende de recurso Android-only.
