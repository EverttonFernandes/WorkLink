import 'package:flutter/foundation.dart';

import 'professional_report_state.dart';

typedef SubmitProfessionalReport = Future<void> Function(
  String professionalIdentifier,
  ProfessionalReportState reportState,
);

class ProfessionalReportController extends ChangeNotifier {
  ProfessionalReportController({
    required this.professionalIdentifier,
    required this.submitProfessionalReport,
  });

  final String professionalIdentifier;
  final SubmitProfessionalReport submitProfessionalReport;

  ProfessionalReportState _state = const ProfessionalReportState();

  ProfessionalReportState get state => _state;

  void selectReason(ProfessionalReportReason reportReason) {
    _state = _state.copyWith(
      selectedReason: reportReason,
      clearError: true,
    );
    notifyListeners();
  }

  void updateDescription(String description) {
    _state = _state.copyWith(description: description, clearError: true);
    notifyListeners();
  }

  void attachEvidence(String evidenceFileName) {
    _state = _state.copyWith(evidenceFileName: evidenceFileName);
    notifyListeners();
  }

  void removeEvidence() {
    _state = _state.copyWith(clearEvidence: true);
    notifyListeners();
  }

  Future<void> submitReport() async {
    if (!_state.canSubmit) {
      _state = _state.copyWith(
        errorMessage: 'Selecione um motivo para enviar a denuncia.',
      );
      notifyListeners();
      return;
    }

    await submitProfessionalReport(professionalIdentifier, _state);
    _state = _state.copyWith(submitted: true, clearError: true);
    notifyListeners();
  }
}
