import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_controller.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_intention.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_state.dart';

void main() {
  const contactIntention = ProfessionalContactIntention(
    contactIntentionIdentifier: 'contact-intention-1',
    professionalIdentifier: 'maria-eletricista',
    professionalName: 'Maria Eletricista',
    whatsappContactLink: 'https://wa.me/51999999999',
  );

  test(
      'GIVEN contato autenticado WHEN iniciar contato THEN deve registrar intencao antes de abrir WhatsApp',
      () async {
    // GIVEN
    final executedSteps = <String>[];
    final controller = ProfessionalContactController(
      registerProfessionalContactIntention: (professionalIdentifier) async {
        executedSteps.add('registrar-$professionalIdentifier');
        return contactIntention;
      },
      openProfessionalWhatsappContact: (whatsappContactLink) async {
        executedSteps.add('abrir-$whatsappContactLink');
        return true;
      },
    );

    // WHEN
    await controller.startProfessionalContact('maria-eletricista');

    // THEN
    expect(executedSteps, [
      'registrar-maria-eletricista',
      'abrir-https://wa.me/51999999999',
    ]);
    expect(controller.state.status, ProfessionalContactStatus.completed);
    expect(controller.state.contactIntention, contactIntention);
  });

  test(
      'GIVEN falha no redirecionamento WHEN iniciar contato THEN deve manter intencao registrada e exibir erro',
      () async {
    // GIVEN
    final controller = ProfessionalContactController(
      registerProfessionalContactIntention: (_) async => contactIntention,
      openProfessionalWhatsappContact: (_) async => false,
    );

    // WHEN
    await controller.startProfessionalContact('maria-eletricista');

    // THEN
    expect(controller.state.status, ProfessionalContactStatus.failed);
    expect(controller.state.hasRegisteredContactIntention, isTrue);
    expect(
      controller.state.errorMessage,
      'Nao foi possivel abrir o WhatsApp. Tente novamente em instantes.',
    );
  });

  test(
      'GIVEN falha no registro WHEN iniciar contato THEN nao deve tentar abrir WhatsApp',
      () async {
    // GIVEN
    var whatsappOpenAttempts = 0;
    final controller = ProfessionalContactController(
      registerProfessionalContactIntention: (_) async {
        throw StateError('backend indisponivel');
      },
      openProfessionalWhatsappContact: (_) async {
        whatsappOpenAttempts++;
        return true;
      },
    );

    // WHEN
    await controller.startProfessionalContact('maria-eletricista');

    // THEN
    expect(whatsappOpenAttempts, 0);
    expect(controller.state.status, ProfessionalContactStatus.failed);
    expect(controller.state.hasRegisteredContactIntention, isFalse);
    expect(
      controller.state.errorMessage,
      'Nao foi possivel registrar sua intencao de contato agora.',
    );
  });
}
