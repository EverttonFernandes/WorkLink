package br.com.worklink.api.location;

import java.util.List;
import java.util.UUID;

public record PreviewCitySelectionHttpRequest(
        List<UUID> selectedCityIdentifiers,
        Double currentLatitude,
        Double currentLongitude
) {
}
