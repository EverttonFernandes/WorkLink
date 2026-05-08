import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile.dart';

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
      availabilityLabel: '',
      reviewSummary: '',
    );

    // WHEN / THEN
    expect(professionalProfile.hasAttendedCities, isFalse);
    expect(professionalProfile.hasAboutDescription, isFalse);
    expect(professionalProfile.hasServiceNames, isFalse);
    expect(professionalProfile.hasAvailability, isFalse);
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
      availabilityLabel: 'Disponível hoje',
      reviewSummary: '4 avaliações positivas',
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
    expect(visibleProfileBadgeLabels, [' Perfil completo ']);
  });
}
