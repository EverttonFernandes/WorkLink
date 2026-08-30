import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/discovery_service.dart';
import 'package:worklink_mobile/services/models/discovery_model.dart';
import 'package:worklink_mobile/services/models/professional_model.dart';
import 'package:worklink_mobile/services/professional_service.dart';

import 'fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
  });

  test(
      'GIVEN filtros de busca WHEN descobrir profissionais THEN deve consultar endpoint de profissionais',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/professionals'] = [
      professionalSummaryJson(),
    ];
    final discoveryService = DiscoveryService(httpClient: httpClient);

    // WHEN
    final result = await discoveryService.discoverProfessionals(
      const DiscoveryRequest(
        categoryIdentifier: 'category-1',
        cityIdentifier: 'city-1',
        keyword: 'eletrica',
      ),
    );

    // THEN
    expect(result.professionals.single.professionalName, 'Maria Eletricista');
    expect(httpClient.requests.single.path, '/api/v1/professionals');
    expect(httpClient.requests.single.queryParameters, {
      'categoryIdentifier': 'category-1',
      'cityIdentifier': 'city-1',
      'keyword': 'eletrica',
    });
  });

  test(
      'GIVEN dados basicos WHEN cadastrar profissional THEN deve enviar DTO do backend',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professionals'] = professionalJson();
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final professional = await professionalService.registerBasicProfessional(
      const RegisterBasicProfessionalRequest(
        professionalName: 'Maria Eletricista',
        whatsappNumber: '+5551999999999',
        cityIdentifier: 'city-1',
        categoryIdentifier: 'category-1',
        shortDescription: 'Atendimento residencial.',
      ),
    );

    // THEN
    expect(professional.professionalIdentifier, 'professional-1');
    expect(httpClient.requests.single.data, {
      'professionalName': 'Maria Eletricista',
      'whatsappNumber': '+5551999999999',
      'cityIdentifier': 'city-1',
      'categoryIdentifier': 'category-1',
      'shortDescription': 'Atendimento residencial.',
    });
  });

  test(
      'GIVEN resumo publico minimo WHEN listar profissionais THEN deve mapear somente dados de descoberta',
      () async {
    // GIVEN
    httpClient.listResponses['/api/v1/professionals'] = [
      professionalSummaryJson(),
    ];
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final professionals = await professionalService.listProfessionals();

    // THEN
    expect(professionals.single.toJson(), professionalSummaryJson());
    expect(httpClient.requests.single.queryParameters, {
      'categoryIdentifier': null,
      'cityIdentifier': null,
      'keyword': null,
    });
  });

  test(
      'GIVEN profissional autenticado WHEN carregar detalhe THEN deve consultar endpoint individual',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professionals/professional-1'] =
        professionalDetailJson();
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final professional =
        await professionalService.loadProfessionalDetail('professional-1');

    // THEN
    expect(professional.professionalIdentifier, 'professional-1');
    expect(professional.serviceDescription, 'Instalacoes e manutencoes.');
    expect(
      httpClient.requests.single.path,
      '/api/v1/professionals/professional-1',
    );
  });

  test(
      'GIVEN tentativa anonima de detalhe WHEN registrar observabilidade THEN deve chamar endpoint dedicado',
      () async {
    // GIVEN
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    await professionalService.recordAnonymousProfessionalDetailAttempt(
      'professional-1',
    );

    // THEN
    expect(httpClient.requests.single.method, 'POST');
    expect(
      httpClient.requests.single.path,
      '/api/v1/professionals/professional-1/detail-access-attempts',
    );
  });

  test(
      'GIVEN requisicao basica WHEN serializar profissional THEN deve preservar nomes do contrato',
      () {
    // GIVEN
    const request = RegisterBasicProfessionalRequest(
      professionalName: 'Maria Eletricista',
      whatsappNumber: '+5551999999999',
      cityIdentifier: 'city-1',
      categoryIdentifier: 'category-1',
      shortDescription: 'Atendimento residencial.',
    );

    // WHEN + THEN
    expect(request.toJson(), {
      'professionalName': 'Maria Eletricista',
      'whatsappNumber': '+5551999999999',
      'cityIdentifier': 'city-1',
      'categoryIdentifier': 'category-1',
      'shortDescription': 'Atendimento residencial.',
    });
  });

  test(
      'GIVEN respostas completas WHEN serializar modelos THEN deve preservar contratos do backend',
      () {
    // GIVEN
    final professional = Professional.fromJson(professionalJson());
    final portfolioItem = ProfessionalPortfolioItem.fromJson(
      portfolioItemJson(),
    );

    // WHEN
    final serializedProfessional = professional.toJson();
    final serializedPortfolioItem = portfolioItem.toJson();

    // THEN
    expect(serializedProfessional, professionalJson());
    expect(serializedPortfolioItem, portfolioItemJson());
  });

  test(
      'GIVEN perfil complementar WHEN completar cadastro THEN deve usar PATCH autenticado',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professionals/professional-1/profile'] =
        professionalJson();
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final professional = await professionalService.completeProfessionalProfile(
      professionalIdentifier: 'professional-1',
      request: const CompleteProfessionalProfileRequest(
        documentNumber: '12345678900',
        usefulLink: 'https://portfolio.example/maria',
        serviceDescription: 'Instalacoes e manutencoes.',
        availabilityStatus: 'AVAILABLE_TODAY',
      ),
    );

    // THEN
    expect(professional.documentProvided, isTrue);
    expect(httpClient.requests.single.method, 'PATCH');
    expect(
      httpClient.requests.single.path,
      '/api/v1/professionals/professional-1/profile',
    );
  });

  test(
      'GIVEN profissional autenticado WHEN solicitar verificacao de telefone THEN deve chamar endpoint correto',
      () async {
    // GIVEN
    httpClient.objectResponses[
        '/api/v1/professionals/professional-1/phone-verification/request'] = {
      'professionalIdentifier': 'professional-1',
      'message': 'Codigo de verificacao enviado.',
      'expiresAt': '2026-05-13T18:05:00Z',
    };
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final result =
        await professionalService.requestProfessionalPhoneVerification(
      'professional-1',
    );

    // THEN
    expect(result.professionalIdentifier, 'professional-1');
    expect(result.expiresAt, '2026-05-13T18:05:00Z');
    expect(httpClient.requests.single.method, 'POST');
    expect(
      httpClient.requests.single.path,
      '/api/v1/professionals/professional-1/phone-verification/request',
    );
  });

  test(
      'GIVEN codigo recebido WHEN confirmar telefone THEN deve retornar profissional verificado',
      () async {
    // GIVEN
    httpClient.objectResponses[
            '/api/v1/professionals/professional-1/phone-verification/confirm'] =
        professionalJson(phoneNumberVerified: true);
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final professional =
        await professionalService.confirmProfessionalPhoneVerification(
      professionalIdentifier: 'professional-1',
      verificationCode: '123456',
    );

    // THEN
    expect(professional.phoneNumberVerified, isTrue);
    expect(httpClient.requests.single.data, {'verificationCode': '123456'});
    expect(
      httpClient.requests.single.path,
      '/api/v1/professionals/professional-1/phone-verification/confirm',
    );
  });

  test(
      'GIVEN portfolio publico WHEN listar itens THEN deve retornar metadados do backend',
      () async {
    // GIVEN
    httpClient.listResponses[
        '/api/v1/professionals/professional-1/portfolio-items'] = [
      portfolioItemJson(),
    ];
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final portfolioItems =
        await professionalService.listProfessionalPortfolioItems(
      'professional-1',
    );

    // THEN
    expect(portfolioItems.single.title, 'Quadro eletrico residencial');
    expect(portfolioItems.single.description, 'Instalacao concluida.');
    expect(
      httpClient.requests.single.path,
      '/api/v1/professionals/professional-1/portfolio-items',
    );
  });

  test(
      'GIVEN item de portfolio WHEN adicionar THEN deve enviar contrato do backend',
      () async {
    // GIVEN
    httpClient.objectResponses[
            '/api/v1/professionals/professional-1/portfolio-items'] =
        portfolioItemJson();
    final professionalService = ProfessionalService(httpClient: httpClient);

    // WHEN
    final portfolioItem =
        await professionalService.addProfessionalPortfolioItem(
      professionalIdentifier: 'professional-1',
      request: const AddProfessionalPortfolioItemRequest(
        fileIdentifier: 'file-1',
        title: 'Quadro eletrico residencial',
        description: 'Instalacao concluida.',
        displayOrder: 1,
      ),
    );

    // THEN
    expect(portfolioItem.fileIdentifier, 'file-1');
    expect(httpClient.requests.single.data, {
      'fileIdentifier': 'file-1',
      'title': 'Quadro eletrico residencial',
      'description': 'Instalacao concluida.',
      'displayOrder': 1,
    });
  });
}

Map<String, dynamic> professionalJson({bool phoneNumberVerified = false}) {
  return {
    'professionalIdentifier': 'professional-1',
    'professionalName': 'Maria Eletricista',
    'whatsappNumber': '+5551999999999',
    'cityIdentifier': 'city-1',
    'categoryIdentifier': 'category-1',
    'shortDescription': 'Atendimento residencial.',
    'profilePhotoFileIdentifier': null,
    'documentProvided': true,
    'usefulLink': 'https://portfolio.example/maria',
    'portfolioDescription': 'Quadros eletricos.',
    'serviceDescription': 'Instalacoes e manutencoes.',
    'profileCompletenessPercentage': 100,
    'profileClassification': 'COMPLETE',
    'availabilityStatus': 'AVAILABLE_TODAY',
    'availabilityBadgeLabel': 'Disponivel hoje',
    'availabilityReducesListingHighlight': false,
    'phoneNumberVerified': phoneNumberVerified,
    'qualityGuarantee': true,
  };
}

Map<String, dynamic> professionalSummaryJson({
  bool phoneNumberVerified = false,
}) {
  return {
    'professionalIdentifier': 'professional-1',
    'professionalName': 'Maria Eletricista',
    'cityIdentifier': 'city-1',
    'categoryIdentifier': 'category-1',
    'shortDescription': 'Atendimento residencial.',
    'profilePhotoFileIdentifier': null,
    'availabilityStatus': 'AVAILABLE_TODAY',
    'availabilityBadgeLabel': 'Disponivel hoje',
    'availabilityReducesListingHighlight': false,
    'phoneNumberVerified': phoneNumberVerified,
    'qualityGuarantee': true,
  };
}

Map<String, dynamic> professionalDetailJson() {
  return {
    'professionalIdentifier': 'professional-1',
    'professionalName': 'Maria Eletricista',
    'cityIdentifier': 'city-1',
    'categoryIdentifier': 'category-1',
    'shortDescription': 'Atendimento residencial.',
    'profilePhotoFileIdentifier': null,
    'usefulLink': 'https://portfolio.example/maria',
    'portfolioDescription': 'Quadros eletricos.',
    'serviceDescription': 'Instalacoes e manutencoes.',
    'profileClassification': 'COMPLETE',
    'availabilityStatus': 'AVAILABLE_TODAY',
    'availabilityBadgeLabel': 'Disponivel hoje',
    'availabilityReducesListingHighlight': false,
    'phoneNumberVerified': false,
    'qualityGuarantee': true,
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
