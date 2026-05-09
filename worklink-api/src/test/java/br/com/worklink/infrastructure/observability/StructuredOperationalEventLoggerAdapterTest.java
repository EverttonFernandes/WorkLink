package br.com.worklink.infrastructure.observability;

import br.com.worklink.application.observability.usecase.OperationalEvent;
import br.com.worklink.application.observability.usecase.OperationalEventSeverity;
import br.com.worklink.application.observability.usecase.OperationalEventType;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThatCode;

class StructuredOperationalEventLoggerAdapterTest {

    @Test
    @DisplayName("GIVEN evento operacional com contexto sensivel WHEN logar THEN deve registrar sem excecao")
    void shouldRecordOperationalEventWithoutThrowingException() {
        // GIVEN
        StructuredOperationalEventLoggerAdapter structuredOperationalEventLoggerAdapter =
                new StructuredOperationalEventLoggerAdapter(new SensitiveLogValueSanitizer());
        OperationalEvent operationalEvent = new OperationalEvent(
                OperationalEventType.AUTHENTICATION_FLOW,
                OperationalEventSeverity.WARN,
                "Falha com otp=123456",
                Map.of("phoneNumber", "51999999999")
        );

        // WHEN / THEN
        assertThatCode(() -> structuredOperationalEventLoggerAdapter.recordOperationalEvent(operationalEvent))
                .doesNotThrowAnyException();
    }
}
