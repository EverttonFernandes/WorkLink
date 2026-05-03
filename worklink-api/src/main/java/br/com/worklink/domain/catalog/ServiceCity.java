package br.com.worklink.domain.catalog;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.text.Normalizer;
import java.util.Locale;
import java.util.UUID;

public record ServiceCity(
        UUID cityIdentifier,
        String cityName,
        String stateCode,
        String citySlug
) {

    public static ServiceCity createServiceCity(String cityName, String stateCode) {
        String normalizedCityName = requireMeaningfulText(cityName, "O nome da cidade e obrigatorio.");
        String normalizedStateCode = requireStateCode(stateCode);
        return new ServiceCity(
                UUID.randomUUID(),
                normalizedCityName,
                normalizedStateCode,
                createSlugFromCityAndState(normalizedCityName, normalizedStateCode)
        );
    }

    public static ServiceCity restoreServiceCity(UUID cityIdentifier, String cityName, String stateCode, String citySlug) {
        return new ServiceCity(
                requireIdentifier(cityIdentifier, "O identificador da cidade e obrigatorio."),
                requireMeaningfulText(cityName, "O nome da cidade e obrigatorio."),
                requireStateCode(stateCode),
                requireMeaningfulText(citySlug, "O slug da cidade e obrigatorio.")
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

    private static String requireStateCode(String stateCode) {
        String normalizedStateCode = requireMeaningfulText(stateCode, "A UF da cidade e obrigatoria.").toUpperCase(Locale.ROOT);
        if (!normalizedStateCode.matches("[A-Z]{2}")) {
            throw new BusinessRuleViolationException("A UF da cidade deve possuir exatamente duas letras.");
        }
        return normalizedStateCode;
    }

    private static String createSlugFromCityAndState(String cityName, String stateCode) {
        String withoutAccents = Normalizer.normalize(cityName + "-" + stateCode, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        return withoutAccents.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-|-$)", "");
    }
}
