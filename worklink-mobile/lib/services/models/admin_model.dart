// ignore_for_file: sort_constructors_first

class AdministrativeProfessionalModel {
  const AdministrativeProfessionalModel({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.cityIdentifier,
    required this.categoryIdentifier,
    required this.profileClassification,
    required this.availabilityStatus,
    required this.blocked,
  });

  final String professionalIdentifier;
  final String professionalName;
  final String cityIdentifier;
  final String categoryIdentifier;
  final String profileClassification;
  final String availabilityStatus;
  final bool blocked;

  factory AdministrativeProfessionalModel.fromJson(Map<String, dynamic> json) {
    return AdministrativeProfessionalModel(
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      professionalName: json['professionalName']?.toString() ?? '',
      cityIdentifier: json['cityIdentifier']?.toString() ?? '',
      categoryIdentifier: json['categoryIdentifier']?.toString() ?? '',
      profileClassification: json['profileClassification']?.toString() ?? '',
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      blocked: json['blocked'] == true,
    );
  }
}

class AdministrativeProfessionalReportModel {
  const AdministrativeProfessionalReportModel({
    required this.professionalReportIdentifier,
    required this.professionalIdentifier,
    required this.reportReason,
    required this.seriousCase,
    this.evidenceFileIdentifier,
    required this.moderationStatus,
    this.moderationDecision,
    this.moderationNotes,
    this.decidedAt,
    required this.createdAt,
  });

  final String professionalReportIdentifier;
  final String professionalIdentifier;
  final String reportReason;
  final bool seriousCase;
  final String? evidenceFileIdentifier;
  final String moderationStatus;
  final String? moderationDecision;
  final String? moderationNotes;
  final DateTime? decidedAt;
  final DateTime createdAt;

  factory AdministrativeProfessionalReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdministrativeProfessionalReportModel(
      professionalReportIdentifier:
          json['professionalReportIdentifier']?.toString() ?? '',
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      reportReason: json['reportReason']?.toString() ?? '',
      seriousCase: json['seriousCase'] == true,
      evidenceFileIdentifier: json['evidenceFileIdentifier']?.toString(),
      moderationStatus: json['moderationStatus']?.toString() ?? '',
      moderationDecision: json['moderationDecision']?.toString(),
      moderationNotes: json['moderationNotes']?.toString(),
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'].toString()),
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}

class AdministrativeReviewAnalysisRequestModel {
  const AdministrativeReviewAnalysisRequestModel({
    required this.reviewAnalysisRequestIdentifier,
    required this.professionalReviewIdentifier,
    required this.professionalIdentifier,
    required this.requestedByProfessionalIdentifier,
    required this.moderationStatus,
    this.moderationDecision,
    this.moderationNotes,
    this.decidedAt,
    required this.createdAt,
  });

  final String reviewAnalysisRequestIdentifier;
  final String professionalReviewIdentifier;
  final String professionalIdentifier;
  final String requestedByProfessionalIdentifier;
  final String moderationStatus;
  final String? moderationDecision;
  final String? moderationNotes;
  final DateTime? decidedAt;
  final DateTime createdAt;

  factory AdministrativeReviewAnalysisRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdministrativeReviewAnalysisRequestModel(
      reviewAnalysisRequestIdentifier:
          json['reviewAnalysisRequestIdentifier']?.toString() ?? '',
      professionalReviewIdentifier:
          json['professionalReviewIdentifier']?.toString() ?? '',
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      requestedByProfessionalIdentifier:
          json['requestedByProfessionalIdentifier']?.toString() ?? '',
      moderationStatus: json['moderationStatus']?.toString() ?? '',
      moderationDecision: json['moderationDecision']?.toString(),
      moderationNotes: json['moderationNotes']?.toString(),
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'].toString()),
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}

class AdministrativeMetricsModel {
  const AdministrativeMetricsModel({
    required this.professionalCount,
    required this.blockedProfessionalCount,
    required this.professionalReportCount,
    required this.reviewAnalysisRequestCount,
    required this.serviceCategoryCount,
  });

  final int professionalCount;
  final int blockedProfessionalCount;
  final int professionalReportCount;
  final int reviewAnalysisRequestCount;
  final int serviceCategoryCount;

  factory AdministrativeMetricsModel.fromJson(Map<String, dynamic> json) {
    return AdministrativeMetricsModel(
      professionalCount: _readInt(json['professionalCount']),
      blockedProfessionalCount: _readInt(json['blockedProfessionalCount']),
      professionalReportCount: _readInt(json['professionalReportCount']),
      reviewAnalysisRequestCount: _readInt(json['reviewAnalysisRequestCount']),
      serviceCategoryCount: _readInt(json['serviceCategoryCount']),
    );
  }
}

class ContactMetricModel {
  const ContactMetricModel({
    required this.metricIdentifier,
    required this.contactCount,
  });

  final String metricIdentifier;
  final int contactCount;

  factory ContactMetricModel.fromJson(Map<String, dynamic> json) {
    return ContactMetricModel(
      metricIdentifier: json['metricIdentifier']?.toString() ?? '',
      contactCount: _readInt(json['contactCount']),
    );
  }
}

class ProfessionalMetricSummaryModel {
  const ProfessionalMetricSummaryModel({
    required this.activeProfessionalCount,
    required this.completeProfessionalCount,
    required this.availableProfessionalCount,
    required this.unavailableProfessionalCount,
    required this.professionalsWithContactCount,
  });

  final int activeProfessionalCount;
  final int completeProfessionalCount;
  final int availableProfessionalCount;
  final int unavailableProfessionalCount;
  final int professionalsWithContactCount;

  factory ProfessionalMetricSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalMetricSummaryModel(
      activeProfessionalCount: _readInt(json['activeProfessionalCount']),
      completeProfessionalCount: _readInt(json['completeProfessionalCount']),
      availableProfessionalCount: _readInt(json['availableProfessionalCount']),
      unavailableProfessionalCount:
          _readInt(json['unavailableProfessionalCount']),
      professionalsWithContactCount:
          _readInt(json['professionalsWithContactCount']),
    );
  }
}

class ResponsivenessSummaryModel {
  const ResponsivenessSummaryModel({
    required this.respondedContactPercentage,
    required this.noResponsePercentage,
    required this.servicePerformedPercentage,
    required this.postContactAnswerRatePercentage,
  });

  final double respondedContactPercentage;
  final double noResponsePercentage;
  final double servicePerformedPercentage;
  final double postContactAnswerRatePercentage;

  factory ResponsivenessSummaryModel.fromJson(Map<String, dynamic> json) {
    return ResponsivenessSummaryModel(
      respondedContactPercentage:
          _readDouble(json['respondedContactPercentage']),
      noResponsePercentage: _readDouble(json['noResponsePercentage']),
      servicePerformedPercentage:
          _readDouble(json['servicePerformedPercentage']),
      postContactAnswerRatePercentage:
          _readDouble(json['postContactAnswerRatePercentage']),
    );
  }
}

class ResponsivenessMetricModel {
  const ResponsivenessMetricModel({
    required this.contactResponsiveness,
    required this.feedbackCount,
  });

  final String contactResponsiveness;
  final int feedbackCount;

  factory ResponsivenessMetricModel.fromJson(Map<String, dynamic> json) {
    return ResponsivenessMetricModel(
      contactResponsiveness: json['contactResponsiveness']?.toString() ?? '',
      feedbackCount: _readInt(json['feedbackCount']),
    );
  }
}

class ReputationSummaryModel {
  const ReputationSummaryModel({
    required this.reviewCount,
    required this.averageRating,
    required this.anonymousReviewCount,
    required this.professionalReportCount,
    required this.reviewAnalysisRequestCount,
  });

  final int reviewCount;
  final double averageRating;
  final int anonymousReviewCount;
  final int professionalReportCount;
  final int reviewAnalysisRequestCount;

  factory ReputationSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReputationSummaryModel(
      reviewCount: _readInt(json['reviewCount']),
      averageRating: _readDouble(json['averageRating']),
      anonymousReviewCount: _readInt(json['anonymousReviewCount']),
      professionalReportCount: _readInt(json['professionalReportCount']),
      reviewAnalysisRequestCount: _readInt(json['reviewAnalysisRequestCount']),
    );
  }
}

class ReputationMetricModel {
  const ReputationMetricModel({
    required this.professionalIdentifier,
    required this.averageRating,
    required this.reviewCount,
  });

  final String professionalIdentifier;
  final double averageRating;
  final int reviewCount;

  factory ReputationMetricModel.fromJson(Map<String, dynamic> json) {
    return ReputationMetricModel(
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      averageRating: _readDouble(json['averageRating']),
      reviewCount: _readInt(json['reviewCount']),
    );
  }
}

class FunctionalMetricsModel {
  const FunctionalMetricsModel({
    required this.searchCount,
    required this.searchWithoutResultCount,
    required this.contactCount,
    required this.postContactFeedbackCount,
    required this.reviewCount,
    required this.anonymousReviewCount,
    required this.professionalReportCount,
    required this.reviewAnalysisRequestCount,
    required this.rankingAlgorithmEnabled,
    required this.searchesByCategory,
    required this.searchesByCity,
    required this.contactsByProfessional,
    required this.contactsByCategory,
    required this.contactsByCity,
    required this.professionalSummary,
    required this.responsivenessSummary,
    required this.responsivenessSignals,
    required this.reputationSummary,
    required this.reputationSignals,
  });

  final int searchCount;
  final int searchWithoutResultCount;
  final int contactCount;
  final int postContactFeedbackCount;
  final int reviewCount;
  final int anonymousReviewCount;
  final int professionalReportCount;
  final int reviewAnalysisRequestCount;
  final bool rankingAlgorithmEnabled;
  final List<ContactMetricModel> searchesByCategory;
  final List<ContactMetricModel> searchesByCity;
  final List<ContactMetricModel> contactsByProfessional;
  final List<ContactMetricModel> contactsByCategory;
  final List<ContactMetricModel> contactsByCity;
  final ProfessionalMetricSummaryModel professionalSummary;
  final ResponsivenessSummaryModel responsivenessSummary;
  final List<ResponsivenessMetricModel> responsivenessSignals;
  final ReputationSummaryModel reputationSummary;
  final List<ReputationMetricModel> reputationSignals;

  factory FunctionalMetricsModel.fromJson(Map<String, dynamic> json) {
    return FunctionalMetricsModel(
      searchCount: _readInt(json['searchCount']),
      searchWithoutResultCount: _readInt(json['searchWithoutResultCount']),
      contactCount: _readInt(json['contactCount']),
      postContactFeedbackCount: _readInt(json['postContactFeedbackCount']),
      reviewCount: _readInt(json['reviewCount']),
      anonymousReviewCount: _readInt(json['anonymousReviewCount']),
      professionalReportCount: _readInt(json['professionalReportCount']),
      reviewAnalysisRequestCount: _readInt(json['reviewAnalysisRequestCount']),
      rankingAlgorithmEnabled: json['rankingAlgorithmEnabled'] == true,
      searchesByCategory: _mapList(
        json['searchesByCategory'],
        ContactMetricModel.fromJson,
      ),
      searchesByCity:
          _mapList(json['searchesByCity'], ContactMetricModel.fromJson),
      contactsByProfessional: _mapList(
        json['contactsByProfessional'],
        ContactMetricModel.fromJson,
      ),
      contactsByCategory: _mapList(
        json['contactsByCategory'],
        ContactMetricModel.fromJson,
      ),
      contactsByCity:
          _mapList(json['contactsByCity'], ContactMetricModel.fromJson),
      professionalSummary: ProfessionalMetricSummaryModel.fromJson(
        Map<String, dynamic>.from(json['professionalSummary'] as Map? ?? {}),
      ),
      responsivenessSummary: ResponsivenessSummaryModel.fromJson(
        Map<String, dynamic>.from(json['responsivenessSummary'] as Map? ?? {}),
      ),
      responsivenessSignals: _mapList(
        json['responsivenessSignals'],
        ResponsivenessMetricModel.fromJson,
      ),
      reputationSummary: ReputationSummaryModel.fromJson(
        Map<String, dynamic>.from(json['reputationSummary'] as Map? ?? {}),
      ),
      reputationSignals: _mapList(
        json['reputationSignals'],
        ReputationMetricModel.fromJson,
      ),
    );
  }
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _readDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<T> _mapList<T>(
  Object? value,
  T Function(Map<String, dynamic>) mapper,
) {
  final listValue = value as List? ?? const [];
  return listValue
      .map((item) => mapper(Map<String, dynamic>.from(item as Map)))
      .toList();
}
