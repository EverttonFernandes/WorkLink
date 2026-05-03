package br.com.worklink.infrastructure.catalog;

import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.LoadServiceCitiesByIdentifiersPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.application.location.port.SuggestNearbyServiceCitiesPort;
import br.com.worklink.application.location.usecase.CurrentLocationRequest;
import br.com.worklink.domain.catalog.ServiceCity;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Repository
public class JdbcServiceCityRepositoryAdapter
        implements SaveServiceCityPort,
        ListServiceCitiesPort,
        LoadServiceCityByIdentifierPort,
        LoadServiceCitiesByIdentifiersPort,
        SuggestNearbyServiceCitiesPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcServiceCityRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ServiceCity saveServiceCity(ServiceCity serviceCity) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.service_cities (city_identifier, city_name, state_code, city_slug, latitude, longitude)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                serviceCity.cityIdentifier(),
                serviceCity.cityName(),
                serviceCity.stateCode(),
                serviceCity.citySlug(),
                serviceCity.latitude(),
                serviceCity.longitude()
        );
        return serviceCity;
    }

    @Override
    public List<ServiceCity> listServiceCities() {
        return jdbcTemplate.query(
                """
                SELECT city_identifier, city_name, state_code, city_slug, latitude, longitude
                FROM worklink.service_cities
                ORDER BY city_name ASC, state_code ASC
                """,
                (resultSet, rowNumber) -> mapServiceCity(resultSet)
        );
    }

    @Override
    public Optional<ServiceCity> loadServiceCityByIdentifier(UUID cityIdentifier) {
        List<ServiceCity> serviceCities = jdbcTemplate.query(
                """
                SELECT city_identifier, city_name, state_code, city_slug, latitude, longitude
                FROM worklink.service_cities
                WHERE city_identifier = ?
                """,
                (resultSet, rowNumber) -> mapServiceCity(resultSet),
                cityIdentifier
        );
        return serviceCities.stream().findFirst();
    }

    @Override
    public List<ServiceCity> loadServiceCitiesByIdentifiers(Set<UUID> cityIdentifiers) {
        if (cityIdentifiers.isEmpty()) {
            return List.of();
        }
        String cityIdentifierPlaceholders = cityIdentifiers.stream()
                .map(cityIdentifier -> "?")
                .collect(Collectors.joining(","));
        return jdbcTemplate.query(
                """
                SELECT city_identifier, city_name, state_code, city_slug, latitude, longitude
                FROM worklink.service_cities
                WHERE city_identifier IN (%s)
                ORDER BY city_name ASC, state_code ASC
                """.formatted(cityIdentifierPlaceholders),
                (resultSet, rowNumber) -> mapServiceCity(resultSet),
                cityIdentifiers.toArray()
        );
    }

    @Override
    public List<ServiceCity> suggestNearbyServiceCities(CurrentLocationRequest currentLocationRequest, int maximumSuggestions) {
        return jdbcTemplate.query(
                        """
                        SELECT city_identifier, city_name, state_code, city_slug, latitude, longitude
                        FROM worklink.service_cities
                        WHERE latitude IS NOT NULL
                        AND longitude IS NOT NULL
                        """,
                        (resultSet, rowNumber) -> mapServiceCity(resultSet)
                )
                .stream()
                .sorted(Comparator.comparingDouble(serviceCity -> distanceInKilometers(currentLocationRequest, serviceCity)))
                .limit(maximumSuggestions)
                .toList();
    }

    private ServiceCity mapServiceCity(ResultSet resultSet) throws SQLException {
        return ServiceCity.restoreServiceCity(
                resultSet.getObject("city_identifier", UUID.class),
                resultSet.getString("city_name"),
                resultSet.getString("state_code"),
                resultSet.getString("city_slug"),
                resultSet.getObject("latitude", Double.class),
                resultSet.getObject("longitude", Double.class)
        );
    }

    private double distanceInKilometers(CurrentLocationRequest currentLocationRequest, ServiceCity serviceCity) {
        double earthRadiusInKilometers = 6371.0;
        double latitudeDistance = Math.toRadians(serviceCity.latitude() - currentLocationRequest.latitude());
        double longitudeDistance = Math.toRadians(serviceCity.longitude() - currentLocationRequest.longitude());
        double currentLatitude = Math.toRadians(currentLocationRequest.latitude());
        double serviceCityLatitude = Math.toRadians(serviceCity.latitude());
        double haversineFormula = Math.sin(latitudeDistance / 2) * Math.sin(latitudeDistance / 2)
                + Math.cos(currentLatitude) * Math.cos(serviceCityLatitude)
                * Math.sin(longitudeDistance / 2) * Math.sin(longitudeDistance / 2);
        return earthRadiusInKilometers * 2 * Math.atan2(Math.sqrt(haversineFormula), Math.sqrt(1 - haversineFormula));
    }
}
