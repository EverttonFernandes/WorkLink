package br.com.worklink.infrastructure.catalog;

import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.domain.catalog.ServiceCity;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcServiceCityRepositoryAdapter implements SaveServiceCityPort, ListServiceCitiesPort, LoadServiceCityByIdentifierPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcServiceCityRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ServiceCity saveServiceCity(ServiceCity serviceCity) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.service_cities (city_identifier, city_name, state_code, city_slug)
                VALUES (?, ?, ?, ?)
                """,
                serviceCity.cityIdentifier(),
                serviceCity.cityName(),
                serviceCity.stateCode(),
                serviceCity.citySlug()
        );
        return serviceCity;
    }

    @Override
    public List<ServiceCity> listServiceCities() {
        return jdbcTemplate.query(
                """
                SELECT city_identifier, city_name, state_code, city_slug
                FROM worklink.service_cities
                ORDER BY city_name ASC, state_code ASC
                """,
                (resultSet, rowNumber) -> ServiceCity.restoreServiceCity(
                        resultSet.getObject("city_identifier", UUID.class),
                        resultSet.getString("city_name"),
                        resultSet.getString("state_code"),
                        resultSet.getString("city_slug")
                )
        );
    }

    @Override
    public Optional<ServiceCity> loadServiceCityByIdentifier(UUID cityIdentifier) {
        List<ServiceCity> serviceCities = jdbcTemplate.query(
                """
                SELECT city_identifier, city_name, state_code, city_slug
                FROM worklink.service_cities
                WHERE city_identifier = ?
                """,
                (resultSet, rowNumber) -> ServiceCity.restoreServiceCity(
                        resultSet.getObject("city_identifier", UUID.class),
                        resultSet.getString("city_name"),
                        resultSet.getString("state_code"),
                        resultSet.getString("city_slug")
                ),
                cityIdentifier
        );
        return serviceCities.stream().findFirst();
    }
}
