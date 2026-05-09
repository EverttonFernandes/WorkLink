package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.admin.port.ListAdministrativeReviewAnalysisRequestsPort;

import java.util.List;

public class ListAdministrativeReviewAnalysisRequestsUseCase {

    private final ListAdministrativeReviewAnalysisRequestsPort listAdministrativeReviewAnalysisRequestsPort;

    public ListAdministrativeReviewAnalysisRequestsUseCase(
            ListAdministrativeReviewAnalysisRequestsPort listAdministrativeReviewAnalysisRequestsPort
    ) {
        this.listAdministrativeReviewAnalysisRequestsPort = listAdministrativeReviewAnalysisRequestsPort;
    }

    public List<AdministrativeReviewAnalysisRequestResponse> listAdministrativeReviewAnalysisRequests() {
        return listAdministrativeReviewAnalysisRequestsPort.listAdministrativeReviewAnalysisRequests().stream()
                .map(AdministrativeReviewAnalysisRequestResponse::fromReviewAnalysisRequest)
                .toList();
    }
}
