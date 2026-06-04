import '../features/administrative_console/administrative_console_state.dart';
import '../features/customer_authentication/customer_authentication_state.dart';
import '../features/customer_profile/customer_profile_state.dart';
import '../features/discovery/discovery_professional.dart';
import '../features/post_contact_feedback/post_contact_feedback_request.dart';
import '../features/post_contact_feedback/post_contact_feedback_state.dart';
import '../features/professional_availability/professional_availability_status.dart';
import '../features/professional_contact/professional_contact_intention.dart';
import '../features/professional_profile/professional_profile.dart';
import '../features/professional_profile/professional_profile_review.dart';
import '../features/professional_registration/professional_registration_draft.dart';
import '../features/professional_report/professional_report_state.dart';
import '../features/professional_review/professional_review_state.dart';
import '../services/admin_service.dart';
import '../services/api_client.dart';
import '../services/authentication_service.dart';
import '../services/catalog_service.dart';
import '../services/contact_service.dart';
import '../services/customer_service.dart';
import '../services/exceptions.dart';
import '../services/models/admin_model.dart' as admin_models;
import '../services/models/catalog_model.dart';
import '../services/models/contact_model.dart' as contact_models;
import '../services/models/customer_model.dart' as customer_models;
import '../services/models/professional_model.dart' as professional_models;
import '../services/models/report_model.dart' as report_models;
import '../services/models/review_model.dart' as review_models;
import '../services/professional_service.dart';
import '../services/report_service.dart';
import '../services/review_service.dart';

class WorkLinkHomeData {
  const WorkLinkHomeData({
    required this.discoveryProfessionals,
    required this.professionalProfiles,
    required this.professionalRegistrationCategoryNames,
    required this.professionalRegistrationCityDisplayNames,
    required this.categoryIdentifiersByName,
    required this.cityIdentifiersByDisplayName,
  });

  final List<DiscoveryProfessional> discoveryProfessionals;
  final List<ProfessionalProfile> professionalProfiles;
  final List<String> professionalRegistrationCategoryNames;
  final List<String> professionalRegistrationCityDisplayNames;
  final Map<String, String> categoryIdentifiersByName;
  final Map<String, String> cityIdentifiersByDisplayName;
}

abstract interface class WorkLinkApplicationGateway {
  bool get administrativeConsoleAvailable;

  WorkLinkHomeData? get initialHomeData;

  Future<WorkLinkHomeData> loadHomeData();

  Future<void> requestCustomerAuthenticationCode(
    String phoneNumber, {
    CustomerAuthenticationVerificationChannel verificationChannel,
    String? emailAddress,
  });

  Future<void> confirmCustomerAuthenticationCode({
    required String phoneNumber,
    required String verificationCode,
  });

  Future<CustomerProfileState> loadCustomerProfile();

  Future<CustomerProfileState> updateCustomerProfilePreferences({
    required bool whatsappNotificationsEnabled,
    required bool profilePersonalizationEnabled,
  });

  Future<CustomerProfileState> saveProfessionalForCustomer(
    String professionalIdentifier,
  );

  Future<CustomerProfileState> removeSavedProfessionalForCustomer(
    String professionalIdentifier,
  );

  Future<List<PostContactFeedbackRequest>>
      loadPendingPostContactFeedbackRequests();

  Future<void> dismissPostContactFeedbackRequest(
    String contactIntentionIdentifier,
  );

  Future<void> registerProfessional(
    ProfessionalRegistrationDraft draft,
    WorkLinkHomeData homeData,
  );

  Future<void> requestProfessionalPhoneVerification(
    String professionalIdentifier,
  );

  Future<void> confirmProfessionalPhoneVerification({
    required String professionalIdentifier,
    required String verificationCode,
  });

  Future<void> addProfessionalPortfolioItem({
    required String professionalIdentifier,
    required String fileIdentifier,
    required String title,
    String? description,
    int displayOrder,
  });

  Future<ProfessionalContactIntention> startProfessionalContact(
    String professionalIdentifier,
  );

  Future<void> submitPostContactFeedback(
    String contactIntentionIdentifier,
    PostContactFeedbackState feedbackState,
  );

  Future<void> submitProfessionalReview(
    String contactIntentionIdentifier,
    ProfessionalReviewState reviewState,
  );

  Future<void> submitProfessionalReport(
    String professionalIdentifier,
    ProfessionalReportState reportState,
  );

  Future<void> requestProfessionalReviewAnalysis(
    String professionalReviewIdentifier,
  );

  Future<AdministrativeConsoleState> loadAdministrativeConsole();

  Future<AdministrativeConsoleState> blockAdministrativeProfessional(
    String professionalIdentifier,
  );

  Future<AdministrativeConsoleState> unblockAdministrativeProfessional(
    String professionalIdentifier,
  );

  Future<AdministrativeConsoleState> approveAdministrativeProfessionalReport(
    String professionalReportIdentifier,
  );

  Future<AdministrativeConsoleState> escalateAdministrativeProfessionalReport(
    String professionalReportIdentifier,
  );

  Future<AdministrativeConsoleState> keepAdministrativeReviewPublic(
    String reviewAnalysisRequestIdentifier,
  );

  Future<AdministrativeConsoleState> hideAdministrativeReviewFromPublic(
    String reviewAnalysisRequestIdentifier,
  );

  Future<AdministrativeConsoleState> registerAdministrativeCategory(
    String categoryName,
  );
}

class WorkLinkBackendGateway implements WorkLinkApplicationGateway {
  WorkLinkBackendGateway({
    WorkLinkHttpClient? httpClient,
    WorkLinkHttpClient? administrativeHttpClient,
    String? administrativeAccessToken,
  })  : _httpClient = httpClient ?? ApiClient(),
        _administrativeHttpClient = administrativeHttpClient,
        _administrativeAccessToken = administrativeAccessToken;

  static const _missingCategoryName = 'Categoria não informada';
  static const _missingCityDisplayName = 'Cidade não informada';
  static const _unmappedCategoryLabel = 'Categoria não mapeada';
  static const _unmappedCityLabel = 'Cidade não mapeada';
  static const _unmappedProfessionalLabel = 'Profissional não mapeado';

  final WorkLinkHttpClient _httpClient;
  final WorkLinkHttpClient? _administrativeHttpClient;
  final String? _administrativeAccessToken;

  @override
  bool get administrativeConsoleAvailable =>
      _administrativeHttpClient != null ||
      (_administrativeAccessToken != null &&
          _administrativeAccessToken.trim().isNotEmpty);

  @override
  WorkLinkHomeData? get initialHomeData => null;

  @override
  Future<WorkLinkHomeData> loadHomeData() async {
    final catalogService = CatalogService(httpClient: _httpClient);
    final professionalService = ProfessionalService(httpClient: _httpClient);
    final reviewService = ReviewService(httpClient: _httpClient);

    final categories = await catalogService.listServiceCategories();
    final cities = await catalogService.listServiceCities();
    final professionals = await professionalService.listProfessionals();

    final categoryNamesByIdentifier = {
      for (final category in categories)
        category.categoryIdentifier: category.categoryName,
    };
    final categoryIdentifiersByName = {
      for (final category in categories)
        category.categoryName: category.categoryIdentifier,
    };
    final cityDisplayNamesByIdentifier = {
      for (final city in cities) city.cityIdentifier: city.displayName,
    };
    final cityIdentifiersByDisplayName = {
      for (final city in cities) city.displayName: city.cityIdentifier,
    };

    final reviewProfilesByProfessionalIdentifier =
        <String, review_models.ProfessionalReviewProfile>{};
    final portfolioItemsByProfessionalIdentifier =
        <String, List<professional_models.ProfessionalPortfolioItem>>{};
    for (final professional in professionals) {
      reviewProfilesByProfessionalIdentifier[
              professional.professionalIdentifier] =
          await reviewService.listProfessionalReviewProfile(
        professional.professionalIdentifier,
      );
      portfolioItemsByProfessionalIdentifier[
              professional.professionalIdentifier] =
          await professionalService.listProfessionalPortfolioItems(
        professional.professionalIdentifier,
      );
    }

    return WorkLinkHomeData(
      discoveryProfessionals: professionals
          .map(
            (professional) => _mapDiscoveryProfessional(
              professional,
              categoryNamesByIdentifier,
              cityDisplayNamesByIdentifier,
            ),
          )
          .toList(),
      professionalProfiles: professionals
          .map(
            (professional) => _mapProfessionalProfile(
              professional,
              categoryNamesByIdentifier,
              cityDisplayNamesByIdentifier,
              reviewProfilesByProfessionalIdentifier[
                  professional.professionalIdentifier],
              portfolioItemsByProfessionalIdentifier[
                      professional.professionalIdentifier] ??
                  const [],
            ),
          )
          .toList(),
      professionalRegistrationCategoryNames:
          categories.map((category) => category.categoryName).toList()..sort(),
      professionalRegistrationCityDisplayNames:
          cities.map((city) => city.displayName).toList()..sort(),
      categoryIdentifiersByName: categoryIdentifiersByName,
      cityIdentifiersByDisplayName: cityIdentifiersByDisplayName,
    );
  }

  @override
  Future<void> requestCustomerAuthenticationCode(
    String phoneNumber, {
    CustomerAuthenticationVerificationChannel verificationChannel =
        CustomerAuthenticationVerificationChannel.sms,
    String? emailAddress,
  }) async {
    final authenticationService =
        AuthenticationService(httpClient: _httpClient);
    await authenticationService.requestAuthenticationOtp(
      phoneNumber,
      deliveryChannel: verificationChannel.apiValue,
      emailAddress: emailAddress,
    );
  }

  @override
  Future<void> confirmCustomerAuthenticationCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    final authenticationService =
        AuthenticationService(httpClient: _httpClient);
    await authenticationService.verifyAuthenticationOtp(
      phoneNumber: phoneNumber,
      oneTimePassword: verificationCode,
    );
  }

  @override
  Future<CustomerProfileState> loadCustomerProfile() async {
    final customerService = CustomerService(httpClient: _httpClient);
    final customerProfile = await customerService.loadCustomerProfile();
    return _mapCustomerProfile(customerProfile);
  }

  @override
  Future<CustomerProfileState> updateCustomerProfilePreferences({
    required bool whatsappNotificationsEnabled,
    required bool profilePersonalizationEnabled,
  }) async {
    final customerService = CustomerService(httpClient: _httpClient);
    final customerProfile =
        await customerService.updateCustomerProfilePreferences(
      whatsappNotificationsEnabled: whatsappNotificationsEnabled,
      profilePersonalizationEnabled: profilePersonalizationEnabled,
    );
    return _mapCustomerProfile(customerProfile);
  }

  @override
  Future<CustomerProfileState> saveProfessionalForCustomer(
    String professionalIdentifier,
  ) async {
    final customerService = CustomerService(httpClient: _httpClient);
    final customerProfile =
        await customerService.saveProfessional(professionalIdentifier);
    return _mapCustomerProfile(customerProfile);
  }

  @override
  Future<CustomerProfileState> removeSavedProfessionalForCustomer(
    String professionalIdentifier,
  ) async {
    final customerService = CustomerService(httpClient: _httpClient);
    final customerProfile =
        await customerService.removeSavedProfessional(professionalIdentifier);
    return _mapCustomerProfile(customerProfile);
  }

  @override
  Future<List<PostContactFeedbackRequest>>
      loadPendingPostContactFeedbackRequests() async {
    final contactService = ContactService(httpClient: _httpClient);
    final requests =
        await contactService.listPendingPostContactFeedbackRequests();
    return requests.map(_mapPendingPostContactFeedbackRequest).toList();
  }

  @override
  Future<void> dismissPostContactFeedbackRequest(
    String contactIntentionIdentifier,
  ) async {
    final contactService = ContactService(httpClient: _httpClient);
    await contactService.dismissPostContactFeedbackRequest(
      contactIntentionIdentifier,
    );
  }

  @override
  Future<void> registerProfessional(
    ProfessionalRegistrationDraft draft,
    WorkLinkHomeData homeData,
  ) async {
    final professionalService = ProfessionalService(httpClient: _httpClient);
    final categoryIdentifier =
        homeData.categoryIdentifiersByName[draft.categoryName];
    final cityIdentifier =
        homeData.cityIdentifiersByDisplayName[draft.cityDisplayName];
    if (categoryIdentifier == null || cityIdentifier == null) {
      throw StateError('Categoria ou cidade sem identificador de backend.');
    }

    final professional = await professionalService.registerBasicProfessional(
      professional_models.RegisterBasicProfessionalRequest(
        professionalName: draft.professionalName.trim(),
        whatsappNumber: draft.whatsappNumber.trim(),
        cityIdentifier: cityIdentifier,
        categoryIdentifier: categoryIdentifier,
        shortDescription: draft.shortDescription.trim(),
      ),
    );

    await professionalService.completeProfessionalProfile(
      professionalIdentifier: professional.professionalIdentifier,
      request: professional_models.CompleteProfessionalProfileRequest(
        documentNumber: draft.documentNumber.trim().isEmpty
            ? null
            : draft.documentNumber.trim(),
        usefulLink:
            draft.usefulLink.trim().isEmpty ? null : draft.usefulLink.trim(),
        portfolioDescription: draft.instagramProfile.trim().isEmpty
            ? null
            : draft.instagramProfile.trim(),
        serviceDescription: draft.shortDescription.trim(),
        availabilityStatus:
            _mapAvailabilityStatusToBackend(draft.availabilityStatus),
      ),
    );
  }

  @override
  Future<void> requestProfessionalPhoneVerification(
    String professionalIdentifier,
  ) async {
    final professionalService = ProfessionalService(httpClient: _httpClient);
    await professionalService.requestProfessionalPhoneVerification(
      professionalIdentifier,
    );
  }

  @override
  Future<void> confirmProfessionalPhoneVerification({
    required String professionalIdentifier,
    required String verificationCode,
  }) async {
    final professionalService = ProfessionalService(httpClient: _httpClient);
    await professionalService.confirmProfessionalPhoneVerification(
      professionalIdentifier: professionalIdentifier,
      verificationCode: verificationCode,
    );
  }

  @override
  Future<void> addProfessionalPortfolioItem({
    required String professionalIdentifier,
    required String fileIdentifier,
    required String title,
    String? description,
    int displayOrder = 0,
  }) async {
    final professionalService = ProfessionalService(httpClient: _httpClient);
    await professionalService.addProfessionalPortfolioItem(
      professionalIdentifier: professionalIdentifier,
      request: professional_models.AddProfessionalPortfolioItemRequest(
        fileIdentifier: fileIdentifier,
        title: title,
        description: description,
        displayOrder: displayOrder,
      ),
    );
  }

  @override
  Future<ProfessionalContactIntention> startProfessionalContact(
    String professionalIdentifier,
  ) async {
    final contactService = ContactService(httpClient: _httpClient);
    final contactIntention = await contactService.startProfessionalContact(
      professionalIdentifier,
    );
    return _mapProfessionalContactIntention(contactIntention);
  }

  @override
  Future<void> submitPostContactFeedback(
    String contactIntentionIdentifier,
    PostContactFeedbackState feedbackState,
  ) async {
    final contactService = ContactService(httpClient: _httpClient);
    await contactService.registerPostContactFeedback(
      contact_models.RegisterPostContactFeedbackRequest(
        contactIntentIdentifier: contactIntentionIdentifier,
        conversationOutcome:
            _mapConversationOutcome(feedbackState.conversationOutcome),
        contactResponsiveness:
            _mapContactResponsiveness(feedbackState.contactResponsiveness),
        serviceExecutionOutcome: _mapServiceExecutionOutcome(
          feedbackState.serviceExecutionOutcome,
        ),
      ),
    );
  }

  @override
  Future<void> submitProfessionalReview(
    String contactIntentionIdentifier,
    ProfessionalReviewState reviewState,
  ) async {
    final reviewService = ReviewService(httpClient: _httpClient);
    await reviewService.registerProfessionalReview(
      review_models.RegisterProfessionalReviewRequest(
        contactIntentIdentifier: contactIntentionIdentifier,
        starRating: reviewState.starRating!,
        comment: reviewState.normalizedComment,
        anonymousToPublic: reviewState.anonymousToPublic,
      ),
    );
  }

  @override
  Future<void> submitProfessionalReport(
    String professionalIdentifier,
    ProfessionalReportState reportState,
  ) async {
    final reportService = ReportService(httpClient: _httpClient);
    await reportService.registerProfessionalReport(
      report_models.RegisterProfessionalReportRequest(
        professionalIdentifier: professionalIdentifier,
        reportReason: _mapReportReason(reportState.selectedReason),
        description: reportState.normalizedDescription,
      ),
    );
  }

  @override
  Future<void> requestProfessionalReviewAnalysis(
    String professionalReviewIdentifier,
  ) async {
    final reviewService = ReviewService(httpClient: _httpClient);
    await reviewService.requestProfessionalReviewAnalysis(
      professionalReviewIdentifier: professionalReviewIdentifier,
      reason: 'Solicitacao de analise pelo profissional.',
    );
  }

  @override
  Future<AdministrativeConsoleState> loadAdministrativeConsole() async {
    final adminService = _createAdministrativeService();
    final catalogService = CatalogService(httpClient: _httpClient);
    final administrativeProfessionalsFuture =
        adminService.listAdministrativeProfessionals();
    final administrativeReportsFuture =
        adminService.listAdministrativeProfessionalReports();
    final administrativeReviewAnalysisRequestsFuture =
        adminService.listAdministrativeReviewAnalysisRequests();
    final administrativeMetricsFuture =
        adminService.loadAdministrativeMetrics();
    final functionalMetricsFuture = adminService.loadFunctionalMetrics();
    final categoriesFuture = catalogService.listServiceCategories();
    final citiesFuture = catalogService.listServiceCities();

    final administrativeProfessionals = await administrativeProfessionalsFuture;
    final administrativeReports = await administrativeReportsFuture;
    final administrativeReviewAnalysisRequests =
        await administrativeReviewAnalysisRequestsFuture;
    final administrativeMetrics = await administrativeMetricsFuture;
    final functionalMetrics = await functionalMetricsFuture;
    final categories = await categoriesFuture;
    final cities = await citiesFuture;

    return _mapAdministrativeConsoleState(
      administrativeProfessionals: administrativeProfessionals,
      administrativeReports: administrativeReports,
      administrativeReviewAnalysisRequests:
          administrativeReviewAnalysisRequests,
      administrativeMetrics: administrativeMetrics,
      functionalMetrics: functionalMetrics,
      categories: categories,
      cities: cities,
      statusMessage: 'Console administrativo carregado.',
    );
  }

  @override
  Future<AdministrativeConsoleState> blockAdministrativeProfessional(
    String professionalIdentifier,
  ) async {
    final adminService = _createAdministrativeService();
    await adminService.blockProfessional(professionalIdentifier);
    return _reloadAdministrativeConsoleAfterMutation(
      'Profissional bloqueado no console administrativo.',
    );
  }

  @override
  Future<AdministrativeConsoleState> unblockAdministrativeProfessional(
    String professionalIdentifier,
  ) async {
    final adminService = _createAdministrativeService();
    await adminService.unblockProfessional(professionalIdentifier);
    return _reloadAdministrativeConsoleAfterMutation(
      'Profissional desbloqueado no console administrativo.',
    );
  }

  @override
  Future<AdministrativeConsoleState> approveAdministrativeProfessionalReport(
    String professionalReportIdentifier,
  ) async {
    final adminService = _createAdministrativeService();
    await adminService.moderateProfessionalReport(
      professionalReportIdentifier: professionalReportIdentifier,
      moderationStatus: 'RESOLVED',
      moderationDecision: 'KEEP_AS_IS',
      moderationNotes: 'Denuncia revisada e mantida sem acao adicional.',
    );
    return _reloadAdministrativeConsoleAfterMutation(
      'Denuncia revisada e mantida.',
    );
  }

  @override
  Future<AdministrativeConsoleState> escalateAdministrativeProfessionalReport(
    String professionalReportIdentifier,
  ) async {
    final adminService = _createAdministrativeService();
    await adminService.moderateProfessionalReport(
      professionalReportIdentifier: professionalReportIdentifier,
      moderationStatus: 'ACTION_REQUIRED',
      moderationDecision: 'REQUIRE_ADDITIONAL_ACTION',
      moderationNotes:
          'Denuncia exige acompanhamento administrativo adicional.',
    );
    return _reloadAdministrativeConsoleAfterMutation(
      'Denuncia sinalizada para acao adicional.',
    );
  }

  @override
  Future<AdministrativeConsoleState> keepAdministrativeReviewPublic(
    String reviewAnalysisRequestIdentifier,
  ) async {
    final adminService = _createAdministrativeService();
    await adminService.moderateReviewAnalysisRequest(
      reviewAnalysisRequestIdentifier: reviewAnalysisRequestIdentifier,
      moderationStatus: 'RESOLVED',
      moderationDecision: 'KEEP_AS_IS',
      moderationNotes: 'Avaliacao mantida publica pela administracao.',
    );
    return _reloadAdministrativeConsoleAfterMutation(
      'Contestacao revisada e avaliacao mantida publica.',
    );
  }

  @override
  Future<AdministrativeConsoleState> hideAdministrativeReviewFromPublic(
    String reviewAnalysisRequestIdentifier,
  ) async {
    final adminService = _createAdministrativeService();
    await adminService.moderateReviewAnalysisRequest(
      reviewAnalysisRequestIdentifier: reviewAnalysisRequestIdentifier,
      moderationStatus: 'ACTION_REQUIRED',
      moderationDecision: 'HIDE_FROM_PUBLIC',
      moderationNotes: 'Avaliacao ocultada do perfil publico.',
    );
    return _reloadAdministrativeConsoleAfterMutation(
      'Avaliacao ocultada do perfil publico.',
    );
  }

  @override
  Future<AdministrativeConsoleState> registerAdministrativeCategory(
    String categoryName,
  ) async {
    final adminService = _createAdministrativeService();
    await adminService.registerServiceCategory(categoryName);
    return _reloadAdministrativeConsoleAfterMutation(
      'Categoria administrativa registrada com sucesso.',
    );
  }

  DiscoveryProfessional _mapDiscoveryProfessional(
    professional_models.Professional professional,
    Map<String, String> categoryNamesByIdentifier,
    Map<String, String> cityDisplayNamesByIdentifier,
  ) {
    final cityDisplayName =
        cityDisplayNamesByIdentifier[professional.cityIdentifier] ??
            _missingCityDisplayName;
    final cityParts = cityDisplayName.split(' - ');
    return DiscoveryProfessional(
      professionalIdentifier: professional.professionalIdentifier,
      professionalName: professional.professionalName,
      categoryName:
          categoryNamesByIdentifier[professional.categoryIdentifier] ??
              _missingCategoryName,
      cityName: cityParts.first,
      stateCode: cityParts.length > 1 ? cityParts.last : '',
      shortDescription: professional.shortDescription,
      profileBadgeLabel: _mapProfileClassificationLabel(
        professional.profileClassification,
      ),
      availabilityStatus:
          _mapAvailabilityStatus(professional.availabilityStatus),
      recentActivityLabel: professional.phoneNumberVerified
          ? 'Telefone verificado'
          : professional.qualityGuarantee
              ? 'Garantia de qualidade'
              : null,
    );
  }

  ProfessionalProfile _mapProfessionalProfile(
    professional_models.Professional professional,
    Map<String, String> categoryNamesByIdentifier,
    Map<String, String> cityDisplayNamesByIdentifier,
    review_models.ProfessionalReviewProfile? reviewProfile,
    List<professional_models.ProfessionalPortfolioItem> portfolioItems,
  ) {
    final cityDisplayName =
        cityDisplayNamesByIdentifier[professional.cityIdentifier] ??
            _missingCityDisplayName;
    final cityParts = cityDisplayName.split(' - ');
    return ProfessionalProfile(
      professionalIdentifier: professional.professionalIdentifier,
      professionalName: professional.professionalName,
      categoryName:
          categoryNamesByIdentifier[professional.categoryIdentifier] ??
              _missingCategoryName,
      baseCityName: cityParts.first,
      baseStateCode: cityParts.length > 1 ? cityParts.last : '',
      attendedCityNames: [cityParts.first],
      aboutDescription:
          professional.serviceDescription ?? professional.shortDescription,
      serviceNames: [
        if (professional.shortDescription.trim().isNotEmpty)
          professional.shortDescription,
      ],
      usefulLinks: [
        if (professional.usefulLink != null) professional.usefulLink!,
      ],
      portfolioItemDescriptions: [
        ...portfolioItems.map((portfolioItem) {
          if (portfolioItem.description != null &&
              portfolioItem.description!.trim().isNotEmpty) {
            return '${portfolioItem.title}: ${portfolioItem.description}';
          }
          return portfolioItem.title;
        }),
        if (professional.portfolioDescription != null)
          professional.portfolioDescription!,
      ],
      profileCompletenessPercentage: professional.profileCompletenessPercentage,
      documentProvided: professional.documentProvided,
      phoneNumberVerified: professional.phoneNumberVerified,
      availabilityStatus:
          _mapAvailabilityStatus(professional.availabilityStatus),
      reviewSummary: _mapReviewSummary(reviewProfile),
    );
  }

  ProfessionalContactIntention _mapProfessionalContactIntention(
    contact_models.ContactIntention contactIntention,
  ) {
    return ProfessionalContactIntention(
      contactIntentionIdentifier: contactIntention.contactIntentIdentifier,
      professionalIdentifier: contactIntention.professionalIdentifier,
      professionalName: contactIntention.professionalName,
      whatsappContactLink: contactIntention.whatsappContactLink,
    );
  }

  PostContactFeedbackRequest _mapPendingPostContactFeedbackRequest(
    contact_models.PendingPostContactFeedbackRequestModel request,
  ) {
    return PostContactFeedbackRequest(
      contactIntentionIdentifier: request.contactIntentIdentifier,
      professionalIdentifier: request.professionalIdentifier,
      professionalName: request.professionalName,
      contactCreatedAt: request.contactCreatedAt,
    );
  }

  ProfessionalProfileReviewSummary? _mapReviewSummary(
    review_models.ProfessionalReviewProfile? reviewProfile,
  ) {
    if (reviewProfile == null) {
      return null;
    }
    return ProfessionalProfileReviewSummary(
      averageRating: reviewProfile.summary.averageRating,
      reviewCount: reviewProfile.summary.reviewCount,
      comments: reviewProfile.reviews
          .map(
            (review) => ProfessionalProfileReviewComment(
              professionalReviewIdentifier: review.professionalReviewIdentifier,
              starRating: review.starRating,
              publicAuthorDisplayName:
                  review.publicAuthorDisplayName ?? 'Usuario anonimo',
              comment: review.comment,
              anonymousToPublic: review.anonymousToPublic,
            ),
          )
          .toList(),
    );
  }

  ProfessionalAvailabilityStatus _mapAvailabilityStatus(String status) {
    return switch (status) {
      'AVAILABLE_TODAY' => ProfessionalAvailabilityStatus.availableToday,
      'AVAILABLE_THIS_WEEK' => ProfessionalAvailabilityStatus.availableThisWeek,
      'EMERGENCY_SERVICE' => ProfessionalAvailabilityStatus.emergencyService,
      'TEMPORARILY_UNAVAILABLE' =>
        ProfessionalAvailabilityStatus.temporarilyUnavailable,
      _ => ProfessionalAvailabilityStatus.acceptingNewClients,
    };
  }

  String _mapConversationOutcome(
    PostContactConversationOutcome? conversationOutcome,
  ) {
    return switch (conversationOutcome) {
      PostContactConversationOutcome.customerReachedProfessional =>
        'CUSTOMER_REACHED_PROFESSIONAL',
      PostContactConversationOutcome.customerDidNotReachProfessional =>
        'CUSTOMER_DID_NOT_REACH_PROFESSIONAL',
      null => 'CUSTOMER_DID_NOT_REACH_PROFESSIONAL',
    };
  }

  String _mapContactResponsiveness(
    PostContactResponsiveness? contactResponsiveness,
  ) {
    return switch (contactResponsiveness) {
      PostContactResponsiveness.fastResponse => 'FAST_RESPONSE',
      PostContactResponsiveness.slowResponse => 'SLOW_RESPONSE',
      PostContactResponsiveness.noResponse => 'NO_RESPONSE',
      null => 'NO_RESPONSE',
    };
  }

  String _mapServiceExecutionOutcome(
    PostContactServiceExecutionOutcome? serviceExecutionOutcome,
  ) {
    return switch (serviceExecutionOutcome) {
      PostContactServiceExecutionOutcome.servicePerformed =>
        'SERVICE_PERFORMED',
      PostContactServiceExecutionOutcome.serviceNotPerformed =>
        'SERVICE_NOT_PERFORMED',
      null => 'SERVICE_NOT_PERFORMED',
    };
  }

  String _mapReportReason(ProfessionalReportReason? reportReason) {
    return switch (reportReason) {
      ProfessionalReportReason.fraud => 'FRAUD',
      ProfessionalReportReason.harassment => 'HARASSMENT',
      ProfessionalReportReason.threat => 'THREAT',
      ProfessionalReportReason.fakeProfile => 'FAKE_PROFILE',
      ProfessionalReportReason.serviceNotPerformed => 'SERVICE_NOT_PERFORMED',
      ProfessionalReportReason.other => 'OTHER',
      null => 'OTHER',
    };
  }

  String _mapAvailabilityStatusToBackend(
    ProfessionalAvailabilityStatus availabilityStatus,
  ) {
    return switch (availabilityStatus) {
      ProfessionalAvailabilityStatus.availableToday => 'AVAILABLE_TODAY',
      ProfessionalAvailabilityStatus.availableThisWeek => 'AVAILABLE_THIS_WEEK',
      ProfessionalAvailabilityStatus.acceptingNewClients =>
        'ACCEPTING_NEW_CLIENTS',
      ProfessionalAvailabilityStatus.emergencyService => 'EMERGENCY_SERVICE',
      ProfessionalAvailabilityStatus.temporarilyUnavailable =>
        'TEMPORARILY_UNAVAILABLE',
    };
  }

  CustomerProfileState _mapCustomerProfile(
    customer_models.CustomerProfileModel customerProfile,
  ) {
    return CustomerProfileState(
      customerName: customerProfile.customerName,
      phoneNumber: _formatCustomerPhoneNumber(customerProfile.phoneNumber),
      mainCity: customerProfile.mainCity == null
          ? null
          : CustomerProfileCity(
              cityName: customerProfile.mainCity!.cityName,
              stateCode: customerProfile.mainCity!.stateCode,
            ),
      selectedCities: customerProfile.selectedCities
          .map(
            (selectedCity) => CustomerProfileCity(
              cityName: selectedCity.cityName,
              stateCode: selectedCity.stateCode,
            ),
          )
          .toList(),
      savedProfessionals: customerProfile.savedProfessionals
          .map(
            (savedProfessional) => CustomerSavedProfessional(
              professionalIdentifier: savedProfessional.professionalIdentifier,
              professionalName: savedProfessional.professionalName,
              categoryName: savedProfessional.categoryName,
              cityDisplayName:
                  '${savedProfessional.city.cityName} - ${savedProfessional.city.stateCode}',
            ),
          )
          .toList(),
      submittedReviews: customerProfile.submittedReviews
          .map(
            (submittedReview) => CustomerSubmittedReview(
              professionalName: submittedReview.professionalName,
              starRating: submittedReview.starRating,
              publiclyAnonymous: submittedReview.publiclyAnonymous,
              comment: submittedReview.comment,
            ),
          )
          .toList(),
      whatsappNotificationsEnabled:
          customerProfile.whatsappNotificationsEnabled,
      profilePersonalizationEnabled:
          customerProfile.profilePersonalizationEnabled,
    );
  }

  String _formatCustomerPhoneNumber(String phoneNumber) {
    final digitsOnlyPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnlyPhoneNumber.length != 11) {
      return phoneNumber;
    }
    return '(${digitsOnlyPhoneNumber.substring(0, 2)}) '
        '${digitsOnlyPhoneNumber.substring(2, 3)} '
        '${digitsOnlyPhoneNumber.substring(3, 7)}-'
        '${digitsOnlyPhoneNumber.substring(7)}';
  }

  AdminService _createAdministrativeService() {
    if (!administrativeConsoleAvailable) {
      throw const AuthorizationException(
        message: 'Console administrativo indisponivel sem token interno.',
      );
    }
    return AdminService(
      httpClient: _administrativeHttpClient ??
          ApiClient(
            bearerToken: _administrativeAccessToken,
          ),
    );
  }

  Future<AdministrativeConsoleState> _reloadAdministrativeConsoleAfterMutation(
    String statusMessage,
  ) async {
    final loadedState = await loadAdministrativeConsole();
    return loadedState.copyWith(statusMessage: statusMessage);
  }

  AdministrativeConsoleState _mapAdministrativeConsoleState({
    required List<admin_models.AdministrativeProfessionalModel>
        administrativeProfessionals,
    required List<admin_models.AdministrativeProfessionalReportModel>
        administrativeReports,
    required List<admin_models.AdministrativeReviewAnalysisRequestModel>
        administrativeReviewAnalysisRequests,
    required admin_models.AdministrativeMetricsModel administrativeMetrics,
    required admin_models.FunctionalMetricsModel functionalMetrics,
    required List<ServiceCategory> categories,
    required List<ServiceCity> cities,
    required String statusMessage,
  }) {
    final categoryNamesByIdentifier = {
      for (final category in categories)
        category.categoryIdentifier: category.categoryName,
    };
    final cityDisplayNamesByIdentifier = {
      for (final city in cities) city.cityIdentifier: city.displayName,
    };
    final professionalNamesByIdentifier = {
      for (final professional in administrativeProfessionals)
        professional.professionalIdentifier: professional.professionalName,
    };

    return AdministrativeConsoleState(
      statusMessage: statusMessage,
      professionals: administrativeProfessionals
          .map(
            (professional) => AdministrativeProfessionalItem(
              professionalIdentifier: professional.professionalIdentifier,
              professionalName: professional.professionalName,
              cityDisplayName:
                  cityDisplayNamesByIdentifier[professional.cityIdentifier] ??
                      _unmappedCityLabel,
              categoryName:
                  categoryNamesByIdentifier[professional.categoryIdentifier] ??
                      _unmappedCategoryLabel,
              profileClassification: _mapProfileClassificationLabel(
                professional.profileClassification,
              ),
              availabilityLabel:
                  _mapAvailabilityStatus(professional.availabilityStatus)
                      .badgeLabel,
              blocked: professional.blocked,
            ),
          )
          .toList(),
      professionalReports: administrativeReports
          .map(
            (report) => AdministrativeProfessionalReportItem(
              professionalReportIdentifier: report.professionalReportIdentifier,
              professionalIdentifier: report.professionalIdentifier,
              professionalName: professionalNamesByIdentifier[
                      report.professionalIdentifier] ??
                  _unmappedProfessionalLabel,
              reportReasonLabel: _mapReportReasonLabel(report.reportReason),
              seriousCase: report.seriousCase,
              moderationStatusLabel:
                  _mapModerationStatusLabel(report.moderationStatus),
              moderationDecisionLabel: report.moderationDecision == null
                  ? null
                  : _mapModerationDecisionLabel(report.moderationDecision!),
              moderationNotes: report.moderationNotes,
              createdAtLabel: _formatAdministrativeDate(report.createdAt),
            ),
          )
          .toList(),
      reviewAnalysisRequests: administrativeReviewAnalysisRequests
          .map(
            (request) => AdministrativeReviewAnalysisItem(
              reviewAnalysisRequestIdentifier:
                  request.reviewAnalysisRequestIdentifier,
              professionalReviewIdentifier:
                  request.professionalReviewIdentifier,
              professionalIdentifier: request.professionalIdentifier,
              professionalName: professionalNamesByIdentifier[
                      request.professionalIdentifier] ??
                  _unmappedProfessionalLabel,
              requestedByProfessionalIdentifier:
                  request.requestedByProfessionalIdentifier,
              moderationStatusLabel:
                  _mapModerationStatusLabel(request.moderationStatus),
              moderationDecisionLabel: request.moderationDecision == null
                  ? null
                  : _mapModerationDecisionLabel(request.moderationDecision!),
              moderationNotes: request.moderationNotes,
              createdAtLabel: _formatAdministrativeDate(request.createdAt),
            ),
          )
          .toList(),
      categoryNames:
          categories.map((category) => category.categoryName).toList()..sort(),
      administrativeMetrics: AdministrativeMetricsSummary(
        professionalCount: administrativeMetrics.professionalCount,
        blockedProfessionalCount:
            administrativeMetrics.blockedProfessionalCount,
        professionalReportCount: administrativeMetrics.professionalReportCount,
        reviewAnalysisRequestCount:
            administrativeMetrics.reviewAnalysisRequestCount,
        serviceCategoryCount: administrativeMetrics.serviceCategoryCount,
      ),
      functionalMetrics: AdministrativeFunctionalMetricsSummary(
        searchCount: functionalMetrics.searchCount,
        searchWithoutResultCount: functionalMetrics.searchWithoutResultCount,
        contactCount: functionalMetrics.contactCount,
        postContactFeedbackCount: functionalMetrics.postContactFeedbackCount,
        reviewCount: functionalMetrics.reviewCount,
        anonymousReviewCount: functionalMetrics.anonymousReviewCount,
        rankingAlgorithmEnabled: functionalMetrics.rankingAlgorithmEnabled,
        topSearchCategories: functionalMetrics.searchesByCategory
            .map(
              (metric) => AdministrativeLabeledMetric(
                label: categoryNamesByIdentifier[metric.metricIdentifier] ??
                    _unmappedCategoryLabel,
                value: metric.contactCount.toString(),
              ),
            )
            .toList(),
        topSearchCities: functionalMetrics.searchesByCity
            .map(
              (metric) => AdministrativeLabeledMetric(
                label: cityDisplayNamesByIdentifier[metric.metricIdentifier] ??
                    _unmappedCityLabel,
                value: metric.contactCount.toString(),
              ),
            )
            .toList(),
        topContactProfessionals: functionalMetrics.contactsByProfessional
            .map(
              (metric) => AdministrativeLabeledMetric(
                label: professionalNamesByIdentifier[metric.metricIdentifier] ??
                    _unmappedProfessionalLabel,
                value: metric.contactCount.toString(),
              ),
            )
            .toList(),
        responsivenessSignals: functionalMetrics.responsivenessSignals
            .map(
              (metric) => AdministrativeLabeledMetric(
                label: _mapResponsivenessLabel(metric.contactResponsiveness),
                value: metric.feedbackCount.toString(),
              ),
            )
            .toList(),
        reputationSignals: functionalMetrics.reputationSignals
            .map(
              (metric) => AdministrativeLabeledMetric(
                label: professionalNamesByIdentifier[
                        metric.professionalIdentifier] ??
                    _unmappedProfessionalLabel,
                value:
                    '${metric.averageRating.toStringAsFixed(1)} (${metric.reviewCount})',
              ),
            )
            .toList(),
        averageRating: functionalMetrics.reputationSummary.averageRating,
        respondedContactPercentage:
            functionalMetrics.responsivenessSummary.respondedContactPercentage,
      ),
    );
  }

  String _mapModerationStatusLabel(String moderationStatus) {
    return switch (moderationStatus) {
      'PENDING' => 'Pendente',
      'IN_REVIEW' => 'Em revisao',
      'RESOLVED' => 'Resolvido',
      'ACTION_REQUIRED' => 'Acao necessaria',
      _ => 'Status não mapeado',
    };
  }

  String _mapModerationDecisionLabel(String moderationDecision) {
    return switch (moderationDecision) {
      'KEEP_AS_IS' => 'Manter como esta',
      'HIDE_FROM_PUBLIC' => 'Ocultar publicamente',
      'RESOLVE_CASE' => 'Resolver caso',
      'REQUIRE_ADDITIONAL_ACTION' => 'Exigir acao adicional',
      _ => 'Decisao não mapeada',
    };
  }

  String _mapReportReasonLabel(String reportReason) {
    return switch (reportReason) {
      'FRAUD' => 'Fraude',
      'HARASSMENT' => 'Assedio',
      'THREAT' => 'Ameaca',
      'FAKE_PROFILE' => 'Perfil falso',
      'SERVICE_NOT_PERFORMED' => 'Servico nao realizado',
      'OTHER' => 'Outro',
      _ => 'Motivo não mapeado',
    };
  }

  String _mapResponsivenessLabel(String contactResponsiveness) {
    return switch (contactResponsiveness) {
      'FAST_RESPONSE' => 'Resposta rapida',
      'SLOW_RESPONSE' => 'Resposta lenta',
      'NO_RESPONSE' => 'Sem resposta',
      _ => 'Sinal não mapeado',
    };
  }

  String _mapProfileClassificationLabel(String profileClassification) {
    final trimmedClassification = profileClassification.trim();
    final normalizedClassification =
        trimmedClassification.toUpperCase().replaceAll(' ', '_');
    return switch (normalizedClassification) {
      'COMPLETE' ||
      'COMPLETE_PROFILE' ||
      'PERFIL_COMPLETO' =>
        'Perfil completo',
      'BASIC' ||
      'BASIC_PROFILE' ||
      'PERFIL_BASICO' ||
      'PERFIL_BÁSICO' =>
        'Perfil básico',
      'INCOMPLETE' ||
      'INCOMPLETE_PROFILE' ||
      'PERFIL_INCOMPLETO' =>
        'Perfil incompleto',
      _ => trimmedClassification.isEmpty
          ? 'Perfil não informado'
          : _looksLikeTechnicalLabel(trimmedClassification)
              ? 'Perfil não informado'
              : trimmedClassification,
    };
  }

  bool _looksLikeTechnicalLabel(String value) {
    return value.contains('_') || RegExp(r'^[A-Z0-9]+$').hasMatch(value);
  }

  String _formatAdministrativeDate(DateTime dateTime) {
    final normalizedDateTime = dateTime.toLocal();
    final day = normalizedDateTime.day.toString().padLeft(2, '0');
    final month = normalizedDateTime.month.toString().padLeft(2, '0');
    final year = normalizedDateTime.year;
    final hour = normalizedDateTime.hour.toString().padLeft(2, '0');
    final minute = normalizedDateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class WorkLinkPreviewGateway implements WorkLinkApplicationGateway {
  const WorkLinkPreviewGateway();

  @override
  bool get administrativeConsoleAvailable => true;

  @override
  WorkLinkHomeData get initialHomeData => previewHomeData;

  @override
  Future<WorkLinkHomeData> loadHomeData() async {
    return previewHomeData;
  }

  @override
  Future<void> requestCustomerAuthenticationCode(
    String phoneNumber, {
    CustomerAuthenticationVerificationChannel verificationChannel =
        CustomerAuthenticationVerificationChannel.sms,
    String? emailAddress,
  }) async {}

  @override
  Future<void> confirmCustomerAuthenticationCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    if (verificationCode != '1234') {
      throw StateError('Codigo de preview invalido.');
    }
  }

  @override
  Future<void> registerProfessional(
    ProfessionalRegistrationDraft draft,
    WorkLinkHomeData homeData,
  ) async {}

  @override
  Future<CustomerProfileState> loadCustomerProfile() async {
    return const CustomerProfileState(
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
          comment: 'Atendimento rapido e organizado.',
        ),
      ],
    );
  }

  @override
  Future<CustomerProfileState> updateCustomerProfilePreferences({
    required bool whatsappNotificationsEnabled,
    required bool profilePersonalizationEnabled,
  }) async {
    final currentProfile = await loadCustomerProfile();
    return currentProfile.copyWith(
      whatsappNotificationsEnabled: whatsappNotificationsEnabled,
      profilePersonalizationEnabled: profilePersonalizationEnabled,
    );
  }

  @override
  Future<CustomerProfileState> saveProfessionalForCustomer(
    String professionalIdentifier,
  ) async {
    return loadCustomerProfile();
  }

  @override
  Future<CustomerProfileState> removeSavedProfessionalForCustomer(
    String professionalIdentifier,
  ) async {
    return loadCustomerProfile();
  }

  @override
  Future<List<PostContactFeedbackRequest>>
      loadPendingPostContactFeedbackRequests() async {
    return const [];
  }

  @override
  Future<void> dismissPostContactFeedbackRequest(
    String contactIntentionIdentifier,
  ) async {}

  @override
  Future<void> requestProfessionalPhoneVerification(
    String professionalIdentifier,
  ) async {}

  @override
  Future<void> confirmProfessionalPhoneVerification({
    required String professionalIdentifier,
    required String verificationCode,
  }) async {
    if (verificationCode != '123456') {
      throw StateError('Codigo de verificacao profissional invalido.');
    }
  }

  @override
  Future<void> addProfessionalPortfolioItem({
    required String professionalIdentifier,
    required String fileIdentifier,
    required String title,
    String? description,
    int displayOrder = 0,
  }) async {}

  @override
  Future<ProfessionalContactIntention> startProfessionalContact(
    String professionalIdentifier,
  ) async {
    final profile = previewHomeData.professionalProfiles.firstWhere(
      (professionalProfile) =>
          professionalProfile.professionalIdentifier == professionalIdentifier,
    );
    return ProfessionalContactIntention(
      contactIntentionIdentifier: 'contact-intention-$professionalIdentifier',
      professionalIdentifier: professionalIdentifier,
      professionalName: profile.professionalName,
      whatsappContactLink: 'https://wa.me/51999999999',
    );
  }

  @override
  Future<void> submitPostContactFeedback(
    String contactIntentionIdentifier,
    PostContactFeedbackState feedbackState,
  ) async {}

  @override
  Future<void> submitProfessionalReview(
    String contactIntentionIdentifier,
    ProfessionalReviewState reviewState,
  ) async {}

  @override
  Future<void> submitProfessionalReport(
    String professionalIdentifier,
    ProfessionalReportState reportState,
  ) async {}

  @override
  Future<void> requestProfessionalReviewAnalysis(
    String professionalReviewIdentifier,
  ) async {}

  @override
  Future<AdministrativeConsoleState> loadAdministrativeConsole() async {
    return const AdministrativeConsoleState(
      statusMessage: 'Console administrativo de preview carregado.',
      professionals: [
        AdministrativeProfessionalItem(
          professionalIdentifier: 'maria-eletricista',
          professionalName: 'Maria Eletricista',
          cityDisplayName: 'Canoas - RS',
          categoryName: 'Eletricista',
          profileClassification: 'Perfil completo',
          availabilityLabel: 'Disponivel esta semana',
          blocked: false,
        ),
        AdministrativeProfessionalItem(
          professionalIdentifier: 'ana-pintora',
          professionalName: 'Ana Pintora',
          cityDisplayName: 'Porto Alegre - RS',
          categoryName: 'Pintora',
          profileClassification: 'Perfil basico',
          availabilityLabel: 'Aceitando novos clientes',
          blocked: true,
        ),
      ],
      professionalReports: [
        AdministrativeProfessionalReportItem(
          professionalReportIdentifier: 'report-1',
          professionalIdentifier: 'ana-pintora',
          professionalName: 'Ana Pintora',
          reportReasonLabel: 'Perfil falso',
          seriousCase: false,
          moderationStatusLabel: 'Pendente',
          createdAtLabel: '15/05/2026 10:00',
        ),
      ],
      reviewAnalysisRequests: [
        AdministrativeReviewAnalysisItem(
          reviewAnalysisRequestIdentifier: 'review-analysis-1',
          professionalReviewIdentifier: 'review-1',
          professionalIdentifier: 'maria-eletricista',
          professionalName: 'Maria Eletricista',
          requestedByProfessionalIdentifier: 'maria-eletricista',
          moderationStatusLabel: 'Pendente',
          createdAtLabel: '15/05/2026 11:30',
        ),
      ],
      categoryNames: ['Eletricista', 'Pintora'],
      administrativeMetrics: AdministrativeMetricsSummary(
        professionalCount: 2,
        blockedProfessionalCount: 1,
        professionalReportCount: 1,
        reviewAnalysisRequestCount: 1,
        serviceCategoryCount: 2,
      ),
      functionalMetrics: AdministrativeFunctionalMetricsSummary(
        searchCount: 12,
        searchWithoutResultCount: 2,
        contactCount: 5,
        postContactFeedbackCount: 3,
        reviewCount: 2,
        anonymousReviewCount: 1,
        averageRating: 4.5,
        respondedContactPercentage: 80,
        topSearchCategories: [
          AdministrativeLabeledMetric(label: 'Eletricista', value: '7'),
          AdministrativeLabeledMetric(label: 'Pintora', value: '5'),
        ],
        topSearchCities: [
          AdministrativeLabeledMetric(label: 'Canoas - RS', value: '6'),
          AdministrativeLabeledMetric(label: 'Porto Alegre - RS', value: '4'),
        ],
        topContactProfessionals: [
          AdministrativeLabeledMetric(
            label: 'Maria Eletricista',
            value: '3',
          ),
        ],
        responsivenessSignals: [
          AdministrativeLabeledMetric(label: 'Resposta rapida', value: '2'),
        ],
        reputationSignals: [
          AdministrativeLabeledMetric(
            label: 'Maria Eletricista',
            value: '4.5 (2)',
          ),
        ],
      ),
    );
  }

  @override
  Future<AdministrativeConsoleState> blockAdministrativeProfessional(
    String professionalIdentifier,
  ) async {
    return loadAdministrativeConsole();
  }

  @override
  Future<AdministrativeConsoleState> unblockAdministrativeProfessional(
    String professionalIdentifier,
  ) async {
    return loadAdministrativeConsole();
  }

  @override
  Future<AdministrativeConsoleState> approveAdministrativeProfessionalReport(
    String professionalReportIdentifier,
  ) async {
    return loadAdministrativeConsole();
  }

  @override
  Future<AdministrativeConsoleState> escalateAdministrativeProfessionalReport(
    String professionalReportIdentifier,
  ) async {
    return loadAdministrativeConsole();
  }

  @override
  Future<AdministrativeConsoleState> keepAdministrativeReviewPublic(
    String reviewAnalysisRequestIdentifier,
  ) async {
    return loadAdministrativeConsole();
  }

  @override
  Future<AdministrativeConsoleState> hideAdministrativeReviewFromPublic(
    String reviewAnalysisRequestIdentifier,
  ) async {
    return loadAdministrativeConsole();
  }

  @override
  Future<AdministrativeConsoleState> registerAdministrativeCategory(
    String categoryName,
  ) async {
    return loadAdministrativeConsole();
  }
}

const previewHomeData = WorkLinkHomeData(
  discoveryProfessionals: [
    DiscoveryProfessional(
      professionalIdentifier: 'ana-costa-energia-residencial',
      professionalName: 'Ana Costa Energia Residencial',
      categoryName: 'Eletricista',
      cityName: 'Charqueadas',
      stateCode: 'RS',
      shortDescription:
          'Instalações, disjuntores e manutenção elétrica residencial.',
      profileBadgeLabel: 'Perfil completo',
      availabilityStatus: ProfessionalAvailabilityStatus.availableToday,
      recentActivityLabel: 'Telefone verificado',
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'bruno-silveira-hidraulica',
      professionalName: 'Bruno Silveira Hidráulica',
      categoryName: 'Encanador',
      cityName: 'São Jerônimo',
      stateCode: 'RS',
      shortDescription:
          'Consertos de vazamentos, caixas d agua e encanamentos.',
      availabilityStatus: ProfessionalAvailabilityStatus.availableThisWeek,
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'carla-mendes-limpeza',
      professionalName: 'Carla Mendes Limpeza',
      categoryName: 'Diarista',
      cityName: 'Arroio dos Ratos',
      stateCode: 'RS',
      shortDescription:
          'Diarista para residências, pequenos escritórios e pós-obra leve.',
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'diego-almeida-reformas',
      professionalName: 'Diego Almeida Reformas',
      categoryName: 'Pedreiro',
      cityName: 'Triunfo',
      stateCode: 'RS',
      shortDescription:
          'Reformas pequenas, alvenaria, reboco, pisos e reparos.',
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'gisele-martins-pinturas',
      professionalName: 'Gisele Martins Pinturas',
      categoryName: 'Pintor',
      cityName: 'Eldorado do Sul',
      stateCode: 'RS',
      shortDescription:
          'Pintura interna, acabamento e pequenos reparos residenciais.',
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'henrique-vargas-jardins',
      professionalName: 'Henrique Vargas Jardins',
      categoryName: 'Jardineiro',
      cityName: 'General Câmara',
      stateCode: 'RS',
      shortDescription: 'Poda, limpeza de pátios e manutenção de jardins.',
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'isabela-torres-obras-leves',
      professionalName: 'Isabela Torres Obras Leves',
      categoryName: 'Pedreiro',
      cityName: 'Butiá',
      stateCode: 'RS',
      shortDescription:
          'Reparos de alvenaria, pisos e pequenas reformas residenciais.',
    ),
  ],
  professionalProfiles: [
    ProfessionalProfile(
      professionalIdentifier: 'ana-costa-energia-residencial',
      professionalName: 'Ana Costa Energia Residencial',
      categoryName: 'Eletricista',
      baseCityName: 'Charqueadas',
      baseStateCode: 'RS',
      attendedCityNames: ['Charqueadas', 'São Jerônimo', 'Triunfo'],
      aboutDescription:
          'Atendimento residencial com foco em instalações, reparos e manutenção preventiva na região carbonífera.',
      serviceNames: ['Instalações', 'Manutenção', 'Emergências elétricas'],
      usefulLinks: ['https://worklink.example/ana-costa-energia-residencial'],
      portfolioItemDescriptions: [
        'Instalação de luminárias',
        'Quadro elétrico residencial',
      ],
      profileCompletenessPercentage: 100,
      phoneNumberVerified: true,
      documentProvided: true,
      availabilityStatus: ProfessionalAvailabilityStatus.availableThisWeek,
      reviewSummary: ProfessionalProfileReviewSummary(
        averageRating: 4.5,
        reviewCount: 2,
        comments: [
          ProfessionalProfileReviewComment(
            professionalReviewIdentifier: 'review-ana-costa-1',
            starRating: 5,
            publicAuthorDisplayName: 'Usuario anonimo',
            comment: 'Atendimento rápido e organizado.',
          ),
        ],
      ),
    ),
    ProfessionalProfile(
      professionalIdentifier: 'bruno-silveira-hidraulica',
      professionalName: 'Bruno Silveira Hidráulica',
      categoryName: 'Encanador',
      baseCityName: 'São Jerônimo',
      baseStateCode: 'RS',
      attendedCityNames: ['São Jerônimo', 'Charqueadas'],
      aboutDescription:
          'Consertos de vazamentos, caixas d agua, torneiras e encanamentos.',
      serviceNames: ['Vazamentos', 'Caixas d agua', 'Torneiras'],
    ),
    ProfessionalProfile(
      professionalIdentifier: 'carla-mendes-limpeza',
      professionalName: 'Carla Mendes Limpeza',
      categoryName: 'Diarista',
      baseCityName: 'Arroio dos Ratos',
      baseStateCode: 'RS',
      attendedCityNames: ['Arroio dos Ratos', 'Butiá'],
      aboutDescription:
          'Diarista para residências, pequenos escritórios e pós-obra leve.',
      serviceNames: ['Limpeza residencial', 'Pós-obra leve'],
    ),
    ProfessionalProfile(
      professionalIdentifier: 'diego-almeida-reformas',
      professionalName: 'Diego Almeida Reformas',
      categoryName: 'Pedreiro',
      baseCityName: 'Triunfo',
      baseStateCode: 'RS',
      attendedCityNames: ['Triunfo', 'General Câmara'],
      aboutDescription:
          'Reformas pequenas, alvenaria, reboco, pisos e reparos.',
      serviceNames: ['Alvenaria', 'Reboco', 'Pisos'],
    ),
    ProfessionalProfile(
      professionalIdentifier: 'gisele-martins-pinturas',
      professionalName: 'Gisele Martins Pinturas',
      categoryName: 'Pintor',
      baseCityName: 'Eldorado do Sul',
      baseStateCode: 'RS',
      attendedCityNames: ['Eldorado do Sul', 'Charqueadas'],
      aboutDescription:
          'Pintura interna, acabamento e pequenos reparos residenciais.',
      serviceNames: ['Pintura interna', 'Acabamento'],
    ),
    ProfessionalProfile(
      professionalIdentifier: 'henrique-vargas-jardins',
      professionalName: 'Henrique Vargas Jardins',
      categoryName: 'Jardineiro',
      baseCityName: 'General Câmara',
      baseStateCode: 'RS',
      attendedCityNames: ['General Câmara', 'Triunfo'],
      aboutDescription: 'Poda, limpeza de pátios e manutenção de jardins.',
      serviceNames: ['Poda', 'Limpeza de pátios', 'Jardinagem'],
    ),
    ProfessionalProfile(
      professionalIdentifier: 'isabela-torres-obras-leves',
      professionalName: 'Isabela Torres Obras Leves',
      categoryName: 'Pedreiro',
      baseCityName: 'Butiá',
      baseStateCode: 'RS',
      attendedCityNames: ['Butiá', 'Arroio dos Ratos'],
      aboutDescription:
          'Reparos de alvenaria, pisos e pequenas reformas residenciais.',
      serviceNames: ['Reparos', 'Pisos', 'Pequenas reformas'],
    ),
  ],
  professionalRegistrationCategoryNames: [
    'Eletricista',
    'Encanador',
    'Diarista',
    'Pedreiro',
    'Pintor',
    'Jardineiro',
  ],
  professionalRegistrationCityDisplayNames: [
    'Charqueadas - RS',
    'São Jerônimo - RS',
    'Triunfo - RS',
    'Arroio dos Ratos - RS',
    'Eldorado do Sul - RS',
    'General Câmara - RS',
    'Butiá - RS',
  ],
  categoryIdentifiersByName: {
    'Eletricista': 'category-eletricista',
    'Encanador': 'category-encanador',
    'Diarista': 'category-diarista',
    'Pedreiro': 'category-pedreiro',
    'Pintor': 'category-pintor',
    'Jardineiro': 'category-jardineiro',
  },
  cityIdentifiersByDisplayName: {
    'Charqueadas - RS': 'city-charqueadas-rs',
    'São Jerônimo - RS': 'city-sao-jeronimo-rs',
    'Triunfo - RS': 'city-triunfo-rs',
    'Arroio dos Ratos - RS': 'city-arroio-dos-ratos-rs',
    'Eldorado do Sul - RS': 'city-eldorado-do-sul-rs',
    'General Câmara - RS': 'city-general-camara-rs',
    'Butiá - RS': 'city-butia-rs',
  },
);
