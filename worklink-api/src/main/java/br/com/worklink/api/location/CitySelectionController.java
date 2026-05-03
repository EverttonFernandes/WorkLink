package br.com.worklink.api.location;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.location.usecase.CurrentLocationRequest;
import br.com.worklink.application.location.usecase.PreviewCitySelectionRequest;
import br.com.worklink.application.location.usecase.PreviewCitySelectionUseCase;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequestMapping("/api/v1/city-selection")
public class CitySelectionController {

    private final PreviewCitySelectionUseCase previewCitySelectionUseCase;

    public CitySelectionController(PreviewCitySelectionUseCase previewCitySelectionUseCase) {
        this.previewCitySelectionUseCase = previewCitySelectionUseCase;
    }

    @PostMapping("/preview")
    CitySelectionPreviewHttpResponse previewCitySelection(@RequestBody PreviewCitySelectionHttpRequest request) {
        return CitySelectionPreviewHttpResponse.fromCitySelectionPreviewResponse(
                previewCitySelectionUseCase.previewCitySelection(
                        new PreviewCitySelectionRequest(
                                request.selectedCityIdentifiers(),
                                currentLocationFromRequest(request)
                        )
                )
        );
    }

    @PostMapping("/clear")
    CitySelectionPreviewHttpResponse clearCitySelection() {
        return CitySelectionPreviewHttpResponse.fromCitySelectionPreviewResponse(previewCitySelectionUseCase.clearCitySelection());
    }

    private Optional<CurrentLocationRequest> currentLocationFromRequest(PreviewCitySelectionHttpRequest request) {
        if (request.currentLatitude() == null && request.currentLongitude() == null) {
            return Optional.empty();
        }
        if (request.currentLatitude() == null || request.currentLongitude() == null) {
            throw new ApplicationRuleViolationException("Latitude e longitude atuais devem ser informadas juntas.");
        }
        return Optional.of(new CurrentLocationRequest(request.currentLatitude(), request.currentLongitude()));
    }
}
