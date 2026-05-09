import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_intention.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_state.dart';

void main() {
  test(
      'GIVEN estado de abertura WHEN consultar estado THEN deve informar ocupado com intencao registrada',
      () {
    // GIVEN
    const contactIntention = ProfessionalContactIntention(
      contactIntentionIdentifier: 'contact-intention-1',
      professionalIdentifier: 'maria-eletricista',
      professionalName: 'Maria Eletricista',
      whatsappContactLink: 'https://wa.me/51999999999',
    );

    // WHEN
    const state = ProfessionalContactState(
      status: ProfessionalContactStatus.openingWhatsapp,
      contactIntention: contactIntention,
    );

    // THEN
    expect(state.isBusy, isTrue);
    expect(state.hasRegisteredContactIntention, isTrue);
    expect(state.hasError, isFalse);
  });

  test(
      'GIVEN estado de falha com mensagem WHEN consultar erro THEN deve informar erro visivel',
      () {
    // GIVEN / WHEN
    const state = ProfessionalContactState(
      status: ProfessionalContactStatus.failed,
      errorMessage: 'Falha ao abrir WhatsApp.',
    );

    // THEN
    expect(state.hasError, isTrue);
  });
}
