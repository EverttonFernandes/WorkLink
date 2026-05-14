package br.com.worklink.api.customer;

import br.com.worklink.application.customer.usecase.CustomerSubmittedReviewResponse;

import java.util.UUID;

public record CustomerSubmittedReviewHttpResponse(
        UUID professionalReviewIdentifier,
        UUID professionalIdentifier,
        String professionalName,
        int starRating,
        boolean publiclyAnonymous,
        String comment
) {

    static CustomerSubmittedReviewHttpResponse fromUseCaseResponse(
            CustomerSubmittedReviewResponse customerSubmittedReviewResponse
    ) {
        return new CustomerSubmittedReviewHttpResponse(
                customerSubmittedReviewResponse.professionalReviewIdentifier(),
                customerSubmittedReviewResponse.professionalIdentifier(),
                customerSubmittedReviewResponse.professionalName(),
                customerSubmittedReviewResponse.starRating(),
                customerSubmittedReviewResponse.publiclyAnonymous(),
                customerSubmittedReviewResponse.comment()
        );
    }
}
