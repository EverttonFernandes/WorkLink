package br.com.worklink.application.metrics.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class FunctionalMetricsUseCaseTest {

    @Test
    @DisplayName("GIVEN busca com filtros WHEN registrar evento THEN deve persistir dados para ranking futuro")
    void shouldRecordProfessionalSearchEventWithFilters() {
        // GIVEN
        UUID categoryIdentifier = UUID.randomUUID();
        UUID cityIdentifier = UUID.randomUUID();
        AtomicReference<ProfessionalSearchEvent> savedSearchEvent = new AtomicReference<>();
        RecordProfessionalSearchEventUseCase useCase = new RecordProfessionalSearchEventUseCase(
                professionalSearchEvent -> {
                    savedSearchEvent.set(professionalSearchEvent);
                    return professionalSearchEvent;
                },
                () -> Instant.parse("2026-05-09T23:50:00Z")
        );

        // WHEN
        ProfessionalSearchEvent response = useCase.recordProfessionalSearchEvent(new RecordProfessionalSearchEventRequest(
                categoryIdentifier,
                Set.of(cityIdentifier),
                " eletricista ",
                12
        ));

        // THEN
        assertThat(response.professionalSearchEventIdentifier()).isNotNull();
        assertThat(savedSearchEvent.get().categoryIdentifier()).isEqualTo(categoryIdentifier);
        assertThat(savedSearchEvent.get().cityIdentifiers()).containsExactly(cityIdentifier);
        assertThat(savedSearchEvent.get().keyword()).isEqualTo("eletricista");
        assertThat(savedSearchEvent.get().resultCount()).isEqualTo(12);
        assertThat(savedSearchEvent.get().createdAt()).isEqualTo(Instant.parse("2026-05-09T23:50:00Z"));
    }

    @Test
    @DisplayName("GIVEN resultado negativo WHEN registrar evento THEN deve rejeitar metrica invalida")
    void shouldRejectNegativeSearchResultCount() {
        // GIVEN
        RecordProfessionalSearchEventUseCase useCase = new RecordProfessionalSearchEventUseCase(
                professionalSearchEvent -> professionalSearchEvent,
                () -> Instant.parse("2026-05-09T23:50:00Z")
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.recordProfessionalSearchEvent(new RecordProfessionalSearchEventRequest(
                null,
                Set.of(),
                null,
                -1
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A quantidade de resultados da busca nao pode ser negativa.");
    }

    @Test
    @DisplayName("GIVEN porta de metricas WHEN carregar sinais THEN deve retornar sem algoritmo de ranking")
    void shouldLoadFunctionalMetricsWithoutRankingAlgorithm() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        FunctionalMetricsResponse metricsResponse = new FunctionalMetricsResponse(
                10,
                8,
                6,
                4,
                3,
                2,
                false,
                List.of(new ContactMetricResponse(professionalIdentifier, 8)),
                List.of(),
                List.of(),
                List.of(new ResponsivenessMetricResponse("FAST_RESPONSE", 5)),
                List.of(new ReputationMetricResponse(professionalIdentifier, 4.5, 4))
        );
        LoadFunctionalMetricsUseCase useCase = new LoadFunctionalMetricsUseCase(() -> metricsResponse);

        // WHEN
        FunctionalMetricsResponse response = useCase.loadFunctionalMetrics();

        // THEN
        assertThat(response.searchCount()).isEqualTo(10);
        assertThat(response.rankingAlgorithmEnabled()).isFalse();
        assertThat(response.contactsByProfessional()).containsExactly(new ContactMetricResponse(professionalIdentifier, 8));
        assertThat(response.responsivenessSignals()).containsExactly(new ResponsivenessMetricResponse("FAST_RESPONSE", 5));
        assertThat(response.reputationSignals()).containsExactly(new ReputationMetricResponse(professionalIdentifier, 4.5, 4));
    }
}
