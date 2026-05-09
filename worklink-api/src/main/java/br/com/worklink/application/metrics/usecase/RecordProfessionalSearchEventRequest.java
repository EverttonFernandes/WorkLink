package br.com.worklink.application.metrics.usecase;

import java.util.Set;
import java.util.UUID;

public record RecordProfessionalSearchEventRequest(
        UUID categoryIdentifier,
        Set<UUID> cityIdentifiers,
        String keyword,
        int resultCount
) {
}
