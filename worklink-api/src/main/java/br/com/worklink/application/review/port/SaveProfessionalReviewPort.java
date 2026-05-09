package br.com.worklink.application.review.port;

import br.com.worklink.domain.review.ProfessionalReview;

public interface SaveProfessionalReviewPort {

    ProfessionalReview saveProfessionalReview(ProfessionalReview professionalReview);
}
