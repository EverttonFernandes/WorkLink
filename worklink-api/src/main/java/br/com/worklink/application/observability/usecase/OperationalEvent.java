package br.com.worklink.application.observability.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

import java.util.Map;

public record OperationalEvent(
        OperationalEventType operationalEventType,
        OperationalEventSeverity operationalEventSeverity,
        String message,
        Map<String, String> safeContext
) {

    public OperationalEvent {
        if (operationalEventType == null) {
            throw new ApplicationRuleViolationException("O tipo do evento operacional e obrigatorio.");
        }
        if (operationalEventSeverity == null) {
            throw new ApplicationRuleViolationException("A severidade do evento operacional e obrigatoria.");
        }
        if (message == null || message.isBlank()) {
            throw new ApplicationRuleViolationException("A mensagem do evento operacional e obrigatoria.");
        }
        safeContext = safeContext == null ? Map.of() : Map.copyOf(safeContext);
    }
}
