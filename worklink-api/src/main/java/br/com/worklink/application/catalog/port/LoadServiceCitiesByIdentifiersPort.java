package br.com.worklink.application.catalog.port;

import br.com.worklink.domain.catalog.ServiceCity;

import java.util.List;
import java.util.Set;
import java.util.UUID;



@FunctionalInterface
public interface LoadServiceCitiesByIdentifiersPort {

    List<ServiceCity> loadServiceCitiesByIdentifiers(Set<UUID> cityIdentifiers);
}
