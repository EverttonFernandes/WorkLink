import 'package:flutter/material.dart';
import 'package:worklink_mobile/app/worklink_theme.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_city.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_controller.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_screen.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_controller.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_screen.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_state.dart';
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

void main() {
  runApp(const Wlt030VisualEvidenceWebApp());
}

class Wlt030VisualEvidenceWebApp extends StatelessWidget {
  const Wlt030VisualEvidenceWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    final requestedScreen = Uri.base.queryParameters['screen'] ?? 'index';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WLT-030 Visual Evidence',
      theme: buildWorkLinkTheme(),
      home: _VisualEvidenceViewport(
        child: _buildScreen(requestedScreen),
      ),
    );
  }

  Widget _buildScreen(String requestedScreen) {
    return switch (requestedScreen) {
      'auth-sign-in' => CustomerAuthenticationScreen(
          customerAuthenticationController: CustomerAuthenticationController(),
        ),
      'auth-sign-up' => CustomerAuthenticationScreen(
          customerAuthenticationController: _authenticationSignUp(),
        ),
      'city-selection' => CitySelectionScreen(
          citySelectionController: _citySelectionController(),
        ),
      'discovery-results' => DiscoveryScreen(
          discoveryController: _discoveryResultsController(),
        ),
      'discovery-empty-state' => DiscoveryScreen(
          discoveryController: _discoveryEmptyStateController(),
        ),
      'professional-profile' => const ProfessionalProfileScreen(
          professionalProfile: _professionalProfile,
        ),
      'professional-registration' => ProfessionalRegistrationScreen(
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
      'customer-profile' => CustomerProfileScreen(
          customerProfileController: CustomerProfileController(
            initialState: _customerProfileState,
          ),
        ),
      'professional-contact' => ProfessionalContactScreen(
          professionalIdentifier: 'maria-eletricista',
          professionalName: 'Maria Eletricista',
          professionalContactController: _professionalContactController(),
        ),
      'post-contact-feedback' => PostContactFeedbackScreen(
          postContactFeedbackController: PostContactFeedbackController(
            contactIntentionIdentifier: 'contact-intention-1',
            submitPostContactFeedback: (_, __) async {},
          ),
        ),
      'professional-review' => ProfessionalReviewScreen(
          professionalReviewController: _professionalReviewController(),
        ),
      'professional-review-success' => _ProfessionalReviewSuccessEvidence(
          professionalReviewController: _professionalReviewController(),
        ),
      'professional-report' => ProfessionalReportScreen(
          professionalName: 'Maria Eletricista',
          professionalReportController: ProfessionalReportController(
            professionalIdentifier: 'maria-eletricista',
            submitProfessionalReport: (_, __) async {},
          ),
        ),
      _ => const _VisualEvidenceIndex(),
    };
  }
}

class _VisualEvidenceViewport extends StatelessWidget {
  const _VisualEvidenceViewport({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE9ECEF),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 430,
          child: Material(
            color: Colors.white,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ProfessionalReviewSuccessEvidence extends StatefulWidget {
  const _ProfessionalReviewSuccessEvidence({
    required this.professionalReviewController,
  });

  final ProfessionalReviewController professionalReviewController;

  @override
  State<_ProfessionalReviewSuccessEvidence> createState() =>
      _ProfessionalReviewSuccessEvidenceState();
}

class _ProfessionalReviewSuccessEvidenceState
    extends State<_ProfessionalReviewSuccessEvidence> {
  @override
  void initState() {
    super.initState();
    widget.professionalReviewController.selectStarRating(5);
    widget.professionalReviewController.changeComment('Servico excelente.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.professionalReviewController.submitReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalReviewScreen(
      professionalReviewController: widget.professionalReviewController,
    );
  }
}

class _VisualEvidenceIndex extends StatelessWidget {
  const _VisualEvidenceIndex();

  final List<String> screenNames = const [
    'auth-sign-in',
    'auth-sign-up',
    'city-selection',
    'discovery-results',
    'discovery-empty-state',
    'professional-profile',
    'professional-registration',
    'customer-profile',
    'professional-contact',
    'post-contact-feedback',
    'professional-review',
    'professional-review-success',
    'professional-report',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WLT-030 Visual Evidence')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final screenName in screenNames)
            ListTile(
              title: Text(screenName),
              subtitle: Text('/?screen=$screenName'),
            ),
        ],
      ),
    );
  }
}

CustomerAuthenticationController _authenticationSignUp() =>
    CustomerAuthenticationController()
      ..selectMode(CustomerAuthenticationMode.signUp);

CitySelectionController _citySelectionController() {
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
  return CitySelectionController(
    availableCities: const [
      charqueadasCity,
      eldoradoDoSulCity,
      triunfoCity,
    ],
    nearbySuggestedCities: const [charqueadasCity, triunfoCity],
  );
}

DiscoveryController _discoveryResultsController() {
  return DiscoveryController(
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
        professionalName: 'Joao Encanador',
        categoryName: 'Encanador',
        cityName: 'Triunfo',
        stateCode: 'RS',
        shortDescription: 'Consertos rapidos e manutencao.',
        availabilityStatus: ProfessionalAvailabilityStatus.availableThisWeek,
      ),
    ],
  );
}

DiscoveryController _discoveryEmptyStateController() {
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
  controller.searchByKeyword('jardinagem');
  return controller;
}

ProfessionalContactController _professionalContactController() {
  return ProfessionalContactController(
    registerProfessionalContactIntention: (_) async =>
        const ProfessionalContactIntention(
      contactIntentionIdentifier: 'contact-intention-1',
      professionalIdentifier: 'maria-eletricista',
      professionalName: 'Maria Eletricista',
      whatsappContactLink: 'https://wa.me/51999999999',
    ),
    openProfessionalWhatsappContact: (_) async => true,
  );
}

ProfessionalReviewController _professionalReviewController() {
  return ProfessionalReviewController(
    contactIntentionIdentifier: 'contact-intention-1',
    submitProfessionalReview: (_, __) async {},
  );
}

const _professionalProfile = ProfessionalProfile(
  professionalIdentifier: 'roberto-eletricista',
  professionalName: 'Roberto Silva',
  categoryName: 'Eletricista Residencial',
  baseCityName: 'Charqueadas',
  baseStateCode: 'RS',
  attendedCityNames: ['Sao Jeronimo', 'Triunfo'],
  aboutDescription: 'Atende instalacoes eletricas residenciais com seguranca.',
  serviceNames: ['Instalacoes', 'Manutencao'],
  usefulLinks: ['https://worklink.example/roberto'],
  portfolioItemDescriptions: ['Quadro eletrico residencial'],
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

const _customerProfileState = CustomerProfileState(
  customerName: 'Cliente Exemplo',
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
);
