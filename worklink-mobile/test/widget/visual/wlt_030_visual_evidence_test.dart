import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_city.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_controller.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_screen.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_controller.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_screen.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_controller.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_screen.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_state.dart';
import 'package:worklink_mobile/features/discovery/discovery_controller.dart';
import 'package:worklink_mobile/features/discovery/discovery_professional.dart';
import 'package:worklink_mobile/features/discovery/discovery_screen.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_controller.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_screen.dart';
import 'package:worklink_mobile/features/professional_availability/professional_availability_status.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_controller.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_intention.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_screen.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile_review.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile_screen.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_controller.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_draft.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_screen.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_controller.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_screen.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_controller.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_screen.dart';

const _rootKey = ValueKey<String>('visual-evidence-root');

void main() {
  Future<void> pumpEvidenceScreen(
    WidgetTester widgetTester,
    Widget screen, {
    required Size viewportSize,
  }) async {
    widgetTester.view.physicalSize = viewportSize;
    widgetTester.view.devicePixelRatio = 1;
    addTearDown(widgetTester.view.resetPhysicalSize);
    addTearDown(widgetTester.view.resetDevicePixelRatio);
    await widgetTester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: _rootKey,
          child: screen,
        ),
      ),
    );
    await widgetTester.pumpAndSettle();
  }

  Future<void> captureGolden(
    WidgetTester widgetTester,
    String goldenFileName,
  ) async {
    await expectLater(
      find.byKey(_rootKey),
      matchesGoldenFile('goldens/$goldenFileName'),
    );
  }

  group('WLT-030 visual evidence', () {
    testWidgets('captures auth phone entry screen', (widgetTester) async {
      final controller = CustomerAuthenticationController();

      await pumpEvidenceScreen(
        widgetTester,
        CustomerAuthenticationScreen(
          customerAuthenticationController: controller,
        ),
        viewportSize: const Size(800, 1400),
      );

      await captureGolden(widgetTester, '01-auth-phone-entry.png');
    });

    testWidgets('captures auth verification screen', (widgetTester) async {
      final controller = CustomerAuthenticationController();

      await pumpEvidenceScreen(
        widgetTester,
        CustomerAuthenticationScreen(
          customerAuthenticationController: controller,
        ),
        viewportSize: const Size(800, 1400),
      );

      await widgetTester.enterText(
        find.byKey(const ValueKey('customer-phone-field')),
        '(51) 9 8446-3545',
      );
      await widgetTester.ensureVisible(
        find.byKey(const ValueKey('request-code-button')),
      );
      await widgetTester.tap(find.byKey(const ValueKey('request-code-button')));
      await widgetTester.pumpAndSettle();

      await captureGolden(widgetTester, '02-auth-verification.png');
    });

    testWidgets('captures city selection screen', (widgetTester) async {
      const charqueadasCity = CitySelectionCity(
        cityIdentifier: 'charqueadas-rs',
        cityName: 'Charqueadas',
        stateCode: 'RS',
      );
      const eldoradoDoSulCity = CitySelectionCity(
        cityIdentifier: 'eldorado-do-sul-rs',
        cityName: 'Eldorado do Sul',
        stateCode: 'RS',
      );
      const triunfoCity = CitySelectionCity(
        cityIdentifier: 'triunfo-rs',
        cityName: 'Triunfo',
        stateCode: 'RS',
      );

      final controller = CitySelectionController(
        availableCities: const [
          charqueadasCity,
          eldoradoDoSulCity,
          triunfoCity,
        ],
        nearbySuggestedCities: const [charqueadasCity, triunfoCity],
      );

      await pumpEvidenceScreen(
        widgetTester,
        CitySelectionScreen(
          citySelectionController: controller,
        ),
        viewportSize: const Size(800, 1600),
      );

      await captureGolden(widgetTester, '03-city-selection.png');
    });

    testWidgets('captures discovery results screen', (widgetTester) async {
      final controller = DiscoveryController(
        availableProfessionals: const [
          DiscoveryProfessional(
            professionalIdentifier: 'maria-eletricista',
            professionalName: 'Maria Eletricista',
            categoryName: 'Eletricista',
            cityName: 'Charqueadas',
            stateCode: 'RS',
            shortDescription: 'Atendimento residencial e comercial.',
            profileBadgeLabel: 'Perfil verificado',
            availabilityStatus: ProfessionalAvailabilityStatus.availableToday,
            recentActivityLabel: 'Ativo recentemente',
          ),
          DiscoveryProfessional(
            professionalIdentifier: 'joao-encanador',
            professionalName: 'João Encanador',
            categoryName: 'Encanador',
            cityName: 'Triunfo',
            stateCode: 'RS',
            shortDescription: 'Consertos rápidos e manutenção.',
            availabilityStatus:
                ProfessionalAvailabilityStatus.availableThisWeek,
          ),
        ],
      );

      await pumpEvidenceScreen(
        widgetTester,
        DiscoveryScreen(
          discoveryController: controller,
        ),
        viewportSize: const Size(900, 1800),
      );

      await captureGolden(widgetTester, '04-discovery-results.png');
    });

    testWidgets('captures discovery empty state screen', (widgetTester) async {
      final controller = DiscoveryController(
        availableProfessionals: const [
          DiscoveryProfessional(
            professionalIdentifier: 'maria-eletricista',
            professionalName: 'Maria Eletricista',
            categoryName: 'Eletricista',
            cityName: 'Charqueadas',
            stateCode: 'RS',
            shortDescription: 'Atendimento residencial e comercial.',
          ),
        ],
      );

      await pumpEvidenceScreen(
        widgetTester,
        DiscoveryScreen(
          discoveryController: controller,
        ),
        viewportSize: const Size(900, 1800),
      );

      await widgetTester.enterText(
        find.byKey(const ValueKey('keyword-search-field')),
        'jardinagem',
      );
      await widgetTester.pumpAndSettle();

      await captureGolden(widgetTester, '05-discovery-empty-state.png');
    });

    testWidgets('captures professional profile screen', (widgetTester) async {
      const profile = ProfessionalProfile(
        professionalIdentifier: 'roberto-eletricista',
        professionalName: 'Roberto Silva',
        categoryName: 'Eletricista Residencial',
        baseCityName: 'Charqueadas',
        baseStateCode: 'RS',
        attendedCityNames: ['São Jerônimo', 'Triunfo'],
        aboutDescription:
            'Atende instalações elétricas residenciais com segurança.',
        serviceNames: ['Instalações', 'Manutenção'],
        usefulLinks: ['https://worklink.example/roberto'],
        portfolioItemDescriptions: ['Quadro elétrico residencial'],
        profileCompletenessPercentage: 100,
        phoneNumberVerified: true,
        documentProvided: true,
        availabilityStatus: ProfessionalAvailabilityStatus.availableThisWeek,
        reviewSummary: ProfessionalProfileReviewSummary(
          averageRating: 4.5,
          reviewCount: 2,
          comments: [
            ProfessionalProfileReviewComment(
              professionalReviewIdentifier: 'review-1',
              starRating: 5,
              publicAuthorDisplayName: 'Usuario anonimo',
              comment: 'Atendimento rapido.',
            ),
          ],
        ),
      );

      await pumpEvidenceScreen(
        widgetTester,
        const ProfessionalProfileScreen(
          professionalProfile: profile,
        ),
        viewportSize: const Size(800, 1600),
      );

      await captureGolden(widgetTester, '06-professional-profile.png');
    });

    testWidgets('captures professional registration screen',
        (widgetTester) async {
      await pumpEvidenceScreen(
        widgetTester,
        ProfessionalRegistrationScreen(
          professionalRegistrationController:
              ProfessionalRegistrationController(
            initialDraft: const ProfessionalRegistrationDraft(
              professionalName: 'Roberto Silva',
              categoryName: 'Eletricista',
              cityDisplayName: 'Charqueadas - RS',
              whatsappNumber: '(51) 9 9999-9999',
              shortDescription: 'Instalacoes e manutencoes residenciais.',
              hasProfilePhoto: true,
              documentNumber: '123.456.789-00',
              availabilityStatus:
                  ProfessionalAvailabilityStatus.emergencyService,
            ),
          ),
          availableCategoryNames: const ['Eletricista', 'Pintora'],
          availableCityDisplayNames: const [
            'Charqueadas - RS',
            'Canoas - RS',
          ],
        ),
        viewportSize: const Size(800, 2400),
      );

      await captureGolden(widgetTester, '07-professional-registration.png');
    });

    testWidgets('captures customer profile screen', (widgetTester) async {
      final controller = CustomerProfileController(
        initialState: const CustomerProfileState(
          customerName: 'Cliente WorkLink',
          phoneNumber: '(51) 9 9999-1234',
          mainCity: CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
          selectedCities: [
            CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
            CustomerProfileCity(cityName: 'Porto Alegre', stateCode: 'RS'),
          ],
          savedProfessionals: [
            CustomerSavedProfessional(
              professionalIdentifier: 'maria-eletricista',
              professionalName: 'Maria Eletricista',
              categoryName: 'Eletricista',
              cityDisplayName: 'Canoas - RS',
            ),
          ],
          submittedReviews: [
            CustomerSubmittedReview(
              professionalName: 'Maria Eletricista',
              starRating: 5,
              publiclyAnonymous: true,
            ),
          ],
        ),
      );

      await pumpEvidenceScreen(
        widgetTester,
        CustomerProfileScreen(
          customerProfileController: controller,
        ),
        viewportSize: const Size(800, 1400),
      );

      await captureGolden(widgetTester, '08-customer-profile.png');
    });

    testWidgets('captures professional contact screen', (widgetTester) async {
      final controller = ProfessionalContactController(
        registerProfessionalContactIntention: (_) async =>
            const ProfessionalContactIntention(
          contactIntentionIdentifier: 'contact-intention-1',
          professionalIdentifier: 'maria-eletricista',
          professionalName: 'Maria Eletricista',
          whatsappContactLink: 'https://wa.me/51999999999',
        ),
        openProfessionalWhatsappContact: (_) async => true,
      );

      await pumpEvidenceScreen(
        widgetTester,
        ProfessionalContactScreen(
          professionalIdentifier: 'maria-eletricista',
          professionalName: 'Maria Eletricista',
          professionalContactController: controller,
        ),
        viewportSize: const Size(800, 1600),
      );

      await captureGolden(widgetTester, '09-professional-contact.png');
    });

    testWidgets('captures post contact feedback screen', (widgetTester) async {
      final controller = PostContactFeedbackController(
        contactIntentionIdentifier: 'contact-intention-1',
        submitPostContactFeedback: (_, __) async {},
      );

      await pumpEvidenceScreen(
        widgetTester,
        PostContactFeedbackScreen(
          postContactFeedbackController: controller,
        ),
        viewportSize: const Size(800, 1600),
      );

      await captureGolden(widgetTester, '10-post-contact-feedback.png');
    });

    testWidgets('captures professional review screen', (widgetTester) async {
      final controller = ProfessionalReviewController(
        contactIntentionIdentifier: 'contact-intention-1',
        submitProfessionalReview: (_, __) async {},
      );

      await pumpEvidenceScreen(
        widgetTester,
        ProfessionalReviewScreen(
          professionalReviewController: controller,
        ),
        viewportSize: const Size(800, 1600),
      );

      await captureGolden(widgetTester, '11-professional-review.png');
    });

    testWidgets('captures professional review success screen',
        (widgetTester) async {
      final controller = ProfessionalReviewController(
        contactIntentionIdentifier: 'contact-intention-1',
        submitProfessionalReview: (_, __) async {},
      );

      await pumpEvidenceScreen(
        widgetTester,
        ProfessionalReviewScreen(
          professionalReviewController: controller,
        ),
        viewportSize: const Size(800, 1600),
      );

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

      await captureGolden(widgetTester, '12-professional-review-success.png');
    });

    testWidgets('captures professional report screen', (widgetTester) async {
      final controller = ProfessionalReportController(
        professionalIdentifier: 'maria-eletricista',
        submitProfessionalReport: (_, __) async {},
      );

      await pumpEvidenceScreen(
        widgetTester,
        ProfessionalReportScreen(
          professionalName: 'Maria Eletricista',
          professionalReportController: controller,
        ),
        viewportSize: const Size(800, 1400),
      );

      await captureGolden(widgetTester, '13-professional-report.png');
    });
  });
}
