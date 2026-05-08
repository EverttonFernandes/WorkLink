import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_registration/professional_registration_draft.dart';

void main() {
  test(
      'GIVEN cadastro minimo WHEN calcular completude THEN deve indicar campos minimos preenchidos',
      () {
    // GIVEN
    const draft = ProfessionalRegistrationDraft(
      professionalName: 'Roberto Silva',
      categoryName: 'Eletricista',
      cityDisplayName: 'Charqueadas - RS',
      whatsappNumber: '(51) 99999-9999',
      shortDescription: 'Instalacoes e manutencoes residenciais.',
    );

    // WHEN
    final profileCompletenessPercentage = draft.profileCompletenessPercentage;

    // THEN
    expect(draft.hasMinimumRequiredFields, isTrue);
    expect(profileCompletenessPercentage, 60);
    expect(draft.stepLabel, 'Etapa 1 de 2');
  });

  test(
      'GIVEN cadastro com campos opcionais WHEN calcular completude THEN deve aumentar sem prometer qualidade',
      () {
    // GIVEN
    const draft = ProfessionalRegistrationDraft(
      professionalName: 'Roberto Silva',
      documentNumber: '123.456.789-00',
      categoryName: 'Eletricista',
      cityDisplayName: 'Charqueadas - RS',
      whatsappNumber: '(51) 99999-9999',
      shortDescription: 'Instalacoes e manutencoes residenciais.',
      instagramProfile: '@robertoeletricista',
      usefulLink: 'https://worklink.example/roberto',
      hasProfilePhoto: true,
    );

    // WHEN
    final completenessLabel = draft.completenessLabel;

    // THEN
    expect(draft.profileCompletenessPercentage, 100);
    expect(draft.stepLabel, 'Etapa 2 de 2');
    expect(completenessLabel, '100% do perfil preenchido');
  });

  test(
      'GIVEN cadastro incompleto WHEN validar campos minimos THEN deve impedir continuacao obrigatoria',
      () {
    // GIVEN
    const draft = ProfessionalRegistrationDraft(
      professionalName: 'Roberto Silva',
    );

    // WHEN / THEN
    expect(draft.hasMinimumRequiredFields, isFalse);
    expect(draft.profileCompletenessPercentage, 10);
  });
}
