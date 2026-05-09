import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_controller.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_screen.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_state.dart';

void main() {
  Future<void> pumpProfessionalReviewScreen(
    WidgetTester widgetTester,
    ProfessionalReviewController controller,
  ) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: ProfessionalReviewScreen(
          professionalReviewController: controller,
        ),
      ),
    );
  }

  testWidgets(
      'GIVEN tela avaliacao WHEN renderizar THEN deve exibir nota comentario e anonimato',
      (widgetTester) async {
    // GIVEN
    final controller = ProfessionalReviewController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitProfessionalReview: (_, __) async {},
    );

    // WHEN
    await pumpProfessionalReviewScreen(widgetTester, controller);

    // THEN
    expect(find.text('Avaliar profissional'), findsOneWidget);
    expect(find.text('Como foi o serviço?'), findsOneWidget);
    expect(find.text('Nota obrigatória'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('professional-review-comment-field')),
      findsOneWidget,
    );
    expect(find.text('Ocultar meu nome publicamente'), findsOneWidget);
  });

  testWidgets(
      'GIVEN nota ausente WHEN enviar THEN deve exibir erro de obrigatoriedade',
      (widgetTester) async {
    // GIVEN
    final controller = ProfessionalReviewController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitProfessionalReview: (_, __) async {},
    );
    await pumpProfessionalReviewScreen(widgetTester, controller);

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('submit-professional-review-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(
      find.byKey(const ValueKey('professional-review-error-message')),
      findsOneWidget,
    );
    expect(find.text('Informe uma nota para enviar.'), findsOneWidget);
  });

  testWidgets(
      'GIVEN avaliacao preenchida WHEN enviar THEN deve registrar avaliacao',
      (widgetTester) async {
    // GIVEN
    String? submittedContactIntentionIdentifier;
    ProfessionalReviewState? submittedReviewState;
    final controller = ProfessionalReviewController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitProfessionalReview: (contactIntentionIdentifier, reviewState) {
        submittedContactIntentionIdentifier = contactIntentionIdentifier;
        submittedReviewState = reviewState;
        return Future<void>.value();
      },
    );
    await pumpProfessionalReviewScreen(widgetTester, controller);

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('professional-review-star-5')),
    );
    await widgetTester.enterText(
      find.byKey(const ValueKey('professional-review-comment-field')),
      'Servico excelente.',
    );
    await widgetTester.tap(
      find.byKey(const ValueKey('submit-professional-review-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(submittedContactIntentionIdentifier, 'contact-intention-1');
    expect(submittedReviewState?.starRating, 5);
    expect(submittedReviewState?.normalizedComment, 'Servico excelente.');
    expect(find.text('Avaliação registrada.'), findsOneWidget);
  });
}
