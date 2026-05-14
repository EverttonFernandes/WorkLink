package br.com.worklink.application.customer.usecase;

import java.util.UUID;

public record CustomerSubmittedReviewResponse(
        UUID professionalReviewIdentifier,
        UUID professionalIdentifier,
        String professionalName,
        int starRating,
        boolean publiclyAnonymous,
        String comment
) {
}
