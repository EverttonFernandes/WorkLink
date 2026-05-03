package br.com.worklink.domain.catalog;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.text.Normalizer;
import java.util.Locale;
import java.util.UUID;

public record ServiceCategory(
        UUID categoryIdentifier,
        String categoryName,
        String categorySlug
) {

    public static ServiceCategory createServiceCategory(String categoryName) {
        String normalizedCategoryName = requireMeaningfulText(categoryName, "O nome da categoria e obrigatorio.");
        return new ServiceCategory(UUID.randomUUID(), normalizedCategoryName, createSlugFromText(normalizedCategoryName));
    }

    public static ServiceCategory restoreServiceCategory(UUID categoryIdentifier, String categoryName, String categorySlug) {
        return new ServiceCategory(
                requireIdentifier(categoryIdentifier, "O identificador da categoria e obrigatorio."),
                requireMeaningfulText(categoryName, "O nome da categoria e obrigatorio."),
                requireMeaningfulText(categorySlug, "O slug da categoria e obrigatorio.")
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

    private static String createSlugFromText(String text) {
        String withoutAccents = Normalizer.normalize(text, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        return withoutAccents.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-|-$)", "");
    }
}
