// coverage:ignore-file

import 'package:flutter/material.dart';

import 'app/worklink_app_configuration.dart';
import 'app/worklink_application_gateway.dart';
import 'features/customer_authentication/customer_authentication_controller.dart';
import 'features/customer_authentication/customer_authentication_screen.dart';
import 'features/customer_profile/customer_profile_controller.dart';
import 'features/customer_profile/customer_profile_screen.dart';
import 'features/customer_profile/customer_profile_state.dart';
import 'features/discovery/discovery_controller.dart';
import 'features/discovery/discovery_screen.dart';
import 'features/post_contact_feedback/post_contact_feedback_controller.dart';
import 'features/post_contact_feedback/post_contact_feedback_screen.dart';
import 'features/professional_contact/professional_contact_controller.dart';
import 'features/professional_contact/professional_contact_screen.dart';
import 'features/professional_profile/professional_profile.dart';
import 'features/professional_profile/professional_profile_screen.dart';
import 'features/professional_registration/professional_registration_controller.dart';
import 'features/professional_registration/professional_registration_draft.dart';
import 'features/professional_registration/professional_registration_screen.dart';
import 'features/professional_report/professional_report_controller.dart';
import 'features/professional_report/professional_report_screen.dart';
import 'features/professional_review/professional_review_controller.dart';
import 'features/professional_review/professional_review_screen.dart';

// coverage:ignore-start
void main() {
  runApp(WorkLinkApp(applicationGateway: WorkLinkBackendGateway()));
}
// coverage:ignore-end

class WorkLinkApp extends StatefulWidget {
  const WorkLinkApp({
    super.key,
    this.applicationConfiguration = const WorkLinkAppConfiguration(),
    required this.applicationGateway,
  });

  const WorkLinkApp.preview({
    super.key,
    this.applicationConfiguration = const WorkLinkAppConfiguration(),
  }) : applicationGateway = const WorkLinkPreviewGateway();

  final WorkLinkAppConfiguration applicationConfiguration;
  final WorkLinkApplicationGateway applicationGateway;

  @override
  State<WorkLinkApp> createState() => _WorkLinkAppState();
}

class _WorkLinkAppState extends State<WorkLinkApp> {
  bool customerAuthenticated = false;
  String customerPhoneNumber = '(51) 9 9999-9999';
  late Future<WorkLinkHomeData> homeDataFuture;

  @override
  void initState() {
    super.initState();
    homeDataFuture = widget.applicationGateway.loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.applicationConfiguration.applicationName,
      home: Builder(
        builder: (context) => FutureBuilder<WorkLinkHomeData>(
          future: homeDataFuture,
          initialData: widget.applicationGateway.initialHomeData,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _WorkLinkUnavailableHome(
                onRetry: () {
                  setState(() {
                    homeDataFuture = widget.applicationGateway.loadHomeData();
                  });
                },
              );
            }
            final homeData = snapshot.data;
            if (homeData == null) {
              return const _WorkLinkLoadingHome();
            }
            return _buildDiscoveryScreen(context, homeData);
          },
        ),
      ),
    );
  }

  DiscoveryScreen _buildDiscoveryScreen(
    BuildContext context,
    WorkLinkHomeData homeData,
  ) {
    return DiscoveryScreen(
      discoveryController: DiscoveryController(
        availableProfessionals: homeData.discoveryProfessionals,
      ),
      onOpenProfessionalProfile: (professionalIdentifier) {
        final professionalProfile = homeData.professionalProfiles.firstWhere(
          (profile) => profile.professionalIdentifier == professionalIdentifier,
        );
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProfessionalProfileScreen(
              professionalProfile: professionalProfile,
              onContactProfessional: (_) => _handleContactProfessional(
                context,
                professionalProfile,
              ),
              onReportProfessional: (_) => _openProfessionalReport(
                context,
                professionalProfile,
              ),
              onRequestReviewAnalysis:
                  widget.applicationGateway.requestProfessionalReviewAnalysis,
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
                  homeData.professionalRegistrationCategoryNames,
              availableCityDisplayNames:
                  homeData.professionalRegistrationCityDisplayNames,
              onContinue: (draft) {
                widget.applicationGateway.registerProfessional(draft, homeData);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
      onOpenCustomerProfile: () => _handleOpenCustomerProfile(context),
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
                _buildCustomerAuthenticationController(),
            onAuthenticationCompleted: (authenticatedPhoneNumber) {
              setState(() {
                customerAuthenticated = true;
                customerPhoneNumber =
                    _formatAuthenticatedPhoneNumber(authenticatedPhoneNumber);
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
                widget.applicationGateway.startProfessionalContact,
            openProfessionalWhatsappContact: (_) async => true,
          ),
          onOpenPostContactFeedback: (contactIntentionIdentifier) =>
              _openPostContactFeedback(context, contactIntentionIdentifier),
        ),
      ),
    );
  }

  void _handleOpenCustomerProfile(BuildContext context) {
    if (!customerAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (authenticationContext) => CustomerAuthenticationScreen(
            customerAuthenticationController:
                _buildCustomerAuthenticationController(),
            onAuthenticationCompleted: (authenticatedPhoneNumber) {
              setState(() {
                customerAuthenticated = true;
                customerPhoneNumber =
                    _formatAuthenticatedPhoneNumber(authenticatedPhoneNumber);
              });
              Navigator.of(authenticationContext).pop();
              _openCustomerProfile(context);
            },
          ),
        ),
      );
      return;
    }

    _openCustomerProfile(context);
  }

  void _openCustomerProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (profileContext) => CustomerProfileScreen(
          customerProfileController: CustomerProfileController(
            initialState: CustomerProfileState(
              customerName: 'Cliente WorkLink',
              phoneNumber: customerPhoneNumber,
              mainCity: const CustomerProfileCity(
                cityName: 'Canoas',
                stateCode: 'RS',
              ),
              selectedCities: const [
                CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
                CustomerProfileCity(cityName: 'Porto Alegre', stateCode: 'RS'),
              ],
              savedProfessionals: const [
                CustomerSavedProfessional(
                  professionalIdentifier: 'maria-eletricista',
                  professionalName: 'Maria Eletricista',
                  categoryName: 'Eletricista',
                  cityDisplayName: 'Canoas - RS',
                ),
              ],
              submittedReviews: const [
                CustomerSubmittedReview(
                  professionalName: 'Maria Eletricista',
                  starRating: 5,
                  publiclyAnonymous: true,
                  comment: 'Atendimento rapido e organizado.',
                ),
              ],
            ),
          ),
          onLogout: () {
            setState(() {
              customerAuthenticated = false;
            });
            Navigator.of(profileContext).pop();
          },
        ),
      ),
    );
  }

  CustomerAuthenticationController _buildCustomerAuthenticationController() {
    return CustomerAuthenticationController(
      requestCustomerAuthenticationCode:
          widget.applicationGateway.requestCustomerAuthenticationCode,
      confirmCustomerAuthenticationCode:
          widget.applicationGateway.confirmCustomerAuthenticationCode,
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
            submitPostContactFeedback:
                widget.applicationGateway.submitPostContactFeedback,
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
            submitProfessionalReview:
                widget.applicationGateway.submitProfessionalReview,
          ),
        ),
      ),
    );
  }

  void _openProfessionalReport(
    BuildContext context,
    ProfessionalProfile professionalProfile,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfessionalReportScreen(
          professionalName: professionalProfile.professionalName,
          professionalReportController: ProfessionalReportController(
            professionalIdentifier: professionalProfile.professionalIdentifier,
            submitProfessionalReport:
                widget.applicationGateway.submitProfessionalReport,
          ),
        ),
      ),
    );
  }

  String _formatAuthenticatedPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 2)}) '
          '${phoneNumber.substring(2, 3)} '
          '${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    }
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 2)}) '
          '${phoneNumber.substring(2, 6)}-${phoneNumber.substring(6)}';
    }
    return phoneNumber;
  }
}

class _WorkLinkLoadingHome extends StatelessWidget {
  const _WorkLinkLoadingHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _WorkLinkUnavailableHome extends StatelessWidget {
  const _WorkLinkUnavailableHome({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WorkLink')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Nao foi possivel carregar os dados do WorkLink agora.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
