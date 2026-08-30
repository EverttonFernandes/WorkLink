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
import 'features/customer_authentication/customer_authentication_state.dart';
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
import 'services/exceptions.dart';

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
    this.themeFontFamily,
  });

  const WorkLinkApp.preview({
    super.key,
    this.applicationConfiguration = const WorkLinkAppConfiguration(),
    this.themeFontFamily,
  }) : applicationGateway = const WorkLinkPreviewGateway();

  final WorkLinkAppConfiguration applicationConfiguration;
  final WorkLinkApplicationGateway applicationGateway;
  final String? themeFontFamily;

  @override
  State<WorkLinkApp> createState() => _WorkLinkAppState();
}

class _WorkLinkAppState extends State<WorkLinkApp> {
  bool customerAuthenticated = false;
  bool guestDiscoveryChoiceAcknowledged = false;
  CustomerProfileState? customerProfileState;
  List<PostContactFeedbackRequest> pendingPostContactFeedbackRequests =
      const [];
  late Future<WorkLinkHomeData> homeDataFuture;

  @override
  void initState() {
    super.initState();
    homeDataFuture = _bootstrapHomeData();
  }

  Future<WorkLinkHomeData> _bootstrapHomeData() async {
    final sessionRestored =
        await widget.applicationGateway.restoreCustomerSession();
    if (mounted) {
      setState(() {
        customerAuthenticated = sessionRestored;
      });
    } else {
      customerAuthenticated = sessionRestored;
    }
    return widget.applicationGateway.loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: widget.applicationConfiguration.applicationName,
      theme: buildWorkLinkTheme(fontFamily: widget.themeFontFamily),
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
      preFiltersContent: _buildDiscoveryTopContent(context),
      onOpenProfessionalProfile: (professionalIdentifier) => unawaited(
        _handleOpenProfessionalProfile(
          context,
          professionalIdentifier,
        ),
      ),
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

  Widget? _buildDiscoveryTopContent(BuildContext context) {
    final topWidgets = <Widget>[];
    final pendingPrompt = _buildPendingPostContactFeedbackPrompt(context);
    if (!customerAuthenticated && !guestDiscoveryChoiceAcknowledged) {
      topWidgets.add(
        _AnonymousDiscoveryEntryCard(
          onContinueWithoutLogin: () {
            setState(() {
              guestDiscoveryChoiceAcknowledged = true;
            });
          },
          onOpenSignIn: () => unawaited(
            _ensureCustomerAuthenticated(context),
          ),
          onOpenSignUp: () => unawaited(
            _ensureCustomerAuthenticated(
              context,
              initialMode: CustomerAuthenticationMode.signUp,
            ),
          ),
        ),
      );
    }
    if (pendingPrompt != null) {
      topWidgets.add(pendingPrompt);
    }
    if (topWidgets.isEmpty) {
      return null;
    }
    return Column(
      children: [
        for (var index = 0; index < topWidgets.length; index++) ...[
          topWidgets[index],
          if (index < topWidgets.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Future<void> _handleOpenProfessionalProfile(
    BuildContext context,
    String professionalIdentifier,
  ) async {
    if (!customerAuthenticated) {
      await _recordAnonymousProfessionalDetailAttempt(
        professionalIdentifier,
      );
    }
    if (!mounted || !context.mounted) {
      return;
    }
    final authenticated = await _ensureCustomerAuthenticated(context);
    if (!authenticated || !mounted || !context.mounted) {
      return;
    }
    final professionalProfile = await _loadProtectedProfessionalProfile(
      context,
      professionalIdentifier,
    );
    if (professionalProfile != null && mounted && context.mounted) {
      await _openProfessionalProfile(context, professionalProfile);
    }
  }

  Future<void> _recordAnonymousProfessionalDetailAttempt(
    String professionalIdentifier,
  ) async {
    try {
      await widget.applicationGateway
          .recordAnonymousProfessionalDetailAttempt(professionalIdentifier);
    } catch (_) {
      // Observabilidade não deve impedir o usuário de chegar à autenticação.
    }
  }

  Future<ProfessionalProfile?> _loadProtectedProfessionalProfile(
    BuildContext context,
    String professionalIdentifier,
  ) async {
    try {
      return await widget.applicationGateway.loadProfessionalProfile(
        professionalIdentifier,
      );
    } catch (error) {
      if (_isAuthorizationError(error)) {
        _showAuthorizationError(context);
        return null;
      }
      if (!_isUnauthenticatedSessionError(error)) {
        rethrow;
      }
    }

    await _handleExpiredCustomerSession();
    if (!mounted || !context.mounted) {
      return null;
    }
    final authenticatedAgain = await _ensureCustomerAuthenticated(context);
    if (!authenticatedAgain || !mounted || !context.mounted) {
      return null;
    }
    try {
      return await widget.applicationGateway.loadProfessionalProfile(
        professionalIdentifier,
      );
    } catch (error) {
      if (_isUnauthenticatedSessionError(error)) {
        await _handleExpiredCustomerSession();
        return null;
      }
      if (_isAuthorizationError(error)) {
        _showAuthorizationError(context);
        return null;
      }
      rethrow;
    }
  }

  Future<void> _openProfessionalProfile(
    BuildContext context,
    ProfessionalProfile professionalProfile,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfessionalProfileScreen(
          professionalProfile: professionalProfile,
          savedByCustomer: _isProfessionalSavedByCustomer(
            professionalProfile.professionalIdentifier,
          ),
          onContactProfessional: (_) =>
              _handleContactProfessional(context, professionalProfile),
          onReportProfessional: (_) =>
              _openProfessionalReport(context, professionalProfile),
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
              onAuthenticationCompleted: (_) {
                setState(() {
                  customerAuthenticated = true;
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
    try {
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
    } catch (error) {
      if (_isUnauthenticatedSessionError(error)) {
        await _handleExpiredCustomerSession();
        return;
      } else if (_isAuthorizationError(error)) {
        if (context.mounted) {
          _showAuthorizationError(context);
        }
        return;
      } else {
        rethrow;
      }
    }
    await _refreshPendingPostContactFeedbackRequests();
  }

  Future<void> _handleOpenCustomerProfile(BuildContext context) async {
    if (!customerAuthenticated) {
      final authenticated = await _ensureCustomerAuthenticated(context);
      if (authenticated && mounted && context.mounted) {
        await _openCustomerProfile(context);
      }
      return;
    }

    await _openCustomerProfile(context);
  }

  Future<void> _openCustomerProfile(BuildContext context) async {
    try {
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
            onLogout: () => unawaited(_logoutCustomer(profileContext)),
          ),
        ),
      );
    } catch (error) {
      if (_isUnauthenticatedSessionError(error)) {
        await _handleExpiredCustomerSession();
      } else if (_isAuthorizationError(error)) {
        if (context.mounted) {
          _showAuthorizationError(context);
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> _logoutCustomer(BuildContext profileContext) async {
    try {
      await widget.applicationGateway.logout();
    } catch (_) {
      // A sessão local deve ser encerrada mesmo quando a revogação remota falhar.
    }
    if (!mounted) {
      return;
    }
    setState(() {
      customerAuthenticated = false;
      guestDiscoveryChoiceAcknowledged = false;
      customerProfileState = null;
      pendingPostContactFeedbackRequests = const [];
    });
    if (profileContext.mounted) {
      Navigator.of(profileContext).pop();
    }
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
      authenticateWithEmailAndPassword:
          widget.applicationGateway.authenticateWithEmailAndPassword,
      registerLocalAccount: widget.applicationGateway.registerLocalAccount,
      requestPasswordRecovery:
          widget.applicationGateway.requestPasswordRecovery,
      resetPassword: widget.applicationGateway.resetPassword,
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
    CustomerProfileState updatedCustomerProfileState;
    try {
      updatedCustomerProfileState = currentlySaved
          ? await widget.applicationGateway.removeSavedProfessionalForCustomer(
              professionalIdentifier,
            )
          : await widget.applicationGateway.saveProfessionalForCustomer(
              professionalIdentifier,
            );
    } catch (error) {
      if (_isUnauthenticatedSessionError(error)) {
        await _handleExpiredCustomerSession();
        return currentlySaved;
      }
      if (_isAuthorizationError(error)) {
        if (context.mounted) {
          _showAuthorizationError(context);
        }
        return currentlySaved;
      }
      rethrow;
    }
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

  Future<bool> _ensureCustomerAuthenticated(
    BuildContext context, {
    CustomerAuthenticationMode initialMode = CustomerAuthenticationMode.signIn,
  }) async {
    if (customerAuthenticated) {
      return true;
    }
    final authenticationCompleter = Completer<bool>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (authenticationContext) => CustomerAuthenticationScreen(
          customerAuthenticationController: CustomerAuthenticationController(
            authenticateWithEmailAndPassword:
                widget.applicationGateway.authenticateWithEmailAndPassword,
            registerLocalAccount:
                widget.applicationGateway.registerLocalAccount,
            requestPasswordRecovery:
                widget.applicationGateway.requestPasswordRecovery,
            resetPassword: widget.applicationGateway.resetPassword,
            initialState: CustomerAuthenticationState(mode: initialMode),
          ),
          onAuthenticationCompleted: (_) {
            setState(() {
              customerAuthenticated = true;
              guestDiscoveryChoiceAcknowledged = true;
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

  Future<void> _handleExpiredCustomerSession() async {
    if (!mounted) {
      return;
    }
    try {
      await widget.applicationGateway.logout();
    } catch (_) {
      // O objetivo aqui e limpar a sessao local mesmo quando a revogacao remota falhar.
    }
    if (!mounted) {
      return;
    }
    setState(() {
      customerAuthenticated = false;
      guestDiscoveryChoiceAcknowledged = false;
      customerProfileState = null;
      pendingPostContactFeedbackRequests = const [];
    });
  }

  bool _isUnauthenticatedSessionError(Object error) {
    return error is ApiException && error.statusCode == 401;
  }

  bool _isAuthorizationError(Object error) {
    return error is ApiException && error.statusCode == 403;
  }

  void _showAuthorizationError(BuildContext context) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Você não tem autorização para acessar este recurso.',
        ),
      ),
    );
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

class _AnonymousDiscoveryEntryCard extends StatelessWidget {
  const _AnonymousDiscoveryEntryCard({
    required this.onContinueWithoutLogin,
    required this.onOpenSignIn,
    required this.onOpenSignUp,
  });

  final VoidCallback onContinueWithoutLogin;
  final VoidCallback onOpenSignIn;
  final VoidCallback onOpenSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4EBF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140E223D),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_search_rounded, color: Color(0xFF18C55E)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Explore antes de entrar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF163253),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Você pode pesquisar profissionais sem conta. Para abrir o perfil completo e seguir com segurança, entre ou crie sua conta.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF4A607A),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final signInButton = OutlinedButton.icon(
                key: const ValueKey('guest-open-sign-in-button'),
                onPressed: onOpenSignIn,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Entrar'),
              );
              final signUpButton = ElevatedButton.icon(
                key: const ValueKey('guest-open-sign-up-button'),
                onPressed: onOpenSignUp,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Criar conta agora'),
              );
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    signInButton,
                    const SizedBox(height: 10),
                    signUpButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: signInButton),
                  const SizedBox(width: 12),
                  Expanded(child: signUpButton),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const ValueKey('guest-continue-without-login-button'),
              onPressed: onContinueWithoutLogin,
              child: const Text('Continuar sem login'),
            ),
          ),
        ],
      ),
    );
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
      appBar: AppBar(title: const Text('Profissional Perto')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Nao foi possivel carregar os dados do Profissional Perto agora.',
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
