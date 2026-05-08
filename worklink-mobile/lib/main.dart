import 'package:flutter/material.dart';

import 'app/worklink_app_configuration.dart';
import 'features/discovery/discovery_controller.dart';
import 'features/discovery/discovery_professional.dart';
import 'features/discovery/discovery_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: applicationConfiguration.applicationName,
      home: DiscoveryScreen(
        discoveryController: DiscoveryController(
          availableProfessionals: const [
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
          ],
        ),
      ),
    );
  }
}
