package br.com.worklink.application.catalog.port;

import br.com.worklink.domain.catalog.ServiceCity;

import java.util.List;



@FunctionalInterface
public interface ListServiceCitiesPort {

    List<ServiceCity> listServiceCities();
}
