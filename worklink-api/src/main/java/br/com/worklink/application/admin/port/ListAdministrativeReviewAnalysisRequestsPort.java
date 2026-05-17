package br.com.worklink.application.admin.port;

import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import java.util.List;



@FunctionalInterface
public interface ListAdministrativeReviewAnalysisRequestsPort {

    List<ProfessionalReviewAnalysisRequest> listAdministrativeReviewAnalysisRequests();
}
