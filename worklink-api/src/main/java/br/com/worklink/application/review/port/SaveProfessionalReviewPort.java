package br.com.worklink.application.review.port;

import br.com.worklink.domain.review.ProfessionalReview;



@FunctionalInterface
public interface SaveProfessionalReviewPort {

    ProfessionalReview saveProfessionalReview(ProfessionalReview professionalReview);
}
