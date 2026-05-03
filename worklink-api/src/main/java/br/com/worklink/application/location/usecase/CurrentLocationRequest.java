package br.com.worklink.application.location.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

public record CurrentLocationRequest(
        double latitude,
        double longitude
) {

    public CurrentLocationRequest {
        if (latitude < -90.0 || latitude > 90.0) {
            throw new ApplicationRuleViolationException("A latitude da localizacao atual deve estar entre -90 e 90.");
        }
        if (longitude < -180.0 || longitude > 180.0) {
            throw new ApplicationRuleViolationException("A longitude da localizacao atual deve estar entre -180 e 180.");
        }
    }
}
