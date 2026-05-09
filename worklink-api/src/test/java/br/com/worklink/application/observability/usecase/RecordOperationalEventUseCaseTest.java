package br.com.worklink.application.observability.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.observability.port.RecordOperationalEventPort;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RecordOperationalEventUseCaseTest {

    @Test
    @DisplayName("GIVEN evento operacional WHEN registrar THEN deve encaminhar tipo severidade mensagem e contexto seguro")
    void shouldRecordOperationalEventWithTypeSeverityMessageAndSafeContext() {
        // GIVEN
        AtomicReference<OperationalEvent> recordedOperationalEvent = new AtomicReference<>();
        RecordOperationalEventPort recordOperationalEventPort = recordedOperationalEvent::set;
        RecordOperationalEventUseCase recordOperationalEventUseCase = new RecordOperationalEventUseCase(recordOperationalEventPort);
        OperationalEvent operationalEvent = new OperationalEvent(
                OperationalEventType.API_REQUEST_FAILURE,
                OperationalEventSeverity.ERROR,
                "Falha ao processar requisicao",
                Map.of("endpoint", "/api/v1/categories")
        );

        // WHEN
        recordOperationalEventUseCase.recordOperationalEvent(operationalEvent);

        // THEN
        assertThat(recordedOperationalEvent.get()).isEqualTo(operationalEvent);
    }

    @Test
    @DisplayName("GIVEN evento sem tipo WHEN construir THEN deve rejeitar")
    void shouldRejectOperationalEventWithoutType() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> new OperationalEvent(
                null,
                OperationalEventSeverity.ERROR,
                "Falha",
                Map.of()
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O tipo do evento operacional e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN evento sem severidade WHEN construir THEN deve rejeitar")
    void shouldRejectOperationalEventWithoutSeverity() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> new OperationalEvent(
                OperationalEventType.API_REQUEST_FAILURE,
                null,
                "Falha",
                Map.of()
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A severidade do evento operacional e obrigatoria.");
    }

    @Test
    @DisplayName("GIVEN evento sem mensagem WHEN construir THEN deve rejeitar")
    void shouldRejectOperationalEventWithoutMessage() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> new OperationalEvent(
                OperationalEventType.API_REQUEST_FAILURE,
                OperationalEventSeverity.ERROR,
                " ",
                Map.of()
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A mensagem do evento operacional e obrigatoria.");
    }

    @Test
    @DisplayName("GIVEN evento sem contexto WHEN construir THEN deve usar contexto vazio")
    void shouldUseEmptyContextWhenContextIsNotProvided() {
        // GIVEN / WHEN
        OperationalEvent operationalEvent = new OperationalEvent(
                OperationalEventType.STORAGE_FLOW,
                OperationalEventSeverity.INFO,
                "Arquivo preparado",
                null
        );

        // THEN
        assertThat(operationalEvent.safeContext()).isEmpty();
    }
}
