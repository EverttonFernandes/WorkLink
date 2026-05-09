package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

import java.util.UUID;

public record RegisterPostContactFeedbackRequest(
        AuthenticatedPrincipal authenticatedPrincipal,
        UUID contactIntentIdentifier,
        String conversationOutcome,
        String contactResponsiveness,
        String serviceExecutionOutcome
) {
}
