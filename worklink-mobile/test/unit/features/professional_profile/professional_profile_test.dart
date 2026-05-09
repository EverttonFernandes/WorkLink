import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_availability/professional_availability_status.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile_review.dart';

void main() {
  test(
      'GIVEN perfil com cidades atendidas WHEN obter texto THEN deve listar cidades em ordem informada',
      () {
    // GIVEN
    const professionalProfile = ProfessionalProfile(
      professionalIdentifier: 'roberto-eletricista',
      professionalName: 'Roberto Silva',
      categoryName: 'Eletricista Residencial',
      baseCityName: 'Charqueadas',
      baseStateCode: 'RS',
      attendedCityNames: ['São Jerônimo', 'Triunfo', 'Eldorado do Sul'],
      aboutDescription:
          'Eletricista residencial com mais de 10 anos de experiência.',
      serviceNames: ['Instalações', 'Manutenção'],
    );

    // WHEN
    final attendedCitiesSummary = professionalProfile.attendedCitiesSummary;

    // THEN
    expect(attendedCitiesSummary, 'São Jerônimo, Triunfo, Eldorado do Sul');
  });

  test(
      'GIVEN perfil com dados opcionais vazios WHEN consultar secoes THEN deve ocultar secoes opcionais',
      () {
    // GIVEN
    const professionalProfile = ProfessionalProfile(
      professionalIdentifier: 'roberto-eletricista',
      professionalName: 'Roberto Silva',
      categoryName: 'Eletricista Residencial',
      baseCityName: 'Charqueadas',
      baseStateCode: 'RS',
      attendedCityNames: [],
      aboutDescription: '',
      serviceNames: [],
    );

    // WHEN / THEN
    expect(professionalProfile.hasAttendedCities, isFalse);
    expect(professionalProfile.hasAboutDescription, isFalse);
    expect(professionalProfile.hasServiceNames, isFalse);
    expect(professionalProfile.hasAvailability, isTrue);
    expect(professionalProfile.hasPortfolioItems, isFalse);
    expect(professionalProfile.hasReviewSummary, isFalse);
  });

  test(
      'GIVEN perfil completo WHEN consultar campos derivados THEN deve expor dados visiveis',
      () {
    // GIVEN
    const professionalProfile = ProfessionalProfile(
      professionalIdentifier: 'roberto-eletricista',
      professionalName: 'Roberto Silva',
      categoryName: 'Eletricista Residencial',
      baseCityName: 'Charqueadas',
      baseStateCode: 'RS',
      attendedCityNames: ['Charqueadas'],
      aboutDescription: 'Atendimento residencial especializado.',
      serviceNames: ['Instalações'],
      profilePhotoUrl: 'https://worklink.example/roberto.jpg',
      usefulLinks: ['https://worklink.example/roberto'],
      portfolioItemDescriptions: ['Instalação de quadro elétrico'],
      profileBadgeLabels: [' Perfil completo ', ''],
      profileCompletenessPercentage: 100,
      phoneNumberVerified: true,
      documentProvided: true,
      availabilityStatus: ProfessionalAvailabilityStatus.availableToday,
      reviewSummary: ProfessionalProfileReviewSummary(
        averageRating: 4.8,
        reviewCount: 4,
      ),
    );

    // WHEN
    final visibleProfileBadgeLabels =
        professionalProfile.visibleProfileBadgeLabels;

    // THEN
    expect(professionalProfile.baseCityDisplayName, 'Charqueadas - RS');
    expect(
      professionalProfile.profilePhotoUrl,
      'https://worklink.example/roberto.jpg',
    );
    expect(professionalProfile.hasUsefulLinks, isTrue);
    expect(professionalProfile.hasPortfolioItems, isTrue);
    expect(professionalProfile.hasAvailability, isTrue);
    expect(professionalProfile.hasReviewSummary, isTrue);
    expect(visibleProfileBadgeLabels, [
      'Perfil completo',
      'Telefone verificado',
      'Documento informado',
    ]);
  });

  test(
      'GIVEN perfil minimo com documento informado WHEN consultar badges THEN deve expor apenas sinal seguro',
      () {
    // GIVEN
    const professionalProfile = ProfessionalProfile(
      professionalIdentifier: 'roberto-eletricista',
      professionalName: 'Roberto Silva',
      categoryName: 'Eletricista Residencial',
      baseCityName: 'Charqueadas',
      baseStateCode: 'RS',
      attendedCityNames: [],
      aboutDescription: '',
      serviceNames: [],
      documentProvided: true,
    );

    // WHEN
    final visibleProfileBadgeLabels =
        professionalProfile.visibleProfileBadgeLabels;

    // THEN
    expect(visibleProfileBadgeLabels, [
      'Perfil básico',
      'Documento informado',
    ]);
  });
}
