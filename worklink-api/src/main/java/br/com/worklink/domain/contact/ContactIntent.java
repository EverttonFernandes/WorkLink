package br.com.worklink.domain.contact;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record ContactIntent(
        UUID contactIntentIdentifier,
        UUID customerIdentifier,
        UUID professionalIdentifier,
        String professionalWhatsappNumber,
        Instant createdAt
) {

    public static ContactIntent registerContactIntent(
            UUID customerIdentifier,
            UUID professionalIdentifier,
            String professionalWhatsappNumber,
            Instant createdAt
    ) {
        return new ContactIntent(
                UUID.randomUUID(),
                requireIdentifier(customerIdentifier, "O cliente autenticado e obrigatorio para registrar contato."),
                requireIdentifier(professionalIdentifier, "O profissional do contato e obrigatorio."),
                requireMeaningfulText(professionalWhatsappNumber, "O WhatsApp do profissional e obrigatorio para contato."),
                requireInstant(createdAt, "O momento da intencao de contato e obrigatorio.")
        );
    }

    public static ContactIntent restoreContactIntent(
            UUID contactIntentIdentifier,
            UUID customerIdentifier,
            UUID professionalIdentifier,
            String professionalWhatsappNumber,
            Instant createdAt
    ) {
        return new ContactIntent(
                requireIdentifier(contactIntentIdentifier, "O identificador da intencao de contato e obrigatorio."),
                requireIdentifier(customerIdentifier, "O cliente autenticado e obrigatorio para registrar contato."),
                requireIdentifier(professionalIdentifier, "O profissional do contato e obrigatorio."),
                requireMeaningfulText(professionalWhatsappNumber, "O WhatsApp do profissional e obrigatorio para contato."),
                requireInstant(createdAt, "O momento da intencao de contato e obrigatorio.")
        );
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
        }
        return identifier;
    }

    private static String requireMeaningfulText(String text, String message) {
        if (text == null || text.isBlank()) {
            throw new BusinessRuleViolationException(message);
        }
        return text.trim();
    }

    private static Instant requireInstant(Instant instant, String message) {
        if (instant == null) {
            throw new BusinessRuleViolationException(message);
        }
        return instant;
    }
}
