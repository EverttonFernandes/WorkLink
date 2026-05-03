package br.com.worklink.application.catalog.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.catalog.ServiceCity;

public class RegisterServiceCityUseCase {

    private final SaveServiceCityPort saveServiceCityPort;

    public RegisterServiceCityUseCase(SaveServiceCityPort saveServiceCityPort) {
        this.saveServiceCityPort = saveServiceCityPort;
    }

    public ServiceCityResponse registerServiceCity(RegisterServiceCityRequest request) {
        try {
            ServiceCity serviceCity = ServiceCity.createServiceCity(request.cityName(), request.stateCode());
            return ServiceCityResponse.fromServiceCity(saveServiceCityPort.saveServiceCity(serviceCity));
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException(exception.getMessage(), exception);
        }
    }
}
