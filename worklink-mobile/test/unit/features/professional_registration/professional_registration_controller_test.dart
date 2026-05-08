import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_controller.dart';

void main() {
  test(
      'GIVEN controlador vazio WHEN preencher campos progressivos THEN deve atualizar rascunho e completude',
      () {
    // GIVEN
    final controller = ProfessionalRegistrationController();

    // WHEN
    controller
      ..changeProfessionalName('Roberto Silva')
      ..changeCategoryName('Eletricista')
      ..changeCityDisplayName('Charqueadas - RS')
      ..changeWhatsappNumber('(51) 99999-9999')
      ..changeShortDescription('Instalacoes residenciais.')
      ..toggleProfilePhoto();

    // THEN
    expect(controller.draft.hasMinimumRequiredFields, isTrue);
    expect(controller.draft.profileCompletenessPercentage, 70);
    expect(controller.draft.hasProfilePhoto, isTrue);
  });

  test(
      'GIVEN controlador vazio WHEN preencher campos opcionais de texto THEN deve atualizar rascunho',
      () {
    // GIVEN
    final controller = ProfessionalRegistrationController();

    // WHEN
    controller
      ..changeDocumentNumber('123.456.789-00')
      ..changeInstagramProfile('@robertoeletricista')
      ..changeUsefulLink('https://worklink.example/roberto');

    // THEN
    expect(controller.draft.documentNumber, '123.456.789-00');
    expect(controller.draft.instagramProfile, '@robertoeletricista');
    expect(
      controller.draft.usefulLink,
      'https://worklink.example/roberto',
    );
  });

  test(
      'GIVEN controlador vazio WHEN selecionar valor nulo THEN deve preservar rascunho',
      () {
    // GIVEN
    final controller = ProfessionalRegistrationController();

    // WHEN
    controller
      ..changeCategoryName(null)
      ..changeCityDisplayName(null);

    // THEN
    expect(controller.draft.categoryName, isNull);
    expect(controller.draft.cityDisplayName, isNull);
  });

  test(
      'GIVEN controlador com foto WHEN alternar foto novamente THEN deve remover foto do rascunho',
      () {
    // GIVEN
    final controller = ProfessionalRegistrationController();

    // WHEN
    controller
      ..toggleProfilePhoto()
      ..toggleProfilePhoto();

    // THEN
    expect(controller.draft.hasProfilePhoto, isFalse);
  });
}
