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
import '../services/api_client.dart';
import '../services/authentication_service.dart';
import '../services/catalog_service.dart';
import '../services/contact_service.dart';
import '../services/customer_service.dart';
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
  WorkLinkHomeData? get initialHomeData;

  Future<WorkLinkHomeData> loadHomeData();

  Future<void> requestCustomerAuthenticationCode(String phoneNumber);

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
}

class WorkLinkBackendGateway implements WorkLinkApplicationGateway {
  WorkLinkBackendGateway({WorkLinkHttpClient? httpClient})
      : _httpClient = httpClient ?? ApiClient();

  final WorkLinkHttpClient _httpClient;

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
  Future<void> requestCustomerAuthenticationCode(String phoneNumber) async {
    final authenticationService =
        AuthenticationService(httpClient: _httpClient);
    await authenticationService.requestAuthenticationOtp(phoneNumber);
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
    final customerProfile = await customerService.updateCustomerProfilePreferences(
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
    final requests = await contactService.listPendingPostContactFeedbackRequests();
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

  DiscoveryProfessional _mapDiscoveryProfessional(
    professional_models.Professional professional,
    Map<String, String> categoryNamesByIdentifier,
    Map<String, String> cityDisplayNamesByIdentifier,
  ) {
    final cityDisplayName =
        cityDisplayNamesByIdentifier[professional.cityIdentifier] ??
            professional.cityIdentifier;
    final cityParts = cityDisplayName.split(' - ');
    return DiscoveryProfessional(
      professionalIdentifier: professional.professionalIdentifier,
      professionalName: professional.professionalName,
      categoryName:
          categoryNamesByIdentifier[professional.categoryIdentifier] ??
              professional.categoryIdentifier,
      cityName: cityParts.first,
      stateCode: cityParts.length > 1 ? cityParts.last : '',
      shortDescription: professional.shortDescription,
      profileBadgeLabel: professional.profileClassification,
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
            professional.cityIdentifier;
    final cityParts = cityDisplayName.split(' - ');
    return ProfessionalProfile(
      professionalIdentifier: professional.professionalIdentifier,
      professionalName: professional.professionalName,
      categoryName:
          categoryNamesByIdentifier[professional.categoryIdentifier] ??
              professional.categoryIdentifier,
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
}

class WorkLinkPreviewGateway implements WorkLinkApplicationGateway {
  const WorkLinkPreviewGateway();

  @override
  WorkLinkHomeData get initialHomeData => previewHomeData;

  @override
  Future<WorkLinkHomeData> loadHomeData() async {
    return previewHomeData;
  }

  @override
  Future<void> requestCustomerAuthenticationCode(String phoneNumber) async {}

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
}

const previewHomeData = WorkLinkHomeData(
  discoveryProfessionals: [
    DiscoveryProfessional(
      professionalIdentifier: 'maria-eletricista',
      professionalName: 'Maria Eletricista',
      categoryName: 'Eletricista',
      cityName: 'Canoas',
      stateCode: 'RS',
      shortDescription: 'Atendimento residencial.',
      profileBadgeLabel: 'Perfil básico',
      availabilityStatus: ProfessionalAvailabilityStatus.availableToday,
      recentActivityLabel: 'Ativo recentemente',
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'ana-pintora',
      professionalName: 'Ana Pintora',
      categoryName: 'Pintora',
      cityName: 'Porto Alegre',
      stateCode: 'RS',
      shortDescription: 'Pintura interna e acabamento.',
    ),
  ],
  professionalProfiles: [
    ProfessionalProfile(
      professionalIdentifier: 'maria-eletricista',
      professionalName: 'Maria Eletricista',
      categoryName: 'Eletricista',
      baseCityName: 'Canoas',
      baseStateCode: 'RS',
      attendedCityNames: ['Canoas', 'Esteio', 'Porto Alegre'],
      aboutDescription:
          'Atendimento residencial com foco em instalações, reparos e manutenção preventiva.',
      serviceNames: ['Instalações', 'Manutenção', 'Emergências'],
      usefulLinks: ['https://worklink.example/maria-eletricista'],
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
            professionalReviewIdentifier: 'review-maria-1',
            starRating: 5,
            publicAuthorDisplayName: 'Usuario anonimo',
            comment: 'Atendimento rapido e organizado.',
          ),
        ],
      ),
    ),
    ProfessionalProfile(
      professionalIdentifier: 'ana-pintora',
      professionalName: 'Ana Pintora',
      categoryName: 'Pintora',
      baseCityName: 'Porto Alegre',
      baseStateCode: 'RS',
      attendedCityNames: ['Porto Alegre'],
      aboutDescription:
          'Pintura interna e acabamento para reformas residenciais.',
      serviceNames: ['Pintura interna', 'Acabamento'],
    ),
  ],
  professionalRegistrationCategoryNames: ['Eletricista', 'Pintora'],
  professionalRegistrationCityDisplayNames: [
    'Canoas - RS',
    'Porto Alegre - RS',
    'Charqueadas - RS',
  ],
  categoryIdentifiersByName: {
    'Eletricista': 'category-eletricista',
    'Pintora': 'category-pintora',
  },
  cityIdentifiersByDisplayName: {
    'Canoas - RS': 'city-canoas-rs',
    'Porto Alegre - RS': 'city-porto-alegre-rs',
    'Charqueadas - RS': 'city-charqueadas-rs',
  },
);
