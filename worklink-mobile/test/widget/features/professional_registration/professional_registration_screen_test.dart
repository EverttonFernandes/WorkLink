import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_availability/professional_availability_status.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_controller.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_draft.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_screen.dart';

void main() {
  Future<void> pumpProfessionalRegistrationScreen(
    WidgetTester widgetTester, {
    ProfessionalRegistrationController? controller,
    ValueChanged<ProfessionalRegistrationDraft>? onContinue,
    ValueChanged<ProfessionalRegistrationDraft>? onSaveAndContinueLater,
  }) async {
    await widgetTester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => widgetTester.binding.setSurfaceSize(null));
    await widgetTester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: ProfessionalRegistrationScreen(
          professionalRegistrationController:
              controller ?? ProfessionalRegistrationController(),
          availableCategoryNames: const ['Eletricista', 'Pintora'],
          availableCityDisplayNames: const [
            'Charqueadas - RS',
            'Canoas - RS',
          ],
          onContinue: onContinue,
          onSaveAndContinueLater: onSaveAndContinueLater,
        ),
      ),
    );
  }

  Future<void> scrollRegistrationScreenUntilVisible(
    WidgetTester widgetTester,
    Finder finder,
  ) async {
    await widgetTester.scrollUntilVisible(
      finder,
      120,
      scrollable: find.byType(Scrollable).first,
    );
  }

  testWidgets(
      'GIVEN tela de cadastro WHEN renderizar THEN deve exibir campos do prototipo e completude inicial',
      (widgetTester) async {
    // GIVEN / WHEN
    await pumpProfessionalRegistrationScreen(widgetTester);

    // THEN
    expect(find.text('Cadastro do Profissional'), findsOneWidget);
    expect(find.text('Etapa 1 de 2'), findsOneWidget);
    expect(find.text('0% do perfil preenchido'), findsOneWidget);
    expect(find.text('Adicionar foto'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('CPF ou CNPJ'), findsOneWidget);
    expect(find.text('Categoria do serviço'), findsOneWidget);
    expect(find.text('Cidade / região de atendimento'), findsOneWidget);
    expect(find.text('Disponibilidade'), findsOneWidget);
    expect(find.text('Aceitando novos clientes'), findsOneWidget);
    await scrollRegistrationScreenUntilVisible(
      widgetTester,
      find.text('WhatsApp').first,
    );
    expect(find.text('WhatsApp'), findsOneWidget);
  });

  testWidgets(
      'GIVEN campos minimos preenchidos WHEN tocar continuar THEN deve emitir cadastro minimo',
      (widgetTester) async {
    // GIVEN
    final continuedDrafts = <ProfessionalRegistrationDraft>[];
    await pumpProfessionalRegistrationScreen(
      widgetTester,
      onContinue: continuedDrafts.add,
    );

    // WHEN
    await widgetTester.enterText(
      find.byKey(const ValueKey('professional-registration-name-field')).first,
      'Roberto Silva',
    );
    await widgetTester.tap(
      find
          .byKey(const ValueKey('professional-registration-category-field'))
          .first,
    );
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.text('Eletricista').last);
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(
      find.byKey(const ValueKey('professional-registration-city-field')).first,
    );
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.text('Charqueadas - RS').last);
    await widgetTester.pumpAndSettle();
    await scrollRegistrationScreenUntilVisible(
      widgetTester,
      find
          .byKey(const ValueKey('professional-registration-whatsapp-field'))
          .first,
    );
    await widgetTester.enterText(
      find
          .byKey(const ValueKey('professional-registration-whatsapp-field'))
          .first,
      '(51) 99999-9999',
    );
    await scrollRegistrationScreenUntilVisible(
      widgetTester,
      find
          .byKey(
            const ValueKey('professional-registration-description-field'),
          )
          .first,
    );
    await widgetTester.enterText(
      find
          .byKey(
            const ValueKey('professional-registration-description-field'),
          )
          .first,
      'Instalacoes e manutencoes residenciais.',
    );
    await widgetTester.pump();
    await widgetTester.ensureVisible(
      find
          .byKey(const ValueKey('professional-registration-continue-button'))
          .first,
    );
    await widgetTester.tap(
      find
          .byKey(const ValueKey('professional-registration-continue-button'))
          .first,
    );
    await widgetTester.pump();

    // THEN
    expect(continuedDrafts, hasLength(1));
    expect(continuedDrafts.single.hasMinimumRequiredFields, isTrue);
    expect(continuedDrafts.single.profileCompletenessPercentage, 60);
    expect(
      continuedDrafts.single.availabilityStatus.badgeLabel,
      'Aceitando novos clientes',
    );
  });

  testWidgets(
      'GIVEN disponibilidade selecionada WHEN continuar THEN deve emitir status permitido',
      (widgetTester) async {
    // GIVEN
    final continuedDrafts = <ProfessionalRegistrationDraft>[];
    final controller = ProfessionalRegistrationController(
      initialDraft: const ProfessionalRegistrationDraft(
        professionalName: 'Roberto Silva',
        categoryName: 'Eletricista',
        cityDisplayName: 'Charqueadas - RS',
        whatsappNumber: '(51) 99999-9999',
        shortDescription: 'Instalacoes e manutencoes residenciais.',
        availabilityStatus: ProfessionalAvailabilityStatus.emergencyService,
      ),
    );
    await pumpProfessionalRegistrationScreen(
      widgetTester,
      controller: controller,
      onContinue: continuedDrafts.add,
    );

    // WHEN
    await scrollRegistrationScreenUntilVisible(
      widgetTester,
      find
          .byKey(
            const ValueKey('professional-registration-description-field'),
          )
          .first,
    );
    await widgetTester.ensureVisible(
      find
          .byKey(const ValueKey('professional-registration-continue-button'))
          .first,
    );
    await widgetTester.tap(
      find
          .byKey(const ValueKey('professional-registration-continue-button'))
          .first,
    );
    await widgetTester.pump();

    // THEN
    expect(
      continuedDrafts.single.availabilityStatus.badgeLabel,
      'Atendimento emergencial',
    );
  });

  testWidgets(
      'GIVEN cadastro parcial WHEN salvar depois THEN deve emitir rascunho sem exigir opcionais',
      (widgetTester) async {
    // GIVEN
    final savedDrafts = <ProfessionalRegistrationDraft>[];
    await pumpProfessionalRegistrationScreen(
      widgetTester,
      onSaveAndContinueLater: savedDrafts.add,
    );

    // WHEN
    await widgetTester.enterText(
      find.byKey(const ValueKey('professional-registration-name-field')).first,
      'Roberto Silva',
    );
    await widgetTester.pump();
    await scrollRegistrationScreenUntilVisible(
      widgetTester,
      find
          .byKey(
            const ValueKey('professional-registration-save-later-button'),
          )
          .first,
    );
    await widgetTester.ensureVisible(
      find
          .byKey(
            const ValueKey('professional-registration-save-later-button'),
          )
          .first,
    );
    await widgetTester.tap(
      find
          .byKey(
            const ValueKey('professional-registration-save-later-button'),
          )
          .first,
    );
    await widgetTester.pump();

    // THEN
    expect(savedDrafts, hasLength(1));
    expect(savedDrafts.single.professionalName, 'Roberto Silva');
    expect(savedDrafts.single.hasMinimumRequiredFields, isFalse);
  });

  testWidgets(
      'GIVEN cadastro progressivo WHEN adicionar foto e campos opcionais THEN deve atualizar completude visual',
      (widgetTester) async {
    // GIVEN
    await pumpProfessionalRegistrationScreen(widgetTester);

    // WHEN
    await widgetTester.tap(
      find
          .byKey(const ValueKey('professional-registration-photo-button'))
          .first,
    );
    await widgetTester.enterText(
      find
          .byKey(const ValueKey('professional-registration-document-field'))
          .first,
      '123.456.789-00',
    );
    await scrollRegistrationScreenUntilVisible(
      widgetTester,
      find.byKey(const ValueKey('professional-registration-link-field')).first,
    );
    await widgetTester.ensureVisible(
      find.byKey(const ValueKey('professional-registration-link-field')).first,
    );
    await widgetTester.enterText(
      find.byKey(const ValueKey('professional-registration-link-field')).first,
      'https://worklink.example/roberto',
    );
    await widgetTester.pump();

    // THEN
    expect(find.text('Foto adicionada'), findsOneWidget);
    expect(find.text('30% do perfil preenchido'), findsOneWidget);
  });
}
