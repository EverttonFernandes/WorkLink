package br.com.worklink.infrastructure.metrics;

import br.com.worklink.application.metrics.usecase.ContactMetricResponse;
import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;
import br.com.worklink.application.metrics.usecase.ProfessionalSearchEvent;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcFunctionalMetricsRepositoryAdapterTest {

    @Test
    @DisplayName("GIVEN evento de busca WHEN salvar THEN deve persistir busca e cidades filtradas")
    void shouldSaveProfessionalSearchEventAndFilteredCities() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcFunctionalMetricsRepositoryAdapter adapter = new JdbcFunctionalMetricsRepositoryAdapter(jdbcTemplate);
        UUID categoryIdentifier = UUID.randomUUID();
        UUID cityIdentifier = UUID.randomUUID();
        ProfessionalSearchEvent professionalSearchEvent = ProfessionalSearchEvent.registerProfessionalSearchEvent(
                categoryIdentifier,
                Set.of(cityIdentifier),
                "eletricista",
                3,
                Instant.parse("2026-05-09T23:50:00Z")
        );

        // WHEN
        ProfessionalSearchEvent savedSearchEvent = adapter.saveProfessionalSearchEvent(professionalSearchEvent);

        // THEN
        assertThat(savedSearchEvent).isEqualTo(professionalSearchEvent);
        verify(jdbcTemplate).update(
                anyString(),
                eq(professionalSearchEvent.professionalSearchEventIdentifier()),
                eq(categoryIdentifier),
                eq("eletricista"),
                eq(3),
                eq(Instant.parse("2026-05-09T23:50:00Z"))
        );
        verify(jdbcTemplate).batchUpdate(anyString(), any(BatchPreparedStatementSetter.class));
    }

    @Test
    @DisplayName("GIVEN tabelas funcionais WHEN carregar metricas THEN deve agregar sinais de ranking futuro")
    void shouldLoadFunctionalMetricsSignals() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        UUID professionalIdentifier = UUID.randomUUID();
        UUID categoryIdentifier = UUID.randomUUID();
        UUID cityIdentifier = UUID.randomUUID();
        when(jdbcTemplate.queryForObject(anyString(), eq(Long.class)))
                .thenReturn(7L, 6L, 5L, 4L, 3L, 2L);
        when(jdbcTemplate.query(anyString(), any(RowMapper.class)))
                .thenAnswer(invocation -> List.of(contactMetricFrom(invocation.getArgument(1), professionalIdentifier, 6)))
                .thenAnswer(invocation -> List.of(contactMetricFrom(invocation.getArgument(1), categoryIdentifier, 5)))
                .thenAnswer(invocation -> List.of(contactMetricFrom(invocation.getArgument(1), cityIdentifier, 4)))
                .thenAnswer(invocation -> List.of(responsivenessMetricFrom(invocation.getArgument(1))))
                .thenAnswer(invocation -> List.of(reputationMetricFrom(invocation.getArgument(1), professionalIdentifier)));
        JdbcFunctionalMetricsRepositoryAdapter adapter = new JdbcFunctionalMetricsRepositoryAdapter(jdbcTemplate);

        // WHEN
        FunctionalMetricsResponse response = adapter.loadFunctionalMetrics();

        // THEN
        assertThat(response.searchCount()).isEqualTo(7);
        assertThat(response.contactCount()).isEqualTo(6);
        assertThat(response.postContactFeedbackCount()).isEqualTo(5);
        assertThat(response.reviewCount()).isEqualTo(4);
        assertThat(response.acceptingNewClientsProfessionalCount()).isEqualTo(3);
        assertThat(response.availableTodayProfessionalCount()).isEqualTo(2);
        assertThat(response.rankingAlgorithmEnabled()).isFalse();
        assertThat(response.contactsByProfessional()).containsExactly(new ContactMetricResponse(professionalIdentifier, 6));
        assertThat(response.contactsByCategory()).containsExactly(new ContactMetricResponse(categoryIdentifier, 5));
        assertThat(response.contactsByCity()).containsExactly(new ContactMetricResponse(cityIdentifier, 4));
        assertThat(response.responsivenessSignals().getFirst().contactResponsiveness()).isEqualTo("FAST_RESPONSE");
        assertThat(response.reputationSignals().getFirst().averageRating()).isEqualTo(4.75);
    }

    private Object contactMetricFrom(RowMapper<?> rowMapper, UUID metricIdentifier, long contactCount) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("metric_identifier", UUID.class)).thenReturn(metricIdentifier);
        when(resultSet.getLong("contact_count")).thenReturn(contactCount);
        return rowMapper.mapRow(resultSet, 0);
    }

    private Object responsivenessMetricFrom(RowMapper<?> rowMapper) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getString("contact_responsiveness")).thenReturn("FAST_RESPONSE");
        when(resultSet.getLong("feedback_count")).thenReturn(2L);
        return rowMapper.mapRow(resultSet, 0);
    }

    private Object reputationMetricFrom(RowMapper<?> rowMapper, UUID professionalIdentifier) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(professionalIdentifier);
        when(resultSet.getDouble("average_rating")).thenReturn(4.75);
        when(resultSet.getLong("review_count")).thenReturn(3L);
        return rowMapper.mapRow(resultSet, 0);
    }
}
