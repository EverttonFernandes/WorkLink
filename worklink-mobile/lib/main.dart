// coverage:ignore-file

import 'package:flutter/material.dart';

import 'app/worklink_app_configuration.dart';
import 'features/discovery/discovery_controller.dart';
import 'features/discovery/discovery_professional.dart';
import 'features/discovery/discovery_screen.dart';
import 'features/professional_profile/professional_profile.dart';
import 'features/professional_profile/professional_profile_screen.dart';
import 'features/professional_registration/professional_registration_controller.dart';
import 'features/professional_registration/professional_registration_draft.dart';
import 'features/professional_registration/professional_registration_screen.dart';

// coverage:ignore-start
void main() {
  runApp(const WorkLinkApp());
}
// coverage:ignore-end

class WorkLinkApp extends StatelessWidget {
  const WorkLinkApp({
    super.key,
    this.applicationConfiguration = const WorkLinkAppConfiguration(),
  });

  final WorkLinkAppConfiguration applicationConfiguration;

  static const List<DiscoveryProfessional> sampleDiscoveryProfessionals = [
    DiscoveryProfessional(
      professionalIdentifier: 'maria-eletricista',
      professionalName: 'Maria Eletricista',
      categoryName: 'Eletricista',
      cityName: 'Canoas',
      stateCode: 'RS',
      shortDescription: 'Atendimento residencial.',
      profileBadgeLabel: 'Perfil básico',
      recentActivityLabel: 'Ativo recentemente',
    ),
    DiscoveryProfessional(
      professionalIdentifier: 'ana-pintora',
      professionalName: 'Ana Pintora',
      categoryName: 'Pintora',
      cityName: 'Porto Alegre',
      stateCode: 'RS',
      shortDescription: 'Pintura interna e acabamento.',
    ),
  ];

  static const List<ProfessionalProfile> sampleProfessionalProfiles = [
    ProfessionalProfile(
      professionalIdentifier: 'maria-eletricista',
      professionalName: 'Maria Eletricista',
      categoryName: 'Eletricista',
      baseCityName: 'Canoas',
      baseStateCode: 'RS',
      attendedCityNames: ['Canoas', 'Esteio', 'Porto Alegre'],
      aboutDescription:
          'Atendimento residencial com foco em instalações, reparos e manutenção preventiva.',
      serviceNames: ['Instalações', 'Manutenção', 'Emergências'],
      usefulLinks: ['https://worklink.example/maria-eletricista'],
      portfolioItemDescriptions: [
        'Instalação de luminárias',
        'Quadro elétrico residencial',
      ],
      profileBadgeLabels: ['Perfil básico'],
      availabilityLabel: 'Atende esta semana',
      reviewSummary: 'Avaliações serão exibidas quando estiverem disponíveis.',
    ),
    ProfessionalProfile(
      professionalIdentifier: 'ana-pintora',
      professionalName: 'Ana Pintora',
      categoryName: 'Pintora',
      baseCityName: 'Porto Alegre',
      baseStateCode: 'RS',
      attendedCityNames: ['Porto Alegre'],
      aboutDescription:
          'Pintura interna e acabamento para reformas residenciais.',
      serviceNames: ['Pintura interna', 'Acabamento'],
    ),
  ];

  static const List<String> sampleProfessionalRegistrationCategories = [
    'Eletricista',
    'Pintora',
  ];

  static const List<String> sampleProfessionalRegistrationCities = [
    'Canoas - RS',
    'Porto Alegre - RS',
    'Charqueadas - RS',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: applicationConfiguration.applicationName,
      home: Builder(
        builder: (context) => DiscoveryScreen(
          discoveryController: DiscoveryController(
            availableProfessionals: sampleDiscoveryProfessionals,
          ),
          onOpenProfessionalProfile: (professionalIdentifier) {
            final professionalProfile = sampleProfessionalProfiles.firstWhere(
              (profile) =>
                  profile.professionalIdentifier == professionalIdentifier,
            );
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProfessionalProfileScreen(
                  professionalProfile: professionalProfile,
                ),
              ),
            );
          },
          onOpenProfessionalRegistration: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProfessionalRegistrationScreen(
                  professionalRegistrationController:
                      ProfessionalRegistrationController(
                    initialDraft: const ProfessionalRegistrationDraft(
                      categoryName: 'Eletricista',
                      cityDisplayName: 'Charqueadas - RS',
                    ),
                  ),
                  availableCategoryNames:
                      sampleProfessionalRegistrationCategories,
                  availableCityDisplayNames:
                      sampleProfessionalRegistrationCities,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
