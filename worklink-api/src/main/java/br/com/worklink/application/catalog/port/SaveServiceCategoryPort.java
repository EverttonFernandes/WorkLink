package br.com.worklink.application.catalog.port;

import br.com.worklink.domain.catalog.ServiceCategory;



@FunctionalInterface
public interface SaveServiceCategoryPort {

    ServiceCategory saveServiceCategory(ServiceCategory serviceCategory);
}
