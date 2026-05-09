enum ProfessionalReportReason {
  fraud(
    'Fraude',
    false,
  ),
  harassment(
    'Assedio',
    true,
  ),
  threat(
    'Ameaca',
    true,
  ),
  fakeProfile(
    'Perfil falso',
    false,
  ),
  serviceNotPerformed(
    'Servico nao realizado',
    false,
  ),
  other(
    'Outro motivo',
    false,
  );

  const ProfessionalReportReason(this.label, this.serious);

  final String label;
  final bool serious;
}

class ProfessionalReportState {
  const ProfessionalReportState({
    this.selectedReason,
    this.description = '',
    this.evidenceFileName,
    this.errorMessage,
    this.submitted = false,
  });

  static const authorityGuidance =
      'Em caso de risco, ameaca ou violencia, busque autoridades competentes imediatamente.';

  final ProfessionalReportReason? selectedReason;
  final String description;
  final String? evidenceFileName;
  final String? errorMessage;
  final bool submitted;

  bool get canSubmit => selectedReason != null;

  bool get hasEvidence =>
      evidenceFileName != null && evidenceFileName!.trim().isNotEmpty;

  bool get shouldShowAuthorityGuidance => selectedReason?.serious ?? false;

  String get normalizedDescription => description.trim();

  ProfessionalReportState copyWith({
    ProfessionalReportReason? selectedReason,
    bool clearReason = false,
    String? description,
    String? evidenceFileName,
    bool clearEvidence = false,
    String? errorMessage,
    bool clearError = false,
    bool? submitted,
  }) {
    return ProfessionalReportState(
      selectedReason:
          clearReason ? null : selectedReason ?? this.selectedReason,
      description: description ?? this.description,
      evidenceFileName:
          clearEvidence ? null : evidenceFileName ?? this.evidenceFileName,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      submitted: submitted ?? this.submitted,
    );
  }
}
