package br.com.worklink.application.review.port;

import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

public interface SaveProfessionalReviewAnalysisRequestPort {

    ProfessionalReviewAnalysisRequest saveProfessionalReviewAnalysisRequest(
            ProfessionalReviewAnalysisRequest professionalReviewAnalysisRequest
    );
}
