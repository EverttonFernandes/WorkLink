package br.com.worklink.application.review.port;

import br.com.worklink.domain.review.ProfessionalReview;

import java.util.List;
import java.util.UUID;

public interface ListProfessionalReviewsByProfessionalIdentifierPort {

    List<ProfessionalReview> listProfessionalReviewsByProfessionalIdentifier(UUID professionalIdentifier);
}
