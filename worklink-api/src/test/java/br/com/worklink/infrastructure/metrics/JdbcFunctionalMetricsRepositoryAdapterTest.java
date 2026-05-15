package br.com.worklink.infrastructure.metrics;

import br.com.worklink.application.metrics.usecase.ContactMetricResponse;
import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;
import br.com.worklink.application.metrics.usecase.ProfessionalSearchEvent;
import br.com.worklink.application.metrics.usecase.ProfessionalMetricSummaryResponse;
import br.com.worklink.application.metrics.usecase.ReputationSummaryResponse;
import br.com.worklink.application.metrics.usecase.ResponsivenessSummaryResponse;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.Timestamp;
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
                eq(Timestamp.from(Instant.parse("2026-05-09T23:50:00Z")))
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
                .thenReturn(7L, 6L, 5L, 4L, 3L, 2L, 1L, 1L, 9L, 4L, 7L, 2L, 5L, 4L, 1L, 3L);
        when(jdbcTemplate.queryForObject(anyString(), eq(Double.class)))
                .thenReturn(4.25);
        when(jdbcTemplate.query(anyString(), any(RowMapper.class)))
                .thenAnswer(invocation -> List.of(contactMetricFrom(invocation.getArgument(1), categoryIdentifier, 7)))
                .thenAnswer(invocation -> List.of(contactMetricFrom(invocation.getArgument(1), cityIdentifier, 6)))
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
        assertThat(response.searchWithoutResultCount()).isEqualTo(1);
        assertThat(response.contactCount()).isEqualTo(6);
        assertThat(response.postContactFeedbackCount()).isEqualTo(5);
        assertThat(response.reviewCount()).isEqualTo(4);
        assertThat(response.anonymousReviewCount()).isEqualTo(3);
        assertThat(response.professionalReportCount()).isEqualTo(2);
        assertThat(response.reviewAnalysisRequestCount()).isEqualTo(1);
        assertThat(response.rankingAlgorithmEnabled()).isFalse();
        assertThat(response.searchesByCategory()).containsExactly(new ContactMetricResponse(categoryIdentifier, 7));
        assertThat(response.searchesByCity()).containsExactly(new ContactMetricResponse(cityIdentifier, 6));
        assertThat(response.contactsByProfessional()).containsExactly(new ContactMetricResponse(professionalIdentifier, 6));
        assertThat(response.contactsByCategory()).containsExactly(new ContactMetricResponse(categoryIdentifier, 5));
        assertThat(response.contactsByCity()).containsExactly(new ContactMetricResponse(cityIdentifier, 4));
        assertThat(response.professionalSummary()).isEqualTo(new ProfessionalMetricSummaryResponse(9, 4, 7, 2, 5));
        assertThat(response.responsivenessSummary()).isEqualTo(new ResponsivenessSummaryResponse(80, 20, 60, 83.33));
        assertThat(response.reputationSummary()).isEqualTo(new ReputationSummaryResponse(4, 4.25, 3, 2, 1));
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
