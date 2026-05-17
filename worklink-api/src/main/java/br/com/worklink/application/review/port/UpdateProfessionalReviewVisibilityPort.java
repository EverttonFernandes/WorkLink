package br.com.worklink.application.review.port;

import java.util.UUID;



@FunctionalInterface
public interface UpdateProfessionalReviewVisibilityPort {

    void updateProfessionalReviewVisibility(UUID professionalReviewIdentifier, boolean hiddenFromPublic);
}
