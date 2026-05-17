class AdministrativeConsoleState {
  const AdministrativeConsoleState({
    this.loading = false,
    this.errorMessage,
    this.statusMessage,
    this.professionals = const [],
    this.professionalReports = const [],
    this.reviewAnalysisRequests = const [],
    this.categoryNames = const [],
    this.administrativeMetrics = const AdministrativeMetricsSummary(),
    this.functionalMetrics = const AdministrativeFunctionalMetricsSummary(),
  });

  const AdministrativeConsoleState.loading()
      : loading = true,
        errorMessage = null,
        statusMessage = null,
        professionals = const [],
        professionalReports = const [],
        reviewAnalysisRequests = const [],
        categoryNames = const [],
        administrativeMetrics = const AdministrativeMetricsSummary(),
        functionalMetrics = const AdministrativeFunctionalMetricsSummary();

  final bool loading;
  final String? errorMessage;
  final String? statusMessage;
  final List<AdministrativeProfessionalItem> professionals;
  final List<AdministrativeProfessionalReportItem> professionalReports;
  final List<AdministrativeReviewAnalysisItem> reviewAnalysisRequests;
  final List<String> categoryNames;
  final AdministrativeMetricsSummary administrativeMetrics;
  final AdministrativeFunctionalMetricsSummary functionalMetrics;

  bool get hasContent =>
      professionals.isNotEmpty ||
      professionalReports.isNotEmpty ||
      reviewAnalysisRequests.isNotEmpty ||
      categoryNames.isNotEmpty;

  AdministrativeConsoleState copyWith({
    bool? loading,
    Object? errorMessage = _sentinel,
    Object? statusMessage = _sentinel,
    List<AdministrativeProfessionalItem>? professionals,
    List<AdministrativeProfessionalReportItem>? professionalReports,
    List<AdministrativeReviewAnalysisItem>? reviewAnalysisRequests,
    List<String>? categoryNames,
    AdministrativeMetricsSummary? administrativeMetrics,
    AdministrativeFunctionalMetricsSummary? functionalMetrics,
  }) {
    return AdministrativeConsoleState(
      loading: loading ?? this.loading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      statusMessage: identical(statusMessage, _sentinel)
          ? this.statusMessage
          : statusMessage as String?,
      professionals: professionals ?? this.professionals,
      professionalReports: professionalReports ?? this.professionalReports,
      reviewAnalysisRequests:
          reviewAnalysisRequests ?? this.reviewAnalysisRequests,
      categoryNames: categoryNames ?? this.categoryNames,
      administrativeMetrics:
          administrativeMetrics ?? this.administrativeMetrics,
      functionalMetrics: functionalMetrics ?? this.functionalMetrics,
    );
  }
}

class AdministrativeProfessionalItem {
  const AdministrativeProfessionalItem({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.cityDisplayName,
    required this.categoryName,
    required this.profileClassification,
    required this.availabilityLabel,
    required this.blocked,
  });

  final String professionalIdentifier;
  final String professionalName;
  final String cityDisplayName;
  final String categoryName;
  final String profileClassification;
  final String availabilityLabel;
  final bool blocked;
}

class AdministrativeProfessionalReportItem {
  const AdministrativeProfessionalReportItem({
    required this.professionalReportIdentifier,
    required this.professionalIdentifier,
    required this.professionalName,
    required this.reportReasonLabel,
    required this.seriousCase,
    required this.moderationStatusLabel,
    this.moderationDecisionLabel,
    this.moderationNotes,
    required this.createdAtLabel,
  });

  final String professionalReportIdentifier;
  final String professionalIdentifier;
  final String professionalName;
  final String reportReasonLabel;
  final bool seriousCase;
  final String moderationStatusLabel;
  final String? moderationDecisionLabel;
  final String? moderationNotes;
  final String createdAtLabel;
}

class AdministrativeReviewAnalysisItem {
  const AdministrativeReviewAnalysisItem({
    required this.reviewAnalysisRequestIdentifier,
    required this.professionalReviewIdentifier,
    required this.professionalIdentifier,
    required this.professionalName,
    required this.requestedByProfessionalIdentifier,
    required this.moderationStatusLabel,
    this.moderationDecisionLabel,
    this.moderationNotes,
    required this.createdAtLabel,
  });

  final String reviewAnalysisRequestIdentifier;
  final String professionalReviewIdentifier;
  final String professionalIdentifier;
  final String professionalName;
  final String requestedByProfessionalIdentifier;
  final String moderationStatusLabel;
  final String? moderationDecisionLabel;
  final String? moderationNotes;
  final String createdAtLabel;
}

class AdministrativeMetricsSummary {
  const AdministrativeMetricsSummary({
    this.professionalCount = 0,
    this.blockedProfessionalCount = 0,
    this.professionalReportCount = 0,
    this.reviewAnalysisRequestCount = 0,
    this.serviceCategoryCount = 0,
  });

  final int professionalCount;
  final int blockedProfessionalCount;
  final int professionalReportCount;
  final int reviewAnalysisRequestCount;
  final int serviceCategoryCount;
}

class AdministrativeFunctionalMetricsSummary {
  const AdministrativeFunctionalMetricsSummary({
    this.searchCount = 0,
    this.searchWithoutResultCount = 0,
    this.contactCount = 0,
    this.postContactFeedbackCount = 0,
    this.reviewCount = 0,
    this.anonymousReviewCount = 0,
    this.rankingAlgorithmEnabled = false,
    this.topSearchCategories = const [],
    this.topSearchCities = const [],
    this.topContactProfessionals = const [],
    this.responsivenessSignals = const [],
    this.reputationSignals = const [],
    this.averageRating = 0,
    this.respondedContactPercentage = 0,
  });

  final int searchCount;
  final int searchWithoutResultCount;
  final int contactCount;
  final int postContactFeedbackCount;
  final int reviewCount;
  final int anonymousReviewCount;
  final bool rankingAlgorithmEnabled;
  final List<AdministrativeLabeledMetric> topSearchCategories;
  final List<AdministrativeLabeledMetric> topSearchCities;
  final List<AdministrativeLabeledMetric> topContactProfessionals;
  final List<AdministrativeLabeledMetric> responsivenessSignals;
  final List<AdministrativeLabeledMetric> reputationSignals;
  final double averageRating;
  final double respondedContactPercentage;
}

class AdministrativeLabeledMetric {
  const AdministrativeLabeledMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

const Object _sentinel = Object();
