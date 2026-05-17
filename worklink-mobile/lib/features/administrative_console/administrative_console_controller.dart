import 'package:flutter/foundation.dart';

import '../../services/exceptions.dart';
import 'administrative_console_state.dart';

typedef LoadAdministrativeConsole = Future<AdministrativeConsoleState>
    Function();
typedef RefreshAdministrativeConsoleAfterMutation
    = Future<AdministrativeConsoleState> Function(String identifier);
typedef RegisterAdministrativeCategory = Future<AdministrativeConsoleState>
    Function(String categoryName);
typedef ModerateAdministrativeEntry = Future<AdministrativeConsoleState>
    Function(String identifier);

class AdministrativeConsoleController extends ChangeNotifier {
  AdministrativeConsoleController({
    required this.loadAdministrativeConsole,
    required this.blockProfessional,
    required this.unblockProfessional,
    required this.approveProfessionalReport,
    required this.escalateProfessionalReport,
    required this.keepReviewPublic,
    required this.hideReviewFromPublic,
    required this.registerCategory,
    AdministrativeConsoleState initialState =
        const AdministrativeConsoleState.loading(),
  }) : _state = initialState;

  final LoadAdministrativeConsole loadAdministrativeConsole;
  final RefreshAdministrativeConsoleAfterMutation blockProfessional;
  final RefreshAdministrativeConsoleAfterMutation unblockProfessional;
  final ModerateAdministrativeEntry approveProfessionalReport;
  final ModerateAdministrativeEntry escalateProfessionalReport;
  final ModerateAdministrativeEntry keepReviewPublic;
  final ModerateAdministrativeEntry hideReviewFromPublic;
  final RegisterAdministrativeCategory registerCategory;

  AdministrativeConsoleState _state;

  AdministrativeConsoleState get state => _state;

  Future<void> loadAdministrativeConsoleAsync() async {
    await _run(() => loadAdministrativeConsole());
  }

  Future<void> blockProfessionalAsync(String professionalIdentifier) async {
    await _run(() => blockProfessional(professionalIdentifier));
  }

  Future<void> unblockProfessionalAsync(String professionalIdentifier) async {
    await _run(() => unblockProfessional(professionalIdentifier));
  }

  Future<void> approveProfessionalReportAsync(
    String professionalReportIdentifier,
  ) async {
    await _run(() => approveProfessionalReport(professionalReportIdentifier));
  }

  Future<void> escalateProfessionalReportAsync(
    String professionalReportIdentifier,
  ) async {
    await _run(() => escalateProfessionalReport(professionalReportIdentifier));
  }

  Future<void> keepReviewPublicAsync(
    String reviewAnalysisRequestIdentifier,
  ) async {
    await _run(() => keepReviewPublic(reviewAnalysisRequestIdentifier));
  }

  Future<void> hideReviewFromPublicAsync(
    String reviewAnalysisRequestIdentifier,
  ) async {
    await _run(() => hideReviewFromPublic(reviewAnalysisRequestIdentifier));
  }

  Future<void> registerCategoryAsync(String categoryName) async {
    await _run(() => registerCategory(categoryName));
  }

  Future<void> _run(
    Future<AdministrativeConsoleState> Function() action,
  ) async {
    final previousState = _state;
    _state = previousState.copyWith(
      loading: true,
      errorMessage: null,
      statusMessage: previousState.statusMessage,
    );
    notifyListeners();
    try {
      _state = await action();
    } catch (error) {
      _state = previousState.copyWith(
        loading: false,
        errorMessage: _mapErrorMessage(error),
      );
    }
    notifyListeners();
  }

  String _mapErrorMessage(Object error) {
    if (error is AuthorizationException) {
      return 'Acesso administrativo negado para esta sessao.';
    }
    if (error is ValidationException) {
      return 'Nao foi possivel concluir a acao administrativa informada.';
    }
    return 'Nao foi possivel carregar o console administrativo agora.';
  }
}
