package br.com.worklink.application.review.port;

import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;



@FunctionalInterface
public interface SaveProfessionalReviewAnalysisRequestPort {

    ProfessionalReviewAnalysisRequest saveProfessionalReviewAnalysisRequest(
            ProfessionalReviewAnalysisRequest professionalReviewAnalysisRequest
    );
}
