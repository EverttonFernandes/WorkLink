import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/app/worklink_application_gateway.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_state.dart';
import 'package:worklink_mobile/features/professional_availability/professional_availability_status.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_draft.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_state.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_state.dart';

import '../services/fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;
  late WorkLinkBackendGateway gateway;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
    gateway = WorkLinkBackendGateway(httpClient: httpClient);
  });

  test(
      'GIVEN contratos publicos do backend WHEN carregar home THEN deve mapear telas principais',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/categories'] = [
      {
        'categoryIdentifier': 'category-1',
        'categoryName': 'Eletricista',
        'categorySlug': 'eletricista',
      },
    ];
    httpClient.listResponses['/api/v1/cities'] = [
      {
        'cityIdentifier': 'city-1',
        'cityName': 'Canoas',
        'stateCode': 'RS',
        'citySlug': 'canoas-rs',
      },
    ];
    httpClient.listResponses['/api/v1/professionals'] = [
      professionalJson(),
    ];
    httpClient.objectResponses[
            '/api/v1/professional-reviews/professionals/professional-1'] =
        reviewProfileJson();
    httpClient.listResponses[
        '/api/v1/professionals/professional-1/portfolio-items'] = [
      portfolioItemJson(),
    ];

    // WHEN
    final homeData = await gateway.loadHomeData();

    // THEN
    expect(homeData.discoveryProfessionals.single.professionalName, 'Maria');
    expect(homeData.discoveryProfessionals.single.categoryName, 'Eletricista');
    expect(
      homeData.discoveryProfessionals.single.cityDisplayName,
      'Canoas - RS',
    );
    expect(homeData.professionalProfiles.single.reviewSummary!.reviewCount, 1);
    expect(homeData.professionalProfiles.single.portfolioItemDescriptions, [
      'Quadro eletrico residencial: Instalacao concluida.',
      'Quadros eletricos.',
    ]);
    expect(homeData.professionalRegistrationCategoryNames, ['Eletricista']);
    expect(homeData.professionalRegistrationCityDisplayNames, ['Canoas - RS']);
  });

  test(
      'GIVEN profissionais com dados opcionais WHEN carregar home THEN deve aplicar fallbacks previsiveis',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/categories'] = [
      {
        'categoryIdentifier': 'category-1',
        'categoryName': 'Eletricista',
        'categorySlug': 'eletricista',
      },
    ];
    httpClient.listResponses['/api/v1/cities'] = [
      {
        'cityIdentifier': 'city-1',
        'cityName': 'Canoas',
        'stateCode': 'RS',
        'citySlug': 'canoas-rs',
      },
    ];
    httpClient.listResponses['/api/v1/professionals'] = [
      professionalJson(
        professionalIdentifier: 'professional-week',
        availabilityStatus: 'AVAILABLE_THIS_WEEK',
        qualityGuarantee: false,
      ),
      professionalJson(
        professionalIdentifier: 'professional-emergency',
        availabilityStatus: 'EMERGENCY_SERVICE',
        usefulLink: null,
        portfolioDescription: null,
        serviceDescription: null,
      ),
      professionalJson(
        professionalIdentifier: 'professional-unavailable',
        availabilityStatus: 'TEMPORARILY_UNAVAILABLE',
        categoryIdentifier: 'category-not-found',
        cityIdentifier: 'city-not-found',
      ),
      professionalJson(
        professionalIdentifier: 'professional-default',
        availabilityStatus: 'UNKNOWN_STATUS',
      ),
    ];

    // WHEN
    final homeData = await gateway.loadHomeData();

    // THEN
    expect(
      homeData.discoveryProfessionals[0].availabilityStatus,
      ProfessionalAvailabilityStatus.availableThisWeek,
    );
    expect(homeData.discoveryProfessionals[0].recentActivityLabel, isNull);
    expect(
      homeData.discoveryProfessionals[1].availabilityStatus,
      ProfessionalAvailabilityStatus.emergencyService,
    );
    expect(
      homeData.professionalProfiles[1].aboutDescription,
      'Atendimento residencial.',
    );
    expect(homeData.professionalProfiles[1].usefulLinks, isEmpty);
    expect(homeData.professionalProfiles[1].portfolioItemDescriptions, isEmpty);
    expect(
      homeData.discoveryProfessionals[2].availabilityStatus,
      ProfessionalAvailabilityStatus.temporarilyUnavailable,
    );
    expect(
      homeData.discoveryProfessionals[2].categoryName,
      'category-not-found',
    );
    expect(homeData.discoveryProfessionals[2].cityName, 'city-not-found');
    expect(homeData.discoveryProfessionals[2].stateCode, '');
    expect(
      homeData.discoveryProfessionals[3].availabilityStatus,
      ProfessionalAvailabilityStatus.acceptingNewClients,
    );
  });

  test(
      'GIVEN profissional com telefone verificado WHEN carregar home THEN deve refletir sinal de confianca nas telas',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/categories'] = [
      {
        'categoryIdentifier': 'category-1',
        'categoryName': 'Eletricista',
        'categorySlug': 'eletricista',
      },
    ];
    httpClient.listResponses['/api/v1/cities'] = [
      {
        'cityIdentifier': 'city-1',
        'cityName': 'Canoas',
        'stateCode': 'RS',
        'citySlug': 'canoas-rs',
      },
    ];
    httpClient.listResponses['/api/v1/professionals'] = [
      professionalJson(phoneNumberVerified: true),
    ];

    // WHEN
    final homeData = await gateway.loadHomeData();

    // THEN
    expect(
      homeData.discoveryProfessionals.single.recentActivityLabel,
      'Telefone verificado',
    );
    expect(homeData.professionalProfiles.single.phoneNumberVerified, isTrue);
  });

  test(
      'GIVEN profissional escolhido WHEN iniciar contato THEN deve mapear intencao para a UI',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/contact-intentions'] = {
      'contactIntentIdentifier': 'contact-1',
      'professionalIdentifier': 'professional-1',
      'professionalName': 'Maria',
      'whatsappContactLink': 'https://wa.me/5551999999999',
      'createdAt': '2026-05-13T10:00:00Z',
      'externalNegotiationNotice': 'Aviso externo.',
      'noServiceGuaranteeNotice': 'Aviso garantia.',
    };

    // WHEN
    final contact = await gateway.startProfessionalContact('professional-1');

    // THEN
    expect(contact.contactIntentionIdentifier, 'contact-1');
    expect(httpClient.requests.single.data, {
      'professionalIdentifier': 'professional-1',
    });
  });

  test(
      'GIVEN telefone cliente WHEN autenticar THEN deve solicitar OTP e armazenar token Bearer',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/authentication/otp/request'] = {
      'message': 'Codigo enviado.',
      'expiresAt': '2026-05-13T10:05:00Z',
    };
    httpClient.objectResponses['/api/v1/authentication/otp/verify'] = {
      'customerIdentifier': 'customer-1',
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'accessTokenExpiresAt': '2026-05-13T10:30:00Z',
      'refreshTokenExpiresAt': '2026-06-13T10:00:00Z',
    };

    // WHEN
    await gateway.requestCustomerAuthenticationCode('51999991234');
    await gateway.confirmCustomerAuthenticationCode(
      phoneNumber: '51999991234',
      verificationCode: '123456',
    );

    // THEN
    expect(
      httpClient.requests.map((request) => request.path),
      [
        '/api/v1/authentication/otp/request',
        '/api/v1/authentication/otp/verify',
      ],
    );
    expect(httpClient.requests.first.data, {'phoneNumber': '51999991234'});
    expect(httpClient.requests.last.data, {
      'phoneNumber': '51999991234',
      'oneTimePassword': '123456',
    });
    expect(httpClient.bearerTokens, ['access-token']);
  });

  test(
      'GIVEN perfil do cliente no backend WHEN carregar e atualizar preferencias THEN deve mapear estado do perfil',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/customers/me/profile'] =
        customerProfileJson();
    httpClient.objectResponses['/api/v1/customers/me/profile/preferences'] =
        customerProfileJson(
      whatsappNotificationsEnabled: false,
    );

    // WHEN
    final customerProfile = await gateway.loadCustomerProfile();
    final updatedCustomerProfile =
        await gateway.updateCustomerProfilePreferences(
      whatsappNotificationsEnabled: false,
      profilePersonalizationEnabled: true,
    );

    // THEN
    expect(customerProfile.customerName, 'Cliente WorkLink');
    expect(customerProfile.mainCityDisplayName, 'Canoas - RS');
    expect(customerProfile.savedProfessionals.single.professionalName, 'Maria');
    expect(updatedCustomerProfile.whatsappNotificationsEnabled, isFalse);
  });

  test(
      'GIVEN cliente autenticado WHEN salvar e remover profissional THEN deve usar endpoints privados do perfil',
      () async {
    // GIVEN
    httpClient.objectResponses[
            '/api/v1/customers/me/saved-professionals/professional-1'] =
        customerProfileJson();

    // WHEN
    await gateway.saveProfessionalForCustomer('professional-1');
    await gateway.removeSavedProfessionalForCustomer('professional-1');

    // THEN
    expect(
      httpClient.requests.where((request) => request.method == 'POST').last.path,
      '/api/v1/customers/me/saved-professionals/professional-1',
    );
    expect(
      httpClient.requests.where((request) => request.method == 'DELETE').single.path,
      '/api/v1/customers/me/saved-professionals/professional-1',
    );
  });

  test(
      'GIVEN perfil sem cidade principal e telefone nao padronizado WHEN carregar perfil THEN deve aplicar fallbacks previsiveis',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/customers/me/profile'] =
        customerProfileJsonWithoutMainCity();

    // WHEN
    final customerProfile = await gateway.loadCustomerProfile();

    // THEN
    expect(customerProfile.mainCityDisplayName, 'Cidade principal pendente');
    expect(customerProfile.phoneNumber, 'telefone-livre');
  });

  test(
      'GIVEN rascunho profissional WHEN cadastrar THEN deve usar identificadores reais do catalogo',
      () async {
    // GIVEN
    const homeData = WorkLinkHomeData(
      discoveryProfessionals: [],
      professionalProfiles: [],
      professionalRegistrationCategoryNames: ['Eletricista'],
      professionalRegistrationCityDisplayNames: ['Canoas - RS'],
      categoryIdentifiersByName: {'Eletricista': 'category-1'},
      cityIdentifiersByDisplayName: {'Canoas - RS': 'city-1'},
    );
    httpClient.objectResponses['/api/v1/professionals'] = professionalJson();
    httpClient.objectResponses['/api/v1/professionals/professional-1/profile'] =
        professionalJson();

    // WHEN
    await gateway.registerProfessional(
      const ProfessionalRegistrationDraft(
        professionalName: ' Maria Eletricista ',
        documentNumber: ' 12345678900 ',
        categoryName: 'Eletricista',
        cityDisplayName: 'Canoas - RS',
        whatsappNumber: ' 51999999999 ',
        shortDescription: ' Instalacoes residenciais. ',
        instagramProfile: ' @mariaeletrica ',
        usefulLink: ' https://example.com/maria ',
        availabilityStatus: ProfessionalAvailabilityStatus.availableThisWeek,
      ),
      homeData,
    );

    // THEN
    expect(httpClient.requests.first.path, '/api/v1/professionals');
    expect(httpClient.requests.first.data, {
      'professionalName': 'Maria Eletricista',
      'whatsappNumber': '51999999999',
      'cityIdentifier': 'city-1',
      'categoryIdentifier': 'category-1',
      'shortDescription': 'Instalacoes residenciais.',
    });
    expect(
      httpClient.requests.last.path,
      '/api/v1/professionals/professional-1/profile',
    );
    expect(httpClient.requests.last.data, {
      'profilePhotoFileIdentifier': null,
      'documentNumber': '12345678900',
      'usefulLink': 'https://example.com/maria',
      'portfolioDescription': '@mariaeletrica',
      'serviceDescription': 'Instalacoes residenciais.',
      'availabilityStatus': 'AVAILABLE_THIS_WEEK',
    });
  });

  test(
      'GIVEN profissional autenticado WHEN verificar telefone THEN deve chamar endpoints de solicitacao e confirmacao',
      () async {
    // GIVEN
    httpClient.objectResponses[
        '/api/v1/professionals/professional-1/phone-verification/request'] = {
      'professionalIdentifier': 'professional-1',
      'message': 'Codigo enviado.',
      'expiresAt': '2026-05-13T18:05:00Z',
    };
    httpClient.objectResponses[
            '/api/v1/professionals/professional-1/phone-verification/confirm'] =
        professionalJson(phoneNumberVerified: true);

    // WHEN
    await gateway.requestProfessionalPhoneVerification('professional-1');
    await gateway.confirmProfessionalPhoneVerification(
      professionalIdentifier: 'professional-1',
      verificationCode: '123456',
    );

    // THEN
    expect(
      httpClient.requests.map((request) => request.path),
      [
        '/api/v1/professionals/professional-1/phone-verification/request',
        '/api/v1/professionals/professional-1/phone-verification/confirm',
      ],
    );
    expect(httpClient.requests.last.data, {'verificationCode': '123456'});
  });

  test(
      'GIVEN profissional autenticado WHEN adicionar portfolio THEN deve chamar endpoint do perfil profissional',
      () async {
    // GIVEN
    httpClient.objectResponses[
            '/api/v1/professionals/professional-1/portfolio-items'] =
        portfolioItemJson();

    // WHEN
    await gateway.addProfessionalPortfolioItem(
      professionalIdentifier: 'professional-1',
      fileIdentifier: 'file-1',
      title: 'Quadro eletrico residencial',
      description: 'Instalacao concluida.',
      displayOrder: 1,
    );

    // THEN
    expect(
      httpClient.requests.single.path,
      '/api/v1/professionals/professional-1/portfolio-items',
    );
    expect(httpClient.requests.single.data, {
      'fileIdentifier': 'file-1',
      'title': 'Quadro eletrico residencial',
      'description': 'Instalacao concluida.',
      'displayOrder': 1,
    });
  });

  test(
      'GIVEN preview gateway WHEN confirmar codigo errado THEN deve recusar autenticacao local',
      () async {
    // GIVEN
    const previewGateway = WorkLinkPreviewGateway();

    // WHEN + THEN
    expect(
      () => previewGateway.confirmCustomerAuthenticationCode(
        phoneNumber: '51999991234',
        verificationCode: '0000',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test(
      'GIVEN feedback preenchido WHEN enviar pos-contato THEN deve converter enums para backend',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/post-contact-feedbacks'] = {
      'postContactFeedbackIdentifier': 'feedback-1',
      'contactIntentIdentifier': 'contact-1',
      'conversationOutcome': 'CUSTOMER_REACHED_PROFESSIONAL',
      'contactResponsiveness': 'FAST_RESPONSE',
      'serviceExecutionOutcome': 'SERVICE_PERFORMED',
      'createdAt': '2026-05-13T10:00:00Z',
    };

    // WHEN
    await gateway.submitPostContactFeedback(
      'contact-1',
      const PostContactFeedbackState(
        conversationOutcome:
            PostContactConversationOutcome.customerReachedProfessional,
        contactResponsiveness: PostContactResponsiveness.fastResponse,
        serviceExecutionOutcome:
            PostContactServiceExecutionOutcome.servicePerformed,
      ),
    );

    // THEN
    expect(httpClient.requests.single.data, {
      'contactIntentIdentifier': 'contact-1',
      'conversationOutcome': 'CUSTOMER_REACHED_PROFESSIONAL',
      'contactResponsiveness': 'FAST_RESPONSE',
      'serviceExecutionOutcome': 'SERVICE_PERFORMED',
    });
  });

  test(
      'GIVEN feedback alternativo WHEN enviar pos-contato THEN deve converter demais resultados',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/post-contact-feedbacks'] = {
      'postContactFeedbackIdentifier': 'feedback-1',
      'contactIntentIdentifier': 'contact-1',
      'conversationOutcome': 'CUSTOMER_DID_NOT_REACH_PROFESSIONAL',
      'contactResponsiveness': 'SLOW_RESPONSE',
      'serviceExecutionOutcome': 'SERVICE_NOT_PERFORMED',
      'createdAt': '2026-05-13T10:00:00Z',
    };

    // WHEN
    await gateway.submitPostContactFeedback(
      'contact-1',
      const PostContactFeedbackState(
        conversationOutcome:
            PostContactConversationOutcome.customerDidNotReachProfessional,
        contactResponsiveness: PostContactResponsiveness.slowResponse,
        serviceExecutionOutcome:
            PostContactServiceExecutionOutcome.serviceNotPerformed,
      ),
    );

    // THEN
    expect(httpClient.requests.single.data, {
      'contactIntentIdentifier': 'contact-1',
      'conversationOutcome': 'CUSTOMER_DID_NOT_REACH_PROFESSIONAL',
      'contactResponsiveness': 'SLOW_RESPONSE',
      'serviceExecutionOutcome': 'SERVICE_NOT_PERFORMED',
    });
  });

  test(
      'GIVEN feedback sem selecoes WHEN enviar pos-contato THEN deve usar valores conservadores',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/post-contact-feedbacks'] = {
      'postContactFeedbackIdentifier': 'feedback-1',
      'contactIntentIdentifier': 'contact-1',
      'conversationOutcome': 'CUSTOMER_DID_NOT_REACH_PROFESSIONAL',
      'contactResponsiveness': 'NO_RESPONSE',
      'serviceExecutionOutcome': 'SERVICE_NOT_PERFORMED',
      'createdAt': '2026-05-13T10:00:00Z',
    };

    // WHEN
    await gateway.submitPostContactFeedback(
      'contact-1',
      const PostContactFeedbackState(),
    );

    // THEN
    expect(httpClient.requests.single.data, {
      'contactIntentIdentifier': 'contact-1',
      'conversationOutcome': 'CUSTOMER_DID_NOT_REACH_PROFESSIONAL',
      'contactResponsiveness': 'NO_RESPONSE',
      'serviceExecutionOutcome': 'SERVICE_NOT_PERFORMED',
    });
  });

  test(
      'GIVEN avaliacao preenchida WHEN enviar review THEN deve converter estado da UI',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professional-reviews'] = reviewJson();

    // WHEN
    await gateway.submitProfessionalReview(
      'contact-1',
      const ProfessionalReviewState(
        starRating: 5,
        comment: ' Atendimento bom. ',
      ),
    );

    // THEN
    expect(httpClient.requests.single.data, {
      'contactIntentIdentifier': 'contact-1',
      'starRating': 5,
      'comment': 'Atendimento bom.',
      'anonymousToPublic': true,
    });
  });

  test(
      'GIVEN denuncia preenchida WHEN enviar denuncia THEN deve converter motivo para backend',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professional-reports'] = {
      'professionalReportIdentifier': 'report-1',
      'professionalIdentifier': 'professional-1',
      'reportReason': 'FRAUD',
      'description': 'Perfil suspeito.',
      'evidenceFileIdentifier': null,
      'seriousCase': false,
      'authorityGuidance': '',
      'createdAt': '2026-05-13T10:00:00Z',
    };

    // WHEN
    await gateway.submitProfessionalReport(
      'professional-1',
      const ProfessionalReportState(
        selectedReason: ProfessionalReportReason.fraud,
        description: ' Perfil suspeito. ',
      ),
    );

    // THEN
    expect(httpClient.requests.single.data, {
      'professionalIdentifier': 'professional-1',
      'reportReason': 'FRAUD',
      'description': 'Perfil suspeito.',
      'evidenceFileIdentifier': null,
    });
  });

  test(
      'GIVEN denuncias com motivos restantes WHEN enviar denuncia THEN deve converter todos os motivos publicos',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professional-reports'] = {
      'professionalReportIdentifier': 'report-1',
      'professionalIdentifier': 'professional-1',
      'reportReason': 'OTHER',
      'description': 'Descricao.',
      'evidenceFileIdentifier': null,
      'seriousCase': false,
      'authorityGuidance': '',
      'createdAt': '2026-05-13T10:00:00Z',
    };

    // WHEN
    for (final reportState in const [
      ProfessionalReportState(
        selectedReason: ProfessionalReportReason.harassment,
        description: 'Assedio.',
      ),
      ProfessionalReportState(
        selectedReason: ProfessionalReportReason.threat,
        description: 'Ameaca.',
      ),
      ProfessionalReportState(
        selectedReason: ProfessionalReportReason.fakeProfile,
        description: 'Perfil falso.',
      ),
      ProfessionalReportState(
        selectedReason: ProfessionalReportReason.serviceNotPerformed,
        description: 'Servico nao realizado.',
      ),
      ProfessionalReportState(
        selectedReason: ProfessionalReportReason.other,
        description: 'Outro.',
      ),
      ProfessionalReportState(description: 'Sem motivo.'),
    ]) {
      await gateway.submitProfessionalReport('professional-1', reportState);
    }

    // THEN
    expect(
      httpClient.requests.map((request) => request.data['reportReason']),
      [
        'HARASSMENT',
        'THREAT',
        'FAKE_PROFILE',
        'SERVICE_NOT_PERFORMED',
        'OTHER',
        'OTHER',
      ],
    );
  });

  test(
      'GIVEN review publica WHEN solicitar analise THEN deve registrar pedido no backend',
      () async {
    // GIVEN
    httpClient.objectResponses[
        '/api/v1/professional-reviews/review-1/analysis-requests'] = {
      'reviewAnalysisRequestIdentifier': 'analysis-1',
      'professionalReviewIdentifier': 'review-1',
      'reason': 'Solicitacao de analise pelo profissional.',
      'createdAt': '2026-05-13T10:00:00Z',
    };

    // WHEN
    await gateway.requestProfessionalReviewAnalysis('review-1');

    // THEN
    expect(
      httpClient.requests.single.path,
      '/api/v1/professional-reviews/review-1/analysis-requests',
    );
    expect(httpClient.requests.single.data, {
      'reason': 'Solicitacao de analise pelo profissional.',
    });
  });

  test(
      'GIVEN preview gateway WHEN carregar dados THEN deve manter dados estaveis para testes de tela',
      () async {
    // GIVEN
    const previewGateway = WorkLinkPreviewGateway();

    // WHEN
    final homeData = await previewGateway.loadHomeData();
    final contact = await previewGateway.startProfessionalContact(
      'maria-eletricista',
    );
    await previewGateway.submitPostContactFeedback(
      'contact-intention-maria-eletricista',
      const PostContactFeedbackState(),
    );
    await previewGateway.submitProfessionalReview(
      'contact-intention-maria-eletricista',
      const ProfessionalReviewState(starRating: 5, comment: 'Bom.'),
    );
    await previewGateway.submitProfessionalReport(
      'maria-eletricista',
      const ProfessionalReportState(),
    );
    await previewGateway.requestProfessionalReviewAnalysis('review-maria-1');

    // THEN
    expect(previewGateway.initialHomeData.discoveryProfessionals, isNotEmpty);
    expect(
      homeData.professionalProfiles.first.professionalName,
      'Maria Eletricista',
    );
    expect(contact.whatsappContactLink, startsWith('https://wa.me/'));
  });

  test(
      'GIVEN preview gateway WHEN carregar e alterar perfil do cliente THEN deve responder estado estavel',
      () async {
    // GIVEN
    const previewGateway = WorkLinkPreviewGateway();

    // WHEN
    final loadedCustomerProfile = await previewGateway.loadCustomerProfile();
    final updatedCustomerProfile =
        await previewGateway.updateCustomerProfilePreferences(
      whatsappNotificationsEnabled: false,
      profilePersonalizationEnabled: false,
    );
    final savedCustomerProfile = await previewGateway.saveProfessionalForCustomer(
      'maria-eletricista',
    );
    final removedCustomerProfile =
        await previewGateway.removeSavedProfessionalForCustomer(
      'maria-eletricista',
    );

    // THEN
    expect(loadedCustomerProfile.customerName, 'Cliente WorkLink');
    expect(updatedCustomerProfile.whatsappNotificationsEnabled, isFalse);
    expect(updatedCustomerProfile.profilePersonalizationEnabled, isFalse);
    expect(savedCustomerProfile.savedProfessionals, isNotEmpty);
    expect(removedCustomerProfile.savedProfessionals, isNotEmpty);
  });
}

Map<String, dynamic> professionalJson({
  String professionalIdentifier = 'professional-1',
  String categoryIdentifier = 'category-1',
  String cityIdentifier = 'city-1',
  String availabilityStatus = 'AVAILABLE_TODAY',
  String? usefulLink = 'https://portfolio.example/maria',
  String? portfolioDescription = 'Quadros eletricos.',
  String? serviceDescription = 'Instalacoes e manutencoes.',
  bool phoneNumberVerified = false,
  bool qualityGuarantee = true,
}) {
  return {
    'professionalIdentifier': professionalIdentifier,
    'professionalName': 'Maria',
    'whatsappNumber': '+5551999999999',
    'cityIdentifier': cityIdentifier,
    'categoryIdentifier': categoryIdentifier,
    'shortDescription': 'Atendimento residencial.',
    'profilePhotoFileIdentifier': null,
    'documentProvided': true,
    'usefulLink': usefulLink,
    'portfolioDescription': portfolioDescription,
    'serviceDescription': serviceDescription,
    'profileCompletenessPercentage': 100,
    'profileClassification': 'COMPLETE',
    'availabilityStatus': availabilityStatus,
    'availabilityBadgeLabel': 'Disponivel hoje',
    'availabilityReducesListingHighlight': false,
    'phoneNumberVerified': phoneNumberVerified,
    'qualityGuarantee': qualityGuarantee,
  };
}

Map<String, dynamic> reviewProfileJson() {
  return {
    'professionalIdentifier': 'professional-1',
    'summary': {
      'averageRating': 5.0,
      'reviewCount': 1,
      'hasReviews': true,
    },
    'reviews': [reviewJson()],
  };
}

Map<String, dynamic> reviewJson() {
  return {
    'professionalReviewIdentifier': 'review-1',
    'contactIntentIdentifier': 'contact-1',
    'professionalIdentifier': 'professional-1',
    'starRating': 5,
    'comment': 'Atendimento bom.',
    'anonymousToPublic': true,
    'publicAuthorIdentifier': null,
    'publicAuthorDisplayName': 'Usuario anonimo',
    'createdAt': '2026-05-13T10:00:00Z',
  };
}

Map<String, dynamic> portfolioItemJson() {
  return {
    'portfolioItemIdentifier': 'portfolio-1',
    'professionalIdentifier': 'professional-1',
    'fileIdentifier': 'file-1',
    'title': 'Quadro eletrico residencial',
    'description': 'Instalacao concluida.',
    'displayOrder': 1,
  };
}

Map<String, dynamic> customerProfileJson({
  bool whatsappNotificationsEnabled = true,
  bool profilePersonalizationEnabled = true,
}) {
  return {
    'customerIdentifier': 'customer-1',
    'customerName': 'Cliente WorkLink',
    'phoneNumber': '51999991234',
    'mainCity': {
      'cityIdentifier': 'city-1',
      'cityName': 'Canoas',
      'stateCode': 'RS',
    },
    'selectedCities': [
      {
        'cityIdentifier': 'city-1',
        'cityName': 'Canoas',
        'stateCode': 'RS',
      },
    ],
    'savedProfessionals': [
      {
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria',
        'categoryName': 'Eletricista',
        'city': {
          'cityIdentifier': 'city-1',
          'cityName': 'Canoas',
          'stateCode': 'RS',
        },
      },
    ],
    'submittedReviews': [
      {
        'professionalReviewIdentifier': 'review-1',
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria',
        'starRating': 5,
        'publiclyAnonymous': true,
        'comment': 'Excelente atendimento.',
      },
    ],
    'whatsappNotificationsEnabled': whatsappNotificationsEnabled,
    'profilePersonalizationEnabled': profilePersonalizationEnabled,
  };
}

Map<String, dynamic> customerProfileJsonWithoutMainCity() {
  return {
    'customerIdentifier': 'customer-1',
    'customerName': 'Cliente WorkLink',
    'phoneNumber': 'telefone-livre',
    'mainCity': null,
    'selectedCities': const [],
    'savedProfessionals': const [],
    'submittedReviews': const [],
    'whatsappNotificationsEnabled': true,
    'profilePersonalizationEnabled': true,
  };
}
