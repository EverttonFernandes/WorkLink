package br.com.worklink.application.catalog.port;

import br.com.worklink.domain.catalog.ServiceCity;

import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface LoadServiceCityByIdentifierPort {

    Optional<ServiceCity> loadServiceCityByIdentifier(UUID cityIdentifier);
}
