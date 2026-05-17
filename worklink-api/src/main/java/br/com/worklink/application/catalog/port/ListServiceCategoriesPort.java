package br.com.worklink.application.catalog.port;

import br.com.worklink.domain.catalog.ServiceCategory;

import java.util.List;



@FunctionalInterface
public interface ListServiceCategoriesPort {

    List<ServiceCategory> listServiceCategories();
}
