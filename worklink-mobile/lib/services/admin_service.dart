import 'api_client.dart';
import 'models/admin_model.dart';

class AdminService {
  const AdminService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<List<AdministrativeProfessionalModel>>
      listAdministrativeProfessionals() async {
    final response = await _httpClient.getList('/api/v1/admin/professionals');
    return response
        .map(
          (item) => AdministrativeProfessionalModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<AdministrativeProfessionalModel> blockProfessional(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/admin/professionals/$professionalIdentifier/block',
    );
    return AdministrativeProfessionalModel.fromJson(response);
  }

  Future<AdministrativeProfessionalModel> unblockProfessional(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/admin/professionals/$professionalIdentifier/unblock',
    );
    return AdministrativeProfessionalModel.fromJson(response);
  }

  Future<List<AdministrativeProfessionalReportModel>>
      listAdministrativeProfessionalReports() async {
    final response = await _httpClient.getList('/api/v1/admin/reports');
    return response
        .map(
          (item) => AdministrativeProfessionalReportModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<AdministrativeProfessionalReportModel> moderateProfessionalReport({
    required String professionalReportIdentifier,
    required String moderationStatus,
    required String moderationDecision,
    String? moderationNotes,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/admin/reports/$professionalReportIdentifier/moderation',
      data: {
        'moderationStatus': moderationStatus,
        'moderationDecision': moderationDecision,
        'moderationNotes': moderationNotes,
      },
    );
    return AdministrativeProfessionalReportModel.fromJson(response);
  }

  Future<List<AdministrativeReviewAnalysisRequestModel>>
      listAdministrativeReviewAnalysisRequests() async {
    final response = await _httpClient.getList(
      '/api/v1/admin/review-analysis-requests',
    );
    return response
        .map(
          (item) => AdministrativeReviewAnalysisRequestModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<AdministrativeReviewAnalysisRequestModel>
      moderateReviewAnalysisRequest({
    required String reviewAnalysisRequestIdentifier,
    required String moderationStatus,
    required String moderationDecision,
    String? moderationNotes,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/admin/review-analysis-requests/'
      '$reviewAnalysisRequestIdentifier/moderation',
      data: {
        'moderationStatus': moderationStatus,
        'moderationDecision': moderationDecision,
        'moderationNotes': moderationNotes,
      },
    );
    return AdministrativeReviewAnalysisRequestModel.fromJson(response);
  }

  Future<AdministrativeMetricsModel> loadAdministrativeMetrics() async {
    final response = await _httpClient.getObject('/api/v1/admin/metrics');
    return AdministrativeMetricsModel.fromJson(response);
  }

  Future<FunctionalMetricsModel> loadFunctionalMetrics() async {
    final response = await _httpClient.getObject(
      '/api/v1/admin/functional-metrics',
    );
    return FunctionalMetricsModel.fromJson(response);
  }

  Future<void> registerServiceCategory(String categoryName) async {
    await _httpClient.postObject(
      '/api/v1/categories',
      data: {'categoryName': categoryName.trim()},
    );
  }
}
