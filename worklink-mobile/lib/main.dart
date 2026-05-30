// coverage:ignore-file

import 'dart:async';

import 'package:flutter/material.dart';

import 'app/worklink_app_configuration.dart';
import 'app/worklink_application_gateway.dart';
import 'app/worklink_theme.dart';
import 'features/administrative_console/administrative_console_controller.dart';
import 'features/administrative_console/administrative_console_screen.dart';
import 'features/customer_authentication/customer_authentication_controller.dart';
import 'features/customer_authentication/customer_authentication_screen.dart';
import 'features/customer_profile/customer_profile_controller.dart';
import 'features/customer_profile/customer_profile_screen.dart';
import 'features/customer_profile/customer_profile_state.dart';
import 'features/discovery/discovery_controller.dart';
import 'features/discovery/discovery_screen.dart';
import 'features/post_contact_feedback/pending_post_contact_feedback_prompt.dart';
import 'features/post_contact_feedback/post_contact_feedback_controller.dart';
import 'features/post_contact_feedback/post_contact_feedback_request.dart';
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
  if (_loadPreviewDataEnabled()) {
    runApp(
      WorkLinkApp.preview(
        applicationConfiguration: WorkLinkAppConfiguration(
          administrativeConsoleEnabled: _loadAdministrativeConsoleEnabled(),
        ),
      ),
    );
    return;
  }

  runApp(
    WorkLinkApp(
      applicationConfiguration: WorkLinkAppConfiguration(
        administrativeConsoleEnabled: _loadAdministrativeConsoleEnabled(),
      ),
      applicationGateway: WorkLinkBackendGateway(
        administrativeAccessToken: _loadAdministrativeAccessToken(),
      ),
    ),
  );
}
// coverage:ignore-end

bool _loadPreviewDataEnabled() {
  return const String.fromEnvironment('WORKLINK_USE_PREVIEW_DATA') == 'true';
}

bool _loadAdministrativeConsoleEnabled() {
  return const String.fromEnvironment('WORKLINK_ENABLE_ADMIN_CONSOLE') ==
      'true';
}

String? _loadAdministrativeAccessToken() {
  const administrativeAccessToken = String.fromEnvironment(
    'WORKLINK_ADMIN_ACCESS_TOKEN',
  );
  return administrativeAccessToken.isEmpty ? null : administrativeAccessToken;
}

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
  CustomerProfileState? customerProfileState;
  List<PostContactFeedbackRequest> pendingPostContactFeedbackRequests =
      const [];
  late Future<WorkLinkHomeData> homeDataFuture;

  @override
  void initState() {
    super.initState();
    homeDataFuture = widget.applicationGateway.loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: widget.applicationConfiguration.applicationName,
      theme: buildWorkLinkTheme(),
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
      preFiltersContent: _buildPendingPostContactFeedbackPrompt(context),
      onOpenProfessionalProfile: (professionalIdentifier) {
        final professionalProfile = homeData.professionalProfiles.firstWhere(
          (profile) => profile.professionalIdentifier == professionalIdentifier,
        );
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProfessionalProfileScreen(
              professionalProfile: professionalProfile,
              savedByCustomer: _isProfessionalSavedByCustomer(
                professionalProfile.professionalIdentifier,
              ),
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
              onToggleSavedProfessional: (currentlySaved) =>
                  _toggleSavedProfessional(
                context,
                professionalProfile.professionalIdentifier,
                currentlySaved,
              ),
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
      onOpenAdministrativeConsole: _shouldExposeAdministrativeConsole()
          ? () => _openAdministrativeConsole(context)
          : null,
      onOpenCustomerProfile: () =>
          unawaited(_handleOpenCustomerProfile(context)),
    );
  }

  bool _shouldExposeAdministrativeConsole() {
    return widget.applicationConfiguration.administrativeConsoleEnabled &&
        widget.applicationGateway.administrativeConsoleAvailable;
  }

  void _handleContactProfessional(
    BuildContext context,
    ProfessionalProfile professionalProfile,
  ) {
    if (!customerAuthenticated) {
      unawaited(
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
                unawaited(_refreshPendingPostContactFeedbackRequests());
                Navigator.of(authenticationContext).pop();
              },
            ),
          ),
        ),
      );
      return;
    }

    unawaited(_openProfessionalContact(context, professionalProfile));
  }

  Future<void> _openProfessionalContact(
    BuildContext context,
    ProfessionalProfile professionalProfile,
  ) async {
    await Navigator.of(context).push(
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
    await _refreshPendingPostContactFeedbackRequests();
  }

  Future<void> _handleOpenCustomerProfile(BuildContext context) async {
    if (!customerAuthenticated) {
      unawaited(
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
                unawaited(_refreshPendingPostContactFeedbackRequests());
                Navigator.of(authenticationContext).pop();
                unawaited(_openCustomerProfile(context));
              },
            ),
          ),
        ),
      );
      return;
    }

    await _openCustomerProfile(context);
  }

  Future<void> _openCustomerProfile(BuildContext context) async {
    final navigator = Navigator.of(context);
    final loadedCustomerProfileState =
        await widget.applicationGateway.loadCustomerProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      customerProfileState = loadedCustomerProfileState;
    });
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (profileContext) => CustomerProfileScreen(
          customerProfileController: CustomerProfileController(
            initialState: loadedCustomerProfileState,
            onPreferencesChanged: ({
              required bool whatsappNotificationsEnabled,
              required bool profilePersonalizationEnabled,
            }) async {
              final persistedCustomerProfileState = await widget
                  .applicationGateway
                  .updateCustomerProfilePreferences(
                whatsappNotificationsEnabled: whatsappNotificationsEnabled,
                profilePersonalizationEnabled: profilePersonalizationEnabled,
              );
              if (mounted) {
                setState(() {
                  customerProfileState = persistedCustomerProfileState;
                });
              }
              return persistedCustomerProfileState;
            },
          ),
          onLogout: () {
            setState(() {
              customerAuthenticated = false;
              customerProfileState = null;
              pendingPostContactFeedbackRequests = const [];
            });
            Navigator.of(profileContext).pop();
          },
        ),
      ),
    );
  }

  Future<void> _openAdministrativeConsole(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdministrativeConsoleScreen(
          administrativeConsoleController: AdministrativeConsoleController(
            loadAdministrativeConsole:
                widget.applicationGateway.loadAdministrativeConsole,
            blockProfessional:
                widget.applicationGateway.blockAdministrativeProfessional,
            unblockProfessional:
                widget.applicationGateway.unblockAdministrativeProfessional,
            approveProfessionalReport: widget
                .applicationGateway.approveAdministrativeProfessionalReport,
            escalateProfessionalReport: widget
                .applicationGateway.escalateAdministrativeProfessionalReport,
            keepReviewPublic:
                widget.applicationGateway.keepAdministrativeReviewPublic,
            hideReviewFromPublic:
                widget.applicationGateway.hideAdministrativeReviewFromPublic,
            registerCategory:
                widget.applicationGateway.registerAdministrativeCategory,
          ),
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

  Future<void> _openPostContactFeedback(
    BuildContext context,
    String contactIntentionIdentifier,
  ) async {
    await Navigator.of(context).push(
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
    await _refreshPendingPostContactFeedbackRequests();
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

  bool _isProfessionalSavedByCustomer(String professionalIdentifier) {
    return customerProfileState?.savedProfessionals.any(
          (savedProfessional) =>
              savedProfessional.professionalIdentifier ==
              professionalIdentifier,
        ) ??
        false;
  }

  Future<bool> _toggleSavedProfessional(
    BuildContext context,
    String professionalIdentifier,
    bool currentlySaved,
  ) async {
    final authenticated = await _ensureCustomerAuthenticated(context);
    if (!authenticated) {
      return currentlySaved;
    }
    final updatedCustomerProfileState = currentlySaved
        ? await widget.applicationGateway.removeSavedProfessionalForCustomer(
            professionalIdentifier,
          )
        : await widget.applicationGateway.saveProfessionalForCustomer(
            professionalIdentifier,
          );
    if (mounted) {
      setState(() {
        customerProfileState = updatedCustomerProfileState;
      });
    }
    return updatedCustomerProfileState.savedProfessionals.any(
      (savedProfessional) =>
          savedProfessional.professionalIdentifier == professionalIdentifier,
    );
  }

  Future<bool> _ensureCustomerAuthenticated(BuildContext context) async {
    if (customerAuthenticated) {
      return true;
    }
    final authenticationCompleter = Completer<bool>();
    await Navigator.of(context).push(
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
            unawaited(_refreshPendingPostContactFeedbackRequests());
            authenticationCompleter.complete(true);
            Navigator.of(authenticationContext).pop();
          },
        ),
      ),
    );
    if (!authenticationCompleter.isCompleted) {
      authenticationCompleter.complete(false);
    }
    return authenticationCompleter.future;
  }

  Widget? _buildPendingPostContactFeedbackPrompt(BuildContext context) {
    if (!customerAuthenticated || pendingPostContactFeedbackRequests.isEmpty) {
      return null;
    }
    final request = pendingPostContactFeedbackRequests.first;
    return PendingPostContactFeedbackPrompt(
      request: request,
      onRespond: () => unawaited(
        _openPostContactFeedback(context, request.contactIntentionIdentifier),
      ),
      onDismiss: () => unawaited(
        _dismissPendingPostContactFeedbackRequest(
          request.contactIntentionIdentifier,
        ),
      ),
    );
  }

  Future<void> _dismissPendingPostContactFeedbackRequest(
    String contactIntentionIdentifier,
  ) async {
    await widget.applicationGateway.dismissPostContactFeedbackRequest(
      contactIntentionIdentifier,
    );
    await _refreshPendingPostContactFeedbackRequests();
  }

  Future<void> _refreshPendingPostContactFeedbackRequests() async {
    if (!customerAuthenticated) {
      if (mounted) {
        setState(() {
          pendingPostContactFeedbackRequests = const [];
        });
      }
      return;
    }
    final requests = await widget.applicationGateway
        .loadPendingPostContactFeedbackRequests();
    if (!mounted) {
      return;
    }
    setState(() {
      pendingPostContactFeedbackRequests = requests;
    });
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
