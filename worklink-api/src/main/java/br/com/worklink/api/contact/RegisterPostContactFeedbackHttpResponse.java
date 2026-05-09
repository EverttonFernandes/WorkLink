package br.com.worklink.api.contact;

import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackResponse;

import java.time.Instant;
import java.util.UUID;

public record RegisterPostContactFeedbackHttpResponse(
        UUID postContactFeedbackIdentifier,
        UUID contactIntentIdentifier,
        String conversationOutcome,
        String contactResponsiveness,
        String serviceExecutionOutcome,
        Instant createdAt
) {

    public static RegisterPostContactFeedbackHttpResponse fromUseCaseResponse(
            RegisterPostContactFeedbackResponse registerPostContactFeedbackResponse
    ) {
        return new RegisterPostContactFeedbackHttpResponse(
                registerPostContactFeedbackResponse.postContactFeedbackIdentifier(),
                registerPostContactFeedbackResponse.contactIntentIdentifier(),
                registerPostContactFeedbackResponse.conversationOutcome(),
                registerPostContactFeedbackResponse.contactResponsiveness(),
                registerPostContactFeedbackResponse.serviceExecutionOutcome(),
                registerPostContactFeedbackResponse.createdAt()
        );
    }
}
