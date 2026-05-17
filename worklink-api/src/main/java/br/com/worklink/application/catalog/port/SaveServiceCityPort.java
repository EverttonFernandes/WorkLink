package br.com.worklink.application.catalog.port;

import br.com.worklink.domain.catalog.ServiceCity;



@FunctionalInterface
public interface SaveServiceCityPort {

    ServiceCity saveServiceCity(ServiceCity serviceCity);
}
