// ignore_for_file: sort_constructors_first

class RegisterProfessionalReportRequest {
  const RegisterProfessionalReportRequest({
    required this.professionalIdentifier,
    required this.reportReason,
    required this.description,
    this.evidenceFileIdentifier,
  });

  final String professionalIdentifier;
  final String reportReason;
  final String description;
  final String? evidenceFileIdentifier;

  Map<String, Object?> toJson() {
    return {
      'professionalIdentifier': professionalIdentifier,
      'reportReason': reportReason,
      'description': description.trim().isEmpty ? null : description.trim(),
      'evidenceFileIdentifier': evidenceFileIdentifier,
    };
  }
}

class ProfessionalReport {
  const ProfessionalReport({
    required this.professionalReportIdentifier,
    required this.professionalIdentifier,
    required this.reportReason,
    required this.description,
    this.evidenceFileIdentifier,
    required this.seriousCase,
    required this.authorityGuidance,
    required this.createdAt,
  });

  final String professionalReportIdentifier;
  final String professionalIdentifier;
  final String reportReason;
  final String description;
  final String? evidenceFileIdentifier;
  final bool seriousCase;
  final String authorityGuidance;
  final DateTime createdAt;

  factory ProfessionalReport.fromJson(Map<String, dynamic> json) {
    return ProfessionalReport(
      professionalReportIdentifier:
          json['professionalReportIdentifier']?.toString() ?? '',
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      reportReason: json['reportReason']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      evidenceFileIdentifier: json['evidenceFileIdentifier']?.toString(),
      seriousCase: json['seriousCase'] == true,
      authorityGuidance: json['authorityGuidance']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}
