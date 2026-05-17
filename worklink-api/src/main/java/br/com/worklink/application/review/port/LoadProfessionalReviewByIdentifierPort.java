package br.com.worklink.application.review.port;

import br.com.worklink.domain.review.ProfessionalReview;

import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface LoadProfessionalReviewByIdentifierPort {

    Optional<ProfessionalReview> loadProfessionalReviewByIdentifier(UUID professionalReviewIdentifier);
}
