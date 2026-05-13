package br.com.worklink.domain.professional;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.util.UUID;

public record ProfessionalPortfolioItem(
        UUID portfolioItemIdentifier,
        UUID professionalIdentifier,
        UUID fileIdentifier,
        String title,
        String description,
        int displayOrder,
        boolean active
) {

    public static ProfessionalPortfolioItem addProfessionalPortfolioItem(
            UUID professionalIdentifier,
            UUID fileIdentifier,
            String title,
            String description,
            int displayOrder
    ) {
        return new ProfessionalPortfolioItem(
                UUID.randomUUID(),
                requireIdentifier(professionalIdentifier, "O profissional do portfolio e obrigatorio."),
                requireIdentifier(fileIdentifier, "O arquivo do portfolio e obrigatorio."),
                requireText(title, "O titulo do item de portfolio e obrigatorio."),
                normalizeOptionalText(description),
                requireNonNegativeDisplayOrder(displayOrder),
                true
        );
    }

    public static ProfessionalPortfolioItem restoreProfessionalPortfolioItem(
            UUID portfolioItemIdentifier,
            UUID professionalIdentifier,
            UUID fileIdentifier,
            String title,
            String description,
            int displayOrder,
            boolean active
    ) {
        return new ProfessionalPortfolioItem(
                requireIdentifier(portfolioItemIdentifier, "O identificador do item de portfolio e obrigatorio."),
                requireIdentifier(professionalIdentifier, "O profissional do portfolio e obrigatorio."),
                requireIdentifier(fileIdentifier, "O arquivo do portfolio e obrigatorio."),
                requireText(title, "O titulo do item de portfolio e obrigatorio."),
                normalizeOptionalText(description),
                requireNonNegativeDisplayOrder(displayOrder),
                active
        );
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
        }
        return identifier;
    }

    private static String requireText(String text, String message) {
        if (text == null || text.isBlank()) {
            throw new BusinessRuleViolationException(message);
        }
        return text.trim();
    }

    private static String normalizeOptionalText(String text) {
        if (text == null || text.isBlank()) {
            return null;
        }
        return text.trim();
    }

    private static int requireNonNegativeDisplayOrder(int displayOrder) {
        if (displayOrder < 0) {
            throw new BusinessRuleViolationException("A ordem do item de portfolio nao pode ser negativa.");
        }
        return displayOrder;
    }
}
