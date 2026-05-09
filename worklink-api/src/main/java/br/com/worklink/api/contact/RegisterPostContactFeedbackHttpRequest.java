package br.com.worklink.api.contact;

import java.util.UUID;

public record RegisterPostContactFeedbackHttpRequest(
        UUID contactIntentIdentifier,
        String conversationOutcome,
        String contactResponsiveness,
        String serviceExecutionOutcome
) {
}
