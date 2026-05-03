package br.com.worklink.application.professional.port;

import java.util.Optional;
import java.util.UUID;

public record ProfessionalSearchCriteria(
        Optional<UUID> categoryIdentifier,
        Optional<UUID> cityIdentifier
) {

    public static ProfessionalSearchCriteria withoutFilters() {
        return new ProfessionalSearchCriteria(Optional.empty(), Optional.empty());
    }
}
