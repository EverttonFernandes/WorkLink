package br.com.worklink.application.catalog.usecase;

import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import java.util.List;

public class ListServiceCitiesUseCase {

    private final ListServiceCitiesPort listServiceCitiesPort;

    public ListServiceCitiesUseCase(ListServiceCitiesPort listServiceCitiesPort) {
        this.listServiceCitiesPort = listServiceCitiesPort;
    }

    public List<ServiceCityResponse> listServiceCities() {
        return listServiceCitiesPort.listServiceCities().stream()
                .map(ServiceCityResponse::fromServiceCity)
                .toList();
    }
}
