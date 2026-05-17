package br.com.worklink.application.catalog.port;

import br.com.worklink.domain.catalog.ServiceCategory;

import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface LoadServiceCategoryByIdentifierPort {

    Optional<ServiceCategory> loadServiceCategoryByIdentifier(UUID categoryIdentifier);
}
