package br.com.worklink.infrastructure.customer;

import br.com.worklink.application.customer.port.CustomerProfilePreferencesProjection;

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
import static org.mockito.ArgumentMatchers.same;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcCustomerProfileRepositoryAdapterTest {

    @Test
    @DisplayName("GIVEN preferencias WHEN salvar e carregar THEN deve mapear configuracoes persistentes")
    void shouldPersistAndLoadCustomerProfilePreferences() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcCustomerProfileRepositoryAdapter adapter = new JdbcCustomerProfileRepositoryAdapter(jdbcTemplate);
        CustomerProfilePreferencesProjection projection = new CustomerProfilePreferencesProjection(
                UUID.randomUUID(),
                false,
                true
        );
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("customer_identifier", UUID.class)).thenReturn(projection.customerIdentifier());
        when(resultSet.getBoolean("whatsapp_notifications_enabled")).thenReturn(false);
        when(resultSet.getBoolean("profile_personalization_enabled")).thenReturn(true);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), same(projection.customerIdentifier())))
                .thenAnswer(invocation -> {
                    RowMapper<CustomerProfilePreferencesProjection> rowMapper = invocation.getArgument(1);
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });

        // WHEN
        CustomerProfilePreferencesProjection savedProjection = adapter.saveCustomerProfilePreferences(projection);
        Optional<CustomerProfilePreferencesProjection> loadedProjection =
                adapter.loadCustomerProfilePreferences(projection.customerIdentifier());

        // THEN
        assertThat(savedProjection).isEqualTo(projection);
        assertThat(loadedProjection).contains(projection);
    }

    @Test
    @DisplayName("GIVEN favoritos WHEN listar salvar e remover THEN deve usar jdbc com idempotencia")
    void shouldListSaveAndRemoveCustomerSavedProfessionals() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcCustomerProfileRepositoryAdapter adapter = new JdbcCustomerProfileRepositoryAdapter(jdbcTemplate);
        UUID customerIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(customerIdentifier)))
                .thenAnswer(invocation -> {
                    RowMapper<UUID> rowMapper = invocation.getArgument(1);
                    ResultSet resultSet = mock(ResultSet.class);
                    when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(professionalIdentifier);
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });

        // WHEN
        adapter.saveCustomerSavedProfessional(customerIdentifier, professionalIdentifier);
        List<UUID> savedProfessionalIdentifiers =
                adapter.listCustomerSavedProfessionalIdentifiers(customerIdentifier);
        adapter.removeCustomerSavedProfessional(customerIdentifier, professionalIdentifier);

        // THEN
        assertThat(savedProfessionalIdentifiers).containsExactly(professionalIdentifier);
        verify(jdbcTemplate, times(2)).update(any(String.class), eq(customerIdentifier), eq(professionalIdentifier));
    }
}
