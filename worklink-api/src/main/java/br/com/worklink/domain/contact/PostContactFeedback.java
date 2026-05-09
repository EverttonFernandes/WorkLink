package br.com.worklink.domain.contact;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record PostContactFeedback(
        UUID postContactFeedbackIdentifier,
        UUID contactIntentIdentifier,
        UUID customerIdentifier,
        ContactConversationOutcome conversationOutcome,
        ContactResponsiveness contactResponsiveness,
        ServiceExecutionOutcome serviceExecutionOutcome,
        Instant createdAt
) {

    public static PostContactFeedback registerPostContactFeedback(
            UUID contactIntentIdentifier,
            UUID customerIdentifier,
            ContactConversationOutcome conversationOutcome,
            ContactResponsiveness contactResponsiveness,
            ServiceExecutionOutcome serviceExecutionOutcome,
            Instant createdAt
    ) {
        return new PostContactFeedback(
                UUID.randomUUID(),
                requireIdentifier(contactIntentIdentifier, "A intencao de contato e obrigatoria para o feedback."),
                requireIdentifier(customerIdentifier, "O cliente do feedback e obrigatorio."),
                requireConversationOutcome(conversationOutcome),
                requireContactResponsiveness(contactResponsiveness),
                requireServiceExecutionOutcome(serviceExecutionOutcome),
                requireInstant(createdAt)
        );
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
        }
        return identifier;
    }

    private static ContactConversationOutcome requireConversationOutcome(ContactConversationOutcome conversationOutcome) {
        if (conversationOutcome == null) {
            throw new BusinessRuleViolationException("Informe se conseguiu falar com o profissional.");
        }
        return conversationOutcome;
    }

    private static ContactResponsiveness requireContactResponsiveness(ContactResponsiveness contactResponsiveness) {
        if (contactResponsiveness == null) {
            throw new BusinessRuleViolationException("Informe a responsividade percebida.");
        }
        return contactResponsiveness;
    }

    private static ServiceExecutionOutcome requireServiceExecutionOutcome(ServiceExecutionOutcome serviceExecutionOutcome) {
        if (serviceExecutionOutcome == null) {
            throw new BusinessRuleViolationException("Informe se o servico foi realizado.");
        }
        return serviceExecutionOutcome;
    }

    private static Instant requireInstant(Instant instant) {
        if (instant == null) {
            throw new BusinessRuleViolationException("O momento do feedback pos-contato e obrigatorio.");
        }
        return instant;
    }
}
