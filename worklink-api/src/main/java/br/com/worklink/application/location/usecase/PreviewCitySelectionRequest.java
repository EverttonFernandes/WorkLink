package br.com.worklink.application.location.usecase;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public record PreviewCitySelectionRequest(
        List<UUID> selectedCityIdentifiers,
        Optional<CurrentLocationRequest> currentLocationRequest
) {

    public PreviewCitySelectionRequest {
        selectedCityIdentifiers = selectedCityIdentifiers == null ? List.of() : List.copyOf(selectedCityIdentifiers);
        currentLocationRequest = currentLocationRequest == null ? Optional.empty() : currentLocationRequest;
    }
}
