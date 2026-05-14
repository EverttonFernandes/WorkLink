package br.com.worklink.api.customer;

import br.com.worklink.application.contact.usecase.PendingPostContactFeedbackRequestResponse;

import java.time.Instant;
import java.util.UUID;

public record PendingPostContactFeedbackRequestHttpResponse(
        UUID contactIntentIdentifier,
        UUID professionalIdentifier,
        String professionalName,
        Instant contactCreatedAt
) {

    static PendingPostContactFeedbackRequestHttpResponse fromUseCaseResponse(
            PendingPostContactFeedbackRequestResponse response
    ) {
        return new PendingPostContactFeedbackRequestHttpResponse(
                response.contactIntentIdentifier(),
                response.professionalIdentifier(),
                response.professionalName(),
                response.contactCreatedAt()
        );
    }
}
