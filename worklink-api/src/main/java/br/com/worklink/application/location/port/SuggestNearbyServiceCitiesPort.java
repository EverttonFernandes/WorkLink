package br.com.worklink.application.location.port;

import br.com.worklink.application.location.usecase.CurrentLocationRequest;
import br.com.worklink.domain.catalog.ServiceCity;

import java.util.List;

public interface SuggestNearbyServiceCitiesPort {

    List<ServiceCity> suggestNearbyServiceCities(CurrentLocationRequest currentLocationRequest, int maximumSuggestions);
}
