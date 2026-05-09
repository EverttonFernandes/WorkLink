// coverage:ignore-file

import 'package:flutter/material.dart';

import 'app/worklink_app_configuration.dart';
import 'features/customer_authentication/customer_authentication_controller.dart';
import 'features/customer_authentication/customer_authentication_screen.dart';
import 'features/discovery/discovery_controller.dart';
import 'features/discovery/discovery_professional.dart';
import 'features/discovery/discovery_screen.dart';
import 'features/post_contact_feedback/post_contact_feedback_controller.dart';
import 'features/post_contact_feedback/post_contact_feedback_screen.dart';
import 'features/professional_availability/professional_availability_status.dart';
import 'features/professional_contact/professional_contact_controller.dart';
import 'features/professional_contact/professional_contact_intention.dart';
import 'features/professional_contact/professional_contact_screen.dart';
import 'features/professional_profile/professional_profile.dart';
import 'features/professional_profile/professional_profile_review.dart';
import 'features/professional_profile/professional_profile_screen.dart';
import 'features/professional_registration/professional_registration_controller.dart';
import 'features/professional_registration/professional_registration_draft.dart';
import 'features/professional_registration/professional_registration_screen.dart';
import 'features/professional_review/professional_review_controller.dart';
import 'features/professional_review/professional_review_screen.dart';

// coverage:ignore-start
void main() {
  runApp(const WorkLinkApp());
}
// coverage:ignore-end

class WorkLinkApp extends StatefulWidget {
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
      availabilityStatus: ProfessionalAvailabilityStatus.availableToday,
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
      profileCompletenessPercentage: 100,
      phoneNumberVerified: true,
      documentProvided: true,
      availabilityStatus: ProfessionalAvailabilityStatus.availableThisWeek,
      reviewSummary: ProfessionalProfileReviewSummary(
        averageRating: 4.5,
        reviewCount: 2,
        comments: [
          ProfessionalProfileReviewComment(
            professionalReviewIdentifier: 'review-maria-1',
            starRating: 5,
            publicAuthorDisplayName: 'Usuario anonimo',
            comment: 'Atendimento rapido e organizado.',
          ),
        ],
      ),
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
  State<WorkLinkApp> createState() => _WorkLinkAppState();
}

class _WorkLinkAppState extends State<WorkLinkApp> {
  bool customerAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.applicationConfiguration.applicationName,
      home: Builder(
        builder: (context) => DiscoveryScreen(
          discoveryController: DiscoveryController(
            availableProfessionals: WorkLinkApp.sampleDiscoveryProfessionals,
          ),
          onOpenProfessionalProfile: (professionalIdentifier) {
            final professionalProfile =
                WorkLinkApp.sampleProfessionalProfiles.firstWhere(
              (profile) =>
                  profile.professionalIdentifier == professionalIdentifier,
            );
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProfessionalProfileScreen(
                  professionalProfile: professionalProfile,
                  onContactProfessional: (_) => _handleContactProfessional(
                    context,
                    professionalProfile,
                  ),
                  onRequestReviewAnalysis: (_) {},
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
                      WorkLinkApp.sampleProfessionalRegistrationCategories,
                  availableCityDisplayNames:
                      WorkLinkApp.sampleProfessionalRegistrationCities,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleContactProfessional(
    BuildContext context,
    ProfessionalProfile professionalProfile,
  ) {
    if (!customerAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (authenticationContext) => CustomerAuthenticationScreen(
            customerAuthenticationController:
                CustomerAuthenticationController(),
            onAuthenticationCompleted: (_) {
              setState(() {
                customerAuthenticated = true;
              });
              Navigator.of(authenticationContext).pop();
            },
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfessionalContactScreen(
          professionalIdentifier: professionalProfile.professionalIdentifier,
          professionalName: professionalProfile.professionalName,
          professionalContactController: ProfessionalContactController(
            registerProfessionalContactIntention:
                (professionalIdentifier) async {
              return ProfessionalContactIntention(
                contactIntentionIdentifier:
                    'contact-intention-$professionalIdentifier',
                professionalIdentifier: professionalIdentifier,
                professionalName: professionalProfile.professionalName,
                whatsappContactLink: 'https://wa.me/51999999999',
              );
            },
            openProfessionalWhatsappContact: (_) async => true,
          ),
          onOpenPostContactFeedback: (contactIntentionIdentifier) =>
              _openPostContactFeedback(context, contactIntentionIdentifier),
        ),
      ),
    );
  }

  void _openPostContactFeedback(
    BuildContext context,
    String contactIntentionIdentifier,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PostContactFeedbackScreen(
          postContactFeedbackController: PostContactFeedbackController(
            contactIntentionIdentifier: contactIntentionIdentifier,
            submitPostContactFeedback: (_, __) async {},
          ),
          onOpenProfessionalReview: (reviewContactIntentionIdentifier) =>
              _openProfessionalReview(
            context,
            reviewContactIntentionIdentifier,
          ),
        ),
      ),
    );
  }

  void _openProfessionalReview(
    BuildContext context,
    String contactIntentionIdentifier,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfessionalReviewScreen(
          professionalReviewController: ProfessionalReviewController(
            contactIntentionIdentifier: contactIntentionIdentifier,
            submitProfessionalReview: (_, __) async {},
          ),
        ),
      ),
    );
  }
}
