import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/contact_service.dart';
import 'package:worklink_mobile/services/models/contact_model.dart';
import 'package:worklink_mobile/services/models/review_model.dart';
import 'package:worklink_mobile/services/review_service.dart';

import 'fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
  });

  test(
      'GIVEN profissional escolhido WHEN iniciar contato THEN deve registrar intencao',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/contact-intentions'] = {
      'contactIntentIdentifier': 'contact-1',
      'professionalIdentifier': 'professional-1',
      'professionalName': 'Maria Eletricista',
      'whatsappContactLink': 'https://wa.me/5551999999999',
      'createdAt': '2026-05-13T10:00:00Z',
      'externalNegotiationNotice':
          'A negociacao acontece fora do WorkLink pelo WhatsApp.',
      'noServiceGuaranteeNotice':
          'O WorkLink nao garante a execucao do servico contratado.',
    };
    final contactService = ContactService(httpClient: httpClient);

    // WHEN
    final contact = await contactService.startProfessionalContact(
      'professional-1',
    );

    // THEN
    expect(contact.contactIntentIdentifier, 'contact-1');
    expect(httpClient.requests.single.path, '/api/v1/contact-intentions');
    expect(
      httpClient.requests.single.data,
      {'professionalIdentifier': 'professional-1'},
    );
  });

  test(
      'GIVEN feedback pos-contato WHEN enviar respostas THEN deve usar endpoint dedicado',
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
    final contactService = ContactService(httpClient: httpClient);

    // WHEN
    final feedback = await contactService.registerPostContactFeedback(
      const RegisterPostContactFeedbackRequest(
        contactIntentIdentifier: 'contact-1',
        conversationOutcome: 'CUSTOMER_REACHED_PROFESSIONAL',
        contactResponsiveness: 'FAST_RESPONSE',
        serviceExecutionOutcome: 'SERVICE_PERFORMED',
      ),
    );

    // THEN
    expect(feedback.postContactFeedbackIdentifier, 'feedback-1');
    expect(httpClient.requests.single.path, '/api/v1/post-contact-feedbacks');
  });

  test(
      'GIVEN solicitacoes pendentes WHEN carregar e dispensar THEN deve usar endpoints privados do cliente',
      () async {
    // GIVEN
    httpClient.listResponses[
        '/api/v1/customers/me/post-contact-feedback-requests'] = [
      {
        'contactIntentIdentifier': 'contact-1',
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria Eletricista',
        'contactCreatedAt': '2026-05-13T10:00:00Z',
      },
    ];
    final contactService = ContactService(httpClient: httpClient);

    // WHEN
    final requests =
        await contactService.listPendingPostContactFeedbackRequests();
    await contactService.dismissPostContactFeedbackRequest('contact-1');

    // THEN
    expect(requests.single.contactIntentIdentifier, 'contact-1');
    expect(requests.single.professionalName, 'Maria Eletricista');
    expect(
      httpClient.requests.map((request) => request.path),
      [
        '/api/v1/customers/me/post-contact-feedback-requests',
        '/api/v1/customers/me/post-contact-feedback-requests/contact-1/dismiss',
      ],
    );
  });

  test(
      'GIVEN contato concluido WHEN avaliar profissional THEN comentario deve ser opcional',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/professional-reviews'] = reviewJson();
    final reviewService = ReviewService(httpClient: httpClient);

    // WHEN
    final review = await reviewService.registerProfessionalReview(
      const RegisterProfessionalReviewRequest(
        contactIntentIdentifier: 'contact-1',
        starRating: 5,
        comment: '',
        anonymousToPublic: true,
      ),
    );

    // THEN
    expect(review.professionalReviewIdentifier, 'review-1');
    expect(httpClient.requests.single.data, {
      'contactIntentIdentifier': 'contact-1',
      'starRating': 5,
      'comment': null,
      'anonymousToPublic': true,
    });
    expect(ReviewValidation.isValid(5, ''), isTrue);
  });

  test(
      'GIVEN profissional no perfil WHEN carregar avaliacoes THEN deve ler resumo publico',
      () async {
    // GIVEN
    const path = '/api/v1/professional-reviews/professionals/professional-1';
    httpClient.objectResponses[path] = {
      'professionalIdentifier': 'professional-1',
      'summary': {
        'averageRating': 4.8,
        'reviewCount': 1,
        'hasReviews': true,
      },
      'reviews': [reviewJson()],
    };
    final reviewService = ReviewService(httpClient: httpClient);

    // WHEN
    final profile = await reviewService.listProfessionalReviewProfile(
      'professional-1',
    );

    // THEN
    expect(profile.summary.averageRating, 4.8);
    expect(profile.reviews.single.starRating, 5);
    expect(httpClient.requests.single.path, path);
  });

  test(
      'GIVEN avaliacao contestada WHEN solicitar analise THEN deve chamar endpoint da avaliacao',
      () async {
    // GIVEN
    const path = '/api/v1/professional-reviews/review-1/analysis-requests';
    httpClient.objectResponses[path] = {
      'reviewAnalysisRequestIdentifier': 'analysis-1',
      'professionalReviewIdentifier': 'review-1',
      'professionalIdentifier': 'professional-1',
      'requestedByProfessionalIdentifier': 'professional-1',
      'reason': 'Comentario nao corresponde ao atendimento.',
      'createdAt': '2026-05-13T10:00:00Z',
    };
    final reviewService = ReviewService(httpClient: httpClient);

    // WHEN
    final request = await reviewService.requestProfessionalReviewAnalysis(
      professionalReviewIdentifier: 'review-1',
      reason: 'Comentario nao corresponde ao atendimento.',
    );

    // THEN
    expect(request.reviewAnalysisRequestIdentifier, 'analysis-1');
    expect(httpClient.requests.single.path, path);
    expect(httpClient.requests.single.data, {
      'reason': 'Comentario nao corresponde ao atendimento.',
    });
  });

  test(
      'GIVEN comentario acima do limite WHEN validar avaliacao THEN deve rejeitar',
      () {
    // GIVEN
    final oversizedComment = 'a' * (ReviewValidation.maxCommentLength + 1);

    // WHEN + THEN
    expect(ReviewValidation.validateRating(0), isNotNull);
    expect(ReviewValidation.validateComment(oversizedComment), isNotNull);
    expect(ReviewValidation.isValid(6, oversizedComment), isFalse);
  });
}

Map<String, dynamic> reviewJson() {
  return {
    'professionalReviewIdentifier': 'review-1',
    'contactIntentIdentifier': 'contact-1',
    'professionalIdentifier': 'professional-1',
    'starRating': 5,
    'comment': '',
    'anonymousToPublic': true,
    'publicAuthorIdentifier': null,
    'publicAuthorDisplayName': 'Usuario anonimo',
    'createdAt': '2026-05-13T10:00:00Z',
  };
}
