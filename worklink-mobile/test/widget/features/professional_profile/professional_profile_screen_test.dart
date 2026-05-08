import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile_screen.dart';

void main() {
  const completeProfessionalProfile = ProfessionalProfile(
    professionalIdentifier: 'roberto-eletricista',
    professionalName: 'Roberto Silva',
    categoryName: 'Eletricista Residencial',
    baseCityName: 'Charqueadas',
    baseStateCode: 'RS',
    attendedCityNames: ['São Jerônimo', 'Triunfo'],
    aboutDescription:
        'Atende instalações elétricas residenciais com segurança.',
    serviceNames: ['Instalações', 'Manutenção'],
    usefulLinks: ['https://worklink.example/roberto'],
    portfolioItemDescriptions: ['Quadro elétrico residencial'],
    profileBadgeLabels: ['Perfil verificado'],
    availabilityLabel: 'Disponível esta semana',
    reviewSummary: '4.9 em 128 avaliações',
  );

  Future<void> pumpProfessionalProfileScreen(
    WidgetTester widgetTester,
    ProfessionalProfile professionalProfile, {
    ValueChanged<String>? onContactProfessional,
    ValueChanged<String>? onReportProfessional,
  }) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: ProfessionalProfileScreen(
          professionalProfile: professionalProfile,
          onContactProfessional: onContactProfessional,
          onReportProfessional: onReportProfessional,
        ),
      ),
    );
  }

  testWidgets(
      'GIVEN perfil completo WHEN renderizar THEN deve mostrar dados principais e secoes preenchidas',
      (widgetTester) async {
    // GIVEN / WHEN
    await pumpProfessionalProfileScreen(
      widgetTester,
      completeProfessionalProfile,
    );

    // THEN
    expect(find.text('Perfil do profissional'), findsOneWidget);
    expect(find.text('Roberto Silva'), findsOneWidget);
    expect(find.text('Eletricista Residencial'), findsOneWidget);
    expect(find.text('Charqueadas - RS'), findsOneWidget);
    expect(find.text('Atendimento em: São Jerônimo, Triunfo'), findsOneWidget);
    expect(find.text('Perfil verificado'), findsOneWidget);
    expect(find.text('Disponível esta semana'), findsOneWidget);
    expect(find.text('Instalações'), findsOneWidget);
    await widgetTester.scrollUntilVisible(
      find.text('Quadro elétrico residencial'),
      120,
    );
    expect(find.text('Quadro elétrico residencial'), findsOneWidget);
    expect(
      find.text('Completude do perfil não garante qualidade do serviço.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN perfil sem dados opcionais WHEN renderizar THEN nao deve mostrar secoes vazias',
      (widgetTester) async {
    // GIVEN
    const minimalProfessionalProfile = ProfessionalProfile(
      professionalIdentifier: 'roberto-eletricista',
      professionalName: 'Roberto Silva',
      categoryName: 'Eletricista Residencial',
      baseCityName: 'Charqueadas',
      baseStateCode: 'RS',
      attendedCityNames: [],
      aboutDescription: '',
      serviceNames: [],
    );

    // WHEN
    await pumpProfessionalProfileScreen(
      widgetTester,
      minimalProfessionalProfile,
    );

    // THEN
    expect(find.text('Roberto Silva'), findsOneWidget);
    expect(find.text('Atendimento em:'), findsNothing);
    expect(find.text('Sobre mim'), findsNothing);
    expect(find.text('Serviços'), findsNothing);
    expect(find.text('Portfólio'), findsNothing);
    expect(find.text('Avaliações'), findsNothing);
  });

  testWidgets(
      'GIVEN perfil publico WHEN tocar contato THEN deve emitir identificador',
      (widgetTester) async {
    // GIVEN
    final contactedProfessionalIdentifiers = <String>[];
    await pumpProfessionalProfileScreen(
      widgetTester,
      completeProfessionalProfile,
      onContactProfessional: contactedProfessionalIdentifiers.add,
    );

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('contact-professional-roberto-eletricista')),
    );
    await widgetTester.pump();

    // THEN
    expect(contactedProfessionalIdentifiers, ['roberto-eletricista']);
  });

  testWidgets(
      'GIVEN perfil publico WHEN tocar denunciar THEN deve emitir identificador',
      (widgetTester) async {
    // GIVEN
    final reportedProfessionalIdentifiers = <String>[];
    await pumpProfessionalProfileScreen(
      widgetTester,
      completeProfessionalProfile,
      onReportProfessional: reportedProfessionalIdentifiers.add,
    );

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('report-professional-roberto-eletricista')),
    );
    await widgetTester.pump();

    // THEN
    expect(reportedProfessionalIdentifiers, ['roberto-eletricista']);
  });
}
