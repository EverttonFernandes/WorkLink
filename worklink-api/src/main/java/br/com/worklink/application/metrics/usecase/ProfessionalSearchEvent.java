package br.com.worklink.application.metrics.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

public record ProfessionalSearchEvent(
        UUID professionalSearchEventIdentifier,
        UUID categoryIdentifier,
        Set<UUID> cityIdentifiers,
        String keyword,
        int resultCount,
        Instant createdAt
) {

    public static ProfessionalSearchEvent registerProfessionalSearchEvent(
            UUID categoryIdentifier,
            Set<UUID> cityIdentifiers,
            String keyword,
            int resultCount,
            Instant createdAt
    ) {
        return new ProfessionalSearchEvent(
                UUID.randomUUID(),
                categoryIdentifier,
                cityIdentifiers,
                meaningfulKeywordOrNull(keyword),
                resultCount,
                createdAt
        );
    }

    public ProfessionalSearchEvent {
        if (professionalSearchEventIdentifier == null) {
            throw new ApplicationRuleViolationException("O identificador do evento de busca e obrigatorio.");
        }
        cityIdentifiers = cityIdentifiers == null ? Set.of() : Set.copyOf(cityIdentifiers);
        if (resultCount < 0) {
            throw new ApplicationRuleViolationException("A quantidade de resultados da busca nao pode ser negativa.");
        }
        if (createdAt == null) {
            throw new ApplicationRuleViolationException("O momento do evento de busca e obrigatorio.");
        }
    }

    private static String meaningfulKeywordOrNull(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        return keyword.trim();
    }
}
