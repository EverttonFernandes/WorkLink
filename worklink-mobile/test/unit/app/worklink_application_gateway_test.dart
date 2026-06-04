import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/app/worklink_application_gateway.dart';
import 'package:worklink_mobile/features/customer_authentication/customer_authentication_state.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_request.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_state.dart';
import 'package:worklink_mobile/features/professional_availability/professional_availability_status.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_draft.dart';
import 'package:worklink_mobile/features/professional_report/professional_report_state.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_state.dart';
import 'package:worklink_mobile/services/exceptions.dart';

import '../services/fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;
  late FakeWorkLinkHttpClient administrativeHttpClient;
  late WorkLinkBackendGateway gateway;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
    administrativeHttpClient = FakeWorkLinkHttpClient();
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
      homeData.discoveryProfessionals.single.comparisonSignalLabels,
      contains('Perfil completo'),
    );
    expect(
      homeData.discoveryProfessionals.single.comparisonSignalLabels,
      isNot(contains('COMPLETE')),
    );
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
      'Categoria não informada',
    );
    expect(homeData.discoveryProfessionals[2].cityName, 'Cidade não informada');
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
      'GIVEN backend retorna classificacao tecnica WHEN carregar home THEN deve expor label publica',
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
      professionalJson(profileClassification: 'BASIC_PROFILE'),
    ];

    // WHEN
    final homeData = await gateway.loadHomeData();

    // THEN
    expect(
      homeData.discoveryProfessionals.single.comparisonSignalLabels,
      contains('Perfil básico'),
    );
    expect(
      homeData.discoveryProfessionals.single.comparisonSignalLabels.join(' '),
      isNot(contains('BASIC_PROFILE')),
    );
  });

  test(
      'GIVEN backend retorna codigos tecnicos WHEN mapear telas THEN nao deve vazar label tecnica',
      () async {
    // GIVEN
    gateway = WorkLinkBackendGateway(
      httpClient: httpClient,
      administrativeHttpClient: administrativeHttpClient,
    );
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
        profileClassification: 'BASIC_PROFILE',
        categoryIdentifier: 'category-sem-mapa',
        cityIdentifier: 'city-sem-mapa',
      ),
    ];
    administrativeHttpClient.listResponses['/api/v1/admin/professionals'] = [
      {
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria Eletricista',
        'cityIdentifier': 'city-sem-mapa',
        'categoryIdentifier': 'category-sem-mapa',
        'profileClassification': 'BASIC_PROFILE',
        'availabilityStatus': 'UNKNOWN_STATUS',
        'blocked': false,
      },
    ];
    administrativeHttpClient.listResponses['/api/v1/admin/reports'] = [
      {
        'professionalReportIdentifier': 'report-1',
        'professionalIdentifier': 'professional-sem-mapa',
        'reportReason': 'UNKNOWN_REASON',
        'seriousCase': false,
        'moderationStatus': 'UNKNOWN_STATUS',
        'moderationDecision': 'UNKNOWN_DECISION',
        'createdAt': '2026-05-17T10:00:00Z',
      },
    ];
    administrativeHttpClient
        .listResponses['/api/v1/admin/review-analysis-requests'] = [
      {
        'reviewAnalysisRequestIdentifier': 'analysis-1',
        'professionalReviewIdentifier': 'review-1',
        'professionalIdentifier': 'professional-sem-mapa',
        'requestedByProfessionalIdentifier': 'professional-sem-mapa',
        'moderationStatus': 'UNKNOWN_STATUS',
        'moderationDecision': 'UNKNOWN_DECISION',
        'createdAt': '2026-05-17T11:00:00Z',
      },
    ];
    administrativeHttpClient.objectResponses['/api/v1/admin/metrics'] = {
      'professionalCount': 1,
      'blockedProfessionalCount': 0,
      'professionalReportCount': 1,
      'reviewAnalysisRequestCount': 1,
      'serviceCategoryCount': 1,
    };
    administrativeHttpClient
        .objectResponses['/api/v1/admin/functional-metrics'] = {
      ...minimalFunctionalMetricsJson(),
      'searchesByCategory': [
        {'metricIdentifier': 'category-sem-mapa', 'contactCount': 1},
      ],
      'searchesByCity': [
        {'metricIdentifier': 'city-sem-mapa', 'contactCount': 1},
      ],
      'contactsByProfessional': [
        {'metricIdentifier': 'professional-sem-mapa', 'contactCount': 1},
      ],
      'responsivenessSignals': [
        {'contactResponsiveness': 'UNKNOWN_SIGNAL', 'feedbackCount': 1},
      ],
      'reputationSignals': [
        {
          'professionalIdentifier': 'professional-sem-mapa',
          'averageRating': 3.5,
          'reviewCount': 1,
        },
      ],
    };

    // WHEN
    final homeData = await gateway.loadHomeData();
    final administrativeConsoleState =
        await gateway.loadAdministrativeConsole();

    // THEN
    expectNoTechnicalLabels([
      ...homeData.discoveryProfessionals.single.comparisonSignalLabels,
      homeData.discoveryProfessionals.single.categoryName,
      homeData.discoveryProfessionals.single.cityDisplayName,
      administrativeConsoleState.professionals.single.cityDisplayName,
      administrativeConsoleState.professionals.single.categoryName,
      administrativeConsoleState.professionals.single.profileClassification,
      administrativeConsoleState.professionals.single.availabilityLabel,
      administrativeConsoleState.professionalReports.single.professionalName,
      administrativeConsoleState.professionalReports.single.reportReasonLabel,
      administrativeConsoleState
          .professionalReports.single.moderationStatusLabel,
      administrativeConsoleState
          .professionalReports.single.moderationDecisionLabel,
      administrativeConsoleState.reviewAnalysisRequests.single.professionalName,
      administrativeConsoleState
          .reviewAnalysisRequests.single.moderationStatusLabel,
      administrativeConsoleState
          .reviewAnalysisRequests.single.moderationDecisionLabel,
      administrativeConsoleState
          .functionalMetrics.topSearchCategories.single.label,
      administrativeConsoleState.functionalMetrics.topSearchCities.single.label,
      administrativeConsoleState
          .functionalMetrics.topContactProfessionals.single.label,
      administrativeConsoleState
          .functionalMetrics.responsivenessSignals.single.label,
      administrativeConsoleState
          .functionalMetrics.reputationSignals.single.label,
    ]);
  });

  test(
      'GIVEN console administrativo autorizado WHEN carregar dados THEN deve mapear profissionais denuncias categorias e metricas',
      () async {
    // GIVEN
    gateway = WorkLinkBackendGateway(
      httpClient: httpClient,
      administrativeHttpClient: administrativeHttpClient,
    );
    httpClient.listResponses['/api/v1/categories'] = [
      {
        'categoryIdentifier': 'category-1',
        'categoryName': 'Eletricista',
        'categorySlug': 'eletricista',
      },
      {
        'categoryIdentifier': 'category-2',
        'categoryName': 'Pintora',
        'categorySlug': 'pintora',
      },
    ];
    httpClient.listResponses['/api/v1/cities'] = [
      {
        'cityIdentifier': 'city-1',
        'cityName': 'Canoas',
        'stateCode': 'RS',
        'citySlug': 'canoas-rs',
      },
      {
        'cityIdentifier': 'city-2',
        'cityName': 'Porto Alegre',
        'stateCode': 'RS',
        'citySlug': 'porto-alegre-rs',
      },
    ];
    administrativeHttpClient.listResponses['/api/v1/admin/professionals'] = [
      {
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria Eletricista',
        'cityIdentifier': 'city-1',
        'categoryIdentifier': 'category-1',
        'profileClassification': 'Perfil completo',
        'availabilityStatus': 'AVAILABLE_THIS_WEEK',
        'blocked': false,
      },
      {
        'professionalIdentifier': 'professional-2',
        'professionalName': 'Ana Pintora',
        'cityIdentifier': 'city-sem-mapa',
        'categoryIdentifier': 'category-sem-mapa',
        'profileClassification': 'Perfil basico',
        'availabilityStatus': 'UNKNOWN_STATUS',
        'blocked': true,
      },
    ];
    administrativeHttpClient.listResponses['/api/v1/admin/reports'] = [
      {
        'professionalReportIdentifier': 'report-1',
        'professionalIdentifier': 'professional-1',
        'reportReason': 'FAKE_PROFILE',
        'seriousCase': true,
        'evidenceFileIdentifier': 'file-1',
        'moderationStatus': 'ACTION_REQUIRED',
        'moderationDecision': 'REQUIRE_ADDITIONAL_ACTION',
        'moderationNotes': 'Escalar moderacao.',
        'decidedAt': '2026-05-17T10:05:00Z',
        'createdAt': '2026-05-17T10:00:00Z',
      },
    ];
    administrativeHttpClient
        .listResponses['/api/v1/admin/review-analysis-requests'] = [
      {
        'reviewAnalysisRequestIdentifier': 'analysis-1',
        'professionalReviewIdentifier': 'review-1',
        'professionalIdentifier': 'professional-2',
        'requestedByProfessionalIdentifier': 'professional-2',
        'moderationStatus': 'RESOLVED',
        'moderationDecision': 'HIDE_FROM_PUBLIC',
        'moderationNotes': 'Ocultada pela administracao.',
        'decidedAt': '2026-05-17T11:05:00Z',
        'createdAt': '2026-05-17T11:00:00Z',
      },
    ];
    administrativeHttpClient.objectResponses['/api/v1/admin/metrics'] = {
      'professionalCount': 2,
      'blockedProfessionalCount': 1,
      'professionalReportCount': 1,
      'reviewAnalysisRequestCount': 1,
      'serviceCategoryCount': 2,
    };
    administrativeHttpClient
        .objectResponses['/api/v1/admin/functional-metrics'] = {
      'searchCount': 12,
      'searchWithoutResultCount': 2,
      'contactCount': 8,
      'postContactFeedbackCount': 5,
      'reviewCount': 4,
      'anonymousReviewCount': 2,
      'professionalReportCount': 1,
      'reviewAnalysisRequestCount': 1,
      'rankingAlgorithmEnabled': false,
      'searchesByCategory': [
        {'metricIdentifier': 'category-1', 'contactCount': 7},
        {'metricIdentifier': 'category-sem-mapa', 'contactCount': 1},
      ],
      'searchesByCity': [
        {'metricIdentifier': 'city-1', 'contactCount': 6},
        {'metricIdentifier': 'city-sem-mapa', 'contactCount': 1},
      ],
      'contactsByProfessional': [
        {'metricIdentifier': 'professional-1', 'contactCount': 3},
        {'metricIdentifier': 'professional-sem-mapa', 'contactCount': 1},
      ],
      'contactsByCategory': <Map<String, Object?>>[],
      'contactsByCity': <Map<String, Object?>>[],
      'professionalSummary': {
        'activeProfessionalCount': 2,
        'completeProfessionalCount': 1,
        'availableProfessionalCount': 1,
        'unavailableProfessionalCount': 1,
        'professionalsWithContactCount': 2,
      },
      'responsivenessSummary': {
        'respondedContactPercentage': 87.5,
        'noResponsePercentage': 12.5,
        'servicePerformedPercentage': 50.0,
        'postContactAnswerRatePercentage': 75.0,
      },
      'responsivenessSignals': [
        {'contactResponsiveness': 'FAST_RESPONSE', 'feedbackCount': 4},
        {'contactResponsiveness': 'UNKNOWN_SIGNAL', 'feedbackCount': 1},
      ],
      'reputationSummary': {
        'reviewCount': 4,
        'averageRating': 4.6,
        'anonymousReviewCount': 2,
        'professionalReportCount': 1,
        'reviewAnalysisRequestCount': 1,
      },
      'reputationSignals': [
        {
          'professionalIdentifier': 'professional-1',
          'averageRating': 4.8,
          'reviewCount': 3,
        },
        {
          'professionalIdentifier': 'professional-sem-mapa',
          'averageRating': 3.5,
          'reviewCount': 1,
        },
      ],
    };

    // WHEN
    final administrativeConsoleState =
        await gateway.loadAdministrativeConsole();

    // THEN
    expect(gateway.administrativeConsoleAvailable, isTrue);
    expect(
      administrativeConsoleState.statusMessage,
      'Console administrativo carregado.',
    );
    expect(administrativeConsoleState.professionals, hasLength(2));
    expect(
      administrativeConsoleState.professionals.first.availabilityLabel,
      'Disponível esta semana',
    );
    expect(
      administrativeConsoleState.professionals.last.cityDisplayName,
      'Cidade não mapeada',
    );
    expect(
      administrativeConsoleState.professionals.last.categoryName,
      'Categoria não mapeada',
    );
    expect(
      administrativeConsoleState.professionals.first.profileClassification,
      'Perfil completo',
    );
    expect(
      administrativeConsoleState.professionals.last.profileClassification,
      'Perfil básico',
    );
    expect(
      administrativeConsoleState.professionalReports.single.reportReasonLabel,
      'Perfil falso',
    );
    expect(
      administrativeConsoleState
          .professionalReports.single.moderationDecisionLabel,
      'Exigir acao adicional',
    );
    expect(
      administrativeConsoleState
          .reviewAnalysisRequests.single.moderationDecisionLabel,
      'Ocultar publicamente',
    );
    expect(
      administrativeConsoleState.categoryNames,
      ['Eletricista', 'Pintora'],
    );
    expect(
      administrativeConsoleState
          .functionalMetrics.topSearchCategories.first.label,
      'Eletricista',
    );
    expect(
      administrativeConsoleState.functionalMetrics.topSearchCities.first.label,
      'Canoas - RS',
    );
    expect(
      administrativeConsoleState
          .functionalMetrics.topContactProfessionals.first.label,
      'Maria Eletricista',
    );
    expect(
      administrativeConsoleState
          .functionalMetrics.responsivenessSignals.first.label,
      'Resposta rapida',
    );
    expect(
      administrativeConsoleState
          .functionalMetrics.responsivenessSignals.last.label,
      'Sinal não mapeado',
    );
    expect(
      administrativeConsoleState.functionalMetrics.reputationSignals.last.label,
      'Profissional não mapeado',
    );
    expect(
      administrativeHttpClient.requests.map((request) => request.path),
      [
        '/api/v1/admin/professionals',
        '/api/v1/admin/reports',
        '/api/v1/admin/review-analysis-requests',
        '/api/v1/admin/metrics',
        '/api/v1/admin/functional-metrics',
      ],
    );
  });

  test(
      'GIVEN console administrativo autorizado WHEN executar mutacoes THEN deve recarregar estado com mensagens de sucesso',
      () async {
    // GIVEN
    gateway = WorkLinkBackendGateway(
      httpClient: httpClient,
      administrativeHttpClient: administrativeHttpClient,
    );
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
    administrativeHttpClient.listResponses['/api/v1/admin/professionals'] = [
      {
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria Eletricista',
        'cityIdentifier': 'city-1',
        'categoryIdentifier': 'category-1',
        'profileClassification': 'Perfil completo',
        'availabilityStatus': 'AVAILABLE_TODAY',
        'blocked': false,
      },
    ];
    administrativeHttpClient.listResponses['/api/v1/admin/reports'] = [
      {
        'professionalReportIdentifier': 'report-1',
        'professionalIdentifier': 'professional-1',
        'reportReason': 'FRAUD',
        'seriousCase': false,
        'moderationStatus': 'PENDING',
        'createdAt': '2026-05-17T10:00:00Z',
      },
    ];
    administrativeHttpClient
        .listResponses['/api/v1/admin/review-analysis-requests'] = [
      {
        'reviewAnalysisRequestIdentifier': 'analysis-1',
        'professionalReviewIdentifier': 'review-1',
        'professionalIdentifier': 'professional-1',
        'requestedByProfessionalIdentifier': 'professional-1',
        'moderationStatus': 'PENDING',
        'createdAt': '2026-05-17T11:00:00Z',
      },
    ];
    administrativeHttpClient.objectResponses['/api/v1/admin/metrics'] = {
      'professionalCount': 1,
      'blockedProfessionalCount': 0,
      'professionalReportCount': 1,
      'reviewAnalysisRequestCount': 1,
      'serviceCategoryCount': 1,
    };
    administrativeHttpClient
            .objectResponses['/api/v1/admin/functional-metrics'] =
        minimalFunctionalMetricsJson();
    administrativeHttpClient.objectResponses[
            '/api/v1/admin/professionals/professional-1/block'] =
        administrativeProfessionalJson(blocked: true);
    administrativeHttpClient.objectResponses[
            '/api/v1/admin/professionals/professional-1/unblock'] =
        administrativeProfessionalJson();
    administrativeHttpClient
            .objectResponses['/api/v1/admin/reports/report-1/moderation'] =
        administrativeReportJson(
      moderationStatus: 'RESOLVED',
      moderationDecision: 'KEEP_AS_IS',
      moderationNotes: 'Resolvido',
    );
    administrativeHttpClient.objectResponses[
            '/api/v1/admin/review-analysis-requests/analysis-1/moderation'] =
        administrativeReviewAnalysisJson(
      moderationStatus: 'ACTION_REQUIRED',
      moderationDecision: 'HIDE_FROM_PUBLIC',
      moderationNotes: 'Ocultada',
    );
    administrativeHttpClient.objectResponses['/api/v1/categories'] = {
      'categoryIdentifier': 'category-2',
      'categoryName': 'Eletricista',
      'categorySlug': 'eletricista',
    };

    // WHEN
    final blockedState =
        await gateway.blockAdministrativeProfessional('professional-1');
    final unblockedState =
        await gateway.unblockAdministrativeProfessional('professional-1');
    final approvedReportState =
        await gateway.approveAdministrativeProfessionalReport('report-1');
    final escalatedReportState =
        await gateway.escalateAdministrativeProfessionalReport('report-1');
    final keptReviewState =
        await gateway.keepAdministrativeReviewPublic('analysis-1');
    final hiddenReviewState =
        await gateway.hideAdministrativeReviewFromPublic('analysis-1');
    final registeredCategoryState =
        await gateway.registerAdministrativeCategory(' Eletricista ');

    // THEN
    expect(
      blockedState.statusMessage,
      'Profissional bloqueado no console administrativo.',
    );
    expect(
      unblockedState.statusMessage,
      'Profissional desbloqueado no console administrativo.',
    );
    expect(
      approvedReportState.statusMessage,
      'Denuncia revisada e mantida.',
    );
    expect(
      escalatedReportState.statusMessage,
      'Denuncia sinalizada para acao adicional.',
    );
    expect(
      keptReviewState.statusMessage,
      'Contestacao revisada e avaliacao mantida publica.',
    );
    expect(
      hiddenReviewState.statusMessage,
      'Avaliacao ocultada do perfil publico.',
    );
    expect(
      registeredCategoryState.statusMessage,
      'Categoria administrativa registrada com sucesso.',
    );
    expect(
      administrativeHttpClient.requests
          .where((request) => request.method == 'POST')
          .map((request) => request.path),
      [
        '/api/v1/admin/professionals/professional-1/block',
        '/api/v1/admin/professionals/professional-1/unblock',
        '/api/v1/admin/reports/report-1/moderation',
        '/api/v1/admin/reports/report-1/moderation',
        '/api/v1/admin/review-analysis-requests/analysis-1/moderation',
        '/api/v1/admin/review-analysis-requests/analysis-1/moderation',
        '/api/v1/categories',
      ],
    );
    final moderationRequests = administrativeHttpClient.requests
        .where((request) => request.path.contains('/moderation'))
        .toList();
    expect(moderationRequests[0].data['moderationDecision'], 'KEEP_AS_IS');
    expect(
      moderationRequests[1].data['moderationDecision'],
      'REQUIRE_ADDITIONAL_ACTION',
    );
    expect(moderationRequests[2].data['moderationDecision'], 'KEEP_AS_IS');
    expect(
      moderationRequests[3].data['moderationDecision'],
      'HIDE_FROM_PUBLIC',
    );
    final categoryRegistrationRequest = administrativeHttpClient.requests
        .singleWhere((request) => request.path == '/api/v1/categories');
    expect(categoryRegistrationRequest.data['categoryName'], 'Eletricista');
  });

  test(
      'GIVEN console administrativo sem credencial WHEN carregar THEN deve falhar com autorizacao',
      () async {
    // WHEN / THEN
    expect(
      gateway.loadAdministrativeConsole,
      throwsA(
        isA<AuthorizationException>().having(
          (error) => error.message,
          'message',
          'Console administrativo indisponivel sem token interno.',
        ),
      ),
    );
    expect(gateway.administrativeConsoleAvailable, isFalse);
  });

  test(
      'GIVEN preview gateway WHEN operar console administrativo THEN deve manter estado consistente',
      () async {
    // GIVEN
    const previewGateway = WorkLinkPreviewGateway();

    // WHEN
    final loadedState = await previewGateway.loadAdministrativeConsole();
    final blockedState = await previewGateway.blockAdministrativeProfessional(
      'maria-eletricista',
    );
    final approvedState = await previewGateway
        .approveAdministrativeProfessionalReport('report-1');
    final hiddenState = await previewGateway.hideAdministrativeReviewFromPublic(
      'review-analysis-1',
    );
    final categoryState =
        await previewGateway.registerAdministrativeCategory('Pintora');

    // THEN
    expect(previewGateway.administrativeConsoleAvailable, isTrue);
    expect(loadedState.professionals, isNotEmpty);
    expect(
      blockedState.professionals.first.professionalName,
      'Maria Eletricista',
    );
    expect(
      approvedState.professionalReports.single.reportReasonLabel,
      'Perfil falso',
    );
    expect(
      hiddenState.reviewAnalysisRequests.single.professionalName,
      'Maria Eletricista',
    );
    expect(categoryState.categoryNames, contains('Eletricista'));
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
      'deliveryChannels': ['SMS', 'WHATSAPP', 'EMAIL'],
      'simulatedDelivery': true,
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
    expect(httpClient.requests.first.data, {
      'phoneNumber': '51999991234',
      'deliveryChannel': 'SMS',
    });
    expect(httpClient.requests.last.data, {
      'phoneNumber': '51999991234',
      'oneTimePassword': '123456',
    });
    expect(httpClient.bearerTokens, ['access-token']);
  });

  test(
      'GIVEN email escolhido WHEN solicitar codigo THEN deve enviar canal e email para API',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/authentication/otp/request'] = {
      'message': 'Codigo enviado.',
      'expiresAt': '2026-05-13T10:05:00Z',
      'deliveryChannels': ['SMS', 'WHATSAPP', 'EMAIL'],
      'simulatedDelivery': true,
    };

    // WHEN
    await gateway.requestCustomerAuthenticationCode(
      '51999991234',
      verificationChannel: CustomerAuthenticationVerificationChannel.email,
      emailAddress: 'cliente@worklink.test',
    );

    // THEN
    expect(httpClient.requests.single.data, {
      'phoneNumber': '51999991234',
      'deliveryChannel': 'EMAIL',
      'emailAddress': 'cliente@worklink.test',
    });
  });

  test(
      'GIVEN solicitacoes pendentes WHEN carregar e dispensar THEN deve mapear prompt de pós-contato',
      () async {
    // GIVEN
    httpClient.listResponses[
        '/api/v1/customers/me/post-contact-feedback-requests'] = [
      {
        'contactIntentIdentifier': 'contact-1',
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria',
        'contactCreatedAt': '2026-05-13T10:00:00Z',
      },
    ];

    // WHEN
    final requests = await gateway.loadPendingPostContactFeedbackRequests();
    await gateway.dismissPostContactFeedbackRequest('contact-1');

    // THEN
    expect(
      requests,
      [
        isA<PostContactFeedbackRequest>()
            .having(
              (request) => request.contactIntentionIdentifier,
              'contactIntentionIdentifier',
              'contact-1',
            )
            .having(
              (request) => request.professionalName,
              'professionalName',
              'Maria',
            ),
      ],
    );
    expect(
      httpClient.requests.map((request) => request.path),
      [
        '/api/v1/customers/me/post-contact-feedback-requests',
        '/api/v1/customers/me/post-contact-feedback-requests/contact-1/dismiss',
      ],
    );
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
      httpClient.requests
          .where((request) => request.method == 'POST')
          .last
          .path,
      '/api/v1/customers/me/saved-professionals/professional-1',
    );
    expect(
      httpClient.requests
          .where((request) => request.method == 'DELETE')
          .single
          .path,
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
    const previewProfessionalIdentifier = 'ana-costa-energia-residencial';

    // WHEN
    final homeData = await previewGateway.loadHomeData();
    final contact = await previewGateway.startProfessionalContact(
      previewProfessionalIdentifier,
    );
    await previewGateway.submitPostContactFeedback(
      'contact-intention-$previewProfessionalIdentifier',
      const PostContactFeedbackState(),
    );
    await previewGateway.submitProfessionalReview(
      'contact-intention-$previewProfessionalIdentifier',
      const ProfessionalReviewState(starRating: 5, comment: 'Bom.'),
    );
    await previewGateway.submitProfessionalReport(
      previewProfessionalIdentifier,
      const ProfessionalReportState(),
    );
    await previewGateway.requestProfessionalReviewAnalysis(
      'review-ana-costa-1',
    );

    // THEN
    expect(previewGateway.initialHomeData.discoveryProfessionals, isNotEmpty);
    expect(
      homeData.professionalProfiles.first.professionalName,
      'Ana Costa Energia Residencial',
    );
    expect(contact.whatsappContactLink, startsWith('https://wa.me/'));
  });

  test(
      'GIVEN preview gateway WHEN carregar homologacao THEN deve cobrir regiao inicial',
      () async {
    // GIVEN
    const previewGateway = WorkLinkPreviewGateway();
    const expectedCityDisplayNames = [
      'Charqueadas - RS',
      'São Jerônimo - RS',
      'Triunfo - RS',
      'Arroio dos Ratos - RS',
      'Eldorado do Sul - RS',
      'General Câmara - RS',
      'Butiá - RS',
    ];

    // WHEN
    final homeData = await previewGateway.loadHomeData();
    final discoveryCityDisplayNames = homeData.discoveryProfessionals
        .map((professional) => professional.cityDisplayName)
        .toSet();
    final profileBaseCityDisplayNames = homeData.professionalProfiles
        .map((profile) => profile.baseCityDisplayName)
        .toSet();

    // THEN
    expect(
      homeData.professionalRegistrationCityDisplayNames,
      expectedCityDisplayNames,
    );
    expect(discoveryCityDisplayNames, containsAll(expectedCityDisplayNames));
    expect(profileBaseCityDisplayNames, containsAll(expectedCityDisplayNames));
    expect(
      homeData.discoveryProfessionals.length,
      greaterThanOrEqualTo(expectedCityDisplayNames.length),
    );
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
    final savedCustomerProfile =
        await previewGateway.saveProfessionalForCustomer(
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
  String profileClassification = 'COMPLETE',
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
    'profileClassification': profileClassification,
    'availabilityStatus': availabilityStatus,
    'availabilityBadgeLabel': 'Disponivel hoje',
    'availabilityReducesListingHighlight': false,
    'phoneNumberVerified': phoneNumberVerified,
    'qualityGuarantee': qualityGuarantee,
  };
}

void expectNoTechnicalLabels(Iterable<String?> labels) {
  const forbiddenTechnicalLabels = {
    'BASIC_PROFILE',
    'COMPLETE_PROFILE',
    'UNKNOWN_SIGNAL',
    'UNKNOWN_STATUS',
    'UNKNOWN_REASON',
    'UNKNOWN_DECISION',
    'category-sem-mapa',
    'city-sem-mapa',
    'professional-sem-mapa',
  };
  for (final label in labels.whereType<String>()) {
    expect(
      forbiddenTechnicalLabels,
      isNot(contains(label)),
      reason: 'Label tecnica vazou para UI: $label',
    );
    expect(
      label,
      isNot(contains('_')),
      reason: 'Label publica nao deve conter underscore: $label',
    );
  }
}

Map<String, dynamic> administrativeProfessionalJson({
  bool blocked = false,
}) {
  return {
    'professionalIdentifier': 'professional-1',
    'professionalName': 'Maria Eletricista',
    'cityIdentifier': 'city-1',
    'categoryIdentifier': 'category-1',
    'profileClassification': 'Perfil completo',
    'availabilityStatus': 'AVAILABLE_TODAY',
    'blocked': blocked,
  };
}

Map<String, dynamic> administrativeReportJson({
  String moderationStatus = 'PENDING',
  String? moderationDecision,
  String? moderationNotes,
}) {
  return {
    'professionalReportIdentifier': 'report-1',
    'professionalIdentifier': 'professional-1',
    'reportReason': 'FRAUD',
    'seriousCase': false,
    'moderationStatus': moderationStatus,
    'moderationDecision': moderationDecision,
    'moderationNotes': moderationNotes,
    'decidedAt': moderationDecision == null ? null : '2026-05-17T10:05:00Z',
    'createdAt': '2026-05-17T10:00:00Z',
  };
}

Map<String, dynamic> administrativeReviewAnalysisJson({
  String moderationStatus = 'PENDING',
  String? moderationDecision,
  String? moderationNotes,
}) {
  return {
    'reviewAnalysisRequestIdentifier': 'analysis-1',
    'professionalReviewIdentifier': 'review-1',
    'professionalIdentifier': 'professional-1',
    'requestedByProfessionalIdentifier': 'professional-1',
    'moderationStatus': moderationStatus,
    'moderationDecision': moderationDecision,
    'moderationNotes': moderationNotes,
    'decidedAt': moderationDecision == null ? null : '2026-05-17T11:05:00Z',
    'createdAt': '2026-05-17T11:00:00Z',
  };
}

Map<String, dynamic> minimalFunctionalMetricsJson() {
  return {
    'searchCount': 1,
    'searchWithoutResultCount': 0,
    'contactCount': 1,
    'postContactFeedbackCount': 0,
    'reviewCount': 0,
    'anonymousReviewCount': 0,
    'professionalReportCount': 1,
    'reviewAnalysisRequestCount': 1,
    'rankingAlgorithmEnabled': false,
    'searchesByCategory': <Map<String, Object?>>[],
    'searchesByCity': <Map<String, Object?>>[],
    'contactsByProfessional': <Map<String, Object?>>[],
    'contactsByCategory': <Map<String, Object?>>[],
    'contactsByCity': <Map<String, Object?>>[],
    'professionalSummary': {
      'activeProfessionalCount': 1,
      'completeProfessionalCount': 1,
      'availableProfessionalCount': 1,
      'unavailableProfessionalCount': 0,
      'professionalsWithContactCount': 1,
    },
    'responsivenessSummary': {
      'respondedContactPercentage': 100.0,
      'noResponsePercentage': 0.0,
      'servicePerformedPercentage': 100.0,
      'postContactAnswerRatePercentage': 0.0,
    },
    'responsivenessSignals': <Map<String, Object?>>[],
    'reputationSummary': {
      'reviewCount': 0,
      'averageRating': 0.0,
      'anonymousReviewCount': 0,
      'professionalReportCount': 1,
      'reviewAnalysisRequestCount': 1,
    },
    'reputationSignals': <Map<String, Object?>>[],
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
    'selectedCities': const <Map<String, dynamic>>[],
    'savedProfessionals': const <Map<String, dynamic>>[],
    'submittedReviews': const <Map<String, dynamic>>[],
    'whatsappNotificationsEnabled': true,
    'profilePersonalizationEnabled': true,
  };
}
