package br.com.worklink.application.review.port;

import java.util.UUID;

public interface UpdateProfessionalReviewVisibilityPort {

    void updateProfessionalReviewVisibility(UUID professionalReviewIdentifier, boolean hiddenFromPublic);
}
