package br.com.worklink.infrastructure.catalog;

import br.com.worklink.domain.catalog.ServiceCity;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcServiceCityRepositoryAdapterTest {

    @Test
    @DisplayName("Deve persistir cidade de atendimento usando JdbcTemplate")
    void shouldPersistServiceCityUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcServiceCityRepositoryAdapter adapter = new JdbcServiceCityRepositoryAdapter(jdbcTemplate);
        ServiceCity serviceCity = ServiceCity.createServiceCity("Canoas", "RS");

        // WHEN
        ServiceCity savedServiceCity = adapter.saveServiceCity(serviceCity);

        // THEN
        assertThat(savedServiceCity).isEqualTo(serviceCity);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(serviceCity.cityIdentifier()),
                eq(serviceCity.cityName()),
                eq(serviceCity.stateCode()),
                eq(serviceCity.citySlug())
        );
    }

    @Test
    @DisplayName("Deve listar cidades de atendimento usando JdbcTemplate")
    void shouldListServiceCitiesUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcServiceCityRepositoryAdapter adapter = new JdbcServiceCityRepositoryAdapter(jdbcTemplate);
        ServiceCity serviceCity = ServiceCity.createServiceCity("Esteio", "RS");
        ResultSet resultSet = cityResultSet(serviceCity);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class))).thenAnswer(invocation -> {
            RowMapper<ServiceCity> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        List<ServiceCity> serviceCities = adapter.listServiceCities();

        // THEN
        assertThat(serviceCities).containsExactly(serviceCity);
    }

    @Test
    @DisplayName("Deve carregar cidade de atendimento por identificador usando JdbcTemplate")
    void shouldLoadServiceCityByIdentifierUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcServiceCityRepositoryAdapter adapter = new JdbcServiceCityRepositoryAdapter(jdbcTemplate);
        ServiceCity serviceCity = ServiceCity.createServiceCity("Porto Alegre", "RS");
        ResultSet resultSet = cityResultSet(serviceCity);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), any(UUID.class))).thenAnswer(invocation -> {
            RowMapper<ServiceCity> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        Optional<ServiceCity> loadedServiceCity = adapter.loadServiceCityByIdentifier(serviceCity.cityIdentifier());

        // THEN
        assertThat(loadedServiceCity).contains(serviceCity);
    }

    private ResultSet cityResultSet(ServiceCity serviceCity) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("city_identifier", UUID.class)).thenReturn(serviceCity.cityIdentifier());
        when(resultSet.getString("city_name")).thenReturn(serviceCity.cityName());
        when(resultSet.getString("state_code")).thenReturn(serviceCity.stateCode());
        when(resultSet.getString("city_slug")).thenReturn(serviceCity.citySlug());
        return resultSet;
    }
}
