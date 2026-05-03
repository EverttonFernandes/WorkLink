package br.com.worklink.application.professional.port;

import java.util.LinkedHashSet;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

public record ProfessionalSearchCriteria(
        Optional<UUID> categoryIdentifier,
        Set<UUID> cityIdentifiers,
        Optional<String> keyword
) {

    public ProfessionalSearchCriteria {
        categoryIdentifier = categoryIdentifier == null ? Optional.empty() : categoryIdentifier;
        cityIdentifiers = cityIdentifiers == null ? Set.of() : new LinkedHashSet<>(cityIdentifiers);
        keyword = normalizeKeyword(keyword);
    }

    public static ProfessionalSearchCriteria withoutFilters() {
        return new ProfessionalSearchCriteria(Optional.empty(), Set.of(), Optional.empty());
    }

    private static Optional<String> normalizeKeyword(Optional<String> keyword) {
        return keyword == null
                ? Optional.empty()
                : keyword.map(String::trim).filter(normalizedKeyword -> !normalizedKeyword.isBlank());
    }
}
