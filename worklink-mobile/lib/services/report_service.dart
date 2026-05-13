import 'api_client.dart';
import 'models/report_model.dart';

class ReportService {
  const ReportService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<ProfessionalReport> registerProfessionalReport(
    RegisterProfessionalReportRequest request,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/professional-reports',
      data: request.toJson(),
    );
    return ProfessionalReport.fromJson(response);
  }
}
